"""
Utility script to fetch and cache sample Open Food Facts and Open Beauty Facts products.
Run: python -m scripts.fetch_off_products
"""
import asyncio
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.db.session import SessionLocal, engine
from app.db.base import Base
from app.services.product_service import get_or_fetch_product

SAMPLE_BARCODES = [
    ("8901030920431", "food"),       # Maggie Noodles / Indian FMCG
    ("8901262010054", "food"),       # Amul Butter
    ("8904005928114", "cosmetic"),   # Nivea / cosmetic
]


async def main():
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    print("🚀 Fetching sample products from Open Food Facts / Open Beauty Facts...")
    try:
        for barcode, category in SAMPLE_BARCODES:
            print(f"Fetching barcode: {barcode} ({category})...")
            p = await get_or_fetch_product(db, barcode, category)
            if p:
                print(f"  ✅ Cached: {p.name} | Nutri-Score: {p.nutri_score}")
            else:
                print(f"  ⚠️ Not found on OFF/OBF API.")
    finally:
        db.close()


if __name__ == "__main__":
    asyncio.run(main())
