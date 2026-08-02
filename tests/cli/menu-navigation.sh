#!/bin/bash

# Regression test: an action may explicitly leave a grouped submenu for root.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

export SHIPGLOWS_ERROR_TRAPS=false
export SHIPGLOWS_STRICT_MODE=false
source "$REPO_ROOT/cli/lib.sh"

# The frontend loops normally redraw headers; remove them from this focused
# control-flow test.
clear() { :; }
ui_screen_header() { :; }
print_header() { :; }

source "$REPO_ROOT/cli/shipglows_devserver_bash.sh"
_bash_run_menu() {
    ui_return_to_main_menu
    return 0
}
_bash_run_nested_menu "Test" "x|Back|__EXIT__"
ui_should_skip_next_pause
! ui_should_return_to_main_menu

(
    bash_root_calls=0
    _bash_run_menu() {
        bash_root_calls=$((bash_root_calls + 1))
        if [ "$bash_root_calls" -eq 1 ]; then
            ui_return_to_main_menu
            return 0
        fi
        exit 0
    }
    ui_pause() { exit 1; }
    run_menu
)

source "$REPO_ROOT/cli/shipglows_devserver_gum.sh"
_gum_run_menu() {
    ui_return_to_main_menu
    return 0
}
_gum_run_nested_menu "Test" "" "x|Back|__EXIT__"
ui_should_skip_next_pause
! ui_should_return_to_main_menu

(
    gum_root_calls=0
    _gum_run_menu() {
        gum_root_calls=$((gum_root_calls + 1))
        if [ "$gum_root_calls" -eq 1 ]; then
            ui_return_to_main_menu
            return 0
        fi
        exit 0
    }
    _gum_pause() { exit 1; }
    run_menu
)

echo "Grouped-menu return to root passed"
