#!/usr/bin/env bash
# scripts/release.sh
#
# 마지막 태그 이후 커밋을 분석해 버전을 자동 판단하고 릴리스합니다.
#
# 사용법:
#   bash scripts/release.sh           # git log 분석 후 자동 판단
#   bash scripts/release.sh minor     # 명시적 override (patch|minor|major)

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
OVERRIDE="${1:-}"

# --- 현재 버전 읽기 ---
VERSION_FILE="$REPO_ROOT/HARNESS_VERSION"
CURRENT="$(tr -d '[:space:]' < "$VERSION_FILE")"
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT"

# --- 마지막 태그 확인 ---
LAST_TAG="$(git describe --tags --abbrev=0 2>/dev/null || echo "")"

if [ -z "$LAST_TAG" ]; then
    echo "⚠️  이전 태그가 없습니다. 전체 커밋 히스토리를 분석합니다."
    LOG_RANGE="HEAD"
else
    echo "🔖 마지막 태그: $LAST_TAG"
    LOG_RANGE="${LAST_TAG}..HEAD"
fi

# --- 커밋 수집 ---
COMMITS="$(git log "$LOG_RANGE" --pretty=format:"%s" 2>/dev/null)"

if [ -z "$COMMITS" ]; then
    echo "ℹ️  ${LAST_TAG} 이후 새 커밋이 없습니다. 릴리스할 내용이 없습니다."
    exit 0
fi

echo ""
echo "📋 분석 대상 커밋 (${LAST_TAG:-처음}..HEAD):"
git log "$LOG_RANGE" --oneline
echo ""

# --- bump 자동 판단 ---
AUTO_BUMP="patch"

while IFS= read -r msg; do
    # BREAKING CHANGE → major
    if echo "$msg" | grep -qE '!:|BREAKING.CHANGE'; then
        AUTO_BUMP="major"
        break
    fi
    # feat → minor (major보다 낮은 경우만)
    if echo "$msg" | grep -qE '^feat(\(.+\))?:' && [ "$AUTO_BUMP" != "major" ]; then
        AUTO_BUMP="minor"
    fi
done <<< "$COMMITS"

# --- override 처리 ---
if [ -n "$OVERRIDE" ]; then
    if [[ ! "$OVERRIDE" =~ ^(patch|minor|major)$ ]]; then
        echo "❌ 유효하지 않은 bump 유형: $OVERRIDE (patch|minor|major)"
        exit 1
    fi
    BUMP="$OVERRIDE"
    echo "🔧 override 적용: $BUMP (자동 판단: $AUTO_BUMP)"
else
    BUMP="$AUTO_BUMP"
    echo "🤖 자동 판단: $BUMP"
fi

# --- 다음 버전 계산 ---
case "$BUMP" in
    major) NEXT="$((MAJOR + 1)).0.0" ;;
    minor) NEXT="${MAJOR}.$((MINOR + 1)).0" ;;
    patch) NEXT="${MAJOR}.${MINOR}.$((PATCH + 1))" ;;
esac

echo ""
echo "  현재 버전: v${CURRENT}"
echo "  다음 버전: v${NEXT}"
echo ""

# --- 사용자 확인 ---
read -rp "진행할까요? [y/N] " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "취소됨."
    exit 0
fi

# --- main 브랜치 확인 ---
CURRENT_BRANCH="$(git branch --show-current)"
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "⚠️  현재 브랜치: $CURRENT_BRANCH"
    read -rp "main이 아닙니다. 계속할까요? [y/N] " CONFIRM2
    [[ "$CONFIRM2" =~ ^[Yy]$ ]] || exit 0
fi

# --- CHANGELOG 항목 생성 ---
DATE="$(date +%Y-%m-%d)"
CHANGELOG_ENTRY="## [${NEXT}] — ${DATE}"$'\n'$'\n'

# 타입별로 커밋 분류
FEAT_LIST=""
FIX_LIST=""
DOCS_LIST=""
CHORE_LIST=""
OTHER_LIST=""

while IFS= read -r msg; do
    if echo "$msg" | grep -qE '^feat(\(.+\))?(!)?:'; then
        FEAT_LIST="${FEAT_LIST}"$'\n'"- ${msg}"
    elif echo "$msg" | grep -qE '^fix(\(.+\))?(!)?:'; then
        FIX_LIST="${FIX_LIST}"$'\n'"- ${msg}"
    elif echo "$msg" | grep -qE '^docs(\(.+\))?:'; then
        DOCS_LIST="${DOCS_LIST}"$'\n'"- ${msg}"
    elif echo "$msg" | grep -qE '^chore(\(.+\))?:'; then
        CHORE_LIST="${CHORE_LIST}"$'\n'"- ${msg}"
    else
        OTHER_LIST="${OTHER_LIST}"$'\n'"- ${msg}"
    fi
done <<< "$COMMITS"

[ -n "$FEAT_LIST" ]  && CHANGELOG_ENTRY="${CHANGELOG_ENTRY}### Features${FEAT_LIST}"$'\n\n'
[ -n "$FIX_LIST" ]   && CHANGELOG_ENTRY="${CHANGELOG_ENTRY}### Fixes${FIX_LIST}"$'\n\n'
[ -n "$DOCS_LIST" ]  && CHANGELOG_ENTRY="${CHANGELOG_ENTRY}### Docs${DOCS_LIST}"$'\n\n'
[ -n "$CHORE_LIST" ] && CHANGELOG_ENTRY="${CHANGELOG_ENTRY}### Chore${CHORE_LIST}"$'\n\n'
[ -n "$OTHER_LIST" ] && CHANGELOG_ENTRY="${CHANGELOG_ENTRY}### Other${OTHER_LIST}"$'\n\n'

CHANGELOG_ENTRY="${CHANGELOG_ENTRY}---"

# CHANGELOG.md에 삽입 (첫 번째 --- 아래에)
CHANGELOG_FILE="$REPO_ROOT/CHANGELOG.md"
TEMP_FILE="$(mktemp)"
awk -v entry="$CHANGELOG_ENTRY" '
    /^---$/ && !inserted {
        print
        print ""
        print entry
        inserted=1
        next
    }
    { print }
' "$CHANGELOG_FILE" > "$TEMP_FILE"
mv "$TEMP_FILE" "$CHANGELOG_FILE"

# --- HARNESS_VERSION 수정 ---
echo "$NEXT" > "$VERSION_FILE"

# --- 커밋 + 태그 + push ---
git add "$VERSION_FILE" "$CHANGELOG_FILE"
git commit -m "chore(release): v${NEXT}"
git tag "v${NEXT}"
git push origin "$(git branch --show-current)" --tags

echo ""
echo "✅ 릴리스 완료: v${NEXT}"
