import re
from collections.abc import Sequence

from safescan_engines.health.ingredient_matcher import (
    HazardEntry,
    normalize_token,
    split_ingredients,
)
from safescan_engines.schemas import IngredientHit


def check_personal_flags(
    tokens: list[str],
    hits: list[IngredientHit],
    user_allergens: Sequence[str],
    catalog: Sequence[HazardEntry] | None = None,
) -> list[str]:
    triggers = [normalize_token(trigger) for trigger in user_allergens if trigger.strip()]
    if not triggers:
        return []

    normalized_tokens: list[str] = []
    for token in tokens:
        normalized_tokens.append(normalize_token(token))
        for inner in re.findall(r"\(([^()]*)\)", token):
            normalized_tokens.extend(
                normalize_token(part.strip())
                for part in inner.split(",")
                if part.strip()
            )

    matched_names: dict[str, str] = {}
    for hit in hits:
        matched_names[normalize_token(hit.matched_canonical)] = hit.matched_canonical
        matched_names[normalize_token(hit.raw_token)] = hit.raw_token

    if catalog:
        for entry in catalog:
            for alias in entry.aliases:
                matched_names[normalize_token(alias)] = alias

    alerts: list[str] = []
    for trigger in triggers:
        for token in normalized_tokens:
            display_name = token
            if trigger in token:
                display_name = token.title()
                alerts.append(
                    f"Allergy/Sensitivity Alert: Contains {display_name} "
                    f"(matches profile trigger '{trigger}')"
                )
                break

        if any(trigger in name for name in matched_names):
            display_name = next(
                (original for name, original in matched_names.items() if trigger in name),
                trigger,
            )
            alert = (
                f"Allergy/Sensitivity Alert: Contains {display_name} "
                f"(matches profile trigger '{trigger}')"
            )
            if alert not in alerts:
                alerts.append(alert)

    return alerts