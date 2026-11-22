"""
Alternatives recommender – returns better-scored products from DB.
"""
from typing import List
from sqlalchemy.orm import Session

from app.models.product import Product
from app.schemas.analysis import AlternativeProduct


def _rating_tier(score: float) -> str:
    if score >= 75: return "excellent"
    if score >= 50: return "good"
    if score >= 25: return "mediocre"
    return "poor"


def recommend_alternatives(db: Session, product: Product, current_score: float) -> List[AlternativeProduct]:
    """Find up to 3 cached products of same category with higher health_score."""
    rows = (
        db.query(Product)
        .filter(
            Product.category == product.category,
            Product.id != product.id,
            Product.health_score > current_score,
        )
        .order_by(Product.health_score.desc())
        .limit(3)
        .all()
    )
    result = []
    for p in rows:
        sc = p.health_score or 0
        tier = _rating_tier(sc)
        result.append(AlternativeProduct(
            id=str(p.id),
            name=p.name,
            brand=p.brand or "",
            category=p.category,
            score=round(sc, 1),
            rating_tier=tier,
            highlight_reason=f"Higher health score ({round(sc)})",
            image_url=p.image_url,
        ))
    return result
