"""
Ingredient hazard matcher – cross-checks product ingredients against
the hazard_ingredients master table.
"""
from typing import List
from app.models.hazard_ingredient import HazardIngredient
from app.schemas.analysis import FlaggedIngredient


def _normalize(name: str) -> str:
    return name.lower().strip()


def match_hazard_ingredients(
    ingredient_list: List[str],
    hazard_records: List[HazardIngredient],
) -> List[FlaggedIngredient]:
    """Return list of FlaggedIngredient for every match found."""
    flagged: List[FlaggedIngredient] = []
    normalized_ingredients = [_normalize(i) for i in ingredient_list]

    for record in hazard_records:
        # Check canonical name and all aliases
        names_to_check = [_normalize(record.name)] + [_normalize(a) for a in (record.aliases or [])]
        for norm_name in names_to_check:
            if any(norm_name in ing for ing in normalized_ingredients):
                flagged.append(FlaggedIngredient(
                    name=record.name,
                    hazard_level=record.hazard_level,
                    reason=record.reason,
                    scientific_details=record.scientific_details,
                    regulatory_status=record.regulatory_source,
                    e_number=record.e_number,
                    data_source=record.regulatory_source,
                    is_verified=True,
                ))
                break  # don't double-count same record

    return flagged
