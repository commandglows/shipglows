#!/bin/bash
# clerk-login.sh - Clerk CLI OAuth login helper via ephemeral SSH tunnel.

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
LOGIN_TIMEOUT_SECONDS="${SHIPGLOWS_CLERK_LOGIN_TIMEOUT_SECONDS:-${SHIPGLOWS_CLERK_LOGIN_TIMEOUT_SECONDS:-600}}"

REMOTE_HOST=""
SSH_IDENTITY_FILE=""
TMP_DIR=""
OAUTH_OUTPUT_FILE=""
TUNNEL_LOG_FILE=""
REMOTE_SSH_PID=""
TUNNEL_PID=""

remote_clerk_path_prefix='export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$HOME/bin:/usr/local/bin:/usr/bin:/bin:$PATH";'

usage() {
    cat <<'EOF'
Usage: shipglows-clerk-login

Run this from your local machine. It starts `clerk auth login` on the
configured remote ShipGlows server, opens a temporary SSH callback tunnel, and
then opens or prints the official Clerk OAuth URL locally.
EOF
}

print_header() {
    local brand="ShipGlows DevServer"
    local title="Clerk CLI Login"
    echo -e "${CYAN}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                  ║${NC}"
    echo -e "${CYAN}║  ${YELLOW}              ${brand}              ${CYAN}  ║${NC}"
    echo -e "${CYAN}║  ${YELLOW}             ${title}              ${CYAN}  ║${NC}"
    echo -e "${CYAN}║                                                  ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
}

load_remote_host() {
    if ! _load_remote_host_core; then
        echo -e "${RED}✗ Aucune connexion distante ShipGlows configurée.${NC}"
        echo -e "${YELLOW}  Ouvre le menu local 'urls', choisis c) Configurer nouveau serveur, puis entre l'adresse SSH.${NC}"
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

    if [ -n "${TMP_DIR:-}" ] && [ -d "$TMP_DIR" ]; then
        rm -rf "$TMP_DIR"
    fi
}

extract_oauth_url() {
    sed -nE 's/.*(https:\/\/[^[:space:]"]+).*/\1/p' "$OAUTH_OUTPUT_FILE" | tail -1
}

parse_clerk_oauth_port_from_text() {
    local text="$1"
    local port=""

    port="$(printf "%s\n" "$text" | sed -nE 's/.*redirect_uri=http%3A%2F%2F(127\.0\.0\.1|localhost)%3A([0-9]{2,5})%2F(callback|oauth(%2F|\/)callback).*/\2/p' | tail -1)"
    if [ -n "$port" ]; then
        echo "$port"
        return 0
    fi

    port="$(printf "%s\n" "$text" | sed -nE 's/.*http:\/\/(127\.0\.0\.1|localhost):([0-9]{2,5})\/(callback|oauth\/callback).*/\2/p' | tail -1)"
    if [ -n "$port" ]; then
        echo "$port"
        return 0
    fi

    return 1
}

