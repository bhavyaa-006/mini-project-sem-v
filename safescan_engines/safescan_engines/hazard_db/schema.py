from sqlalchemy import ForeignKey, String, Text, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from safescan_engines.db import Base


class HazardIngredient(Base):
    __tablename__ = "hazard_ingredients"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    canonical_name: Mapped[str] = mapped_column(String(255), unique=True, index=True, nullable=False)
    canonical_norm: Mapped[str] = mapped_column(String(255), unique=True, index=True, nullable=False)
    severity: Mapped[str] = mapped_column(String(32), nullable=False)
    domain: Mapped[str] = mapped_column(String(32), index=True, nullable=False)
    reason: Mapped[str] = mapped_column(Text, nullable=False)
    source_url: Mapped[str | None] = mapped_column(String(512), nullable=True)
    aliases: Mapped[list["IngredientAlias"]] = relationship(
        back_populates="ingredient",
        cascade="all, delete-orphan",
    )


class IngredientAlias(Base):
    __tablename__ = "hazard_ingredient_aliases"
    __table_args__ = (
        UniqueConstraint("ingredient_id", "alias_norm", name="uq_hazard_alias"),
    )

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    ingredient_id: Mapped[int] = mapped_column(
        ForeignKey("hazard_ingredients.id", ondelete="CASCADE"),
        index=True,
        nullable=False,
    )
    alias_name: Mapped[str] = mapped_column(String(255), nullable=False)
    alias_norm: Mapped[str] = mapped_column(String(255), index=True, nullable=False)
    ingredient: Mapped["HazardIngredient"] = relationship(back_populates="aliases")