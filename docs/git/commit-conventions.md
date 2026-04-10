# 커밋 메시지 규칙 (Conventional Commits)

## 형식

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

## type 목록

| type | 의미 | 버전 범프 |
|------|------|-----------|
| `feat` | 새 기능 | Minor (1.x.0) |
| `fix` | 버그 수정 | Patch (1.0.x) |
| `docs` | 문서만 변경 | 없음 |
| `style` | 코드 의미 변경 없는 포맷 수정 | 없음 |
| `refactor` | 버그 수정도 기능 추가도 아닌 코드 변경 | 없음 |
| `test` | 테스트 추가/수정 | 없음 |
| `chore` | 빌드 설정, 의존성 등 | 없음 |

## scope 목록 (이 프로젝트)

| scope | 적용 범위 |
|-------|-----------|
| `backend` | 백엔드 전반 |
| `frontend` | 프론트엔드 전반 |
| `auth` | 인증/인가 |
| `users` | 사용자 도메인 |
| `infra` | Docker, nginx 등 인프라 |
| `docs` | 문서 파일 |
| `specs` | SPEC 파일 |
| `reviews` | REVIEW 파일 |

## 예시

```bash
# 기능 추가
feat(backend): add user registration endpoint
feat(frontend): add login form component
feat(auth): implement JWT token refresh

# 버그 수정
fix(backend): handle duplicate email registration
fix(frontend): fix token not cleared on logout

# 문서
docs(specs): add SPEC-001 user authentication
docs(reviews): add REVIEW-001 user auth feedback
docs(backend): update api-conventions with pagination

# 테스트
test(backend): add integration tests for user endpoints
test(frontend): add unit tests for UserCard component

# 리팩터링
refactor(backend): extract user validation to service layer

# 인프라
chore(infra): update postgres image to 16-alpine
chore(backend): add psycopg2-binary to requirements
```

## Breaking Change

하위 호환성이 깨지는 변경은 `!` 또는 footer에 `BREAKING CHANGE:` 표기:

```bash
# 방법 1: !
feat(api)!: change user response schema to include nested address

# 방법 2: footer
feat(api): change user response schema

BREAKING CHANGE: user.address is now a nested object instead of flat fields
```

## 커밋 단위

- 하나의 커밋 = 하나의 논리적 변경
- WIP(Work In Progress) 커밋은 PR 전에 squash
- 테스트와 구현은 같은 커밋 또는 바로 다음 커밋에

```bash
# 좋은 예
git commit -m "feat(backend): add user registration endpoint"
git commit -m "test(backend): add tests for user registration"

# 나쁜 예
git commit -m "wip"
git commit -m "fix"
git commit -m "asdf"
```
