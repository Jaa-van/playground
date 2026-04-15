# Backend Testing Guide

## Test Structure

```
backend/tests/
├── conftest.py          ← shared fixtures (DB session, test client)
├── unit/
│   └── test_user_service.py
└── integration/
    └── test_user_endpoints.py
```

## Shared Fixtures (`tests/conftest.py`)

```python
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.main import app
from app.core.database import Base, get_db

# In-memory SQLite for tests (no file created, fully isolated between tests)
SQLALCHEMY_TEST_URL = "sqlite:///:memory:"

engine = create_engine(SQLALCHEMY_TEST_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

@pytest.fixture(scope="function")
def db():
    Base.metadata.create_all(bind=engine)
    session = TestingSessionLocal()
    try:
        yield session
    finally:
        session.close()
        Base.metadata.drop_all(bind=engine)

@pytest.fixture(scope="function")
def client(db):
    def override_get_db():
        yield db
    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as c:
        yield c
    app.dependency_overrides.clear()
```

## Integration Test Examples

```python
# tests/integration/test_user_endpoints.py

def test_create_user_success(client):
    response = client.post("/api/v1/users", json={
        "email": "test@example.com",
        "password": "password123",
        "name": "John Doe"
    })
    assert response.status_code == 201
    data = response.json()
    assert data["email"] == "test@example.com"
    assert "password" not in data  # password must not appear in response

def test_create_user_duplicate_email(client):
    payload = {"email": "dup@example.com", "password": "pw12345678", "name": "Duplicate"}
    client.post("/api/v1/users", json=payload)

    response = client.post("/api/v1/users", json=payload)
    assert response.status_code == 409

def test_get_user_not_found(client):
    response = client.get("/api/v1/users/99999")
    assert response.status_code == 404
```

## Unit Test Examples

```python
# tests/unit/test_user_service.py
from unittest.mock import MagicMock
from app.services.user_service import UserService
from app.schemas.user import UserCreate
import pytest

def test_create_user_raises_on_duplicate():
    mock_repo = MagicMock()
    mock_repo.find_by_email.return_value = MagicMock()  # user already exists

    service = UserService(repo=mock_repo)

    with pytest.raises(ValueError, match="already exists"):
        service.create_user(UserCreate(
            email="test@example.com",
            password="password123",
            name="John Doe"
        ))
```

## Running Tests

```bash
# run inside Docker
docker compose exec backend pytest

# with coverage
docker compose exec backend pytest --cov=app --cov-report=term-missing

# specific file only
docker compose exec backend pytest tests/integration/test_user_endpoints.py -v

# run locally (after activating venv)
pytest tests/ -v
```

## Coverage Targets

- New code: **80%+**
- Service layer: **90%+** (where business logic is concentrated)
- Repository layer: covered by integration tests

## Test Naming Convention

```
test_<target>_<condition>_<expected_result>

Examples:
test_create_user_success
test_create_user_duplicate_email_raises_409
test_get_user_not_found_returns_404
test_update_user_without_auth_returns_401
```
