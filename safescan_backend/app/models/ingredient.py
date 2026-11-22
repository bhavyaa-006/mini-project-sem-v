import uuid
from sqlalchemy import Column, String, ForeignKey, Uuid
from sqlalchemy.orm import relationship

from app.db.base import Base


class Ingredient(Base):
    __tablename__ = "ingredients"

    id = Column(Uuid, primary_key=True, default=uuid.uuid4)
    product_id = Column(Uuid, ForeignKey("products.id", ondelete="CASCADE"), nullable=False)
    name = Column(String(255), nullable=False)
    hazard_level = Column(String(20), nullable=True)  # "low" | "moderate" | "high" | None
    reason = Column(String(500), nullable=True)

    product = relationship("Product", back_populates="ingredients")
