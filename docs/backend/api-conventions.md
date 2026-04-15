# API Naming Conventions

## URL Structure

```
/api/v1/<resource>
/api/v1/<resource>/{id}
/api/v1/<resource>/{id}/<sub-resource>
```

- Resource names: **plural lowercase** (`users`, `products`, `orders`)
- Word separator: hyphen (`order-items`, not `orderItems`, not `order_items`)
- Version prefix: `/api/v1/` fixed

## HTTP Method Rules

| Action | Method | URL example | Response code |
|--------|--------|-------------|---------------|
| List | GET | `/api/v1/users` | 200 |
| Get one | GET | `/api/v1/users/{id}` | 200 / 404 |
| Create | POST | `/api/v1/users` | 201 |
| Full update | PUT | `/api/v1/users/{id}` | 200 |
| Partial update | PATCH | `/api/v1/users/{id}` | 200 |
| Delete | DELETE | `/api/v1/users/{id}` | 204 |

## Response Format

### Single resource

```json
{
  "id": 1,
  "name": "John Doe",
  "email": "john@example.com",
  "created_at": "2024-01-01T00:00:00Z"
}
```

### List response (with pagination)

```json
{
  "items": [...],
  "total": 100,
  "page": 1,
  "size": 20,
  "pages": 5
}
```

### Error response

```json
{
  "detail": "User not found"
}
```

Multiple errors (validation failure):

```json
{
  "detail": [
    {"loc": ["body", "email"], "msg": "Enter a valid email", "type": "value_error"}
  ]
}
```

## HTTP Status Codes

| Code | Meaning | When to use |
|------|---------|-------------|
| 200 | OK | GET, update success |
| 201 | Created | Create success |
| 204 | No Content | Delete success |
| 400 | Bad Request | Malformed request |
| 401 | Unauthorized | Missing/expired auth token |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource does not exist |
| 409 | Conflict | Duplicate data |
| 422 | Unprocessable Entity | Pydantic validation failure (FastAPI automatic) |
| 500 | Internal Server Error | Server error |

## Field Naming

- JSON fields: `snake_case` (`created_at`, `user_id`)
- Dates/times: ISO 8601 format (`2024-01-01T00:00:00Z`)
- IDs: integer or UUID (consistent within the project)

## Pagination Query Parameters

```
GET /api/v1/users?page=1&size=20&sort=created_at&order=desc
```

| Parameter | Default | Description |
|-----------|---------|-------------|
| page | 1 | Page number (1-based) |
| size | 20 | Items per page (max 100) |
| sort | created_at | Sort field |
| order | desc | Sort direction (asc/desc) |

## FastAPI Router File Structure

```python
# app/api/v1/router.py
from fastapi import APIRouter
from app.api.v1.endpoints import health, users

api_router = APIRouter()
api_router.include_router(health.router, prefix="/health", tags=["health"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
```
