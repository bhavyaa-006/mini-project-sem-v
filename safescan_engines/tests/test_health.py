import pytest

from safescan_engines.health.cosmetic_score import (
    calculate_cosmetic_score,
    get_position_multiplier,
)
from safescan_engines.health.ingredient_matcher import (
    HazardEntry,
    normalize_token,
    split_ingredients,
)
from safescan_engines.health.nutri_score import (
    calculate_nutri_score,
    map_raw_to_grade,
    score_fvl_percent,
    score_strictly_above,
)
from safescan_engines.health.personal_flags import check_personal_flags
from safescan_engines.schemas import (
    DataStatus,
    NutrientProfile,
    NutriGrade,
    ProductDomain,
    SeverityTier,
)
from safescan_engines.health.weights import ENERGY_KCAL_THRESHOLDS


def test_unhealthy_and_healthy_nutri_examples():
    unhealthy = calculate_nutri_score(
        NutrientProfile(
            energy_kcal=454,
            sugars_g=25,
            saturated_fat_g=8,
            sodium_mg=400,
            fiber_g=2,
            protein_g=6,
            fvl_percent=0,
        )
    )
    assert unhealthy.nutri_raw_score >= 19
    assert unhealthy.nutri_grade == NutriGrade.E

    healthy = calculate_nutri_score(
        NutrientProfile(
            energy_kcal=36,
            sugars_g=2,
            saturated_fat_g=0.2,
            sodium_mg=20,
            fiber_g=3,
            protein_g=4,
            fvl_percent=90,
        )
    )
    assert healthy.nutri_raw_score == -10
    assert healthy.nutri_grade == NutriGrade.A


def test_nutri_boundaries_and_grade_edges():
    assert score_strictly_above(80.0, ENERGY_KCAL_THRESHOLDS) == 0
    assert score_strictly_above(80.1, ENERGY_KCAL_THRESHOLDS) == 1
    assert score_fvl_percent(40.0) == 0
    assert score_fvl_percent(40.1) == 1

    grade_edges = {
        -1: NutriGrade.A,
        0: NutriGrade.B,
        2: NutriGrade.B,
        3: NutriGrade.C,
        10: NutriGrade.C,
        11: NutriGrade.D,
        18: NutriGrade.D,
        19: NutriGrade.E,
    }
    for raw_score, grade in grade_edges.items():
        assert map_raw_to_grade(raw_score) == grade


def test_nutri_insufficient_data():
    result = calculate_nutri_score(
        NutrientProfile(
            energy_kcal=24,
            sugars_g=None,
            saturated_fat_g=1,
            sodium_mg=100,
            fiber_g=2,
            protein_g=3,
            fvl_percent=50,
        )
    )
    assert result.status == DataStatus.INSUFFICIENT_DATA


def test_nutri_n_equals_11_protein_rule():
    low_fvl = calculate_nutri_score(
        NutrientProfile(
            energy_kcal=0,
            sugars_g=0,
            saturated_fat_g=2.1,
            sodium_mg=900,
            fiber_g=0.9,
            protein_g=8,
            fvl_percent=50,
        )
    )
    assert low_fvl.nutri_raw_score == 10

    high_fvl = calculate_nutri_score(
        NutrientProfile(
            energy_kcal=0,
            sugars_g=0,
            saturated_fat_g=2.1,
            sodium_mg=900,
            fiber_g=0.9,
            protein_g=8,
            fvl_percent=85,
        )
    )
    assert high_fvl.nutri_raw_score == 2


def test_ingredient_split_and_normalization():
    assert split_ingredients(
        "Aqua (Water), Parfum (Fragrance, Linalool), BHT"
    ) == ["Aqua (Water)", "Parfum (Fragrance, Linalool)", "BHT"]
    assert normalize_token("Sodium Lauryl Sulphate (2%)") == "sodium lauryl sulfate"
    assert normalize_token("INS 211") == "ins211"
    assert normalize_token("INS-211") == "ins211"
    assert normalize_token("E-211") == "e211"


