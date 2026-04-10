# DB 모델 & 마이그레이션 규칙

## 테이블 네이밍

| 항목 | 규칙 | 예시 |
|------|------|------|
| 테이블명 | `snake_case` 복수형 | `users`, `order_items` |
| 컬럼명 | `snake_case` | `created_at`, `user_id` |
| PK | 항상 `id` (Integer, auto increment) | `id = Column(Integer, primary_key=True)` |
| FK | `<참조테이블단수>_id` | `user_id`, `product_id` |
| 인덱스 | FK 컬럼, 자주 조회하는 컬럼 | `index=True` |
| 유니크 | 비즈니스 규칙상 중복 불가 컬럼 | `unique=True` |

## 공통 컬럼 (모든 테이블에 포함)

```python
# app/models/base_model.py
from sqlalchemy import Column, Integer, DateTime, func
from app.core.database import Base

class TimestampMixin:
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now(), nullable=False)
```

모든 모델은 `TimestampMixin`을 상속받습니다:

```python
class User(Base, TimestampMixin):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    ...
```

## 소프트 삭제 (Soft Delete)

데이터를 물리적으로 삭제하지 않고 `deleted_at` 컬럼으로 관리:

```python
class SoftDeleteMixin:
    deleted_at = Column(DateTime, nullable=True, default=None)

    @property
    def is_deleted(self) -> bool:
        return self.deleted_at is not None
```

Repository에서 항상 `deleted_at IS NULL` 필터 적용:

```python
def find_all(self) -> list[User]:
    return self.db.query(User).filter(User.deleted_at.is_(None)).all()
```

## Alembic 마이그레이션 규칙

### 마이그레이션 생성

```bash
# 자동 생성 (모델 변경 감지)
alembic revision --autogenerate -m "add_users_table"

# 수동 생성 (데이터 마이그레이션 등)
alembic revision -m "backfill_user_names"
```

### 파일명 규칙

```
alembic/versions/
├── 20240101_001_add_users_table.py
├── 20240102_001_add_products_table.py
└── 20240103_001_add_user_id_to_orders.py
```

형식: `YYYYMMDD_NNN_<설명>.py`

### 마이그레이션 파일 작성 규칙

1. `upgrade()` 와 `downgrade()` 항상 작성
2. 데이터 마이그레이션은 배치로 처리 (전체 테이블 한번에 UPDATE 금지)
3. NOT NULL 컬럼 추가 시 반드시 default 값 제공

```python
# 나쁜 예 - 롤백 불가
def upgrade():
    op.add_column('users', sa.Column('phone', sa.String(), nullable=False))

# 좋은 예 - nullable로 추가 후 backfill
def upgrade():
    op.add_column('users', sa.Column('phone', sa.String(), nullable=True))
    # 필요 시 데이터 backfill
    op.execute("UPDATE users SET phone = '' WHERE phone IS NULL")
    op.alter_column('users', 'phone', nullable=False)

def downgrade():
    op.drop_column('users', 'phone')
```

### 마이그레이션 실행

```bash
# 최신으로 업그레이드
alembic upgrade head

# 특정 버전으로
alembic upgrade <revision>

# 롤백
alembic downgrade -1

# 현재 상태 확인
alembic current
```

## 관계 정의

```python
# One-to-Many
class User(Base):
    orders = relationship("Order", back_populates="user")

class Order(Base):
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    user = relationship("User", back_populates="orders")
```

`lazy="select"` (기본값) 사용. N+1 문제가 의심되면 `joinedload` 명시적 사용.
