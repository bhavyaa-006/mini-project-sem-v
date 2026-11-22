import pytest
from pydantic import ValidationError

from safescan_engines.health.cosmetic_score import calculate_cosmetic_score
from safescan_engines.hazard_db.loader import (
    load_catalog_from_db,
    merge_hazard_csvs,
    upsert_hazards,
)
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


def test_cross_domain_merge_and_upsert(tmp_path, db_session):
    food_csv = tmp_path / "food.csv"
    cosmetic_csv = tmp_path / "cosmetic.csv"
    output_csv = tmp_path / "master.csv"
    food_csv.write_text(
        "canonical_name,aliases,severity,domain,reason,source_url\n"
        "BHT,INS 321|E321,moderate,food,Food antioxidant,https://example.com/food\n",
        encoding="utf-8",
    )
    cosmetic_csv.write_text(
        "canonical_name,aliases,severity,domain,reason,source_url\n"
        "BHT,BHT Antioxidant,moderate,cosmetic,Cosmetic antioxidant,https://example.com/cosmetic\n",
        encoding="utf-8",
    )

    assert merge_hazard_csvs([food_csv, cosmetic_csv], output_csv) == 2
    rows = [
        HazardRowSchema.model_validate({
            "canonical_name": "BHT",
            "aliases": "INS 321",
            "severity": "moderate",
            "domain": "food",
            "reason": "Food antioxidant",
            "source_url": "https://example.com/food",
        }),
        HazardRowSchema.model_validate({
            "canonical_name": "BHT",
            "aliases": "BHT Antioxidant",
            "severity": "moderate",
            "domain": "cosmetic",
            "reason": "Cosmetic antioxidant",
            "source_url": "https://example.com/cosmetic",
        }),
    ]
    assert upsert_hazards(db_session, rows) == {"inserted": 2, "updated": 0}
    db_session.commit()
    assert db_session.query(HazardIngredient).count() == 2