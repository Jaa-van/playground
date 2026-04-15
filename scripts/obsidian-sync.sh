#!/usr/bin/env bash
# scripts/obsidian-sync.sh — docs/ → Obsidian 동기화
#
# 사용법:
#   scripts/obsidian-sync.sh                           # 전체 동기화
#   scripts/obsidian-sync.sh docs/specs/SPEC-001-foo.md  # 특정 파일만
#
# 필요 환경변수 (.env 또는 shell):
#   OBSIDIAN_API_KEY  — Obsidian Local REST API 키 (필수)
#   OBSIDIAN_HOST     — Obsidian 호스트 (기본값: https://127.0.0.1:27124)
#   OBSIDIAN_VAULT    — vault 내 폴더명 (기본값: harness-template)

REPO_ROOT="$(git rev-parse --show-toplevel)"

# .env 로드 (있을 경우)
if [ -f "$REPO_ROOT/.env" ]; then
    set -a
    # shellcheck disable=SC1091
    source "$REPO_ROOT/.env"
    set +a
fi

HOST="${OBSIDIAN_HOST:-https://127.0.0.1:27124}"
VAULT="${OBSIDIAN_VAULT:-harness-template}"

if [ -z "${OBSIDIAN_API_KEY:-}" ]; then
    echo "⚠️  OBSIDIAN_API_KEY 환경변수가 설정되지 않았습니다. .env를 확인하세요." >&2
    exit 0  # Obsidian 미설정 환경에서는 조용히 종료
fi

TOKEN="$OBSIDIAN_API_KEY"

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

put_content() {  # put_content <tmp_file> <vault_rel_path>
    put_file "$1" "$2"
}

# ── 파싱 헬퍼 ────────────────────────────────────────────────────────────

# SPEC-001-foo-bar.md → 001
extract_num() {
    basename "$1" .md | sed 's/[A-Z_]*-//' | cut -d'-' -f1
}

# SPEC-001-foo-bar.md → foo-bar
spec_slug() {
    basename "$1" .md | sed 's/SPEC-[0-9]*-//'
}

# REVIEW-001-foo-bar.md → foo-bar
review_slug() {
    basename "$1" .md | sed 's/REVIEW-[0-9]*-//'
}

# SPEC 파일 첫 번째 헤딩에서 제목 추출
# "# SPEC-001: 사용자 인증" → "사용자 인증"
spec_title() {
    local t
    t=$(grep -m1 "^# " "$1" 2>/dev/null \
        | sed 's/^# SPEC-[0-9]*: //' \
        | sed 's/^# //' \
        | tr -d '\r')
    echo "${t:-$(spec_slug "$1")}"
}

# REVIEW 파일에서 결정 추출
# "## 결정: APPROVE" → "APPROVE"
review_decision() {
    grep -m1 "^## 결정:" "$1" 2>/dev/null \
        | sed 's/## 결정: *//' \
        | tr -d '\r '
}

# REVIEW 파일에서 합계 점수 추출  → "22/25"
review_score() {
    grep -m1 "합계" "$1" 2>/dev/null \
        | grep -oE '[0-9]+/25' \
        | head -1 \
        || echo "-"
}

# 결정 → 이모지 포함 표시
decision_label() {
    case "$1" in
        APPROVE)          echo "✅ APPROVE" ;;
        REQUEST_CHANGES)  echo "🔄 재작업중" ;;
        REJECT)           echo "❌ REJECT" ;;
        *)                echo "📋 리뷰 대기" ;;
    esac
}

# 파일의 마지막 커밋 날짜
file_date() {  # file_date <docs/relative/path>
    git -C "$REPO_ROOT" log -1 --format="%ad" --date=short -- "$1" 2>/dev/null || echo "-"
}

