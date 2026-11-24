import re

from safescan_engines.ocr import ExtractedLabelFields, OcrDocumentResult


INGREDIENT_HEADER = re.compile(r"ingredients?|composition|contains", re.I)
NUTRITION_HEADER = re.compile(
    r"\b(?:nutritional|nutrition|mfd\.?|mfg\.?|pkd\.?|packed|mrp|m\.r\.p|"
    r"max retail|net wt|net weight|net vol|net qty|net quantity|"
    r"mfd\.?\s*by|best before|storage|allergen)\b",
    re.I,
)
MRP_LINE = re.compile(r"\b(?:mrp|m\.r\.p|max\s*retail\s*price)\b|₹|rs\.?|incl\.?\s*(?:of)?\s*all\s*tax", re.I)
NET_LINE = re.compile(
    r"\b(?:net\s*(?:wt|weight|vol|qty|quantity))\b|\b\d+(?:\.\d+)?\s*(?:g|kg|ml|l|gm|gms)\b",
    re.I,
)
DATES_LINE = re.compile(
    r"\b(?:mfd\.?|mfg\.?|pkd\.?|packed|exp(?:iry)?|best\s*before|use\s*by|batch)\b",
    re.I,
)
MANUFACTURER_LINE = re.compile(
    r"(?:mfd\.?\s*by|manufactured\s+by|marketed\s+by|imported\s+by|packed\s+by|"
    r"consumer\s*care|customer\s*care|country\s+of\s+origin)",
    re.I,
)
ADDRESS_CONTINUATION = re.compile(r"\b[1-9][0-9]{5}\b|(?:\+91|1800|0\d{2,4})[\s\-]?\d|@", re.I)


def extract_label_fields(ocr_result: OcrDocumentResult | str) -> ExtractedLabelFields:
    if isinstance(ocr_result, OcrDocumentResult):
        raw_text = ocr_result.full_text
        lines = [line.text for line in ocr_result.lines]
    else:
        raw_text = ocr_result
        lines = [line.strip() for line in ocr_result.splitlines() if line.strip()]
    if not lines:
        lines = [line.strip() for line in raw_text.splitlines() if line.strip()]

    ingredients: list[str] = []
    mrp: list[str] = []
    net_quantity: list[str] = []
    dates: list[str] = []
    manufacturer: list[str] = []
    in_ingredients = False

    for line in lines:
        if INGREDIENT_HEADER.search(line):
            in_ingredients = True
            stripped = re.sub(
                r"^\s*(?:ingredients?|composition|contains)\s*[:\-]?\s*",
                "",
                line,
                flags=re.I,
            )
            if stripped:
                ingredients.append(stripped)
            continue
        if in_ingredients:
            if NUTRITION_HEADER.search(line):
                in_ingredients = False
            else:
                ingredients.append(line)

        if MRP_LINE.search(line):
            mrp.append(line)
        if NET_LINE.search(line):
            net_quantity.append(line)
        if DATES_LINE.search(line):
            dates.append(line)
        if MANUFACTURER_LINE.search(line):
            manufacturer.append(line)
        elif manufacturer and ADDRESS_CONTINUATION.search(line):
            manufacturer.append(line)

    return ExtractedLabelFields(
        raw_text=raw_text,
        ingredients_text=", ".join(ingredients).strip() or None,
        mrp_text=" | ".join(mrp).strip() or None,
        net_quantity_text=" | ".join(net_quantity).strip() or None,
        dates_text=" | ".join(dates).strip() or None,
        manufacturer_text=" | ".join(manufacturer).strip() or None,
    )