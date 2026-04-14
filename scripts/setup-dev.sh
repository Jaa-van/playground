#!/usr/bin/env bash
# scripts/setup-dev.sh — 개발 환경 초기 설정
#
# 사용법: bash scripts/setup-dev.sh
# clone 후 최초 1회 실행

set -e

REPO_ROOT="$(git rev-parse --show-toplevel)"

echo "🔧 platground 개발 환경 설정 중..."

# ── 1. git hook 설치 ──────────────────────────────────────────────────────
HOOK_SRC="$REPO_ROOT/.githooks/post-commit"
HOOK_DST="$REPO_ROOT/.git/hooks/post-commit"

if [ -f "$HOOK_SRC" ]; then
    cp "$HOOK_SRC" "$HOOK_DST"
    chmod +x "$HOOK_DST"
    echo "✓ git post-commit hook 설치 완료"
else
    echo "⚠️  .githooks/post-commit 파일을 찾을 수 없습니다."
fi

# ── 2. .env 생성 ──────────────────────────────────────────────────────────
if [ ! -f "$REPO_ROOT/.env" ]; then
    cp "$REPO_ROOT/.env.example" "$REPO_ROOT/.env"
    echo "✓ .env 생성 완료"
    echo "  → SECRET_KEY와 OBSIDIAN_API_KEY를 직접 설정해주세요: $REPO_ROOT/.env"
else
    echo "✓ .env 이미 존재 (스킵)"
fi

# ── 3. scripts 실행 권한 ──────────────────────────────────────────────────
chmod +x "$REPO_ROOT/scripts/"*.sh 2>/dev/null || true
echo "✓ scripts/*.sh 실행 권한 설정 완료"

# ── 4. Obsidian vault 초기화 (연결되어 있을 때만) ────────────────────────
echo ""
INIT_SCRIPT="$REPO_ROOT/scripts/obsidian-init.sh"

# .env 로드해서 Obsidian 연결 여부 확인
if [ -f "$REPO_ROOT/.env" ]; then
    set -a
    # shellcheck disable=SC1091
    source "$REPO_ROOT/.env"
    set +a
fi

if [ -n "${OBSIDIAN_API_KEY:-}" ] && \
   curl -sk --max-time 3 \
     -H "Authorization: Bearer $OBSIDIAN_API_KEY" \
     "${OBSIDIAN_HOST:-https://127.0.0.1:27124}/vault/" > /dev/null 2>&1; then
    echo "🔗 Obsidian 연결 감지 — vault 초기화 실행..."
    bash "$INIT_SCRIPT"
else
    echo "ℹ️  Obsidian 미연결 — vault 초기화 스킵"
    echo "   나중에 연결 후: bash scripts/obsidian-init.sh"
fi

echo ""
echo "✅ 설정 완료! 다음 단계:"
echo "   1. .env 파일에서 SECRET_KEY 변경"
echo "   2. Obsidian 미연결이었다면 OBSIDIAN_API_KEY 설정 후:"
echo "      bash scripts/obsidian-init.sh"
echo "   3. cd infrastructure && docker compose up --build"
