from app.engines.health.ingredient_matcher import match_hazard_ingredients
from app.models.hazard_ingredient import HazardIngredient


def _make_hazard(name, aliases, level, source, reason):
    h = HazardIngredient()
    h.name = name
    h.aliases = aliases
    h.hazard_level = level
    h.regulatory_source = source
    h.reason = reason
    h.category = "food"
    return h


def test_match_found():
    hazards = [_make_hazard("Sodium Benzoate", ["E211"], "moderate", "FSSAI", "Preservative")]
    flagged = match_hazard_ingredients(["water", "sodium benzoate", "sugar"], hazards)
    assert len(flagged) == 1
    assert flagged[0].name == "Sodium Benzoate"


def test_no_match():
    hazards = [_make_hazard("Aspartame", ["E951"], "moderate", "FSSAI", "Artificial sweetener")]
    flagged = match_hazard_ingredients(["water", "sugar", "salt"], hazards)
    assert len(flagged) == 0


def test_alias_match():
    hazards = [_make_hazard("Tartrazine", ["E102", "FD&C Yellow 5"], "high", "EWG", "Synthetic dye")]
    flagged = match_hazard_ingredients(["water", "e102", "glucose"], hazards)
    assert len(flagged) == 1
