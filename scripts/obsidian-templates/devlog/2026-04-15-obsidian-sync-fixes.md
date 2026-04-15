---
date: 2026-04-15
spec: 
tags: [devlog]
---

# Obsidian Sync 한글 전용 전환

---

## Summary

- `regen_root_index`의 CLAUDE.md 파싱 필드명 수정 (`**단계**` → `**Stage**`, `**다음 필요 액션**` → `**Next action**`)
- 루트 `_index.md` 빠른 링크 6개 → 8개 (inbox, harness-guide 누락 추가)
- `full_sync()`에 한글 참조 문서 sync 추가 (`scripts/obsidian-templates/reference/*.md`, `harness-guide.md`)
- `obsidian-sync.sh` / `obsidian-init.sh`에서 영문 docs 제거 (agents, architecture, backend, frontend, git, deployment, lessons, CLAUDE.md)
- Obsidian에 남아 있던 영문 파일 21개 API로 직접 삭제

---

## Approach

### 필드명 불일치
`obsidian-sync.sh`의 `regen_root_index`가 한글 필드명을 grep하고 있었는데
CLAUDE.md는 영문으로 리네임된 상태였다. grep 패턴을 영문으로 맞춰 수정.

### 영문 docs 제거
`full_sync()`의 `docs/agents:agents` 등 dir_pair 루프 전체와
`CLAUDE.md` 업로드 블록을 삭제.
`obsidian-init.sh`의 HARNESS_DOCS 배열(22개 항목)도 HARNESS_FEEDBACK.md 1개만 남기고 제거.

### 기존 영문 파일 삭제
이전 sync로 이미 올라간 파일들은 스크립트 수정만으로는 안 지워지므로
Obsidian REST API `DELETE /vault/$VAULT/$path`로 21개 직접 삭제.

---

## Blockers

없음. 파일 목록은 이전 sync 로그에서 그대로 추출했다.

---

## Next Steps

- 한글 reference 파일이 영문 원본(docs/agents/*.md)과 내용 차이가 생길 경우
  수동 갱신이 필요함 — 자동화 여부 검토

---

## Notes

Obsidian에 올라가는 파일 현황 (변경 후):

| 유형 | 파일 |
|------|------|
| 한글 참조 | `reference/agents-*.md`, `harness-guide.md` |
| 프로젝트 | SPEC, REVIEW, FEEDBACK, HARNESS_FEEDBACK.md |
| 자동 인덱스 | `_index.md`, `specs/`, `reviews/`, `feedback/` |
| Inbox / Devlog | 사람이 Obsidian에서 직접 작성 |
