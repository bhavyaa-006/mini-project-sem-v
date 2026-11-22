from typing import Literal

from pydantic import BaseModel, Field
from enum import Enum


class ProductDomain(str, Enum):
    FOOD = "food"
    COSMETIC = "cosmetic"


class NutriGrade(str, Enum):
    A = "A"
    B = "B"
    C = "C"
    D = "D"
    E = "E"


class CosmeticBand(str, Enum):
    GOOD = "Good"
    FAIR = "Fair"
    CAUTION = "Caution"
    AVOID = "Avoid"


class SeverityTier(str, Enum):
    HIGH = "high"
    MODERATE = "moderate"
    LOW = "low"


class ComplianceStatus(str, Enum):
    PASS = "PASS"
    FAIL = "FAIL"
    UNKNOWN = "UNKNOWN"


class DataStatus(str, Enum):
    OK = "OK"
    INSUFFICIENT_DATA = "INSUFFICIENT_DATA"
    NOT_FOUND = "NOT_FOUND"


class NutrientProfile(BaseModel):
    energy_kj: float | None = Field(default=None, ge=0)
    sugars_g: float | None = Field(default=None, ge=0)
    saturated_fat_g: float | None = Field(default=None, ge=0)
    sodium_mg: float | None = Field(default=None, ge=0)
    fiber_g: float | None = Field(default=None, ge=0)
    protein_g: float | None = Field(default=None, ge=0)
    fvl_percent: float | None = Field(default=None, ge=0, le=100)


class NormalizedProduct(BaseModel):
    barcode: str | None = None
    name: str | None = None
    brand: str | None = None
    domain: ProductDomain
    category: str | None = None
    ingredients_raw: str | None = None
    ingredients_list: list[str] = Field(default_factory=list)
    nutrients: NutrientProfile | None = None
    source: Literal["off", "obf", "ocr", "manual"] = "off"


class IngredientHit(BaseModel):
    raw_token: str
    matched_canonical: str
    match_type: Literal["exact", "fuzzy"]
    match_score: float = Field(ge=0, le=100)
    severity: SeverityTier
    position: int = Field(ge=1)
    position_factor: float
    points_deducted: float = Field(ge=0)
    reason: str
    source_url: str | None = None


class HealthResult(BaseModel):
    status: DataStatus
    domain: ProductDomain
    nutri_raw_score: int | None = None
    nutri_grade: NutriGrade | None = None
    cosmetic_score: int | None = Field(default=None, ge=0, le=100)
    cosmetic_band: CosmeticBand | None = None
    capped_by_high_severity: bool = False
    deductions: list[IngredientHit] = Field(default_factory=list)
    personal_alerts: list[str] = Field(default_factory=list)


class ClauseCheck(BaseModel):
    clause_id: str
    title: str
    status: ComplianceStatus
    extracted_value: str | None = None
    note: str = ""


class ComplianceResult(BaseModel):
    overall_status: ComplianceStatus
    checks: list[ClauseCheck] = Field(default_factory=list)
    dual_mrp_detected: bool = False


class AuditReportPayload(BaseModel):
    product: NormalizedProduct
    health: HealthResult
    compliance: ComplianceResult
    alternatives: list[NormalizedProduct] = Field(default_factory=list)
    summary_highlights: list[str] = Field(default_factory=list)
