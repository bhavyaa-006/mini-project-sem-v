from safescan_engines.alternatives.recommender import recommend_alternatives
from safescan_engines.data_sources.cache import save_cached_product
from safescan_engines.data_sources.normalizer import normalize_off_product
from safescan_engines.hazard_db.loader import upsert_hazards
from safescan_engines.hazard_db.validators import HazardRowSchema
from safescan_engines.health.nutri_score import calculate_nutri_score
from safescan_engines.legal_metrology.compliance import evaluate_legal_metrology
from safescan_engines.pdf.audit_report import build_audit_pdf_bytes
from safescan_engines.schemas import AuditReportPayload, ProductDomain
from safescan_engines.summary.rule_based_summary import generate_rule_based_highlights


def test_complete_food_pipeline(db_session):
    hazard = HazardRowSchema.model_validate({
        "canonical_name": "Sodium Lauryl Sulfate",
        "aliases": "SLS",
        "severity": "high",
        "domain": "cosmetic",
        "reason": "Irritant",
        "source_url": "https://example.com/sls",
    })
    upsert_hazards(db_session, [hazard])

    target = normalize_off_product({
        "status": 1,
        "product": {
            "code": "8900000000001",
            "product_name": "Test Oats",
            "brands": "SafeScan",
            "categories_tags": ["en:breakfast-cereals", "en:oatmeal"],
            "ingredients_text": "oats, sugar",
            "nutriments": {
                "energy-kcal_100g": 454,
                "sugars_100g": 25,
                "saturated-fat_100g": 8,
                "sodium_100g": 0.4,
                "fiber_100g": 2,
                "proteins_100g": 6,
                "fruits-vegetables-nuts-estimate-from-ingredients_100g": 0,
            },
        },
    })
    candidate = normalize_off_product({
        "status": 1,
        "product": {
            "code": "8900000000002",
            "product_name": "Better Oats",
            "brands": "SafeScan",
            "categories_tags": ["en:breakfast-cereals", "en:oatmeal"],
            "ingredients_text": "oats",
            "nutriments": {
                "energy-kcal_100g": 36,
                "sugars_100g": 2,
                "saturated-fat_100g": 0.2,
                "sodium_100g": 0.02,
                "fiber_100g": 3,
                "proteins_100g": 4,
                "fruits-vegetables-nuts-estimate-from-ingredients_100g": 90,
            },
        },
    })
    assert target is not None and candidate is not None
    save_cached_product(db_session, target)
    save_cached_product(db_session, candidate)
    db_session.commit()

    health = calculate_nutri_score(target.nutrients)
    compliance = evaluate_legal_metrology(
        "Mfd. by: Test Foods, Bengaluru - 560001\n"
        "Net Wt.: 250 g\nMFD: 09/2026\n"
        "BEST BEFORE 9 MONTHS FROM MFD\n"
        "MRP Rs. 120.00 (Incl. of all taxes)\n"
        "Consumer Care: 1800-123-4567",
        domain=ProductDomain.FOOD,
        product_name=target.name,
    )
    alternatives = recommend_alternatives(
        db_session,
        target,
        health,
        catalog=[],
        limit=3,
    )
    highlights = generate_rule_based_highlights(
        target,
        health,
        compliance,
        alternatives,
    )
    payload = AuditReportPayload(
        product=target,
        health=health,
        compliance=compliance,
        alternatives=[item.product for item in alternatives],
        summary_highlights=highlights,
    )
    pdf = build_audit_pdf_bytes(payload)

    assert payload.product.barcode == "8900000000001"
    assert alternatives
    assert pdf.startswith(b"%PDF-")
