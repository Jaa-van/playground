# Agent 역할 정의

> Multi-Agent 시스템의 각 역할 정의와 워크플로우를 기록합니다.

## 역할별 문서

| 역할 | 문서 | 핵심 책임 |
|------|------|-----------|
| 기획자 (Planner) | [[harness-template/agents/planner\|Planner 역할]] | SPEC 작성, LESSONS 확인 |
| 개발자 (Developer) | [[harness-template/agents/developer\|Developer 역할]] | SPEC 기반 구현, PR 오픈 |
| 평가자 (Evaluator) | [[harness-template/agents/evaluator\|Evaluator 역할]] | 코드 리뷰, APPROVE/REJECT 결정 |

## 워크플로우

```
기획자 → SPEC 생성
   ↓
개발자 → 구현 → PR [REVIEW]
   ↓
평가자 → REVIEW → APPROVE / REQUEST_CHANGES / REJECT
   ↓
(반복 또는 다음 SPEC)
```

---
> 출처: `docs/agents/` in git repo
