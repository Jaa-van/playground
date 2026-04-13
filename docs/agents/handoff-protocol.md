# Handoff 프로토콜

## 개요

Agent 간 인수인계는 **파일 기반**으로 동작합니다. 세션 체이닝 없이 git 저장소에 커밋된 파일이 유일한 인수인계 수단입니다. 어떤 agent도 이전 세션의 컨텍스트 없이 파일만으로 작업을 재개할 수 있어야 합니다.

## 전체 흐름

```
사용자 요구사항
      ↓
[기획자 session]
  ① docs/feedback/LESSONS.md 확인 (최근 5개)
  ② docs/feedback/FEEDBACK-NNN-*.md 확인 (REJECT 수신 시)
  ③ docs/feedback/DEVNOTES-NNN-*.md 확인 (직전 사이클)
      ↓ docs/specs/SPEC-NNN-<name>.md 생성 + LESSONS.md 업데이트 + develop 커밋
[개발자 session]
      ↓ feature/SPEC-NNN-<name> 브랜치 → PR 오픈 ([REVIEW] 태그)
[평가자 session]
      ↓
  ┌── APPROVE ─────────────────────────────────────────────┐
  │   PR merge to develop                                  │
  │   개발자: DEVNOTES-NNN 생성 + develop 커밋              │
  └────────────────────────────────────────────────────────┘
  ┌── REQUEST_CHANGES ─────────────────────────────────────┐
  │   REVIEW 파일 커밋 → 개발자 재작업 → [REVIEW-2] 재태그  │
  │   (최대 3회, 이후 REJECT 경로)                          │
  └────────────────────────────────────────────────────────┘
  ┌── REJECT ──────────────────────────────────────────────┐
  │   FEEDBACK-NNN 생성 + develop 직접 커밋                 │
  │   PR 닫기                                              │
  │   기획자: 다음 세션에서 FEEDBACK 읽고 SPEC 재설계        │
  └────────────────────────────────────────────────────────┘
      ↓
[다음 SPEC으로 반복]
```

## 인수인계 아티팩트 규칙

### 기획자 → 개발자

| 항목 | 규칙 |
|------|------|
| 파일 위치 | `docs/specs/SPEC-NNN-<kebab-name>.md` |
| 브랜치 | `develop`에 직접 커밋 (docs 파일만) |
| 커밋 메시지 | `docs(specs): add SPEC-NNN <기능명>` |
| 완료 신호 | `develop` 브랜치에 SPEC 파일이 존재함 |

개발자는 SPEC 파일을 읽고 추가 질문 없이 구현을 시작할 수 있어야 합니다.
질문이 생긴다면 SPEC이 불완전한 것 → 기획자 재작업 필요.

### 개발자 → 평가자

| 항목 | 규칙 |
|------|------|
| PR 브랜치 | `feature/SPEC-NNN-<name>` → `develop` |
| PR 제목 | `feat(<scope>): SPEC-NNN <설명> [REVIEW]` |
| PR 본문 필수 항목 | 구현 내용 요약, 테스트 방법, 체크리스트 |
| 완료 신호 | PR 제목에 `[REVIEW]` 태그 존재 |

평가자는 `[REVIEW]` 태그가 있는 PR을 리뷰 대상으로 식별합니다.

### 평가자 → 팀

| 항목 | 규칙 |
|------|------|
| 파일 위치 | `docs/reviews/REVIEW-NNN-<name>.md` |
| 브랜치 | feature 브랜치에 커밋 (PR에 포함되도록) |
| 커밋 메시지 | `docs(reviews): add REVIEW-NNN <기능명>` |
| APPROVE 시 | PR merge to `develop` 실행 |
| REQUEST_CHANGES 시 | REVIEW 파일 커밋 후 개발자에게 재작업 요청 |
| REJECT 시 | FEEDBACK 파일 생성 + PR 닫기, 기획자에게 SPEC 재검토 요청 |

