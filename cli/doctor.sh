#!/usr/bin/env sh
# doctor.sh - Read-only prerequisite check for the ShipGlows bootstrap.
# Installs nothing and changes nothing: it reports what is missing and prints
# the command that fixes each gap for the detected platform.
# Reuses install-shipglows.sh (platform detection and refusals) and
# cli/python-runtime.sh (Python guard). Matrix: shipglows_data/technical/bootstrap-matrix.md

DOCTOR_ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
DOCTOR_MISSING=0

# Library mode: defines detect_platform and check_platform_support, runs nothing.
SHIPGLOWS_BOOTSTRAP_LIBRARY=1
. "$DOCTOR_ROOT/install-shipglows.sh"
. "$DOCTOR_ROOT/cli/python-runtime.sh"

doctor_say() {
    printf '%s\n' "$*"
}

# Prints the command that installs $1 (git, curl, bash) on $PLATFORM.
doctor_package_hint() {
    case "$PLATFORM" in
        termux)
            echo "pkg install -y $1" ;;
        macos)
            if [ "$1" = git ]; then
                echo "xcode-select --install"
            else
                echo "brew install $1"
            fi ;;
        linux|wsl)
            if [ "$DISTRO_FAMILY" = debian ]; then
                echo "sudo apt-get install -y $1"
            else
                echo "votre gestionnaire de paquets, par exemple: sudo dnf install -y $1"
            fi ;;
    esac
}

doctor_check_tool() {
    if command -v "$1" >/dev/null 2>&1; then
        doctor_say "✓ $1"
        return 0
    fi
    doctor_say "✗ $1 absent"
    doctor_say "  Corriger: $(doctor_package_hint "$1")"
    DOCTOR_MISSING=$((DOCTOR_MISSING + 1))
}

doctor_check_python() {
    if shipglows_python3_ready; then
        version="$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:3])))' 2>/dev/null)"
        doctor_say "✓ python3 $version (${SHIPGLOWS_PYTHON_MIN_VERSION}+ requis)"
        return 0
    fi
    doctor_say "✗ python3 ${SHIPGLOWS_PYTHON_MIN_VERSION}+ absent ou trop ancien"
    doctor_say "  Corriger: $(shipglows_python3_install_hint)"
    DOCTOR_MISSING=$((DOCTOR_MISSING + 1))
}

# Informational only: mode full is optional for the local prerequisites.
doctor_check_full_mode() {
    case "$PLATFORM" in
        linux|wsl)
            if [ "$DISTRO_FAMILY" != debian ]; then
                doctor_say "- mode full: non disponible (Debian/Ubuntu uniquement), utilisez local"
            elif [ "$CURRENT_UID" -eq 0 ]; then
                doctor_say "- mode full: disponible (root, Debian/Ubuntu)"
            else
                doctor_say "- mode full: requiert root"
                doctor_say "  Commande: curl -fsSL $PUBLIC_INSTALL_URL | sudo env SHIPGLOWS_INSTALL_MODE=full sh"
            fi ;;
        *)
            doctor_say "- mode full: non supporté sur $PLATFORM, utilisez local" ;;
    esac
}

doctor_main() {
    INSTALL_MODE=""
    detect_platform
    if ! check_platform_support; then
        doctor_say "Diagnostic arrêté: plateforme refusée ($PLATFORM). Rien n'a été vérifié."
        return 1
    fi

    doctor_say "Plateforme: $PLATFORM (famille: $DISTRO_FAMILY)"
    doctor_check_tool git
    doctor_check_tool curl
    doctor_check_tool bash
    doctor_check_python
    doctor_check_full_mode

    if [ "$DOCTOR_MISSING" -eq 0 ]; then
        doctor_say "Prérequis OK pour le mode local."
        return 0
    fi
    doctor_say "$DOCTOR_MISSING prérequis manquant(s). Aucune commande n'a été lancée: exécutez celles ci-dessus."
    return 1
}

doctor_main
exit $?
