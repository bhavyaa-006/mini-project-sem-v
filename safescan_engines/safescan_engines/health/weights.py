from typing import Final

from safescan_engines.schemas import CosmeticBand, NutriGrade, SeverityTier


ENERGY_KJ_THRESHOLDS: Final[tuple[float, ...]] = (335, 670, 1005, 1340, 1675, 2010, 2345, 2680, 3015, 3350)
SUGARS_G_THRESHOLDS: Final[tuple[float, ...]] = (4.5, 9.0, 13.5, 18.0, 22.5, 27.0, 31.0, 36.0, 40.0, 45.0)
SATURATED_FAT_G_THRESHOLDS: Final[tuple[float, ...]] = (1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0)
SODIUM_MG_THRESHOLDS: Final[tuple[float, ...]] = (90, 180, 270, 360, 450, 540, 630, 720, 810, 900)
FIBER_G_THRESHOLDS: Final[tuple[float, ...]] = (0.9, 1.9, 2.8, 3.7, 4.7)
PROTEIN_G_THRESHOLDS: Final[tuple[float, ...]] = (1.6, 3.2, 4.8, 6.4, 8.0)
FVL_PERCENT_POINTS: Final[tuple[tuple[float, int], ...]] = ((80.0, 5), (60.0, 2), (40.0, 1))
NUTRI_SCORE_PROTEIN_CAP_N: Final[int] = 11
NUTRI_SCORE_FVL_EXEMPTION_POINTS: Final[int] = 5
NUTRI_GRADE_MAX_THRESHOLDS: Final[tuple[tuple[int, NutriGrade], ...]] = (
    (-1, NutriGrade.A),
    (2, NutriGrade.B),
    (10, NutriGrade.C),
    (18, NutriGrade.D),
)

COSMETIC_BASE_SCORE: Final[int] = 100
SEVERITY_WEIGHTS: Final[dict[SeverityTier, float]] = {
    SeverityTier.HIGH: 20.0,
    SeverityTier.MODERATE: 10.0,
    SeverityTier.LOW: 3.0,
}
POSITION_MULTIPLIERS: Final[tuple[tuple[int, float], ...]] = ((5, 1.0), (10, 0.7))
POSITION_DEFAULT_MULTIPLIER: Final[float] = 0.4
HIGH_SEVERITY_SCORE_CAP: Final[int] = 49
COSMETIC_BAND_MIN_THRESHOLDS: Final[tuple[tuple[int, CosmeticBand], ...]] = (
    (80, CosmeticBand.GOOD),
    (60, CosmeticBand.FAIR),
    (40, CosmeticBand.CAUTION),
)