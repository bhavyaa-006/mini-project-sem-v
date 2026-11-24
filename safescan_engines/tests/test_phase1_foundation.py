import pytest
from pydantic import ValidationError
from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.orm import sessionmaker

import safescan_engines
from safescan_engines import db
from safescan_engines.config import Settings, settings
from safescan_engines.db import Base
from safescan_engines.schemas import (
    AuditReportPayload,
    ComplianceResult,
    ComplianceStatus,
    DataStatus,
    HealthResult,
    NormalizedProduct,
    NutrientProfile,
    ProductDomain,
)


def test_package_and_paths():
    assert safescan_engines.__version__ == "0.1.0"
    assert settings.ROOT_DIR.exists()
    assert settings.DATA_DIR.name == "data"


def test_env_override(monkeypatch):
    monkeypatch.setenv("FUZZY_MATCH_THRESHOLD", "90")
    assert Settings().fuzzy_match_threshold == 90

    monkeypatch.setenv("FUZZY_MATCH_THRESHOLD", "150")
    with pytest.raises(ValidationError):
        Settings()


def test_schema_validation_and_serialization():
    with pytest.raises(ValidationError):
        NormalizedProduct(
            domain=ProductDomain.FOOD,
            nutrients={"energy_kcal": -10},
        )

    product = NormalizedProduct(
        domain=ProductDomain.FOOD,
        name="No nutrient data",
        nutrients=None,
    )
    assert product.nutrients is None

    payload = AuditReportPayload(
        product=product,
        health=HealthResult(
            status=DataStatus.INSUFFICIENT_DATA,
            domain=ProductDomain.FOOD,
        ),
        compliance=ComplianceResult(
            overall_status=ComplianceStatus.UNKNOWN,
        ),
    )
    restored = AuditReportPayload.model_validate_json(payload.model_dump_json())
    assert restored == payload


def test_db_session_and_transaction_isolation(db_engine, monkeypatch):
    class TestRow(Base):
        __tablename__ = "phase1_test_rows"

        id: Mapped[int] = mapped_column(primary_key=True)
        value: Mapped[str] = mapped_column(String)

    Base.metadata.create_all(db_engine)
    test_session_factory = sessionmaker(
        bind=db_engine,
        autoflush=False,
        autocommit=False,
        expire_on_commit=False,
    )
    monkeypatch.setattr(db, "SessionLocal", test_session_factory)

    with db.session_scope() as session:
        session.add(TestRow(value="committed"))

    with test_session_factory() as session:
        assert session.query(TestRow).filter_by(value="committed").one()

    with pytest.raises(RuntimeError, match="forced rollback"):
        with db.session_scope() as session:
            session.add(TestRow(value="rolled back"))
            raise RuntimeError("forced rollback")

    with test_session_factory() as session:
        assert session.query(TestRow).filter_by(value="rolled back").count() == 0
