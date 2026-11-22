import math
from typing import Literal

from safescan_engines.health.ingredient_matcher import split_ingredients
from safescan_engines.schemas import NormalizedProduct, NutrientProfile, ProductDomain


FIELDS_TO_REQUEST = "code,product_name,brands,categories_tags,ingredients_text,nutriments"


def _safe_float(value: object) -> float | None:
    if isinstance(value, bool):
        return None
    try:
        parsed = float(value)
    except (TypeError, ValueError):
        return None
    if not math.isfinite(parsed) or parsed < 0:
        return None
    return parsed


def _category(product: dict) -> str | None:
    tags = product.get("categories_tags")
    if isinstance(tags, list):
        for tag in reversed(tags):
            category = str(tag).removeprefix("en:").strip()
            if category:
                return category
    return None


def normalize_off_product(
    payload: dict,
    domain: ProductDomain = ProductDomain.FOOD,
    source: Literal["off", "obf"] = "off",
) -> NormalizedProduct | None:
    status = payload.get("status")
    if status not in (1, "1") or "product" not in payload:
        return None
    product = payload.get("product")
    if not isinstance(product, dict):
        return None

    ingredients_raw = product.get("ingredients_text")
    if not isinstance(ingredients_raw, str) or not ingredients_raw.strip():
        ingredients_raw = None

    nutrients = None
    if domain == ProductDomain.FOOD:
        nutriments = product.get("nutriments")
        if not isinstance(nutriments, dict):
            nutriments = {}

        energy_kj = _safe_float(nutriments.get("energy-kj_100g"))
        if energy_kj is None:
            energy_kcal = _safe_float(nutriments.get("energy-kcal_100g"))
            energy_kj = energy_kcal * 4.184 if energy_kcal is not None else None

        sodium_mg = None
        sodium_g = _safe_float(nutriments.get("sodium_100g"))
        if sodium_g is not None:
            sodium_mg = sodium_g * 1000.0
        else:
            salt_g = _safe_float(nutriments.get("salt_100g"))
            if salt_g is not None:
                sodium_mg = (salt_g / 2.5) * 1000.0

        fvl = _safe_float(
            nutriments.get("fruits-vegetables-nuts-estimate-from-ingredients_100g")
        )
        if fvl is None:
            fvl = _safe_float(nutriments.get("fruits-vegetables-nuts_100g"))
        if fvl is not None:
            fvl = min(100.0, max(0.0, fvl))

        nutrients = NutrientProfile(
            energy_kj=energy_kj,
            sugars_g=_safe_float(nutriments.get("sugars_100g")),
            saturated_fat_g=_safe_float(nutriments.get("saturated-fat_100g")),
            sodium_mg=sodium_mg,
            fiber_g=_safe_float(nutriments.get("fiber_100g")),
            protein_g=_safe_float(nutriments.get("proteins_100g")),
            fvl_percent=fvl,
        )

    barcode = product.get("code") or payload.get("code")
    return NormalizedProduct(
        barcode=str(barcode) if barcode is not None else None,
        name=str(product["product_name"]).strip() if isinstance(product.get("product_name"), str) and product["product_name"].strip() else None,
        brand=str(product["brands"]).strip() if isinstance(product.get("brands"), str) and product["brands"].strip() else None,
        domain=domain,
        category=_category(product),
        ingredients_raw=ingredients_raw,
        ingredients_list=split_ingredients(ingredients_raw) if ingredients_raw else [],
        nutrients=nutrients,
        source=source,
    )