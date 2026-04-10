# Handoff 프로토콜

## 개요

Agent 간 인수인계는 **파일 기반**으로 동작합니다. 세션 체이닝 없이 git 저장소에 커밋된 파일이 유일한 인수인계 수단입니다. 어떤 agent도 이전 세션의 컨텍스트 없이 파일만으로 작업을 재개할 수 있어야 합니다.

## 전체 흐름

```
사용자 요구사항
      ↓
[기획자 session]
      ↓ docs/specs/SPEC-NNN-<name>.md 생성 + 커밋
[개발자 session]
      ↓ feature/SPEC-NNN-<name> 브랜치 → PR 오픈 ([REVIEW] 태그)
[평가자 session]
      ↓ docs/reviews/REVIEW-NNN-<name>.md 생성 + PR APPROVE/REQUEST_CHANGES
[머지 → develop]
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
| REJECT 시 | PR 닫기, 기획자에게 SPEC 재검토 요청 |

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

## 현재 작업 현황 확인

```bash
# 미리뷰 대기 중인 PR 목록
gh pr list --label "[REVIEW]" --base develop

# 최신 SPEC 번호 확인
ls docs/specs/

# 최신 REVIEW 번호 확인
ls docs/reviews/
```
