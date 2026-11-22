import pytest
from pydantic import ValidationError

from safescan_engines.health.cosmetic_score import calculate_cosmetic_score
from safescan_engines.hazard_db.loader import load_catalog_from_db, upsert_hazards
from safescan_engines.hazard_db.schema import HazardIngredient
from safescan_engines.hazard_db.validators import HazardRowSchema
from safescan_engines.schemas import ProductDomain


def test_validator_rejects_invalid_rows():
    with pytest.raises(ValidationError):
        HazardRowSchema.model_validate({
            "canonical_name": "Test",
            "aliases": "",
            "severity": "extreme",
            "domain": "cosmetic",
            "reason": "Unsafe",
            "source_url": "https://example.com",
        })
    with pytest.raises(ValidationError):
        HazardRowSchema.model_validate({
            "canonical_name": "",
            "aliases": "",
            "severity": "low",
            "domain": "cosmetic",
            "reason": "Unsafe",
            "source_url": "https://example.com",
        })
    with pytest.raises(ValidationError):
        HazardRowSchema.model_validate({
            "canonical_name": "Test",
            "aliases": "",
            "severity": "low",
            "domain": "cosmetic",
            "reason": "Unsafe",
            "source_url": "ftp://example.com",
        })


def test_upsert_is_idempotent_and_loads_cosmetic_catalog(db_session):
    first = HazardRowSchema.model_validate({
        "canonical_name": "Sodium Lauryl Sulfate",
        "aliases": "SLS|Sodium Dodecyl Sulfate",
        "severity": "moderate",
        "domain": "cosmetic",
        "reason": "Can irritate sensitive skin",
        "source_url": "https://example.com/sls",
    })
    assert upsert_hazards(db_session, [first]) == {"inserted": 1, "updated": 0}
    db_session.commit()

    updated = HazardRowSchema.model_validate({
        "canonical_name": "Sodium Lauryl Sulfate",
        "aliases": "SLS",
        "severity": "high",
        "domain": "cosmetic",
        "reason": "Updated irritation profile",
        "source_url": "https://example.com/updated",
    })
    assert upsert_hazards(db_session, [updated]) == {"inserted": 0, "updated": 1}
    db_session.commit()

    assert db_session.query(HazardIngredient).count() == 1
    catalog = load_catalog_from_db(db_session, domain=ProductDomain.COSMETIC)
    assert len(catalog) == 1
    assert catalog[0].aliases == ["SLS"]
    result = calculate_cosmetic_score(
        "Aqua, Sodium Lauryl Sulfate",
        [],
        catalog,
    )
    assert result.cosmetic_score is not None