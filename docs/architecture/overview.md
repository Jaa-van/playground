# 시스템 아키텍처 개요

## 전체 구조

```
┌─────────────────────────────────────────────────────────────┐
│                      Client (Browser)                        │
└──────────────────────────┬──────────────────────────────────┘
                           │ HTTP/HTTPS :80
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                       nginx (Reverse Proxy)                  │
│   /api/* → backend:8000    /  → frontend:3000               │
└──────────┬──────────────────────────┬───────────────────────┘
           │                          │
           ▼                          ▼
┌──────────────────┐        ┌──────────────────┐
│  Backend         │        │  Frontend         │
│  FastAPI         │        │  React + Vite     │
│  :8000           │        │  :3000            │
└────────┬─────────┘        └──────────────────┘
         │
         ▼
┌──────────────────┐
│  SQLite           │
│  /app/data/app.db │
└──────────────────┘
```

## 컴포넌트 역할

| 컴포넌트 | 기술 | 역할 |
|----------|------|------|
| nginx | nginx:alpine | 리버스 프록시, `/api/*` → backend, `/` → frontend |
| backend | Python 3.12 + FastAPI | REST API, 비즈니스 로직 |
| frontend | React 18 + Vite | SPA UI |
| db | SQLite | 영속 데이터 저장 (`/app/data/app.db`, Docker 볼륨) |

## 요청 흐름

```
Browser → nginx:80
  ├── GET /api/v1/users  → backend:8000/v1/users
  └── GET /*             → frontend:3000 (React SPA)

backend:8000
  └── FastAPI router → service layer → repository layer → SQLite:/app/data/app.db
```

## 환경 구분

| 환경 | docker-compose 파일 | 특징 |
|------|---------------------|------|
| 개발 (로컬) | `docker-compose.yml` + `docker-compose.override.yml` | hot reload, 볼륨 마운트 |
| 운영 (EC2) | `docker-compose.yml` 단독 | 볼륨 마운트 없음 |

## 포트 정리

| 서비스 | 내부 포트 | 외부 포트 (로컬) | 접근 방법 |
|--------|-----------|------------------|-----------|
| nginx | 80 | 80 | http://localhost |
| backend | 8000 | 8000 | http://localhost:8000 (직접 접근 가능) |
| frontend | 3000 | 3000 | http://localhost:3000 (직접 접근 가능) |
| Swagger UI | - | - | http://localhost:8000/docs |
