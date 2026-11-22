"""
Measure OCR text extraction accuracy and CER (Character Error Rate) against ground truth.
Run: python -m scripts.measure_ocr_accuracy
"""
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def calculate_levenshtein(s1: str, s2: str) -> int:
    """Compute basic Levenshtein distance between two strings."""
    if len(s1) < len(s2):
        return calculate_levenshtein(s2, s1)
    if len(s2) == 0:
        return len(s1)

    prev_row = range(len(s2) + 1)
    for i, c1 in enumerate(s1):
        curr_row = [i + 1]
        for j, c2 in enumerate(s2):
            insertions = prev_row[j + 1] + 1
            deletions = curr_row[j] + 1
            substitutions = prev_row[j] + (c1 != c2)
            curr_row.append(min(insertions, deletions, substitutions))
        prev_row = curr_row
    return prev_row[-1]


def evaluate_accuracy(ground_truth: str, predicted: str) -> float:
    dist = calculate_levenshtein(ground_truth.lower().strip(), predicted.lower().strip())
    max_len = max(len(ground_truth), len(predicted), 1)
    return max(0.0, 1.0 - (dist / max_len))


if __name__ == "__main__":
    print("OCR Accuracy Measurement Utility ready.")
