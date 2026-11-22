"""
Nutri-Score inspired health scoring for food products.
Returns (score 0-100, nutri_grade A-E or None).
"""
from typing import List, Tuple, Optional
from app.models.product import Product


def compute_nutri_score(product: Product, flagged: list) -> Tuple[float, Optional[str]]:
    """
    Simplified scoring:
      - Start at 100
      - Deduct 15 per high-hazard ingredient, 7 per moderate, 2 per low
      - Add bonus if nutri_score from OFF is good
    """
    score = 100.0

    # Deductions from hazardous ingredients
    for fi in flagged:
        if fi.hazard_level == "high":
            score -= 15
        elif fi.hazard_level == "moderate":
            score -= 7
        elif fi.hazard_level == "low":
            score -= 2

    # Bonus from Nutri-Score grade
    grade_bonus = {"A": 10, "B": 5, "C": 0, "D": -5, "E": -10}
    grade = (product.nutri_score or "").upper()
    score += grade_bonus.get(grade, 0)

    score = max(0.0, min(100.0, score))

    # Map to Nutri-Score grade if not already set
    nutri_grade = grade if grade in ("A", "B", "C", "D", "E") else _score_to_grade(score)
    return score, nutri_grade


def _score_to_grade(score: float) -> str:
    if score >= 80: return "A"
    if score >= 60: return "B"
    if score >= 40: return "C"
    if score >= 20: return "D"
    return "E"
