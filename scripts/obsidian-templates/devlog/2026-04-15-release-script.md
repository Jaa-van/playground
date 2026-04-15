---
date: 2026-04-15
spec: 
tags: [devlog, harness]
---

# release.sh — 자동 버전 bump 및 릴리스 스크립트

---

## Summary

- `scripts/release.sh` 신규 작성
  - 마지막 Git 태그 이후 커밋 메시지를 Conventional Commits 기준으로 분석
  - patch / minor / major 자동 판단 후 사용자 확인
  - HARNESS_VERSION 수정 + CHANGELOG 항목 자동 생성 + 커밋 + 태그 + push 일괄 처리
  - `bash scripts/release.sh minor` 형태로 명시적 override 가능
- `CHANGELOG.md` 릴리스 절차 섹션을 스크립트 참조로 업데이트

---

## Approach

### 판단 로직

```
BREAKING CHANGE 또는 feat! → major
feat                        → minor
그 외 (fix, docs, chore...) → patch
```

커밋 목록을 순회하며 가장 높은 우선순위 하나를 적용.

### 사용자 확인 단계 유지

자동 판단이 틀릴 수 있으므로 판단 결과와 커밋 목록을 보여주고 y/N으로 확인받는다.  
override(`bash scripts/release.sh minor`)를 지원하므로 자동 판단이 틀려도 재실행 없이 처리 가능.

### CHANGELOG 자동 생성

커밋을 feat / fix / docs / chore / other 로 분류해 섹션별로 정리.  
기존 CHANGELOG.md의 첫 번째 `---` 구분선 아래에 새 항목을 삽입 (`awk` 사용).

### 실행 시점은 수동

릴리스 타이밍 판단은 자동화하기 어렵다. contrib PR merge 후 변경 규모를 보고 직접 실행하는 방식으로 결정.  
스크립트는 과정만 자동화한다.

---

## Blockers

없음.

---

## Next Steps

- PR #6 merge 후 실제 동작 검증
- contrib PR이 들어오면 release.sh 실행해서 v1.1.0 릴리스 테스트

---

## Notes

- 브랜치 무관하게 실행 가능하나 main에서 실행 권장 (main 아닐 경우 경고 출력)
- 이전 태그가 없는 경우 전체 히스토리 분석으로 fallback