# SPEC 번호에 해당하는 REVIEW 결과 → 라벨
spec_review_status() {  # spec_review_status <num e.g. 001>
    local rf
    rf=$(find "$REPO_ROOT/docs/reviews" -name "REVIEW-$1-*.md" 2>/dev/null | sort | tail -1)
    if [ -z "$rf" ]; then
        echo "📋 리뷰 대기"
    else
        decision_label "$(review_decision "$rf")"
    fi
}

# ── 인덱스 재생성 ─────────────────────────────────────────────────────────

regen_specs_index() {
    local tmp
    tmp=$(mktemp /tmp/obs-XXXXXX.md)
    {
        printf "# SPEC 목록\n\n"
        printf "| SPEC | 기능명 | 상태 | 날짜 |\n"
        printf "|------|--------|------|------|\n"

        for f in "$REPO_ROOT/docs/specs"/SPEC-*.md; do
            [ -f "$f" ] || continue
            local num slug title date status
            num=$(extract_num "$f")
            slug=$(spec_slug "$f")
            title=$(spec_title "$f")
            date=$(file_date "docs/specs/$(basename "$f")")
            status=$(spec_review_status "$num")
            printf "| [[harness-template/specs/SPEC-%s-%s|SPEC-%s]] | %s | %s | %s |\n" \
                "$num" "$slug" "$num" "$title" "$status" "$date"
        done

        printf "\n---\n> 자동 생성: git post-commit hook\n"
    } > "$tmp"
    put_content "$tmp" "specs/_index.md"
    rm -f "$tmp"
    printf "  ✓ specs/_index.md 갱신\n"
}

regen_reviews_index() {
    local tmp
    tmp=$(mktemp /tmp/obs-XXXXXX.md)
    {
        printf "# REVIEW 이력\n\n"
        printf "| REVIEW | 기능명 | 결정 | 점수 | 날짜 |\n"
        printf "|--------|--------|------|------|------|\n"

        for f in "$REPO_ROOT/docs/reviews"/REVIEW-*.md; do
            [ -f "$f" ] || continue
            local num slug decision score date
            num=$(extract_num "$f")
            slug=$(review_slug "$f")
            decision=$(review_decision "$f")
            score=$(review_score "$f")
            date=$(file_date "docs/reviews/$(basename "$f")")
            printf "| [[harness-template/reviews/REVIEW-%s-%s|REVIEW-%s]] | %s | %s | %s | %s |\n" \
                "$num" "$slug" "$num" "$slug" "$(decision_label "$decision")" "$score" "$date"
        done

        printf "\n---\n> 자동 생성: git post-commit hook\n"
    } > "$tmp"
    put_content "$tmp" "reviews/_index.md"
    rm -f "$tmp"
    printf "  ✓ reviews/_index.md 갱신\n"
}

regen_feedback_index() {
    local tmp
    tmp=$(mktemp /tmp/obs-XXXXXX.md)
    {
        printf "# 피드백 & 개발 노트\n\n"

        printf "## FEEDBACK (REJECT 사유)\n\n"
        local has_fb=0
        for f in "$REPO_ROOT/docs/feedback"/FEEDBACK-*.md; do
            [ -f "$f" ] || continue
            has_fb=1
            local bname num date
            bname=$(basename "$f" .md)
            num=$(extract_num "$f")
            date=$(file_date "docs/feedback/$(basename "$f")")
            printf '%s\n' "- [[harness-template/feedback/$bname|$bname]] — SPEC-$num ($date)"
        done
        [ $has_fb -eq 0 ] && printf "*(없음)*\n"

        printf "\n## DEVNOTES (구현 노트)\n\n"
        local has_dn=0
        for f in "$REPO_ROOT/docs/feedback"/DEVNOTES-*.md; do
            [ -f "$f" ] || continue
            has_dn=1
            local bname num date
            bname=$(basename "$f" .md)
            num=$(extract_num "$f")
            date=$(file_date "docs/feedback/$(basename "$f")")
            printf '%s\n' "- [[harness-template/feedback/$bname|$bname]] — SPEC-$num ($date)"
        done
        [ $has_dn -eq 0 ] && printf "*(없음)*\n"

        printf "\n## 누적 교훈\n\n"
        printf "[[harness-template/feedback/LESSONS|LESSONS.md 보기]]\n"

        printf "\n---\n> 자동 생성: git post-commit hook\n"
    } > "$tmp"
    put_content "$tmp" "feedback/_index.md"
    rm -f "$tmp"
    printf "  ✓ feedback/_index.md 갱신\n"
}

