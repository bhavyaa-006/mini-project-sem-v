from typing import Optional
from pydantic import BaseModel


class ProductResponse(BaseModel):
    id: str
    barcode: Optional[str] = None
    name: str
    brand: Optional[str] = None
    category: str
    health_score: Optional[float] = None
    nutri_score: Optional[str] = None
    safety_score: Optional[float] = None
    ingredients_text: Optional[str] = None
    image_url: Optional[str] = None

    class Config:
        from_attributes = True
