# Backend Layer Architecture

## 5-Layer Pattern

The FastAPI project is divided into 5 layers. Each layer only calls the layer directly below it.

```
HTTP request
    ↓
[1] Router (api/v1/endpoints/)   ← HTTP entry point, auth checks
    ↓
[2] Schema (schemas/)            ← input validation, serialization
    ↓
[3] Service (services/)          ← business logic
    ↓
[4] Repository (repositories/)   ← DB queries
    ↓
[5] Model (models/)              ← SQLAlchemy ORM
    ↓
SQLite
```

## Layer Roles and Examples

### [1] Router (`app/api/v1/endpoints/`)

- Defines HTTP methods and paths
- Handles auth/permission checks (Depends)
- Calls Service and returns Schema response
- No business logic

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

- Pydantic BaseModel based
- Request and Response schemas are separate
- Do not map 1:1 to DB model (separate fields that should not be exposed)

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

- Owns all business logic
- Calls Repository
- Manages transactions
- No HTTP concepts from Router layer (no HTTPException — use custom exception classes)

```python
# app/services/user_service.py
from app.repositories.user_repository import UserRepository
from app.schemas.user import UserCreate, UserResponse

class UserService:
    def __init__(self, repo: UserRepository = Depends()):
        self.repo = repo

    async def create_user(self, data: UserCreate) -> UserResponse:
        if await self.repo.find_by_email(data.email):
            raise ValueError("Email already exists")
        user = await self.repo.create(data)
        return UserResponse.model_validate(user)
```

### [4] Repository (`app/repositories/`)

- DB queries only
- Direct use of SQLAlchemy session
- No business logic

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

- SQLAlchemy ORM models
- Table definitions only
- Inherit from `Base`

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

## Layer Violation Prohibitions

| Prohibited | Reason |
|-----------|--------|
| Direct DB query in Router | Not testable, not reusable |
| HTTPException in Service | Service must have no HTTP concepts |
| Business logic in Repository | Violates single responsibility |
| Circular schema imports | Causes Pydantic errors |
