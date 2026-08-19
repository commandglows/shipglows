#!/bin/bash

# Regression test: a GitHub clone catalogues launch surfaces without creating
# Flox state, installing dependencies, prompting for a surface, or starting it.
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

cloned_url=""

get_github_username() {
    printf '%s\n' 'test-owner'
}

git() {
    [ "${1:-}" = "clone" ] || return 1
    cloned_url="$2"
    mkdir -p "$3/.git"
    if [ "$(basename "$3")" = "monorepo" ]; then
        mkdir -p "$3/site" "$3/worker"
    fi
}

init_flox_env() {
    fail "clone must not initialize Flox"
}

registry_sync() {
    mkdir -p "$(dirname "$SHIPGLOWS_REGISTRY")"
    if [ -d "$SHIPGLOWS_PROJECTS_DIR/monorepo/.git" ]; then
        printf '%s\n' \
            "monorepo_site|uninitialized||$SHIPGLOWS_PROJECTS_DIR/monorepo/site|$SHIPGLOWS_PROJECTS_DIR/monorepo/site" \
            "monorepo_worker|uninitialized||$SHIPGLOWS_PROJECTS_DIR/monorepo/worker|$SHIPGLOWS_PROJECTS_DIR/monorepo/worker" \
            > "$SHIPGLOWS_REGISTRY"
    elif [ -d "$SHIPGLOWS_PROJECTS_DIR/gocharbon_quiz/.git" ]; then
        printf '%s\n' "gocharbon_quiz|uninitialized||$SHIPGLOWS_PROJECTS_DIR/gocharbon_quiz|$SHIPGLOWS_PROJECTS_DIR/gocharbon_quiz" > "$SHIPGLOWS_REGISTRY"
    else
        : > "$SHIPGLOWS_REGISTRY"
    fi
    invalidate_environment_index_cache
}

ui_choose() {
    fail "clone must not prompt for a launch surface"
}

env_start() {
    fail "clone must not start an environment"
}

shipglows_init_project() { :; }
pm2_port_load() { return 1; }

deploy_github_project 'commandglows/gocharbon_quiz' >/dev/null

expected_path="$SHIPGLOWS_PROJECTS_DIR/gocharbon_quiz"
[ "$cloned_url" = 'git@github.com:commandglows/gocharbon_quiz.git' ] || \
    fail "deployment must preserve the selected organization owner (got '$cloned_url')"
[ ! -e "$expected_path/.flox" ] || fail "single-app clone must not create Flox state"
grep -Fqx "gocharbon_quiz|uninitialized||$expected_path|$expected_path" "$SHIPGLOWS_REGISTRY" || \
    fail "single-app clone must be catalogued as uninitialized"

printf 'PASS: GitHub clone catalogues a single app without initializing or starting it\n'

cloned_url=""
deploy_github_project 'commandglows/monorepo' >/dev/null

monorepo_root="$SHIPGLOWS_PROJECTS_DIR/monorepo"
[ ! -e "$monorepo_root/.flox" ] && [ ! -e "$monorepo_root/site/.flox" ] && [ ! -e "$monorepo_root/worker/.flox" ] || \
    fail "monorepo clone must not create Flox state"
grep -Fqx "monorepo_site|uninitialized||$monorepo_root/site|$monorepo_root/site" "$SHIPGLOWS_REGISTRY" || \
    fail "monorepo site must be catalogued as uninitialized"
grep -Fqx "monorepo_worker|uninitialized||$monorepo_root/worker|$monorepo_root/worker" "$SHIPGLOWS_REGISTRY" || \
    fail "monorepo worker must be catalogued as uninitialized"

printf 'PASS: GitHub monorepo clone catalogues every surface without prompting or starting\n'

existing_marker="$expected_path/preserved.txt"
printf 'keep me\n' > "$existing_marker"
set +e
deploy_github_project 'commandglows/gocharbon_quiz' >/dev/null
existing_rc=$?
set -e
[ "$existing_rc" -ne 0 ] || fail "clone must reject an existing destination"
grep -Fqx 'keep me' "$existing_marker" || fail "existing destination must remain unchanged"

printf 'PASS: GitHub clone refuses an existing destination without deleting it\n'