### 평가자 → 기획자 (REJECT 시)

| 항목 | 규칙 |
|------|------|
| 파일 위치 | `docs/feedback/FEEDBACK-NNN-<kebab-name>.md` |
| 브랜치 | `develop`에 직접 커밋 |
| 커밋 메시지 | `docs(feedback): add FEEDBACK-NNN <기능명>` |
| 완료 신호 | develop에 FEEDBACK 파일 존재 + PR 닫힘 |

### 개발자 → 기획자 (머지 후)

| 항목 | 규칙 |
|------|------|
| 파일 위치 | `docs/feedback/DEVNOTES-NNN-<kebab-name>.md` |
| 브랜치 | `develop`에 직접 커밋 |
| 커밋 메시지 | `docs(feedback): add DEVNOTES-NNN <기능명>` |
| 완료 신호 | develop에 DEVNOTES 파일 존재 |
| 이슈 없을 때 | 파일 생성 후 "SPEC 품질 이슈 없음." 한 줄만 기재 |

## 파일 네이밍 규칙

```
SPEC 번호와 REVIEW 번호는 반드시 일치시킵니다.
SPEC-001-user-auth.md  ↔  REVIEW-001-user-auth.md

<name> 부분은 kebab-case (소문자 + 하이픈)
예시:
  SPEC-001-user-auth.md
  SPEC-002-product-crud.md
  SPEC-003-order-checkout.md
```

## 재작업 사이클

```
REQUEST_CHANGES 수신
      ↓
개발자: REVIEW 파일 읽기 → 수정 → 커밋
      ↓
PR 제목에 [REVIEW] 재태그 (예: "[REVIEW-2]")
      ↓
평가자: 재리뷰 → APPROVE 또는 재 REQUEST_CHANGES
```

최대 3회 REQUEST_CHANGES 후에도 해결 안 되면 REJECT → SPEC 재검토.

## 최근 작업 이력 파악 (git log)

각 agent는 세션 시작 시 아래 명령으로 최근 작업 흐름을 파악합니다.
commit message는 Conventional Commits 형식이므로 `feat/fix/docs` 접두사로 어떤 작업이 있었는지 빠르게 파악할 수 있습니다.

### 공통: develop 브랜치 최근 이력

```bash
git log develop --oneline --decorate -20
```

출력 해석 기준:
- `docs(specs): add SPEC-NNN` — 기획 완료, 개발 대기 중
- `feat(...)` — 구현 커밋
- `docs(reviews): add REVIEW-NNN` — 리뷰 완료
- `docs(feedback): add FEEDBACK-NNN` — REJECT 발생, 기획자 재작업 필요
- `docs(feedback): add DEVNOTES-NNN` — 머지 완료, 개발자 노트 있음

### 기획자 전용

```bash
# 최신 SPEC 번호 확인 (다음 번호 결정)
git log develop --oneline --grep="docs(specs)" -5

# 최근 REJECT 이력 확인
git log develop --oneline --grep="FEEDBACK" -5
```

### 개발자 전용

```bash
# 작업 중인 feature 브랜치에서 develop 대비 내 커밋 목록
git log develop..HEAD --oneline

# REQUEST_CHANGES 이후 재작업 시: 어떤 리뷰가 있었는지
git log --oneline --grep="REVIEW-NNN" --all
```

### 평가자 전용

```bash
# PR 브랜치의 커밋 목록 (구현 의도 파악)
git log develop..<feature-branch> --oneline

# 동일 SPEC의 이전 리뷰 사이클 여부 확인
git log --oneline --all --grep="SPEC-NNN"
```

## 현재 작업 현황 확인

```bash
# 리뷰 대기 중인 PR 목록
gh pr list --base develop

# 최신 SPEC/REVIEW 번호 확인
ls docs/specs/
ls docs/reviews/

# 미처리 피드백 확인
ls docs/feedback/

# 최신 교훈 확인
head -50 docs/feedback/LESSONS.md
```
