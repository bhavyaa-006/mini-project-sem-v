import asyncio

import httpx

from safescan_engines.config import settings
from safescan_engines.health.ingredient_matcher import HazardEntry
from safescan_engines.health.nutri_score import calculate_nutri_score
from safescan_engines.schemas import (
    ComplianceResult,
    ComplianceStatus,
    HealthResult,
    NormalizedProduct,
    NutrientProfile,
    ProductDomain,
)
from safescan_engines.summary.llm_summary import generate_summary_highlights
from safescan_engines.summary.rule_based_summary import generate_rule_based_highlights


def make_food():
    product = NormalizedProduct(
        barcode="1",
        name="Masala Oats",
        domain=ProductDomain.FOOD,
        nutrients=NutrientProfile(
            energy_kcal=454,
            sugars_g=25,
            saturated_fat_g=8,
            sodium_mg=400,
            fiber_g=2,
            protein_g=6,
            fvl_percent=0,
        ),
    )
    health = calculate_nutri_score(product.nutrients)
    health.personal_alerts = ["Avoid peanuts"]
    compliance = ComplianceResult(
        overall_status=ComplianceStatus.FAIL,
        checks=[],
    )
    return product, health, compliance


def test_rule_based_food_and_legal_status():
    product, health, compliance = make_food()
    bullets = generate_rule_based_highlights(product, health, compliance)
    text = " ".join(bullets)
    assert "Nutri-Score" in text
    assert "Personal alert: Avoid peanuts" in text
    assert "Legal Metrology" in text


def test_cosmetic_rule_and_personal_alert():
    product = NormalizedProduct(
        barcode="2", name="Face Cream", domain=ProductDomain.COSMETIC
    )
    health = HealthResult(
        status="INSUFFICIENT_DATA",
        domain=ProductDomain.COSMETIC,
        personal_alerts=["Avoid fragrance"],
    )
    compliance = ComplianceResult(overall_status=ComplianceStatus.UNKNOWN)
    bullets = generate_rule_based_highlights(product, health, compliance)
    text = " ".join(bullets)
    assert "Insufficient nutrition/ingredient data" in text
    assert "Personal alert: Avoid fragrance" in text


def test_llm_none_and_fallback(monkeypatch):
    product, health, compliance = make_food()
    baseline = generate_rule_based_highlights(product, health, compliance)

    monkeypatch.setattr(settings, "llm_api_key", None)
    assert asyncio.run(
        generate_summary_highlights(product, health, compliance)
    ) == baseline

    monkeypatch.setattr(settings, "llm_api_key", "test-key")

    def raise_connect(request):
        raise httpx.ConnectError("offline")

    transport = httpx.MockTransport(raise_connect)
    async def run():
        async with httpx.AsyncClient(transport=transport) as client:
            return await generate_summary_highlights(
                product, health, compliance, client=client
            )
    assert asyncio.run(run()) == baseline