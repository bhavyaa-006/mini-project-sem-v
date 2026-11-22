import re
from collections.abc import Sequence

from pydantic import BaseModel
from rapidfuzz import fuzz, process

from safescan_engines.config import settings
from safescan_engines.schemas import (
    IngredientHit,
    ProductDomain,
    SeverityTier,
)


class HazardEntry(BaseModel):
    canonical_name: str
    aliases: list[str] = []
    severity: SeverityTier
    domain: ProductDomain
    reason: str
    source_url: str | None = None


def split_ingredients(raw_text: str | None) -> list[str]:
    if raw_text is None or not raw_text.strip():
        return []

    tokens: list[str] = []
    start = 0
    depth = 0
    for index, char in enumerate(raw_text):
        if char == "(":
            depth += 1
        elif char == ")" and depth:
            depth -= 1
        elif char in ",;" and depth == 0:
            token = raw_text[start:index].strip()
            if token:
                tokens.append(token)
            start = index + 1
    tail = raw_text[start:].strip()
    if tail:
        tokens.append(tail)
    return tokens


def normalize_token(token: str) -> str:
    norm = token.strip().lower().rstrip(".")
    norm = re.sub(r"^contains\s*:\s*", "", norm)
    norm = re.sub(r"\(?\s*\d+(?:\.\d+)?\s*%\s*\)?", "", norm)
    norm = re.sub(r"\bins[\s-]*([0-9]+)\b", r"ins\1", norm)
    norm = re.sub(r"\be[\s-]*([0-9]+)\b", r"e\1", norm)
    norm = norm.replace("sulphate", "sulfate").replace("colour", "color")
    norm = re.sub(r"\s+", " ", norm).strip()
    return norm


def _parenthetical_tokens(raw_token: str) -> list[str]:
    matches = re.findall(r"\(([^()]*)\)", raw_token)
    inner: list[str] = []
    for match in matches:
        inner.extend(part.strip() for part in match.split(",") if part.strip())
    return inner


def match_ingredients(
    tokens: list[str],
    catalog: Sequence[HazardEntry],
    threshold: int = settings.fuzzy_match_threshold,
    min_fuzzy_len: int = settings.min_fuzzy_token_length,
    domain: ProductDomain | None = None,
) -> list[IngredientHit]:
    exact_lookup: dict[str, HazardEntry] = {}
    for entry in catalog:
        if domain is not None and entry.domain != domain:
            continue
        names = [entry.canonical_name, *entry.aliases]
        for name in names:
            normalized = normalize_token(name)
            if normalized:
                exact_lookup.setdefault(normalized, entry)

    exact_keys = list(exact_lookup)
    hits: list[IngredientHit] = []

    for position, raw_token in enumerate(tokens, start=1):

        stripped_outer = re.sub(r"\([^()]*\)", "", raw_token).strip()
        candidates = [
            raw_token,
            stripped_outer,
            *_parenthetical_tokens(raw_token),
        ]

        matched_norm: str | None = None
        matched_entry: HazardEntry | None = None
        match_type: str | None = None
        match_score = 0.0
        matched_raw = raw_token

        for candidate in candidates:
            candidate_norm = normalize_token(candidate)
            if candidate_norm in exact_lookup:
                matched_norm = candidate_norm
                matched_entry = exact_lookup[candidate_norm]
                match_type = "exact"
                match_score = 100.0
                matched_raw = candidate
                break

        if matched_entry is None:
            best_match: tuple[str, float] | None = None
            for candidate in candidates:
                candidate_norm = normalize_token(candidate)
                if len(candidate_norm) < min_fuzzy_len:
                    continue
                match = process.extractOne(
                    candidate_norm,
                    exact_keys,
                    scorer=fuzz.WRatio,
                    score_cutoff=threshold,
                )
                if match:
                    candidate_matched_norm, candidate_score, _ = match
                    candidate_score = round(float(candidate_score), 2)
                    if best_match is None or candidate_score > best_match[1]:
                        best_match = (candidate_matched_norm, candidate_score)

            if best_match is not None:
                matched_norm, match_score = best_match
                matched_entry = exact_lookup[matched_norm]
                match_type = "fuzzy"
                matched_raw = raw_token

        if matched_entry is not None and match_type is not None:
            hits.append(
                IngredientHit(
                    raw_token=matched_raw.strip(),
                    matched_canonical=matched_entry.canonical_name,
                    match_type=match_type,
                    match_score=match_score,
                    severity=matched_entry.severity,
                    position=position,
                    position_factor=1.0,
                    points_deducted=0.0,
                    reason=matched_entry.reason,
                    source_url=matched_entry.source_url,
                )
            )

    deduplicated: dict[str, IngredientHit] = {}
    for hit in hits:
        existing = deduplicated.get(hit.matched_canonical.lower())
        if existing is None:
            deduplicated[hit.matched_canonical.lower()] = hit
            continue
        if hit.position < existing.position:
            deduplicated[hit.matched_canonical.lower()] = hit

    return list(deduplicated.values())