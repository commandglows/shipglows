#!/bin/bash

# Script d'installation ShipGlows — DOIT être lancé en root (sudo ./cli/install.sh)
# Installe les paquets système puis configure le compte lanceur par défaut

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SHIPGLOWS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHIPGLOWS_DIR="$SHIPGLOWS_DIR"
SHIPGLOWS_LOG_DIR="${SHIPGLOWS_LOG_DIR:-${SHIPGLOWS_LOG_DIR:-$HOME/install-logs}}"
SHIPGLOWS_LOG_FILE="${SHIPGLOWS_LOG_FILE:-${SHIPGLOWS_LOG_FILE:-$SHIPGLOWS_LOG_DIR/shipglows-$(date -u +%Y%m%dT%H%M%SZ).log}}"
SHIPGLOWS_REPORT_DIR="${SHIPGLOWS_REPORT_DIR:-${SHIPGLOWS_REPORT_DIR:-$HOME/install-reports}}"
SHIPGLOWS_REPORT_FILE="${SHIPGLOWS_REPORT_FILE:-${SHIPGLOWS_REPORT_FILE:-$SHIPGLOWS_REPORT_DIR/shipglows-$(date -u +%Y%m%dT%H%M%SZ).md}}"
SHIPGLOWS_LOG_DIR="$SHIPGLOWS_LOG_DIR"
SHIPGLOWS_LOG_FILE="$SHIPGLOWS_LOG_FILE"
SHIPGLOWS_REPORT_DIR="$SHIPGLOWS_REPORT_DIR"
SHIPGLOWS_REPORT_FILE="$SHIPGLOWS_REPORT_FILE"
mkdir -p "$SHIPGLOWS_LOG_DIR"
mkdir -p "$SHIPGLOWS_REPORT_DIR"
touch "$SHIPGLOWS_LOG_FILE"

shipglows_log() {
    local level="$1"
    local message="$2"
    local clean_message
    clean_message=$(printf '%s' "$message" | sed -E 's/\x1B\[[0-9;]*[a-zA-Z]//g')
    printf '%s [%s] %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$level" "$clean_message" >> "$SHIPGLOWS_LOG_FILE"
}

echo -e "${CYAN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}         ${YELLOW}ShipGlows Installation${NC}            ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
shipglows_log "INFO" "ShipGlows install started"

# Fonction helper
success() {
    echo -e "${GREEN}✅${NC} $1"
    shipglows_log "INFO" "OK: $1"
}

error() {
    echo -e "${RED}❌${NC} $1"
    shipglows_log "ERROR" "FAIL: $1"
}

info() {
    echo -e "${BLUE}ℹ️${NC} $1"
    shipglows_log "INFO" "INFO: $1"
}

warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
    shipglows_log "WARN" "WARN: $1"
}

warn_flutter_android_ci_policy() {
    local arch
    arch="$(uname -m 2>/dev/null || echo unknown)"

    if [ "$arch" = "aarch64" ] || [ "$arch" = "arm64" ]; then
        echo ""
        echo -e "${YELLOW}╔══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${YELLOW}║  Flutter Android : builds release APK en CI x64          ║${NC}"
        echo -e "${YELLOW}╚══════════════════════════════════════════════════════════╝${NC}"
        echo -e "${YELLOW}Cette machine est ${arch}. Flutter peut tourner localement, mais les${NC}"
        echo -e "${YELLOW}Android build tools officiels Linux sont principalement x86_64.${NC}"
        echo -e "${YELLOW}Pour éviter de saturer ou crasher la VM, garde localement :${NC}"
        echo -e "  ${CYAN}flutter analyze && flutter test && flutter build web --release${NC}"
        echo -e "${YELLOW}et route les APK/AAB Android vers Blacksmith ou une CI Linux x64.${NC}"
        echo ""
        shipglows_log "WARN" "Flutter Android policy: host arch ${arch}; do not run local release APK/AAB builds here. Use Blacksmith or another Linux x64 CI runner."
    fi
}

prompt_yes_no() {
    local prompt="$1"
    local default="${2:-no}"
    local reply
    local suffix

    case "$default" in
        yes|y|true|1)
            suffix="[Y/n]"
            ;;
        *)
            suffix="[y/N]"
            ;;
    esac

    if [ ! -r /dev/tty ] || [ ! -w /dev/tty ]; then
        return 1
    fi

    printf '%s %s ' "$prompt" "$suffix" > /dev/tty
    if ! IFS= read -r reply < /dev/tty; then
        reply=""
    fi

    case "$reply" in
        y|Y|yes|YES|oui|OUI|true|TRUE|1)
            return 0
            ;;
        n|N|no|NO|non|NON|false|FALSE|0)
            return 1
            ;;
        "")
            case "$default" in
                yes|y|true|1)
                    return 0
                    ;;
                *)
                    return 1
                    ;;
            esac
            ;;
        *)
            return 1
            ;;
    esac
}

resolve_autonomy_mode() {
    local requested_mode="${SHIPGLOWS_AUTONOMY_MODE:-${SHIPGLOWS_AUTONOMY_MODE:-ask}}"
    case "$requested_mode" in
        permissive|permissive-mode|danger|dangerous|1|true|yes)
            SHIPGLOWS_AUTONOMY_MODE_RESOLVED="permissive"
            ;;
        standard|safe|restricted|0|false|no)
            SHIPGLOWS_AUTONOMY_MODE_RESOLVED="standard"
            ;;
        ask|"")
            if prompt_yes_no "Activer le mode autonome permissif pour Claude/Codex sur les comptes configurés ?" no; then
                SHIPGLOWS_AUTONOMY_MODE_RESOLVED="permissive"
            else
                SHIPGLOWS_AUTONOMY_MODE_RESOLVED="standard"
            fi
            ;;
        *)
            warning "Valeur SHIPGLOWS_AUTONOMY_MODE inconnue: ${requested_mode}; mode standard utilisé."
            SHIPGLOWS_AUTONOMY_MODE_RESOLVED="standard"
            ;;
    esac
}

resolve_root_autonomy_opt_in() {
    if [ "${SHIPGLOWS_AUTONOMY_MODE_RESOLVED:-standard}" != "permissive" ]; then
        SHIPGLOWS_ROOT_AUTONOMOUS_ALLOWED="0"
        return 0
    fi

    local root_autonomy_opt_in="${SHIPGLOWS_AI_ALLOW_ROOT_AUTONOMOUS:-${SHIPGLOWS_AI_ALLOW_ROOT_AUTONOMOUS:-}}"
    if [ "$root_autonomy_opt_in" = "1" ]; then
        SHIPGLOWS_ROOT_AUTONOMOUS_ALLOWED="1"
        return 0
    fi

    if [ "$root_autonomy_opt_in" = "0" ]; then
        SHIPGLOWS_ROOT_AUTONOMOUS_ALLOWED="0"
        return 0
    fi

    if prompt_yes_no "Autoriser aussi root en mode autonome permissif ?" no; then
        SHIPGLOWS_ROOT_AUTONOMOUS_ALLOWED="1"
    else
        SHIPGLOWS_ROOT_AUTONOMOUS_ALLOWED="0"
    fi
}

resolve_install_components() {
    local value="${SHIPGLOWS_INSTALL_COMPONENTS:-${SHIPGLOWS_INSTALL_COMPONENTS:-ask}}"
    SHIPGLOWS_INSTALL_AI_AGENTS="1"
    SHIPGLOWS_INSTALL_AGENT_CLAUDE="1"
    SHIPGLOWS_INSTALL_AGENT_CODEX="1"
    SHIPGLOWS_INSTALL_AGENT_OPENCODE="1"
    SHIPGLOWS_INSTALL_AGENT_KILOCODE="1"
    SHIPGLOWS_INSTALL_AI_RUNTIME="1"
    SHIPGLOWS_INSTALL_SKILL_CORPUS="0"
    SHIPGLOWS_INSTALL_TUI="1"

    case "${SHIPGLOWS_INSTALL_SURFACE:-runtime}" in
        corpus|skills|opencode|kilocode) SHIPGLOWS_INSTALL_SKILL_CORPUS="1" ;;
    esac

    case "$value" in
        all|"")
            SHIPGLOWS_INSTALL_SKILL_CORPUS="1"
            return 0
            ;;
        none)
            SHIPGLOWS_INSTALL_AI_AGENTS="0"
            SHIPGLOWS_INSTALL_AGENT_CLAUDE="0"
            SHIPGLOWS_INSTALL_AGENT_CODEX="0"
            SHIPGLOWS_INSTALL_AGENT_OPENCODE="0"
            SHIPGLOWS_INSTALL_AGENT_KILOCODE="0"
            SHIPGLOWS_INSTALL_AI_RUNTIME="0"
            SHIPGLOWS_INSTALL_TUI="0"
            return 0
            ;;
        ask)
            if [ -r /dev/tty ] && [ -w /dev/tty ]; then
                if prompt_yes_no "Installer Claude ?" yes; then SHIPGLOWS_INSTALL_AGENT_CLAUDE="1"; else SHIPGLOWS_INSTALL_AGENT_CLAUDE="0"; fi
                if prompt_yes_no "Installer Codex ?" yes; then SHIPGLOWS_INSTALL_AGENT_CODEX="1"; else SHIPGLOWS_INSTALL_AGENT_CODEX="0"; fi
                if prompt_yes_no "Installer OpenCode ?" yes; then SHIPGLOWS_INSTALL_AGENT_OPENCODE="1"; else SHIPGLOWS_INSTALL_AGENT_OPENCODE="0"; fi
                if prompt_yes_no "Installer KiloCode ?" yes; then SHIPGLOWS_INSTALL_AGENT_KILOCODE="1"; else SHIPGLOWS_INSTALL_AGENT_KILOCODE="0"; fi

                if prompt_yes_no "Installer la couche runtime ShipGlows (settings Claude/Codex, MCP, aliases) ?" yes; then
                    SHIPGLOWS_INSTALL_AI_RUNTIME="1"
                else
                    SHIPGLOWS_INSTALL_AI_RUNTIME="0"
                fi

                if prompt_yes_no "Installer le corpus public de skills (Claude/OpenCode/KiloCode) ?" no; then
                    SHIPGLOWS_INSTALL_SKILL_CORPUS="1"
                fi

                if prompt_yes_no "Installer la TUI ShipGlows pour les utilisateurs ciblés ?" yes; then
                    SHIPGLOWS_INSTALL_TUI="1"
                else
                    SHIPGLOWS_INSTALL_TUI="0"
                fi
            fi
            if [ "${SHIPGLOWS_INSTALL_AGENT_CLAUDE:-0}" = "1" ] || [ "${SHIPGLOWS_INSTALL_AGENT_CODEX:-0}" = "1" ] || [ "${SHIPGLOWS_INSTALL_AGENT_OPENCODE:-0}" = "1" ] || [ "${SHIPGLOWS_INSTALL_AGENT_KILOCODE:-0}" = "1" ]; then
                SHIPGLOWS_INSTALL_AI_AGENTS="1"
            else
                SHIPGLOWS_INSTALL_AI_AGENTS="0"
            fi
            return 0
            ;;
        *)
            SHIPGLOWS_INSTALL_AI_AGENTS="0"
            SHIPGLOWS_INSTALL_AGENT_CLAUDE="0"
            SHIPGLOWS_INSTALL_AGENT_CODEX="0"
            SHIPGLOWS_INSTALL_AGENT_OPENCODE="0"
            SHIPGLOWS_INSTALL_AGENT_KILOCODE="0"
            SHIPGLOWS_INSTALL_AI_RUNTIME="0"
            SHIPGLOWS_INSTALL_TUI="0"
            case ",$value," in
                *,ai-agents,*)
                    SHIPGLOWS_INSTALL_AI_AGENTS="1"
                    SHIPGLOWS_INSTALL_AGENT_CLAUDE="1"
                    SHIPGLOWS_INSTALL_AGENT_CODEX="1"
                    SHIPGLOWS_INSTALL_AGENT_OPENCODE="1"
                    SHIPGLOWS_INSTALL_AGENT_KILOCODE="1"
                    ;;
            esac
            case ",$value," in
                *,claude,*) SHIPGLOWS_INSTALL_AGENT_CLAUDE="1" ;;
            esac
            case ",$value," in
                *,codex,*) SHIPGLOWS_INSTALL_AGENT_CODEX="1" ;;
            esac
            case ",$value," in
                *,opencode,*) SHIPGLOWS_INSTALL_AGENT_OPENCODE="1" ;;
            esac
            case ",$value," in
                *,kilocode,*) SHIPGLOWS_INSTALL_AGENT_KILOCODE="1" ;;
            esac
            case ",$value," in
                *,ai-runtime,*) SHIPGLOWS_INSTALL_AI_RUNTIME="1" ;;
            esac
            case ",$value," in
                *,skills,*|*,corpus,*) SHIPGLOWS_INSTALL_SKILL_CORPUS="1" ;;
            esac
            case ",$value," in
                *,tui,*) SHIPGLOWS_INSTALL_TUI="1" ;;
            esac
            if [ "${SHIPGLOWS_INSTALL_AGENT_CLAUDE:-0}" = "1" ] || [ "${SHIPGLOWS_INSTALL_AGENT_CODEX:-0}" = "1" ] || [ "${SHIPGLOWS_INSTALL_AGENT_OPENCODE:-0}" = "1" ] || [ "${SHIPGLOWS_INSTALL_AGENT_KILOCODE:-0}" = "1" ]; then
                SHIPGLOWS_INSTALL_AI_AGENTS="1"
            fi
            return 0
            ;;
    esac

}

