# Git Branching Strategy

## Branch Model

```
main          ← production baseline. no direct commits. protected branch.
develop       ← integration branch. always in a runnable state.
  ├── feature/SPEC-001-user-auth
  ├── feature/SPEC-002-product-crud
  ├── fix/login-token-expiry
  └── docs/update-api-conventions
```

## Branch Naming

| Type | Format | Example |
|------|--------|---------|
| Feature development | `feature/SPEC-NNN-<kebab-name>` | `feature/SPEC-001-user-auth` |
| Bug fix | `fix/<kebab-description>` | `fix/login-token-expiry` |
| Documentation | `docs/<kebab-description>` | `docs/update-api-conventions` |
| Hotfix | `hotfix/v<version>-<description>` | `hotfix/v1.0.1-null-pointer` |
| Release | `release/v<major>.<minor>` | `release/v1.0` |

## Merge Rules

| From | To | Method | Condition |
|------|----|--------|-----------|
| `feature/*` | `develop` | Squash merge | PR required, Evaluator APPROVE |
| `fix/*` | `develop` | Squash merge | PR required |
| `docs/*` | `develop` | Squash merge | PR optional (simple docs can go direct) |
| `develop` | `main` | Merge commit | QA complete before deploy |
| `hotfix/*` | `main` + `develop` | Merge commit | Emergency fixes only |

**Why squash merge**: collapses WIP commits from feature branches into one, keeping `develop` history clean.

## Branch Workflows

### Feature development (normal case)

```bash
# update develop
git checkout develop
git pull origin develop

# create feature branch
git checkout -b feature/SPEC-001-user-auth

# commit after work
git add backend/app/api/v1/endpoints/users.py
git commit -m "feat(backend): implement user registration endpoint"

# rebase onto latest develop before PR (required)
git fetch origin
git rebase origin/develop

# create PR
gh pr create --base develop --title "feat(auth): SPEC-001 user auth [REVIEW]"
```

### Bug fix

```bash
git checkout -b fix/login-token-expiry develop
# after fix
git commit -m "fix(auth): correct JWT token expiry calculation"
gh pr create --base develop --title "fix(auth): correct JWT token expiry"
```

### Hotfix (production emergency)

```bash
git checkout -b hotfix/v1.0.1-null-pointer main
# after fix
git commit -m "fix(users): handle null pointer on empty profile"

# merge to both main and develop
gh pr create --base main --title "hotfix: null pointer in user profile"
# after merging to main
git checkout develop
git merge --no-ff hotfix/v1.0.1-null-pointer
git push origin develop
```

## GitHub Branch Protection Settings

Apply to `main`:
- Require pull request before merging: ✅
- Require approvals: 1
- Dismiss stale pull request approvals: ✅
- Require status checks to pass: ✅ (CI must pass)
- Include administrators: ✅

Apply to `develop`:
- Require pull request before merging: ✅ (optional for solo work)

## Branch Cleanup

Delete merged branches immediately:

```bash
# auto-delete after PR merge (enable in GitHub settings — recommended)
# manual delete
git branch -d feature/SPEC-001-user-auth
git push origin --delete feature/SPEC-001-user-auth
```
