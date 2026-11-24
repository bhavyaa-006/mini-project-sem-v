from safescan_engines.alternatives.recommender import rank_and_explain_alternatives
from safescan_engines.health.ingredient_matcher import HazardEntry
from safescan_engines.health.nutri_score import calculate_nutri_score
from safescan_engines.health.cosmetic_score import calculate_cosmetic_score
from safescan_engines.schemas import (
    NormalizedProduct,
    NutrientProfile,
    ProductDomain,
    SeverityTier,
)


def food_product(barcode, name, sugars, sodium, fiber=2):
    return NormalizedProduct(
        barcode=barcode,
        name=name,
        domain=ProductDomain.FOOD,
        category="cereals",
        nutrients=NutrientProfile(
            energy_kcal=191,
            sugars_g=sugars,
            saturated_fat_g=3,
            sodium_mg=sodium,
            fiber_g=fiber,
            protein_g=5,
            fvl_percent=20,
        ),
    )


def test_food_ranking():
    target = food_product("target", "Target", 30, 800)
    target_health = calculate_nutri_score(target.nutrients)
    candidates = [
        target,
        food_product("a", "Best", 5, 300, 8),
        food_product("c", "Middle", 20, 500, 5),
        food_product("e", "Worse", 50, 1000, 1),
    ]
    ranked = rank_and_explain_alternatives(target, target_health, candidates)
    assert ranked
    assert ranked[0].product.barcode == "a"
    assert all(item.product.barcode != "target" for item in ranked)
    assert all(item.health.nutri_raw_score < target_health.nutri_raw_score for item in ranked)
    why = " ".join(reason for item in ranked for reason in item.why_reasons).lower()
    assert "nutri-score" in why
    assert "less sugar" in why


def test_cosmetic_ranking():
    target = NormalizedProduct(
        barcode="target",
        name="Target Cosmetic",
        domain=ProductDomain.COSMETIC,
        category="cream",
        ingredients_raw="Water, Sodium Lauryl Sulfate",
        ingredients_list=["Water", "Sodium Lauryl Sulfate"],
    )
    catalog = [
        HazardEntry(
            canonical_name="Sodium Lauryl Sulfate",
            aliases=["SLS"],
            severity=SeverityTier.HIGH,
            domain=ProductDomain.COSMETIC,
            reason="Irritant",
        ),
    ]
    target_health = calculate_cosmetic_score(
        target.ingredients_raw, target.ingredients_list, catalog
    )
    clean = NormalizedProduct(
        barcode="clean", name="Clean", domain=ProductDomain.COSMETIC,
        category="cream", ingredients_raw="Water, Glycerin",
        ingredients_list=["Water", "Glycerin"],
    )
    moderate = NormalizedProduct(
        barcode="moderate", name="Moderate", domain=ProductDomain.COSMETIC,
        category="cream", ingredients_raw="Water, Methylparaben",
        ingredients_list=["Water", "Methylparaben"],
    )
    capped = NormalizedProduct(
        barcode="capped", name="Capped", domain=ProductDomain.COSMETIC,
        category="cream", ingredients_raw="Water, Sodium Lauryl Sulfate",
        ingredients_list=["Water", "Sodium Lauryl Sulfate"],
    )
    ranked = rank_and_explain_alternatives(
        target, target_health,
        [target, clean, moderate, capped],
        catalog=catalog,
    )
    assert ranked
    assert ranked[0].product.barcode == "clean"
    assert all(item.product.barcode != "capped" for item in ranked)
    why = " ".join(reason for item in ranked for reason in item.why_reasons)
    assert "Sodium Lauryl Sulfate" in why