SHIPGLOWS_PRE_STATUS_DIR_NODE=""
SHIPGLOWS_PRE_STATUS_PM2=""
SHIPGLOWS_PRE_STATUS_VERCEL=""
SHIPGLOWS_PRE_STATUS_CONVEX=""
SHIPGLOWS_PRE_STATUS_CLERK=""
SHIPGLOWS_PRE_STATUS_SUPABASE=""
SHIPGLOWS_PRE_STATUS_FLOX=""
SHIPGLOWS_PRE_STATUS_GH=""
SHIPGLOWS_PRE_STATUS_PYTHON3=""
SHIPGLOWS_PRE_STATUS_PYYAML=""
SHIPGLOWS_PRE_STATUS_CADDY=""
SHIPGLOWS_PRE_STATUS_GIT=""
SHIPGLOWS_PRE_STATUS_JQ=""
SHIPGLOWS_PRE_STATUS_FUSER=""

shipglows_capture_status() {
    command -v node >/dev/null 2>&1 && SHIPGLOWS_PRE_STATUS_DIR_NODE="present" || true
    command -v pm2 >/dev/null 2>&1 && SHIPGLOWS_PRE_STATUS_PM2="present" || true
    command -v vercel >/dev/null 2>&1 && SHIPGLOWS_PRE_STATUS_VERCEL="present" || true
    command -v convex >/dev/null 2>&1 && SHIPGLOWS_PRE_STATUS_CONVEX="present" || true
    command -v clerk >/dev/null 2>&1 && SHIPGLOWS_PRE_STATUS_CLERK="present" || true
    command -v supabase >/dev/null 2>&1 && SHIPGLOWS_PRE_STATUS_SUPABASE="present" || true
    command -v flox >/dev/null 2>&1 && SHIPGLOWS_PRE_STATUS_FLOX="present" || true
    command -v gh >/dev/null 2>&1 && SHIPGLOWS_PRE_STATUS_GH="present" || true
    command -v python3 >/dev/null 2>&1 && SHIPGLOWS_PRE_STATUS_PYTHON3="present" || true
    python3 -c 'import yaml' 2>/dev/null && SHIPGLOWS_PRE_STATUS_PYYAML="present" || true
    command -v caddy >/dev/null 2>&1 && SHIPGLOWS_PRE_STATUS_CADDY="present" || true
    command -v git >/dev/null 2>&1 && SHIPGLOWS_PRE_STATUS_GIT="present" || true
    command -v jq >/dev/null 2>&1 && SHIPGLOWS_PRE_STATUS_JQ="present" || true
    command -v fuser >/dev/null 2>&1 && SHIPGLOWS_PRE_STATUS_FUSER="present" || true
}

shipglows_status() {
    local pre="$1"
    local post="$2"
    if [ "$pre" = "present" ] && [ "$post" = "present" ]; then
        echo "DÉJÀ_PRÉSENT"
    elif [ "$pre" != "present" ] && [ "$post" = "present" ]; then
        echo "INSTALLÉ"
    elif [ "$pre" = "present" ] && [ "$post" != "present" ]; then
        echo "ÉCHEC"
    else
        echo "ÉCHEC"
    fi
}

# Root check — système packages need root, no silent elevation
if [ "$EUID" -ne 0 ]; then
    shipglows_log "ERROR" "ShipGlows install stopped: non-root execution by $(id -un)."
    shipglows_log "ERROR" "Root-required scope not applied: Node.js system install, global PM2/Vercel/Convex/Clerk npm prefix /usr/local, Supabase /usr/local/bin, Flox .deb, apt packages, GitHub CLI apt/deb, PyYAML system install, Caddy apt repo/install, /etc/dokploy/compose, and ShipGlows user configuration."
    echo ""
    echo -e "${RED}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                                                          ║${NC}"
    echo -e "${RED}║   ⛔  CE SCRIPT DOIT ÊTRE LANCÉ EN ROOT !  ⛔           ║${NC}"
    echo -e "${RED}║                                                          ║${NC}"
    echo -e "${RED}║   L'installation des paquets système (Node.js, PM2,      ║${NC}"
    echo -e "${RED}║   Flox, Caddy, etc.) nécessite les droits root.          ║${NC}"
    echo -e "${RED}║                                                          ║${NC}"
    echo -e "${RED}║   Non appliqué sans root : /usr/local, /etc/dokploy,     ║${NC}"
    echo -e "${RED}║   Caddy, Flox .deb et config tous users.                 ║${NC}"
    echo -e "${RED}║                                                          ║${NC}"
    echo -e "${RED}║   Relancez avec :                                        ║${NC}"
    echo -e "${RED}║   ${YELLOW}sudo ./cli/install.sh${RED}                                  ║${NC}"
    echo -e "${RED}║                                                          ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    exit 1
fi

info "Mode root confirmé : installation système + configuration ShipGlows du compte principal"
echo -e "${BLUE}ℹ️${NC} Scope root appliqué : /usr/local, /etc/dokploy, Caddy, Flox, outils globaux"
shipglows_log "INFO" "Privilege scope: root run. Applying system/global setup plus ShipGlows user configuration."

shipglows_capture_status

# Default to the invoking sudo user, or root when launched directly.
PRIMARY_USER="${SUDO_USER:-root}"
PRIMARY_USER_HOME="$(getent passwd "$PRIMARY_USER" 2>/dev/null | cut -d: -f6 || true)"
PRIMARY_USER_HOME="${PRIMARY_USER_HOME:-${HOME:-/root}}"

warn_flutter_android_ci_policy

echo -e "${BLUE}🔍 Vérification des dépendances...${NC}"
echo ""

# 1. Installer Node.js (pour PM2)
if command -v node >/dev/null 2>&1; then
    NODE_VERSION=$(node --version)
    success "Node.js déjà installé: $NODE_VERSION"
else
    info "Installation de Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_24.x | bash -
    apt-get install -y nodejs
    
    if command -v node >/dev/null 2>&1; then
        success "Node.js installé: $(node --version)"
    else
        error "Échec de l'installation de Node.js"
        exit 1
    fi
fi

echo ""

# 2. Installer PM2
if command -v pm2 >/dev/null 2>&1; then
    PM2_VERSION=$(pm2 --version)
    success "PM2 déjà installé: $PM2_VERSION"
else
    info "Installation de PM2..."
    export PNPM_HOME="/usr/local/share/pnpm"
    export PATH="$PNPM_HOME:$PATH"
    corepack prepare pnpm@latest --activate >/dev/null 2>&1
    pnpm add -g pm2
    hash -r 2>/dev/null

    if command -v pm2 >/dev/null 2>&1; then
        success "PM2 installé: $(pm2 --version)"
    else
        error "Échec de l'installation de PM2"
        exit 1
    fi
fi

echo ""

# 3. Installer les CLI Node globales utiles
export PNPM_HOME="/usr/local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
corepack prepare pnpm@latest --activate >/dev/null 2>&1

if command -v vercel >/dev/null 2>&1; then
    success "Vercel CLI déjà installé: $(vercel --version 2>/dev/null | head -n1)"
else
    info "Installation de Vercel CLI..."
    pnpm add -g vercel
    hash -r 2>/dev/null

    if command -v vercel >/dev/null 2>&1; then
        success "Vercel CLI installé: $(vercel --version 2>/dev/null | head -n1)"
    else
        error "Échec de l'installation de Vercel CLI"
        exit 1
    fi
fi

echo ""

if command -v convex >/dev/null 2>&1; then
    success "Convex CLI déjà installé: $(convex --version 2>/dev/null | head -n1)"
else
    info "Installation de Convex CLI..."
    pnpm add -g convex
    hash -r 2>/dev/null

    if command -v convex >/dev/null 2>&1; then
        success "Convex CLI installé: $(convex --version 2>/dev/null | head -n1)"
    else
        error "Échec de l'installation de Convex CLI"
        exit 1
    fi
fi

echo ""

if command -v clerk >/dev/null 2>&1; then
    success "Clerk CLI déjà installé: $(clerk --version 2>/dev/null | head -n1)"
else
    info "Installation de Clerk CLI..."
    pnpm add -g clerk
    hash -r 2>/dev/null

    if command -v clerk >/dev/null 2>&1; then
        success "Clerk CLI installé: $(clerk --version 2>/dev/null | head -n1)"
    else
        error "Échec de l'installation de Clerk CLI"
        exit 1
    fi
fi

echo ""

# Supabase CLI — standalone binary install, because npm global install is not supported officially.
if command -v supabase >/dev/null 2>&1; then
    success "Supabase CLI déjà installé: $(supabase --version 2>/dev/null | head -n1)"
else
    info "Installation de Supabase CLI..."
    ARCH=$(uname -m)
    case "$ARCH" in
        aarch64|arm64)
            SUPABASE_ARCH="arm64"
            ;;
        x86_64|amd64)
            SUPABASE_ARCH="amd64"
            ;;
        *)
            error "Architecture non supportée pour Supabase CLI: $ARCH"
            exit 1
            ;;
    esac

    SUPABASE_TMP_DIR=$(mktemp -d)
    SUPABASE_ARCHIVE="supabase_linux_${SUPABASE_ARCH}.tar.gz"
    curl -L -o "$SUPABASE_TMP_DIR/$SUPABASE_ARCHIVE" "https://github.com/supabase/cli/releases/latest/download/$SUPABASE_ARCHIVE"
    tar -xzf "$SUPABASE_TMP_DIR/$SUPABASE_ARCHIVE" -C "$SUPABASE_TMP_DIR"
    install -m 0755 "$SUPABASE_TMP_DIR/supabase" /usr/local/bin/supabase
    rm -rf "$SUPABASE_TMP_DIR"
    hash -r 2>/dev/null

    if command -v supabase >/dev/null 2>&1; then
        success "Supabase CLI installé: $(supabase --version 2>/dev/null | head -n1)"
    else
        error "Échec de l'installation de Supabase CLI"
        exit 1
    fi
fi

echo ""

# 4. PM2 autostart policy
info "PM2 installé sans démarrage automatique au boot"
shipglows_log "INFO" "PM2 startup intentionally not configured. ShipGlows environments run under the operator user when started."

echo ""

# 5. Installer Flox
if command -v flox >/dev/null 2>&1; then
    FLOX_VERSION=$(flox --version 2>&1 | head -n1)
    success "Flox déjà installé: $FLOX_VERSION"
else
    info "Installation de Flox..."
    ARCH=$(uname -m)
    FLOX_VERSION="1.8.1"
    
    # Télécharger et installer le package Flox selon l'architecture
    cd /tmp
    if [ "$ARCH" = "aarch64" ]; then
        FLOX_DEB="flox-${FLOX_VERSION}.aarch64-linux.deb"
    else
        FLOX_DEB="flox-${FLOX_VERSION}.x86_64-linux.deb"
    fi
    
    curl -L -o "$FLOX_DEB" "https://downloads.flox.dev/by-env/stable/deb/$FLOX_DEB"
    dpkg -i "$FLOX_DEB"
    rm -f "$FLOX_DEB"
    
    if command -v flox >/dev/null 2>&1; then
        success "Flox installé: $(flox --version)"
    else
        error "Échec de l'installation de Flox"
        warning "Installation manuelle requise: https://flox.dev/docs/install-flox/"
    fi
fi

echo ""

# 6. Installer les outils système nécessaires
info "Vérification des outils système..."

TOOLS_TO_CHECK=("git" "curl" "python3" "ss" "jq" "fuser")
MISSING_TOOLS=()

for tool in "${TOOLS_TO_CHECK[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        success "$tool installé"
    else
        MISSING_TOOLS+=("$tool")
    fi
