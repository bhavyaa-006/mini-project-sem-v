"""
Open Food Facts (OFF) & Open Beauty Facts (OBF) API client.
Fetches product data by barcode and caches it in PostgreSQL.
"""
import json
from typing import Optional
import httpx

OFF_BASE = "https://world.openfoodfacts.org/api/v2/product"
OBF_BASE = "https://world.openbeautyfacts.org/api/v2/product"

HEADERS = {"User-Agent": "SafeScan-PackCheck/1.0 (github.com/bhavyaa-006/mini-project-sem-v)"}


async def fetch_product(barcode: str, category: str = "food") -> Optional[dict]:
    """Return raw product dict from OFF/OBF or None if not found."""
    base = OBF_BASE if category == "cosmetic" else OFF_BASE
    url = f"{base}/{barcode}.json"
    try:
        async with httpx.AsyncClient(timeout=10.0, headers=HEADERS) as client:
            resp = await client.get(url)
            if resp.status_code != 200:
                return None
            data = resp.json()
            if data.get("status") != 1:
                return None
            return data.get("product", {})
    except Exception:
        return None


def parse_product_fields(raw: dict, barcode: str, category: str) -> dict:
    """Extract & normalize essential fields from OFF/OBF response."""
    return {
        "barcode": barcode,
        "name": raw.get("product_name") or raw.get("product_name_en") or "Unknown",
        "brand": raw.get("brands", ""),
        "category": category,
        "ingredients_text": raw.get("ingredients_text") or raw.get("ingredients_text_en", ""),
        "image_url": raw.get("image_url") or raw.get("image_front_url", ""),
        "nutri_score": raw.get("nutriscore_grade", "").upper() or None,
        "off_data": json.dumps(raw),
    }
