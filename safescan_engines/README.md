# SafeScan Engines

Developer documentation for `safescan-engines`, the core scoring, Legal Metrology compliance, OCR, and PDF report engines for SafeScan and PackCheck AI. The project is developed at BMSIT&M, Department of Computer Science and Engineering.

## Project Overview

The repository provides shared Pydantic schemas, SQLAlchemy foundations, and deterministic Engine B health calculations. It currently includes the 2017 Original Nutri-Score, cosmetic ingredient matching and scoring, personal allergen/sensitivity alerts, and itemized ingredient deductions.

## Repository Structure

```text
safescan_engines/       Editable Python package and package modules
data/                   Hazard and verification data
docs/                   Data-source and scoring documentation
reports/                Generated report artifacts
scripts/                Utility and verification scripts
tests/                  Phase 1 foundation and Phase 2 health tests
pyproject.toml          Package metadata and pytest configuration
.env.example            Example environment configuration
```

The installable package is the inner `safescan_engines/` directory. Run package and test commands from this project root.

## Prerequisites and Installation

- Python 3.10 or newer
- A virtual environment

```bash
python -m venv .venv
```

Activate it on Linux or macOS:

```bash
source .venv/bin/activate
```

Activate it on Windows PowerShell:

```powershell
.venv\Scripts\Activate.ps1
```

Install the package and development tools in editable mode:

```bash
pip install -e ".[dev]"
```

OCR dependencies are available for later phases:

```bash
pip install -e ".[dev,ocr]"
```

Create a local environment file:

```bash
cp .env.example .env
```

| Variable | Purpose |
|---|---|
| `DATABASE_URL` | SQLAlchemy database URL. The default uses a local SQLite development database. |
| `OFF_USER_AGENT` | User-Agent sent to Open Food Facts and identified with the project/contact details. |
| `FUZZY_MATCH_THRESHOLD` | Minimum fuzzy ingredient match score, from 0 to 100. |
| `LLM_API_KEY` | Optional API key for future LLM-powered summaries. Leave empty when unused. |

## Quickstart Usage

### Nutri-Score example

```python
from safescan_engines.schemas import NutrientProfile
from safescan_engines.health.nutri_score import calculate_nutri_score

nutrients = NutrientProfile(
    energy_kj=1900,
    sugars_g=25,
    saturated_fat_g=8,
    sodium_mg=400,
    fiber_g=2,
    protein_g=6,
    fvl_percent=0,
)

result = calculate_nutri_score(nutrients)
print(result.nutri_raw_score, result.nutri_grade)
# 19 NutriGrade.E
```

The engine requires all seven nutrient fields for a valid score.

### Cosmetic safety example

```python
from safescan_engines.health.cosmetic_score import calculate_cosmetic_score
from safescan_engines.health.ingredient_matcher import HazardEntry
from safescan_engines.schemas import ProductDomain, SeverityTier

catalog = [
    HazardEntry(
        canonical_name="Phenoxyethanol",
        aliases=[],
        severity=SeverityTier.MODERATE,
        domain=ProductDomain.COSMETIC,
        reason="Potential preservative-related irritation",
    ),
]

result = calculate_cosmetic_score(
    ingredients_raw="Aqua, Phenoxyethanol",
    ingredients_list=[],
    catalog=catalog,
)

print(result.cosmetic_score, result.cosmetic_band)
for deduction in result.deductions:
    print(
        deduction.raw_token,
        deduction.position,
        deduction.points_deducted,
        deduction.reason,
    )
```

## Running Tests

Run the full suite:

```bash
pytest -v
```

Run only the Phase 1 foundation tests:

```bash
pytest tests/test_phase1_foundation.py -v
```

Run only the Phase 2 health engine tests:

```bash
pytest tests/test_health.py -v
```

## Implementation Roadmap Status

- [x] Phase 1: Foundation, packaging, configuration, schemas, and SQLAlchemy sessions
- [x] Phase 2: Engine B — health and safety, Nutri-Score, cosmetic matching/scoring, and personal alerts
- [x] Phase 3: Hazard DB and OFF/OBF data-source ingestion
- [x] Phase 4: Engine A — Legal Metrology compliance
- [x] Phase 5: Alternatives, summaries, and PDF audit reports
- [x] Phase 6: OCR preprocessing, extraction, and benchmark pipeline
- [x] Phase 7: CLI scripts, verification, documentation, and end-to-end pipeline

## CLI Scripts

Run all scripts from the `safescan_engines/` project root:

```bash
python scripts/seed_hazards.py [--csv-dir PATH] [--db-url URL]
python scripts/fetch_products.py [--barcodes 890...,890...] [--file PATH] [--domain food|cosmetic] [--delay 1.0]
python scripts/verify_scores.py
python scripts/run_ocr_benchmark.py [--ground-truth PATH] [--image-dir PATH] [--output PATH]
python scripts/generate_sample_report.py [--barcode BARCODE]
```

Use `--help` with any script for its full argument list.

## Technical Documentation

- `docs/scoring_formulas.md`
- `docs/legal_metrology_clause_map.md`
- `docs/data_sources_and_licences.md`

`reports/score_verification.csv` is generated by the 10-product score verifier.
