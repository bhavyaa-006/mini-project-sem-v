"""
Cosmetic safety scoring (0-100).
"""
from app.models.product import Product


def compute_cosmetic_score(product: Product, flagged: list) -> float:
    score = 100.0
    for fi in flagged:
        if fi.hazard_level == "high":
            score -= 20
        elif fi.hazard_level == "moderate":
            score -= 10
        elif fi.hazard_level == "low":
            score -= 3
    return max(0.0, min(100.0, score))
