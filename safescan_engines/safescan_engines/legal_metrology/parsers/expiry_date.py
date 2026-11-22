import re
from datetime import date

from pydantic import BaseModel


MONTHS = {
    "JAN": 1, "FEB": 2, "MAR": 3, "APR": 4, "MAY": 5, "JUN": 6,
    "JUL": 7, "JULY": 7, "AUG": 8, "SEP": 9, "SEPT": 9,
    "OCT": 10, "NOV": 11, "DEC": 12,
}


class ExpiryDateParseResult(BaseModel):
    mfg_date_raw: str | None
    mfg_year_month: tuple[int, int] | None
    expiry_raw: str | None
    expiry_year_month: tuple[int, int] | None
    relative_shelf_life_months: int | None
    is_expired: bool | None


def _parse_date_token(token: str) -> tuple[int, int] | None:
    token = token.strip()
    month_name = re.search(
        r"(JAN(?:UARY)?|FEB(?:RUARY)?|MAR(?:CH)?|APR(?:IL)?|MAY|"
        r"JUN(?:E)?|JUL(?:Y)?|AUG(?:UST)?|SEP(?:T(?:EMBER)?)?|"
        r"OCT(?:OBER)?|NOV(?:EMBER)?|DEC(?:EMBER)?)",
        token,
        re.I,
    )
    year_match = re.search(r"(20\d{2}|19\d{2}|^(\d{2})$)", token)
    if month_name:
        month = MONTHS.get(month_name.group(1).upper()[:3])
        year_match = re.search(r"(20\d{2}|19\d{2}|\d{2})", token)
        if month is not None and year_match:
            year = int(year_match.group(1))
            if year < 100:
                year += 2000
            return year, month

    parts = re.split(r"[\/\-]", token)
    if len(parts) == 2:
        month_value = int(parts[0]) if parts[0].isdigit() else 0
        year_value = int(parts[1]) if parts[1].isdigit() else 0
        if month_value < 1 or month_value > 12:
            return None
        if year_value < 100:
            year_value += 2000
        return (year_value, month_value) if year_value >= 1900 else None

    if len(parts) == 3:
        day_value = int(parts[0]) if parts[0].isdigit() else 0
        month_value = int(parts[1]) if parts[1].isdigit() else 0
        year_value = int(parts[2]) if parts[2].isdigit() else 0
        if day_value < 1 or day_value > 31:
            return None
        if month_value < 1 or month_value > 12:
            return None
        if year_value < 100:
            year_value += 2000
        return (year_value, month_value) if year_value >= 1900 else None
    return None


def _add_months(year_month: tuple[int, int], months: int) -> tuple[int, int]:
    year, month = year_month
    absolute = year * 12 + month - 1 + months
    return absolute // 12, absolute % 12 + 1


def parse_dates(text: str | None, reference_date: date | None = None) -> ExpiryDateParseResult:
    if not text or not text.strip():
        return ExpiryDateParseResult(
            mfg_date_raw=None, mfg_year_month=None, expiry_raw=None,
            expiry_year_month=None, relative_shelf_life_months=None,
            is_expired=None,
        )

    normalized = re.sub(r"[ \t]+", " ", text)
    mfg_match = re.search(
        r"(?:MFD?\.?(?:\s+ON)?|MFG\.?(?:\s+ON)?|PKD\.?|PACKED(?:\s+ON)?|"
        r"DATE\s+OF\s+(?:MANUFACTURE|PACK(?:ING)?))"
        r"\s*[:\-]?\s*"
        r"((?:\d{1,2}[\/\-]\d{4})|(?:\d{1,2}[\/\-]\d{1,2}[\/\-]\d{4})"
        r"|(?:[A-Z]{3,9}[\s\-]+\d{2,4}))",
        normalized,
        re.I,
    )
    mfg_raw = mfg_match.group(1).strip() if mfg_match else None
    mfg_year_month = _parse_date_token(mfg_raw) if mfg_raw else None

    expiry_match = re.search(
        r"(?:EXP(?:IRY)?|BEST\s*BEFORE|USE\s*BY)"
        r"\s*[:\-]?\s*"
        r"((?:\d{1,2}[\/\-]\d{4})|(?:\d{1,2}[\/\-]\d{1,2}[\/\-]\d{4})"
        r"|(?:[A-Z]{3,9}[\s\-]+\d{2,4})"
        r"|(?:\d+\s*(?:MONTHS?|YEARS?)[^,\n]*))",
        normalized,
        re.I,
    )
    expiry_raw = expiry_match.group(1).strip() if expiry_match else None
    relative_months = None
    expiry_year_month = None
    if expiry_raw:
        duration = re.search(r"(\d+)\s*(MONTHS?|YEARS?)", expiry_raw, re.I)
        if duration:
            amount = int(duration.group(1))
            if duration.group(2).lower().startswith("year"):
                amount *= 12
            relative_months = amount
            if mfg_year_month:
                expiry_year_month = _add_months(mfg_year_month, amount)
        else:
            expiry_year_month = _parse_date_token(expiry_raw)

    reference = reference_date or date.today()
    is_expired = None
    if expiry_year_month is not None:
        is_expired = (reference.year, reference.month) > expiry_year_month

    return ExpiryDateParseResult(
        mfg_date_raw=mfg_raw,
        mfg_year_month=mfg_year_month,
        expiry_raw=expiry_raw,
        expiry_year_month=expiry_year_month,
        relative_shelf_life_months=relative_months,
        is_expired=is_expired,
    )