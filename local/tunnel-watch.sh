#!/bin/bash

# tunnel-watch.sh - Synchronise les tunnels locaux quand les ports distants changent.

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=remote-helpers.sh
source "$SCRIPT_DIR/remote-helpers.sh"

shipglowz_migrate_local_config || true
CONFIG_DIR="$(shipglowz_local_config_dir)"
WATCH_LOCK_DIR="$CONFIG_DIR/tunnel-watch.lock"
INTERVAL="${SHIPGLOWZ_TUNNEL_WATCH_INTERVAL:-${SHIPFLOW_TUNNEL_WATCH_INTERVAL:-60}}"

if ! [[ "$INTERVAL" =~ ^[1-9][0-9]*$ ]]; then
    INTERVAL=5
fi

if REMOTE_HOST="$(shipglowz_read_config_value current_connection 2>/dev/null)"; then
    :
else
    REMOTE_HOST="${SHIPGLOWZ_SSH_REMOTE_HOST:-${SHIPFLOW_SSH_REMOTE_HOST:-}}"
fi

if SSH_IDENTITY_FILE="$(shipglowz_read_config_value current_identity_file 2>/dev/null)"; then
    :
else
    SSH_IDENTITY_FILE=""
fi
if SSH_AUTH_METHOD="$(shipglowz_read_config_value current_auth_method 2>/dev/null)"; then
    :
else
    SSH_AUTH_METHOD="key"
fi

if [ -z "$REMOTE_HOST" ] || ! validate_connection_target "$REMOTE_HOST"; then
    echo "Impossible de démarrer la synchronisation : connexion distante invalide." >&2
    exit 1
fi

if ! validate_identity_file "$SSH_IDENTITY_FILE"; then
    echo "Clé SSH locale invalide ou introuvable : $SSH_IDENTITY_FILE" >&2
    exit 1
fi

if ! mkdir "$WATCH_LOCK_DIR" 2>/dev/null; then
    echo "La synchronisation des tunnels est déjà active pour $REMOTE_HOST." >&2
    exit 0
fi

cleanup() {
    rmdir "$WATCH_LOCK_DIR" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

snapshot_ports() {
    local ports=""
    if ! ports="$(run_remote_ssh "$(shipglowz_remote_pm2_ports_command comma)" 2>/dev/null)"; then
        return 1
    fi
    printf '%s\n' "$ports" | tr ',' '\n' | sed '/^$/d' | sort -t: -k1,1n -k2,2
}

sync_tunnels() {
    local ports="$1"
    if [ -n "$ports" ]; then
        "$SCRIPT_DIR/dev-tunnel.sh" >/dev/null 2>&1 ||
            {
                echo "Synchronisation des tunnels échouée ; nouvelle tentative dans ${INTERVAL}s." >&2
                return 1
            }
    else
        "$SCRIPT_DIR/dev-tunnel.sh" --stop >/dev/null 2>&1 || return 1
    fi
}

watch_remote_events() {
    run_remote_ssh 'tail -n 0 -F "${SHIPGLOWZ_TUNNEL_EVENT_FILE:-${SHIPFLOW_TUNNEL_EVENT_FILE:-$HOME/.shipglowz/tunnel-events.log}}"' 2>/dev/null
}

echo "Synchronisation automatique active pour $REMOTE_HOST (intervalle : ${INTERVAL}s)."
previous="__uninitialised__"

while true; do
    if current="$(snapshot_ports)" && [ "$current" != "$previous" ]; then
        if sync_tunnels "$current"; then
            previous="$current"
        fi
    fi

    # One long-lived SSH command blocks until the server emits a lifecycle
    # event. If SSH drops, retry after a slow backoff and resync once.
    while IFS= read -r _event; do
        if current="$(snapshot_ports)" && [ "$current" != "$previous" ]; then
            if sync_tunnels "$current"; then
                previous="$current"
            fi
        fi
    done < <(watch_remote_events)
    sleep "$INTERVAL"
done
