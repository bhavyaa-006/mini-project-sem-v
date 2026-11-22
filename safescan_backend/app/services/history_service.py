"""
Scan history service – retrieve past scans for a user.
"""
from typing import List
from sqlalchemy.orm import Session

from app.models.scan import Scan
from app.models.result import Result
from app.models.product import Product
from app.schemas.history import ScanHistoryItem


def _rating_label(tier: str) -> str:
    return {"excellent": "Excellent", "good": "Good",
            "mediocre": "Mediocre", "poor": "Poor / Risky"}.get(tier or "", "Unknown")


def get_user_history(db: Session, user_id: str) -> List[ScanHistoryItem]:
    scans = (
        db.query(Scan)
        .filter(Scan.user_id == user_id)
        .order_by(Scan.scanned_at.desc())
        .limit(50)
        .all()
    )
    items = []
    for scan in scans:
        result = scan.result
        product = scan.product
        if not product or not result:
            continue
        items.append(
            ScanHistoryItem(
                id=str(scan.id),
                product_id=str(product.id),
                product_name=product.name,
                brand=product.brand or "",
                category=product.category,
                score=result.health_score or 0,
                rating_tier=result.rating_tier or "poor",
                rating_label=_rating_label(result.rating_tier),
                is_compliant=result.is_compliant,
                flagged_count=0,  # simplified
                timestamp=scan.scanned_at.isoformat(),
                thumbnail_url=product.image_url,
            )
        )
    return items
