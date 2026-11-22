"""
Rule-based summary generator (no LLM required).
"""
from typing import List


def build_summary(product_name: str, score: float, flagged: list, lm_result) -> str:
    tier = "excellent" if score >= 75 else "good" if score >= 50 else "mediocre" if score >= 25 else "poor"
    high = [f.name for f in flagged if f.hazard_level == "high"]
    moderate = [f.name for f in flagged if f.hazard_level == "moderate"]

    parts = [f"{product_name} has a {tier} health score of {round(score)}/100."]

    if high:
        parts.append(f"High-concern ingredients detected: {', '.join(high[:3])}.")
    if moderate:
        parts.append(f"Moderate-concern ingredients: {', '.join(moderate[:3])}.")
    if not high and not moderate:
        parts.append("No major hazardous ingredients detected.")

    if lm_result.compliant:
        parts.append("Label is fully Legal Metrology compliant.")
    else:
        missing = lm_result.missing_fields
        parts.append(f"Label is missing {len(missing)} mandatory field(s): {', '.join(missing[:2])}.")

    return " ".join(parts)
