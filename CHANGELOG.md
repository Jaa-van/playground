# Changelog

harness-template의 버전별 변경 내역입니다.  
형식: [Conventional Commits](docs/git/commit-conventions.md) 기반

---

## [1.0.0] — 2026-04-15

### 초기 릴리스

**Agent 시스템**
- Planner / Developer / Evaluator 3단계 Multi-Agent 워크플로우
- handoff-protocol: 파일 기반 세션 간 인수인계
- 각 역할별 rubric, 출력 형식, CLAUDE.md 업데이트 규칙 정의

**문서 체계**
- docs/architecture/, docs/backend/, docs/frontend/, docs/git/, docs/deployment/ 전체
- SPEC / REVIEW / FEEDBACK / DEVNOTES 파일 네이밍 규칙
- Conventional Commits 기반 커밋 메시지 규칙

**자동화**
- `scripts/setup-dev.sh` — 개발 환경 초기화, post-commit hook 설치
- `scripts/obsidian-sync.sh` — docs/ → Obsidian 단방향 동기화
- `scripts/obsidian-init.sh` — Obsidian vault 구조 초기화
- `scripts/contribute-to-harness.sh` — 개선사항을 harness-template에 PR 자동 생성
- post-commit hook — 커밋 시 Obsidian 자동 동기화

**Obsidian 연동**
- obsidian-templates/ 전체 (harness-guide, inbox, reference, devlog 등)
- 역방향 기획 흐름: Obsidian inbox → Planner 세션

**멀티 레포 전략**
- GitHub Template Repository 기반 파생 프로젝트 운용
- harness upstream remote 선택적 파일 동기화 패턴
- 버저닝 전략 (HARNESS_VERSION + CHANGELOG + Git 태그)

---

## 버전 번호 규칙

| 변경 종류 | 버전 bump |
|-----------|-----------|
| 오타, 링크 수정, 설명 보완 | patch `1.0.x` |
| 새 스크립트, 문서 섹션, 선택적 기능 추가 | minor `1.x.0` |
| agent 워크플로우, 파일명 규칙, 디렉토리 구조 변경 | major `x.0.0` |

릴리스 절차:
```bash
bash scripts/release.sh          # git log 분석 → 자동 판단
bash scripts/release.sh minor    # 명시적 override
```

`release.sh`가 자동으로 처리:
1. 마지막 태그 이후 커밋 분석 → patch/minor/major 판단
2. 사용자 확인
3. HARNESS_VERSION 수정 + CHANGELOG 항목 생성
4. 커밋 + 태그 + push
