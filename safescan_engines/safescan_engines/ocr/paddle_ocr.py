from functools import lru_cache

import numpy as np

from safescan_engines.ocr import OcrDocumentResult, OcrLine

try:
    import cv2
except ImportError as exc:
    raise ImportError(
        "OpenCV is required for PaddleOCR. Install with pip install -e '.[ocr]'"
    ) from exc


@lru_cache(maxsize=1)
def _get_paddle():
    try:
        from paddleocr import PaddleOCR
    except ImportError as exc:
        raise ImportError(
            "PaddleOCR is required. Install with pip install -e '.[ocr]'"
        ) from exc
    return PaddleOCR(use_angle_cls=True, lang="en", show_log=False)


def run_paddle_ocr(
    image: np.ndarray,
    preprocessed: bool = False,
) -> OcrDocumentResult:
    paddle = _get_paddle()
    if image.ndim == 2:
        image = cv2.cvtColor(image, cv2.COLOR_GRAY2BGR)
    result = paddle.ocr(image, cls=True)

    entries: list[tuple[tuple[float, float], tuple[float, float], str, float]] = []
    for page in result or []:
        for entry in page:
            bbox, payload = entry
            text, confidence = payload
            xs = [float(point[0]) for point in bbox]
            ys = [float(point[1]) for point in bbox]
            top_left = (min(xs), min(ys))
            bottom_right = (max(xs), max(ys))
            entries.append((top_left, bottom_right, str(text).strip(), float(confidence)))

    sorted_entries = sorted(entries, key=lambda item: (round(item[0][1] / 12), item[0][0]))
    lines = [
        OcrLine(
            text=text,
            confidence=max(0.0, min(1.0, confidence)),
            bbox=[
                (top_left),
                (bottom_right[0], top_left[1]),
                (bottom_right),
                (top_left[0], bottom_right[1]),
            ],
        )
        for top_left, bottom_right, text, confidence in sorted_entries
        if text
    ]
    confidences = [line.confidence for line in lines]
    mean = sum(confidences) / len(confidences) if confidences else 0.0
    return OcrDocumentResult(
        engine="paddle",
        preprocessed=preprocessed,
        full_text="\n".join(line.text for line in lines),
        lines=lines,
        mean_confidence=max(0.0, min(1.0, mean)),
    )