done

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    info "Installation des outils manquants: ${MISSING_TOOLS[*]}"
    apt-get update >/dev/null 2>&1
    for tool in "${MISSING_TOOLS[@]}"; do
        case $tool in
            "ss")
                apt-get install -y iproute2
                ;;
            "jq")
                apt-get install -y jq
                ;;
            "fuser")
                apt-get install -y psmisc
                ;;
            *)
                apt-get install -y "$tool"
                ;;
        esac
    done
    success "Outils système installés"
fi

echo ""

install_first_available_apt_package() {
    local label="$1"
    shift
    local pkg

    for pkg in "$@"; do
        if dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "install ok installed"; then
            success "$label déjà installé ($pkg)"
            return 0
        fi
    done

    for pkg in "$@"; do
        if apt-cache show "$pkg" >/dev/null 2>&1; then
            apt-get install -y "$pkg"
            success "$label installé ($pkg)"
            return 0
        fi
    done

    warning "Dépendance Playwright introuvable dans apt: $label ($*)"
    return 1
}

# Playwright MCP is provisioned by default. Install the Chromium runtime
# libraries explicitly so Linux ARM64 hosts do not fall through to Chrome stable.
info "Vérification des dépendances runtime Playwright..."
apt-get update >/dev/null 2>&1 || warning "apt-get update a échoué; tentative avec le cache apt existant"
install_first_available_apt_package "ATK" libatk1.0-0t64 libatk1.0-0 || true
install_first_available_apt_package "ATK bridge" libatk-bridge2.0-0t64 libatk-bridge2.0-0 || true
install_first_available_apt_package "ALSA" libasound2t64 libasound2 || true
install_first_available_apt_package "GBM" libgbm1 || true
install_first_available_apt_package "X composite" libxcomposite1 || true
install_first_available_apt_package "X damage" libxdamage1 || true
install_first_available_apt_package "X fixes" libxfixes3 || true
install_first_available_apt_package "X randr" libxrandr2 || true
install_first_available_apt_package "AT-SPI" libatspi2.0-0t64 libatspi2.0-0 || true

echo ""

# 7. Vérifier/Installer GitHub CLI
if command -v gh >/dev/null 2>&1; then
    GH_VERSION=$(gh --version | head -n1)
    success "GitHub CLI déjà installé: $GH_VERSION"
else
    info "Installation de GitHub CLI..."
    # Try apt repo first, fallback to direct .deb download
    gh_installed=false
    if type -p curl >/dev/null; then
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null
        chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        apt-get update -qq 2>/dev/null && apt-get install -y gh 2>/dev/null && gh_installed=true
    fi
    # Fallback: direct .deb download (handles GPG key issues)
    if [ "$gh_installed" != "true" ]; then
        info "Fallback: telechargement direct du .deb..."
        gh_arch="amd64"
        [ "$(uname -m)" = "aarch64" ] && gh_arch="arm64"
        gh_version=""
        gh_version=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | jq -r '.tag_name' 2>/dev/null || echo "v2.67.0")
        curl -fsSL "https://github.com/cli/cli/releases/download/${gh_version}/gh_${gh_version#v}_linux_${gh_arch}.deb" -o /tmp/gh.deb 2>/dev/null
        dpkg -i /tmp/gh.deb 2>/dev/null || true
        rm -f /tmp/gh.deb
    fi
    
    if command -v gh >/dev/null 2>&1; then
        success "GitHub CLI installé: $(gh --version | head -n1)"
    else
        error "Échec de l'installation de GitHub CLI"
    fi
fi

echo ""

# 8. Installer PyYAML pour la gestion des fichiers compose
info "Installation de PyYAML..."
if python3 -c "import yaml" 2>/dev/null; then
    success "PyYAML déjà installé"
else
    apt-get install -y python3-pip >/dev/null 2>&1
    pip3 install pyyaml >/dev/null 2>&1
    success "PyYAML installé"
fi

echo ""

# 9. Installer Caddy (pour publication web)
if command -v caddy >/dev/null 2>&1; then
    CADDY_VERSION=$(caddy version | head -n1)
    success "Caddy déjà installé: $CADDY_VERSION"
else
    info "Installation de Caddy..."
    apt-get install -y debian-keyring debian-archive-keyring apt-transport-https curl >/dev/null 2>&1
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list > /dev/null
    apt-get update >/dev/null 2>&1
    apt-get install -y caddy >/dev/null 2>&1
    
    if command -v caddy >/dev/null 2>&1; then
        success "Caddy installé: $(caddy version | head -n1)"
    else
        error "Échec de l'installation de Caddy"
        warning "Installation manuelle requise: https://caddyserver.com/docs/install"
    fi
fi

if command -v caddy >/dev/null 2>&1 && command -v systemctl >/dev/null 2>&1; then
    info "Désactivation du service Caddy système par défaut..."
    if systemctl disable --now caddy >/dev/null 2>&1; then
        success "Caddy système désactivé; ShipGlows lancera Caddy en mode utilisateur quand nécessaire"
    else
        warning "Impossible de désactiver automatiquement caddy.service; le menu Health peut l'arrêter si aucune app PM2 n'est en ligne"
    fi
fi

echo ""

# 10. Créer le répertoire de configuration
DOKPLOY_DIR="/etc/dokploy/compose"
if [ ! -d "$DOKPLOY_DIR" ]; then
    info "Création du répertoire de configuration..."
    mkdir -p "$DOKPLOY_DIR"
    success "Répertoire créé: $DOKPLOY_DIR"
else
    success "Répertoire de configuration existe: $DOKPLOY_DIR"
fi

# ──────────────────────────────────────────────────────────────
# Per-user setup: Claude Code, skills, aliases, data
# Runs for root + ALL regular users in /home/
# ──────────────────────────────────────────────────────────────

SHIPGLOWS_INSTALL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

# StatusLine — pointer vers le script ShipGlows
configure_statusline() {
    local target_home="$1"
    local settings_file="$target_home/.claude/settings.json"
    mkdir -p "$target_home/.claude"
    if [ ! -f "$settings_file" ]; then
        echo '{}' > "$settings_file"
    fi
    if command -v jq >/dev/null 2>&1; then
        jq --arg cmd "bash $SHIPGLOWS_INSTALL_ROOT/.claude/statusline-starship.sh" \
            '.statusLine = {"type": "command", "command": $cmd}' \
            "$settings_file" > "${settings_file}.tmp" \
            && mv "${settings_file}.tmp" "$settings_file"
    fi
}

# Context7 MCP — official current library docs, installed globally for Claude Code.
configure_context7_mcp() {
    local target_home="$1"
    local settings_file="$target_home/.claude/settings.json"
    mkdir -p "$target_home/.claude"
    if [ ! -f "$settings_file" ]; then
        echo '{}' > "$settings_file"
    fi
    if command -v jq >/dev/null 2>&1; then
        jq '
            .mcpServers.context7 = {
                "command": "npx",
                "args": ["-y", "@upstash/context7-mcp@latest"]
            }
        ' "$settings_file" > "${settings_file}.tmp" \
            && mv "${settings_file}.tmp" "$settings_file"
    fi
}

# Vercel MCP — remote MCP for Vercel deployments, logs, and toolbar.
configure_vercel_mcp() {
    local target_home="$1"
    local settings_file="$target_home/.claude/settings.json"
    mkdir -p "$target_home/.claude"
    if [ ! -f "$settings_file" ]; then
        echo '{}' > "$settings_file"
    fi
    if command -v jq >/dev/null 2>&1; then
        jq '
            .mcpServers.vercel = {
                "url": "https://mcp.vercel.com"
            }
        ' "$settings_file" > "${settings_file}.tmp" \
            && mv "${settings_file}.tmp" "$settings_file"
    fi
}

# Convex MCP — stdio MCP for Convex projects and deployments.
configure_convex_mcp() {
    local target_home="$1"
    local settings_file="$target_home/.claude/settings.json"
    mkdir -p "$target_home/.claude"
    if [ ! -f "$settings_file" ]; then
        echo '{}' > "$settings_file"
    fi
    if command -v jq >/dev/null 2>&1; then
        jq '
            .mcpServers.convex = {
                "command": "npx",
                "args": ["-y", "convex@latest", "mcp", "start"]
            }
        ' "$settings_file" > "${settings_file}.tmp" \
            && mv "${settings_file}.tmp" "$settings_file"
    fi
}

# Clerk MCP — remote MCP for Clerk SDK patterns and implementation guides.
configure_clerk_mcp() {
    local target_home="$1"
    local settings_file="$target_home/.claude/settings.json"
    mkdir -p "$target_home/.claude"
    if [ ! -f "$settings_file" ]; then
        echo '{}' > "$settings_file"
    fi
    if command -v jq >/dev/null 2>&1; then
        jq '
            .mcpServers.clerk = {
                "url": "https://mcp.clerk.com/mcp"
            }
        ' "$settings_file" > "${settings_file}.tmp" \
            && mv "${settings_file}.tmp" "$settings_file"
    fi
}

# Supabase MCP — remote MCP for project state, SQL, logs, and schema-aware assistance.
configure_supabase_mcp() {
    local target_home="$1"
    local settings_file="$target_home/.claude/settings.json"
    mkdir -p "$target_home/.claude"
    if [ ! -f "$settings_file" ]; then
        echo '{}' > "$settings_file"
    fi
    if command -v jq >/dev/null 2>&1; then
        jq '
            .mcpServers.supabase = {
                "url": "https://mcp.supabase.com/mcp"
            }
        ' "$settings_file" > "${settings_file}.tmp" \
            && mv "${settings_file}.tmp" "$settings_file"
    fi
}

