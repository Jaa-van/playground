# System Architecture Overview

## Overall Structure

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

## Component Roles

| Component | Technology | Role |
|-----------|-----------|------|
| nginx | nginx:alpine | Reverse proxy — `/api/*` → backend, `/` → frontend |
| backend | Python 3.12 + FastAPI | REST API, business logic |
| frontend | React 18 + Vite | SPA UI |
| db | SQLite | Persistent data storage (`/app/data/app.db`, Docker volume) |

## Request Flow

```
Browser → nginx:80
  ├── GET /api/v1/users  → backend:8000/v1/users
  └── GET /*             → frontend:3000 (React SPA)

backend:8000
  └── FastAPI router → service layer → repository layer → SQLite:/app/data/app.db
```

## Environments

| Environment | docker-compose file | Characteristics |
|-------------|---------------------|-----------------|
| Development (local) | `docker-compose.yml` + `docker-compose.override.yml` | hot reload, volume mount |
| Production (EC2) | `docker-compose.yml` only | no volume mount |

## Ports

| Service | Internal port | External port (local) | Access |
|---------|--------------|----------------------|--------|
| nginx | 80 | 80 | http://localhost |
| backend | 8000 | 8000 | http://localhost:8000 (direct) |
| frontend | 3000 | 3000 | http://localhost:3000 (direct) |
| Swagger UI | - | - | http://localhost:8000/docs |
