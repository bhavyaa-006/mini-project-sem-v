from bisect import bisect_left

from safescan_engines.health.weights import (
    ENERGY_KJ_THRESHOLDS,
    FIBER_G_THRESHOLDS,
    FVL_PERCENT_POINTS,
    NUTRI_SCORE_FVL_EXEMPTION_POINTS,
    NUTRI_SCORE_PROTEIN_CAP_N,
    PROTEIN_G_THRESHOLDS,
    SATURATED_FAT_G_THRESHOLDS,
    SODIUM_MG_THRESHOLDS,
    SUGARS_G_THRESHOLDS,
)
from safescan_engines.schemas import (
    DataStatus,
    HealthResult,
    NutrientProfile,
    NutriGrade,
    ProductDomain,
)


def score_strictly_above(value: float, thresholds: tuple[float, ...]) -> int:
    return bisect_left(thresholds, value)


def score_fvl_percent(fvl_percent: float) -> int:
    for threshold, points in FVL_PERCENT_POINTS:
        if fvl_percent > threshold:
            return points
    return 0


def map_raw_to_grade(raw_score: int) -> NutriGrade:
    if raw_score <= -1:
        return NutriGrade.A
    if raw_score <= 2:
        return NutriGrade.B
    if raw_score <= 10:
        return NutriGrade.C
    if raw_score <= 18:
        return NutriGrade.D
    return NutriGrade.E


def calculate_nutri_score(nutrients: NutrientProfile | None) -> HealthResult:
    if nutrients is None:
        return HealthResult(status=DataStatus.INSUFFICIENT_DATA, domain=ProductDomain.FOOD)

    values = (
        nutrients.energy_kj,
        nutrients.sugars_g,
        nutrients.saturated_fat_g,
        nutrients.sodium_mg,
        nutrients.fiber_g,
        nutrients.protein_g,
        nutrients.fvl_percent,
    )
    if any(value is None for value in values):
        return HealthResult(status=DataStatus.INSUFFICIENT_DATA, domain=ProductDomain.FOOD)

    energy_pts = score_strictly_above(nutrients.energy_kj, ENERGY_KJ_THRESHOLDS)
    sugars_pts = score_strictly_above(nutrients.sugars_g, SUGARS_G_THRESHOLDS)
    sat_fat_pts = score_strictly_above(nutrients.saturated_fat_g, SATURATED_FAT_G_THRESHOLDS)
    sodium_pts = score_strictly_above(nutrients.sodium_mg, SODIUM_MG_THRESHOLDS)
    fiber_pts = score_strictly_above(nutrients.fiber_g, FIBER_G_THRESHOLDS)
    protein_pts = score_strictly_above(nutrients.protein_g, PROTEIN_G_THRESHOLDS)
    fvl_pts = score_fvl_percent(nutrients.fvl_percent)

    n_points = energy_pts + sugars_pts + sat_fat_pts + sodium_pts
    if n_points >= NUTRI_SCORE_PROTEIN_CAP_N and fvl_pts < NUTRI_SCORE_FVL_EXEMPTION_POINTS:
        p_points = fiber_pts + fvl_pts
    else:
        p_points = fiber_pts + protein_pts + fvl_pts

    raw_score = n_points - p_points
    return HealthResult(
        status=DataStatus.OK,
        domain=ProductDomain.FOOD,
        nutri_raw_score=raw_score,
        nutri_grade=map_raw_to_grade(raw_score),
    )