---
date: 2026-04-15
spec: 
tags: [devlog]
---

# Obsidian Devlog 디렉토리 구축 + 인코딩 수정

---

## Summary

- `scripts/obsidian-templates/devlog/` 폴더 신설
  - `_index.md` — 폴더 안내, 파일명 규칙 안내
  - `_template.md` — 로그 작성 템플릿 (무엇을/어떻게/막혔던 것/다음에 할 것/메모)
- `obsidian-init.sh` STATIC_FILES에 devlog 두 파일 추가
- `obsidian-templates/_index.md` 빠른 링크에 `개발 로그 →` 추가
- `regen_root_index`에 devlog 링크 추가
- 기존 devlog 파일(`devlog-2026-04-14.md`) 새 형식으로 변환 후 `devlog/` 폴더로 이동
- **한글 인코딩 깨짐 발견 및 수정**

---

## Approach

### 파일명 규칙
`YYYY-MM-DD-<작업요약>.md` 패턴 채택.
"devlog"로 시작하지 않아도 된다는 요구사항 반영 — 날짜 + 작업명으로만 구성.

### 기존 devlog 이전
원본 내용을 보존하면서 섹션 구조만 새 템플릿으로 재구성.

---

## Blockers

### 한글 인코딩 깨짐
bash 변수에 담긴 한글을 `--data-binary "$VAR"`로 curl에 넘겼더니 CP949로 인코딩돼
Obsidian에서 한글이 모두 깨졌다.

**해결**: Write 도구로 UTF-8 파일 생성 → `--data-binary @파일` 방식으로 업로드.

앞으로 한글이 포함된 내용을 Obsidian에 올릴 때는 반드시
1. 파일로 먼저 저장 (Write 도구 사용)
2. `@파일` 방식으로 curl 전송

`obsidian-sync.sh`의 `regen_*` 함수들은 이미 `mktemp` → `@파일` 방식이라 문제없음.

---

## Next Steps

- devlog 파일은 Obsidian에서 직접 작성하는 것이므로 git 추적 대상 아님
- `scripts/obsidian-templates/devlog/`에는 템플릿과 히스토리 보관용으로만 저장

---

## Notes

인코딩 문제 재현 조건:
- OS: Windows 11
- Shell: Git Bash
- 증상: bash 변수 `$VAR`에 한글 포함 시 CP949로 전송
- 안전한 패턴: `Write 도구` → `curl --data-binary @file`
