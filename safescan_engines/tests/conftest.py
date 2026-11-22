import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from safescan_engines.db import Base
from safescan_engines.schemas import NormalizedProduct, ProductDomain


@pytest.fixture
def db_engine():
    engine = create_engine(
        "sqlite:///:memory:",
        connect_args={"check_same_thread": False},
    )
    Base.metadata.create_all(engine)
    try:
        yield engine
    finally:
        Base.metadata.drop_all(engine)
        engine.dispose()


@pytest.fixture
def db_session(db_engine):
    session_factory = sessionmaker(
        bind=db_engine,
        autoflush=False,
        autocommit=False,
        expire_on_commit=False,
    )
    session = session_factory()
    try:
        yield session
    finally:
        session.rollback()
        session.close()


@pytest.fixture
def sample_food_product():
    return NormalizedProduct(
        barcode="8901234567890",
        name="Test Oats",
        brand="SafeScan",
        domain=ProductDomain.FOOD,
        category="Breakfast cereal",
        ingredients_raw="oats, sugar",
        ingredients_list=["oats", "sugar"],
    )


@pytest.fixture
def sample_cosmetic_product():
    return NormalizedProduct(
        barcode="8909876543210",
        name="Test Lotion",
        brand="SafeScan",
        domain=ProductDomain.COSMETIC,
        category="Moisturizer",
        ingredients_raw="water, glycerin",
        ingredients_list=["water", "glycerin"],
    )