# DataForSEO MCP — stdio MCP for SEO data APIs. Enabled only when credentials
# are available in the install environment.
configure_dataforseo_mcp() {
    local target_home="$1"
    local settings_file="$target_home/.claude/settings.json"
    local doppler_project="${SHIPGLOWS_DATAFORSEO_DOPPLER_PROJECT:-${SHIPGLOWS_DATAFORSEO_DOPPLER_PROJECT:-contentflow_app}}"
    local doppler_config="${SHIPGLOWS_DATAFORSEO_DOPPLER_CONFIG:-${SHIPGLOWS_DATAFORSEO_DOPPLER_CONFIG:-prd}}"
    local enabled="${SHIPGLOWS_ENABLE_DATAFORSEO_MCP:-${SHIPGLOWS_ENABLE_DATAFORSEO_MCP:-0}}"
    local enabled_for_jq="false"
    mkdir -p "$target_home/.claude"
    if [ ! -f "$settings_file" ]; then
        echo '{}' > "$settings_file"
    fi
    if command -v jq >/dev/null 2>&1; then
        if command -v doppler >/dev/null 2>&1; then
            [ "$enabled" = "1" ] && enabled_for_jq="true"

            jq --arg project "$doppler_project" --arg config "$doppler_config" --argjson enabled "$enabled_for_jq" '
                .mcpServers.dataforseo = {
                    "command": "doppler",
                    "args": [
                        "run",
                        "--project", $project,
                        "--config", $config,
                        "--",
                        "bash",
                        "-lc",
                        "export DATAFORSEO_USERNAME=\"${DATAFORSEO_USERNAME:-${DATAFORSEO_LOGIN:-}}\"; exec npx -y dataforseo-mcp-server"
                    ]
                }
                | .disabledMcpServers = if $enabled then
                    ((.disabledMcpServers // []) - ["dataforseo"])
                  else
                    ((.disabledMcpServers // []) + ["dataforseo"] | unique)
                  end
            ' "$settings_file" > "${settings_file}.tmp" \
                && mv "${settings_file}.tmp" "$settings_file"
        else
            jq '
            .mcpServers.dataforseo = {
                "command": "npx",
                "args": ["-y", "dataforseo-mcp-server"]
            }
            ' "$settings_file" > "${settings_file}.tmp" \
                && mv "${settings_file}.tmp" "$settings_file"

            if [ "$enabled" != "1" ] || [ -z "${DATAFORSEO_USERNAME:-${DATAFORSEO_LOGIN:-}}" ] || [ -z "${DATAFORSEO_PASSWORD:-}" ]; then
                jq '
                    .disabledMcpServers = ((.disabledMcpServers // []) + ["dataforseo"] | unique)
                ' "$settings_file" > "${settings_file}.tmp" \
                    && mv "${settings_file}.tmp" "$settings_file"
            else
                jq '
                    .disabledMcpServers = ((.disabledMcpServers // []) - ["dataforseo"])
                ' "$settings_file" > "${settings_file}.tmp" \
                    && mv "${settings_file}.tmp" "$settings_file"
            fi
        fi
    fi
}

playwright_mcp_executable_path() {
    local target_home="$1"
    local arch
    local candidate=""

    if [ -n "${SHIPGLOWS_PLAYWRIGHT_EXECUTABLE_PATH:-${SHIPGLOWS_PLAYWRIGHT_EXECUTABLE_PATH:-}}" ] && [ -x "${SHIPGLOWS_PLAYWRIGHT_EXECUTABLE_PATH:-${SHIPGLOWS_PLAYWRIGHT_EXECUTABLE_PATH:-}}" ]; then
        printf '%s' "${SHIPGLOWS_PLAYWRIGHT_EXECUTABLE_PATH:-${SHIPGLOWS_PLAYWRIGHT_EXECUTABLE_PATH:-}}"
        return 0
    fi

    arch="$(uname -m)"
    candidate=$(find "$target_home/.cache/ms-playwright" \
        -path '*/chrome-linux/chrome' \
        -type f -perm -111 2>/dev/null | sort -Vr | head -n 1 || true)
    if [ -n "$candidate" ]; then
        printf '%s' "$candidate"
        return 0
    fi

    candidate=$(find "$target_home/.cache/ms-playwright" \
        -path '*/chrome-linux/headless_shell' \
        -type f -perm -111 2>/dev/null | sort -Vr | head -n 1 || true)
    if [ -n "$candidate" ]; then
        printf '%s' "$candidate"
        return 0
    fi

    for candidate in chromium chromium-browser; do
        candidate="$(command -v "$candidate" 2>/dev/null || true)"
        if [ -n "$candidate" ] && [ -x "$candidate" ]; then
            printf '%s' "$candidate"
            return 0
        fi
    done

    # Google Chrome stable is not available through Playwright on Linux ARM64.
    if [ "$arch" != "aarch64" ] && [ "$arch" != "arm64" ]; then
        for candidate in google-chrome google-chrome-stable chrome; do
            candidate="$(command -v "$candidate" 2>/dev/null || true)"
            if [ -n "$candidate" ] && [ -x "$candidate" ]; then
                printf '%s' "$candidate"
                return 0
            fi
        done
    fi

    return 1
}

playwright_mcp_args_json() {
    local target_home="$1"
    local executable_path=""

    executable_path="$(playwright_mcp_executable_path "$target_home" || true)"

    if [ -n "$executable_path" ]; then
        printf '["-y","@playwright/mcp@latest","--executable-path","%s","--headless","--no-sandbox"]' "$executable_path"
    else
        printf '["-y","@playwright/mcp@latest","--browser","chromium","--headless","--no-sandbox"]'
    fi
}

# Playwright MCP — uses the local Playwright Chromium on ARM where Chrome stable
# is not available as /opt/google/chrome/chrome.
configure_playwright_mcp() {
    local target_home="$1"
    local settings_file="$target_home/.claude/settings.json"
    local args_json

    mkdir -p "$target_home/.claude"
    if [ ! -f "$settings_file" ]; then
        echo '{}' > "$settings_file"
    fi
    if command -v jq >/dev/null 2>&1; then
        args_json="$(playwright_mcp_args_json "$target_home")"
        jq --argjson args "$args_json" '
            .mcpServers.playwright = {
                "command": "npx",
                "args": $args
            }
        ' "$settings_file" > "${settings_file}.tmp" \
            && mv "${settings_file}.tmp" "$settings_file"
    fi
}

# Codex TUI defaults — idempotent and non-destructive
configure_codex_tui() {
    local target_home="$1"
    local codex_dir="$target_home/.codex"
    local config_file="$codex_dir/config.toml"
    local tmp_file="$config_file.tmp.$$"
    local cleaned_file="$config_file.cleaned.$$"

    mkdir -p "$codex_dir"
    [ -f "$config_file" ] || touch "$config_file"

    awk '
        BEGIN {
            in_shipglows_block = 0
        }
        /^# >>> shipglows codex tui >>>$/ {
            in_shipglows_block = 1
            next
        }
        /^# <<< shipglows codex tui <<<$/ {
            in_shipglows_block = 0
            next
        }
        /^# >>> shipglows codex tui >>>$/ {
            in_shipglows_block = 1
            next
        }
        /^# <<< shipglows codex tui <<<$/ {
            in_shipglows_block = 0
            next
        }
        in_shipglows_block {
            next
        }
        {
            print
        }
    ' "$config_file" > "$cleaned_file"

    local has_status_line
    local has_terminal_title
    local has_tui_table

    has_status_line=$(awk '
        BEGIN {
            before_table = 1
            in_tui_table = 0
            found = 0
        }
        before_table && /^[[:space:]]*tui[[:space:]]*\.[[:space:]]*status_line[[:space:]]*=/ {
            found = 1
        }
        /^\[[[:space:]]*tui[[:space:]]*\][[:space:]]*$/ {
            before_table = 0
            in_tui_table = 1
            next
        }
        /^\[[^]]+\][[:space:]]*$/ {
            before_table = 0
            in_tui_table = 0
            next
        }
        in_tui_table && /^[[:space:]]*status_line[[:space:]]*=/ {
            found = 1
        }
        END {
            print found
        }
    ' "$cleaned_file")

    has_terminal_title=$(awk '
        BEGIN {
            before_table = 1
            in_tui_table = 0
            found = 0
        }
        before_table && /^[[:space:]]*tui[[:space:]]*\.[[:space:]]*terminal_title[[:space:]]*=/ {
            found = 1
        }
        /^\[[[:space:]]*tui[[:space:]]*\][[:space:]]*$/ {
            before_table = 0
            in_tui_table = 1
            next
        }
        /^\[[^]]+\][[:space:]]*$/ {
            before_table = 0
            in_tui_table = 0
            next
        }
        in_tui_table && /^[[:space:]]*terminal_title[[:space:]]*=/ {
            found = 1
        }
        END {
            print found
        }
    ' "$cleaned_file")

    has_tui_table=$(awk '
        BEGIN {
            found = 0
        }
        /^\[[[:space:]]*tui[[:space:]]*\][[:space:]]*$/ {
            found = 1
        }
        END {
            print found
        }
    ' "$cleaned_file")

    if [ "$has_status_line" -eq 0 ] || [ "$has_terminal_title" -eq 0 ]; then
        if [ "$has_tui_table" -eq 1 ]; then
            awk \
                -v add_status="$has_status_line" \
                -v add_title="$has_terminal_title" '
                BEGIN {
                    in_tui = 0
                    inserted = 0
                }
                /^\[[[:space:]]*tui[[:space:]]*\][[:space:]]*$/ {
                    in_tui = 1
                    print
                    next
                }
                in_tui && /^\[[^]]+\][[:space:]]*$/ {
                    if (inserted == 0) {
                        print "# >>> shipglows codex tui >>>"
                        if (add_status == 0) {
                            print "status_line = [\"model-with-reasoning\", \"current-dir\", \"context-remaining\", \"five-hour-limit\", \"weekly-limit\"]"
                        }
                        if (add_title == 0) {
                            print "terminal_title = [\"spinner\", \"thread\", \"project\"]"
                        }
                        print "# <<< shipglows codex tui <<<"
                        inserted = 1
                    }
                    in_tui = 0
                    print
                    next
                }
                {
                    print
                }
                END {
                    if (in_tui == 1 && inserted == 0) {
                        print "# >>> shipglows codex tui >>>"
                        if (add_status == 0) {
                            print "status_line = [\"model-with-reasoning\", \"current-dir\", \"context-remaining\", \"five-hour-limit\", \"weekly-limit\"]"
                        }
                        if (add_title == 0) {
                            print "terminal_title = [\"spinner\", \"thread\", \"project\"]"
                        }
                        print "# <<< shipglows codex tui <<<"
                    }
                }
            ' "$cleaned_file" > "$tmp_file"
        else
            {
                printf '# >>> shipglows codex tui >>>\n'
                if [ "$has_status_line" -eq 0 ]; then
                    printf 'tui.status_line = ["model-with-reasoning", "current-dir", "context-remaining", "five-hour-limit", "weekly-limit"]\n'
                fi
                if [ "$has_terminal_title" -eq 0 ]; then
                    printf 'tui.terminal_title = ["spinner", "thread", "project"]\n'
                fi
                printf '# <<< shipglows codex tui <<<\n'
                printf '\n'
                cat "$cleaned_file"
            } > "$tmp_file"
        fi
    else
        cat "$cleaned_file" > "$tmp_file"
    fi

    mv "$tmp_file" "$config_file"
    rm -f "$cleaned_file"
}

configure_codex_rmcp() {
    local target_home="$1"
    local codex_dir="$target_home/.codex"
    local config_file="$codex_dir/config.toml"
    local tmp_file="$config_file.tmp.$$"
    local cleaned_file="$config_file.cleaned-rmcp.$$"

    mkdir -p "$codex_dir"
    [ -f "$config_file" ] || touch "$config_file"

    awk '
        BEGIN {
            in_shipglows_block = 0
        }
        /^# >>> shipglows codex rmcp >>>$/ {
            in_shipglows_block = 1
            next
        }
        /^# <<< shipglows codex rmcp <<<$/ {
            in_shipglows_block = 0
            next
        }
        /^# >>> shipglows codex rmcp >>>$/ {
            in_shipglows_block = 1
            next
        }
        /^# <<< shipglows codex rmcp <<<$/ {
            in_shipglows_block = 0
            next
        }
        in_shipglows_block {
            next
        }
        {
            print
        }
    ' "$config_file" > "$cleaned_file"

    local has_beta_table
    local has_rmcp

    has_beta_table=$(awk '
        BEGIN { found = 0 }
        /^\[[[:space:]]*beta[[:space:]]*\][[:space:]]*$/ { found = 1 }
        END { print found }
    ' "$cleaned_file")

    has_rmcp=$(awk '
        BEGIN {
            in_beta = 0
            found = 0
        }
        /^[[:space:]]*beta[[:space:]]*\.[[:space:]]*rmcp[[:space:]]*=/ {
            found = 1
        }
        /^\[[[:space:]]*beta[[:space:]]*\][[:space:]]*$/ {
            in_beta = 1
            next
        }
        /^\[[^]]+\][[:space:]]*$/ {
            in_beta = 0
            next
        }
        in_beta && /^[[:space:]]*rmcp[[:space:]]*=/ {
            found = 1
        }
        END { print found }
    ' "$cleaned_file")

    if [ "$has_rmcp" -eq 1 ]; then
        cat "$cleaned_file" > "$tmp_file"
    elif [ "$has_beta_table" -eq 1 ]; then
        awk '
            BEGIN {
                in_beta = 0
                inserted = 0
            }
            /^\[[[:space:]]*beta[[:space:]]*\][[:space:]]*$/ {
                in_beta = 1
                print
                next
            }
            in_beta && /^\[[^]]+\][[:space:]]*$/ {
                if (inserted == 0) {
                    print "# >>> shipglows codex rmcp >>>"
                    print "rmcp = true"
                    print "# <<< shipglows codex rmcp <<<"
                    inserted = 1
                }
                in_beta = 0
                print
                next
            }
            {
                print
            }
            END {
                if (in_beta == 1 && inserted == 0) {
                    print "# >>> shipglows codex rmcp >>>"
                    print "rmcp = true"
                    print "# <<< shipglows codex rmcp <<<"
                }
            }
        ' "$cleaned_file" > "$tmp_file"
    else
        {
            cat "$cleaned_file"
            printf '\n'
            printf '# >>> shipglows codex rmcp >>>\n'
            printf '[beta]\n'
            printf 'rmcp = true\n'
            printf '# <<< shipglows codex rmcp <<<\n'
        } > "$tmp_file"
    fi

    mv "$tmp_file" "$config_file"
    rm -f "$cleaned_file"
}

