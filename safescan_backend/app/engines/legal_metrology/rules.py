"""
Legal Metrology compliance checker.
Checks OCR text for mandatory fields per India's Legal Metrology
(Packaged Commodities) Rules 2011 & FSSAI regulations.
"""
import re
from typing import List
from app.schemas.analysis import LegalMetrology

MANDATORY_FOOD = ["mrp", "net_quantity", "manufacturer_name", "expiry_date", "fssai"]
MANDATORY_COSMETIC = ["mrp", "net_quantity", "manufacturer_name", "batch_number"]


def _extract_mrp(text: str):
    match = re.search(r"MRP[:\s₹Rs.]*\s*([\d,]+\.?\d*)", text, re.IGNORECASE)
    return f"₹{match.group(1)}" if match else None


def _extract_net_qty(text: str):
    match = re.search(r"Net\s*(?:Wt\.?|Qty\.?|Weight|Content)[:\s]*([\d.]+\s*(?:g|ml|kg|L|oz))", text, re.IGNORECASE)
    return match.group(1) if match else None


def _extract_expiry(text: str):
    match = re.search(
        r"(?:Best Before|Expiry|Exp\.?|Use By)[:\s]*(\d{1,2}[/\-]\d{1,2}[/\-]\d{2,4}|\w{3,9}\s*\d{4})",
        text, re.IGNORECASE
    )
    return match.group(1) if match else None


def _extract_batch(text: str):
    match = re.search(r"(?:Batch|Lot)[:\s#]*([A-Z0-9\-]+)", text, re.IGNORECASE)
    return match.group(1) if match else None


def _extract_fssai(text: str):
    match = re.search(r"FSSAI[:\s#]*(\d{14})", text, re.IGNORECASE)
    return match.group(1) if match else None


def _extract_manufacturer(text: str):
    match = re.search(r"Mfg\.?\s*(?:by|name)?[:\s]+([A-Za-z][\w\s&,.]+?)(?:\n|,)", text, re.IGNORECASE)
    return match.group(1).strip() if match else None


def check_legal_metrology(ocr_text: str, category: str) -> LegalMetrology:
    text = ocr_text or ""
    mrp = _extract_mrp(text)
    net_qty = _extract_net_qty(text)
    expiry = _extract_expiry(text)
    batch = _extract_batch(text)
    fssai = _extract_fssai(text)
    manufacturer = _extract_manufacturer(text)

    present = {
        "mrp": bool(mrp),
        "net_quantity": bool(net_qty),
        "manufacturer_name": bool(manufacturer),
        "expiry_date": bool(expiry),
        "fssai": bool(fssai),
        "batch_number": bool(batch),
    }

    mandatory = MANDATORY_FOOD if category == "food" else MANDATORY_COSMETIC
    missing = [field for field in mandatory if not present.get(field, False)]
    compliant = len(missing) == 0
    compliance_score = round((len(mandatory) - len(missing)) / len(mandatory) * 100, 1)

    return LegalMetrology(
        compliant=compliant,
        mrp=mrp,
        net_quantity=net_qty,
        expiry_date=expiry,
        batch_number=batch,
        fssai_license_number=fssai,
        manufacturer_name=manufacturer,
        missing_fields=missing,
        compliance_score=compliance_score,
        notes=None if compliant else f"Missing: {', '.join(missing)}",
    )
