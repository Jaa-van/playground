# harness-template 하네스 — 완전 설명서

> 작성일: 2026-04-14 | 대상: 이 프로젝트를 처음 보는 나 (또는 Claude)

---

## 1. 이 하네스란?

**harness-template**는 Claude Code의 Multi-Agent 시스템을 활용한 1인 풀스택 개발 환경입니다.

기능 하나를 만들 때 세 역할(기획자 → 개발자 → 평가자)을 각각의 Claude 세션이 맡아 수행합니다.  
각 세션은 이전 세션의 컨텍스트 없이 **파일만 보고 작업을 이어받습니다.**

```
사람이 아이디어 작성 (Obsidian inbox)
          ↓
[기획자 세션]  SPEC 파일 작성 → develop 커밋
          ↓
[개발자 세션]  feature 브랜치 → 구현 → PR 오픈 [REVIEW]
          ↓
[평가자 세션]  코드 리뷰 → APPROVE / REQUEST_CHANGES / REJECT
          ↓
       (반복)
```

---

## 2. 기술 스택

| 레이어 | 기술 | 버전 |
|--------|------|------|
| Backend | Python + FastAPI | 3.12 |
| Frontend | React + Vite | 18 |
| Database | SQLite (SQLAlchemy ORM) | - |
| Reverse Proxy | nginx | alpine |
| 컨테이너 | Docker Compose | - |
| 운영 서버 | AWS EC2 | - |
| AI | Claude Code (Sonnet 4.6) | - |

---

## 3. 시스템 아키텍처

```
Browser
   │ HTTP :80
   ▼
nginx (Reverse Proxy)
   ├── /api/* → backend:8000  (FastAPI)
   └── /*     → frontend:3000 (React SPA)
                   │
                   ▼
               SQLite
           /app/data/app.db
           (Docker 볼륨)
```

### 접속 주소 (로컬)

| 서비스 | URL |
|--------|-----|
| 앱 (nginx) | http://localhost |
| API | http://localhost/api/v1 |
| Swagger UI | http://localhost:8000/docs |

---

## 4. 프로젝트 디렉토리 구조

```
harness-template/
├── backend/
│   └── app/
│       ├── api/          ← FastAPI 라우터
│       ├── services/     ← 비즈니스 로직
│       ├── repositories/ ← DB 접근 계층
│       ├── models/       ← SQLAlchemy 모델
│       ├── schemas/      ← Pydantic 스키마
│       └── core/         ← 설정, 의존성
├── frontend/
│   └── src/
│       ├── pages/        ← 페이지 컴포넌트
│       ├── components/   ← 공통 컴포넌트
│       ├── hooks/        ← 커스텀 훅
│       ├── services/     ← API 호출
│       ├── store/        ← 전역 상태
│       └── utils/
├── infrastructure/
│   ├── docker-compose.yml
│   └── nginx/
├── docs/
│   ├── specs/            ← SPEC-NNN 파일
│   ├── reviews/          ← REVIEW-NNN 파일
│   ├── feedback/         ← FEEDBACK, DEVNOTES, LESSONS
│   ├── agents/           ← 각 Agent 역할 정의
│   ├── architecture/     ← 설계 문서
│   ├── backend/          ← 백엔드 컨벤션
│   ├── frontend/         ← 프론트엔드 컨벤션
│   ├── git/              ← Git 규칙
│   └── deployment/       ← 배포 가이드
├── scripts/
│   └── obsidian-sync.sh  ← Obsidian 동기화 스크립트
├── CLAUDE.md             ← Agent가 제일 먼저 읽는 파일
└── .env                  ← 환경변수 (git 비관리)
```

---

## 5. Multi-Agent 시스템

### 역할 정의

| 역할 | 담당 | 읽는 파일 | 만드는 파일 |
|------|------|-----------|-------------|
| **기획자** | SPEC 작성 | LESSONS, FEEDBACK, Obsidian inbox | SPEC-NNN-*.md |
| **개발자** | 구현 + PR | SPEC 파일 | 코드, PR |
| **평가자** | 코드 리뷰 | SPEC, PR diff | REVIEW-NNN-*.md |

### 전체 사이클

```
① 기획자: Obsidian inbox 확인
   → SPEC-NNN 작성 → develop 커밋
   → CLAUDE.md 현황 업데이트

② 개발자: SPEC 파일 읽기
   → feature/SPEC-NNN-<name> 브랜치 생성
   → 구현 → 커밋
   → PR 오픈 (제목에 [REVIEW] 태그)

③ 평가자: [REVIEW] PR 확인
   → 5개 항목 루브릭으로 점수 산정 (각 1-5점)
   → 결정:
     APPROVE       → PR merge to develop
     REQUEST_CHANGES → REVIEW 파일 커밋, 개발자 재작업
     REJECT        → FEEDBACK 파일 생성, PR 닫기
   → CLAUDE.md 현황 업데이트

④ 개발자(머지 후): DEVNOTES 작성 → develop 커밋

⑤ 기획자: 다음 SPEC 작성 (LESSONS.md 업데이트 포함)
```

