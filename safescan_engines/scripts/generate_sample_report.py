import argparse
from datetime import date

from safescan_engines.config import settings
from safescan_engines.data_sources.cache import get_cached_product
from safescan_engines.db import session_scope
from safescan_engines.health.nutri_score import calculate_nutri_score
from safescan_engines.legal_metrology.compliance import evaluate_legal_metrology
from safescan_engines.pdf.audit_report import write_audit_pdf
from safescan_engines.schemas import (
    AuditReportPayload,
    ClauseCheck,
    ComplianceResult,
    ComplianceStatus,
    CosmeticBand,
    IngredientHit,
    NutriGrade,
    NormalizedProduct,
    NutrientProfile,
    ProductDomain,
    SeverityTier,
)
from safescan_engines.health.cosmetic_score import calculate_cosmetic_score
from safescan_engines.health.ingredient_matcher import HazardEntry
from safescan_engines.summary.rule_based_summary import generate_rule_based_highlights


def sample_product() -> NormalizedProduct:
    return NormalizedProduct(
        barcode="8901058851298",
        name="Sample Masala Oats",
        brand="SafeScan Sample",
        domain=ProductDomain.FOOD,
        category="breakfast-cereals",
        ingredients_raw="oats, sugar",
        ingredients_list=["oats", "sugar"],
        nutrients=NutrientProfile(
            energy_kj=1900,
            sugars_g=25,
            saturated_fat_g=8,
            sodium_mg=400,
            fiber_g=2,
            protein_g=6,
            fvl_percent=0,
        ),
        source="manual",
    )


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate a SafeScan audit PDF")
    parser.add_argument("--barcode", help="Load a cached product by barcode")
    args = parser.parse_args()

    product = sample_product()
    if args.barcode:
        with session_scope() as session:
            cached = get_cached_product(session, args.barcode)
        if cached:
            product = cached

    health = calculate_nutri_score(product.nutrients)
    label = (
        "Mfd. by: SafeScan Sample Foods Pvt. Ltd., Bengaluru - 560001\n"
        "Net Wt.: 250 g\n"
        "MFD: 09/2026\n"
        "BEST BEFORE 9 MONTHS FROM MFD\n"
        "MRP Rs. 120.00 (Incl. of all taxes)\n"
        "Consumer Care: care@safescan.example"
    )
    compliance = evaluate_legal_metrology(
        label,
        domain=product.domain,
        product_name=product.name,
        reference_date=date.today(),
    )
    payload = AuditReportPayload(
        product=product,
        health=health,
        compliance=compliance,
        alternatives=[],
    )
    payload.summary_highlights = generate_rule_based_highlights(
        product, health, compliance
    )
    food_output = settings.REPORTS_DIR / "sample_food_audit_report.pdf"
    write_audit_pdf(payload, food_output)
    print(food_output)

    cosmetic_catalog = [
        HazardEntry(
            canonical_name="Sodium Lauryl Sulfate",
            aliases=["SLS"],
            severity=SeverityTier.HIGH,
            domain=ProductDomain.COSMETIC,
            reason="Strong surfactant that may irritate sensitive skin",
        )
    ]
    cosmetic_product = NormalizedProduct(
        barcode="8909876543210",
        name="Sample Sensitive Shampoo",
        brand="SafeScan Personal Care",
        domain=ProductDomain.COSMETIC,
        category="shampoo",
        ingredients_raw="Aqua, Sodium Lauryl Sulfate",
        ingredients_list=["Aqua", "Sodium Lauryl Sulfate"],
        source="manual",
    )
    cosmetic_health = calculate_cosmetic_score(
        cosmetic_product.ingredients_raw,
        cosmetic_product.ingredients_list,
        cosmetic_catalog,
    )
    cosmetic_compliance = ComplianceResult(
        overall_status=ComplianceStatus.FAIL,
        dual_mrp_detected=True,
        checks=[
            ClauseCheck(
                clause_id="6(1)(c)",
                title="Net Quantity",
                status=ComplianceStatus.PASS,
                extracted_value="200 ml",
            ),
            ClauseCheck(
                clause_id="6(3)",
                title="No Tampering / Dual-MRP",
                status=ComplianceStatus.FAIL,
                extracted_value="150.0, 180.0",
                note="Conflicting MRP declarations found.",
            ),
        ],
    )
    cosmetic_payload = AuditReportPayload(
        product=cosmetic_product,
        health=cosmetic_health,
        compliance=cosmetic_compliance,
        alternatives=[],
        summary_highlights=[
            "Cosmetic Safety Score: 49/100 (Avoid) — capped due to high-severity ingredient.",
            "Legal Metrology Alert: Dual-MRP declarations require review.",
        ],
    )
    cosmetic_payload.health.personal_alerts = ["Personal alert: avoid fragrance"]
    cosmetic_output = settings.REPORTS_DIR / "sample_cosmetic_audit_report.pdf"
    write_audit_pdf(cosmetic_payload, cosmetic_output)
    print(cosmetic_output)


if __name__ == "__main__":
    main()