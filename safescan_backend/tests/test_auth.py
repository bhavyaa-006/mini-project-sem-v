def test_register_and_login(client):
    # Register
    resp = client.post("/api/v1/auth/register", json={
        "name": "Test User", "email": "test@safescan.com", "password": "password123"
    })
    assert resp.status_code == 201
    data = resp.json()
    assert "access_token" in data

    # Login
    resp2 = client.post("/api/v1/auth/login", json={
        "email": "test@safescan.com", "password": "password123"
    })
    assert resp2.status_code == 200
    assert "access_token" in resp2.json()

    # Wrong password
    resp3 = client.post("/api/v1/auth/login", json={
        "email": "test@safescan.com", "password": "wrongpassword"
    })
    assert resp3.status_code == 401
