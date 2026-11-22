from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.api.deps import get_db
from app.models.product import Product
from app.schemas.analysis import AlternativeProduct
from app.engines.alternatives.recommender import _rating_tier

router = APIRouter(prefix="/alternatives", tags=["alternatives"])


@router.get("/{product_id}")
def get_alternatives(
    product_id: str,
    db: Session = Depends(get_db),
):
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        from fastapi import HTTPException
        raise HTTPException(status_code=404, detail="Product not found")

    rows = (
        db.query(Product)
        .filter(
            Product.category == product.category,
            Product.id != product.id,
        )
        .order_by(Product.health_score.desc())
        .limit(5)
        .all()
    )
    return [
        AlternativeProduct(
            id=str(p.id),
            name=p.name,
            brand=p.brand or "",
            category=p.category,
            score=round(p.health_score or 0, 1),
            rating_tier=_rating_tier(p.health_score or 0),
            highlight_reason=f"Score: {round(p.health_score or 0)}",
            image_url=p.image_url,
        )
        for p in rows
    ]
