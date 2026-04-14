#!/usr/bin/env bash
# scripts/obsidian-init.sh — Obsidian vault 초기 구조 및 템플릿 설정
#
# 사용법: bash scripts/obsidian-init.sh
#
# 수행 작업:
#   1. vault 내 폴더 구조 생성 (_index.md 업로드로 폴더 생성)
#   2. inbox/_template.md 등 정적 템플릿 업로드
#   3. harness-guide.md 업로드
#   4. obsidian-sync.sh 전체 동기화 (docs/ → vault)
#
# 필요 환경변수 (.env 또는 shell):
#   OBSIDIAN_API_KEY, OBSIDIAN_HOST, OBSIDIAN_VAULT

set -e

REPO_ROOT="$(git rev-parse --show-toplevel)"
TEMPLATES_DIR="$REPO_ROOT/scripts/obsidian-templates"

# .env 로드
if [ -f "$REPO_ROOT/.env" ]; then
    set -a
    # shellcheck disable=SC1091
    source "$REPO_ROOT/.env"
    set +a
fi

HOST="${OBSIDIAN_HOST:-https://127.0.0.1:27124}"
VAULT="${OBSIDIAN_VAULT:-platground}"
TOKEN="${OBSIDIAN_API_KEY:-}"

# ── 유틸리티 ──────────────────────────────────────────────────────────────

obsidian_alive() {
    curl -sk --max-time 3 -H "Authorization: Bearer $TOKEN" "$HOST/vault/" > /dev/null 2>&1
}

put_file() {  # put_file <local_abs_path> <vault_rel_path>
    curl -sk -X PUT \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: text/markdown; charset=utf-8" \
        --data-binary @"$1" \
        "$HOST/vault/$VAULT/$2" > /dev/null 2>&1
}

# ── 사전 검사 ─────────────────────────────────────────────────────────────

if [ -z "$TOKEN" ]; then
    echo "⚠️  OBSIDIAN_API_KEY가 설정되지 않았습니다. .env를 확인하세요." >&2
    exit 1
fi

if ! obsidian_alive; then
    echo "⚠️  Obsidian에 연결할 수 없습니다. Obsidian이 실행 중인지, Local REST API 플러그인이 활성화되어 있는지 확인하세요." >&2
    exit 1
fi

echo "🗂️  Obsidian vault 초기화 시작 (vault: $VAULT)"

# ── 1. 정적 템플릿 업로드 ─────────────────────────────────────────────────
# 아래 파일들은 git이 추적하는 templates에서 vault로 업로드됩니다.
# auto-generated 파일(_index.md for specs/reviews/feedback/root)은
# 이후 obsidian-sync.sh가 덮어씁니다.

STATIC_FILES=(
    "_index.md:_index.md"
    "inbox/_index.md:inbox/_index.md"
    "inbox/_template.md:inbox/_template.md"
    "agents/_index.md:agents/_index.md"
    "architecture/_index.md:architecture/_index.md"
    "specs/_index.md:specs/_index.md"
    "reviews/_index.md:reviews/_index.md"
    "feedback/_index.md:feedback/_index.md"
)

for entry in "${STATIC_FILES[@]}"; do
    local_rel="${entry%%:*}"
    vault_rel="${entry##*:}"
    local_abs="$TEMPLATES_DIR/$local_rel"

    if [ -f "$local_abs" ]; then
        put_file "$local_abs" "$vault_rel"
        printf "  ✓ %s\n" "$vault_rel"
    else
        printf "  ⚠ 템플릿 파일 없음: %s\n" "$local_abs" >&2
    fi
done

# ── 2. harness-guide.md 업로드 ────────────────────────────────────────────
HARNESS_GUIDE="$REPO_ROOT/docs/harness-guide.md"
if [ -f "$HARNESS_GUIDE" ]; then
    put_file "$HARNESS_GUIDE" "harness-guide.md"
    printf "  ✓ harness-guide.md\n"
else
    # docs/에 없으면 templates의 것 사용 (fallback)
    HARNESS_FALLBACK="$TEMPLATES_DIR/harness-guide.md"
    if [ -f "$HARNESS_FALLBACK" ]; then
        put_file "$HARNESS_FALLBACK" "harness-guide.md"
        printf "  ✓ harness-guide.md (templates fallback)\n"
    fi
fi

# ── 3. docs/ 전체 동기화 (SPEC, REVIEW, FEEDBACK 등) ────────────────────
echo ""
echo "🔄 docs/ → Obsidian 동기화..."
SYNC_SCRIPT="$REPO_ROOT/scripts/obsidian-sync.sh"
if [ -x "$SYNC_SCRIPT" ]; then
    bash "$SYNC_SCRIPT"
else
    echo "  ⚠ obsidian-sync.sh를 찾을 수 없습니다." >&2
fi

echo ""
echo "✅ Obsidian 초기화 완료!"
echo "   Obsidian에서 '$VAULT/' 폴더를 확인하세요."
