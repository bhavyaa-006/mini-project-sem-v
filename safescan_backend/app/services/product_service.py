"""
Product service – fetch from DB cache or pull from Open Food Facts / OBF.
"""
from typing import Optional
from sqlalchemy.orm import Session

from app.models.product import Product
from app.services.off_client import fetch_product, parse_product_fields


async def get_or_fetch_product(db: Session, barcode: str, category: str = "food") -> Optional[Product]:
    """Return cached Product or fetch from OFF/OBF and cache it."""
    # 1. Try DB cache first
    product = db.query(Product).filter(Product.barcode == barcode).first()
    if product:
        return product

    # 2. Fetch from Open Food Facts / Open Beauty Facts
    raw = await fetch_product(barcode, category)
    if not raw:
        return None

    fields = parse_product_fields(raw, barcode, category)
    product = Product(**fields)
    db.add(product)
    db.commit()
    db.refresh(product)
    return product
