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

run_required() {
    local label="$1"
    shift

    if "$@"; then
        return 0
    fi

    error "$label a échoué. Corrigez la cause indiquée ci-dessus puis relancez sudo ./cli/install.sh."
    return 1
}

require_command() {
    local command_name="$1"
    local label="${2:-$1}"

    if command -v "$command_name" >/dev/null 2>&1; then
        return 0
    fi

    error "$label est requis pour vérifier les téléchargements de l'installateur."
    return 1
}

checked_download() {
    local url="$1"
    local destination="$2"
    local label="$3"

    rm -f "$destination"
    if ! curl \
        --fail \
        --show-error \
        --silent \
        --location \
        --retry 3 \
        --retry-connrefused \
        --connect-timeout 15 \
        --output "$destination" \
        "$url"; then
        rm -f "$destination"
        error "Téléchargement impossible pour $label: $url"
        return 1
    fi

    if [ ! -s "$destination" ]; then
        rm -f "$destination"
        error "Téléchargement vide refusé pour $label: $url"
        return 1
    fi
}

verify_sha256() {
    local file_path="$1"
    local expected_sha256="$2"
    local label="$3"
    local actual_sha256

    actual_sha256="$(sha256sum "$file_path" 2>/dev/null | awk '{print $1}')" || actual_sha256=""
    if [ "$actual_sha256" != "$expected_sha256" ]; then
        error "Checksum SHA256 invalide pour $label (attendu: $expected_sha256, reçu: ${actual_sha256:-indisponible})."
        return 1
    fi
}

extract_tar_member() {
    local archive_path="$1"
    local destination_dir="$2"
    local member_name="$3"
    local label="$4"

    if ! tar -tzf "$archive_path" -- "$member_name" >/dev/null 2>&1 \
        || ! tar -xzf "$archive_path" -C "$destination_dir" -- "$member_name" \
        || [ ! -f "$destination_dir/$member_name" ]; then
        error "Archive invalide pour $label: le membre attendu '$member_name' est absent ou illisible."
        return 1
    fi
}

require_exact_line() {
    local file_path="$1"
    local expected_line="$2"
    local label="$3"

    if grep -Fxq "$expected_line" "$file_path"; then
        return 0
    fi

    error "Contenu inattendu pour $label; la configuration distante n'a pas été installée."
    return 1
}

require_only_exact_lines() {
    local file_path="$1"
    local label="$2"
    local line
    local allowed_line
    local line_allowed
    shift 2

    while IFS= read -r line || [ -n "$line" ]; do
        case "$line" in
            ""|\#*)
                continue
                ;;
        esac
        line_allowed=false
        for allowed_line in "$@"; do
            if [ "$line" = "$allowed_line" ]; then
                line_allowed=true
                break
            fi
        done
        if [ "$line_allowed" != "true" ]; then
            error "Ligne active inattendue dans $label; la configuration distante n'a pas été installée."
            return 1
        fi
    done < "$file_path"
}

verify_gpg_primary_fingerprint() {
    local key_file="$1"
    local expected_fingerprint="$2"
    local label="$3"
    local actual_fingerprint

    actual_fingerprint="$(gpg --batch --with-colons --show-keys "$key_file" 2>/dev/null | awk -F: '$1 == "fpr" { print $10; exit }')"
    if [ "$actual_fingerprint" != "$expected_fingerprint" ]; then
        error "Empreinte GPG invalide pour $label (attendue: $expected_fingerprint, reçue: ${actual_fingerprint:-indisponible})."
        return 1
    fi
}

verify_gpg_key_file() {
    local key_file="$1"
    local label="$2"

    if gpg --batch --with-colons --show-keys "$key_file" 2>/dev/null | grep -q '^pub:'; then
        return 0
    fi

    error "Clé GPG invalide pour $label."
    return 1
}

install_file_atomically() {
    local source_file="$1"
    local target_file="$2"
    local mode="$3"
    local target_dir
    local temporary_file

    target_dir="$(dirname "$target_file")"
    install -d -m 0755 "$target_dir" || return 1
    temporary_file="$(mktemp "$target_dir/.shipglows-install.XXXXXX")" || return 1
    if ! install -m "$mode" "$source_file" "$temporary_file" || ! mv -f "$temporary_file" "$target_file"; then
        rm -f "$temporary_file"
        return 1
    fi
}

write_text_atomically() {
    local target_file="$1"
    local mode="$2"
    local content="$3"
    local target_dir
    local temporary_file

    target_dir="$(dirname "$target_file")"
    install -d -m 0755 "$target_dir" || return 1
    temporary_file="$(mktemp "$target_dir/.shipglows-install.XXXXXX")" || return 1
    if ! printf '%s\n' "$content" > "$temporary_file" || ! chmod "$mode" "$temporary_file" || ! mv -f "$temporary_file" "$target_file"; then
        rm -f "$temporary_file"
        return 1
    fi
}

resolve_linux_arch() {
    case "$1" in
        x86_64|amd64)
            printf '%s\n' "amd64"
            ;;
        aarch64|arm64)
            printf '%s\n' "arm64"
            ;;
        *)
            return 1
            ;;
    esac
}

SHIPGLOWS_SYSTEM_PNPM_HOME="${SHIPGLOWS_SYSTEM_PNPM_HOME:-/usr/local/lib/shipglows/pnpm}"
SHIPGLOWS_SYSTEM_PNPM_GLOBAL_DIR="${SHIPGLOWS_SYSTEM_PNPM_GLOBAL_DIR:-$SHIPGLOWS_SYSTEM_PNPM_HOME/global}"
SHIPGLOWS_SYSTEM_BIN_DIR="${SHIPGLOWS_SYSTEM_BIN_DIR:-/usr/local/bin}"
SHIPGLOWS_OS_RELEASE_FILE="${SHIPGLOWS_OS_RELEASE_FILE:-/etc/os-release}"

NODESOURCE_GPG_FINGERPRINT="6F71F525282841EEDAF851B42F59B5F99B1BE0B4"
GITHUB_CLI_KEYRING_SHA256="6084d5d7bd8e288441e0e94fc6275570895da18e6751f70f057485dc2d1a811b"
SUPABASE_VERSION="2.115.0"
SUPABASE_LINUX_AMD64_SHA256="ff099608ce758b625532ef03a61f4c9520b995e94ff6cd5480dc0428cad64cb3"
SUPABASE_LINUX_ARM64_SHA256="02d2dfddf41fb6d03d2f1baf6e0c63b32ecc8c4dfddcbe63f9b11aecd2a9111c"
FLOX_VERSION="1.14.1"
FLOX_LINUX_AMD64_SHA256="7dfdd1ae576ab7519e5b2bbaa4e76db1265756d23fa6c142671af1d7744dddc0"
FLOX_LINUX_ARM64_SHA256="19937aecc3f711946b3fb7c6e0ec83fdce74f94d59fe5c53566f079f9bc7721c"

