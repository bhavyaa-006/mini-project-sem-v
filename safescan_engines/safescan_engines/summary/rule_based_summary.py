from collections.abc import Sequence

from safescan_engines.alternatives.recommender import AlternativeRecommendation
from safescan_engines.schemas import (
    ComplianceResult,
    ComplianceStatus,
    DataStatus,
    HealthResult,
    NormalizedProduct,
)


def generate_rule_based_highlights(
    product: NormalizedProduct,
    health: HealthResult,
    compliance: ComplianceResult,
    alternatives: Sequence[AlternativeRecommendation] = (),
) -> list[str]:
    bullets: list[str] = []

    if health.status != DataStatus.OK:
        bullets.append("Insufficient nutrition/ingredient data to compute full health score.")
    elif product.domain.value == "food":
        grade = health.nutri_grade.value if health.nutri_grade else "N/A"
        raw = health.nutri_raw_score
        balanced = "balanced nutritional profile." if grade in ("A", "B") else "nutritional profile needs improvement."
        bullets.append(f"Nutri-Score {grade} (Raw score: {raw}) — {balanced}")
        nutrients = product.nutrients
        if nutrients:
            for value, label, threshold, unit in (
                (nutrients.sugars_g, "sugar", 10.0, "g"),
                (nutrients.saturated_fat_g, "saturated fat", 5.0, "g"),
                (nutrients.sodium_mg, "sodium", 400.0, "mg"),
            ):
                if value is not None and value >= threshold:
                    bullets.append(f"High {label}: {value:.1f} {unit} per 100 g")
    else:
        score = health.cosmetic_score
        band = health.cosmetic_band.value if health.cosmetic_band else "Unknown"
        headline = f"Cosmetic Safety Score: {score}/100 ({band})"
        headline += " — capped due to high-severity ingredient." if health.capped_by_high_severity else "."
        bullets.append(headline)

    if product.domain.value == "cosmetic":
        severity_order = {"high": 0, "moderate": 1, "low": 2}
        deductions = sorted(
            health.deductions,
            key=lambda hit: (severity_order[hit.severity.value], hit.position),
        )
        for hit in deductions[:3]:
            position_note = "top-5 ingredient" if hit.position <= 5 else f"ingredient position {hit.position}"
            bullets.append(
                f"Flagged: {hit.matched_canonical} "
                f"({hit.severity.value.capitalize()} severity, {position_note})"
            )
    bullets.extend(f"Personal alert: {alert}" for alert in health.personal_alerts)

    failed = [check for check in compliance.checks if check.status == ComplianceStatus.FAIL]
    if compliance.overall_status == ComplianceStatus.PASS:
        bullets.append("Legal Metrology: Compliant across all verified mandatory declarations.")
    elif failed:
        first = failed[0]
        detail = first.note or "declaration requires review"
        bullets.append(f"Legal Metrology Alert: Failed Rule {first.clause_id} ({detail})")
    else:
        bullets.append("Legal Metrology: Partial label read — some declarations could not be verified.")

    if alternatives:
        alt = alternatives[0]
        reason = alt.why_reasons[0] if alt.why_reasons else "Better health score"
        name = alt.product.name or alt.product.brand or "Alternative product"
        bullets.append(f"Safer option available: {name} ({reason}).")
    return bullets