def test_exact_fuzzy_and_short_token_matching():
    catalog = [
        HazardEntry(
            canonical_name="Sodium Lauryl Sulfate",
            aliases=["SLS"],
            severity=SeverityTier.MODERATE,
            domain=ProductDomain.COSMETIC,
            reason="Potential irritant",
        ),
        HazardEntry(
            canonical_name="Sodium Benzoate",
            aliases=["INS 211", "E211"],
            severity=SeverityTier.LOW,
            domain=ProductDomain.COSMETIC,
            reason="Preservative",
        ),
        HazardEntry(
            canonical_name="Phenoxyethanol",
            aliases=[],
            severity=SeverityTier.MODERATE,
            domain=ProductDomain.COSMETIC,
            reason="Preservative",
        ),
        HazardEntry(
            canonical_name="BHT",
            aliases=[],
            severity=SeverityTier.LOW,
            domain=ProductDomain.COSMETIC,
            reason="Antioxidant",
        ),
    ]

    from safescan_engines.health.ingredient_matcher import match_ingredients

    hits = match_ingredients(
        ["Sodium Lauryl Sulphate (2%)", "INS 211", "Phenoxyethnol", "BHA"],
        catalog,
    )
    matched = {hit.matched_canonical: hit for hit in hits}
    assert matched["Sodium Lauryl Sulfate"].match_type == "exact"
    assert matched["Sodium Benzoate"].match_type == "exact"
    assert matched["Phenoxyethanol"].match_type == "fuzzy"
    assert "BHT" not in matched


def test_cosmetic_position_deductions_and_high_cap():
    catalog = [
        HazardEntry(
            canonical_name="Test High",
            aliases=[],
            severity=SeverityTier.HIGH,
            domain=ProductDomain.COSMETIC,
            reason="High hazard",
        ),
        HazardEntry(
            canonical_name="Test Moderate",
            aliases=[],
            severity=SeverityTier.MODERATE,
            domain=ProductDomain.COSMETIC,
            reason="Moderate hazard",
        ),
    ]

    assert get_position_multiplier(2) == 1.0
    assert get_position_multiplier(7) == 0.7
    assert get_position_multiplier(12) == 0.4

    capped = calculate_cosmetic_score(
        "Water, Glycerin, Test Moderate",
        ["Water", "Glycerin", "Test Moderate", "", "", "", "", "", "", "", "", "", "", "", "Test High"],
        catalog,
    )
    assert capped.status == DataStatus.OK
    assert capped.capped_by_high_severity is True
    assert capped.cosmetic_score == 49
    high_hit = next(hit for hit in capped.deductions if hit.matched_canonical == "Test High")
    assert high_hit.position == 15
    assert high_hit.position_factor == 0.4
    assert high_hit.points_deducted == 8.0

    empty = calculate_cosmetic_score(None, [], catalog)
    assert empty.status == DataStatus.INSUFFICIENT_DATA


def test_parenthetical_outer_fuzzy_match_and_domain_filter():
    from safescan_engines.health.ingredient_matcher import match_ingredients

    catalog = [
        HazardEntry(
            canonical_name="Sodium Laureth Sulfate",
            aliases=[],
            severity=SeverityTier.MODERATE,
            domain=ProductDomain.COSMETIC,
            reason="Irritant",
        ),
        HazardEntry(
            canonical_name="Ins 102",
            aliases=["INS 102"],
            severity=SeverityTier.HIGH,
            domain=ProductDomain.FOOD,
            reason="Food additive",
        ),
    ]

    hits = match_ingredients(
        ["Sodium Laureth Sulphate (SLES)", "INS 102"],
        catalog,
        domain=ProductDomain.COSMETIC,
    )
    assert len(hits) == 1
    assert hits[0].matched_canonical == "Sodium Laureth Sulfate"

    result = calculate_cosmetic_score(
        "INS 102",
        [],
        catalog,
    )
    assert result.status == DataStatus.OK
    assert result.cosmetic_score == 100
    assert result.deductions == []


def test_deduplication_keeps_earliest_position():
    from safescan_engines.health.ingredient_matcher import match_ingredients

    catalog = [
        HazardEntry(
            canonical_name="Fragrance",
            aliases=[],
            severity=SeverityTier.MODERATE,
            domain=ProductDomain.COSMETIC,
            reason="Fragrance allergen",
        )
    ]
    hits = match_ingredients(
        ["Aqua", "Fragrance"] + ["Water"] * 9 + ["Fragrance"],
        catalog,
    )
    fragrance_hits = [
        hit for hit in hits
        if hit.matched_canonical == "Fragrance"
    ]
    assert len(fragrance_hits) == 1
    assert fragrance_hits[0].position == 2


def test_personal_flags():
    catalog = [
        HazardEntry(
            canonical_name="Propylparaben",
            aliases=["Paraben"],
            severity=SeverityTier.MODERATE,
            domain=ProductDomain.COSMETIC,
            reason="Preservative",
        )
    ]
    hits = []
    alerts = check_personal_flags(
        ["Propylparaben"],
        hits,
        ["paraben"],
        catalog,
    )
    assert any("Propylparaben" in alert for alert in alerts)

    assert check_personal_flags(
        ["Aqua", "Glycerin"],
        [],
        ["peanut"],
        catalog,
    ) == []