# Context7 MCP for Codex — stdio transport, registered disabled by default.
configure_codex_context7_mcp() {
    local target_home="$1"
    local codex_dir="$target_home/.codex"
    local config_file="$codex_dir/config.toml"
    local tmp_file="$config_file.tmp.$$"

    mkdir -p "$codex_dir"
    [ -f "$config_file" ] || touch "$config_file"

    awk '
        /^# >>> shipglows codex context7 mcp >>>$/ { skip = 1; next }
        /^# <<< shipglows codex context7 mcp <<</ { skip = 0; next }
        /^# >>> shipglows codex context7 mcp >>>$/ { skip = 1; next }
        /^# <<< shipglows codex context7 mcp <<</ { skip = 0; next }
        /^\[mcp_servers\.context7\]$/ { skip = 1; next }
        /^\[/ && $0 !~ /^\[mcp_servers\.context7\]$/ && skip == 1 { skip = 0 }
        !skip { print }
    ' "$config_file" > "$tmp_file"

    {
        printf '\n'
        printf '# >>> shipglows codex context7 mcp >>>\n'
        printf '[mcp_servers.context7]\n'
        printf 'command = "npx"\n'
        printf 'args = ["-y", "@upstash/context7-mcp@latest"]\n'
        printf 'enabled = false\n'
        printf '# <<< shipglows codex context7 mcp <<<\n'
    } >> "$tmp_file"

    mv "$tmp_file" "$config_file"
}

# Vercel MCP for Codex — remote HTTP transport, registered disabled by default.
configure_codex_vercel_mcp() {
    local target_home="$1"
    local codex_dir="$target_home/.codex"
    local config_file="$codex_dir/config.toml"
    local tmp_file="$config_file.tmp.$$"

    mkdir -p "$codex_dir"
    [ -f "$config_file" ] || touch "$config_file"

    awk '
        /^# >>> shipglows codex vercel mcp >>>$/ { skip = 1; next }
        /^# <<< shipglows codex vercel mcp <<</ { skip = 0; next }
        /^# >>> shipglows codex vercel mcp >>>$/ { skip = 1; next }
        /^# <<< shipglows codex vercel mcp <<</ { skip = 0; next }
        /^\[mcp_servers\.vercel\]$/ { skip = 1; next }
        /^\[/ && $0 !~ /^\[mcp_servers\.vercel\]$/ && skip == 1 { skip = 0 }
        !skip { print }
    ' "$config_file" > "$tmp_file"

    {
        printf '\n'
        printf '# >>> shipglows codex vercel mcp >>>\n'
        printf '[mcp_servers.vercel]\n'
        printf 'url = "https://mcp.vercel.com"\n'
        printf 'enabled = false\n'
        printf '# <<< shipglows codex vercel mcp <<<\n'
    } >> "$tmp_file"

    mv "$tmp_file" "$config_file"
}

# Convex MCP for Codex — stdio transport, registered disabled by default.
configure_codex_convex_mcp() {
    local target_home="$1"
    local codex_dir="$target_home/.codex"
    local config_file="$codex_dir/config.toml"
    local tmp_file="$config_file.tmp.$$"

    mkdir -p "$codex_dir"
    [ -f "$config_file" ] || touch "$config_file"

    awk '
        /^# >>> shipglows codex convex mcp >>>$/ { skip = 1; next }
        /^# <<< shipglows codex convex mcp <<</ { skip = 0; next }
        /^# >>> shipglows codex convex mcp >>>$/ { skip = 1; next }
        /^# <<< shipglows codex convex mcp <<</ { skip = 0; next }
        /^\[mcp_servers\.convex\]$/ { skip = 1; next }
        /^\[/ && $0 !~ /^\[mcp_servers\.convex\]$/ && skip == 1 { skip = 0 }
        !skip { print }
    ' "$config_file" > "$tmp_file"

    {
        printf '\n'
        printf '# >>> shipglows codex convex mcp >>>\n'
        printf '[mcp_servers.convex]\n'
        printf 'command = "npx"\n'
        printf 'args = ["-y", "convex@latest", "mcp", "start"]\n'
        printf 'enabled = false\n'
        printf '# <<< shipglows codex convex mcp <<<\n'
    } >> "$tmp_file"

    mv "$tmp_file" "$config_file"
}

# Clerk MCP for Codex — remote HTTP transport, registered disabled by default.
configure_codex_clerk_mcp() {
    local target_home="$1"
    local codex_dir="$target_home/.codex"
    local config_file="$codex_dir/config.toml"
    local tmp_file="$config_file.tmp.$$"

    mkdir -p "$codex_dir"
    [ -f "$config_file" ] || touch "$config_file"

    awk '
        /^# >>> shipglows codex clerk mcp >>>$/ { skip = 1; next }
        /^# <<< shipglows codex clerk mcp <<</ { skip = 0; next }
        /^# >>> shipglows codex clerk mcp >>>$/ { skip = 1; next }
        /^# <<< shipglows codex clerk mcp <<</ { skip = 0; next }
        /^\[mcp_servers\.clerk\]$/ { skip = 1; next }
        /^\[/ && $0 !~ /^\[mcp_servers\.clerk\]$/ && skip == 1 { skip = 0 }
        !skip { print }
    ' "$config_file" > "$tmp_file"

    {
        printf '\n'
        printf '# >>> shipglows codex clerk mcp >>>\n'
        printf '[mcp_servers.clerk]\n'
        printf 'url = "https://mcp.clerk.com/mcp"\n'
        printf 'enabled = false\n'
        printf '# <<< shipglows codex clerk mcp <<<\n'
    } >> "$tmp_file"

    mv "$tmp_file" "$config_file"
}

# Supabase MCP for Codex — remote HTTP transport, registered disabled by default.
configure_codex_supabase_mcp() {
    local target_home="$1"
    local codex_dir="$target_home/.codex"
    local config_file="$codex_dir/config.toml"
    local tmp_file="$config_file.tmp.$$"

    mkdir -p "$codex_dir"
    [ -f "$config_file" ] || touch "$config_file"

    awk '
        /^# >>> shipglows codex supabase mcp >>>$/ { skip = 1; next }
        /^# <<< shipglows codex supabase mcp <<</ { skip = 0; next }
        /^# >>> shipglows codex supabase mcp >>>$/ { skip = 1; next }
        /^# <<< shipglows codex supabase mcp <<</ { skip = 0; next }
        /^\[mcp_servers\.supabase\]$/ { skip = 1; next }
        /^\[/ && $0 !~ /^\[mcp_servers\.supabase\]$/ && skip == 1 { skip = 0 }
        !skip { print }
    ' "$config_file" > "$tmp_file"

    {
        printf '\n'
        printf '# >>> shipglows codex supabase mcp >>>\n'
        printf '[mcp_servers.supabase]\n'
        printf 'url = "https://mcp.supabase.com/mcp"\n'
        printf 'enabled = false\n'
        printf '# <<< shipglows codex supabase mcp <<<\n'
    } >> "$tmp_file"

    mv "$tmp_file" "$config_file"
}

# DataForSEO MCP for Codex — stdio transport. Kept disabled unless credentials
# are exported when ShipGlows runs the installer.
configure_codex_dataforseo_mcp() {
    local target_home="$1"
    local codex_dir="$target_home/.codex"
    local config_file="$codex_dir/config.toml"
    local tmp_file="$config_file.tmp.$$"
    local enabled="false"
    local enable_dataforseo="${SHIPGLOWS_ENABLE_DATAFORSEO_MCP:-${SHIPGLOWS_ENABLE_DATAFORSEO_MCP:-0}}"
    local command="npx"
    local args='["-y", "dataforseo-mcp-server"]'
    local doppler_project="${SHIPGLOWS_DATAFORSEO_DOPPLER_PROJECT:-${SHIPGLOWS_DATAFORSEO_DOPPLER_PROJECT:-contentflow_app}}"
    local doppler_config="${SHIPGLOWS_DATAFORSEO_DOPPLER_CONFIG:-${SHIPGLOWS_DATAFORSEO_DOPPLER_CONFIG:-prd}}"

    mkdir -p "$codex_dir"
    [ -f "$config_file" ] || touch "$config_file"

    if command -v doppler >/dev/null 2>&1; then
        [ "$enable_dataforseo" = "1" ] && enabled="true"
        command="doppler"
        args="[\"run\", \"--project\", \"$doppler_project\", \"--config\", \"$doppler_config\", \"--\", \"bash\", \"-lc\", \"export DATAFORSEO_USERNAME=\\\"\${DATAFORSEO_USERNAME:-\${DATAFORSEO_LOGIN:-}}\\\"; exec npx -y dataforseo-mcp-server\"]"
    elif [ "$enable_dataforseo" = "1" ] && [ -n "${DATAFORSEO_USERNAME:-${DATAFORSEO_LOGIN:-}}" ] && [ -n "${DATAFORSEO_PASSWORD:-}" ]; then
        enabled="true"
    fi

    awk '
        /^# >>> shipglows codex dataforseo mcp >>>$/ { skip = 1; next }
        /^# <<< shipglows codex dataforseo mcp <<</ { skip = 0; next }
        /^# >>> shipglows codex dataforseo mcp >>>$/ { skip = 1; next }
        /^# <<< shipglows codex dataforseo mcp <<</ { skip = 0; next }
        /^\[mcp_servers\.dataforseo\]$/ { skip = 1; next }
        /^\[/ && $0 !~ /^\[mcp_servers\.dataforseo\]$/ && skip == 1 { skip = 0 }
        !skip { print }
    ' "$config_file" > "$tmp_file"

    {
        printf '\n'
        printf '# >>> shipglows codex dataforseo mcp >>>\n'
        printf '[mcp_servers.dataforseo]\n'
        printf 'command = "%s"\n' "$command"
        printf 'args = %s\n' "$args"
        printf 'enabled = %s\n' "$enabled"
        printf '# <<< shipglows codex dataforseo mcp <<<\n'
    } >> "$tmp_file"

    mv "$tmp_file" "$config_file"
}

# Playwright MCP for Codex — stdio transport, registered disabled by default.
configure_codex_playwright_mcp() {
    local target_home="$1"
    local codex_dir="$target_home/.codex"
    local config_file="$codex_dir/config.toml"
    local tmp_file="$config_file.tmp.$$"
    local args_json

    mkdir -p "$codex_dir"
    [ -f "$config_file" ] || touch "$config_file"

    awk '
        /^# >>> shipglows codex playwright mcp >>>$/ { skip = 1; next }
        /^# <<< shipglows codex playwright mcp <<</ { skip = 0; next }
        /^# >>> shipglows codex playwright mcp >>>$/ { skip = 1; next }
        /^# <<< shipglows codex playwright mcp <<</ { skip = 0; next }
        /^\[mcp_servers\.playwright(\.|\])?/ { skip = 1; next }
        /^\[/ && $0 !~ /^\[mcp_servers\.playwright(\.|\])?/ && skip == 1 { skip = 0 }
        !skip { print }
    ' "$config_file" > "$tmp_file"

    args_json="$(playwright_mcp_args_json "$target_home")"
    {
        printf '\n'
        printf '# >>> shipglows codex playwright mcp >>>\n'
        printf '[mcp_servers.playwright]\n'
        printf 'command = "npx"\n'
        printf 'args = %s\n' "$args_json"
        printf 'enabled = false\n'
        printf '\n'
        printf '[mcp_servers.playwright.tools]\n'
        printf 'browser_snapshot = {}\n'
        printf 'browser_click = {}\n'
        printf 'browser_type = {}\n'
        printf 'browser_take_screenshot = {}\n'
        printf 'browser_console_messages = {}\n'
        printf 'browser_network_requests = {}\n'
        printf 'browser_run_code = {}\n'
        printf '\n'
        printf '[mcp_servers.playwright.tools.browser_navigate]\n'
        printf 'approval_mode = "approve"\n'
        printf '\n'
        printf '[mcp_servers.playwright.tools.browser_resize]\n'
        printf 'approval_mode = "approve"\n'
        printf '# <<< shipglows codex playwright mcp <<<\n'
    } >> "$tmp_file"

    mv "$tmp_file" "$config_file"
}

# Configure skills symlinks for a user
ensure_skill_link() {
    local source_dir="$1"
    local target_path="$2"
    local resolved_target
    local backup_dir
    local normalized_source

    if [ -L "$target_path" ]; then
        resolved_target=$(readlink -f "$target_path" 2>/dev/null || true)
        normalized_source=$(readlink -f "${source_dir%/}" 2>/dev/null || true)
        if [ -n "$resolved_target" ] && [ "$resolved_target" = "$normalized_source" ]; then
            return 0
        fi
        rm -f "$target_path"
        ln -s "${source_dir%/}" "$target_path"
        return $?
    fi

    if [ -e "$target_path" ]; then
        backup_dir="$(dirname "$target_path")/.backup-$(date '+%Y%m%d-%H%M%S')"
        mkdir -p "$backup_dir"
        mv "$target_path" "$backup_dir/"
    fi

    ln -s "${source_dir%/}" "$target_path"
}

verify_skill_link() {
    local target_path="$1"
    [ -L "$target_path" ] && [ -f "$target_path/SKILL.md" ]
}

cleanup_legacy_skill_entries() {
    local skills_home="$1"
    local legacy_entry="$skills_home/references"

    if [ -L "$legacy_entry" ]; then
        rm -f "$legacy_entry"
    fi
}

configure_skills() {
    local target_home="$1"
    local sync_helper="$SHIPGLOWS_INSTALL_ROOT/tools/shipglows_sync_skills.sh"

    if [ ! -d "$SHIPGLOWS_INSTALL_ROOT/skills" ]; then
        warning "Dossier skills introuvable: $SHIPGLOWS_INSTALL_ROOT/skills"
        return 1
    fi
    if [ ! -f "$sync_helper" ]; then
        warning "Helper de synchronisation des skills introuvable: $sync_helper"
        return 1
    fi

    mkdir -p "$target_home/.claude/skills"
    mkdir -p "$target_home/.codex/skills"
    cleanup_legacy_skill_entries "$target_home/.claude/skills"
    cleanup_legacy_skill_entries "$target_home/.codex/skills"

    if ! bash "$sync_helper" --repair --all --target-home "$target_home" \
        --shipglows-root "$SHIPGLOWS_INSTALL_ROOT" --runtime all --backup-existing; then
        warning "Synchronisation des skills incomplète pour $target_home"
        return 1
    fi

    if ! bash "$sync_helper" --check --all --target-home "$target_home" \
        --shipglows-root "$SHIPGLOWS_INSTALL_ROOT" --runtime all; then
        warning "Vérification des skills incomplète pour $target_home"
        return 1
    fi

    echo -e "  ${GREEN}✅ Skills liés :${NC} Claude + Codex synchronisés"
    return 0
}

# Configure aliases in bashrc
configure_aliases() {
    local bashrc="$1/.bashrc"
    local autonomy_mode="${2:-standard}"
    local c_alias
    local coask_alias

    if [ "$autonomy_mode" = "permissive" ]; then
        c_alias='claude --dangerously-skip-permissions --permission-mode bypassPermissions'
    else
        c_alias='claude --permission-mode default'
    fi

    coask_alias='codex --ask-for-approval on-request --sandbox workspace-write'

    [ -f "$bashrc" ] || touch "$bashrc"
    sed -i '/^# >>> ShipGlows AI aliases >>>$/,/^# <<< ShipGlows AI aliases <<<$/{d}' "$bashrc"
    sed -i '/^# >>> ShipGlows AI aliases >>>$/,/^# <<< ShipGlows AI aliases <<<$/{d}' "$bashrc"
    sed -i '/^alias \(shipglows\|sg\|c\|co\|cask\|coask\|ch\|re\|reload\|update-codex\)=/d' "$bashrc"
    cat >> "$bashrc" << ALIASES

# >>> ShipGlows AI aliases >>>
alias shipglows='$SHIPGLOWS_INSTALL_ROOT/cli/shipglows.sh'
alias sg='$SHIPGLOWS_INSTALL_ROOT/cli/shipglows.sh'
alias c='$c_alias'
alias co='codex'
function update-codex {
    local latest installed
    latest="\$(pnpm view @openai/codex@latest version)" || return 1
    pnpm add -g "@openai/codex@\$latest" || return 1
    hash -r
    installed="\$(codex --version | awk '{print \$2}')"
    if [ "\$installed" != "\$latest" ]; then
        printf 'Codex update mismatch: installed=%s latest=%s\n' "\$installed" "\$latest" >&2
        return 1
    fi
    printf 'codex-cli %s\n' "\$installed"
}
alias cask='claude --permission-mode default'
alias coask='$coask_alias'
alias ch='clear; tmux clear-history'
alias re='source ~/.bashrc && echo "✓ Shell reloaded"'
alias reload='source ~/.bashrc && echo "✓ Shell reloaded"'
# <<< ShipGlows AI aliases <<<
ALIASES
}

configure_shipglows_environment() {
    local target_home="$1"
    local bashrc="$target_home/.bashrc"
    [ -f "$bashrc" ] || return 0

    sed -i '/^# >>> ShipGlows environment >>>$/,/^# <<< ShipGlows environment <<<$/{d}' "$bashrc"
    sed -i '/^# >>> ShipGlows environment >>>$/,/^# <<< ShipGlows environment <<<$/{d}' "$bashrc"
    cat >> "$bashrc" << ENV

# >>> ShipGlows environment >>>
export SHIPGLOWS_ROOT='$SHIPGLOWS_INSTALL_ROOT'
export SHIPGLOWS_ROOT='$SHIPGLOWS_INSTALL_ROOT'

if [ -d "\$HOME/.local/bin" ]; then
  export PATH="\$HOME/.local/bin:\$PATH"
fi

# Flutter / Android shared tooling, when installed for this user.
if [ -d "\$HOME/flutter/bin" ]; then
  export PATH="\$HOME/flutter/bin:\$PATH"
fi

if [ -d "\$HOME/Android/Sdk" ]; then
  export ANDROID_HOME="\$HOME/Android/Sdk"
  export ANDROID_SDK_ROOT="\$HOME/Android/Sdk"
  export PATH="\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:\$PATH"
fi

if [ -d "/usr/lib/jvm/java-17-openjdk-arm64" ]; then
  export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-arm64"
elif [ -d "/usr/lib/jvm/java-17-openjdk-amd64" ]; then
  export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
fi

case "\$(uname -m 2>/dev/null)" in
  aarch64|arm64)
    export SHIPGLOWS_ANDROID_RELEASE_BUILD_POLICY="ci-x64-required"
    export SHIPGLOWS_ANDROID_RELEASE_BUILD_POLICY="ci-x64-required"
    ;;
esac
# <<< ShipGlows environment <<<
ENV
}

configure_command_wrappers() {
    local shipglows_target="$SHIPGLOWS_INSTALL_ROOT/shipglows.sh"
    local gsc_target="$SHIPGLOWS_INSTALL_ROOT/cli/shipglows-gsc.sh"
    local turso_login_target="$SHIPGLOWS_INSTALL_ROOT/local/turso-login.sh"
    local turso_ssh_target="$SHIPGLOWS_INSTALL_ROOT/local/turso-ssh.sh"
    local bin_dir="/usr/local/bin"

    mkdir -p "$bin_dir"
    ln -sf "$shipglows_target" "$bin_dir/shipglows"
    ln -sf "$shipglows_target" "$bin_dir/sg"
    if [ -f "$gsc_target" ]; then
        ln -sf "$gsc_target" "$bin_dir/shipglows-gsc"
        ln -sf "$gsc_target" "$bin_dir/gsc"
    fi
    if [ -f "$turso_login_target" ]; then
        ln -sf "$turso_login_target" "$bin_dir/shipglows-turso-login"
        ln -sf "$turso_login_target" "$bin_dir/turso-login"
    fi
    if [ -f "$turso_ssh_target" ]; then
        ln -sf "$turso_ssh_target" "$bin_dir/shipglows-turso-ssh"
        ln -sf "$turso_ssh_target" "$bin_dir/turso-ssh"
    fi
    chmod +x "$bin_dir/shipglows" "$bin_dir/sg" "$bin_dir/shipglows-gsc" "$bin_dir/gsc" "$bin_dir/shipglows-turso-login" "$bin_dir/turso-login" "$bin_dir/shipglows-turso-ssh" "$bin_dir/turso-ssh" 2>/dev/null || true

    if [ -x "$bin_dir/shipglows" ] && [ -x "$bin_dir/sg" ]; then
        echo -e "  ${GREEN}✅ Commandes système disponibles :${NC} /usr/local/bin/shipglows et /usr/local/bin/sg"
    else
        echo -e "  ${YELLOW}⚠️ Commandes /usr/local/bin/shipglows ou /usr/local/bin/sg non trouvées${NC}"
    fi
    if [ -x "$bin_dir/shipglows-turso-login" ]; then
        echo -e "  ${GREEN}✅ Commande Turso login disponible :${NC} /usr/local/bin/shipglows-turso-login"
    fi
    if [ -x "$bin_dir/shipglows-turso-ssh" ]; then
        echo -e "  ${GREEN}✅ Commande Turso SSH disponible :${NC} /usr/local/bin/shipglows-turso-ssh"
    fi
    if [ -x "$bin_dir/shipglows-gsc" ]; then
        echo -e "  ${GREEN}✅ Commande Google Search Console disponible :${NC} /usr/local/bin/shipglows-gsc"
    fi
}

install_shipglows_tui_for_user() {
    local target_home="$1"
    local username="$2"
    local installer="$SHIPGLOWS_INSTALL_ROOT/tui/scripts/install-shipglows-tui.sh"

    if [ "${SHIPGLOWS_SKIP_TUI_INSTALL:-${SHIPGLOWS_SKIP_TUI_INSTALL:-0}}" = "1" ] || [ "${SHIPGLOWS_INSTALL_TUI:-1}" != "1" ]; then
        echo -e "  ${YELLOW}⚠️ ShipGlows TUI ignorée pour :${NC} $username"
        return 0
    fi

    if [ "$username" = "root" ] && [ "${SHIPGLOWS_INSTALL_TUI_FOR_ROOT:-${SHIPGLOWS_INSTALL_TUI_FOR_ROOT:-0}}" != "1" ] && [ "${#TARGET_USERS[@]}" -gt 0 ]; then
        echo -e "  ${BLUE}ℹ️ ShipGlows TUI installée côté utilisateur quotidien, pas côté root${NC}"
        return 0
    fi

    if [ ! -f "$installer" ]; then
        warning "Installateur TUI introuvable: $installer"
        return 1
    fi

    if [ "$username" = "root" ]; then
        HOME="$target_home" bash "$installer" || {
            warning "Installation ShipGlows TUI incomplète pour $username"
            return 1
        }
    else
        sudo -u "$username" -H bash "$installer" || {
            warning "Installation ShipGlows TUI incomplète pour $username"
            return 1
        }
    fi

    echo -e "  ${GREEN}✅ ShipGlows TUI installée :${NC} tui, shipglows-tui, sg-tui"
    return 0
}

ensure_user_local_npm_bootstrap() {
    local user_home="$1"
    local username="$2"
    local bashrc="$user_home/.bashrc"
    local pnpm_home="$user_home/.local/share/pnpm"
    [ -f "$bashrc" ] || touch "$bashrc"
    mkdir -p "$pnpm_home"
    chown -R "$username:$username" "$pnpm_home" 2>/dev/null || true

    sed -i '/^# >>> ShipGlows pnpm bootstrap >>>$/,/^# <<< ShipGlows pnpm bootstrap <<<$/{d}' "$bashrc"
    sed -i '/^# >>> ShipGlows pnpm bootstrap >>>$/,/^# <<< ShipGlows pnpm bootstrap <<<$/{d}' "$bashrc"
    cat >> "$bashrc" << 'BOOTSTRAP'

# >>> ShipGlows pnpm bootstrap >>>
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
# <<< ShipGlows pnpm bootstrap <<<
BOOTSTRAP
}

install_ai_agent_clis_for_user() {
    local user_home="$1"
    local username="$2"
    if [ "$username" = "root" ]; then
        return 0
    fi
    ensure_user_local_npm_bootstrap "$user_home" "$username"
    if [ "${SHIPGLOWS_INSTALL_AGENT_CLAUDE:-0}" = "1" ]; then
        sudo -u "$username" -H bash -lc 'export PNPM_HOME="$HOME/.local/share/pnpm"; export PATH="$PNPM_HOME:$PATH"; corepack prepare pnpm@latest --activate >/dev/null 2>&1; command -v claude >/dev/null 2>&1 || pnpm add -g @anthropic-ai/claude-code' || return 1
    fi
    if [ "${SHIPGLOWS_INSTALL_AGENT_CODEX:-0}" = "1" ]; then
        sudo -u "$username" -H bash -lc 'export PNPM_HOME="$HOME/.local/share/pnpm"; export PATH="$PNPM_HOME:$PATH"; corepack prepare pnpm@latest --activate >/dev/null 2>&1; command -v codex >/dev/null 2>&1 || pnpm add -g @openai/codex' || return 1
    fi
    if [ "${SHIPGLOWS_INSTALL_AGENT_OPENCODE:-0}" = "1" ]; then
        sudo -u "$username" -H bash -lc 'export PNPM_HOME="$HOME/.local/share/pnpm"; export PATH="$PNPM_HOME:$PATH"; corepack prepare pnpm@latest --activate >/dev/null 2>&1; command -v opencode >/dev/null 2>&1 || pnpm add -g opencode-ai' || return 1
    fi
    if [ "${SHIPGLOWS_INSTALL_AGENT_KILOCODE:-0}" = "1" ]; then
        sudo -u "$username" -H bash -lc 'export PNPM_HOME="$HOME/.local/share/pnpm"; export PATH="$PNPM_HOME:$PATH"; corepack prepare pnpm@latest --activate >/dev/null 2>&1; command -v kilocode >/dev/null 2>&1 || pnpm add -g @kilocode/cli' || return 1
    fi
    return 0
}

verify_ai_agent_clis_for_user() {
    local user_home="$1"
    local username="$2"
    local missing=0
    local status_output=""
    local claude_path=""
    local codex_path=""
    local opencode_path=""
    local kilocode_path=""

    if [ "$username" = "root" ]; then
        return 0
    fi

    claude_path=$(sudo -u "$username" -H bash -lc 'export PNPM_HOME="$HOME/.local/share/pnpm"; export PATH="$PNPM_HOME:$PATH"; command -v claude 2>/dev/null || true')
    codex_path=$(sudo -u "$username" -H bash -lc 'export PNPM_HOME="$HOME/.local/share/pnpm"; export PATH="$PNPM_HOME:$PATH"; command -v codex 2>/dev/null || true')
    opencode_path=$(sudo -u "$username" -H bash -lc 'export PNPM_HOME="$HOME/.local/share/pnpm"; export PATH="$PNPM_HOME:$PATH"; command -v opencode 2>/dev/null || true')
    kilocode_path=$(sudo -u "$username" -H bash -lc 'export PNPM_HOME="$HOME/.local/share/pnpm"; export PATH="$PNPM_HOME:$PATH"; command -v kilocode 2>/dev/null || true')

    if [ "${SHIPGLOWS_INSTALL_AGENT_CLAUDE:-0}" = "1" ] && [ -n "$claude_path" ]; then
        status_output="${status_output} claude=${claude_path}"
    elif [ "${SHIPGLOWS_INSTALL_AGENT_CLAUDE:-0}" = "1" ]; then
        status_output="${status_output} claude=MISSING"
        missing=1
    else
        status_output="${status_output} claude=SKIPPED"
    fi

    if [ "${SHIPGLOWS_INSTALL_AGENT_CODEX:-0}" = "1" ] && [ -n "$codex_path" ]; then
        status_output="${status_output} codex=${codex_path}"
    elif [ "${SHIPGLOWS_INSTALL_AGENT_CODEX:-0}" = "1" ]; then
        status_output="${status_output} codex=MISSING"
        missing=1
    else
        status_output="${status_output} codex=SKIPPED"
    fi

    if [ "${SHIPGLOWS_INSTALL_AGENT_OPENCODE:-0}" = "1" ] && [ -n "$opencode_path" ]; then
        status_output="${status_output} opencode=${opencode_path}"
    elif [ "${SHIPGLOWS_INSTALL_AGENT_OPENCODE:-0}" = "1" ]; then
        status_output="${status_output} opencode=MISSING"
        missing=1
    else
        status_output="${status_output} opencode=SKIPPED"
    fi

    if [ "${SHIPGLOWS_INSTALL_AGENT_KILOCODE:-0}" = "1" ] && [ -n "$kilocode_path" ]; then
        status_output="${status_output} kilocode=${kilocode_path}"
    elif [ "${SHIPGLOWS_INSTALL_AGENT_KILOCODE:-0}" = "1" ]; then
        status_output="${status_output} kilocode=MISSING"
        missing=1
    else
        status_output="${status_output} kilocode=SKIPPED"
    fi

    if [ "$missing" -ne 0 ]; then
        warning "Vérification agents IA incomplète pour $username:${status_output}"
        warning "Action recommandée: relancer l'installation avec les agents voulus, ou installer seulement les paquets manquants via pnpm dans PNPM_HOME."
        return 1
    fi

    info "Agents IA vérifiés pour $username:${status_output}"
    return 0
}

configure_claude_autonomous_permissions() {
    local target_home="$1"
    local mode="${2:-standard}"
    local settings_file="$target_home/.claude/settings.json"
    local default_mode
    local skip_prompt

    if [ "$mode" = "permissive" ]; then
        default_mode="bypassPermissions"
        skip_prompt="true"
    else
        default_mode="default"
        skip_prompt="false"
    fi

    mkdir -p "$target_home/.claude"
    [ -f "$settings_file" ] || echo '{}' > "$settings_file"
    jq --arg default_mode "$default_mode" --argjson skip_prompt "$skip_prompt" '
      .permissions = (.permissions // {})
      | .permissions.defaultMode = $default_mode
      | .permissions.skipDangerousModePermissionPrompt = $skip_prompt
    ' "$settings_file" > "${settings_file}.tmp" && mv "${settings_file}.tmp" "$settings_file"
}

configure_codex_autonomous_permissions() {
    local target_home="$1"
    local mode="${2:-standard}"
    local codex_dir="$target_home/.codex"
    local config_file="$codex_dir/config.toml"
    local tmp_file="$config_file.tmp.$$"
    local cleaned_file="$config_file.cleaned-autonomous.$$"
    local approval_policy
    local sandbox_mode

    if [ "$mode" = "permissive" ]; then
        approval_policy="never"
        sandbox_mode="danger-full-access"
    else
        approval_policy="on-request"
        sandbox_mode="workspace-write"
    fi

    mkdir -p "$codex_dir"
    [ -f "$config_file" ] || touch "$config_file"
    awk '
      BEGIN {
        before_table = 1
        in_shipglows_block = 0
      }
      /^# >>> shipglows codex autonomous >>>$/ {
        in_shipglows_block = 1
        next
      }
      /^# <<< shipglows codex autonomous <<<$/ {
        in_shipglows_block = 0
        next
      }
      in_shipglows_block {
        next
      }
      /^\[[^]]+\][[:space:]]*$/ {
        before_table = 0
      }
      before_table && /^[[:space:]]*approval_policy[[:space:]]*=/ {
        next
      }
      before_table && /^[[:space:]]*sandbox_mode[[:space:]]*=/ {
        next
      }
      {
        print
      }
    ' "$config_file" > "$cleaned_file"
    {
      printf '# >>> shipglows codex autonomous >>>\n'
      printf 'approval_policy = "%s"\n' "$approval_policy"
      printf 'sandbox_mode = "%s"\n' "$sandbox_mode"
      printf '# <<< shipglows codex autonomous <<<\n'
      printf '\n'
      cat "$cleaned_file"
    } > "$tmp_file"
    mv "$tmp_file" "$config_file"
    rm -f "$cleaned_file"
}

is_user_eligible() {
    local username="$1"
    local home shell
    [ "$username" = "root" ] && return 1
    home="$(getent passwd "$username" | cut -d: -f6)"
    shell="$(getent passwd "$username" | cut -d: -f7)"
    [ -z "$home" ] && return 1
    [ ! -d "$home" ] && return 1
    [ ! -w "$home" ] && return 1
    case "$shell" in
        *nologin|*false) return 1 ;;
    esac
    return 0
}

collect_target_users() {
    local mode="${SHIPGLOWS_INSTALL_USERS_MODE:-${SHIPGLOWS_INSTALL_USERS_MODE:-}}"
    local list="${SHIPGLOWS_INSTALL_USERS:-${SHIPGLOWS_INSTALL_USERS:-}}"
    local user
    TARGET_USERS=()
    REJECTED_USERS=()

    if [ "$mode" = "user-list" ]; then
        for user in $list; do
            if id "$user" >/dev/null 2>&1 && is_user_eligible "$user"; then
                TARGET_USERS+=("$user")
            else
                REJECTED_USERS+=("$user")
            fi
        done
    fi
}

target_users_summary() {
    local summary=""
    local user
    local seen=" "

    for user in "$PRIMARY_USER" "${TARGET_USERS[@]}"; do
        [ -n "$user" ] || continue
        case "$seen" in
            *" $user "*) continue ;;
        esac
        seen="$seen$user "
        if [ -n "$summary" ]; then
            summary="$summary, $user"
        else
            summary="$user"
        fi
    done

    printf '%s' "$summary"
}

# Full per-user setup
setup_user() {
    local user_home="$1"
    local username="$2"
    local effective_mode="${SHIPGLOWS_AUTONOMY_MODE_RESOLVED:-standard}"
    local setup_failed=0

    if [ "$username" = "root" ] && [ "$effective_mode" = "permissive" ] && [ "${SHIPGLOWS_ROOT_AUTONOMOUS_ALLOWED:-0}" != "1" ]; then
        effective_mode="standard"
        warning "Root garde un mode standard: l'autonomie permissive n'a pas ete explicitement autorisee."
    fi

    if [ "${SHIPGLOWS_INSTALL_AI_RUNTIME:-1}" = "1" ]; then
        configure_statusline "$user_home"
        configure_context7_mcp "$user_home"
        configure_vercel_mcp "$user_home"
        configure_convex_mcp "$user_home"
        configure_clerk_mcp "$user_home"
        configure_supabase_mcp "$user_home"
        configure_dataforseo_mcp "$user_home"
        configure_playwright_mcp "$user_home"
        configure_codex_tui "$user_home"
        configure_codex_rmcp "$user_home"
        configure_codex_context7_mcp "$user_home"
        configure_codex_vercel_mcp "$user_home"
        configure_codex_convex_mcp "$user_home"
        configure_codex_clerk_mcp "$user_home"
        configure_codex_supabase_mcp "$user_home"
        configure_codex_dataforseo_mcp "$user_home"
        configure_codex_playwright_mcp "$user_home"
    fi
    if [ "$username" != "root" ] && [ "${SHIPGLOWS_INSTALL_AI_AGENTS:-1}" = "1" ]; then
        install_ai_agent_clis_for_user "$user_home" "$username" || setup_failed=1
        verify_ai_agent_clis_for_user "$user_home" "$username" || setup_failed=1
    fi
    if [ "${SHIPGLOWS_INSTALL_AI_RUNTIME:-1}" = "1" ]; then
        configure_claude_autonomous_permissions "$user_home" "$effective_mode" || setup_failed=1
        configure_codex_autonomous_permissions "$user_home" "$effective_mode" || setup_failed=1
        if [ "${SHIPGLOWS_INSTALL_SKILL_CORPUS:-0}" = "1" ]; then
            configure_skills "$user_home" || setup_failed=1
        fi
    fi
    configure_shipglows_environment "$user_home"
    if [ "${SHIPGLOWS_INSTALL_AI_RUNTIME:-1}" = "1" ]; then
        configure_aliases "$user_home" "$effective_mode"
    fi
    install_shipglows_tui_for_user "$user_home" "$username" || setup_failed=1

    # Fix ownership — everything we created must belong to the user
    if [ "$username" != "root" ]; then
        chown -hR "$username:$username" "$user_home/.claude" 2>/dev/null || true
        chown -hR "$username:$username" "$user_home/.codex" 2>/dev/null || true
    fi

    if [ "$setup_failed" -eq 0 ]; then
        echo -e "  ${GREEN}✅ Utilisateur configuré :${NC} $username"
    else
        echo -e "  ${YELLOW}⚠️ Utilisateur configuré avec warnings :${NC} $username"
    fi
}

echo ""
echo -e "${BLUE}👥 Configuration par utilisateur...${NC}"
configure_command_wrappers

collect_target_users
resolve_autonomy_mode
resolve_root_autonomy_opt_in
resolve_install_components
info "Mode IA autonome ShipGlows: ${SHIPGLOWS_AUTONOMY_MODE_RESOLVED}"
info "Autonomie root: $([ "${SHIPGLOWS_ROOT_AUTONOMOUS_ALLOWED:-0}" = "1" ] && echo autorisee || echo standard)"
info "Composants user ShipGlows: claude=${SHIPGLOWS_INSTALL_AGENT_CLAUDE:-0}, codex=${SHIPGLOWS_INSTALL_AGENT_CODEX:-0}, opencode=${SHIPGLOWS_INSTALL_AGENT_OPENCODE:-0}, kilocode=${SHIPGLOWS_INSTALL_AGENT_KILOCODE:-0}, ai-runtime=${SHIPGLOWS_INSTALL_AI_RUNTIME:-1}, skill-corpus=${SHIPGLOWS_INSTALL_SKILL_CORPUS:-0}, tui=${SHIPGLOWS_INSTALL_TUI:-1}"
setup_user "$PRIMARY_USER_HOME" "$PRIMARY_USER"
for username in "${TARGET_USERS[@]}"; do
    [ "$username" = "$PRIMARY_USER" ] && continue
    user_home="$(getent passwd "$username" | cut -d: -f6)"
    [ -n "$user_home" ] || continue
    setup_user "$user_home" "$username"
done

TARGET_USERS_SUMMARY="$(target_users_summary)"

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}          ${YELLOW}Installation terminée !${NC}              ${CYAN}║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}📝 Prochaines étapes :${NC}"
echo ""
echo -e "1. ${YELLOW}Authentification GitHub${NC} (si pas déjà fait) :"
echo -e "   ${CYAN}gh auth login${NC}"
echo ""
echo -e "2. ${YELLOW}Lancer ShipGlows${NC} :"
echo -e "   ${CYAN}shipglows${NC}  ou  ${CYAN}sg${NC}"
echo ""
echo -e "3. ${YELLOW}Lancer la TUI ShipGlows${NC} :"
echo -e "   ${CYAN}tui${NC}  ou  ${CYAN}shipglows-tui${NC}"
echo ""

