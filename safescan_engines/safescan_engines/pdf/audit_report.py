import io
from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.units import mm
from reportlab.platypus import (
    KeepTogether,
    Paragraph,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)

from safescan_engines.pdf.styles import (
    BORDER_MINT,
    CARD_BG,
    GRADE_COLORS,
    MINT_BG,
    PRIMARY_GREEN,
    STATUS_COLORS,
    TEXT_DARK,
    TEXT_MUTED,
    get_report_styles,
)
from safescan_engines.schemas import AuditReportPayload, ComplianceStatus, ProductDomain


def _styled_paragraph(text: str, style_name: str, styles: dict) -> Paragraph:
    return Paragraph(text.replace("&", "&amp;"), styles[style_name])


def _header_table(payload: AuditReportPayload, styles: dict) -> Table:
    product = payload.product
    title = "SafeScan &amp; PackCheck AI — Product Audit Report"
    subtitle = (
        f"{product.name or 'Unnamed Product'}"
        f"{' | ' + product.brand if product.brand else ''}"
        f"{' | Barcode: ' + product.barcode if product.barcode else ''}"
        f"{' | Category: ' + product.category if product.category else ''}"
        f" | Source: {product.source}"
    )
    table = Table([[
        [_styled_paragraph(title, "Title", styles),
         _styled_paragraph(subtitle, "Subtitle", styles)]
    ]], colWidths=[170 * mm])
    table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), PRIMARY_GREEN),
        ("BOX", (0, 0), (-1, -1), 0.5, PRIMARY_GREEN),
        ("TOPPADDING", (0, 0), (-1, -1), 7 * mm),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 7 * mm),
    ]))
    return table


def _score_strip(payload: AuditReportPayload, styles: dict) -> Table:
    health = payload.health
    if payload.product.domain == ProductDomain.FOOD:
        grade = health.nutri_grade.value if health.nutri_grade else "N/A"
        grade_color = GRADE_COLORS.get(grade, TEXT_MUTED)
        left = (
            "<b>Engine B — Health &amp; Safety</b><br/>"
            f"<font color='{grade_color.hexval()}'><b>Nutri-Score {grade}</b></font>"
            f" | Raw score: {health.nutri_raw_score if health.nutri_raw_score is not None else 'N/A'}"
        )
    else:
        score = health.cosmetic_score
        band = health.cosmetic_band.value if health.cosmetic_band else "Unknown"
        left = (
            "<b>Engine B — Health &amp; Safety</b><br/>"
            f"Cosmetic Safety Score: {score if score is not None else 'N/A'}/100 "
            f"({band})"
            + ("<br/><b>High-severity cap applied</b>" if health.capped_by_high_severity else "")
        )

    status = payload.compliance.overall_status
    status_label = {
        ComplianceStatus.PASS: "COMPLIANT",
        ComplianceStatus.FAIL: "NON-COMPLIANT",
        ComplianceStatus.UNKNOWN: "INCOMPLETE DATA",
    }[status]
    right = (
        "<b>Engine A — Legal Metrology</b><br/>"
        f"<b>{status_label}</b>"
        + ("<br/><font color='#DC2626'><b>Dual-MRP alert</b></font>" if payload.compliance.dual_mrp_detected else "")
    )
    table = Table([
        [_styled_paragraph(left, "BodyText", styles),
         _styled_paragraph(right, "BodyText", styles)]
    ], colWidths=[82 * mm, 82 * mm])
    table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), MINT_BG),
        ("BOX", (0, 0), (-1, -1), 0.8, BORDER_MINT),
        ("INNERGRID", (0, 0), (-1, -1), 0.4, BORDER_MINT),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("LEFTPADDING", (0, 0), (-1, -1), 4 * mm),
        ("RIGHTPADDING", (0, 0), (-1, -1), 4 * mm),
        ("TOPPADDING", (0, 0), (-1, -1), 4 * mm),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 4 * mm),
    ]))
    return table


