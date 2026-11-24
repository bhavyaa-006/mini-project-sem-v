from safescan_engines.pdf.audit_report import build_audit_pdf_bytes
from safescan_engines.health.nutri_score import calculate_nutri_score
from safescan_engines.health.cosmetic_score import calculate_cosmetic_score
from safescan_engines.health.ingredient_matcher import HazardEntry
from safescan_engines.schemas import (
    AuditReportPayload,
    ClauseCheck,
    ComplianceResult,
    ComplianceStatus,
    NormalizedProduct,
    NutrientProfile,
    ProductDomain,
    SeverityTier,
)


def test_food_pdf():
    product = NormalizedProduct(
        barcode="100",
        name="Oats",
        brand="Brand",
        domain=ProductDomain.FOOD,
        category="cereals",
        nutrients=NutrientProfile(
            energy_kcal=36,
            sugars_g=2,
            saturated_fat_g=0.2,
            sodium_mg=20,
            fiber_g=3,
            protein_g=4,
            fvl_percent=90,
        ),
        source="off",
    )
    health = calculate_nutri_score(product.nutrients)
    compliance = ComplianceResult(
        overall_status=ComplianceStatus.PASS,
        checks=[ClauseCheck(
            clause_id="6(1)(e)",
            title="Maximum Retail Price",
            status=ComplianceStatus.PASS,
            extracted_value="120.0",
        )],
    )
    payload = AuditReportPayload(
        product=product,
        health=health,
        compliance=compliance,
        alternatives=[product.model_copy(update={"barcode": "101", "name": "Better Oats"})],
        summary_highlights=["Nutri-Score A"],
    )
    pdf = build_audit_pdf_bytes(payload)
    assert pdf.startswith(b"%PDF-")
    assert len(pdf) > 100


def test_cosmetic_pdf():
    catalog = [
        HazardEntry(
            canonical_name="Sodium Lauryl Sulfate",
            aliases=["SLS"],
            severity=SeverityTier.HIGH,
            domain=ProductDomain.COSMETIC,
            reason="Irritant",
        )
    ]
    product = NormalizedProduct(
        barcode="200",
        name="Shampoo",
        brand="Brand",
        domain=ProductDomain.COSMETIC,
        category="shampoo",
        ingredients_raw="Water, Sodium Lauryl Sulfate",
        ingredients_list=["Water", "Sodium Lauryl Sulfate"],
        source="obf",
    )
    health = calculate_cosmetic_score(
        product.ingredients_raw, product.ingredients_list, catalog
    )
    compliance = ComplianceResult(
        overall_status=ComplianceStatus.FAIL,
        dual_mrp_detected=True,
        checks=[ClauseCheck(
            clause_id="6(3)",
            title="Dual-MRP",
            status=ComplianceStatus.FAIL,
            extracted_value="150.0, 180.0",
        )],
    )
    payload = AuditReportPayload(
        product=product,
        health=health,
        compliance=compliance,
        summary_highlights=["Cosmetic safety review"],
    )
    pdf = build_audit_pdf_bytes(payload)
    assert pdf.startswith(b"%PDF-")
    assert len(pdf) > 100