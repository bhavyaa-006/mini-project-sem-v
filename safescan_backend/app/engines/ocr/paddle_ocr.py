"""
PaddleOCR integration with graceful fallback if paddleocr is not installed.
"""
from typing import Optional
from app.services.ocr_service import extract_text_from_image

try:
    from paddleocr import PaddleOCR
    _paddle = PaddleOCR(use_angle_cls=True, lang='en', show_log=False)
except ImportError:
    _paddle = None


def extract_with_paddle_ocr(image_bytes: bytes) -> Optional[str]:
    """Run PaddleOCR if available, else fallback to standard OCR service."""
    if _paddle is None:
        return extract_text_from_image(image_bytes)

    try:
        result = _paddle.ocr(image_bytes, cls=True)
        if not result or not result[0]:
            return None
        lines = [line[1][0] for line in result[0] if line and len(line) > 1]
        return "\n".join(lines).strip() or None
    except Exception:
        return extract_text_from_image(image_bytes)
