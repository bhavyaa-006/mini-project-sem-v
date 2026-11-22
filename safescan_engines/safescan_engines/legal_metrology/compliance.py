from datetime import date

from safescan_engines.schemas import (
    ClauseCheck,
    ComplianceResult,
    ComplianceStatus,
    ProductDomain,
)
from safescan_engines.legal_metrology.dual_mrp import check_dual_mrp
from safescan_engines.legal_metrology.parsers.expiry_date import parse_dates
from safescan_engines.legal_metrology.parsers.manufacturer_address import (
    parse_manufacturer_and_contact,
)
from safescan_engines.legal_metrology.parsers.mrp import parse_mrp
from safescan_engines.legal_metrology.parsers.net_quantity import parse_net_quantity
from safescan_engines.legal_metrology.rules import LM_RULES


def _check(
    clause_id: str,
    status: ComplianceStatus,
    extracted_value: str | None = None,
    note: str = "",
) -> ClauseCheck:
    rule = LM_RULES[clause_id]
    return ClauseCheck(
        clause_id=clause_id,
        title=rule.title,
        status=status,
        extracted_value=extracted_value,
        note=note,
    )


def evaluate_legal_metrology(
    raw_text: str | None,
    domain: ProductDomain = ProductDomain.FOOD,
    product_name: str | None = None,
    reference_date: date | None = None,
) -> ComplianceResult:
    if not raw_text or not raw_text.strip():
        mandatory_ids = [
            "6(1)(a)", "6(1)(b)", "6(1)(c)", "6(1)(d)",
            "6(1)(da)", "6(1)(e)", "6(2)", "6(3)",
        ]
        checks = [
            _check(clause_id, ComplianceStatus.UNKNOWN)
            for clause_id in mandatory_ids
        ]
        if domain == ProductDomain.COSMETIC:
            checks.append(_check("6(8)", ComplianceStatus.UNKNOWN))
        return ComplianceResult(
            overall_status=ComplianceStatus.UNKNOWN,
            checks=checks,
            dual_mrp_detected=False,
        )

    mrp = parse_mrp(raw_text)
    net_qty = parse_net_quantity(raw_text)
    dates = parse_dates(raw_text, reference_date)
    manufacturer = parse_manufacturer_and_contact(raw_text)
    dual = check_dual_mrp(mrp, raw_text)

    checks: list[ClauseCheck] = []

    if manufacturer.has_entity_declaration:
        status = ComplianceStatus.PASS if manufacturer.has_valid_pin else ComplianceStatus.FAIL
    else:
        status = ComplianceStatus.UNKNOWN
    checks.append(_check(
        "6(1)(a)", status,
        manufacturer.entity_snippet,
        "Valid 6-digit Indian PIN code found." if manufacturer.has_valid_pin
        else "Manufacturer/packer/importer block present without a valid 6-digit PIN."
        if manufacturer.has_entity_declaration else "",
    ))

    imported = bool(
        manufacturer.entity_snippet
        and "imported by" in manufacturer.entity_snippet.lower()
    ) or "country of origin" in raw_text.lower()
    if imported:
        origin_status = ComplianceStatus.PASS if manufacturer.country_of_origin else ComplianceStatus.UNKNOWN
    else:
        origin_status = ComplianceStatus.PASS
    checks.append(_check(
        "6(1)(aa)", origin_status,
        manufacturer.country_of_origin,
        "Country of origin declaration." if manufacturer.country_of_origin
        else ("Imported product; origin declaration is missing." if imported else "Not applicable."),
    ))

    generic_value = product_name.strip() if product_name and product_name.strip() else None
    if generic_value:
        generic_status = ComplianceStatus.PASS
    else:
        generic_status = ComplianceStatus.UNKNOWN
    checks.append(_check("6(1)(b)", generic_status, generic_value))

    if net_qty.found:
        qty_status = ComplianceStatus.PASS if net_qty.is_standard_si else ComplianceStatus.FAIL
        qty_value = net_qty.raw_match
    else:
        qty_status = ComplianceStatus.UNKNOWN
        qty_value = None
    checks.append(_check("6(1)(c)", qty_status, qty_value))

    mfg_status = ComplianceStatus.PASS if dates.mfg_date_raw else ComplianceStatus.UNKNOWN
    checks.append(_check(
        "6(1)(d)", mfg_status,
        dates.mfg_date_raw,
    ))

    if dates.is_expired is True:
        expiry_status = ComplianceStatus.FAIL
    elif dates.expiry_raw or dates.relative_shelf_life_months is not None:
        expiry_status = ComplianceStatus.PASS
    else:
        expiry_status = ComplianceStatus.UNKNOWN
    expiry_value = dates.expiry_raw or (
        f"{dates.relative_shelf_life_months} months"
        if dates.relative_shelf_life_months is not None else None
    )
    checks.append(_check(
        "6(1)(da)", expiry_status, expiry_value,
        "Expiry date is before the reference month." if dates.is_expired else "",
    ))

    if mrp.found:
        mrp_status = ComplianceStatus.PASS if mrp.has_tax_inclusive_text else ComplianceStatus.FAIL
        mrp_value = ", ".join(str(price) for price in mrp.prices)
    else:
        mrp_status = ComplianceStatus.UNKNOWN
        mrp_value = None
    checks.append(_check("6(1)(e)", mrp_status, mrp_value))

    care_value = manufacturer.consumer_care_phone or manufacturer.consumer_care_email
    care_status = ComplianceStatus.PASS if care_value else ComplianceStatus.UNKNOWN
    checks.append(_check("6(2)", care_status, care_value))

    checks.append(_check(
        "6(3)", dual.status,
        ", ".join(str(price) for price in dual.prices_found),
        dual.note,
    ))

    if domain == ProductDomain.COSMETIC:
        veg_match = raw_text.lower()
        if re_search_veg_mark(veg_match):
            veg_status = ComplianceStatus.PASS
            veg_value = "Vegetarian mark"
        else:
            veg_status = ComplianceStatus.UNKNOWN
            veg_value = None
        checks.append(_check("6(8)", veg_status, veg_value))

    if any(check.status == ComplianceStatus.FAIL for check in checks):
        overall = ComplianceStatus.FAIL
    elif all(
        check.status == ComplianceStatus.PASS
        for check in checks
        if check.clause_id in {
            "6(1)(a)", "6(1)(b)", "6(1)(c)", "6(1)(d)",
            "6(1)(da)", "6(1)(e)", "6(2)", "6(3)",
        }
    ):
        overall = ComplianceStatus.PASS
    else:
        overall = ComplianceStatus.UNKNOWN

    return ComplianceResult(
        overall_status=overall,
        checks=checks,
        dual_mrp_detected=dual.dual_mrp_detected,
    )


def re_search_veg_mark(text: str) -> bool:
    import re
    return bool(re.search(r"100%\s*vegetarian|(?:^|\W)veg(?:\W|$)|green\s*(?:dot|circle)", text, re.I))