require_supported_linux_distribution() {
    local os_id=""
    local os_like=""

    if [ ! -r "$SHIPGLOWS_OS_RELEASE_FILE" ]; then
        error "Distribution Linux indétectable: $SHIPGLOWS_OS_RELEASE_FILE est absent ou illisible. Le mode full prend en charge Ubuntu et Debian."
        return 1
    fi

    os_id="$(sed -n 's/^ID=//p' "$SHIPGLOWS_OS_RELEASE_FILE" | head -n 1 | tr -d '\"')"
    os_like="$(sed -n 's/^ID_LIKE=//p' "$SHIPGLOWS_OS_RELEASE_FILE" | head -n 1 | tr -d '\"')"
    case " $os_id $os_like " in
        *" ubuntu "*|*" debian "*)
            info "Distribution Linux prise en charge: ${os_id:-dérivée Debian/Ubuntu}"
            return 0
            ;;
        *)
            error "Distribution Linux non prise en charge: ${os_id:-inconnue}. Le mode full prend en charge Ubuntu, Debian et leurs dérivées déclarées compatibles."
            return 1
            ;;
    esac
}

write_shipglows_command_wrapper() {
    local cli_name="$1"
    local cli_target="$2"
    local wrapper_path="$SHIPGLOWS_SYSTEM_BIN_DIR/$cli_name"
    local wrapper_tmp

    install -d -m 0755 "$SHIPGLOWS_SYSTEM_BIN_DIR" || return 1
    wrapper_tmp="$(mktemp "$SHIPGLOWS_SYSTEM_BIN_DIR/.${cli_name}.shipglows.XXXXXX")" || return 1
    if ! printf '#!/bin/sh\nexec "%s" "$@"\n' "$cli_target" > "$wrapper_tmp"; then
        rm -f "$wrapper_tmp"
        return 1
    fi
    if ! chmod 755 "$wrapper_tmp" || ! mv -f "$wrapper_tmp" "$wrapper_path"; then
        rm -f "$wrapper_tmp"
        return 1
    fi
}

cli_command_works() {
    local cli_name="$1"
    shift

    command -v "$cli_name" >/dev/null 2>&1 || return 1
    "$cli_name" "$@" >/dev/null 2>&1
}

managed_pnpm_cli_path() {
    local cli_name="$1"

    if [ -x "$SHIPGLOWS_SYSTEM_PNPM_HOME/$cli_name" ]; then
        printf '%s\n' "$SHIPGLOWS_SYSTEM_PNPM_HOME/$cli_name"
        return 0
    fi
    if [ -x "$SHIPGLOWS_SYSTEM_PNPM_HOME/bin/$cli_name" ]; then
        printf '%s\n' "$SHIPGLOWS_SYSTEM_PNPM_HOME/bin/$cli_name"
        return 0
    fi
    return 1
}

managed_pnpm_cli_works() {
    local cli_name="$1"
    local cli_path
    shift

    cli_path="$(managed_pnpm_cli_path "$cli_name")" || return 1
    "$cli_path" "$@" >/dev/null 2>&1
}

install_managed_pnpm_cli() {
    local package_name="$1"

    PATH="$SHIPGLOWS_SYSTEM_PNPM_HOME:$SHIPGLOWS_SYSTEM_PNPM_HOME/bin:$PATH" \
        PNPM_HOME="$SHIPGLOWS_SYSTEM_PNPM_HOME" \
        pnpm \
            --global-dir "$SHIPGLOWS_SYSTEM_PNPM_GLOBAL_DIR" \
            --global-bin-dir "$SHIPGLOWS_SYSTEM_PNPM_HOME" \
            add -g "$package_name"
}

prepare_pnpm() {
    export PNPM_HOME="$SHIPGLOWS_SYSTEM_PNPM_HOME"
    export PATH="$PNPM_HOME:$PNPM_HOME/bin:$PATH"
    install -d -m 0755 "$PNPM_HOME" "$PNPM_HOME/bin" "$SHIPGLOWS_SYSTEM_PNPM_GLOBAL_DIR"

    if ! corepack enable >/dev/null 2>&1; then
        error "Échec de l'activation de Corepack pour pnpm"
        return 1
    fi

    if ! corepack prepare pnpm@latest --activate >/dev/null 2>&1; then
        error "Échec de la préparation de pnpm"
        return 1
    fi

    if ! command -v pnpm >/dev/null 2>&1; then
        error "pnpm reste introuvable après l'initialisation de Corepack"
        return 1
    fi
}

expose_pnpm_global_cli() {
    local cli_name="$1"
    local cli_path
    local wrapper_path="$SHIPGLOWS_SYSTEM_BIN_DIR/$cli_name"
    local wrapper_tmp

    if ! cli_path="$(managed_pnpm_cli_path "$cli_name")"; then
        error "Impossible d'exposer $cli_name: exécutable pnpm introuvable dans $PNPM_HOME"
        return 1
    fi

    chmod -R a+rX "$PNPM_HOME"
    install -d -m 0755 "$SHIPGLOWS_SYSTEM_BIN_DIR"
    wrapper_tmp="$(mktemp "$SHIPGLOWS_SYSTEM_BIN_DIR/.${cli_name}.shipglows.XXXXXX")"
    cat > "$wrapper_tmp" <<EOF
#!/bin/sh
exec "$cli_path" "\$@"
EOF
    chmod 755 "$wrapper_tmp"
    mv "$wrapper_tmp" "$wrapper_path"

    if ! cli_command_works "$wrapper_path" --version; then
        error "Wrapper $wrapper_path présent mais non exécutable"
        return 1
    fi
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
    SHIPGLOWS_CODEX_ENTRYPOINT_RESOLVED="${SHIPGLOWS_CODEX_ENTRYPOINT:-linked}"
    case "$SHIPGLOWS_CODEX_ENTRYPOINT_RESOLVED" in
        linked|plugin) ;;
        *)
            error "SHIPGLOWS_CODEX_ENTRYPOINT doit valoir linked ou plugin"
            return 1
            ;;
    esac
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

                if prompt_yes_no "Installer le corpus public de skills (Claude/Codex developpeur/OpenCode/KiloCode) ?" no; then
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

