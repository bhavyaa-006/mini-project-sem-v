import argparse
import csv
import sys
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parents[1]
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

from safescan_engines.health.cosmetic_score import calculate_cosmetic_score
from safescan_engines.health.ingredient_matcher import HazardEntry
from safescan_engines.health.nutri_score import calculate_nutri_score
from safescan_engines.schemas import (
    NutrientProfile,
    ProductDomain,
    SeverityTier,
)


def main() -> int:
    parser = argparse.ArgumentParser(description="Verify hand-calculated health scores")
    parser.add_argument(
        "--input",
        type=Path,
        default=ROOT_DIR / "data" / "score_verification" / "manual_scores.csv",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=ROOT_DIR / "reports" / "score_verification.csv",
    )
    args = parser.parse_args()

    catalog = [
        HazardEntry(
            canonical_name="Sodium Lauryl Sulfate",
            aliases=["SLS"],
            severity=SeverityTier.HIGH,
            domain=ProductDomain.COSMETIC,
            reason="Irritant",
        ),
        HazardEntry(
            canonical_name="Methylparaben",
            aliases=[],
            severity=SeverityTier.MODERATE,
            domain=ProductDomain.COSMETIC,
            reason="Preservative",
        ),
    ]
    results = []
    with args.input.open("r", encoding="utf-8-sig", newline="") as handle:
        for row in csv.DictReader(handle):
            domain = row["domain"].strip().lower()
            if domain == "food":
                nutrients = NutrientProfile(
                    energy_kj=_float(row["energy_kj"]),
                    sugars_g=_float(row["sugars_g"]),
                    saturated_fat_g=_float(row["saturated_fat_g"]),
                    sodium_mg=_float(row["sodium_mg"]),
                    fiber_g=_float(row["fiber_g"]),
                    protein_g=_float(row["protein_g"]),
                    fvl_percent=_float(row["fvl_percent"]),
                )
                result = calculate_nutri_score(nutrients)
                actual = str(result.nutri_raw_score)
                expected = row["expected_raw_or_score"].strip()
                actual_label = result.nutri_grade.value if result.nutri_grade else ""
            else:
                result = calculate_cosmetic_score(
                    row["ingredients_raw"],
                    [],
                    catalog,
                )
                actual = str(result.cosmetic_score)
                expected = row["expected_raw_or_score"].strip()
                actual_label = result.cosmetic_band.value if result.cosmetic_band else ""

            expected_label = row["expected_grade_or_band"].strip()
            match = actual == expected and actual_label == expected_label
            results.append({
                "product_id": row["product_id"],
                "name": row["name"],
                "domain": domain,
                "expected": f"{expected}/{expected_label}",
                "actual": f"{actual}/{actual_label}",
                "match": "PASS" if match else "FAIL",
            })

    args.output.parent.mkdir(parents=True, exist_ok=True)
    fieldnames = ["product_id", "name", "domain", "expected", "actual", "match"]
    with args.output.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(results)

    mismatches = [row for row in results if row["match"] == "FAIL"]
    for row in results:
        print(f"{row['product_id']}: {row['match']} expected={row['expected']} actual={row['actual']}")
    print(f"{len(results) - len(mismatches)}/{len(results)} PASS")
    return 1 if mismatches else 0


def _float(value: str) -> float | None:
    value = value.strip()
    return float(value) if value else None


if __name__ == "__main__":
    raise SystemExit(main())
