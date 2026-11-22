import uuid
from sqlalchemy import Column, String, JSON, Uuid

from app.db.base import Base


class HazardIngredient(Base):
    """Master hazard ingredient database (seeded from CSV)."""
    __tablename__ = "hazard_ingredients"

    id = Column(Uuid, primary_key=True, default=uuid.uuid4)
    name = Column(String(255), nullable=False, index=True)
    aliases = Column(JSON, nullable=False, default=list)
    category = Column(String(20), nullable=False)        # "food" | "cosmetic"
    hazard_level = Column(String(20), nullable=False)    # "low" | "moderate" | "high"
    regulatory_source = Column(String(50), nullable=False)  # EWG | FSSAI | INCI | BIS | CIR
    reason = Column(String(500), nullable=False)
    scientific_details = Column(String(1000), nullable=True)
    e_number = Column(String(20), nullable=True)
