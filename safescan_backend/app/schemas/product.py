from typing import Optional, Union
from uuid import UUID
from pydantic import BaseModel, ConfigDict


class ProductResponse(BaseModel):
    id: Union[UUID, str]
    barcode: Optional[str] = None
    name: str
    brand: Optional[str] = None
    category: str
    health_score: Optional[float] = None
    nutri_score: Optional[str] = None
    safety_score: Optional[float] = None
    ingredients_text: Optional[str] = None
    image_url: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)
