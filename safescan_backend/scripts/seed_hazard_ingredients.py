"""
Seed hazard ingredients from data/hazard_ingredients_seed.csv into PostgreSQL.
Run: python -m scripts.seed_hazard_ingredients
"""
import csv
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.db.session import SessionLocal
from app.models.hazard_ingredient import HazardIngredient
from app.db.base import Base
from app.db.session import engine

Base.metadata.create_all(bind=engine)

CSV_PATH = os.path.join(os.path.dirname(__file__), "..", "data", "hazard_ingredients_seed.csv")


def seed():
    db = SessionLocal()
    try:
        count = 0
        with open(CSV_PATH, newline="", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            for row in reader:
                existing = db.query(HazardIngredient).filter(
                    HazardIngredient.name == row["name"]
                ).first()
                if existing:
                    continue
                aliases = [a.strip() for a in row.get("aliases", "").split(",") if a.strip()]
                record = HazardIngredient(
                    name=row["name"],
                    aliases=aliases,
                    category=row["category"],
                    hazard_level=row["hazard_level"],
                    regulatory_source=row["regulatory_source"],
                    reason=row["reason"],
                    scientific_details=row.get("scientific_details") or None,
                    e_number=row.get("e_number") or None,
                )
                db.add(record)
                count += 1
        db.commit()
        print(f"✅ Seeded {count} hazard ingredients.")
    except Exception as e:
        db.rollback()
        print(f"❌ Seeding failed: {e}")
    finally:
        db.close()


if __name__ == "__main__":
    seed()
