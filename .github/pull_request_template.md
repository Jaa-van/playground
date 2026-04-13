> **PR 제목에 반드시 `[REVIEW]` 포함** — 평가자 agent가 이 태그로 리뷰 대상 PR을 식별합니다.
> 예시: `feat(backend): SPEC-001 user auth [REVIEW]`

## 관련 SPEC

- SPEC-NNN: [기능명](../docs/specs/SPEC-NNN-<name>.md)

## 구현 내용

- 

## 테스트 방법

```bash
docker compose exec backend pytest tests/ -v
```

## 체크리스트

- [ ] 모든 인수 조건(AC) 구현 완료
- [ ] 테스트 작성 및 통과
- [ ] 하드코딩된 시크릿 없음
- [ ] api-conventions.md 준수
- [ ] `docker compose up` 후 정상 동작 확인
