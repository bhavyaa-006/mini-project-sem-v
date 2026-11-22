from app.engines.legal_metrology.rules import check_legal_metrology


def test_compliant_food_label():
    text = """
    MRP: ₹120
    Net Wt. 500g
    Best Before: 12/2026
    Mfg. by: Amul Dairy, Anand
    FSSAI: 10013022000104
    """
    result = check_legal_metrology(text, "food")
    assert result.mrp == "₹120"
    assert result.net_quantity == "500g"
    assert result.expiry_date is not None
    assert result.fssai_license_number == "10013022000104"


def test_missing_fields_detected():
    text = "Just some random text with no label info."
    result = check_legal_metrology(text, "food")
    assert not result.compliant
    assert len(result.missing_fields) > 0
