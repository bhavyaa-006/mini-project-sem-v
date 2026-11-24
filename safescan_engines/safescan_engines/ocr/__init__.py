from typing import Literal

from pydantic import BaseModel, Field


class OcrLine(BaseModel):
    text: str
    confidence: float = Field(default=0.0, ge=0.0, le=1.0)
    bbox: list[tuple[float, float]] = Field(default_factory=list)


class OcrDocumentResult(BaseModel):
    engine: Literal["paddle", "tesseract"]
    preprocessed: bool
    full_text: str
    lines: list[OcrLine] = Field(default_factory=list)
    mean_confidence: float = Field(default=0.0, ge=0.0, le=1.0)


class ExtractedLabelFields(BaseModel):
    raw_text: str
    ingredients_text: str | None = None
    mrp_text: str | None = None
    net_quantity_text: str | None = None
    dates_text: str | None = None
    manufacturer_text: str | None = None


__all__ = [
    "OcrLine",
    "OcrDocumentResult",
    "ExtractedLabelFields",
]