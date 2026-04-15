# Local Environment Setup

## Prerequisites

- Docker Desktop installed (Windows: Docker Desktop for Windows)
- Git
- GitHub CLI (`gh`) — optional

## First Run

```bash
# 1. create env file
cp .env.example .env
# open .env and change SECRET_KEY

# 2. go to infrastructure directory
cd infrastructure

# 3. build and start full stack
docker compose up --build
```

## Access URLs

| Service | URL |
|---------|-----|
| Frontend | http://localhost |
| Backend API | http://localhost/api/v1 |
| Backend direct | http://localhost:8000 |
| API docs (Swagger) | http://localhost:8000/docs |

## SQLite DB File Location

DB file is stored in Docker volume (`sqlite_data`).
To back up:

```bash
docker compose cp backend:/app/data/app.db ./app.db.backup
```

## Common Commands

```bash
# start all (background)
docker compose up -d

# view logs
docker compose logs -f backend
docker compose logs -f frontend

# rebuild (after code changes)
docker compose up --build backend

# stop all
docker compose down

# full teardown including DB volume (warning: data is deleted)
docker compose down -v
```

## DB Table Management

Uses SQLite. Tables are created automatically by `Base.metadata.create_all()` on app start.
No manual migration runs needed.

```bash
# check DB file location
docker compose exec backend ls -la /app/data/

# backup DB file
docker compose cp backend:/app/data/app.db ./app.db.backup
```

## Running Tests

```bash
# backend tests
docker compose exec backend pytest -v

# with coverage
docker compose exec backend pytest --cov=app --cov-report=term-missing
```

## Hot Reload

In dev environment (`docker-compose.override.yml` applied automatically), code changes trigger auto-restart:

- **Backend**: Python file changes in `backend/app/` → uvicorn restarts automatically
- **Frontend**: File changes in `frontend/src/` → Vite HMR updates automatically

## Troubleshooting

### Port conflict

```bash
# find process using port 80 (Windows)
netstat -ano | findstr :80
```

### Package changes not reflected

```bash
# image rebuild required
docker compose up --build backend
```
