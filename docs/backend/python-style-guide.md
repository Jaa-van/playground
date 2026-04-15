# Python Style Guide (for Java Developers)

Common Python mistakes made by Java backend developers, and the correct patterns.

## Type Hints (mapping to Java's type system)

Unlike Java, Python does not enforce types at runtime. Type hints are still required.

```python
# Java: private String name;
# Python:
name: str = "John Doe"

# Java: List<String>
from typing import List
names: list[str] = []         # Python 3.9+
names: List[str] = []         # Python 3.8 and below

# Java: Optional<String>
from typing import Optional
name: Optional[str] = None    # value that can be None
name: str | None = None       # Python 3.10+ syntax

# Java: Map<String, Integer>
scores: dict[str, int] = {}

# function signature
def get_user(user_id: int) -> UserResponse | None:
    ...
```

## Classes vs Functions

In Java, everything is a class. In Python, functions are first-class citizens.

```python
# Java habit: unnecessary class wrapping
class UserUtils:
    @staticmethod
    def format_name(first: str, last: str) -> str:
        return f"{last} {first}"

# Python way: just a function
def format_name(first: str, last: str) -> str:
    return f"{last} {first}"
```

Service and Repository layers in FastAPI are written as classes; utility functions do not need a class.

## async/await

FastAPI supports async. Choose sync or async for DB operations and stay consistent.

```python
# This project uses SQLAlchemy sync sessions
# async def is not required (it's optional)

# sync (default for this project)
def create_user(self, data: UserCreate) -> User:
    user = User(**data.model_dump())
    self.db.add(user)
    self.db.commit()
    return user

# async when needed (external API calls etc.)
import httpx

async def call_external_api(url: str) -> dict:
    async with httpx.AsyncClient() as client:
        response = await client.get(url)
        return response.json()
```

## Pydantic (equivalent to Java DTO/Bean)

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
    email: EmailStr            # validates email format automatically
    password: str
    name: str

    @field_validator("password")
    @classmethod
    def password_length(cls, v: str) -> str:
        if len(v) < 8:
            raise ValueError("Password must be at least 8 characters")
        return v
```

## Exception Handling

```python
# Java habit: checked exception
# try { ... } catch (UserNotFoundException e) { ... }

# Python way: only where needed
class UserNotFoundError(Exception):
    def __init__(self, user_id: int):
        super().__init__(f"User {user_id} not found")

# raise in Service
def get_user(self, user_id: int) -> User:
    user = self.repo.find_by_id(user_id)
    if user is None:
        raise UserNotFoundError(user_id)
    return user

# convert to HTTP exception in Router
from fastapi import HTTPException

@router.get("/{user_id}")
def get_user(user_id: int, service: UserService = Depends()):
    try:
        return service.get_user(user_id)
    except UserNotFoundError as e:
        raise HTTPException(status_code=404, detail=str(e))
```

## List Comprehension (equivalent to Java Stream)

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

## Environment Variables / Settings

```python
# Java habit: hardcode in application.properties
# Python way: pydantic-settings
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    database_url: str          # reads DATABASE_URL from .env
    secret_key: str
    debug: bool = False        # has default, not required in .env

    model_config = {"env_file": ".env"}  # auto-load .env file

settings = Settings()
```

## Underscore Conventions

```python
# public → write normally
def get_user(self): ...

# private → single underscore (convention, not enforced)
def _validate_password(self): ...

# never use from outside → double underscore (name mangling)
def __internal_only(self): ...

# avoid collision with Python reserved words
type_ = "admin"   # type is a Python built-in
```

## f-strings (equivalent to Java String.format)

```python
# Java: String.format("Hello, %s! You are %d years old.", name, age)
# Python:
message = f"Hello, {name}! You are {age} years old."

# expressions work too
message = f"Total: {price * quantity:.2f}"
```
