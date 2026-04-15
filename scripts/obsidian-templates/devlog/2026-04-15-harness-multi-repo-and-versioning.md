---
date: 2026-04-15
spec: 
tags: [devlog, harness]
---

# Harness 멀티 레포 전략 / 자동화 / 버저닝 구축

---

## Summary

오늘 실질적인 개발 시작 전에 harness 자체를 운용할 수 있는 인프라를 정비했다.

- **멀티 레포 전략** 문서화 (`harness-guide.md` 섹션 12)
  - GitHub Template Repository 기반 파생 프로젝트 운용 패턴
  - `git remote add harness` + 선택적 파일 동기화 패턴
- **contribute-to-harness.sh** 신규 작성
  - HARNESS_FEEDBACK.md + LESSON 파일을 harness-template에 PR로 자동 전송
  - `--dry-run` 옵션, 중복 브랜치 방지, cleanup trap 포함
- **Evaluator 역할 업데이트** — SPEC 사이클 종료 시 스크립트 실행 단계 명시
- **harness 전체 점검** — Critical 이슈 없음, Minor 2개 발견 및 수정
  - developer-role.md 링크 텍스트 불일치 수정
  - MCP 설정은 현재 불필요 (curl 기반으로 충분)
- **버저닝 전략** 도입
  - `HARNESS_VERSION` (1.0.0) + `CHANGELOG.md` 신규 생성
  - semver 규칙 (patch/minor/major 기준 정의)
  - 특정 버전으로 롤백: `git checkout harness/v1.0.0 -- docs/ scripts/`
  - contribute-to-harness.sh가 버전 정보를 브랜치명과 PR 본문에 자동 포함

---

## Approach

### 자동화 범위 결정

harness → downstream 동기화(선택적 pull)는 이미 패턴이 있었고,  
반대 방향(downstream → harness PR)이 완전 수동이었다.  
스크립트 한 개로 클론 ~ PR까지 자동화하되, Agent(Evaluator)의 역할 정의에도 반영해  
"스크립트 실행"이 사이클의 공식 단계가 되도록 구성했다.

### 버저닝은 경량으로

Git 서브모듈이나 package.json 기반은 오버킬.  
`HARNESS_VERSION` 파일 한 줄 + Git 태그 + CHANGELOG로 충분하다고 판단.  
롤백도 결국 선택적 파일 체크아웃 패턴과 동일 — 태그를 대상으로 삼는 것만 다름.

---

## Blockers

없음.

---

## Next Steps

- GitHub에서 harness-template repo를 Template Repository로 설정
- `v1.0.0` 태그 push (`git tag v1.0.0 && git push origin --tags`)
- 첫 번째 파생 프로젝트 생성 후 `git remote add harness` 등록

---

## Notes

- 버저닝 롤백 명령: `git checkout harness/v1.0.0 -- docs/ scripts/ CLAUDE.md .env.example`
- contribute 스크립트 브랜치 형식: `contrib/from-<project>-v<version>-<date>`
- MCP(mcp-obsidian)는 vault 검색이 필요해질 때 도입 검토 (현재 불필요)
