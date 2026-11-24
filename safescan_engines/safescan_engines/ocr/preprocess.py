from pathlib import Path

import numpy as np

try:
    import cv2
except ImportError as exc:
    raise ImportError(
        "OpenCV is required for OCR preprocessing. Install with pip install -e '.[ocr]'"
    ) from exc


def load_image(image_source: Path | str | np.ndarray) -> np.ndarray:
    if isinstance(image_source, np.ndarray):
        if image_source.size == 0:
            raise FileNotFoundError("The image array is empty.")
        return image_source
    path = Path(image_source)
    image = cv2.imread(str(path), cv2.IMREAD_UNCHANGED)
    if image is None:
        raise FileNotFoundError(f"Could not load image: {path}")
    return image


def to_grayscale(img: np.ndarray) -> np.ndarray:
    if img.ndim == 2:
        gray = img
    elif img.shape[2] == 4:
        gray = cv2.cvtColor(img, cv2.COLOR_BGRA2GRAY)
    else:
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    return np.ascontiguousarray(gray, dtype=np.uint8)


def upscale_if_small(gray: np.ndarray, min_height: int = 800) -> np.ndarray:
    height = gray.shape[0]
    if height >= min_height:
        return gray
    scale = min_height / float(height)
    width = max(1, int(round(gray.shape[1] * scale)))
    return cv2.resize(gray, (width, min_height), interpolation=cv2.INTER_CUBIC)


def denoise_image(gray: np.ndarray) -> np.ndarray:
    return cv2.fastNlMeansDenoising(
        gray,
        h=10,
        templateWindowSize=7,
        searchWindowSize=21,
    )


def deskew_image(gray: np.ndarray, max_angle_deg: float = 15.0) -> np.ndarray:
    threshold = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY_INV + cv2.THRESH_OTSU)[1]
    coordinates = cv2.findNonZero(threshold)
    angle = 0.0
    if coordinates is not None:
        rect = cv2.minAreaRect(coordinates)
        candidate = rect[-1]
        if rect[1][0] < rect[1][1]:
            candidate = candidate + 90.0
        if candidate > 90:
            candidate -= 180
        angle = max(-max_angle_deg, min(max_angle_deg, float(candidate)))
    if abs(angle) < 0.1:
        return gray
    center = (gray.shape[1] / 2.0, gray.shape[0] / 2.0)
    matrix = cv2.getRotationMatrix2D(center, angle, 1.0)
    return cv2.warpAffine(
        gray,
        matrix,
        (gray.shape[1], gray.shape[0]),
        flags=cv2.INTER_CUBIC,
        borderMode=cv2.BORDER_REPLICATE,
    )


def apply_adaptive_threshold(gray: np.ndarray) -> np.ndarray:
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
    enhanced = clahe.apply(gray)
    return cv2.adaptiveThreshold(
        enhanced,
        255,
        cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
        cv2.THRESH_BINARY,
        blockSize=31,
        C=11,
    ).astype(np.uint8)


def preprocess_label_image(
    image_source: Path | str | np.ndarray,
    binarize: bool = True,
) -> np.ndarray:
    gray = to_grayscale(load_image(image_source))
    gray = upscale_if_small(gray)
    gray = denoise_image(gray)
    gray = deskew_image(gray)
    if binarize:
        return apply_adaptive_threshold(gray)
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
    return clahe.apply(gray).astype(np.uint8)