resolve_codex_plugin_install() {
    local requested="${SHIPGLOWS_INSTALL_CODEX_PLUGIN:-ask}"
    case "$requested" in
        1|true|yes|install) SHIPGLOWS_INSTALL_CODEX_PLUGIN_RESOLVED="yes" ;;
        0|false|no|skip) SHIPGLOWS_INSTALL_CODEX_PLUGIN_RESOLVED="no" ;;
        ask)
            if [ "${SHIPGLOWS_INSTALL_AGENT_CODEX:-0}" != "1" ]; then
                SHIPGLOWS_INSTALL_CODEX_PLUGIN_RESOLVED="no"
            elif [ "${SHIPGLOWS_INSTALL_SKILL_CORPUS:-0}" = "1" ]; then
                # An explicit corpus checkout is the developer/live-link path.
                SHIPGLOWS_INSTALL_CODEX_PLUGIN_RESOLVED="no"
            elif [ -r /dev/tty ] && [ -w /dev/tty ]; then
                if prompt_yes_no "Installer le plugin ShipGlows officiel pour Codex ?" yes; then
                    SHIPGLOWS_INSTALL_CODEX_PLUGIN_RESOLVED="yes"
                else
                    SHIPGLOWS_INSTALL_CODEX_PLUGIN_RESOLVED="no"
                fi
            else
                SHIPGLOWS_INSTALL_CODEX_PLUGIN_RESOLVED="no"
            fi
            ;;
        *)
            error "SHIPGLOWS_INSTALL_CODEX_PLUGIN doit valoir ask, yes ou no"
            return 1
            ;;
    esac

    if [ "$SHIPGLOWS_INSTALL_CODEX_PLUGIN_RESOLVED" = "yes" ] \
        && [ "${SHIPGLOWS_INSTALL_SKILL_CORPUS:-0}" = "1" ]; then
        error "Le plugin public et le corpus live sont deux canaux exclusifs. Désactivez l'un des deux; les développeurs utilisent la commande shipglows skills link depuis leur clone."
        return 1
    fi
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
    managed_pnpm_cli_works pm2 --version && SHIPGLOWS_PRE_STATUS_PM2="present" || true
    managed_pnpm_cli_works vercel --version && SHIPGLOWS_PRE_STATUS_VERCEL="present" || true
    managed_pnpm_cli_works convex --version && SHIPGLOWS_PRE_STATUS_CONVEX="present" || true
    managed_pnpm_cli_works clerk --version && SHIPGLOWS_PRE_STATUS_CLERK="present" || true
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

require_supported_linux_distribution || exit 1

info "Préparation des outils de vérification de l'installateur..."
run_required "Mise à jour initiale des index apt" apt-get update || exit 1
run_required "Installation des outils de vérification" apt-get install -y ca-certificates curl gnupg || exit 1
for verification_command in curl gpg sha256sum install mktemp tar dpkg-deb; do
    require_command "$verification_command" "$verification_command" || exit 1
done

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
    NODESOURCE_TMP_DIR="$(mktemp -d)" || exit 1
    NODESOURCE_KEY="$NODESOURCE_TMP_DIR/nodesource-repo.gpg.key"
    NODESOURCE_KEYRING="$NODESOURCE_TMP_DIR/nodesource.gpg"
    NODESOURCE_SOURCE='deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_24.x nodistro main'

    if ! checked_download "https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key" "$NODESOURCE_KEY" "clé de signature NodeSource" \
        || ! verify_gpg_primary_fingerprint "$NODESOURCE_KEY" "$NODESOURCE_GPG_FINGERPRINT" "NodeSource" \
        || ! gpg --batch --yes --dearmor --output "$NODESOURCE_KEYRING" "$NODESOURCE_KEY" \
        || [ ! -s "$NODESOURCE_KEYRING" ] \
        || ! install_file_atomically "$NODESOURCE_KEYRING" "/usr/share/keyrings/nodesource.gpg" 0644 \
        || ! write_text_atomically "/etc/apt/sources.list.d/nodesource.list" 0644 "$NODESOURCE_SOURCE"; then
        rm -rf "$NODESOURCE_TMP_DIR"
        error "Configuration NodeSource refusée. Vérifiez la clé officielle et relancez l'installateur."
        exit 1
    fi
    rm -rf "$NODESOURCE_TMP_DIR"
    run_required "Actualisation du dépôt NodeSource" apt-get update || exit 1
    run_required "Installation de Node.js" apt-get install -y nodejs || exit 1
    
    if command -v node >/dev/null 2>&1; then
        success "Node.js installé: $(node --version)"
    else
        error "Échec de l'installation de Node.js"
        exit 1
    fi
fi

echo ""

# 2. Installer PM2
prepare_pnpm || exit 1

if managed_pnpm_cli_works pm2 --version; then
    PM2_VERSION=$("$(managed_pnpm_cli_path pm2)" --version)
    success "PM2 déjà installé: $PM2_VERSION"
else
    info "Installation de PM2..."
    install_managed_pnpm_cli pm2
    hash -r 2>/dev/null

    if managed_pnpm_cli_works pm2 --version; then
        success "PM2 installé: $("$(managed_pnpm_cli_path pm2)" --version)"
    else
        error "Échec de l'installation de PM2"
        exit 1
    fi
fi
expose_pnpm_global_cli pm2 || exit 1

echo ""

# 3. Installer les CLI Node globales utiles
if managed_pnpm_cli_works vercel --version; then
    success "Vercel CLI déjà installé: $("$(managed_pnpm_cli_path vercel)" --version 2>/dev/null | head -n1)"
else
    info "Installation de Vercel CLI..."
    install_managed_pnpm_cli vercel
    hash -r 2>/dev/null

    if managed_pnpm_cli_works vercel --version; then
        success "Vercel CLI installé: $("$(managed_pnpm_cli_path vercel)" --version 2>/dev/null | head -n1)"
    else
        error "Échec de l'installation de Vercel CLI"
        exit 1
    fi
fi
expose_pnpm_global_cli vercel || exit 1

echo ""

if managed_pnpm_cli_works convex --version; then
    success "Convex CLI déjà installé: $("$(managed_pnpm_cli_path convex)" --version 2>/dev/null | head -n1)"
else
    info "Installation de Convex CLI..."
    install_managed_pnpm_cli convex
    hash -r 2>/dev/null

    if managed_pnpm_cli_works convex --version; then
        success "Convex CLI installé: $("$(managed_pnpm_cli_path convex)" --version 2>/dev/null | head -n1)"
    else
        error "Échec de l'installation de Convex CLI"
        exit 1
    fi
