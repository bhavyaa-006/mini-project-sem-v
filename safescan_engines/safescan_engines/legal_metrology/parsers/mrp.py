import re

from pydantic import BaseModel


class MrpParseResult(BaseModel):
    found: bool
    prices: list[float]
    primary_price: float | None
    has_tax_inclusive_text: bool
    raw_matches: list[str]


def parse_mrp(text: str | None) -> MrpParseResult:
    if not text or not text.strip():
        return MrpParseResult(found=False, prices=[], primary_price=None,
                              has_tax_inclusive_text=False, raw_matches=[])

    normalized = re.sub(r"[ \t]+", " ", text)
    normalized = re.sub(r"\n+", " ", normalized)
    pattern = re.compile(
        r"(?:M\s*\.?\s*R\s*\.?\s*P\s*\.?|MAX\s*\.?\s*RETAIL\s*PRICE)"
        r"\s*[:\-]?\s*(?:₹|Rs\.?|INR)?\s*(\d+(?:\.\d{1,2})?)",
        re.IGNORECASE,
    )
    matches = list(pattern.finditer(normalized))
    raw_matches = [match.group(0).strip() for match in matches]

    # Standalone currency symbols are candidates only on MRP-bearing lines.
    standalone = re.compile(r"(?:₹|Rs\.?|INR)\s*(\d+(?:\.\d{1,2})?)", re.IGNORECASE)
    for line in text.splitlines():
        if re.search(r"M\s*\.?\s*R\s*\.?\s*P|MAX\s*RETAIL\s*PRICE", line, re.I):
            for match in standalone.finditer(line):
                value = match.group(1)
                if value not in raw_matches:
                    raw_matches.append(match.group(0).strip())
                    matches.append(match)

    prices: list[float] = []
    for match in matches:
        try:
            prices.append(float(match.group(1)))
        except (TypeError, ValueError, IndexError):
            continue
    unique = list(dict.fromkeys(prices))
    tax_text = re.search(
        r"(?:incl\.?\s*(?:of)?\s*all\s*tax(?:es)?|inclusive\s+of\s+all\s+tax(?:es)?)",
        normalized,
        re.IGNORECASE,
    )
    return MrpParseResult(
        found=bool(unique),
        prices=unique,
        primary_price=unique[0] if unique else None,
        has_tax_inclusive_text=tax_text is not None,
        raw_matches=raw_matches,
    )