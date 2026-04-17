# Project Harness

## Stack
- **Backend**: Python 3.12 + FastAPI → [docs/backend/api-conventions.md](docs/backend/api-conventions.md)
- **Frontend**: JavaScript + React 18 (Vite) → [docs/frontend/component-conventions.md](docs/frontend/component-conventions.md)
- **DB**: SQLite (SQLAlchemy ORM, tables auto-created via `create_all` on app start)
- **Infra**: Docker Compose (local), AWS EC2 (production)

## Agent Role Reference

| Role | Required reading before session |
|------|--------------------------------|
| Planner | [docs/agents/planner-role.md](docs/agents/planner-role.md) |
| Developer | [docs/agents/developer-role.md](docs/agents/developer-role.md) |
| Evaluator | [docs/agents/evaluator-role.md](docs/agents/evaluator-role.md) |
| Handoff protocol | [docs/agents/handoff-protocol.md](docs/agents/handoff-protocol.md) |

## Architecture Reference (load as needed)

| Topic | File |
|-------|------|
| Overall system structure | [docs/architecture/overview.md](docs/architecture/overview.md) |
| Backend layer pattern | [docs/architecture/backend-layers.md](docs/architecture/backend-layers.md) |
| Frontend component structure | [docs/architecture/frontend-structure.md](docs/architecture/frontend-structure.md) |
| API naming conventions | [docs/backend/api-conventions.md](docs/backend/api-conventions.md) |
| DB model/migration rules | [docs/backend/database-conventions.md](docs/backend/database-conventions.md) |
| Testing guide | [docs/backend/testing-guide.md](docs/backend/testing-guide.md) |
| Python style (for Java developers) | [docs/backend/python-style-guide.md](docs/backend/python-style-guide.md) |
| React component conventions | [docs/frontend/component-conventions.md](docs/frontend/component-conventions.md) |
| State management guide | [docs/frontend/state-management.md](docs/frontend/state-management.md) |
| API integration patterns | [docs/frontend/api-integration.md](docs/frontend/api-integration.md) |

## Harness Improvement (Feedback Loop)

This project is cloned from **harness-template**.
Record friction and improvement ideas immediately:

- **[HARNESS_FEEDBACK.md](HARNESS_FEEDBACK.md)** — friction / what worked / template change proposals
- **[docs/git/upstream-workflow.md](docs/git/upstream-workflow.md)** — how to PR improvements back to harness-template
- **[docs/lessons/LESSON-TEMPLATE.md](docs/lessons/LESSON-TEMPLATE.md)** — format for individual Lesson files

> Evaluator must check HARNESS_FEEDBACK.md update status at the end of every SPEC cycle.

## Security Rules

- **Never hardcode** API keys, tokens, passwords, or any secrets in code or scripts
- All secrets must be managed in `.env` and referenced as environment variables
- `.env` is included in `.gitignore` — never commit it
- Scripts that need secrets: `source .env` or reference via `${VAR_NAME}`

## Git Rules (summary)

- No direct commits to `main` or `develop`
- Branch naming: `feature/SPEC-NNN-*`, `fix/*`, `docs/*`
- Commit format: Conventional Commits → [docs/git/commit-conventions.md](docs/git/commit-conventions.md)
- Full strategy: [docs/git/branching-strategy.md](docs/git/branching-strategy.md)

## Current Status

> **Updated**: -
> **Stage**: initial setup complete, awaiting first SPEC
> **Active SPEC**: -
> **Branch / PR**: -
> **Next action**: **Planner** → write first SPEC (SPEC-001)
> **Notes**: -

---

## Handoff Protocol (summary)

```
Planner → Developer: create docs/specs/SPEC-NNN-<name>.md and commit
Developer → Evaluator: open PR from feature branch with [REVIEW] tag in title
Evaluator → Team: create docs/reviews/REVIEW-NNN-<name>.md, APPROVE or REQUEST_CHANGES
```

Full rules: [docs/agents/handoff-protocol.md](docs/agents/handoff-protocol.md)

## Local Run

```bash
cp .env.example .env        # configure env vars
cd infrastructure
docker compose up --build   # start full stack
# http://localhost      → Frontend
# http://localhost/api  → Backend API
# http://localhost:8000/docs → Swagger UI
```

→ Details: [docs/deployment/local-setup.md](docs/deployment/local-setup.md)
