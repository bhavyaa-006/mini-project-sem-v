from typing import Optional, List
from pydantic import BaseModel
from uuid import UUID


class ScanHistoryItem(BaseModel):
    id: str
    product_id: Optional[str] = None
    product_name: str
    brand: str
    category: str
    score: float
    rating_tier: str
    rating_label: str
    is_compliant: bool
    flagged_count: int
    timestamp: str
    thumbnail_url: Optional[str] = None


class ScanHistoryResponse(BaseModel):
    items: List[ScanHistoryItem]
    total: int
