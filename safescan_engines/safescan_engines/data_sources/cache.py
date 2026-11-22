from datetime import datetime, timezone

from sqlalchemy import DateTime, String, Text, select
from sqlalchemy.orm import Mapped, Session, mapped_column

from safescan_engines.db import Base
from safescan_engines.schemas import NormalizedProduct, ProductDomain


class CachedProduct(Base):
    __tablename__ = "cached_products"

    barcode: Mapped[str] = mapped_column(String(64), primary_key=True)
    domain: Mapped[str] = mapped_column(String(32), index=True, nullable=False)
    category: Mapped[str | None] = mapped_column(String(255), index=True, nullable=True)
    source: Mapped[str] = mapped_column(String(32), nullable=False)
    payload_json: Mapped[str] = mapped_column(Text, nullable=False)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
    )


def get_cached_product(session: Session, barcode: str) -> NormalizedProduct | None:
    row = session.get(CachedProduct, barcode)
    if row is None:
        return None
    try:
        return NormalizedProduct.model_validate_json(row.payload_json)
    except Exception:
        return None


def save_cached_product(session: Session, product: NormalizedProduct) -> None:
    if product.barcode is None:
        raise ValueError("A barcode is required to cache a product")
    row = session.get(CachedProduct, product.barcode)
    if row is None:
        row = CachedProduct(
            barcode=product.barcode,
            domain=product.domain.value,
            category=product.category,
            source=product.source,
            payload_json=product.model_dump_json(),
            updated_at=datetime.now(timezone.utc),
        )
        session.add(row)
    else:
        row.domain = product.domain.value
        row.category = product.category
        row.source = product.source
        row.payload_json = product.model_dump_json()
        row.updated_at = datetime.now(timezone.utc)
    session.flush()


def get_products_by_category(
    session: Session,
    category: str,
    domain: ProductDomain,
    exclude_barcode: str | None = None,
    limit: int = 10,
) -> list[NormalizedProduct]:
    statement = select(CachedProduct).where(CachedProduct.domain == domain.value)
    rows = list(session.scalars(statement).all())
    category_key = category.lower().strip().removeprefix("en:")
    products: list[NormalizedProduct] = []
    for row in rows:
        if exclude_barcode and row.barcode == exclude_barcode:
            continue
        if row.category is None:
            continue
        row_category = row.category.lower().strip().removeprefix("en:")
        if row_category != category_key:
            continue
        try:
            product = NormalizedProduct.model_validate_json(row.payload_json)
        except Exception:
            continue
        products.append(product)
        if len(products) >= limit:
            break
    return products