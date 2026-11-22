from app.engines.health.nutri_score import compute_nutri_score
from app.models.product import Product


def _make_product(nutri_score=""):
    p = Product()
    p.nutri_score = nutri_score
    p.category = "food"
    return p


def test_good_nutri_score():
    score, grade = compute_nutri_score(_make_product("A"), [])
    assert score >= 100  # capped at 100 after +10 bonus from A
    assert grade == "A"


def test_high_hazard_deduction():
    class FakeFlag:
        hazard_level = "high"
    score, _ = compute_nutri_score(_make_product(""), [FakeFlag(), FakeFlag()])
    assert score <= 70  # 2 × 15 = 30 deducted from 100
