from datetime import date

from safescan_engines.legal_metrology.compliance import evaluate_legal_metrology
from safescan_engines.legal_metrology.parsers.expiry_date import parse_dates
from safescan_engines.legal_metrology.parsers.mrp import parse_mrp
from safescan_engines.legal_metrology.parsers.net_quantity import parse_net_quantity
from safescan_engines.schemas import ComplianceStatus, ProductDomain


def check(result, clause_id):
    return next(check for check in result.checks if check.clause_id == clause_id)


def test_fully_compliant_indian_food_pack():
    text = (
        "Mfd. by: ABC Foods Pvt. Ltd., Bengaluru - 560064\n"
        "Consumer Care: 1800-123-4567 / care@abcfoods.in\n"
        "Net Wt.: 250 g\n"
        "MFD: 09/2026\n"
        "BEST BEFORE 9 MONTHS FROM MFD\n"
        "MRP Rs. 120.00 (Incl. of all taxes)"
    )
    result = evaluate_legal_metrology(
        text,
        product_name="ABC Masala Oats",
        reference_date=date(2026, 11, 22),
    )
    assert result.overall_status == ComplianceStatus.PASS
    assert not [item for item in result.checks if item.status == ComplianceStatus.FAIL]
    assert check(result, "6(1)(da)").extracted_value is not None


def test_missing_tax_clause_fails():
    result = evaluate_legal_metrology("MRP Rs. 85.00", product_name="Test Snack")
    assert check(result, "6(1)(e)").status == ComplianceStatus.FAIL


def test_non_si_quantity_fails():
    result = evaluate_legal_metrology("Net Wt: 8 oz", product_name="Test Snack")
    parsed = parse_net_quantity("Net Wt: 8 oz")
    assert parsed.found is True
    assert parsed.is_standard_si is False
    assert check(result, "6(1)(c)").status == ComplianceStatus.FAIL


def test_expired_relative_best_before_fails():
    dates = parse_dates(
        "MFD: 01/2025, BEST BEFORE 6 MONTHS",
        reference_date=date(2026, 11, 22),
    )
    assert dates.expiry_year_month == (2025, 7)
    assert dates.is_expired is True

    result = evaluate_legal_metrology(
        "MFD: 01/2025, BEST BEFORE 6 MONTHS",
        product_name="Test Snack",
        reference_date=date(2026, 11, 22),
    )
    assert check(result, "6(1)(da)").status == ComplianceStatus.FAIL


def test_dual_mrp_fails():
    mrp = parse_mrp("MRP ₹150.00 and MRP ₹180.00")
    assert len(mrp.prices) == 2
    result = evaluate_legal_metrology(
        "MRP ₹150.00 and MRP ₹180.00",
        product_name="Test Snack",
    )
    assert result.dual_mrp_detected is True
    assert check(result, "6(3)").status == ComplianceStatus.FAIL


def test_blurry_text_returns_unknown():
    result = evaluate_legal_metrology(
        "Crunchy Masala Oats, Batch A12",
    )
    assert result.overall_status == ComplianceStatus.UNKNOWN
    assert all(
        item.status != ComplianceStatus.FAIL
        for item in result.checks
    )


def test_cosmetic_veg_mark_is_optional_when_not_detected():
    result = evaluate_legal_metrology(
        (
            "Mfd. by: Beauty Labs Pvt. Ltd., Bengaluru - 560001\n"
            "Net Quantity: 100 ml\n"
            "MFD: 08/2026\n"
            "BEST BEFORE 12 MONTHS\n"
            "MRP: Rs. 250.00 (Incl. of all taxes)\n"
            "Consumer Care: care@beauty.in"
        ),
        domain=ProductDomain.COSMETIC,
        product_name="Face Cream",
    )
    assert check(result, "6(8)").status == ComplianceStatus.UNKNOWN
    assert result.overall_status == ComplianceStatus.PASS


def test_ddmmyyyy_expiry_and_packed_on():
    dates = parse_dates(
        "PACKED ON 15/08/2026, EXP: 25/08/2027",
        reference_date=date(2026, 11, 22),
    )
    assert dates.mfg_year_month == (2026, 8)
    assert dates.expiry_year_month == (2027, 8)
    assert dates.is_expired is False