"""
Personal flags – highlight ingredients matching user's allergies / skin type.
"""
from typing import List


def apply_personal_flags(ingredient_list: List[str], allergies: List[str]) -> List[str]:
    """Return subset of ingredients matching user's known allergens."""
    allergen_set = {a.lower().strip() for a in allergies}
    return [ing for ing in ingredient_list if any(a in ing.lower() for a in allergen_set)]
