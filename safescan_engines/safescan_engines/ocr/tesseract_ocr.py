import numpy as np

from safescan_engines.ocr import OcrDocumentResult, OcrLine

try:
    import pytesseract
except ImportError as exc:
    raise ImportError(
        "pytesseract is required for Tesseract OCR. Install with pip install -e '.[ocr]'"
    ) from exc


def run_tesseract_ocr(
    image: np.ndarray,
    preprocessed: bool = False,
    psm: int = 6,
) -> OcrDocumentResult:
    data = pytesseract.image_to_data(
        image,
        config=f"--oem 3 --psm {psm}",
        output_type=pytesseract.Output.DICT,
    )
    groups: dict[tuple[int, int, int], list[dict[str, object]]] = {}
    count = len(data.get("text", []))
    for index in range(count):
        text = str(data["text"][index]).strip()
        try:
            conf = float(data["conf"][index])
        except (TypeError, ValueError):
            conf = -1.0
        if not text or conf < 0:
            continue
        key = (
            int(data["block_num"][index]),
            int(data["par_num"][index]),
            int(data["line_num"][index]),
        )
        groups.setdefault(key, []).append({
            "text": text,
            "conf": conf,
            "left": int(data["left"][index]),
            "top": int(data["top"][index]),
            "width": int(data["width"][index]),
            "height": int(data["height"][index]),
        })

    lines: list[OcrLine] = []
    for key in sorted(groups):
        words = sorted(groups[key], key=lambda word: word["left"])
        text = " ".join(str(word["text"]) for word in words)
        left = min(int(word["left"]) for word in words)
        top = min(int(word["top"]) for word in words)
        right = max(int(word["left"]) + int(word["width"]) for word in words)
        bottom = max(int(word["top"]) + int(word["height"]) for word in words)
        confidence = sum(float(word["conf"]) for word in words) / len(words) / 100.0
        lines.append(OcrLine(
            text=text,
            confidence=max(0.0, min(1.0, confidence)),
            bbox=[
                (float(left), float(top)),
                (float(right), float(top)),
                (float(right), float(bottom)),
                (float(left), float(bottom)),
            ],
        ))
    mean = sum(line.confidence for line in lines) / len(lines) if lines else 0.0
    return OcrDocumentResult(
        engine="tesseract",
        preprocessed=preprocessed,
        full_text="\n".join(line.text for line in lines),
        lines=lines,
        mean_confidence=max(0.0, min(1.0, mean)),
    )