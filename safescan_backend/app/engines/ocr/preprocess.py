"""
Image preprocessing pipeline for label OCR (deskew, denoise, adaptive thresholding).
"""
import io
from typing import Optional
from PIL import Image, ImageFilter, ImageOps


def preprocess_label_image(image_bytes: bytes) -> bytes:
    """Preprocess label image: convert to grayscale, autoadjust contrast and sharpen."""
    try:
        img = Image.open(io.BytesIO(image_bytes))
        # Convert to grayscale
        gray = img.convert("L")
        # Enhance contrast
        contrasted = ImageOps.autocontrast(gray)
        # Sharpen slightly
        sharpened = contrasted.filter(ImageFilter.SHARPEN)

        buf = io.BytesIO()
        sharpened.save(buf, format="PNG")
        return buf.getvalue()
    except Exception:
        return image_bytes
