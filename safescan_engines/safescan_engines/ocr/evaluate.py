import csv
import re
from collections import defaultdict
from collections.abc import Sequence
from pathlib import Path
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field


class BenchmarkRecord(BaseModel):
    model_config = ConfigDict(extra="allow")

    engine: Literal["paddle", "tesseract"]
    preprocessed: bool
    condition: str
    image_filename: str = ""
    ingredients_gt: str | None = None
    mrp_gt: str | None = None
    net_quantity_gt: str | None = None
    dates_gt: str | None = None
    manufacturer_gt: str | None = None
    full_text_gt: str | None = None
    ingredients_pred: str | None = None
    mrp_pred: str | None = None
    net_quantity_pred: str | None = None
    dates_pred: str | None = None
    manufacturer_pred: str | None = None
    full_text_pred: str | None = None


def _normalize(text: str) -> str:
    return re.sub(r"\s+", " ", text.lower()).strip()


def compute_cer(reference: str, hypothesis: str) -> float:
    ref = _normalize(reference)
    hyp = _normalize(hypothesis)
    if not ref and not hyp:
        return 0.0
    if not ref:
        return 1.0

    previous = list(range(len(hyp) + 1))
    for i, ref_char in enumerate(ref, start=1):
        current = [i]
        for j, hyp_char in enumerate(hyp, start=1):
            current.append(
                min(
                    current[-1] + 1,
                    previous[j] + 1,
                    previous[j - 1] + (ref_char != hyp_char),
                )
            )
        previous = current
    return previous[-1] / max(len(ref), 1)


def score_field_match(
    gt_value: str | None,
    pred_value: str | None,
    cer_cutoff: float = 0.25,
) -> bool:
    gt = _normalize(gt_value or "")
    pred = _normalize(pred_value or "")
    if not gt and not pred:
        return True
    if not gt or not pred:
        return False
    if gt in pred or pred in gt:
        return True
    return compute_cer(gt, pred) <= cer_cutoff


def evaluate_benchmark_rows(records: Sequence[BenchmarkRecord]) -> list[dict[str, object]]:
    normalized = [
        BenchmarkRecord.model_validate(record)
        if not isinstance(record, BenchmarkRecord)
        else record
        for record in records
    ]
    grouped: dict[tuple[str, bool, str], list[BenchmarkRecord]] = defaultdict(list)
    overall: dict[tuple[str, bool], list[BenchmarkRecord]] = defaultdict(list)
    for record in normalized:
        grouped[(record.engine, record.preprocessed, record.condition)].append(record)
        overall[(record.engine, record.preprocessed)].append(record)

    rows: list[dict[str, object]] = []
    field_names = ("mrp", "net_quantity", "dates", "ingredients", "manufacturer")

    def metrics(group: Sequence[BenchmarkRecord]) -> dict[str, object]:
        if not group:
            return {}
        cers = [
            compute_cer(record.full_text_gt or "", record.full_text_pred or "")
            for record in group
        ]
        accuracies: dict[str, float] = {}
        for field_name in field_names:
            gt_values = [getattr(record, f"{field_name}_gt") for record in group]
            pred_values = [getattr(record, f"{field_name}_pred") for record in group]
            matches = sum(
                score_field_match(gt, pred)
                for gt, pred in zip(gt_values, pred_values)
            )
            accuracies[field_name] = matches / len(group)
        overall_accuracy = sum(accuracies.values()) / len(field_names)
        return {
            "sample_count": len(group),
            "mean_cer": sum(cers) / len(cers),
            "mrp_acc": accuracies["mrp"],
            "net_qty_acc": accuracies["net_quantity"],
            "dates_acc": accuracies["dates"],
            "ingredients_acc": accuracies["ingredients"],
            "manufacturer_acc": accuracies["manufacturer"],
            "overall_field_acc": overall_accuracy,
        }

    for (engine, preprocessed, condition), group in sorted(
        grouped.items(),
        key=lambda item: (item[0][0], item[0][1], item[0][2]),
    ):
        row: dict[str, object] = {
            "engine": engine,
            "preprocessed": preprocessed,
            "condition": condition,
        }
        row.update(metrics(group))
        rows.append(row)

    for (engine, preprocessed), group in sorted(overall.items()):
        row: dict[str, object] = {
            "engine": engine,
            "preprocessed": preprocessed,
            "condition": "ALL",
        }
        row.update(metrics(group))
        rows.append(row)
    return rows