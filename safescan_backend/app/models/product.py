import uuid
from sqlalchemy import Column, String, Float, DateTime, func, Text, Uuid
from sqlalchemy.orm import relationship

from app.db.base import Base


class Product(Base):
    __tablename__ = "products"

    id = Column(Uuid, primary_key=True, default=uuid.uuid4)
    barcode = Column(String(50), unique=True, nullable=True, index=True)
    name = Column(String(255), nullable=False)
    brand = Column(String(255), nullable=True)
    category = Column(String(20), nullable=False)  # "food" | "cosmetic"

    # Scores
    health_score = Column(Float, nullable=True)
    nutri_score = Column(String(2), nullable=True)   # A-E
    safety_score = Column(Float, nullable=True)      # 0-100 for cosmetics

    # Raw data from Open Food Facts / Open Beauty Facts
    ingredients_text = Column(Text, nullable=True)
    image_url = Column(String(500), nullable=True)
    off_data = Column(Text, nullable=True)           # JSON blob from API

    cached_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    scans = relationship("Scan", back_populates="product")
    ingredients = relationship("Ingredient", back_populates="product")
