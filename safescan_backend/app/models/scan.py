import uuid
from sqlalchemy import Column, String, ForeignKey, DateTime, func, Uuid
from sqlalchemy.orm import relationship

from app.db.base import Base


class Scan(Base):
    __tablename__ = "scans"

    id = Column(Uuid, primary_key=True, default=uuid.uuid4)
    user_id = Column(Uuid, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    product_id = Column(Uuid, ForeignKey("products.id", ondelete="SET NULL"), nullable=True)

    # For OCR scans — uploaded image path
    image_path = Column(String(500), nullable=True)
    barcode = Column(String(50), nullable=True)

    scanned_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    user = relationship("User", back_populates="scans")
    product = relationship("Product", back_populates="scans")
    result = relationship("Result", back_populates="scan", uselist=False)