fi
expose_pnpm_global_cli convex || exit 1

echo ""

if managed_pnpm_cli_works clerk --version; then
    success "Clerk CLI déjà installé: $("$(managed_pnpm_cli_path clerk)" --version 2>/dev/null | head -n1)"
else
    info "Installation de Clerk CLI..."
    install_managed_pnpm_cli clerk
    hash -r 2>/dev/null

    if managed_pnpm_cli_works clerk --version; then
        success "Clerk CLI installé: $("$(managed_pnpm_cli_path clerk)" --version 2>/dev/null | head -n1)"
    else
        error "Échec de l'installation de Clerk CLI"
        exit 1
    fi
fi
expose_pnpm_global_cli clerk || exit 1

echo ""

# Supabase CLI — standalone binary install, because npm global install is not supported officially.
if command -v supabase >/dev/null 2>&1; then
    success "Supabase CLI déjà installé: $(supabase --version 2>/dev/null | head -n1)"
else
    info "Installation de Supabase CLI..."
    ARCH="$(uname -m)"
    if ! SUPABASE_ARCH="$(resolve_linux_arch "$ARCH")"; then
        error "Architecture non supportée pour Supabase CLI: $ARCH"
        exit 1
    fi
    case "$SUPABASE_ARCH" in
        arm64) SUPABASE_SHA256="$SUPABASE_LINUX_ARM64_SHA256" ;;
        amd64) SUPABASE_SHA256="$SUPABASE_LINUX_AMD64_SHA256" ;;
    esac

    SUPABASE_TMP_DIR="$(mktemp -d)" || exit 1
    SUPABASE_ARCHIVE="supabase_${SUPABASE_VERSION}_linux_${SUPABASE_ARCH}.tar.gz"
    SUPABASE_URL="https://github.com/supabase/cli/releases/download/v${SUPABASE_VERSION}/${SUPABASE_ARCHIVE}"
    if ! checked_download "$SUPABASE_URL" "$SUPABASE_TMP_DIR/$SUPABASE_ARCHIVE" "Supabase CLI $SUPABASE_VERSION" \
        || ! verify_sha256 "$SUPABASE_TMP_DIR/$SUPABASE_ARCHIVE" "$SUPABASE_SHA256" "Supabase CLI $SUPABASE_VERSION" \
        || ! extract_tar_member "$SUPABASE_TMP_DIR/$SUPABASE_ARCHIVE" "$SUPABASE_TMP_DIR" "supabase" "Supabase CLI $SUPABASE_VERSION" \
        || ! install_file_atomically "$SUPABASE_TMP_DIR/supabase" "/usr/local/bin/supabase" 0755; then
        rm -rf "$SUPABASE_TMP_DIR"
        error "Installation vérifiée de Supabase CLI impossible. Aucun binaire non vérifié n'a été installé."
        exit 1
    fi
    rm -rf "$SUPABASE_TMP_DIR"
    hash -r 2>/dev/null

    if command -v supabase >/dev/null 2>&1 && supabase --version 2>/dev/null | grep -Fq "$SUPABASE_VERSION"; then
        success "Supabase CLI installé: $(supabase --version 2>/dev/null | head -n1)"
    else
        error "Supabase CLI installé mais la version $SUPABASE_VERSION n'a pas pu être vérifiée"
        exit 1
    fi
fi

echo ""

# 4. PM2 autostart policy. Personal-cloud hosts opt in explicitly; local
# workstations retain the existing user-session lifecycle.
if [ "${SHIPGLOWS_CLOUD_MODE:-false}" = "true" ]; then
    PM2_STARTUP_USER="${SUDO_USER:-$(id -un)}"
    PM2_STARTUP_HOME=$(getent passwd "$PM2_STARTUP_USER" | cut -d: -f6)
    if [ -n "$PM2_STARTUP_HOME" ] && pm2 startup systemd -u "$PM2_STARTUP_USER" --hp "$PM2_STARTUP_HOME" >/dev/null 2>&1; then
        success "PM2 configuré pour restaurer les processus au boot ($PM2_STARTUP_USER)"
    else
        warning "Impossible de configurer PM2 au boot; relance l'installation avec un utilisateur opérateur valide"
    fi
else
    info "PM2 installé sans démarrage automatique au boot"
    shipglows_log "INFO" "PM2 startup intentionally not configured. ShipGlows environments run under the operator user when started."
fi

echo ""

# 5. Installer Flox
if command -v flox >/dev/null 2>&1; then
    FLOX_VERSION=$(flox --version 2>&1 | head -n1)
    success "Flox déjà installé: $FLOX_VERSION"