# Résumé des installations
echo -e "${BLUE}🎯 Résumé :${NC}"
echo -e "  • Node.js: $(command -v node >/dev/null 2>&1 && echo '✅' || echo '❌')"
echo -e "  • PM2: $(command -v pm2 >/dev/null 2>&1 && echo '✅' || echo '❌')"
echo -e "  • Vercel CLI: $(command -v vercel >/dev/null 2>&1 && echo '✅' || echo '❌')"
echo -e "  • Convex CLI: $(command -v convex >/dev/null 2>&1 && echo '✅' || echo '❌')"
echo -e "  • Clerk CLI: $(command -v clerk >/dev/null 2>&1 && echo '✅' || echo '❌')"
echo -e "  • Supabase CLI: $(command -v supabase >/dev/null 2>&1 && echo '✅' || echo '❌')"
echo -e "  • Flox: $(command -v flox >/dev/null 2>&1 && echo '✅' || echo '⚠️ Installation manuelle requise')"
echo -e "  • GitHub CLI: $(command -v gh >/dev/null 2>&1 && echo '✅' || echo '❌')"
echo -e "  • Caddy: $(command -v caddy >/dev/null 2>&1 && echo '✅' || echo '⚠️ Installation manuelle requise')"
echo -e "  • Python3: $(command -v python3 >/dev/null 2>&1 && echo '✅' || echo '❌')"
echo -e "  • PyYAML: $(python3 -c 'import yaml' 2>/dev/null && echo '✅' || echo '❌')"
echo -e "  • Git: $(command -v git >/dev/null 2>&1 && echo '✅' || echo '❌')"
echo -e "  • jq: $(command -v jq >/dev/null 2>&1 && echo '✅ (2-5x faster JSON)' || echo '❌')"
echo -e "  • fuser: $(command -v fuser >/dev/null 2>&1 && echo '✅ (port cleanup)' || echo '❌')"
echo -e "  • Utilisateurs configurés: ${TARGET_USERS_SUMMARY:-$PRIMARY_USER}"
echo -e "  • Mode IA autonome: ${SHIPGLOWS_AUTONOMY_MODE_RESOLVED:-standard}"
if [ "$(uname -m 2>/dev/null || echo unknown)" = "aarch64" ] || [ "$(uname -m 2>/dev/null || echo unknown)" = "arm64" ]; then
    echo -e "  • Flutter Android release: ⚠️ CI x64 requise (Blacksmith recommandé)"
