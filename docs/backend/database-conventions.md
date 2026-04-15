# DB Model & Migration Conventions

## Table Naming

| Item | Rule | Example |
|------|------|---------|
| Table name | `snake_case` plural | `users`, `order_items` |
| Column name | `snake_case` | `created_at`, `user_id` |
| PK | Always `id` (Integer, auto increment) | `id = Column(Integer, primary_key=True)` |
| FK | `<referenced_table_singular>_id` | `user_id`, `product_id` |
| Index | FK columns and frequently queried columns | `index=True` |
| Unique | Columns that must be unique per business rules | `unique=True` |

## Common Columns (all tables)

```python
# app/models/base_model.py
from sqlalchemy import Column, Integer, DateTime, func
from app.core.database import Base

class TimestampMixin:
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now(), nullable=False)
```

All models inherit `TimestampMixin`:

```python
class User(Base, TimestampMixin):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    ...
```

## Soft Delete

Manage deletion via `deleted_at` column rather than physical deletion:

```python
class SoftDeleteMixin:
    deleted_at = Column(DateTime, nullable=True, default=None)

    @property
    def is_deleted(self) -> bool:
        return self.deleted_at is not None
```

Repository must always apply `deleted_at IS NULL` filter:

```python
def find_all(self) -> list[User]:
    return self.db.query(User).filter(User.deleted_at.is_(None)).all()
```

## Alembic Migration Rules

### Creating a migration

```bash
# auto-generate (detects model changes)
alembic revision --autogenerate -m "add_users_table"

# manual (for data migrations etc.)
alembic revision -m "backfill_user_names"
```

### Filename convention

```
alembic/versions/
├── 20240101_001_add_users_table.py
├── 20240102_001_add_products_table.py
└── 20240103_001_add_user_id_to_orders.py
```

Format: `YYYYMMDD_NNN_<description>.py`

### Migration file rules

1. Always write both `upgrade()` and `downgrade()`
2. Data migrations must be processed in batches (no full-table UPDATE in one shot)
3. Adding a NOT NULL column must provide a default value

```python
# Bad — not rollback-safe
def upgrade():
    op.add_column('users', sa.Column('phone', sa.String(), nullable=False))

# Good — add nullable first, then backfill
def upgrade():
    op.add_column('users', sa.Column('phone', sa.String(), nullable=True))
    # backfill if needed
    op.execute("UPDATE users SET phone = '' WHERE phone IS NULL")
    op.alter_column('users', 'phone', nullable=False)

def downgrade():
    op.drop_column('users', 'phone')
```

### Running migrations

```bash
# upgrade to latest
alembic upgrade head

# upgrade to specific revision
alembic upgrade <revision>

# rollback one step
alembic downgrade -1

# check current state
alembic current
```

## Relationships

```python
# One-to-Many
class User(Base):
    orders = relationship("Order", back_populates="user")

class Order(Base):
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    user = relationship("User", back_populates="orders")
```

Use `lazy="select"` (default). If N+1 is suspected, use `joinedload` explicitly.
