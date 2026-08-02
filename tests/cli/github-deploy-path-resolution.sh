#!/bin/bash

# Regression test: a GitHub deployment must start the directory it has just
# cloned, even when the lazy environment registry was built before .flox
# existed and therefore does not yet contain the repository name.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

export HOME="$TEST_ROOT/home"
export SHIPGLOWS_STATE_DIR="$HOME/.shipglows"
export SHIPGLOWS_PROJECTS_DIR="$HOME/projects"
export SHIPGLOWS_PROJECTS_DIR="$SHIPGLOWS_PROJECTS_DIR"
export SHIPGLOWS_REGISTRY="$SHIPGLOWS_STATE_DIR/envs.reg"
export SHIPGLOWS_REGISTRY="$SHIPGLOWS_REGISTRY"
export SHIPGLOWS_ERROR_TRAPS=false
export SHIPGLOWS_STRICT_MODE=false
export SHIPGLOWS_LOGGING_ENABLED=false
export SHIPGLOWS_LOGGING_ENABLED=false

source "$REPO_ROOT/cli/lib.sh"
trap - ERR 2>/dev/null || true

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

started_identifier=""

get_github_username() {
    printf '%s\n' 'test-owner'
}

git() {
    [ "${1:-}" = "clone" ] || return 1
    mkdir -p "$3"
}

init_flox_env() {
    local project_dir="$1" project_name="$2" unresolved=""
    mkdir -p "$project_dir/.flox"

    # The deployment's earlier existence check populated the registry before
    # this new .flox directory existed. The name must still be absent here.
    if resolve_project_path_into unresolved "$project_name"; then
        fail "fresh project name unexpectedly resolved through stale registry"
    fi
}

env_start() {
    started_identifier="$1"
}

shipglows_init_project() { :; }
pm2_port_load() { return 1; }

deploy_github_project 'gocharbon_quiz' >/dev/null

expected_path="$SHIPGLOWS_PROJECTS_DIR/gocharbon_quiz"
[ "$started_identifier" = "$expected_path" ] || \
    fail "deployment must start cloned path (got '$started_identifier')"

printf 'PASS: GitHub deployment starts the authoritative cloned path\n'
