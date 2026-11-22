from collections.abc import Sequence

from safescan_engines.config import settings
from safescan_engines.schemas import (
    CosmeticBand,
    DataStatus,
    HealthResult,
    ProductDomain,
    SeverityTier,
)
from safescan_engines.health.ingredient_matcher import (
    HazardEntry,
    match_ingredients,
    split_ingredients,
)
from safescan_engines.health.weights import (
    COSMETIC_BASE_SCORE,
    HIGH_SEVERITY_SCORE_CAP,
    POSITION_DEFAULT_MULTIPLIER,
    POSITION_MULTIPLIERS,
    SEVERITY_WEIGHTS,
)


def get_position_multiplier(position: int) -> float:
    if position <= 5:
        return POSITION_MULTIPLIERS[0][1]
    if position <= 10:
        return POSITION_MULTIPLIERS[1][1]
    return POSITION_DEFAULT_MULTIPLIER


def map_score_to_band(score: int) -> CosmeticBand:
    if score >= 80:
        return CosmeticBand.GOOD
    if score >= 60:
        return CosmeticBand.FAIR
    if score >= 40:
        return CosmeticBand.CAUTION
    return CosmeticBand.AVOID


def calculate_cosmetic_score(
    ingredients_raw: str | None,
    ingredients_list: list[str],
    catalog: Sequence[HazardEntry],
    threshold: int = settings.fuzzy_match_threshold,
) -> HealthResult:
    tokens = ingredients_list if ingredients_list else split_ingredients(ingredients_raw)
    if not tokens:
        return HealthResult(
            status=DataStatus.INSUFFICIENT_DATA,
            domain=ProductDomain.COSMETIC,
        )

    hits = match_ingredients(
        tokens,
        catalog,
        threshold=threshold,
        domain=ProductDomain.COSMETIC,
    )
    updated_hits = []
    total_deduction = 0.0
    for hit in hits:
        factor = get_position_multiplier(hit.position)
        points = round(SEVERITY_WEIGHTS[hit.severity] * factor, 2)
        total_deduction += points
        updated_hits.append(
            hit.model_copy(
                update={
                    "position_factor": factor,
                    "points_deducted": points,
                }
            )
        )

    raw_score = round(max(0.0, float(COSMETIC_BASE_SCORE) - total_deduction))
    capped = any(hit.severity == SeverityTier.HIGH for hit in updated_hits)
    final_score = min(raw_score, HIGH_SEVERITY_SCORE_CAP) if capped else raw_score

    return HealthResult(
        status=DataStatus.OK,
        domain=ProductDomain.COSMETIC,
        cosmetic_score=final_score,
        cosmetic_band=map_score_to_band(final_score),
        capped_by_high_severity=capped,
        deductions=updated_hits,
    )