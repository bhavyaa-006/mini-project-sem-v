import re

from pydantic import BaseModel


class NetQuantityParseResult(BaseModel):
    found: bool
    value: float | None
    unit: str | None
    is_standard_si: bool
    raw_match: str | None


UNIT_NORMALIZATION = {
    "gm": "g", "gms": "g", "gram": "g", "grams": "g", "g": "g",
    "kgs": "kg", "kilogram": "kg", "kilograms": "kg", "kg": "kg",
    "mls": "ml", "ml": "ml", "millilitre": "ml", "millilitres": "ml",
    "ltr": "l", "litre": "l", "litres": "l", "liter": "l", "liters": "l", "l": "l",
    "nos": "N", "n": "N", "unit": "N", "units": "N", "pcs": "N",
    "tablets": "N", "capsules": "N",
}


def parse_net_quantity(text: str | None) -> NetQuantityParseResult:
    if not text or not text.strip():
        return NetQuantityParseResult(found=False, value=None, unit=None,
                                      is_standard_si=False, raw_match=None)

    normalized = re.sub(r"O(?=\d)", "0", text, flags=re.I)
    labeled = re.search(
        r"(?:net\s*(?:wt\.?|weight|vol\.?|qty\.?|quantity))\s*[:\-]?\s*"
        r"(\d+(?:\.\d+)?)\s*([A-Za-z]+)",
        normalized,
        re.I,
    )
    standalone = re.search(
        r"(?<!\d)(\d+(?:\.\d+)?)\s*(fl\.?\s*oz|oz|lbs?|gm?s?|grams?|kgs?|kilograms?|"
        r"mls?|millilitres?|ltr|litres?|liters?|nos|n|units?|pcs|tablets|capsules)\b",
        normalized,
        re.I,
    )
    match = labeled or standalone
    if not match:
        return NetQuantityParseResult(found=False, value=None, unit=None,
                                      is_standard_si=False, raw_match=None)

    raw_match = match.group(0).strip()
    try:
        value = float(match.group(1))
    except (TypeError, ValueError):
        value = None
    raw_unit = re.sub(r"\s+", "", match.group(2)).lower()
    raw_unit = raw_unit.replace(".", "")
    unit = UNIT_NORMALIZATION.get(raw_unit)
    is_standard = unit is not None
    if unit is None:
        unit = raw_unit
    return NetQuantityParseResult(
        found=True,
        value=value,
        unit=unit,
        is_standard_si=is_standard,
        raw_match=raw_match,
    )