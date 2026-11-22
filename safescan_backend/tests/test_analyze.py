def test_analyze_requires_auth(client):
    """Analyze endpoint must reject unauthenticated requests."""
    resp = client.post("/api/v1/analyze/", json={"barcode": "1234567890", "category": "food"})
    assert resp.status_code == 403


def test_analyze_with_auth(client):
    # Register & login
    client.post("/api/v1/auth/register", json={
        "name": "Ana Tester", "email": "ana@safescan.com", "password": "password123"
    })
    login = client.post("/api/v1/auth/login", json={
        "email": "ana@safescan.com", "password": "password123"
    })
    token = login.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # Analyze by product_name + ocr_text (no real network needed)
    resp = client.post("/api/v1/analyze/", json={
        "product_name": "Test Chips",
        "category": "food",
        "ocr_text": "MRP: ₹30 Net Wt. 50g Best Before: 12/2026 Mfg. by: Test Foods FSSAI: 10013022000104",
    }, headers=headers)
    assert resp.status_code == 200
    body = resp.json()
    assert body["name"] == "Test Chips"
    assert "score" in body
    assert "legal_metrology" in body
