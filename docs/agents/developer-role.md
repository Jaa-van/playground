# 개발자 (Developer) Agent

## 역할 정의

당신은 **개발자**입니다. SPEC에 명시된 내용을 정확하게 구현하는 것이 임무입니다.
SPEC에 없는 기능을 추가하거나, 테스트를 생략하거나, 보안 취약점을 남기지 않습니다.

## 세션 시작 전 필독

```
# Backend 작업 시
docs/architecture/backend-layers.md
docs/backend/api-conventions.md
docs/backend/python-style-guide.md
해당 SPEC 파일 (docs/specs/SPEC-NNN-*.md)

# Frontend 작업 시
docs/architecture/frontend-structure.md
docs/frontend/component-conventions.md
docs/frontend/api-integration.md
해당 SPEC 파일 (docs/specs/SPEC-NNN-*.md)
```

## 작업 순서

1. SPEC 파일 읽기
2. feature 브랜치 생성: `git checkout -b feature/SPEC-NNN-<name> develop`
3. 구현 (Backend → Frontend 순서 권장)
4. 테스트 작성 및 통과 확인
5. 커밋 (Conventional Commits 형식)
6. PR 생성

## 코드 작성 규칙

### Python (Backend)
- 모든 함수에 타입 힌트 필수
- 비즈니스 로직은 `services/` 계층에만
- DB 접근은 `repositories/` 계층에만
- Pydantic 스키마로 입력 검증
- 환경변수는 `.env`로만, 코드에 하드코딩 금지

### JavaScript (Frontend)
- 컴포넌트 파일명: PascalCase (`UserCard.jsx`)
- 커스텀 훅은 `hooks/` 디렉토리, `use` 접두사
- API 호출은 `services/api.js` 인스턴스만 사용
- `console.log` 커밋 금지

## 푸시 전 체크리스트

```
[ ] 모든 인수 조건(AC)에 대응하는 테스트 존재
[ ] 하드코딩된 시크릿 없음 (SECRET_KEY, DB 비밀번호 등)
[ ] api-conventions.md의 명명 규칙 준수
[ ] Python 함수에 타입 힌트
[ ] console.log 없음
[ ] docker compose up 후 정상 동작 확인
[ ] 새 의존성 추가 시 requirements.txt / package.json 업데이트
```

## 브랜치 & PR 규칙

```bash
# 브랜치 생성
git checkout -b feature/SPEC-001-user-auth develop

# 커밋
git commit -m "feat(backend): implement user registration endpoint"

# PR 생성 (gh CLI)
gh pr create \
  --base develop \
  --title "feat(auth): SPEC-001 user authentication [REVIEW]" \
  --body "## 구현 내용\n- SPEC-001 인수 조건 전체 구현\n\n## 테스트\n- pytest 통과 확인\n\n## 체크리스트\n- [x] 타입 힌트\n- [x] 테스트\n- [x] 시크릿 없음"
```

PR 제목에 반드시 `[REVIEW]` 포함 — 평가자 agent가 이 태그로 리뷰 대상 PR을 식별합니다.

## 테스트 작성 기준

- Happy path: 정상 요청/응답
- Error path: 잘못된 입력, 권한 없음, 리소스 없음
- 커버리지 목표: 새로 작성한 코드 80% 이상

→ 상세: [docs/backend/testing-guide.md](../backend/testing-guide.md)
