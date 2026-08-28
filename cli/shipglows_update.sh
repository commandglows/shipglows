#!/usr/bin/env bash
# Canonical ShipGlows self-update entrypoint. The installer remains the only
# writer of the managed runtime; this adapter only resolves the active source.

set -euo pipefail

UPDATE_SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UPDATE_ROOT="$(cd -P "$UPDATE_SCRIPT_DIR/.." && pwd)"

update_fail() {
    printf 'shipglows update: %s\n' "$*" >&2
    exit 2
}

update_git() {
    command -v git >/dev/null 2>&1 || update_fail 'Git is required to inspect this ShipGlows source.'
    git -C "$UPDATE_ROOT" "$@"
}

update_channel() {
    if [ -n "${SHIPGLOWS_ROOT:-}" ] && [ "$(cd -P "$SHIPGLOWS_ROOT" 2>/dev/null && pwd)" = "$UPDATE_ROOT" ]; then
        printf 'linked\n'
    else
        printf 'stable\n'
    fi
}

update_status() {
    local channel branch upstream dirty
    channel="$(update_channel)"
    if [ ! -e "$UPDATE_ROOT/.git" ]; then
        printf 'ShipGlows update status: channel=%s source=managed-runtime git=unavailable\n' "$channel"
        return 0
    fi
    branch="$(update_git branch --show-current)"
    upstream="$(update_git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null || true)"
    dirty="$(update_git status --porcelain)"
    printf 'ShipGlows update status: channel=%s branch=%s upstream=%s source=%s skills=%s\n' \
        "$channel" "${branch:-detached}" "${upstream:-none}" "$UPDATE_ROOT" \
        "$( [ "$channel" = linked ] && printf live || printf managed )"
    if [ -n "$dirty" ]; then
        printf 'Runtime update is blocked: the selected source has uncommitted changes.\n' >&2
        return 1
    fi
}

update_apply() {
    local branch upstream
    [ -f "$UPDATE_ROOT/install-shipglows.sh" ] || update_fail "bootstrap missing from $UPDATE_ROOT"
    [ -e "$UPDATE_ROOT/.git" ] || update_fail 'The active runtime is not a Git checkout; reinstall from the official bootstrap.'
    if ! update_git diff --quiet || ! update_git diff --cached --quiet || [ -n "$(update_git ls-files --others --exclude-standard)" ]; then
        update_fail 'the selected source has uncommitted changes; commit, stash, or discard them yourself before updating.'
    fi
    branch="$(update_git branch --show-current)"
    [ -n "$branch" ] || update_fail 'detached HEAD cannot select an update branch.'
    upstream="$(update_git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null || true)"
    [ -n "$upstream" ] || update_fail "branch '$branch' has no upstream; update stopped before bootstrap."

    printf 'Updating ShipGlows from %s (%s)…\n' "$branch" "$(update_channel)"
    exec env SHIPGLOWS_DIR="$UPDATE_ROOT" SHIPGLOWS_BRANCH="$branch" \
        bash "$UPDATE_ROOT/install-shipglows.sh"
}

case "${1:-}" in
    status|--check|check)
        [ "$#" -eq 1 ] || update_fail 'accepted forms: shipglows update [status|--check]'
        update_status
        ;;
    '')
        update_apply
        ;;
    *)
        update_fail 'accepted forms: shipglows update [status|--check]'
        ;;
esac
