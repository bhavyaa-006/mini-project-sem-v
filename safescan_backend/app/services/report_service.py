"""
Report service – generates a PDF audit report using ReportLab.
"""
import os
import json
from datetime import datetime, timezone

from app.models.scan import Scan

REPORTS_DIR = "reports"
os.makedirs(REPORTS_DIR, exist_ok=True)


def generate_pdf_report(scan: Scan) -> str:
    """Generate a PDF audit report for the given scan and return its file path."""
    try:
        from reportlab.lib.pagesizes import A4
        from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
        from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
        from reportlab.lib import colors
        from reportlab.lib.units import cm

        pdf_path = os.path.join(REPORTS_DIR, f"report_{scan.id}.pdf")
        doc = SimpleDocTemplate(pdf_path, pagesize=A4, leftMargin=2*cm, rightMargin=2*cm)
        styles = getSampleStyleSheet()
        story = []

        title_style = ParagraphStyle("title", fontSize=18, spaceAfter=10, fontName="Helvetica-Bold")
        heading_style = ParagraphStyle("heading", fontSize=13, spaceAfter=6, fontName="Helvetica-Bold")
        body_style = styles["BodyText"]

        story.append(Paragraph("SafeScan & PackCheck – Audit Report", title_style))
        story.append(Paragraph(f"Generated: {datetime.now(timezone.utc).strftime('%d %B %Y, %H:%M UTC')}", body_style))
        story.append(Spacer(1, 0.5*cm))

        result = scan.result
        product = scan.product

        if product:
            story.append(Paragraph("Product Information", heading_style))
            data = [
                ["Field", "Value"],
                ["Product Name", product.name or "—"],
                ["Brand", product.brand or "—"],
                ["Category", product.category or "—"],
                ["Barcode", product.barcode or "—"],
                ["Nutri-Score", product.nutri_score or "—"],
            ]
            t = Table(data, colWidths=[6*cm, 11*cm])
            t.setStyle(TableStyle([
                ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#2C3E50")),
                ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
                ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
                ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.HexColor("#F8F9FA"), colors.white]),
                ("GRID", (0, 0), (-1, -1), 0.5, colors.grey),
                ("FONTSIZE", (0, 0), (-1, -1), 10),
                ("PADDING", (0, 0), (-1, -1), 6),
            ]))
            story.append(t)
            story.append(Spacer(1, 0.4*cm))

        if result:
            story.append(Paragraph("Health & Compliance Summary", heading_style))
            summary_data = [
                ["Metric", "Value"],
                ["Health Score", f"{result.health_score or 0:.1f} / 100"],
                ["Rating", result.rating_tier or "—"],
                ["Legal Metrology Compliant", "Yes" if result.is_compliant else "No"],
                ["Compliance Score", f"{result.compliance_score or 0:.1f}%"],
            ]
            t2 = Table(summary_data, colWidths=[8*cm, 9*cm])
            t2.setStyle(TableStyle([
                ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#27AE60")),
                ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
                ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
                ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.HexColor("#F8F9FA"), colors.white]),
                ("GRID", (0, 0), (-1, -1), 0.5, colors.grey),
                ("FONTSIZE", (0, 0), (-1, -1), 10),
                ("PADDING", (0, 0), (-1, -1), 6),
            ]))
            story.append(t2)
            story.append(Spacer(1, 0.4*cm))

            if result.missing_fields:
                story.append(Paragraph("Missing Label Fields", heading_style))
                try:
                    missing = json.loads(result.missing_fields)
                    for field in missing:
                        story.append(Paragraph(f"• {field}", body_style))
                except Exception:
                    story.append(Paragraph(result.missing_fields, body_style))
                story.append(Spacer(1, 0.3*cm))

        story.append(Paragraph("Disclaimer", heading_style))
        story.append(Paragraph(
            "This report is generated automatically by SafeScan AI for educational purposes. "
            "It is not a substitute for professional regulatory advice.",
            body_style,
        ))

        doc.build(story)
        return pdf_path
    except Exception as e:
        print(f"[report_service] PDF generation failed: {e}")
        return None
