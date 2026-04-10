# API 명명 규칙

## URL 구조

```
/api/v1/<resource>
/api/v1/<resource>/{id}
/api/v1/<resource>/{id}/<sub-resource>
```

- 리소스명: **복수형 소문자** (`users`, `products`, `orders`)
- 단어 구분: 하이픈 (`order-items`, not `orderItems`, not `order_items`)
- 버전 접두사: `/api/v1/` 고정

## HTTP 메서드 규칙

| 작업 | 메서드 | URL 예시 | 응답 코드 |
|------|--------|----------|-----------|
| 목록 조회 | GET | `/api/v1/users` | 200 |
| 단건 조회 | GET | `/api/v1/users/{id}` | 200 / 404 |
| 생성 | POST | `/api/v1/users` | 201 |
| 전체 수정 | PUT | `/api/v1/users/{id}` | 200 |
| 부분 수정 | PATCH | `/api/v1/users/{id}` | 200 |
| 삭제 | DELETE | `/api/v1/users/{id}` | 204 |

## 응답 형식

### 단건 응답

```json
{
  "id": 1,
  "name": "홍길동",
  "email": "hong@example.com",
  "created_at": "2024-01-01T00:00:00Z"
}
```

### 목록 응답 (페이지네이션 포함)

```json
{
  "items": [...],
  "total": 100,
  "page": 1,
  "size": 20,
  "pages": 5
}
```

### 에러 응답

```json
{
  "detail": "사용자를 찾을 수 없습니다"
}
```

복수 에러 (유효성 검사 실패):

```json
{
  "detail": [
    {"loc": ["body", "email"], "msg": "유효한 이메일을 입력하세요", "type": "value_error"}
  ]
}
```

## HTTP 상태 코드

| 코드 | 의미 | 사용 시점 |
|------|------|-----------|
| 200 | OK | 조회, 수정 성공 |
| 201 | Created | 생성 성공 |
| 204 | No Content | 삭제 성공 |
| 400 | Bad Request | 잘못된 요청 형식 |
| 401 | Unauthorized | 인증 토큰 없음/만료 |
| 403 | Forbidden | 권한 없음 |
| 404 | Not Found | 리소스 없음 |
| 409 | Conflict | 중복 데이터 |
| 422 | Unprocessable Entity | Pydantic 유효성 검사 실패 (FastAPI 자동) |
| 500 | Internal Server Error | 서버 오류 |

## 필드 네이밍

- JSON 필드: `snake_case` (`created_at`, `user_id`)
- 날짜/시간: ISO 8601 형식 (`2024-01-01T00:00:00Z`)
- ID: 정수 또는 UUID (프로젝트 내 통일)

## 페이지네이션 쿼리 파라미터

```
GET /api/v1/users?page=1&size=20&sort=created_at&order=desc
```

| 파라미터 | 기본값 | 설명 |
|----------|--------|------|
| page | 1 | 페이지 번호 (1부터 시작) |
| size | 20 | 페이지당 항목 수 (최대 100) |
| sort | created_at | 정렬 기준 필드 |
| order | desc | 정렬 방향 (asc/desc) |

## FastAPI 라우터 파일 구조 예시

```python
# app/api/v1/router.py
from fastapi import APIRouter
from app.api.v1.endpoints import health, users

api_router = APIRouter()
api_router.include_router(health.router, prefix="/health", tags=["health"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
```
