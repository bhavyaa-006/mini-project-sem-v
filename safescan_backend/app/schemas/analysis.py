from typing import Optional, List
from pydantic import BaseModel


class FlaggedIngredient(BaseModel):
    name: str
    hazard_level: str                  # "low" | "moderate" | "high" | "info"
    reason: str
    category: Optional[str] = None
    scientific_details: Optional[str] = None
    regulatory_status: Optional[str] = None
    e_number: Optional[str] = None
    data_source: Optional[str] = None
    is_verified: Optional[bool] = None


class LegalMetrology(BaseModel):
    compliant: bool
    mrp: Optional[str] = None
    net_quantity: Optional[str] = None
    expiry_date: Optional[str] = None
    manufacture_date: Optional[str] = None
    batch_number: Optional[str] = None
    manufacturer_name: Optional[str] = None
    manufacturer_address: Optional[str] = None
    consumer_care_details: Optional[str] = None
    country_of_origin: Optional[str] = None
    fssai_license_number: Optional[str] = None
    missing_fields: List[str] = []
    compliance_score: Optional[float] = None
    notes: Optional[str] = None


class AlternativeProduct(BaseModel):
    id: str
    name: str
    brand: str
    category: str
    score: float
    rating_tier: str
    highlight_reason: str
    mrp: Optional[str] = None
    net_quantity: Optional[str] = None
    image_url: Optional[str] = None


class ProductAnalysisResponse(BaseModel):
    id: str
    barcode: Optional[str] = None
    name: str
    brand: str
    category: str
    score: float
    rating_tier: str
    rating_label: str
    nutri_score: Optional[str] = None
    safety_score: Optional[float] = None
    summary: str
    image_url: Optional[str] = None
    ingredients_text: Optional[str] = None
    ingredients_list: Optional[List[str]] = None
    flagged_ingredients: List[FlaggedIngredient] = []
    positive_points: List[str] = []
    negative_points: List[str] = []
    legal_metrology: LegalMetrology
    alternatives: List[AlternativeProduct] = []
    scanned_at: Optional[str] = None
    pack_verified: Optional[bool] = None