else
    info "Installation de Flox..."
    ARCH="$(uname -m)"
    if ! FLOX_ARCH="$(resolve_linux_arch "$ARCH")"; then
        error "Architecture non supportée pour Flox: $ARCH"
        exit 1
    fi
    case "$FLOX_ARCH" in
        arm64)
            FLOX_PACKAGE_ARCH="aarch64"
            FLOX_SHA256="$FLOX_LINUX_ARM64_SHA256"
            ;;
        amd64)
            FLOX_PACKAGE_ARCH="x86_64"
            FLOX_SHA256="$FLOX_LINUX_AMD64_SHA256"
            ;;
    esac

    FLOX_TMP_DIR="$(mktemp -d)" || exit 1
    FLOX_DEB="flox-${FLOX_VERSION}.${FLOX_PACKAGE_ARCH}-linux.deb"
    FLOX_URL="https://downloads.flox.dev/by-env/stable/deb/$FLOX_DEB"
    if ! checked_download "$FLOX_URL" "$FLOX_TMP_DIR/$FLOX_DEB" "Flox $FLOX_VERSION" \
        || ! verify_sha256 "$FLOX_TMP_DIR/$FLOX_DEB" "$FLOX_SHA256" "Flox $FLOX_VERSION" \
        || ! dpkg-deb --info "$FLOX_TMP_DIR/$FLOX_DEB" >/dev/null \
        || ! run_required "Installation du paquet Flox $FLOX_VERSION" dpkg -i "$FLOX_TMP_DIR/$FLOX_DEB"; then
        rm -rf "$FLOX_TMP_DIR"
        error "Installation vérifiée de Flox impossible. Exécutez 'dpkg --audit' avant de réessayer."
        exit 1
    fi
    rm -rf "$FLOX_TMP_DIR"

    if command -v flox >/dev/null 2>&1 && flox --version 2>&1 | grep -Fq "$FLOX_VERSION"; then
        success "Flox installé: $(flox --version)"
    else
        error "Flox installé mais la version $FLOX_VERSION n'a pas pu être vérifiée"
        exit 1
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
    run_required "Actualisation des index apt pour les outils système" apt-get update || exit 1
    for tool in "${MISSING_TOOLS[@]}"; do
        case $tool in
            "ss")
                package_name="iproute2"
                ;;
            "jq")
                package_name="jq"
                ;;
            "fuser")
                package_name="psmisc"
                ;;
            *)
                package_name="$tool"
                ;;
        esac
        run_required "Installation de l'outil système $tool" apt-get install -y "$package_name" || exit 1
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
            if apt-get install -y "$pkg"; then
                success "$label installé ($pkg)"
                return 0
            fi
            warning "Échec d'installation de la dépendance Playwright $label ($pkg)"
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
    GH_TMP_DIR="$(mktemp -d)" || exit 1
    GH_KEYRING="$GH_TMP_DIR/githubcli-archive-keyring.gpg"
    GH_SOURCE="deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main"
    if ! checked_download "https://cli.github.com/packages/githubcli-archive-keyring.gpg" "$GH_KEYRING" "trousseau GitHub CLI" \
        || ! verify_sha256 "$GH_KEYRING" "$GITHUB_CLI_KEYRING_SHA256" "trousseau GitHub CLI" \
        || ! verify_gpg_key_file "$GH_KEYRING" "GitHub CLI" \
        || ! install_file_atomically "$GH_KEYRING" "/etc/apt/keyrings/githubcli-archive-keyring.gpg" 0644 \
        || ! write_text_atomically "/etc/apt/sources.list.d/github-cli.list" 0644 "$GH_SOURCE"; then
        rm -rf "$GH_TMP_DIR"
        error "Configuration du dépôt GitHub CLI refusée. Vérifiez le checksum officiel du trousseau."
        exit 1
    fi
    rm -rf "$GH_TMP_DIR"
    run_required "Actualisation du dépôt GitHub CLI" apt-get update || exit 1
    run_required "Installation de GitHub CLI" apt-get install -y gh || exit 1
    
    if command -v gh >/dev/null 2>&1; then
        success "GitHub CLI installé: $(gh --version | head -n1)"
    else
        error "Échec de l'installation de GitHub CLI"
        exit 1
    fi
fi

echo ""

# 8. Installer PyYAML pour la gestion des fichiers compose
info "Installation de PyYAML..."
if python3 -c "import yaml" 2>/dev/null; then
    success "PyYAML déjà installé"
else
    run_required "Installation de PyYAML depuis apt" apt-get install -y python3-yaml || exit 1
    if python3 -c "import yaml" 2>/dev/null; then
        success "PyYAML installé"
    else
        error "python3-yaml est installé mais l'import Python yaml échoue"
        exit 1
    fi
fi

echo ""

# 9. Installer Caddy (pour publication web)
if command -v caddy >/dev/null 2>&1; then
    CADDY_VERSION=$(caddy version | head -n1)
    success "Caddy déjà installé: $CADDY_VERSION"
else
    info "Installation de Caddy..."
    run_required "Installation des prérequis du dépôt Caddy" apt-get install -y debian-keyring debian-archive-keyring apt-transport-https curl || exit 1
    CADDY_TMP_DIR="$(mktemp -d)" || exit 1
    CADDY_KEY="$CADDY_TMP_DIR/caddy-stable.key"
    CADDY_KEYRING="$CADDY_TMP_DIR/caddy-stable.gpg"
    CADDY_SOURCE="$CADDY_TMP_DIR/caddy-stable.list"
    CADDY_DEB_LINE='deb [signed-by=/usr/share/keyrings/caddy-stable-archive-keyring.gpg] https://dl.cloudsmith.io/public/caddy/stable/deb/debian any-version main'
    CADDY_DEB_SRC_LINE='deb-src [signed-by=/usr/share/keyrings/caddy-stable-archive-keyring.gpg] https://dl.cloudsmith.io/public/caddy/stable/deb/debian any-version main'
    if ! checked_download "https://dl.cloudsmith.io/public/caddy/stable/gpg.key" "$CADDY_KEY" "clé du dépôt Caddy stable" \
        || ! verify_gpg_key_file "$CADDY_KEY" "Caddy stable" \
        || ! checked_download "https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt" "$CADDY_SOURCE" "source apt Caddy stable" \
        || ! require_exact_line "$CADDY_SOURCE" "$CADDY_DEB_LINE" "source apt Caddy stable" \
        || ! require_exact_line "$CADDY_SOURCE" "$CADDY_DEB_SRC_LINE" "source apt Caddy stable" \
        || ! require_only_exact_lines "$CADDY_SOURCE" "source apt Caddy stable" "$CADDY_DEB_LINE" "$CADDY_DEB_SRC_LINE" \
        || ! gpg --batch --yes --dearmor --output "$CADDY_KEYRING" "$CADDY_KEY" \
        || [ ! -s "$CADDY_KEYRING" ] \
        || ! install_file_atomically "$CADDY_KEYRING" "/usr/share/keyrings/caddy-stable-archive-keyring.gpg" 0644 \
        || ! install_file_atomically "$CADDY_SOURCE" "/etc/apt/sources.list.d/caddy-stable.list" 0644; then
        rm -rf "$CADDY_TMP_DIR"
        error "Configuration du dépôt Caddy refusée. La clé ou la source officielle est invalide."
        exit 1
    fi
    rm -rf "$CADDY_TMP_DIR"
    run_required "Actualisation du dépôt Caddy" apt-get update || exit 1
    run_required "Installation de Caddy" apt-get install -y caddy || exit 1
    
    if command -v caddy >/dev/null 2>&1; then
        success "Caddy installé: $(caddy version | head -n1)"
    else
        error "Échec de l'installation de Caddy"
        exit 1
    fi
fi

if command -v caddy >/dev/null 2>&1 && command -v systemctl >/dev/null 2>&1 && [ "${SHIPGLOWS_CLOUD_MODE:-false}" != "true" ]; then
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

SHIPGLOWS_INSTALL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

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

