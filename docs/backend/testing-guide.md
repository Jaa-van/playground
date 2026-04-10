# Backend 테스트 가이드

## 테스트 구조

```
backend/tests/
├── conftest.py          ← 공통 픽스처 (DB 세션, 테스트 클라이언트)
├── unit/
│   └── test_user_service.py
└── integration/
    └── test_user_endpoints.py
```

## 공통 픽스처 (`tests/conftest.py`)

```python
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.main import app
from app.core.database import Base, get_db

# 테스트용 인메모리 SQLite DB
SQLALCHEMY_TEST_URL = "sqlite:///./test.db"

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

## 통합 테스트 예시

```python
# tests/integration/test_user_endpoints.py

def test_create_user_success(client):
    response = client.post("/api/v1/users", json={
        "email": "test@example.com",
        "password": "password123",
        "name": "홍길동"
    })
    assert response.status_code == 201
    data = response.json()
    assert data["email"] == "test@example.com"
    assert "password" not in data  # 비밀번호 응답에 포함 금지

def test_create_user_duplicate_email(client):
    payload = {"email": "dup@example.com", "password": "pw12345678", "name": "중복"}
    client.post("/api/v1/users", json=payload)

    response = client.post("/api/v1/users", json=payload)
    assert response.status_code == 409

def test_get_user_not_found(client):
    response = client.get("/api/v1/users/99999")
    assert response.status_code == 404
```

## 단위 테스트 예시

```python
# tests/unit/test_user_service.py
from unittest.mock import MagicMock
from app.services.user_service import UserService
from app.schemas.user import UserCreate
import pytest

def test_create_user_raises_on_duplicate():
    mock_repo = MagicMock()
    mock_repo.find_by_email.return_value = MagicMock()  # 이미 존재하는 사용자

    service = UserService(repo=mock_repo)

    with pytest.raises(ValueError, match="이미 존재하는"):
        service.create_user(UserCreate(
            email="test@example.com",
            password="password123",
            name="홍길동"
        ))
```

## 테스트 실행

```bash
# Docker 내부에서 실행
docker compose exec backend pytest

# 커버리지 포함
docker compose exec backend pytest --cov=app --cov-report=term-missing

# 특정 파일만
docker compose exec backend pytest tests/integration/test_user_endpoints.py -v

# 로컬에서 직접 (venv 활성화 후)
pytest tests/ -v
```

## 커버리지 목표

- 신규 작성 코드: **80% 이상**
- Service 계층: **90% 이상** (비즈니스 로직이 집중된 곳)
- Repository 계층: 통합 테스트로 커버

## 테스트 명명 규칙

```
test_<대상>_<상황>_<기대결과>

예시:
test_create_user_success
test_create_user_duplicate_email_raises_409
test_get_user_not_found_returns_404
test_update_user_without_auth_returns_401
```
