from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.api.deps import get_db, get_current_user
from app.schemas.analysis import ProductAnalysisResponse
from app.schemas.scan import AnalyzeRequest
from app.services.product_service import get_or_fetch_product
from app.services.analysis_service import analyze_product
from app.models.product import Product
from app.models.user import User

router = APIRouter(prefix="/analyze", tags=["analyze"])


@router.post("/", response_model=ProductAnalysisResponse)
async def analyze(
    payload: AnalyzeRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Full product analysis: health scoring + legal metrology."""
    if payload.barcode:
        product = await get_or_fetch_product(db, payload.barcode, payload.category or "food")
        if not product:
            # Create a placeholder product from provided name
            product = Product(
                barcode=payload.barcode,
                name=payload.product_name or "Unknown Product",
                category=payload.category or "food",
            )
            db.add(product)
            db.commit()
            db.refresh(product)
    elif payload.product_name:
        # No barcode – create inline product from OCR text / name
        product = Product(
            name=payload.product_name,
            category=payload.category or "food",
            ingredients_text=payload.ocr_text,
        )
        db.add(product)
        db.commit()
        db.refresh(product)
    else:
        raise HTTPException(status_code=422, detail="Provide barcode or product_name")

    result = analyze_product(
        db, product,
        ocr_text=payload.ocr_text,
        user_allergies=current_user.allergies,
        user_skin_type=current_user.skin_type,
    )
    return result