extract_callback_port() {
    parse_clerk_oauth_port_from_text "$(cat "$OAUTH_OUTPUT_FILE")"
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

remote_clerk_whoami() {
    run_remote_ssh "bash -lc '$remote_clerk_path_prefix clerk whoami'" 2>&1
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

run_clerk_login() {
    local oauth_url=""
    local callback_port=""
    local whoami_output=""

    # Batched SSH: connectivity + CLI + auth (1 round-trip vs 3)
    local _cl_batch=""
    if ! _cl_batch=$(run_remote_ssh "bash -lc '$remote_clerk_path_prefix echo ok && (command -v clerk >/dev/null 2>&1 && echo CLI=ok || echo CLI=no) && (clerk whoami >/dev/null 2>&1 && echo AUTH=ok || echo AUTH=no)'"); then
        echo -e "${RED}✗ SSH inaccessible vers '$REMOTE_HOST'.${NC}"
        echo -e "${YELLOW}  Le détail SSH affiché ci-dessus indique la cause.${NC}"
        return 1
    fi

    if ! echo "$_cl_batch" | grep -q "CLI=ok"; then
        echo -e "${RED}✗ Clerk CLI absent sur le serveur distant.${NC}"
        echo -e "${YELLOW}  À lancer dans un terminal connecté au serveur:${NC}"
        echo "  npm install -g clerk"
        echo "  # ou: curl -fsSL https://clerk.com/install | bash"
        return 1
    fi

    if echo "$_cl_batch" | grep -q "AUTH=ok"; then
        echo -e "${GREEN}✓ Clerk CLI déjà authentifiée sur le serveur.${NC}"
        whoami_output="$(remote_clerk_whoami || true)"
        [ -n "$whoami_output" ] && printf '%s\n' "$whoami_output" | sed 's/^/  /'
        return 0
    fi

    : > "$OAUTH_OUTPUT_FILE"
    : > "$TUNNEL_LOG_FILE"
    REMOTE_SSH_PID=""
    TUNNEL_PID=""

    run_remote_ssh "bash -lc '$remote_clerk_path_prefix BROWSER=echo clerk auth login & pid=\$!; wait \$pid'" \
        > "$OAUTH_OUTPUT_FILE" \
        2>&1 &
    REMOTE_SSH_PID="$!"

    if ! wait_for_output_or_timeout; then
        echo -e "${RED}✗ Impossible d'extraire URL OAuth + port callback depuis la sortie Clerk.${NC}"
        echo -e "${YELLOW}Sortie Clerk capturée:${NC}"
        sed 's/^/  /' "$OAUTH_OUTPUT_FILE" | tail -20
        echo -e "${YELLOW}  Si Clerk affiche une URL sans callback localhost, colle la sortie pour adapter le flow.${NC}"
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

    echo -e "${BLUE}🔁 Tunnel Clerk OAuth: localhost:${callback_port} -> ${REMOTE_HOST}:127.0.0.1:${callback_port}${NC}"
    local tunnel_args=("-N" "-L" "${callback_port}:127.0.0.1:${callback_port}")
    while IFS= read -r arg; do
        tunnel_args+=("$arg")
    done < <(ssh_tunnel_args)
    ssh "${tunnel_args[@]}" "$REMOTE_HOST" >"$TUNNEL_LOG_FILE" 2>&1 &
    TUNNEL_PID="$!"
    sleep 1
    if ! kill -0 "$TUNNEL_PID" 2>/dev/null; then
        echo -e "${RED}✗ Impossible de démarrer le tunnel SSH OAuth Clerk.${NC}"
        return 1
    fi

    open_browser_or_print "$oauth_url" "Clerk OAuth"
    echo -e "${YELLOW}⏳ Finalise le login Clerk dans le navigateur...${NC}"

    if ! wait_remote_login_completion "$LOGIN_TIMEOUT_SECONDS"; then
        return 1
    fi

    if remote_clerk_whoami >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Login Clerk confirmé sur le serveur distant.${NC}"
        whoami_output="$(remote_clerk_whoami || true)"
        [ -n "$whoami_output" ] && printf '%s\n' "$whoami_output" | sed 's/^/  /'
        return 0
    fi

    echo -e "${RED}✗ Login terminé mais auth Clerk non confirmée sur le serveur.${NC}"
    return 1
}

main() {
    set -euo pipefail

    if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
        usage
        exit 0
    fi

    print_header
    mkdir -p "$CONFIG_DIR"
    load_remote_host

    trap cleanup EXIT INT TERM

    TMP_DIR="$(mktemp -d)"
    OAUTH_OUTPUT_FILE="$TMP_DIR/clerk-oauth-login.log"
    TUNNEL_LOG_FILE="$TMP_DIR/clerk-oauth-tunnel.log"

    echo -e "${BLUE}Connexion distante:${NC} ${GREEN}$REMOTE_HOST${NC}"
    echo ""

    if ! run_clerk_login; then
        echo -e "${RED}✗ Flow Clerk OAuth terminé avec erreur.${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Flow Clerk OAuth terminé avec succès.${NC}"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    main "$@"
fi