regen_root_index() {
    local tmp
    tmp=$(mktemp /tmp/obs-XXXXXX.md)

    # CLAUDE.md에서 현재 상태 읽기 (영문 필드명 기준)
    local step next_action updated
    step=$(grep "\*\*Stage\*\*" "$REPO_ROOT/CLAUDE.md" 2>/dev/null \
        | sed 's/.*\*\*Stage\*\*: *//' | head -1 || true)
    next_action=$(grep "\*\*Next action\*\*" "$REPO_ROOT/CLAUDE.md" 2>/dev/null \
        | sed 's/.*\*\*Next action\*\*: *//' | head -1 || true)
    step="${step:-초기 설정 완료}"
    next_action="${next_action:-기획자 → SPEC-001 작성}"
    updated=$(date +%Y-%m-%d)

    # 파일 수 카운트
    local spec_cnt review_cnt fb_cnt
    spec_cnt=$(find "$REPO_ROOT/docs/specs" -name "SPEC-*.md" 2>/dev/null | wc -l | tr -d ' ')
    review_cnt=$(find "$REPO_ROOT/docs/reviews" -name "REVIEW-*.md" 2>/dev/null | wc -l | tr -d ' ')
    fb_cnt=$(find "$REPO_ROOT/docs/feedback" \( -name "FEEDBACK-*.md" -o -name "DEVNOTES-*.md" \) 2>/dev/null | wc -l | tr -d ' ')

    {
        printf "# harness-template — 프로젝트 허브\n\n"
        printf "> 마지막 동기화: %s\n\n" "$updated"

        printf "## 현재 상태\n\n"
        printf "| 항목 | 내용 |\n"
        printf "|------|------|\n"
        printf "| 단계 | %s |\n" "$step"
        printf "| 다음 액션 | %s |\n" "$next_action"

        printf "\n## 진행 현황\n\n"
        printf "| 유형 | 건수 |\n"
        printf "|------|------|\n"
        printf "| SPEC | %s |\n" "$spec_cnt"
        printf "| REVIEW | %s |\n" "$review_cnt"
        printf "| FEEDBACK / DEVNOTES | %s |\n" "$fb_cnt"

        printf "\n## 빠른 링크\n\n"
        echo "- [[harness-template/overview|프로젝트 설계 개요]]"
        echo "- [[harness-template/specs/_index|SPEC 목록 →]]"
        echo "- [[harness-template/reviews/_index|REVIEW 이력 →]]"
        echo "- [[harness-template/feedback/_index|피드백 & 노트 →]]"
        echo "- [[harness-template/architecture/_index|아키텍처]]"
        echo "- [[harness-template/agents/_index|Agent 역할]]"
        echo "- [[harness-template/inbox/_index|Inbox (기획 메모) →]]"
        echo "- [[harness-template/devlog/_index|개발 로그 →]]"
        echo "- [[harness-template/harness-guide|하네스 완전 설명서]]"

        printf "\n---\n"
        printf "*이 노트는 git post-commit hook이 자동으로 갱신합니다.*\n"
    } > "$tmp"
    put_content "$tmp" "_index.md"
    rm -f "$tmp"
    printf "  ✓ _index.md (허브) 갱신\n"
}

# ── 파일별 처리 ───────────────────────────────────────────────────────────

