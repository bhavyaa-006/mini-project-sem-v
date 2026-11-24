from collections.abc import Sequence

from pydantic import BaseModel
from sqlalchemy.orm import Session

from safescan_engines.data_sources.cache import get_products_by_category
from safescan_engines.health.cosmetic_score import calculate_cosmetic_score
from safescan_engines.health.ingredient_matcher import HazardEntry
from safescan_engines.health.nutri_score import calculate_nutri_score
from safescan_engines.schemas import (
    DataStatus,
    HealthResult,
    NormalizedProduct,
    NutriGrade,
    SeverityTier,
)


class AlternativeRecommendation(BaseModel):
    product: NormalizedProduct
    health: HealthResult
    why_reasons: list[str]


def _grade_index(grade: NutriGrade | None) -> int:
    if grade is None:
        return 5
    return ["A", "B", "C", "D", "E"].index(grade.value)


def _reduction(target: float | None, candidate: float | None) -> float | None:
    if target is None or candidate is None or target <= 0:
        return None
    return (target - candidate) / target * 100


def rank_and_explain_alternatives(
    target_product: NormalizedProduct,
    target_health: HealthResult,
    candidates: Sequence[NormalizedProduct],
    catalog: Sequence[HazardEntry] = (),
    limit: int = 3,
) -> list[AlternativeRecommendation]:
    if target_health.status != DataStatus.OK:
        return []

    recommendations: list[AlternativeRecommendation] = []
    for candidate in candidates:
        if candidate.barcode == target_product.barcode:
            continue
        if candidate.domain != target_product.domain:
            continue

        if target_product.domain.value == "food":
            if target_health.nutri_raw_score is None or candidate.nutrients is None:
                continue
            candidate_health = calculate_nutri_score(candidate.nutrients)
            if candidate_health.status != DataStatus.OK:
                continue
            if candidate_health.nutri_raw_score is None:
                continue
            if candidate_health.nutri_raw_score >= target_health.nutri_raw_score:
                continue
            if _grade_index(candidate_health.nutri_grade) > _grade_index(target_health.nutri_grade):
                continue

            reasons: list[str] = []
            if candidate_health.nutri_grade and target_health.nutri_grade:
                reasons.append(
                    f"Nutri-Score {candidate_health.nutri_grade.value} vs "
                    f"{target_health.nutri_grade.value}"
                )
            target_nutrients = target_product.nutrients
            candidate_nutrients = candidate.nutrients
            if target_nutrients and candidate_nutrients:
                for field, label, unit in (
                    ("sugars_g", "less sugar", "g"),
                    ("saturated_fat_g", "less saturated fat", "g"),
                    ("sodium_mg", "less sodium", "mg"),
                ):
                    target_value = getattr(target_nutrients, field)
                    candidate_value = getattr(candidate_nutrients, field)
                    reduction = _reduction(target_value, candidate_value)
                    if reduction is not None and reduction >= 15:
                        reasons.append(f"{reduction:.0f}% {label}")
                for field, label in (("fiber_g", "more fiber"), ("protein_g", "more protein")):
                    target_value = getattr(target_nutrients, field)
                    candidate_value = getattr(candidate_nutrients, field)
                    if candidate_value is not None and target_value is not None and candidate_value > target_value:
                        reasons.append(f"{label}")
            recommendations.append(
                AlternativeRecommendation(product=candidate, health=candidate_health, why_reasons=reasons)
            )
        else:
            if target_health.cosmetic_score is None:
                continue
            candidate_health = calculate_cosmetic_score(
                candidate.ingredients_raw,
                candidate.ingredients_list,
                catalog,
            )
            if (
                candidate_health.status != DataStatus.OK
                or candidate_health.cosmetic_score is None
                or candidate_health.cosmetic_score <= target_health.cosmetic_score
                or candidate_health.capped_by_high_severity
            ):
                continue

            reasons = [
                f"Safety Score {candidate_health.cosmetic_score}/100 "
                f"({candidate_health.cosmetic_band.value if candidate_health.cosmetic_band else 'Unknown'}) "
                f"vs {target_health.cosmetic_score}/100 "
                f"({target_health.cosmetic_band.value if target_health.cosmetic_band else 'Unknown'})"
            ]
            avoided = {
                hit.matched_canonical
                for hit in target_health.deductions
                if hit.severity in (SeverityTier.HIGH, SeverityTier.MODERATE)
                and hit.matched_canonical not in {
                    deduction.matched_canonical for deduction in candidate_health.deductions
                }
            }
            if avoided:
                reasons.append("Avoids " + ", ".join(sorted(avoided)))
            recommendations.append(
                AlternativeRecommendation(product=candidate, health=candidate_health, why_reasons=reasons)
            )

    if target_product.domain.value == "food":
        recommendations.sort(
            key=lambda item: (
                item.health.nutri_raw_score if item.health.nutri_raw_score is not None else 999,
                item.product.barcode or "",
            )
        )
    else:
        recommendations.sort(
            key=lambda item: (
                -(item.health.cosmetic_score if item.health.cosmetic_score is not None else -1),
                item.product.barcode or "",
            )
        )
    return recommendations[: max(0, limit)]


def recommend_alternatives(
    session: Session,
    target_product: NormalizedProduct,
    target_health: HealthResult,
    catalog: Sequence[HazardEntry] = (),
    limit: int = 3,
) -> list[AlternativeRecommendation]:
    if target_product.category is None or target_health.status != DataStatus.OK:
        return []
    candidates = get_products_by_category(
        session,
        category=target_product.category,
        domain=target_product.domain,
        exclude_barcode=target_product.barcode,
        limit=25,
    )
    return rank_and_explain_alternatives(
        target_product,
        target_health,
        candidates,
        catalog=catalog,
        limit=limit,
    )