### 평가 루브릭 (평가자 기준)

| 항목 | 3점 미만이면 승인 불가 |
|------|----------------------|
| 정확성 | AC가 모두 구현됐는가 |
| 테스트 | 에러 케이스 테스트 있는가 |
| 규칙 준수 | api-conventions 준수 |
| 보안 | 하드코딩 시크릿 없음, 입력 검증 |
| 가독성 | 주니어도 이해 가능 |

---

## 6. Obsidian 연동

### 자동 동기화 (docs/ → Obsidian)

`docs/` 하위 파일이 커밋될 때마다 git post-commit hook이 Obsidian에 자동 업로드합니다.

```
커밋 발생
   ↓
.git/hooks/post-commit 실행
   ↓
scripts/obsidian-sync.sh 호출
   ↓
변경된 파일 Obsidian에 PUT
+ 해당 폴더 _index.md 자동 갱신
+ 허브(_index.md) 현황 갱신
```

수동 전체 동기화:
```bash
bash scripts/obsidian-sync.sh
```

Obsidian이 꺼져 있으면 조용히 스킵됩니다.

### 역방향 — Obsidian에서 기획하기

1. `harness-template/inbox/` 폴더에서 `_template.md` 복사
2. 새 파일(`기능명.md`)로 기획 내용 작성
3. 기획자 세션 시작 → 자동으로 inbox 확인 후 SPEC 생성

### Obsidian 폴더 구조

```
harness-template/ (Obsidian vault)
├── _index.md      ← 현황판 (자동 갱신)
├── overview.md    ← 프로젝트 설계 개요
├── inbox/         ← 기획 메모 작성 공간
├── specs/         ← SPEC 파일 미러
├── reviews/       ← REVIEW 파일 미러
├── feedback/      ← FEEDBACK, DEVNOTES, LESSONS
├── architecture/  ← 아키텍처 문서
└── agents/        ← Agent 역할 정의
```

---

## 7. Git 워크플로우

### 브랜치 구조

```
main      ← 운영 배포. 직접 커밋 금지.
develop   ← 통합 브랜치. 항상 실행 가능 상태.
  └── feature/SPEC-NNN-<name>   ← 기능 개발
  └── fix/<description>         ← 버그 수정
  └── docs/<description>        ← 문서 (직접 커밋 가능)
```

### 커밋 메시지 형식 (Conventional Commits)

```
<type>(<scope>): <설명>
```

| type | 의미 |
|------|------|
| `feat` | 새 기능 |
| `fix` | 버그 수정 |
| `docs` | 문서 |
| `test` | 테스트 |
| `refactor` | 리팩터링 |
| `chore` | 빌드/설정 |

예시:
```bash
feat(backend): add user registration endpoint
docs(specs): add SPEC-001 user authentication
fix(auth): correct JWT token expiry calculation
```

### 인수인계 파일 네이밍

```
SPEC-001-user-auth.md       ← Planner가 작성
REVIEW-001-user-auth.md     ← Evaluator가 작성 (번호 일치 필수)
FEEDBACK-001-user-auth.md   ← Evaluator가 REJECT 시 작성
DEVNOTES-001-user-auth.md   ← Developer가 머지 후 작성
```

---

## 8. 로컬 실행

```bash
# 최초 설정
cp .env.example .env   # SECRET_KEY 변경 필요

# 실행
cd infrastructure
docker compose up --build

# 자주 쓰는 명령
docker compose up -d              # 백그라운드 실행
docker compose logs -f backend    # 로그 확인
docker compose up --build backend # 재빌드
docker compose down               # 종료
```

---

## 9. Claude Code 설정

`~/.claude/settings.json`에 다음 MCP 서버가 설정되어 있습니다:

| MCP 서버 | 용도 |
|----------|------|
| `obsidian` | Obsidian Local REST API 읽기/쓰기 |

각 Agent 세션을 시작할 때 역할에 맞는 파일을 먼저 읽도록 `CLAUDE.md`에 명시되어 있습니다.

---

## 10. CLAUDE.md — Agent 진입점

모든 Claude 세션이 제일 먼저 읽는 파일입니다.

주요 내용:
- 기술 스택 요약
- 역할별 필독 파일 경로
- **현재 작업 현황** (단계, 진행 SPEC, 다음 액션)

현재 작업 현황은 각 세션 종료 전 해당 Agent가 업데이트합니다.  
→ 다음 세션이 이 섹션만 읽어도 현재 상태를 파악할 수 있습니다.

---

*이 문서는 [[harness-template/overview|하네스 설계 개요]]와 함께 읽으면 좋습니다.*
---

## 11. 새로운 팀원 온보딩 (Clone 후 설정)

> repo를 clone한 뒤 처음 설정하는 순서입니다.

### 사전 조건

- Docker Desktop 설치
- Node.js 설치 (npx 사용)
- Obsidian + Local REST API 플러그인 활성화 (선택)

---

