# Handoff 프로토콜

## 전체 흐름

```
사용자 요구사항
      ↓
[기획자 session]
  ① LESSONS.md 확인 → ② FEEDBACK 확인 → ③ DEVNOTES 확인
      ↓ SPEC-NNN 생성 + commit to develop
[개발자 session]
      ↓ feature 브랜치 → PR 오픈 [REVIEW]
[평가자 session]
      ↓
  APPROVE → PR merge → DEVNOTES 생성
  REQUEST_CHANGES → 개발자 재작업 → [REVIEW-2]
  REJECT → FEEDBACK 생성 + PR 닫기 → 기획자 재기획
```

## 인수인계 규칙 요약

| From → To | 아티팩트 | 완료 신호 |
|-----------|---------|---------|
| 기획자 → 개발자 | `docs/specs/SPEC-NNN-*.md` | develop에 SPEC 파일 존재 |
| 개발자 → 평가자 | PR with `[REVIEW]` tag | PR 제목에 [REVIEW] 존재 |
| 평가자 → 개발자 | `docs/reviews/REVIEW-NNN-*.md` | feature 브랜치에 REVIEW 파일 |
| 평가자 → 기획자 (REJECT) | `docs/feedback/FEEDBACK-NNN-*.md` | develop에 FEEDBACK 존재 |
| 개발자 → 기획자 (머지 후) | `docs/feedback/DEVNOTES-NNN-*.md` | develop에 DEVNOTES 존재 |

## 파일 네이밍

```
SPEC-001-user-auth.md  ↔  REVIEW-001-user-auth.md
<name>은 kebab-case (소문자 + 하이픈)
```

---
> 이 파일은 사람 참조용 한글 버전입니다. 에이전트용 영문 버전: `docs/agents/handoff-protocol.md`
