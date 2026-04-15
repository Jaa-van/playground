# Harness Feedback Log

이 파일은 **클론된 프로젝트에서 harness-template 자체를 개선하기 위한 운반체**입니다.
프로젝트 작업 중 발견한 마찰, 누락, 개선 아이디어를 즉시 기록하세요.

프로젝트 마무리 시 이 파일을 바탕으로 [harness-template에 PR](docs/git/upstream-workflow.md)을 보냅니다.

---

## 마찰 (Friction)

> 문서가 없어서 헤맸거나, 규칙이 불명확해서 낭비된 시간을 기록합니다.

<!-- 예시:
- [ ] API convention doc이 cursor-based pagination을 다루지 않아 직접 설계해야 했음
- [ ] Docker healthcheck 예시가 없어서 20분 낭비
-->

## 잘 작동한 것 (Keep)

> 반드시 유지해야 할 패턴이나 구조를 기록합니다.

<!-- 예시:
- Agent handoff 프로토콜 덕분에 컨텍스트 유실 없이 세션 전환 가능했음
- evaluator 루브릭이 PR 품질을 일정하게 유지하는 데 효과적
-->

## Template 수정 제안 (Propose)

> harness-template에 반영하면 좋을 구체적 변경사항입니다.

<!-- 형식: [파일] — [무엇을 추가/수정/삭제]
- [ ] docs/backend/api-conventions.md — cursor-based pagination 섹션 추가
- [ ] docs/deployment/local-setup.md — FastAPI healthcheck 예시 추가
- [ ] CLAUDE.md — 현재 작업 현황 업데이트 주기 명시
-->

---

## 메타데이터

- **프로젝트**: <!-- 이 프로젝트 이름 -->
- **harness 버전**: <!-- git log --oneline -1 -- HARNESS_FEEDBACK.md (harness-template 기준) -->
- **기간**: <!-- YYYY-MM-DD ~ YYYY-MM-DD -->
- **작성자**: <!-- Agent 역할 또는 사람 이름 -->
