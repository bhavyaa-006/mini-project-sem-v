"""
Core analysis service: combines health scoring + legal metrology
into a single ProductAnalysisResponse.
"""
import json
import uuid
from datetime import datetime, timezone
from typing import Optional, List
from sqlalchemy.orm import Session

from app.models.hazard_ingredient import HazardIngredient
from app.models.product import Product
from app.schemas.analysis import (
    ProductAnalysisResponse, FlaggedIngredient, LegalMetrology, AlternativeProduct
)
from app.engines.health.nutri_score import compute_nutri_score
from app.engines.health.cosmetic_score import compute_cosmetic_score
from app.engines.health.ingredient_matcher import match_hazard_ingredients
from app.engines.legal_metrology.rules import check_legal_metrology
from app.engines.alternatives.recommender import recommend_alternatives
from app.engines.summary.rule_based_summary import build_summary


def _rating_tier(score: float) -> str:
    if score >= 75:
        return "excellent"
    if score >= 50:
        return "good"
    if score >= 25:
        return "mediocre"
    return "poor"


def _rating_label(tier: str) -> str:
    return {"excellent": "Excellent", "good": "Good",
            "mediocre": "Mediocre", "poor": "Poor / Risky"}.get(tier, "Unknown")


def analyze_product(
    db: Session,
    product: Product,
    ocr_text: Optional[str] = None,
    user_allergies: Optional[List[str]] = None,
    user_skin_type: Optional[str] = None,
) -> ProductAnalysisResponse:
    """Run full analysis and return response schema."""

    ingredients_text = ocr_text or product.ingredients_text or ""
    ingredient_list = [i.strip() for i in ingredients_text.split(",") if i.strip()]

    # ── Hazard Matching ──────────────────────────────────────────────────────
    hazard_records = db.query(HazardIngredient).filter(
        HazardIngredient.category == product.category
    ).all()
    flagged = match_hazard_ingredients(ingredient_list, hazard_records)

    # ── Health Score ─────────────────────────────────────────────────────────
    if product.category == "food":
        score, nutri_score = compute_nutri_score(product, flagged)
        safety_score = None
    else:
        score, nutri_score = compute_cosmetic_score(product, flagged), None
        safety_score = score

    # ── Legal Metrology ──────────────────────────────────────────────────────
    lm_result = check_legal_metrology(ocr_text or "", product.category)

    # ── Alternatives ─────────────────────────────────────────────────────────
    alternatives = recommend_alternatives(db, product, score)

    # ── Positive / Negative points ───────────────────────────────────────────
    positive_points: List[str] = []
    negative_points: List[str] = []

    if score >= 75:
        positive_points.append("Overall health score is excellent.")
    if nutri_score in ("A", "B"):
        positive_points.append(f"Nutri-Score grade {nutri_score} — nutritionally strong.")
    if lm_result.compliant:
        positive_points.append("All mandatory label fields present (Legal Metrology compliant).")

    high_hazards = [f for f in flagged if f.hazard_level == "high"]
    if high_hazards:
        negative_points.append(f"{len(high_hazards)} high-hazard ingredient(s) found: "
                               f"{', '.join(f.name for f in high_hazards[:3])}.")
    if lm_result.missing_fields:
        negative_points.append(f"Missing label fields: {', '.join(lm_result.missing_fields[:3])}.")
    if score < 25:
        negative_points.append("Very low health score — consider a healthier alternative.")

    # ── Summary ──────────────────────────────────────────────────────────────
    summary = build_summary(product.name, score, flagged, lm_result)

    tier = _rating_tier(score)
    return ProductAnalysisResponse(
        id=str(product.id),
        barcode=product.barcode,
        name=product.name,
        brand=product.brand or "",
        category=product.category,
        score=round(score, 1),
        rating_tier=tier,
        rating_label=_rating_label(tier),
        nutri_score=nutri_score,
        safety_score=round(safety_score, 1) if safety_score is not None else None,
        summary=summary,
        image_url=product.image_url,
        ingredients_text=ingredients_text,
        ingredients_list=ingredient_list,
        flagged_ingredients=flagged,
        positive_points=positive_points,
        negative_points=negative_points,
        legal_metrology=lm_result,
        alternatives=alternatives,
        scanned_at=datetime.now(timezone.utc).isoformat(),
        pack_verified=lm_result.compliant,
    )
