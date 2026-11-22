from typing import Optional, List
from pydantic import BaseModel


class ScanResponse(BaseModel):
    scan_id: str
    status: str = "success"
    message: Optional[str] = None
    ocr_fields: Optional[dict] = None


class AnalyzeRequest(BaseModel):
    barcode: Optional[str] = None
    product_name: Optional[str] = None
    category: Optional[str] = "food"
    ocr_text: Optional[str] = None
