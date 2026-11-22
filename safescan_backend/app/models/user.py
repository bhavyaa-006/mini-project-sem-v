import uuid
from sqlalchemy import Column, String, Boolean, DateTime, func, JSON, Uuid
from sqlalchemy.orm import relationship

from app.db.base import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Uuid, primary_key=True, default=uuid.uuid4)
    name = Column(String(255), nullable=False)
    email = Column(String(255), unique=True, nullable=False, index=True)
    hashed_password = Column(String(255), nullable=False)
    role = Column(String(20), nullable=False, default="user")  # "user" | "admin"

    # Health preferences
    skin_type = Column(String(50), nullable=True)
    dietary_preferences = Column(JSON, nullable=False, default=list)
    allergies = Column(JSON, nullable=False, default=list)

    is_active = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    scans = relationship("Scan", back_populates="user", lazy="dynamic")