install_playwright_chromium_for_user() {
    local target_home="$1"
    local username="$2"
    local executable_path=""

    executable_path="$(playwright_mcp_executable_path "$target_home" || true)"
    if [ -n "$executable_path" ] && [[ "$executable_path" == "$target_home/.cache/ms-playwright/"* ]]; then
        success "Playwright Chromium déjà disponible pour $username"
        return 0
    fi

    info "Installation de Playwright Chromium pour $username..."
    if [ "$username" = "root" ]; then
        HOME="$target_home" bash -lc 'command -v node >/dev/null 2>&1 || { echo "Node.js est requis pour Playwright MCP" >&2; exit 20; }; command -v npx >/dev/null 2>&1 || { echo "npx est requis pour Playwright MCP" >&2; exit 21; }; npx -y --package=@playwright/mcp@latest playwright install chromium'
    else
        sudo -u "$username" -H bash -lc 'command -v node >/dev/null 2>&1 || { echo "Node.js est requis pour Playwright MCP" >&2; exit 20; }; command -v npx >/dev/null 2>&1 || { echo "npx est requis pour Playwright MCP" >&2; exit 21; }; npx -y --package=@playwright/mcp@latest playwright install chromium'
    fi

    executable_path="$(playwright_mcp_executable_path "$target_home" || true)"
    if [ -z "$executable_path" ] || [[ "$executable_path" != "$target_home/.cache/ms-playwright/"* ]]; then
        warning "Playwright Chromium n'a pas été trouvé dans le cache utilisateur de $username"
        return 1
    fi
    success "Playwright Chromium installé pour $username: $executable_path"
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

# Playwright MCP for Codex — default web-QA transport, registered enabled globally.
configure_codex_playwright_mcp() {
    local target_home="$1"
    local codex_dir="$target_home/.codex"
    local config_file="$codex_dir/config.toml"
    local tmp_file="$config_file.tmp.$$"
    local clean_file="$tmp_file.clean"
    local block_file="$tmp_file.block"
    local args_json

    mkdir -p "$codex_dir"
    [ -f "$config_file" ] || touch "$config_file"

    awk '
        /^# >>> shipglows codex playwright mcp >>>$/ { next }
        /^# <<< shipglows codex playwright mcp <<</ { next }
        /^\[mcp_servers\.playwright(\.|\])?/ { skip = 1; next }
        /^\[/ && $0 !~ /^\[mcp_servers\.playwright(\.|\])?/ && skip == 1 { skip = 0 }
        !skip { print }
    ' "$config_file" > "$clean_file"

    args_json="$(playwright_mcp_args_json "$target_home")"
    {
        printf '# >>> shipglows codex playwright mcp >>>\n'
        printf '[mcp_servers.playwright]\n'
        printf 'command = "npx"\n'
        printf 'args = %s\n' "$args_json"
        printf 'enabled = true\n'
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
    } > "$block_file"

    awk -v block_file="$block_file" '
        function emit_block(line) {
            while ((getline line < block_file) > 0) print line
            close(block_file)
        }
        !inserted && /^\[/ {
            emit_block()
            print ""
            inserted = 1
        }
        { print }
        END {
            if (!inserted) {
                print ""
                emit_block()
            }
        }
    ' "$clean_file" > "$tmp_file"

    mv "$tmp_file" "$config_file"
    rm -f "$clean_file" "$block_file"
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
    mkdir -p "$target_home/.agents/skills"
    cleanup_legacy_skill_entries "$target_home/.claude/skills"
    cleanup_legacy_skill_entries "$target_home/.agents/skills"

    if ! bash "$sync_helper" --repair --all --target-home "$target_home" \
        --shipglows-root "$SHIPGLOWS_INSTALL_ROOT" --runtime all --backup-existing \
        --codex-entrypoint "$SHIPGLOWS_CODEX_ENTRYPOINT_RESOLVED"; then
        warning "Synchronisation des skills incomplète pour $target_home"
        return 1
    fi

    if ! bash "$sync_helper" --check --all --target-home "$target_home" \
        --shipglows-root "$SHIPGLOWS_INSTALL_ROOT" --runtime all \
        --codex-entrypoint "$SHIPGLOWS_CODEX_ENTRYPOINT_RESOLVED"; then
        warning "Vérification des skills incomplète pour $target_home"
        return 1
    fi

    echo -e "  ${GREEN}✅ Skills liés :${NC} Claude + Codex synchronisés (entrée Codex: $SHIPGLOWS_CODEX_ENTRYPOINT_RESOLVED)"
    return 0
}

install_codex_shipglows_plugin_for_user() {
    local target_home="$1"
    local username="$2"
    local helper="$SHIPGLOWS_INSTALL_ROOT/cli/shipglows_skills.py"
    local user_path="$target_home/.local/share/pnpm:$target_home/.local/share/pnpm/bin:$PATH"

    [ "${SHIPGLOWS_INSTALL_CODEX_PLUGIN_RESOLVED:-no}" = "yes" ] || return 0
    if [ ! -f "$helper" ]; then
        warning "Gestionnaire du plugin Codex ShipGlows introuvable: $helper"
        return 1
    fi

    if [ "$username" = "root" ]; then
        if ! HOME="$target_home" PATH="$user_path" command -v codex >/dev/null 2>&1; then
            warning "Codex est absent pour root; plugin ShipGlows ignoré"
            return 0
        fi
        HOME="$target_home" PATH="$user_path" python3 "$helper" \
            --target-home "$target_home" plugin-install --yes
        return $?
    fi

    if ! sudo -u "$username" -H env HOME="$target_home" PATH="$user_path" \
        sh -c 'command -v codex >/dev/null 2>&1'; then
        warning "Codex est absent pour $username; plugin ShipGlows ignoré"
        return 0
    fi
    sudo -u "$username" -H env HOME="$target_home" PATH="$user_path" \
        python3 "$helper" --target-home "$target_home" plugin-install --yes
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
    sed -i '/^alias \(shipglows\|sg\|c\|co\|cor\|cask\|coask\|ch\|re\|reload\|update-codex\)=/d' "$bashrc"
    cat >> "$bashrc" << ALIASES

# >>> ShipGlows AI aliases >>>
alias shipglows='/usr/local/bin/shipglows'
alias sg='/usr/local/bin/sg'
alias c='$c_alias'
alias co='codex'
alias cor='codex resume'
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
    local gsc_target="$SHIPGLOWS_INSTALL_ROOT/cli/shipglows-gsc.sh"
    local turso_login_target="$SHIPGLOWS_INSTALL_ROOT/local/turso-login.sh"
    local turso_ssh_target="$SHIPGLOWS_INSTALL_ROOT/local/turso-ssh.sh"
    local bin_dir="$SHIPGLOWS_SYSTEM_BIN_DIR"

    write_shipglows_command_wrapper shipglows "$SHIPGLOWS_INSTALL_ROOT/cli/shipglows.sh" || return 1
    write_shipglows_command_wrapper sg "$SHIPGLOWS_INSTALL_ROOT/cli/shipglows.sh" || return 1
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
export PATH="$PNPM_HOME:$PNPM_HOME/bin:$PATH"
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
        sudo -u "$username" -H bash -lc 'export PNPM_HOME="$HOME/.local/share/pnpm"; export PATH="$PNPM_HOME:$PNPM_HOME/bin:$PATH"; corepack prepare pnpm@latest --activate >/dev/null 2>&1; command -v claude >/dev/null 2>&1 || pnpm add -g --allow-build=@anthropic-ai/claude-code @anthropic-ai/claude-code' || return 1
    fi
    if [ "${SHIPGLOWS_INSTALL_AGENT_CODEX:-0}" = "1" ]; then
        sudo -u "$username" -H bash -lc 'export PNPM_HOME="$HOME/.local/share/pnpm"; export PATH="$PNPM_HOME:$PNPM_HOME/bin:$PATH"; corepack prepare pnpm@latest --activate >/dev/null 2>&1; command -v codex >/dev/null 2>&1 || pnpm add -g @openai/codex' || return 1
    fi
    if [ "${SHIPGLOWS_INSTALL_AGENT_OPENCODE:-0}" = "1" ]; then
        sudo -u "$username" -H bash -lc 'export PNPM_HOME="$HOME/.local/share/pnpm"; export PATH="$PNPM_HOME:$PNPM_HOME/bin:$PATH"; corepack prepare pnpm@latest --activate >/dev/null 2>&1; command -v opencode >/dev/null 2>&1 || pnpm add -g --allow-build=opencode-ai opencode-ai' || return 1
    fi
    if [ "${SHIPGLOWS_INSTALL_AGENT_KILOCODE:-0}" = "1" ]; then
        sudo -u "$username" -H bash -lc 'export PNPM_HOME="$HOME/.local/share/pnpm"; export PATH="$PNPM_HOME:$PNPM_HOME/bin:$PATH"; corepack prepare pnpm@latest --activate >/dev/null 2>&1; command -v kilocode >/dev/null 2>&1 || pnpm add -g --allow-build=@kilocode/cli @kilocode/cli' || return 1
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

    claude_path=$(sudo -u "$username" -H bash -lc 'export PNPM_HOME="$HOME/.local/share/pnpm"; export PATH="$PNPM_HOME:$PNPM_HOME/bin:$PATH"; command -v claude 2>/dev/null || true')
    codex_path=$(sudo -u "$username" -H bash -lc 'export PNPM_HOME="$HOME/.local/share/pnpm"; export PATH="$PNPM_HOME:$PNPM_HOME/bin:$PATH"; command -v codex 2>/dev/null || true')
    opencode_path=$(sudo -u "$username" -H bash -lc 'export PNPM_HOME="$HOME/.local/share/pnpm"; export PATH="$PNPM_HOME:$PNPM_HOME/bin:$PATH"; command -v opencode 2>/dev/null || true')
    kilocode_path=$(sudo -u "$username" -H bash -lc 'export PNPM_HOME="$HOME/.local/share/pnpm"; export PATH="$PNPM_HOME:$PNPM_HOME/bin:$PATH"; command -v kilocode 2>/dev/null || true')

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
    local permission_profile

    if [ "$mode" = "permissive" ]; then
        approval_policy="never"
        permission_profile=":danger-full-access"
    else
        approval_policy="on-request"
        permission_profile=":workspace"
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
      before_table && /^[[:space:]]*default_permissions[[:space:]]*=/ {
        next
      }
      {
        print
      }
    ' "$config_file" > "$cleaned_file"
    {
      printf '# >>> shipglows codex autonomous >>>\n'
      printf 'approval_policy = "%s"\n' "$approval_policy"
      printf 'default_permissions = "%s"\n' "$permission_profile"
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
    local playwright_ready=0

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
        if install_playwright_chromium_for_user "$user_home" "$username"; then
            playwright_ready=1
            configure_playwright_mcp "$user_home"
        else
            setup_failed=1
            warning "Playwright MCP n'est pas configuré pour $username car Chromium est indisponible."
        fi
        configure_codex_tui "$user_home"
        configure_codex_rmcp "$user_home"
        configure_codex_context7_mcp "$user_home"
        configure_codex_vercel_mcp "$user_home"
        configure_codex_convex_mcp "$user_home"
        configure_codex_clerk_mcp "$user_home"
        configure_codex_supabase_mcp "$user_home"
        configure_codex_dataforseo_mcp "$user_home"
        if [ "$playwright_ready" = "1" ]; then
            configure_codex_playwright_mcp "$user_home"
        fi
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
    install_codex_shipglows_plugin_for_user "$user_home" "$username" || setup_failed=1
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
        return 0
    else
        echo -e "  ${YELLOW}⚠️ Utilisateur configuré avec warnings :${NC} $username"
        return 1
    fi
}

echo ""
echo -e "${BLUE}👥 Configuration par utilisateur...${NC}"
collect_target_users
resolve_autonomy_mode
resolve_root_autonomy_opt_in
resolve_install_components || exit 1
resolve_codex_plugin_install || exit 1
if [ "${SHIPGLOWS_INSTALL_SKILL_CORPUS:-0}" = "1" ] && { [ ! -d "$SHIPGLOWS_INSTALL_ROOT/skills" ] || [ ! -x "$SHIPGLOWS_INSTALL_ROOT/tools/shipglows_sync_skills.sh" ]; }; then
    error "Le corpus de skills a été demandé mais il manque dans $SHIPGLOWS_INSTALL_ROOT. Relancez l'installeur public avec SHIPGLOWS_INSTALL_SURFACE=corpus."
    exit 1
fi
configure_command_wrappers || {
    error "Impossible d'installer les commandes système shipglows et sg"
    exit 1
}
info "Mode IA autonome ShipGlows: ${SHIPGLOWS_AUTONOMY_MODE_RESOLVED}"
info "Autonomie root: $([ "${SHIPGLOWS_ROOT_AUTONOMOUS_ALLOWED:-0}" = "1" ] && echo autorisee || echo standard)"
info "Composants user ShipGlows: claude=${SHIPGLOWS_INSTALL_AGENT_CLAUDE:-0}, codex=${SHIPGLOWS_INSTALL_AGENT_CODEX:-0}, opencode=${SHIPGLOWS_INSTALL_AGENT_OPENCODE:-0}, kilocode=${SHIPGLOWS_INSTALL_AGENT_KILOCODE:-0}, ai-runtime=${SHIPGLOWS_INSTALL_AI_RUNTIME:-1}, skill-corpus=${SHIPGLOWS_INSTALL_SKILL_CORPUS:-0}, tui=${SHIPGLOWS_INSTALL_TUI:-1}"
info "Plugin Codex ShipGlows: ${SHIPGLOWS_INSTALL_CODEX_PLUGIN_RESOLVED:-no}"
if [ "${SHIPGLOWS_INSTALL_SKILL_CORPUS:-0}" = "1" ]; then
    info "Canal d'entrée Codex ShipGlows: ${SHIPGLOWS_CODEX_ENTRYPOINT_RESOLVED:-linked}"
fi
SHIPGLOWS_USER_SETUP_FAILED=0
if ! setup_user "$PRIMARY_USER_HOME" "$PRIMARY_USER"; then
    SHIPGLOWS_USER_SETUP_FAILED=1
fi
for username in "${TARGET_USERS[@]}"; do
    [ "$username" = "$PRIMARY_USER" ] && continue
    user_home="$(getent passwd "$username" | cut -d: -f6)"
    [ -n "$user_home" ] || continue
    if ! setup_user "$user_home" "$username"; then
        SHIPGLOWS_USER_SETUP_FAILED=1
    fi
done

TARGET_USERS_SUMMARY="$(target_users_summary)"

echo ""
if [ "$SHIPGLOWS_USER_SETUP_FAILED" -eq 0 ]; then
    echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}          ${YELLOW}Installation terminée !${NC}              ${CYAN}║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
else
    echo -e "${RED}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║${NC}          ${YELLOW}Installation incomplète${NC}               ${RED}║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════╝${NC}"
fi
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
echo -e "  • PM2: $(managed_pnpm_cli_works pm2 --version && echo '✅' || echo '❌')"
echo -e "  • Vercel CLI: $(managed_pnpm_cli_works vercel --version && echo '✅' || echo '❌')"
echo -e "  • Convex CLI: $(managed_pnpm_cli_works convex --version && echo '✅' || echo '❌')"
echo -e "  • Clerk CLI: $(managed_pnpm_cli_works clerk --version && echo '✅' || echo '❌')"
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

generate_install_report() {
    local status_node status_pm2 status_vercel status_convex status_clerk status_supabase status_flox status_gh status_python3 status_pyyaml status_caddy status_git status_jq status_fuser
    local report_claude_path report_codex_path report_opencode_path report_kilocode_path
    if command -v node >/dev/null 2>&1; then status_node="present"; else status_node=""; fi
    if managed_pnpm_cli_works pm2 --version; then status_pm2="present"; else status_pm2=""; fi
    if managed_pnpm_cli_works vercel --version; then status_vercel="present"; else status_vercel=""; fi
    if managed_pnpm_cli_works convex --version; then status_convex="present"; else status_convex=""; fi
    if managed_pnpm_cli_works clerk --version; then status_clerk="present"; else status_clerk=""; fi
    if command -v supabase >/dev/null 2>&1; then status_supabase="present"; else status_supabase=""; fi
    if command -v flox >/dev/null 2>&1; then status_flox="present"; else status_flox=""; fi
    if command -v gh >/dev/null 2>&1; then status_gh="present"; else status_gh=""; fi
    if command -v python3 >/dev/null 2>&1; then status_python3="present"; else status_python3=""; fi
    if python3 -c 'import yaml' 2>/dev/null; then status_pyyaml="present"; else status_pyyaml=""; fi
    if command -v caddy >/dev/null 2>&1; then status_caddy="present"; else status_caddy=""; fi
    if command -v git >/dev/null 2>&1; then status_git="present"; else status_git=""; fi
    if command -v jq >/dev/null 2>&1; then status_jq="present"; else status_jq=""; fi
    if command -v fuser >/dev/null 2>&1; then status_fuser="present"; else status_fuser=""; fi
    report_claude_path="$(sudo -u "$PRIMARY_USER" -H bash -lc 'export PNPM_HOME="$HOME/.local/share/pnpm"; export PATH="$PNPM_HOME:$PNPM_HOME/bin:$PATH"; command -v claude 2>/dev/null || true' 2>/dev/null)"
    report_codex_path="$(sudo -u "$PRIMARY_USER" -H bash -lc 'export PNPM_HOME="$HOME/.local/share/pnpm"; export PATH="$PNPM_HOME:$PNPM_HOME/bin:$PATH"; command -v codex 2>/dev/null || true' 2>/dev/null)"
    report_opencode_path="$(sudo -u "$PRIMARY_USER" -H bash -lc 'export PNPM_HOME="$HOME/.local/share/pnpm"; export PATH="$PNPM_HOME:$PNPM_HOME/bin:$PATH"; command -v opencode 2>/dev/null || true' 2>/dev/null)"
    report_kilocode_path="$(sudo -u "$PRIMARY_USER" -H bash -lc 'export PNPM_HOME="$HOME/.local/share/pnpm"; export PATH="$PNPM_HOME:$PNPM_HOME/bin:$PATH"; command -v kilocode 2>/dev/null || true' 2>/dev/null)"

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
- Statut global: $(if [ "${SHIPGLOWS_USER_SETUP_FAILED:-1}" -eq 0 ] && command -v node >/dev/null 2>&1 && managed_pnpm_cli_works pm2 --version && managed_pnpm_cli_works vercel --version; then echo "SUCCÈS"; else echo "PARTIEL"; fi)

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
- $(if [ "${SHIPGLOWS_USER_SETUP_FAILED:-1}" -eq 0 ]; then echo "Aucune erreur de configuration utilisateur détectée."; else echo "Au moins une configuration utilisateur a échoué; consulter le log brut."; fi)
- Recommandations:
REPORT
}

generate_install_report

echo -e "${BLUE}🗒️  Rapport :${NC}"
echo -e "  • Fichier: ${SHIPGLOWS_REPORT_FILE}"

if [ "$SHIPGLOWS_USER_SETUP_FAILED" -ne 0 ]; then
    error "Installation incomplète: au moins une configuration utilisateur a échoué. Consultez $SHIPGLOWS_LOG_FILE"
    exit 1
fi

shipglows_log "INFO" "ShipGlows install completed successfully"
success "Installation complète pour tous les utilisateurs !"
