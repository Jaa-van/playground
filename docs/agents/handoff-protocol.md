# Handoff Protocol

## Overview

Agent handoffs are **file-based**. There is no session chaining — committed files in the git repository are the sole handoff mechanism. Any agent must be able to resume work from files alone, without context from previous sessions.

## Full Flow

```
User requirement
      ↓
[Planner session]
  ① Read docs/feedback/LESSONS.md (latest 5 entries)
  ② Read docs/feedback/FEEDBACK-NNN-*.md (if REJECT received)
  ③ Read docs/feedback/DEVNOTES-NNN-*.md (from previous cycle)
      ↓ Create docs/specs/SPEC-NNN-<name>.md + update LESSONS.md + commit to develop
[Developer session]
      ↓ feature/SPEC-NNN-<name> branch → open PR ([REVIEW] tag)
[Evaluator session]
      ↓
  ┌── APPROVE ────────────────────────────────────────────────┐
  │   Merge PR to develop                                     │
  │   Developer: create DEVNOTES-NNN + commit to develop      │
  └───────────────────────────────────────────────────────────┘
  ┌── REQUEST_CHANGES ─────────────────────────────────────────┐
  │   Commit REVIEW file → Developer reworks → re-tag [REVIEW-2]│
  │   (max 3 cycles, then REJECT path)                         │
  └───────────────────────────────────────────────────────────┘
  ┌── REJECT ──────────────────────────────────────────────────┐
  │   Create FEEDBACK-NNN + commit directly to develop          │
  │   Close PR                                                  │
  │   Planner: read FEEDBACK in next session, redesign SPEC     │
  └───────────────────────────────────────────────────────────┘
      ↓
[Repeat with next SPEC]
```

## Handoff Artifact Rules

### Planner → Developer

| Item | Rule |
|------|------|
| File location | `docs/specs/SPEC-NNN-<kebab-name>.md` |
| Branch | Commit directly to `develop` (docs files only) |
| Commit message | `docs(specs): add SPEC-NNN <feature name>` |
| Completion signal | SPEC file exists on `develop` branch |

The Developer must be able to start implementation by reading the SPEC alone.
If questions arise, the SPEC is incomplete → Planner must rework it.

### Developer → Evaluator

| Item | Rule |
|------|------|
| PR branch | `feature/SPEC-NNN-<name>` → `develop` |
| PR title | `feat(<scope>): SPEC-NNN <description> [REVIEW]` |
| PR body required | implementation summary, how to test, checklist |
| Completion signal | PR title contains `[REVIEW]` tag |

Evaluator identifies review targets by the `[REVIEW]` tag in PR titles.

### Evaluator → Team

| Item | Rule |
|------|------|
| File location | `docs/reviews/REVIEW-NNN-<name>.md` |
| Branch | Commit to feature branch (so it is included in the PR) |
| Commit message | `docs(reviews): add REVIEW-NNN <feature name>` |
| On APPROVE | Merge PR to `develop` |
| On REQUEST_CHANGES | Commit REVIEW file, ask Developer to rework |
| On REJECT | Create FEEDBACK file + close PR, ask Planner to revisit SPEC |

### Evaluator → Planner (on REJECT)

| Item | Rule |
|------|------|
| File location | `docs/feedback/FEEDBACK-NNN-<kebab-name>.md` |
| Branch | Commit directly to `develop` |
| Commit message | `docs(feedback): add FEEDBACK-NNN <feature name>` |
| Completion signal | FEEDBACK file on develop + PR closed |

### Developer → Planner (after merge)

| Item | Rule |
|------|------|
| File location | `docs/feedback/DEVNOTES-NNN-<kebab-name>.md` |
| Branch | Commit directly to `develop` |
| Commit message | `docs(feedback): add DEVNOTES-NNN <feature name>` |
| Completion signal | DEVNOTES file on develop |
| If no issues | Create the file anyway; write only "No SPEC quality issues." |

## File Naming Rules

```
SPEC number and REVIEW number must match.
SPEC-001-user-auth.md  ↔  REVIEW-001-user-auth.md

<name> part is kebab-case (lowercase + hyphens)
Examples:
  SPEC-001-user-auth.md
  SPEC-002-product-crud.md
  SPEC-003-order-checkout.md
```

## Rework Cycle

```
REQUEST_CHANGES received
      ↓
Developer: read REVIEW file → fix → commit
      ↓
Re-tag PR title with [REVIEW] (e.g., "[REVIEW-2]")
      ↓
Evaluator: re-review → APPROVE or REQUEST_CHANGES again
```

After 3 REQUEST_CHANGES cycles with no resolution → REJECT → revisit SPEC.

## Reading Recent History (git log)

Each agent reads recent history at session start to understand current workflow state.
Commit messages follow Conventional Commits format, so `feat/fix/docs` prefixes quickly show what happened.

### All agents: recent develop history

```bash
git log develop --oneline --decorate -20
```

Interpretation guide:
- `docs(specs): add SPEC-NNN` — planning done, awaiting development
- `feat(...)` — implementation commit
- `docs(reviews): add REVIEW-NNN` — review complete
- `docs(feedback): add FEEDBACK-NNN` — REJECT occurred, Planner rework needed
- `docs(feedback): add DEVNOTES-NNN` — merge complete, developer notes available

### Planner only

```bash
# find latest SPEC number (determine next number)
git log develop --oneline --grep="docs(specs)" -5

# check recent REJECT history
git log develop --oneline --grep="FEEDBACK" -5
```

### Developer only

```bash
# my commits on feature branch vs develop
git log develop..HEAD --oneline

# when reworking after REQUEST_CHANGES: see what reviews exist
git log --oneline --grep="REVIEW-NNN" --all
```

### Evaluator only

```bash
# commits on PR branch (understand implementation intent)
git log develop..<feature-branch> --oneline

# check if prior review cycles exist for this SPEC
git log --oneline --all --grep="SPEC-NNN"
```

## Current Status Check

```bash
# PRs awaiting review
gh pr list --base develop

# latest SPEC/REVIEW numbers
ls docs/specs/
ls docs/reviews/

# unresolved feedback
ls docs/feedback/

# latest lessons
head -50 docs/feedback/LESSONS.md
```
