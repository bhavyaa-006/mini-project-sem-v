from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.api.deps import get_db
from app.schemas.product import ProductResponse
from app.services.product_service import get_or_fetch_product

router = APIRouter(prefix="/products", tags=["products"])


@router.get("/{barcode}", response_model=ProductResponse)
async def get_product(
    barcode: str,
    category: str = Query(default="food", pattern="^(food|cosmetic)$"),
    db: Session = Depends(get_db),
):
    """Fetch product by barcode (from cache or Open Food Facts / OBF)."""
    product = await get_or_fetch_product(db, barcode, category)
    if not product:
        raise HTTPException(status_code=404, detail=f"Product with barcode '{barcode}' not found")
    return product
