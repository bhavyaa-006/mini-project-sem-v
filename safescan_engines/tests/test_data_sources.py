import asyncio
import threading
from http.server import BaseHTTPRequestHandler, HTTPServer

import httpx

from safescan_engines.data_sources.cache import (
    get_cached_product,
    get_products_by_category,
    save_cached_product,
)
from safescan_engines.data_sources.normalizer import normalize_off_product
from safescan_engines.data_sources.off_client import fetch_off_product
from safescan_engines.data_sources.obf_client import fetch_obf_product
from safescan_engines.data_sources.robots_check import can_fetch_url
from safescan_engines.schemas import ProductDomain


def test_normalizer_sodium_fallback_and_missing_fields():
    categorical = normalize_off_product({
        "status": 1,
        "product": {
            "code": "4",
            "categories_tags": [
                "en:snacks",
                "en:sweet-snacks",
                "en:biscuits-and-cakes",
                "en:chocolate-biscuits",
            ],
        },
    })
    assert categorical.category == "chocolate-biscuits"

    sodium = normalize_off_product({
        "status": 1,
        "product": {
            "code": "1",
            "nutriments": {"sodium_100g": 0.4},
        },
    })
    assert sodium.nutrients.sodium_mg == 400.0

    salt = normalize_off_product({
        "status": 1,
        "product": {"code": "2", "nutriments": {"salt_100g": 2.5}},
    })
    assert salt.nutrients.sodium_mg == 1000.0

    missing = normalize_off_product({
        "status": 1,
        "product": {"code": "3", "nutriments": {}},
    })
    assert missing.nutrients.sugars_g is None
    assert missing.nutrients.sodium_mg is None
    assert missing.nutrients.energy_kcal is None

    from_kcal = normalize_off_product({
        "status": 1,
        "product": {"code": "4", "nutriments": {"energy-kcal_100g": 100}},
    })
    assert from_kcal.nutrients.energy_kcal == 100.0

    from_kj = normalize_off_product({
        "status": 1,
        "product": {"code": "5", "nutriments": {"energy-kj_100g": 418.4}},
    })
    assert abs(from_kj.nutrients.energy_kcal - 100.0) < 0.0001


def test_off_and_obf_mock_transport():
    def handler(request: httpx.Request) -> httpx.Response:
        assert request.headers["user-agent"]
        if "890123" in str(request.url):
            payload = {
                "status": 1,
                "product": {
                    "code": "890123",
                    "product_name": "Mock Oats",
                    "brands": "SafeScan",
                    "categories_tags": ["en:breakfast-cereal"],
                    "ingredients_text": "oats, sugar",
                    "nutriments": {"sodium_100g": 0.4},
                },
            }
        else:
            payload = {"status": 0, "product": None}
        return httpx.Response(200, json=payload)

    transport = httpx.MockTransport(handler)
    async def run():
        async with httpx.AsyncClient(transport=transport) as client:
            off = await fetch_off_product("890123", client)
            obf = await fetch_obf_product("missing", client)
            return off, obf

    off, obf = asyncio.run(run())
    assert off is not None
    assert off.nutrients.sodium_mg == 400.0
    assert obf is None


def test_cache_round_trip_and_category_filter(db_session, sample_food_product):
    sample = sample_food_product.model_copy(update={"category": "breakfast-cereal"})
    save_cached_product(db_session, sample)
    db_session.commit()
    assert get_cached_product(db_session, sample.barcode) == sample

    other = sample.model_copy(
        update={"barcode": "8901234567891", "name": "Another Oats", "category": "breakfast-cereal"}
    )
    save_cached_product(db_session, other)
    db_session.commit()
    products = get_products_by_category(
        db_session,
        "breakfast-cereal",
        ProductDomain.FOOD,
        exclude_barcode=sample_food_product.barcode,
    )
    assert [product.barcode for product in products] == [other.barcode]


def test_robots_check_allows_and_blocks(monkeypatch):
    class MockParser:
        def set_url(self, url):
            pass

        def read(self):
            pass

        def can_fetch(self, user_agent, url):
            return "/private" not in url

    from safescan_engines.data_sources import robots_check

    monkeypatch.setattr(robots_check, "RobotFileParser", lambda url: MockParser())
    robots_check._robots_cache.clear()
    assert can_fetch_url("https://example.test/public") is True
    assert can_fetch_url("https://example.test/private/item") is False