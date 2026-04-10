# Backend 계층 구조

## 5계층 패턴

FastAPI 프로젝트는 다음 5개 계층으로 나뉩니다. 각 계층은 바로 아래 계층만 호출합니다.

```
HTTP 요청
    ↓
[1] Router (api/v1/endpoints/)   ← HTTP 진입점, 인증 확인
    ↓
[2] Schema (schemas/)            ← 입력 검증, 직렬화
    ↓
[3] Service (services/)          ← 비즈니스 로직
    ↓
[4] Repository (repositories/)   ← DB 쿼리
    ↓
[5] Model (models/)              ← SQLAlchemy ORM
    ↓
PostgreSQL
```

## 각 계층 역할과 예시

### [1] Router (`app/api/v1/endpoints/`)

- HTTP 메서드, 경로 정의
- 인증/권한 확인 (Depends)
- Service 호출 후 Schema로 응답 반환
- 비즈니스 로직 없음

```python
# app/api/v1/endpoints/users.py
from fastapi import APIRouter, Depends, HTTPException
from app.schemas.user import UserCreate, UserResponse
from app.services.user_service import UserService

router = APIRouter()

@router.post("", response_model=UserResponse, status_code=201)
async def create_user(
    body: UserCreate,
    service: UserService = Depends(),
) -> UserResponse:
    return await service.create_user(body)
```

### [2] Schema (`app/schemas/`)

- Pydantic BaseModel 기반
- Request와 Response 스키마 분리
- DB 모델과 1:1 매핑 금지 (노출하면 안 되는 필드 분리)

```python
# app/schemas/user.py
from pydantic import BaseModel, EmailStr

class UserCreate(BaseModel):
    email: EmailStr
    password: str
    name: str

class UserResponse(BaseModel):
    id: int
    email: str
    name: str

    model_config = {"from_attributes": True}
```

### [3] Service (`app/services/`)

- 비즈니스 로직 전담
- Repository 호출
- 트랜잭션 관리
- Router 계층의 HTTP 개념 없음 (HTTPException 사용 금지 → 전용 예외 클래스 사용)

```python
# app/services/user_service.py
from app.repositories.user_repository import UserRepository
from app.schemas.user import UserCreate, UserResponse

class UserService:
    def __init__(self, repo: UserRepository = Depends()):
        self.repo = repo

    async def create_user(self, data: UserCreate) -> UserResponse:
        if await self.repo.find_by_email(data.email):
            raise ValueError("이미 존재하는 이메일입니다")
        user = await self.repo.create(data)
        return UserResponse.model_validate(user)
```

### [4] Repository (`app/repositories/`)

- DB 쿼리만 담당
- SQLAlchemy 세션 직접 사용
- 비즈니스 로직 없음

```python
# app/repositories/user_repository.py
from sqlalchemy.orm import Session
from app.models.user import User
from app.schemas.user import UserCreate

class UserRepository:
    def __init__(self, db: Session = Depends(get_db)):
        self.db = db

    def find_by_email(self, email: str) -> User | None:
        return self.db.query(User).filter(User.email == email).first()

    def create(self, data: UserCreate) -> User:
        user = User(email=data.email, name=data.name)
        self.db.add(user)
        self.db.commit()
        self.db.refresh(user)
        return user
```

### [5] Model (`app/models/`)

- SQLAlchemy ORM 모델
- 테이블 정의만
- `Base`를 상속

```python
# app/models/user.py
from sqlalchemy import Column, Integer, String, DateTime, func
from app.core.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    name = Column(String, nullable=False)
    created_at = Column(DateTime, server_default=func.now())
```

## 계층 위반 금지 사항

| 금지 | 이유 |
|------|------|
| Router에서 직접 DB 쿼리 | 테스트 불가, 재사용 불가 |
| Service에서 HTTPException | Service는 HTTP 개념 없어야 함 |
| Repository에 비즈니스 로직 | 단일 책임 원칙 위반 |
| Schema에서 다른 Schema import 순환 참조 | Pydantic 오류 발생 |
