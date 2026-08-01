#!/bin/bash
# install.sh - Installation automatique pour machine locale

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=remote-helpers.sh
source "$SCRIPT_DIR/remote-helpers.sh"
SSH_CONFIG="$HOME/.ssh/config"
SHELL_RC="$HOME/.bashrc"

# Détecter le système d'exploitation
IS_WSL=false
IS_WINDOWS=false
IS_MACOS=false
IS_LINUX=false
IS_TERMUX=false

if [ -n "${TERMUX_VERSION:-}" ] || [[ "${PREFIX:-}" == */com.termux/* ]]; then
    IS_TERMUX=true
elif grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
    IS_WSL=true
    IS_WINDOWS=true
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
    IS_WINDOWS=true
elif [[ "$OSTYPE" == "darwin"* ]]; then
    IS_MACOS=true
else
    IS_LINUX=true
fi

# Détecter le shell (bash ou zsh)
if [ -n "$ZSH_VERSION" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.zshrc" ] && [ -n "$SHELL" ] && [[ "$SHELL" == *"zsh"* ]]; then
    SHELL_RC="$HOME/.zshrc"
fi

echo -e "${BLUE}🚀 Installation ShipGlowz - Configuration Locale${NC}"
echo ""

# Afficher le système détecté
if [ "$IS_TERMUX" = true ]; then
    echo -e "${GREEN}✓ Système détecté: Android / Termux${NC}"
elif [ "$IS_WSL" = true ]; then
    echo -e "${GREEN}✓ Système détecté: Windows WSL${NC}"
elif [ "$IS_WINDOWS" = true ]; then
    echo -e "${YELLOW}⚠ Système détecté: Windows (Git Bash)${NC}"
    echo -e "${YELLOW}  Pour une meilleure expérience, utilisez WSL (Windows Subsystem for Linux)${NC}"
    echo ""
elif [ "$IS_MACOS" = true ]; then
    echo -e "${GREEN}✓ Système détecté: macOS${NC}"
else
    echo -e "${GREEN}✓ Système détecté: Linux${NC}"
fi
echo ""

# 1. Vérifier autossh
echo -e "${BLUE}1. Vérification des dépendances...${NC}"
if ! command -v autossh &> /dev/null; then
    echo -e "${RED}   ✗ autossh non installé${NC}"
    echo -e "${YELLOW}   Installation requise:${NC}"

    if [ "$IS_TERMUX" = true ]; then
        echo -e "${YELLOW}     pkg install openssh autossh${NC}"
    elif [ "$IS_MACOS" = true ]; then
        echo -e "${YELLOW}     brew install autossh${NC}"
    elif [ "$IS_WSL" = true ]; then
        echo -e "${YELLOW}     sudo apt update && sudo apt install autossh${NC}"
    elif [ "$IS_WINDOWS" = true ]; then
        echo -e "${RED}   ⚠️  Git Bash ne supporte pas autossh nativement${NC}"
        echo -e "${YELLOW}   Solutions recommandées:${NC}"
        echo -e "${YELLOW}   1. Installer WSL: https://aka.ms/wsl${NC}"
        echo -e "${YELLOW}   2. Utiliser PowerShell avec OpenSSH (voir install_local.ps1)${NC}"
        echo -e "${YELLOW}   3. Utiliser un client SSH graphique (PuTTY, MobaXterm)${NC}"
    else
        echo -e "${YELLOW}     sudo apt update && sudo apt install autossh${NC}"
    fi
    exit 1
fi
echo -e "${GREEN}   ✓ autossh installé${NC}"

# 2. Configurer SSH
echo ""
echo -e "${BLUE}2. Configuration SSH...${NC}"

# Créer ~/.ssh si nécessaire
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# Prefer the explicit saved ShipGlowz connection. Hardcoded historical server
# aliases become stale as soon as the operator migrates to a new machine.
shipglowz_migrate_local_config || true
LOCAL_CONFIG_DIR="$(shipglowz_local_config_dir)"
mkdir -p "$LOCAL_CONFIG_DIR"
DEFAULT_REMOTE_HOST="${SHIPGLOWZ_SSH_REMOTE_HOST:-${SHIPFLOW_SSH_REMOTE_HOST:-}}"
if [ -n "$DEFAULT_REMOTE_HOST" ]; then
    printf '%s\n' "$DEFAULT_REMOTE_HOST" > "$LOCAL_CONFIG_DIR/current_connection"
    chmod 600 "$LOCAL_CONFIG_DIR/current_connection"
    echo -e "${GREEN}   ✓ Connexion ShipGlowz enregistrée: $DEFAULT_REMOTE_HOST${NC}"
elif [ -f "$LOCAL_CONFIG_DIR/current_connection" ]; then
    echo -e "${GREEN}   ✓ Connexion ShipGlowz existante: $(cat "$LOCAL_CONFIG_DIR/current_connection")${NC}"
else
    echo -e "${YELLOW}   ⚠ Aucune connexion distante enregistrée${NC}"
    echo -e "${YELLOW}   Après installation, lancez 'urls' puis choisissez c) Configurer nouveau serveur.${NC}"
fi

CURRENT_AUTH_METHOD_FILE="$LOCAL_CONFIG_DIR/current_auth_method"

# 3. Ajouter les alias
echo ""
echo -e "${BLUE}3. Ajout des alias shell...${NC}"

ALIAS_BLOCK="
# ShipGlowz - Alias tunnels
_shipglowz_remote_user() {
    local cfg=\"\${SHIPGLOWZ_LOCAL_CONFIG_DIR:-\$HOME/.shipglowz}/current_connection\"
    [ -f \"\$cfg\" ] || return 1
    local val
    val=\"\$(grep -E '^[^|]+' \"\$cfg\" 2>/dev/null | head -n1)\"
    case \"\$val\" in
        *@*) printf '%s' \"\${val%%@*}\" ;;
        *) printf '%s' 'ubuntu' ;;
    esac
}

_shipglowz_remote_host() {
    local cfg=\"\${SHIPGLOWZ_LOCAL_CONFIG_DIR:-\$HOME/.shipglowz}/current_connection\"
    [ -f \"\$cfg\" ] || return 1
    local val
    val=\"\$(grep -E '^[^|]+' \"\$cfg\" 2>/dev/null | head -n1)\"
    case \"\$val\" in
        *@*) printf '%s' \"\${val#*@}\" ;;
        *) printf '%s' \"\$val\" ;;
    esac
}

alias tunnel='$SCRIPT_DIR/local.sh'
alias urls='$SCRIPT_DIR/local.sh'
alias l='$SCRIPT_DIR/local.sh'
alias m='mosh \"\$(_shipglowz_remote_user)@\$(_shipglowz_remote_host)\" -- bash -l -c \"tmux a || tmux\"'
alias sss='ssh -tt \"\$(_shipglowz_remote_user)@\$(_shipglowz_remote_host)\" \"tmux new-session -A -s 0\"'
alias root='mosh root@\"\$(_shipglowz_remote_host)\" -- bash -l -c \"tmux a || tmux\"'
"

if grep -Eq "# ShipGlowz - Alias tunnels" "$SHELL_RC" 2>/dev/null; then
    echo -e "${YELLOW}   ⚠ Alias tunnels déjà présents dans $SHELL_RC${NC}"
else
    echo "$ALIAS_BLOCK" >> "$SHELL_RC"
    echo -e "${GREEN}   ✓ Alias tunnels ajoutés à $SHELL_RC${NC}"
fi

# 4. Rendre les scripts exécutables
echo ""
echo -e "${BLUE}4. Configuration des permissions...${NC}"
chmod +x "$SCRIPT_DIR/dev-tunnel.sh"
chmod +x "$SCRIPT_DIR/tunnel-watch.sh"
chmod +x "$SCRIPT_DIR/local.sh"
chmod +x "$SCRIPT_DIR/mcp-login.sh"
chmod +x "$SCRIPT_DIR/clerk-login.sh"
chmod +x "$SCRIPT_DIR/blacksmith-login.sh"
chmod +x "$SCRIPT_DIR/turso-login.sh"
chmod +x "$SCRIPT_DIR/turso-ssh.sh"
echo -e "${GREEN}   ✓ Scripts exécutables${NC}"

# 5. Résumé
echo ""
echo -e "${GREEN}✅ Installation terminée !${NC}"
echo ""
echo -e "${BLUE}📋 Commandes disponibles:${NC}"
echo -e "   ${GREEN}urls${NC} ou ${GREEN}tunnel${NC}         - Ouvrir le menu de gestion des tunnels"
echo -e "   ${GREEN}shipglowz-mcp-login${NC}   - Login OAuth MCP distant via tunnel éphémère"
echo -e "   ${GREEN}shipglowz-clerk-login${NC} - Login Clerk CLI distant via tunnel éphémère"
echo -e "   ${GREEN}shipglowz-blacksmith-login${NC} - Login Blacksmith distant via tunnel éphémère"
echo -e "   ${GREEN}shipglowz-turso-login${NC} - Login Turso distant via tunnel/headless"
echo -e "   ${GREEN}shipglowz-turso-ssh${NC} - Copie auth Turso vers le serveur + checks SQL"
echo -e "   ${YELLOW}Legacy aliases:${NC} shipflow-mcp-login, shipflow-clerk-login, shipflow-blacksmith-login, shipflow-turso-login, shipflow-turso-ssh"
echo -e "   ${YELLOW}Primary aliases:${NC} shipglowz-mcp-login, shipglowz-clerk-login, shipglowz-blacksmith-login, shipglowz-turso-login, shipglowz-turso-ssh"
echo ""
echo -e "${YELLOW}⚠  Pour activer les alias, rechargez votre shell:${NC}"
echo -e "   ${BLUE}source $SHELL_RC${NC}"
echo -e "   ${YELLOW}ou${NC} fermez et rouvrez votre terminal"
echo ""
echo -e "${BLUE}🚀 Test de connexion SSH:${NC}"
TEST_REMOTE=""
TEST_IDENTITY_FILE=""
TEST_AUTH_METHOD="key"
if [ -f "$LOCAL_CONFIG_DIR/current_connection" ]; then
    TEST_REMOTE="$(cat "$LOCAL_CONFIG_DIR/current_connection")"
fi
if [ -f "$LOCAL_CONFIG_DIR/current_identity_file" ]; then
    TEST_IDENTITY_FILE="$(cat "$LOCAL_CONFIG_DIR/current_identity_file")"
fi
if [ -f "$CURRENT_AUTH_METHOD_FILE" ]; then
    TEST_AUTH_METHOD="$(cat "$CURRENT_AUTH_METHOD_FILE")"
fi

SSH_AUTH_METHOD="$TEST_AUTH_METHOD"
SSH_IDENTITY_FILE="$TEST_IDENTITY_FILE"
REMOTE_HOST="$TEST_REMOTE"

if [ -n "$TEST_REMOTE" ] && run_remote_ssh "echo OK" >/dev/null; then
    echo -e "${GREEN}   ✓ Connexion SSH au serveur OK${NC}"
    echo ""
    echo -e "${GREEN}   Vous pouvez maintenant lancer: ${BLUE}urls${NC}"
else
    echo -e "${YELLOW}   ⚠ Impossible de se connecter au serveur${NC}"
    echo -e "${YELLOW}   Lancez 'urls' puis choisissez c) Configurer nouveau serveur.${NC}"
fi
