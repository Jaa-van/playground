# 로컬 환경 셋업 가이드

## 사전 요구사항

- Docker Desktop 설치 (Windows: Docker Desktop for Windows)
- Git
- GitHub CLI (`gh`) — 선택사항

## 최초 실행

```bash
# 1. 환경변수 파일 생성
cp .env.example .env
# .env 파일을 열어 SECRET_KEY를 변경하세요

# 2. infrastructure 디렉토리로 이동
cd infrastructure

# 3. 전체 스택 빌드 및 실행
docker compose up --build
```

## 접속 주소

| 서비스 | URL |
|--------|-----|
| Frontend | http://localhost |
| Backend API | http://localhost/api/v1 |
| Backend 직접 | http://localhost:8000 |
| API 문서 (Swagger) | http://localhost:8000/docs |

## SQLite DB 파일 위치

DB 파일은 Docker 볼륨(`sqlite_data`)에 저장됩니다.
백업이 필요하면:

```bash
docker compose cp backend:/app/data/app.db ./app.db.backup
```

## 자주 쓰는 명령어

```bash
# 전체 실행 (백그라운드)
docker compose up -d

# 로그 확인
docker compose logs -f backend
docker compose logs -f frontend

# 재빌드 (코드 변경 시)
docker compose up --build backend

# 전체 종료
docker compose down

# DB 볼륨 포함 전체 삭제 (주의: 데이터 삭제)
docker compose down -v
```

## DB 테이블 관리

SQLite를 사용하며, 앱 시작 시 `Base.metadata.create_all()`이 자동으로 테이블을 생성합니다.
별도의 마이그레이션 실행이 필요 없습니다.

```bash
# DB 파일 위치 확인
docker compose exec backend ls -la /app/data/

# DB 파일 백업
docker compose cp backend:/app/data/app.db ./app.db.backup
```

## 테스트 실행

```bash
# Backend 테스트
docker compose exec backend pytest -v

# 커버리지 포함
docker compose exec backend pytest --cov=app --cov-report=term-missing
```

## Hot Reload

개발 환경(`docker-compose.override.yml` 자동 적용)에서는 코드 변경 시 자동 재시작됩니다:

- **Backend**: `backend/app/` 내 Python 파일 수정 → uvicorn 자동 재시작
- **Frontend**: `frontend/src/` 내 파일 수정 → Vite HMR 자동 갱신

## 트러블슈팅

### 포트 충돌

```bash
# 80 포트 사용 중인 프로세스 확인 (Windows)
netstat -ano | findstr :80
```

### 패키지 추가 후 반영 안 됨

```bash
# 이미지 재빌드 필요
docker compose up --build backend
```
