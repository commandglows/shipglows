#!/bin/bash
# mcp-login.sh - OAuth login helper for remote Codex MCP servers via ephemeral SSH tunnel

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/../config.sh" ]; then
    # shellcheck source=../config.sh
    source "$SCRIPT_DIR/../config.sh"
fi
# shellcheck source=remote-helpers.sh
source "$SCRIPT_DIR/remote-helpers.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

shipglows_migrate_local_config || true
CONFIG_DIR="$(shipglows_local_config_dir)"
CURRENT_CONNECTION_FILE="$CONFIG_DIR/current_connection"
CURRENT_IDENTITY_FILE="$CONFIG_DIR/current_identity_file"
CURRENT_AUTH_METHOD_FILE="$CONFIG_DIR/current_auth_method"

KNOWN_PROVIDERS=("vercel" "supabase")
LOGIN_TIMEOUT_SECONDS="${SHIPGLOWS_MCP_LOGIN_TIMEOUT_SECONDS:-${SHIPGLOWS_MCP_LOGIN_TIMEOUT_SECONDS:-600}}"

REMOTE_HOST=""
SSH_IDENTITY_FILE=""
TMP_DIR=""
OAUTH_OUTPUT_FILE=""
TUNNEL_LOG_FILE=""
REMOTE_PID_FILE=""
REMOTE_SSH_PID=""
TUNNEL_PID=""
CURRENT_PROVIDER=""

usage() {
    cat <<'EOF'
Usage: shipglows-mcp-login <provider|all>

Examples:
  shipglows-mcp-login vercel
  shipglows-mcp-login supabase
  shipglows-mcp-login all
  shipglows-mcp-login custom-name_1
EOF
}

print_header() {
    local brand="ShipGlows DevServer"
    local title="MCP OAuth Login"
    echo -e "${CYAN}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                  ║${NC}"
    echo -e "${CYAN}║  ${YELLOW}              ${brand}              ${CYAN}  ║${NC}"
    echo -e "${CYAN}║  ${YELLOW}                ${title}                 ${CYAN}  ║${NC}"
    echo -e "${CYAN}║                                                  ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
}

validate_mcp_provider_name() {
    local provider="$1"
    [[ -n "$provider" ]] || return 1
    [[ "$provider" != -* ]] || return 1
    [[ "$provider" =~ ^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$ ]] || return 1
}

is_known_provider() {
    local provider="$1"
    local known
    for known in "${KNOWN_PROVIDERS[@]}"; do
        if [ "$provider" = "$known" ]; then
            return 0
        fi
    done
    return 1
}

known_provider_add_command() {
    local provider="$1"
    case "$provider" in
        vercel) echo "codex mcp add vercel --url https://mcp.vercel.com" ;;
        supabase) echo "codex mcp add supabase --url https://mcp.supabase.com/mcp" ;;
        *) return 1 ;;
    esac
}

load_remote_host() {
    if ! _load_remote_host_core; then
        echo -e "${RED}✗ Aucune connexion distante ShipGlows configurée.${NC}"
        echo -e "${YELLOW}  Ouvrez le menu local 'urls', choisissez c) Configurer nouveau serveur, puis entrez l'adresse IP.${NC}"
        exit 1
    fi
}

cleanup() {
    if [ -n "${TUNNEL_PID:-}" ] && kill -0 "$TUNNEL_PID" 2>/dev/null; then
        kill "$TUNNEL_PID" 2>/dev/null || true
        wait "$TUNNEL_PID" 2>/dev/null || true
    fi

    if [ -n "${REMOTE_SSH_PID:-}" ] && kill -0 "$REMOTE_SSH_PID" 2>/dev/null; then
        kill "$REMOTE_SSH_PID" 2>/dev/null || true
        wait "$REMOTE_SSH_PID" 2>/dev/null || true
    fi

    if [ -n "${REMOTE_PID_FILE:-}" ] && [ -f "$REMOTE_PID_FILE" ]; then
        local remote_login_pid=""
        remote_login_pid="$(cat "$REMOTE_PID_FILE" 2>/dev/null || true)"
        if [[ "$remote_login_pid" =~ ^[0-9]+$ ]]; then
            run_remote_ssh "kill $remote_login_pid 2>/dev/null || true" >/dev/null 2>&1 || true
        fi
    fi

    if [ -n "${TMP_DIR:-}" ] && [ -d "$TMP_DIR" ]; then
        rm -rf "$TMP_DIR"
    fi
}

