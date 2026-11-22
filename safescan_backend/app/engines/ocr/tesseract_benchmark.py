"""
Tesseract OCR benchmark comparison against PaddleOCR.
"""
import time
from typing import Dict, Any
from app.services.ocr_service import extract_text_from_image


def benchmark_tesseract(image_bytes: bytes) -> Dict[str, Any]:
    """Run Tesseract extraction with timing."""
    start = time.perf_counter()
    extracted_text = extract_text_from_image(image_bytes) or ""
    duration = time.perf_counter() - start

    return {
        "engine": "tesseract",
        "duration_seconds": round(duration, 4),
        "char_count": len(extracted_text),
        "word_count": len(extracted_text.split()),
        "text": extracted_text,
    }
