import csv
from pathlib import Path

from safescan_engines.config import settings
from safescan_engines.ocr.evaluate import BenchmarkRecord, evaluate_benchmark_rows
from safescan_engines.ocr.field_extractor import extract_label_fields
from safescan_engines.ocr.paddle_ocr import run_paddle_ocr
from safescan_engines.ocr.preprocess import preprocess_label_image
from safescan_engines.ocr.tesseract_ocr import run_tesseract_ocr


def main() -> None:
    ground_truth_path = settings.DATA_DIR / "ocr_test" / "ground_truth.csv"
    image_dir = settings.DATA_DIR / "ocr_test" / "images"
    report_path = settings.REPORTS_DIR / "ocr_accuracy.csv"

    records: list[BenchmarkRecord] = []
    if ground_truth_path.exists():
        with ground_truth_path.open("r", encoding="utf-8-sig", newline="") as handle:
            rows = list(csv.DictReader(handle))
    else:
        rows = []

    for row in rows:
        image_name = (row.get("image_filename") or "").strip()
        if not image_name:
            continue
        image_path = image_dir / image_name
        if not image_path.exists():
            continue
        condition = row.get("condition") or "flat"

        for engine in ("paddle", "tesseract"):
            for preprocessed in (False, True):
                image = preprocess_label_image(image_path, binarize=preprocessed)
                if engine == "paddle":
                    result = run_paddle_ocr(image, preprocessed=preprocessed)
                else:
                    result = run_tesseract_ocr(image, preprocessed=preprocessed)
                fields = extract_label_fields(result)
                records.append(BenchmarkRecord(
                    engine=engine,
                    preprocessed=preprocessed,
                    condition=condition,
                    image_filename=image_name,
                    ingredients_gt=row.get("ingredients_gt"),
                    mrp_gt=row.get("mrp_gt"),
                    net_quantity_gt=row.get("net_quantity_gt"),
                    dates_gt=row.get("dates_gt"),
                    manufacturer_gt=row.get("manufacturer_gt"),
                    full_text_gt=row.get("full_text_gt"),
                    ingredients_pred=fields.ingredients_text,
                    mrp_pred=fields.mrp_text,
                    net_quantity_pred=fields.net_quantity_text,
                    dates_pred=fields.dates_text,
                    manufacturer_pred=fields.manufacturer_text,
                    full_text_pred=result.full_text,
                ))

    report_path.parent.mkdir(parents=True, exist_ok=True)
    metrics = evaluate_benchmark_rows(records)
    fieldnames = [
        "engine", "preprocessed", "condition", "sample_count",
        "mean_cer", "mrp_acc", "net_qty_acc", "dates_acc",
        "ingredients_acc", "manufacturer_acc", "overall_field_acc",
    ]
    with report_path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(metrics)
    print(report_path)


if __name__ == "__main__":
    main()