else
    echo -e "  • Flutter Android release: ✅ hôte non-ARM détecté"
fi
echo ""
echo -e "${BLUE}🗂️  Logs :${NC}"
echo -e "  • Fichier: ${SHIPGLOWS_LOG_FILE}"
shipglows_log "INFO" "ShipGlows install completed"

generate_install_report() {
    local status_node status_pm2 status_vercel status_convex status_clerk status_supabase status_flox status_gh status_python3 status_pyyaml status_caddy status_git status_jq status_fuser
    local report_claude_path report_codex_path report_opencode_path report_kilocode_path
    if command -v node >/dev/null 2>&1; then status_node="present"; else status_node=""; fi
    if command -v pm2 >/dev/null 2>&1; then status_pm2="present"; else status_pm2=""; fi
    if command -v vercel >/dev/null 2>&1; then status_vercel="present"; else status_vercel=""; fi
    if command -v convex >/dev/null 2>&1; then status_convex="present"; else status_convex=""; fi
    if command -v clerk >/dev/null 2>&1; then status_clerk="present"; else status_clerk=""; fi
    if command -v supabase >/dev/null 2>&1; then status_supabase="present"; else status_supabase=""; fi
    if command -v flox >/dev/null 2>&1; then status_flox="present"; else status_flox=""; fi
    if command -v gh >/dev/null 2>&1; then status_gh="present"; else status_gh=""; fi
    if command -v python3 >/dev/null 2>&1; then status_python3="present"; else status_python3=""; fi
    if python3 -c 'import yaml' 2>/dev/null; then status_pyyaml="present"; else status_pyyaml=""; fi
    if command -v caddy >/dev/null 2>&1; then status_caddy="present"; else status_caddy=""; fi
    if command -v git >/dev/null 2>&1; then status_git="present"; else status_git=""; fi
    if command -v jq >/dev/null 2>&1; then status_jq="present"; else status_jq=""; fi
    if command -v fuser >/dev/null 2>&1; then status_fuser="present"; else status_fuser=""; fi
    report_claude_path="$(sudo -u "$PRIMARY_USER" -H bash -lc 'export PNPM_HOME="$HOME/.local/share/pnpm"; export PATH="$PNPM_HOME:$PATH"; command -v claude 2>/dev/null || true' 2>/dev/null)"
    report_codex_path="$(sudo -u "$PRIMARY_USER" -H bash -lc 'export PNPM_HOME="$HOME/.local/share/pnpm"; export PATH="$PNPM_HOME:$PATH"; command -v codex 2>/dev/null || true' 2>/dev/null)"
    report_opencode_path="$(sudo -u "$PRIMARY_USER" -H bash -lc 'export PNPM_HOME="$HOME/.local/share/pnpm"; export PATH="$PNPM_HOME:$PATH"; command -v opencode 2>/dev/null || true' 2>/dev/null)"
    report_kilocode_path="$(sudo -u "$PRIMARY_USER" -H bash -lc 'export PNPM_HOME="$HOME/.local/share/pnpm"; export PATH="$PNPM_HOME:$PATH"; command -v kilocode 2>/dev/null || true' 2>/dev/null)"

    cat > "$SHIPGLOWS_REPORT_FILE" << REPORT
# Rapport d'installation ShipGlows

## Run summary

- Date UTC: $(date -u +%Y-%m-%dT%H:%M:%SZ)
- Repo: ShipGlows
- Utilisateur: $(id -un)
- Commande: sudo ./cli/install.sh
- Mode: root (system + user config)
- Mode IA autonome: ${SHIPGLOWS_AUTONOMY_MODE_RESOLVED:-standard}
- Autonomie root: $(if [ "${SHIPGLOWS_ROOT_AUTONOMOUS_ALLOWED:-0}" = "1" ]; then echo "autorisee"; else echo "standard"; fi)
- Composants user sélectionnés: claude=${SHIPGLOWS_INSTALL_AGENT_CLAUDE:-0}, codex=${SHIPGLOWS_INSTALL_AGENT_CODEX:-0}, opencode=${SHIPGLOWS_INSTALL_AGENT_OPENCODE:-0}, kilocode=${SHIPGLOWS_INSTALL_AGENT_KILOCODE:-0}, ai-runtime=${SHIPGLOWS_INSTALL_AI_RUNTIME:-1}, skill-corpus=${SHIPGLOWS_INSTALL_SKILL_CORPUS:-0}, tui=${SHIPGLOWS_INSTALL_TUI:-1}
- Version script: local
- Machine: $(hostname)
- Log brut: $SHIPGLOWS_LOG_FILE
- Statut global: $(if command -v node >/dev/null 2>&1 && command -v pm2 >/dev/null 2>&1 && command -v vercel >/dev/null 2>&1; then echo "SUCCÈS"; else echo "PARTIEL"; fi)

## Packages / outils

| Élément | Résultat | Détails |
|---|---|---|
| Node.js | $(shipglows_status "$SHIPGLOWS_PRE_STATUS_DIR_NODE" "$status_node") | Détection binaire |
| PM2 | $(shipglows_status "$SHIPGLOWS_PRE_STATUS_PM2" "$status_pm2") | Détection binaire |
| Vercel CLI | $(shipglows_status "$SHIPGLOWS_PRE_STATUS_VERCEL" "$status_vercel") | Détection binaire |
| Convex CLI | $(shipglows_status "$SHIPGLOWS_PRE_STATUS_CONVEX" "$status_convex") | Détection binaire |
| Clerk CLI | $(shipglows_status "$SHIPGLOWS_PRE_STATUS_CLERK" "$status_clerk") | Détection binaire |
| Supabase CLI | $(shipglows_status "$SHIPGLOWS_PRE_STATUS_SUPABASE" "$status_supabase") | Détection binaire |
| Flox | $(shipglows_status "$SHIPGLOWS_PRE_STATUS_FLOX" "$status_flox") | Détection binaire |
| GitHub CLI | $(shipglows_status "$SHIPGLOWS_PRE_STATUS_GH" "$status_gh") | Détection binaire |
| Caddy | $(shipglows_status "$SHIPGLOWS_PRE_STATUS_CADDY" "$status_caddy") | Détection binaire |
| Python3 | $(shipglows_status "$SHIPGLOWS_PRE_STATUS_PYTHON3" "$status_python3") | Détection binaire |
| PyYAML | $(shipglows_status "$SHIPGLOWS_PRE_STATUS_PYYAML" "$status_pyyaml") | python3 -c 'import yaml' |
| Git | $(shipglows_status "$SHIPGLOWS_PRE_STATUS_GIT" "$status_git") | Détection binaire |
| jq | $(shipglows_status "$SHIPGLOWS_PRE_STATUS_JQ" "$status_jq") | Détection binaire |
| fuser | $(shipglows_status "$SHIPGLOWS_PRE_STATUS_FUSER" "$status_fuser") | Détection binaire |

## Outils utilisateur

| Élément | Résultat | Détails |
|---|---|---|
| claude | $(if [ "${SHIPGLOWS_INSTALL_AGENT_CLAUDE:-0}" != "1" ]; then echo "IGNORÉ"; elif [ -n "$report_claude_path" ]; then echo "INSTALLÉ"; else echo "PARTIEL"; fi) | géré par ShipGlows (scope utilisateur) ; chemin: $(if [ "${SHIPGLOWS_INSTALL_AGENT_CLAUDE:-0}" != "1" ]; then echo "skipped"; else echo "${report_claude_path:-missing}"; fi) |
| codex | $(if [ "${SHIPGLOWS_INSTALL_AGENT_CODEX:-0}" != "1" ]; then echo "IGNORÉ"; elif [ -n "$report_codex_path" ]; then echo "INSTALLÉ"; else echo "PARTIEL"; fi) | géré par ShipGlows (scope utilisateur) ; chemin: $(if [ "${SHIPGLOWS_INSTALL_AGENT_CODEX:-0}" != "1" ]; then echo "skipped"; else echo "${report_codex_path:-missing}"; fi) |
| opencode | $(if [ "${SHIPGLOWS_INSTALL_AGENT_OPENCODE:-0}" != "1" ]; then echo "IGNORÉ"; elif [ -n "$report_opencode_path" ]; then echo "INSTALLÉ"; else echo "PARTIEL"; fi) | géré par ShipGlows (scope utilisateur) ; chemin: $(if [ "${SHIPGLOWS_INSTALL_AGENT_OPENCODE:-0}" != "1" ]; then echo "skipped"; else echo "${report_opencode_path:-missing}"; fi) |
| kilocode | $(if [ "${SHIPGLOWS_INSTALL_AGENT_KILOCODE:-0}" != "1" ]; then echo "IGNORÉ"; elif [ -n "$report_kilocode_path" ]; then echo "INSTALLÉ"; else echo "PARTIEL"; fi) | géré par ShipGlows (scope utilisateur) ; chemin: $(if [ "${SHIPGLOWS_INSTALL_AGENT_KILOCODE:-0}" != "1" ]; then echo "skipped"; else echo "${report_kilocode_path:-missing}"; fi) |
| tmux | NON_APPLICABLE | géré par dotfiles |
| mosh | NON_APPLICABLE | géré par dotfiles |

## Configuration

- Utilisateurs ciblés: ${TARGET_USERS_SUMMARY:-$PRIMARY_USER}
- Cibles de config: le compte lanceur par défaut, ou les comptes explicitement listés via `SHIPGLOWS_INSTALL_USERS_MODE=user-list`
- Compte principal: $PRIMARY_USER
- Résumé santé/diagnostic:
- Flutter Android release policy: $(case "$(uname -m 2>/dev/null || echo unknown)" in aarch64|arm64) echo "CI x64 requise; utiliser Blacksmith pour APK/AAB Android";; *) echo "Build local possible si Android SDK/JDK sont configurés";; esac)
- Actions correctives suggérées:

## Observations

- Avertissements:
- Sur hôte ARM64, éviter \`flutter build apk --release\` local; router Android release vers Blacksmith ou une CI Linux x64.
- Erreurs bloquantes:
- Recommandations:
REPORT
}

generate_install_report

echo -e "${BLUE}🗒️  Rapport :${NC}"
echo -e "  • Fichier: ${SHIPGLOWS_REPORT_FILE}"

success "Installation complète pour tous les utilisateurs !"
