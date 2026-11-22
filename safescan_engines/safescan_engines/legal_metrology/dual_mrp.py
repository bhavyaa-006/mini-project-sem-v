import re

from pydantic import BaseModel

from safescan_engines.schemas import ComplianceStatus
from safescan_engines.legal_metrology.parsers.mrp import MrpParseResult


class DualMrpResult(BaseModel):
    dual_mrp_detected: bool
    prices_found: list[float]
    status: ComplianceStatus
    note: str


def check_dual_mrp(
    mrp_result: MrpParseResult,
    raw_text: str | None = None,
) -> DualMrpResult:
    unique = list(dict.fromkeys(mrp_result.prices))
    if len(unique) <= 1:
        status = ComplianceStatus.PASS if unique else ComplianceStatus.UNKNOWN
        return DualMrpResult(
            dual_mrp_detected=False,
            prices_found=unique,
            status=status,
            note="Rule 6(3) / Rule 18: no conflicting MRP declarations found.",
        )

    revised = bool(
        raw_text
        and re.search(r"revised\s+mrp|offer\s+price", raw_text, re.I)
        and min(unique) < max(unique)
    )
    note = (
        "Rule 6(3) / Rule 18: multiple MRP values require user review"
        + ("; revised/offer pricing wording is present." if revised else "; conflicting values found.")
    )
    return DualMrpResult(
        dual_mrp_detected=True,
        prices_found=unique,
        status=ComplianceStatus.FAIL,
        note=note,
    )