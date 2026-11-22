"""
OCR service – basic label text extraction via Tesseract (fallback to raw text).
PaddleOCR integration is in engines/ocr/paddle_ocr.py.
"""
import io
from typing import Optional

try:
    import pytesseract
    from PIL import Image
    _TESSERACT_AVAILABLE = True
except ImportError:
    _TESSERACT_AVAILABLE = False


def extract_text_from_image(image_bytes: bytes) -> Optional[str]:
    """Extract text from uploaded image bytes using Tesseract OCR."""
    if not _TESSERACT_AVAILABLE:
        return None
    try:
        image = Image.open(io.BytesIO(image_bytes))
        text = pytesseract.image_to_string(image, lang="eng")
        return text.strip() or None
    except Exception:
        return None
