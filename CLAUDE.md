# Project Harness

## Stack
- **Backend**: Python 3.12 + FastAPI → [docs/backend/api-conventions.md](docs/backend/api-conventions.md)
- **Frontend**: JavaScript + React 18 (Vite) → [docs/frontend/component-conventions.md](docs/frontend/component-conventions.md)
- **DB**: PostgreSQL 16 (SQLAlchemy ORM + Alembic 마이그레이션)
- **Infra**: Docker Compose (로컬), AWS EC2 (운영)

## Agent 역할별 필독 파일

| 역할 | 세션 시작 전 반드시 읽어야 할 파일 |
|------|----------------------------------|
| 기획자 (Planner) | [docs/agents/planner-role.md](docs/agents/planner-role.md) |
| 개발자 (Developer) | [docs/agents/developer-role.md](docs/agents/developer-role.md) |
| 평가자 (Evaluator) | [docs/agents/evaluator-role.md](docs/agents/evaluator-role.md) |
| 인수인계 프로토콜 | [docs/agents/handoff-protocol.md](docs/agents/handoff-protocol.md) |

## 아키텍처 참조 (필요 시 로드)

| 주제 | 파일 |
|------|------|
| 전체 시스템 구조 | [docs/architecture/overview.md](docs/architecture/overview.md) |
| Backend 계층 패턴 | [docs/architecture/backend-layers.md](docs/architecture/backend-layers.md) |
| Frontend 컴포넌트 구조 | [docs/architecture/frontend-structure.md](docs/architecture/frontend-structure.md) |
| API 명명 규칙 | [docs/backend/api-conventions.md](docs/backend/api-conventions.md) |
| DB 모델/마이그레이션 규칙 | [docs/backend/database-conventions.md](docs/backend/database-conventions.md) |
| 테스트 가이드 | [docs/backend/testing-guide.md](docs/backend/testing-guide.md) |
| Python 스타일 (Java 개발자용) | [docs/backend/python-style-guide.md](docs/backend/python-style-guide.md) |
| React 컴포넌트 규칙 | [docs/frontend/component-conventions.md](docs/frontend/component-conventions.md) |
| 상태 관리 가이드 | [docs/frontend/state-management.md](docs/frontend/state-management.md) |
| API 연동 패턴 | [docs/frontend/api-integration.md](docs/frontend/api-integration.md) |

## Git 규칙 (요약)

- `main`, `develop`에 직접 커밋 **금지**
- 브랜치 네이밍: `feature/SPEC-NNN-*`, `fix/*`, `docs/*`
- 커밋 형식: Conventional Commits → [docs/git/commit-conventions.md](docs/git/commit-conventions.md)
- 전체 전략: [docs/git/branching-strategy.md](docs/git/branching-strategy.md)

## Handoff 프로토콜 (요약)

```
기획자 → 개발자: docs/specs/SPEC-NNN-<name>.md 생성 후 커밋
개발자 → 평가자: feature 브랜치에서 PR 오픈, 제목에 [REVIEW] 태그
평가자 → 팀:    docs/reviews/REVIEW-NNN-<name>.md 생성, PR APPROVE 또는 REQUEST_CHANGES
```

전체 규칙: [docs/agents/handoff-protocol.md](docs/agents/handoff-protocol.md)

## 로컬 실행

```bash
cp .env.example .env        # 환경변수 설정
cd infrastructure
docker compose up --build   # 전체 스택 실행
# http://localhost      → Frontend
# http://localhost/api  → Backend API
# http://localhost:5050 → pgAdmin (개발용)
```

→ 상세: [docs/deployment/local-setup.md](docs/deployment/local-setup.md)
