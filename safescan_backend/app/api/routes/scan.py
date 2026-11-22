import os
import uuid
from fastapi import APIRouter, Depends, UploadFile, File, HTTPException
from sqlalchemy.orm import Session

from app.api.deps import get_db, get_current_user
from app.schemas.analysis import ProductAnalysisResponse
from app.models.scan import Scan
from app.models.product import Product
from app.models.user import User
from app.services.ocr_service import extract_text_from_image
from app.services.analysis_service import analyze_product
from app.engines.legal_metrology.rules import check_legal_metrology

router = APIRouter(prefix="/scan", tags=["scan"])

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)


@router.post("/upload", response_model=ProductAnalysisResponse)
async def scan_label(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Accept a product label image, run OCR, then full analysis."""
    image_bytes = await file.read()

    # Save image
    ext = os.path.splitext(file.filename or "label.jpg")[1] or ".jpg"
    filename = f"{uuid.uuid4().hex}{ext}"
    image_path = os.path.join(UPLOAD_DIR, filename)
    with open(image_path, "wb") as f:
        f.write(image_bytes)

    # OCR
    ocr_text = extract_text_from_image(image_bytes) or ""

    # Create a temporary product entry for OCR scan
    product = Product(
        name="Scanned Product",
        category="food",
        ingredients_text=ocr_text,
    )
    db.add(product)
    db.commit()
    db.refresh(product)

    # Save scan record
    scan = Scan(
        user_id=current_user.id,
        product_id=product.id,
        image_path=image_path,
    )
    db.add(scan)
    db.commit()

    return analyze_product(
        db, product,
        ocr_text=ocr_text,
        user_allergies=current_user.allergies,
        user_skin_type=current_user.skin_type,
    )
