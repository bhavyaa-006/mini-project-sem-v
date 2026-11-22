from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from slowapi.errors import RateLimitExceeded
from slowapi.middleware import SlowAPIMiddleware
from fastapi.responses import JSONResponse

from app.core.config import settings
from app.core.rate_limit import limiter
from app.db.base import Base
from app.db.session import engine

# Import all route modules
from app.api.routes import (
    health, auth, product, analyze, scan, profile, history, report, alternatives, admin
)

# Create all tables on startup (for development; use Alembic for production)
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="SafeScan & PackCheck API",
    description="AI-powered food & cosmetic product analysis backend",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# ── Rate Limiting ──────────────────────────────────────────────────────────────
app.state.limiter = limiter
app.add_middleware(SlowAPIMiddleware)


@app.exception_handler(RateLimitExceeded)
async def rate_limit_handler(request, exc):
    return JSONResponse(status_code=429, content={"detail": "Rate limit exceeded. Try again later."})


# ── CORS ───────────────────────────────────────────────────────────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Routers ───────────────────────────────────────────────────────────────────
API_PREFIX = "/api/v1"

app.include_router(health.router, prefix=API_PREFIX)
app.include_router(auth.router, prefix=API_PREFIX)
app.include_router(product.router, prefix=API_PREFIX)
app.include_router(analyze.router, prefix=API_PREFIX)
app.include_router(scan.router, prefix=API_PREFIX)
app.include_router(profile.router, prefix=API_PREFIX)
app.include_router(history.router, prefix=API_PREFIX)
app.include_router(report.router)             # /report/{scan_id}/pdf (matches React client)
app.include_router(alternatives.router, prefix=API_PREFIX)
app.include_router(admin.router, prefix=API_PREFIX)


@app.get("/")
def root():
    return {"message": "SafeScan Backend is running 🚀", "docs": "/docs"}
