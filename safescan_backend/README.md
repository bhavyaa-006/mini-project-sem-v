# SafeScan Backend

FastAPI + PostgreSQL backend for the SafeScan & PackCheck AI project.

## Quick Start

```bash
# 1. Copy and edit env
cp .env.example .env

# 2. Start services
docker compose up -d

# 3. Seed hazard ingredients database
docker compose exec api python -m scripts.seed_hazard_ingredients

# 4. Access API docs
open http://localhost:8000/docs
```

## Running Locally (without Docker)

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# Make sure PostgreSQL is running and DATABASE_URL in .env is correct
uvicorn app.main:app --reload
```

## Running Tests

```bash
pip install -r requirements-dev.txt
pytest tests/ -v
```

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/auth/register` | Register new user |
| POST | `/api/v1/auth/login` | Login → JWT token |
| GET  | `/api/v1/products/{barcode}` | Fetch product from OFF/OBF cache |
| POST | `/api/v1/analyze/` | Full product analysis |
| POST | `/api/v1/scan/upload` | Upload label image (OCR + analysis) |
| GET  | `/api/v1/user/profile` | Get user profile |
| PUT  | `/api/v1/user/profile` | Update preferences/allergies |
| GET  | `/api/v1/history/` | Scan history |
| GET  | `/report/{scan_id}/pdf` | Download PDF audit report |
| GET  | `/api/v1/alternatives/{product_id}` | Get alternative products |