extract_oauth_url() {
    sed -nE 's/.*(https:\/\/[^[:space:]"]+).*/\1/p' "$OAUTH_OUTPUT_FILE" | tail -1
}

extract_callback_port() {
    parse_mcp_oauth_port_from_text "$(cat "$OAUTH_OUTPUT_FILE")"
}

parse_mcp_oauth_port_from_text() {
    local text="$1"
    local port=""
    port="$(printf "%s\n" "$text" | sed -nE 's/.*redirect_uri=http%3A%2F%2F127\.0\.0\.1%3A([0-9]{2,5})%2Fcallback.*/\1/p' | tail -1)"
    if [ -n "$port" ]; then
        echo "$port"
        return 0
    fi

    port="$(printf "%s\n" "$text" | sed -nE 's/.*http:\/\/127\.0\.0\.1:([0-9]{2,5})\/callback.*/\1/p' | tail -1)"
    if [ -n "$port" ]; then
        echo "$port"
        return 0
    fi

    return 1
}

wait_for_output_or_timeout() {
    local waited=0
    local max_wait=45
    while [ "$waited" -lt "$max_wait" ]; do
        if ! kill -0 "$REMOTE_SSH_PID" 2>/dev/null; then
            break
        fi
        if extract_oauth_url >/dev/null 2>&1 && extract_callback_port >/dev/null 2>&1; then
            return 0
        fi
        sleep 1
        waited=$((waited + 1))
    done
    return 1
}

ensure_remote_provider_exists() {
    local provider="$1"
    local list_output
    list_output="$(run_remote_ssh "codex mcp list" 2>&1 || true)"

    if ! echo "$list_output" | grep -Eq "(^|[[:space:]|])$provider([[:space:]|]|$)"; then
        echo -e "${RED}✗ MCP '$provider' absent de la configuration Codex distante.${NC}"
        if is_known_provider "$provider"; then
            local add_cmd
            add_cmd="$(known_provider_add_command "$provider" || true)"
            if [ -n "$add_cmd" ]; then
                echo -e "${YELLOW}  Ajoutez-le d'abord sur le serveur:${NC}"
                echo "  $add_cmd"
            fi
        fi
        return 1
    fi

    return 0
}

wait_remote_login_completion() {
    local timeout_seconds="$1"
    local elapsed=0

    while kill -0 "$REMOTE_SSH_PID" 2>/dev/null; do
        sleep 1
        elapsed=$((elapsed + 1))
        if [ "$elapsed" -ge "$timeout_seconds" ]; then
            echo -e "${RED}✗ Timeout OAuth atteint (${timeout_seconds}s).${NC}"
            return 1
        fi
    done

    wait "$REMOTE_SSH_PID"
}

verify_remote_auth_status() {
    local provider="$1"
    local status_output
    local provider_line

    status_output="$(run_remote_ssh "codex mcp list" 2>&1 || true)"
    provider_line="$(printf "%s\n" "$status_output" | grep -E "(^|[[:space:]|])$provider([[:space:]|]|$)" | head -1 || true)"

    if [ -n "$provider_line" ]; then
        echo -e "${BLUE}ℹ Statut MCP:${NC} $provider_line"
    fi

    if echo "$provider_line" | grep -qi "oauth"; then
        echo -e "${GREEN}✓ Login OAuth confirmé pour '$provider'.${NC}"
        return 0
    fi

    echo -e "${RED}✗ Login terminé mais statut OAuth non confirmé pour '$provider'.${NC}"
    return 1
}

