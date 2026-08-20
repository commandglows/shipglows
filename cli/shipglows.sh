#!/bin/bash

# ShipGlows - Development Environment Manager
# Manages Flox environments, PM2 processes, and Caddy reverse proxy
#
# Architecture:
#   lib.sh       — shared library (actions, utilities, ui_* wrappers)
#   shipglows_devserver_gum.sh  — pure gum menus (when gum is installed)
#   shipglows_devserver_bash.sh — pure bash menus (fallback)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Skill distribution is a lightweight control plane. It must remain usable
# without bootstrapping the DevServer menu or its local prerequisites.
if [ "${1:-}" = "skills" ]; then
    shift
    if ! command -v python3 >/dev/null 2>&1; then
        echo "ShipGlows skill commands require Python 3." >&2
        exit 2
    fi
    exec python3 "$SCRIPT_DIR/shipglows_skills.py" "$@"
fi

# The environment control plane is intentionally independent from the legacy
# DevServer prerequisite/menu bootstrap. Its inspect/plan/status paths must not
# create setup markers or require Flox, PM2, Caddy, Gum, or fzf.
if [ "${1:-}" = "env" ]; then
    shift
    if ! command -v python3 >/dev/null 2>&1; then
        echo "ShipGlows environment commands require Python 3." >&2
        exit 2
    fi
    exec python3 "$SCRIPT_DIR/environment/shipglows_environment.py" "$@"
fi

source "$SCRIPT_DIR/lib.sh"

# Load the right menu frontend
if [ "$HAS_GUM" = true ]; then
    source "$SCRIPT_DIR/shipglows_devserver_gum.sh"
else
    source "$SCRIPT_DIR/shipglows_devserver_bash.sh"
fi

# Main entry point
main() {
    if [ "${1:-}" = "codex" ] || [ "${1:-}" = "co" ]; then
        run_menu_shortcut "$@"
        exit $?
    fi

    local marker="${SHIPGLOWS_SETUP_MARKER:-$HOME/.shipglows_setup_done}"
    local legacy_marker="$HOME/.shipglows_setup_done"

    if [ ! -f "$marker" ] && [ -f "$legacy_marker" ]; then
        mkdir -p "$(dirname "$marker")" 2>/dev/null || true
        cp -p "$legacy_marker" "$marker" 2>/dev/null || touch "$marker"
    fi

    if [ ! -f "$marker" ]; then
        clear
        print_header
        if ! check_prerequisites; then
            ui_pause "Appuie sur une touche pour quitter..."
            exit 1
        fi
        touch "$marker"
        ui_pause
    else
        if ! check_prerequisites "quiet"; then
            clear
            print_header
            check_prerequisites
            ui_pause "Appuie sur une touche pour quitter..."
            exit 1
        fi
    fi

    if [ "$#" -gt 0 ]; then
        local shortcut_status=0
        run_menu_shortcut "$@" || shortcut_status=$?
        exit "$shortcut_status"
    else
        run_menu
    fi
}

main "$@"
