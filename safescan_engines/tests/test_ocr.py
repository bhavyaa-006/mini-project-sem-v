from datetime import date

import numpy as np

from safescan_engines.ocr.evaluate import (
    BenchmarkRecord,
    compute_cer,
    evaluate_benchmark_rows,
)
from safescan_engines.ocr.field_extractor import extract_label_fields
from safescan_engines.ocr.preprocess import (
    apply_adaptive_threshold,
    deskew_image,
    to_grayscale,
    upscale_if_small,
)
from safescan_engines.legal_metrology.compliance import evaluate_legal_metrology
from safescan_engines.schemas import ComplianceStatus


def test_preprocessing_synthetic_image():
    image = np.full((300, 100, 3), 220, dtype=np.uint8)
    cv_image = image.copy()
    cv_image[30:270, 20:80] = 30
    gray = to_grayscale(cv_image)
    assert gray.ndim == 2
    upscaled = upscale_if_small(gray, min_height=800)
    assert upscaled.shape[0] >= 800
    deskewed = deskew_image(upscaled)
    assert deskewed.shape == upscaled.shape
    thresholded = apply_adaptive_threshold(deskewed)
    assert thresholded.dtype == np.uint8
    assert set(np.unique(thresholded)).issubset({0, 255})


def test_field_extraction_and_engine_a():
    text = (
        "INGREDIENTS: Sugar, Wheat Flour,\nPalm Oil, INS 211\n"
        "MRP Rs. 50.00 (Incl. of all taxes)\n"
        "Net Wt: 150 g\n"
        "PKD: 09/2026 BEST BEFORE 6 MONTHS\n"
        "Mfd. by: ABC Foods, Bengaluru - 560064\n"
        "Consumer Care: 1800-123-4567"
    )
    fields = extract_label_fields(text)
    assert "Palm Oil" in (fields.ingredients_text or "")
    assert "MRP" in (fields.mrp_text or "")
    assert "150 g" in (fields.net_quantity_text or "")
    assert "09/2026" in (fields.dates_text or "")
    assert "560064" in (fields.manufacturer_text or "")
    result = evaluate_legal_metrology(
        text,
        product_name="Masala Biscuit",
        reference_date=date(2026, 11, 22),
    )
    assert result.overall_status == ComplianceStatus.PASS


def test_cer_and_field_match():
    assert compute_cer("MRP Rs. 50.00", "MRP Rs. 50.00") == 0.0
    assert abs(compute_cer("abcdefghij", "abcdXfghij") - 0.1) < 1e-9


def test_stratified_benchmark_rows():
    conditions = ["flat", "curved", "glare", "small_print"]
    records = []
    for engine in ("paddle", "tesseract"):
        for preprocessed in (False, True):
            for condition in conditions:
                records.append(BenchmarkRecord(
                    engine=engine,
                    preprocessed=preprocessed,
                    condition=condition,
                    full_text_gt="MRP Rs. 50.00",
                    full_text_pred="MRP Rs. 50.00",
                    mrp_gt="50.00",
                    mrp_pred="50.00",
                    net_quantity_gt="150 g",
                    net_quantity_pred="150 g",
                    dates_gt="09/2026",
                    dates_pred="09/2026",
                    ingredients_gt="Sugar",
                    ingredients_pred="Sugar",
                    manufacturer_gt="560064",
                    manufacturer_pred="560064",
                ))
    rows = evaluate_benchmark_rows(records)
    for engine in ("paddle", "tesseract"):
        for preprocessed in (False, True):
            matching = [
                row for row in rows
                if row["engine"] == engine
                and row["preprocessed"] is preprocessed
            ]
            assert any(row["condition"] == "ALL" for row in matching)
            assert {
                row["condition"] for row in matching
            } >= set(conditions)