run_one_provider() {
    local provider="$1"
    local oauth_url=""
    local callback_port=""

    CURRENT_PROVIDER="$provider"
    echo -e "${BLUE}➡ Provider: ${GREEN}$provider${NC}"

    if ! validate_mcp_provider_name "$provider"; then
        echo -e "${RED}✗ Provider invalide: '$provider'${NC}"
        echo -e "${YELLOW}  Format autorisé: ^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$${NC}"
        return 1
    fi

    # Batched SSH: connectivity + CLI + provider (1 round-trip vs 3)
    local _mcp_batch=""
    if ! _mcp_batch=$(run_remote_ssh "bash -lc 'echo ok && (command -v codex >/dev/null 2>&1 && echo CLI=ok || echo CLI=no) && (codex mcp list 2>/dev/null | grep -Eq \"(^|[[:space:]|])$provider([[:space:]|]|\$)\" && echo PROV=ok || echo PROV=no)'"); then
        echo -e "${RED}✗ SSH inaccessible vers '$REMOTE_HOST'.${NC}"
        echo -e "${YELLOW}  Le détail SSH affiché ci-dessus indique la cause.${NC}"
        return 1
    fi

    if ! echo "$_mcp_batch" | grep -q "CLI=ok"; then
        echo -e "${RED}✗ Codex CLI absent sur le serveur distant.${NC}"
        return 1
    fi

    if ! echo "$_mcp_batch" | grep -q "PROV=ok"; then
        echo -e "${RED}✗ MCP '$provider' absent de la configuration Codex distante.${NC}"
        if is_known_provider "$provider"; then
            local add_cmd
            add_cmd="$(known_provider_add_command "$provider" || true)"
            if [ -n "$add_cmd" ]; then
                echo -e "${YELLOW}  Ajoutez-le d'abord sur le serveur:${NC}"
                echo "  $add_cmd"
            fi
        fi
        return 1
    fi

    : > "$OAUTH_OUTPUT_FILE"
    : > "$TUNNEL_LOG_FILE"
    : > "$REMOTE_PID_FILE"
    REMOTE_SSH_PID=""
    TUNNEL_PID=""

    run_remote_ssh "bash -lc 'set -e; BROWSER=echo codex mcp login \"$provider\" & pid=\$!; echo \$pid; wait \$pid'" \
        > >(tee -a "$OAUTH_OUTPUT_FILE") \
        2> >(tee -a "$OAUTH_OUTPUT_FILE" >&2) &
    REMOTE_SSH_PID="$!"

    if ! wait_for_output_or_timeout; then
        echo -e "${RED}✗ Impossible d'extraire URL OAuth + port callback depuis la sortie Codex.${NC}"
        return 1
    fi

    oauth_url="$(extract_oauth_url || true)"
    callback_port="$(extract_callback_port || true)"
    if [ -z "$oauth_url" ] || [ -z "$callback_port" ]; then
        echo -e "${RED}✗ Données OAuth incomplètes (URL/port).${NC}"
        return 1
    fi

    if ! check_local_port_free "$callback_port"; then
        echo -e "${RED}✗ Port local déjà occupé: $callback_port${NC}"
        return 1
    fi

    echo -e "${BLUE}🔁 Tunnel OAuth: localhost:${callback_port} -> ${REMOTE_HOST}:127.0.0.1:${callback_port}${NC}"
    local tunnel_args=("-N" "-L" "${callback_port}:127.0.0.1:${callback_port}")
    while IFS= read -r arg; do
        tunnel_args+=("$arg")
    done < <(ssh_tunnel_args)
    ssh "${tunnel_args[@]}" "$REMOTE_HOST" >"$TUNNEL_LOG_FILE" 2>&1 &
    TUNNEL_PID="$!"
    sleep 1
    if ! kill -0 "$TUNNEL_PID" 2>/dev/null; then
        echo -e "${RED}✗ Impossible de démarrer le tunnel SSH OAuth.${NC}"
        return 1
    fi

    open_browser_or_print "$oauth_url" "MCP Codex OAuth"
    echo -e "${YELLOW}⏳ Finalisez le login dans le navigateur...${NC}"

    if ! wait_remote_login_completion "$LOGIN_TIMEOUT_SECONDS"; then
        return 1
    fi

    if ! verify_remote_auth_status "$provider"; then
        return 1
    fi

    return 0
}

main() {
    set -euo pipefail
    local provider="${1:-}"
    local failure=0

    print_header
    mkdir -p "$CONFIG_DIR"
    load_remote_host

    if [ -z "$provider" ] || [ "$provider" = "-h" ] || [ "$provider" = "--help" ]; then
        usage
        exit 1
    fi

    trap cleanup EXIT INT TERM

    TMP_DIR="$(mktemp -d)"
    OAUTH_OUTPUT_FILE="$TMP_DIR/oauth-login.log"
    TUNNEL_LOG_FILE="$TMP_DIR/oauth-tunnel.log"
    REMOTE_PID_FILE="$TMP_DIR/remote.pid"

    echo -e "${BLUE}Connexion distante:${NC} ${GREEN}$REMOTE_HOST${NC}"
    echo ""

    if [ "$provider" = "all" ]; then
        local p
        for p in "${KNOWN_PROVIDERS[@]}"; do
            if ! run_one_provider "$p"; then
                failure=1
            fi
            echo ""
        done
    else
        if ! run_one_provider "$provider"; then
            failure=1
        fi
    fi

    if [ "$failure" -ne 0 ]; then
        echo -e "${RED}✗ Flow MCP OAuth terminé avec erreur.${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Flow MCP OAuth terminé avec succès.${NC}"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    main "$@"
fi
