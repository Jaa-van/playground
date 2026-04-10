# Git 브랜치 전략

## 브랜치 모델

```
main          ← 운영 배포 기준. 직접 커밋 금지. 보호 브랜치.
develop       ← 통합 브랜치. 항상 실행 가능한 상태 유지.
  ├── feature/SPEC-001-user-auth
  ├── feature/SPEC-002-product-crud
  ├── fix/login-token-expiry
  └── docs/update-api-conventions
```

## 브랜치 네이밍

| 유형 | 형식 | 예시 |
|------|------|------|
| 기능 개발 | `feature/SPEC-NNN-<kebab-name>` | `feature/SPEC-001-user-auth` |
| 버그 수정 | `fix/<kebab-description>` | `fix/login-token-expiry` |
| 문서 업데이트 | `docs/<kebab-description>` | `docs/update-api-conventions` |
| 핫픽스 | `hotfix/v<version>-<description>` | `hotfix/v1.0.1-null-pointer` |
| 릴리즈 | `release/v<major>.<minor>` | `release/v1.0` |

## 머지 규칙

| From | To | 방법 | 조건 |
|------|-----|------|------|
| `feature/*` | `develop` | Squash merge | PR 필수, 평가자 APPROVE |
| `fix/*` | `develop` | Squash merge | PR 필수 |
| `docs/*` | `develop` | Squash merge | PR 선택 (단순 문서는 직접 가능) |
| `develop` | `main` | Merge commit | 배포 전 QA 완료 |
| `hotfix/*` | `main` + `develop` | Merge commit | 긴급 수정 시만 |

**Squash merge를 사용하는 이유**: feature 브랜치의 WIP 커밋들을 하나로 합쳐 `develop` 히스토리를 깔끔하게 유지.

## 브랜치 작업 흐름

### 기능 개발 (일반 케이스)

```bash
# develop 최신화
git checkout develop
git pull origin develop

# feature 브랜치 생성
git checkout -b feature/SPEC-001-user-auth

# 작업 후 커밋
git add backend/app/api/v1/endpoints/users.py
git commit -m "feat(backend): implement user registration endpoint"

# develop 최신화 후 rebase (머지 전 필수)
git fetch origin
git rebase origin/develop

# PR 생성
gh pr create --base develop --title "feat(auth): SPEC-001 user auth [REVIEW]"
```

### 버그 수정

```bash
git checkout -b fix/login-token-expiry develop
# 수정 후
git commit -m "fix(auth): correct JWT token expiry calculation"
gh pr create --base develop --title "fix(auth): correct JWT token expiry"
```

### 핫픽스 (운영 긴급 수정)

```bash
git checkout -b hotfix/v1.0.1-null-pointer main
# 수정 후
git commit -m "fix(users): handle null pointer on empty profile"

# main과 develop 양쪽 머지
gh pr create --base main --title "hotfix: null pointer in user profile"
# main 머지 후
git checkout develop
git merge --no-ff hotfix/v1.0.1-null-pointer
git push origin develop
```

## GitHub 브랜치 보호 설정

`main` 브랜치에 적용:
- Require pull request before merging: ✅
- Require approvals: 1
- Dismiss stale pull request approvals: ✅
- Require status checks to pass: ✅ (CI 통과)
- Include administrators: ✅

`develop` 브랜치에 적용:
- Require pull request before merging: ✅ (혼자 작업 시 선택)

## 브랜치 정리

머지된 브랜치는 즉시 삭제:

```bash
# PR 머지 후 자동 삭제 (GitHub 설정에서 활성화 권장)
# 수동 삭제
git branch -d feature/SPEC-001-user-auth
git push origin --delete feature/SPEC-001-user-auth
```
