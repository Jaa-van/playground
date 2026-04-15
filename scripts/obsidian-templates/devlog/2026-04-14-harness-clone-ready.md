---
date: 2026-04-14
spec: 
tags: [devlog]
---

# Harness Clone-Ready 설정

> 이 repo를 다른 사람이 clone해서 바로 쓸 수 있도록 설정 자동화 작업을 진행했다.

---

## Summary

harness가 개인 환경에 종속된 문제를 해결하고, clone 후 바로 쓸 수 있는 구조로 전환했다.

- Obsidian API 토큰 환경변수화 (`OBSIDIAN_API_KEY`, `OBSIDIAN_HOST`, `OBSIDIAN_VAULT`)
- `.env.example` 업데이트
- git hook repo 추적 (`.githooks/post-commit` → `setup-dev.sh`가 설치)
- `scripts/setup-dev.sh` 신규 생성 (clone 후 1회 실행 초기화)
- `scripts/obsidian-init.sh` 신규 생성 (vault 초기 구조 자동 세팅)
- `scripts/obsidian-templates/` 신규 생성 (정적 템플릿 파일들)
- `harness-guide.md` 섹션 11 추가 (온보딩 순서 문서화)
- Notion MCP 제거 (더 이상 미사용)

---

## Approach

### 환경변수화
`obsidian-sync.sh`에서 하드코딩된 값을 제거하고 `.env` 자동 로드로 전환.
API 키 없으면 조용히 종료해 Obsidian 미사용 환경도 대응.

### git hook 추적
`.git/hooks/`는 clone 시 사라지는 문제 → `.githooks/post-commit`으로 repo에 커밋.
`setup-dev.sh`가 심링크/복사로 설치.

### Obsidian 초기화 자동화
`obsidian-init.sh`가 `obsidian-templates/` 하위 파일을 vault에 PUT 후
`obsidian-sync.sh`를 호출해 `docs/` 전체 동기화까지 완료.

---

## Blockers

`~/.claude/settings.json` MCP 설정은 전역 파일 수정이라 자동화 보류.
`setup-dev.sh`에서 자동화 가능하나 의도치 않은 전역 설정 변경 리스크로 수동 유지.

---

## Next Steps

- `~/.claude/settings.json` MCP 자동 설정 방법 검토 (선택적 자동화)

---

## Notes

Clone 후 설정 순서:
```bash
cp .env.example .env          # SECRET_KEY, OBSIDIAN_API_KEY 편집
bash scripts/setup-dev.sh     # hook 설치 + Obsidian vault 초기화
# ~/.claude/settings.json MCP 설정 (수동, harness-guide.md 섹션 11 참고)
cd infrastructure && docker compose up --build
```
