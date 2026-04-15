# Commit Message Conventions (Conventional Commits)

## Format

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

## Type List

| type | Meaning | Version bump |
|------|---------|-------------|
| `feat` | New feature | Minor (1.x.0) |
| `fix` | Bug fix | Patch (1.0.x) |
| `docs` | Documentation only | None |
| `style` | Format changes with no logic change | None |
| `refactor` | Code change that is neither a fix nor feature | None |
| `test` | Adding or modifying tests | None |
| `chore` | Build config, dependencies, etc. | None |

## Scope List (this project)

| scope | Coverage |
|-------|---------|
| `backend` | backend in general |
| `frontend` | frontend in general |
| `auth` | authentication/authorization |
| `users` | user domain |
| `infra` | Docker, nginx, infrastructure |
| `docs` | documentation files |
| `specs` | SPEC files |
| `reviews` | REVIEW files |

## Examples

```bash
# feature
feat(backend): add user registration endpoint
feat(frontend): add login form component
feat(auth): implement JWT token refresh

# bug fix
fix(backend): handle duplicate email registration
fix(frontend): fix token not cleared on logout

# documentation
docs(specs): add SPEC-001 user authentication
docs(reviews): add REVIEW-001 user auth feedback
docs(backend): update api-conventions with pagination

# tests
test(backend): add integration tests for user endpoints
test(frontend): add unit tests for UserCard component

# refactor
refactor(backend): extract user validation to service layer

# infrastructure
chore(infra): update postgres image to 16-alpine
chore(backend): add psycopg2-binary to requirements
```

## Breaking Changes

Breaking changes use `!` or `BREAKING CHANGE:` in footer:

```bash
# method 1: !
feat(api)!: change user response schema to include nested address

# method 2: footer
feat(api): change user response schema

BREAKING CHANGE: user.address is now a nested object instead of flat fields
```

## Commit Granularity

- One commit = one logical change
- WIP commits must be squashed before PR
- Tests and implementation in the same commit or immediately following

```bash
# good
git commit -m "feat(backend): add user registration endpoint"
git commit -m "test(backend): add tests for user registration"

# bad
git commit -m "wip"
git commit -m "fix"
git commit -m "asdf"
```
