#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$ROOT_DIR/../.." && pwd)"
SCRIPT="$REPO_ROOT/skills/800-tmux-capture-conversation/scripts/capture_tmux_conversation.sh"
SHIPGLOWS_ROOT_UNDER_TEST="${SHIPGLOWS_ROOT:-$REPO_ROOT}"

pass_count=0
fail_count=0

pass() {
  printf 'PASS: %s\n' "$1"
  pass_count=$((pass_count + 1))
}

fail_test() {
  printf 'FAIL: %s\n' "$1" >&2
  fail_count=$((fail_count + 1))
}

assert_contains() {
  local name="$1"
  local haystack="$2"
  local needle="$3"

  if grep -Fq "$needle" <<<"$haystack"; then
    pass "$name"
  else
    fail_test "$name"
    printf 'Expected to find: %s\nOutput:\n%s\n' "$needle" "$haystack" >&2
  fi
}

assert_fails_with() {
  local name="$1"
  local expected="$2"
  shift 2
  local output status

  set +e
  output=$("$@" 2>&1)
  status=$?
  set -e

  if [ "$status" -ne 0 ] && grep -Fq "$expected" <<<"$output"; then
    pass "$name"
  else
    fail_test "$name"
    printf 'Expected failure containing: %s\nStatus: %s\nOutput:\n%s\n' "$expected" "$status" "$output" >&2
  fi
}

need_tmux() {
  command -v tmux >/dev/null 2>&1 || {
    printf 'SKIP: tmux is not installed; conversation storage test needs tmux dry-run context.\n'
    exit 0
  }
  tmux display-message -p '#S' >/dev/null 2>&1 || {
    printf 'SKIP: no current tmux pane; run this test inside tmux.\n'
    exit 0
  }
}

need_tmux

tmp_project=$(mktemp -d)
trap 'rm -rf "$tmp_project"' EXIT
mkdir -p "$tmp_project/.git" "$tmp_project/shipglows_data/workflow/conversations"

shipglows_output=$(
  cd "$tmp_project"
  SHIPGLOWS_ROOT="$SHIPGLOWS_ROOT_UNDER_TEST" "$SCRIPT" --preset shipglows --title "Conversation Storage Guard" --dry-run
)
assert_contains \
  "shipglows preset from project cwd uses ShipGlows root" \
  "$shipglows_output" \
  "Destination: $SHIPGLOWS_ROOT_UNDER_TEST/shipglows_data/workflow/conversations/"

assert_fails_with \
  "shipglows preset blocks relative project-local conversation destination" \
  "shipglows preset output must stay under $SHIPGLOWS_ROOT_UNDER_TEST/shipglows_data/workflow/conversations" \
  bash -c "cd '$tmp_project' && SHIPGLOWS_ROOT='$SHIPGLOWS_ROOT_UNDER_TEST' '$SCRIPT' --preset shipglows --title 'Bad Relative' --destination shipglows_data/workflow/conversations/bad-relative.md --dry-run"

assert_fails_with \
  "shipglows preset blocks absolute project-local conversation destination" \
  "shipglows preset output must stay under $SHIPGLOWS_ROOT_UNDER_TEST/shipglows_data/workflow/conversations" \
  env SHIPGLOWS_ROOT="$SHIPGLOWS_ROOT_UNDER_TEST" "$SCRIPT" --preset shipglows --title "Bad Absolute" --destination "$tmp_project/shipglows_data/workflow/conversations/bad-absolute.md" --dry-run

docs_output=$(
  cd "$tmp_project"
  SHIPGLOWS_ROOT="$SHIPGLOWS_ROOT_UNDER_TEST" "$SCRIPT" --preset docs --title "Project Docs Conversation" --destination shipglows_data/workflow/conversations/project-note.md --dry-run
)
assert_contains \
  "legacy docs preset routes to canonical project-local destination" \
  "$docs_output" \
  "Destination: $tmp_project/shipglows_data/workflow/conversations/project-note.md"

printf '\nConversation audit storage tests: %s passed, %s failed\n' "$pass_count" "$fail_count"
[ "$fail_count" -eq 0 ]
