import uuid
from sqlalchemy import Column, String, Float, Boolean, ForeignKey, Text, DateTime, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship

from app.db.base import Base


class Result(Base):
    __tablename__ = "results"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    scan_id = Column(UUID(as_uuid=True), ForeignKey("scans.id", ondelete="CASCADE"), unique=True, nullable=False)

    # Scores
    health_score = Column(Float, nullable=True)
    rating_tier = Column(String(20), nullable=True)      # excellent|good|mediocre|poor
    nutri_score = Column(String(2), nullable=True)
    safety_score = Column(Float, nullable=True)

    # Legal Metrology
    is_compliant = Column(Boolean, default=False, nullable=False)
    compliance_score = Column(Float, nullable=True)
    missing_fields = Column(Text, nullable=True)   # JSON array as text

    # Full report as JSON
    report_json = Column(Text, nullable=True)

    generated_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationship
    scan = relationship("Scan", back_populates="result")