def build_audit_pdf_bytes(
    payload: AuditReportPayload,
    alternative_reasons: dict[str, list[str]] | None = None,
) -> bytes:
    styles = get_report_styles()
    buffer = io.BytesIO()
    doc = SimpleDocTemplate(
        buffer, pagesize=A4,
        rightMargin=18 * mm, leftMargin=18 * mm,
        topMargin=12 * mm, bottomMargin=14 * mm,
        title="SafeScan & PackCheck AI — Product Audit Report",
    )
    story = [
        _header_table(payload, styles),
        Spacer(1, 4 * mm),
        _score_strip(payload, styles),
    ]

    story.append(_styled_paragraph("Key Highlights", "SectionHeader", styles))
    for highlight in payload.summary_highlights:
        story.append(_styled_paragraph(f"• {highlight}", "BodyText", styles))
    if payload.health.personal_alerts:
        alert_table = Table([[_styled_paragraph(
            "<b>Personal Alerts:</b> " + "; ".join(payload.health.personal_alerts),
            "BodyText",
            styles,
        )]], colWidths=[164 * mm])
        alert_table.setStyle(TableStyle([
            ("BACKGROUND", (0, 0), (-1, -1), colors.HexColor("#FEE2E2")),
            ("BOX", (0, 0), (-1, -1), 0.7, colors.HexColor("#DC2626")),
            ("LEFTPADDING", (0, 0), (-1, -1), 3 * mm),
            ("RIGHTPADDING", (0, 0), (-1, -1), 3 * mm),
            ("TOPPADDING", (0, 0), (-1, -1), 3 * mm),
            ("BOTTOMPADDING", (0, 0), (-1, -1), 3 * mm),
        ]))
        story.append(alert_table)

    story.append(_styled_paragraph("Engine B Details", "SectionHeader", styles))
    if payload.product.domain == ProductDomain.FOOD:
        nutrients = payload.product.nutrients
        rows = [["Nutrient", "Per 100 g"]]
        if nutrients:
            rows.extend([
                ["Energy", f"{nutrients.energy_kj:.1f} kJ" if nutrients.energy_kj is not None else "N/A"],
                ["Sugars", f"{nutrients.sugars_g:.1f} g" if nutrients.sugars_g is not None else "N/A"],
                ["Saturated Fat", f"{nutrients.saturated_fat_g:.1f} g" if nutrients.saturated_fat_g is not None else "N/A"],
                ["Sodium", f"{nutrients.sodium_mg:.1f} mg" if nutrients.sodium_mg is not None else "N/A"],
                ["Fiber", f"{nutrients.fiber_g:.1f} g" if nutrients.fiber_g is not None else "N/A"],
                ["Protein", f"{nutrients.protein_g:.1f} g" if nutrients.protein_g is not None else "N/A"],
                ["Fruits/Veg/Nuts", f"{nutrients.fvl_percent:.1f}%" if nutrients.fvl_percent is not None else "N/A"],
            ])
        table = Table(rows, colWidths=[82 * mm, 82 * mm], repeatRows=1)
        table.setStyle(TableStyle([
            ("BACKGROUND", (0, 0), (-1, 0), PRIMARY_GREEN),
            ("TEXTCOLOR", (0, 0), (-1, 0), CARD_BG),
            ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
            ("GRID", (0, 0), (-1, -1), 0.35, BORDER_MINT),
            ("FONTNAME", (0, 1), (-1, -1), "Helvetica"),
            ("FONTSIZE", (0, 0), (-1, -1), 8),
            ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ]))
        story.append(table)
    else:
        rows = [["#", "Ingredient", "Match", "Severity", "Pos", "Deduction", "Reason"]]
        for index, hit in enumerate(payload.health.deductions, start=1):
            rows.append([
                str(index), hit.matched_canonical, hit.match_type,
                hit.severity.value, str(hit.position),
                f"{hit.points_deducted:.1f}", hit.reason,
            ])
        table = Table(rows, colWidths=[8 * mm, 32 * mm, 16 * mm, 18 * mm, 10 * mm, 16 * mm, 64 * mm], repeatRows=1)
        table.setStyle(TableStyle([
            ("BACKGROUND", (0, 0), (-1, 0), PRIMARY_GREEN),
            ("TEXTCOLOR", (0, 0), (-1, 0), CARD_BG),
            ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
            ("GRID", (0, 0), (-1, -1), 0.35, BORDER_MINT),
            ("FONTSIZE", (0, 0), (-1, -1), 7),
            ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ]))
        story.append(table)

    story.append(_styled_paragraph("Engine A — Legal Metrology Clause Audit", "SectionHeader", styles))
    clause_rows = [["Clause", "Declaration Requirement", "Extracted Value", "Status"]]
    for check in payload.compliance.checks:
        status_color = STATUS_COLORS[check.status.value].hexval()
        clause_rows.append([
            check.clause_id,
            check.title,
            check.extracted_value or "N/A",
            f"<font color='{status_color}'><b>{check.status.value}</b></font>",
        ])
    clause_table = Table(clause_rows, colWidths=[22 * mm, 62 * mm, 50 * mm, 30 * mm], repeatRows=1)
    clause_table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), PRIMARY_GREEN),
        ("TEXTCOLOR", (0, 0), (-1, 0), CARD_BG),
        ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
        ("GRID", (0, 0), (-1, -1), 0.35, BORDER_MINT),
        ("FONTSIZE", (0, 0), (-1, -1), 7),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
    ]))
    story.append(clause_table)

    if payload.alternatives:
        story.append(_styled_paragraph("Safer Alternatives", "SectionHeader", styles))
        reasons = alternative_reasons or {}
        for alternative in payload.alternatives:
            key = alternative.barcode or alternative.name or "alternative"
            why = reasons.get(key, [])
            text = (
                f"<b>{alternative.name or 'Unnamed Product'}</b>"
                f"{' | ' + alternative.brand if alternative.brand else ''}"
            )
            if alternative.domain == ProductDomain.FOOD:
                text += "<br/>Alternative available in the selected category."
            story.append(_styled_paragraph(text, "BodyText", styles))
            for reason in why:
                story.append(_styled_paragraph(f"• {reason}", "SmallMuted", styles))

    disclaimer = (
        "Informational academic audit. Statutory compliance should be confirmed against "
        "the applicable Legal Metrology requirements and current official guidance."
    )
    if payload.product.source in ("off", "obf"):
        disclaimer += " Product data source: Open Food Facts / Open Beauty Facts (ODbL)."
    story.append(Spacer(1, 5 * mm))
    story.append(_styled_paragraph(disclaimer, "SmallMuted", styles))

    doc.build(story)
    pdf_bytes = buffer.getvalue()
    buffer.close()
    return pdf_bytes


def write_audit_pdf(payload: AuditReportPayload, output_path: str | Path) -> Path:
    path = Path(output_path)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(build_audit_pdf_bytes(payload))
    return path