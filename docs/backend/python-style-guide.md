# Python 스타일 가이드 (Java 개발자용)

Java 백엔드 개발자가 자주 하는 Python 실수와 올바른 패턴을 정리합니다.

## 타입 힌트 (Java 타입 시스템 대응)

Java와 달리 Python은 런타임에 타입을 강제하지 않습니다. 하지만 타입 힌트를 반드시 작성합니다.

```python
# Java: private String name;
# Python:
name: str = "홍길동"

# Java: List<String>
from typing import List
names: list[str] = []         # Python 3.9+
names: List[str] = []         # Python 3.8 이하

# Java: Optional<String>
from typing import Optional
name: Optional[str] = None    # None이 될 수 있는 값
name: str | None = None       # Python 3.10+ 문법

# Java: Map<String, Integer>
scores: dict[str, int] = {}

# 함수 시그니처
def get_user(user_id: int) -> UserResponse | None:
    ...
```

## 클래스 vs 함수

Java는 모든 것이 클래스. Python은 함수가 일급 시민.

```python
# Java 습관: 불필요한 클래스 래핑
class UserUtils:
    @staticmethod
    def format_name(first: str, last: str) -> str:
        return f"{last} {first}"

# Python 방식: 그냥 함수
def format_name(first: str, last: str) -> str:
    return f"{last} {first}"
```

FastAPI의 Service, Repository 계층은 클래스로 작성하되, 유틸리티성 함수는 클래스 불필요.

## async/await

FastAPI는 비동기를 지원합니다. DB 작업은 동기/비동기 중 하나로 통일.

```python
# 이 프로젝트는 SQLAlchemy 동기 세션 사용
# async def 필요 없음 (선택 사항)

# 동기 방식 (이 프로젝트 기본)
def create_user(self, data: UserCreate) -> User:
    user = User(**data.model_dump())
    self.db.add(user)
    self.db.commit()
    return user

# 비동기가 필요한 경우 (외부 API 호출 등)
import httpx

async def call_external_api(url: str) -> dict:
    async with httpx.AsyncClient() as client:
        response = await client.get(url)
        return response.json()
```

## Pydantic (Java의 DTO/Bean 대응)

```python
# Java: 
# public class UserCreateDto {
#     @NotNull private String email;
#     @Size(min=8) private String password;
#     private String name;
# }

# Python (Pydantic):
from pydantic import BaseModel, EmailStr, field_validator

class UserCreate(BaseModel):
    email: EmailStr            # 이메일 형식 자동 검증
    password: str
    name: str

    @field_validator("password")
    @classmethod
    def password_length(cls, v: str) -> str:
        if len(v) < 8:
            raise ValueError("비밀번호는 8자 이상이어야 합니다")
        return v
```

## 예외 처리

```python
# Java 습관: checked exception
# try { ... } catch (UserNotFoundException e) { ... }

# Python 방식: 필요한 곳에서만
class UserNotFoundError(Exception):
    def __init__(self, user_id: int):
        super().__init__(f"사용자 {user_id}를 찾을 수 없습니다")

# Service에서 발생
def get_user(self, user_id: int) -> User:
    user = self.repo.find_by_id(user_id)
    if user is None:
        raise UserNotFoundError(user_id)
    return user

# Router에서 HTTP 예외로 변환
from fastapi import HTTPException

@router.get("/{user_id}")
def get_user(user_id: int, service: UserService = Depends()):
    try:
        return service.get_user(user_id)
    except UserNotFoundError as e:
        raise HTTPException(status_code=404, detail=str(e))
```

## 리스트 컴프리헨션 (Java Stream 대응)

```python
# Java: users.stream().map(User::getName).collect(Collectors.toList())
# Python:
names = [user.name for user in users]

# Java: users.stream().filter(u -> u.isActive()).collect(...)
# Python:
active_users = [u for u in users if u.is_active]

# Java: users.stream().map(...).filter(...).collect(...)
# Python:
active_names = [u.name for u in users if u.is_active]
```

## 환경변수 / 설정

```python
# Java 습관: application.properties 하드코딩
# Python 방식: pydantic-settings
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    database_url: str          # .env에서 DATABASE_URL로 읽음
    secret_key: str
    debug: bool = False        # 기본값 있으면 없어도 됨

    model_config = {"env_file": ".env"}  # .env 파일 자동 로드

settings = Settings()
```

## 언더스코어 컨벤션

```python
# public → 그냥 작성
def get_user(self): ...

# private → 언더스코어 하나 (관례, 강제 아님)
def _validate_password(self): ...

# 절대 외부에서 쓰지 말 것 → 언더스코어 둘 (name mangling)
def __internal_only(self): ...

# 파이썬 예약어와 충돌 방지
type_ = "admin"   # type은 Python 예약어
```

## f-string (Java String.format 대응)

```python
# Java: String.format("Hello, %s! You are %d years old.", name, age)
# Python:
message = f"Hello, {name}! You are {age} years old."

# 연산도 가능
message = f"Total: {price * quantity:.2f}원"
```