### 1단계 — `.env` 설정

```bash
cp .env.example .env
```

`.env`를 열어 아래 항목 수정:

| 항목 | 설명 |
|------|------|
| `SECRET_KEY` | 랜덤 32자 문자열로 변경 |
| `OBSIDIAN_API_KEY` | Obsidian → Settings → Community Plugins → Local REST API 에서 복사 |
| `OBSIDIAN_HOST` | 기본값 유지 (`https://127.0.0.1:27124`) |
| `OBSIDIAN_VAULT` | 기본값 유지 (`harness-template`) |

Obsidian을 사용하지 않는다면 `OBSIDIAN_API_KEY`는 비워도 됩니다.

---

### 2단계 — 개발 환경 초기화

```bash
bash scripts/setup-dev.sh
```

수행 작업:
- `.git/hooks/post-commit` 설치 → 커밋 시 Obsidian 자동 동기화
- `scripts/*.sh` 실행 권한 설정
- `OBSIDIAN_API_KEY`가 설정되어 있고 Obsidian이 실행 중이면:
  - vault 폴더 구조 자동 생성
  - 템플릿 파일 업로드
  - `docs/` 전체 동기화

Obsidian을 나중에 연결하는 경우:
```bash
bash scripts/obsidian-init.sh  # 수동 초기화
```

---

### 3단계 — Claude Code MCP 설정 (Obsidian 사용 시)

`~/.claude/settings.json`에 아래 블록을 추가합니다.  
*(전역 파일이라 자동화 불가 — 직접 편집 필요)*

```json
"mcpServers": {
  "obsidian": {
    "command": "npx",
    "args": ["-y", "mcp-obsidian"],
    "env": {
      "OBSIDIAN_API_KEY": "<.env에 설정한 키>",
      "OBSIDIAN_HOST": "https://127.0.0.1:27124"
    }
  }
}
```

설정 후 Claude Code 재시작 필요.

---

### 4단계 — 앱 실행

```bash
cd infrastructure
docker compose up --build
```

| 서비스 | URL |
|--------|-----|
| 앱 | http://localhost |
| API | http://localhost/api/v1 |
| Swagger UI | http://localhost:8000/docs |

---

### 요약

| 단계 | 명령 | 자동? |
|------|------|-------|
| `.env` 설정 | 직접 편집 | ❌ |
| 환경 초기화 + Obsidian vault | `bash scripts/setup-dev.sh` | ✅ |
| Claude MCP 설정 | `~/.claude/settings.json` 편집 | ❌ |
| 앱 실행 | `docker compose up --build` | ✅ |

---

## 12. 멀티 레포 운용 전략

> harness-template 하나에서 여러 독립 프로젝트를 파생시키는 방법입니다.

### 구조

```
harness-template (GitHub Template Repo)
    ↓ "Use this template"
project-alpha/     ← 독립 repo
project-beta/      ← 독립 repo
project-gamma/     ← 독립 repo
```

각 프로젝트는 **독립 repo**입니다. fork가 아니므로 히스토리가 분리되고, 프로젝트 코드가 서로 영향을 주지 않습니다.

---

### 1단계 — harness-template을 GitHub Template Repository로 설정

GitHub 레포 설정에서 **"Template repository"** 체크박스를 활성화합니다.  
이후 새 프로젝트는 `Use this template` 버튼으로 생성합니다.

---

### 2단계 — 새 프로젝트에서 harness를 upstream으로 등록

```bash
git remote add harness https://github.com/your-username/harness-template.git

# 확인
git remote -v
# origin   https://github.com/your-username/my-project.git
# harness  https://github.com/your-username/harness-template.git
```

---

### 3단계 — harness 업데이트 동기화 (선택적)

harness-template에 개선이 반영된 경우, **전체 merge 없이 파일 단위로** 가져옵니다:

```bash
git fetch harness main

# 변경 내용 확인
git diff HEAD harness/main -- docs/ CLAUDE.md

# 필요한 파일만 선택적으로 적용
git checkout harness/main -- docs/backend/api-conventions.md
```

> 전체 merge는 하지 않습니다 — 프로젝트 코드와 충돌합니다.

---

### 4단계 — 개선사항을 harness-template에 피드백

```
프로젝트 작업 중 마찰 발견
    → HARNESS_FEEDBACK.md에 즉시 기록
    → 프로젝트 마무리 시 harness-template에 PR
    → 다음 프로젝트는 개선된 harness로 시작
```

자세한 PR 절차 → [[reference/upstream-workflow|upstream-workflow]]

---

### 새 프로젝트 시작 체크리스트

| 순서 | 작업 |
|------|------|
| 1 | GitHub `Use this template` → 새 repo 생성 |
| 2 | 로컬 clone 후 `git remote add harness <url>` 등록 |
| 3 | `bash scripts/setup-dev.sh` 실행 |
| 4 | `CLAUDE.md` → Current Status 섹션 업데이트 |
| 5 | Planner 세션 시작 → 첫 SPEC 작성 |
