#!/usr/bin/env bash
# Python 3 runtime guard shared by the ShipGlows CLI entry points.
# Sourced, never executed. Installs nothing: it only detects and explains.
# Policy: shipglows_data/technical/python-runtime-provisioning.md

SHIPGLOWS_PYTHON_MIN_VERSION="3.9"

# Returns 0 when `python3` exists and meets SHIPGLOWS_PYTHON_MIN_VERSION.
shipglows_python3_ready() {
    command -v python3 >/dev/null 2>&1 || return 1
    python3 -c "import sys; sys.exit(0 if sys.version_info >= (3, 9) else 1)" >/dev/null 2>&1
}

# Prints the platform-specific install command for Python 3.
shipglows_python3_install_hint() {
    case "$(uname -s 2>/dev/null)" in
        Darwin)
            echo "brew install python@3.12" ;;
        MINGW*|MSYS*|CYGWIN*)
            echo "winget install -e --id Python.Python.3.12 (then reopen the terminal; on Windows, disable the python3 App Execution Alias if it shadows the install)" ;;
        *)
            echo "sudo apt-get install -y python3 python3-yaml (Debian/Ubuntu server: sudo ./cli/install.sh)" ;;
    esac
}

# Prints a precise diagnostic to stderr. $1 names the command that needs Python.
shipglows_python3_diagnose() {
    local context="${1:-ShipGlows}" reason found
    if command -v python3 >/dev/null 2>&1; then
        found="$(python3 -c "import sys; print('.'.join(map(str, sys.version_info[:3])))" 2>/dev/null || echo "unusable")"
        reason="python3 is ${found} (need ${SHIPGLOWS_PYTHON_MIN_VERSION}+)"
    else
        reason="python3 is not in PATH"
    fi
    echo "$context requires Python ${SHIPGLOWS_PYTHON_MIN_VERSION}+: ${reason}." >&2
    echo "Install: $(shipglows_python3_install_hint)" >&2
    echo "Policy: shipglows_data/technical/python-runtime-provisioning.md" >&2
}