sync_file() {  # sync_file <docs/...> (repo root 기준 상대경로)
    local rel="$1"
    local abs="$REPO_ROOT/$rel"
    [ -f "$abs" ] || return 0

    case "$rel" in
        docs/specs/SPEC-*.md)
            put_file "$abs" "specs/$(basename "$abs")"
            printf "  ↑ %s\n" "$rel"
            regen_specs_index
            regen_root_index
            ;;
        docs/reviews/REVIEW-*.md)
            put_file "$abs" "reviews/$(basename "$abs")"
            printf "  ↑ %s\n" "$rel"
            regen_reviews_index
            regen_specs_index   # SPEC 상태도 갱신 (리뷰 결과 반영)
            regen_root_index
            ;;
        docs/feedback/FEEDBACK-*.md|docs/feedback/DEVNOTES-*.md)
            put_file "$abs" "feedback/$(basename "$abs")"
            printf "  ↑ %s\n" "$rel"
            regen_feedback_index
            regen_root_index
            ;;
        docs/feedback/LESSONS.md)
            put_file "$abs" "feedback/LESSONS.md"
            printf "  ↑ %s\n" "$rel"
            regen_feedback_index
            ;;
        HARNESS_FEEDBACK.md)
            put_file "$abs" "HARNESS_FEEDBACK.md"
            printf "  ↑ HARNESS_FEEDBACK.md\n"
            ;;
    esac
}

full_sync() {
    printf "🔄 전체 동기화 시작...\n"

    if [ -f "$REPO_ROOT/HARNESS_FEEDBACK.md" ]; then
        put_file "$REPO_ROOT/HARNESS_FEEDBACK.md" "HARNESS_FEEDBACK.md"
        printf "  ↑ HARNESS_FEEDBACK.md\n"
    fi

    # ── 한글 참조 문서 (templates/reference → Obsidian reference/) ──────────
    local templates_dir="$REPO_ROOT/scripts/obsidian-templates"
    for f in "$templates_dir/reference"/*.md; do
        [ -f "$f" ] || continue
        put_file "$f" "reference/$(basename "$f")"
        printf "  ↑ scripts/obsidian-templates/reference/%s\n" "$(basename "$f")"
    done
    if [ -f "$templates_dir/harness-guide.md" ]; then
        put_file "$templates_dir/harness-guide.md" "harness-guide.md"
        printf "  ↑ scripts/obsidian-templates/harness-guide.md\n"
    fi

    # ── project docs (SPEC, REVIEW, FEEDBACK) ────────────────────────────
    for f in "$REPO_ROOT/docs/specs"/SPEC-*.md; do
        [ -f "$f" ] || continue
        put_file "$f" "specs/$(basename "$f")"
        printf "  ↑ docs/specs/%s\n" "$(basename "$f")"
    done

    for f in "$REPO_ROOT/docs/reviews"/REVIEW-*.md; do
        [ -f "$f" ] || continue
        put_file "$f" "reviews/$(basename "$f")"
        printf "  ↑ docs/reviews/%s\n" "$(basename "$f")"
    done

    for f in "$REPO_ROOT/docs/feedback"/FEEDBACK-*.md \
             "$REPO_ROOT/docs/feedback"/DEVNOTES-*.md; do
        [ -f "$f" ] || continue
        put_file "$f" "feedback/$(basename "$f")"
        printf "  ↑ docs/feedback/%s\n" "$(basename "$f")"
    done

    if [ -f "$REPO_ROOT/docs/feedback/LESSONS.md" ]; then
        put_file "$REPO_ROOT/docs/feedback/LESSONS.md" "feedback/LESSONS.md"
        printf "  ↑ docs/feedback/LESSONS.md\n"
    fi

    regen_specs_index
    regen_reviews_index
    regen_feedback_index
    regen_root_index

    printf "✅ 동기화 완료\n"
}

# ── 엔트리포인트 ──────────────────────────────────────────────────────────

# Obsidian이 꺼져 있으면 조용히 종료
if ! obsidian_alive; then
    exit 0
fi

if [ $# -eq 0 ]; then
    full_sync
else
    for f in "$@"; do
        sync_file "$f"
    done
fi
