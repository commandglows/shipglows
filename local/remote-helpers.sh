#!/bin/bash
# Shared SSH and remote PM2 helpers for ShipGlows local tunnel tools.

shipglows_local_config_dir() {
    printf '%s\n' "${SHIPGLOWS_LOCAL_CONFIG_DIR:-$HOME/.shipglows}"
}

shipglows_legacy_local_config_dir() {
    printf '%s\n' "${SHIPGLOWS_LEGACY_LOCAL_CONFIG_DIR:-${SHIPGLOWS_LEGACY_LOCAL_CONFIG_DIR:-$HOME/.shipglows}}"
}

shipglows_local_config_file() {
    local name="$1"
    printf '%s/%s\n' "$(shipglows_local_config_dir)" "$name"
}

shipglows_migrate_local_config() {
    local new_dir legacy_dir
    new_dir="$(shipglows_local_config_dir)"
    legacy_dir="$(shipglows_legacy_local_config_dir)"

    mkdir -p "$new_dir" 2>/dev/null || return 1
    chmod 700 "$new_dir" 2>/dev/null || true

    [ -d "$legacy_dir" ] || return 0
    [ "$legacy_dir" = "$new_dir" ] && return 0

    local name
    for name in current_connection current_identity_file current_auth_method connections.conf envs.reg flutter-web-sessions.tsv; do
        if [ ! -e "$new_dir/$name" ] && [ -e "$legacy_dir/$name" ]; then
            cp -p "$legacy_dir/$name" "$new_dir/$name" 2>/dev/null || true
        fi
    done
}

shipglows_read_config_value() {
    local name="$1"
    local new_path legacy_path
    new_path="$(shipglows_local_config_file "$name")"
    legacy_path="$(shipglows_legacy_local_config_dir)/$name"

    if [ -f "$new_path" ]; then
        cat "$new_path"
        return 0
    fi
    if [ -f "$legacy_path" ]; then
        cat "$legacy_path"
        return 0
    fi
    return 1
}

shipglows_write_config_value() {
    local name="$1"
    local value="$2"
    local path
    path="$(shipglows_local_config_file "$name")"
    mkdir -p "$(dirname "$path")" 2>/dev/null || return 1
    printf '%s\n' "$value" > "$path"
}

expand_identity_path() {
    local identity_file="$1"
    case "$identity_file" in
        "~") echo "$HOME" ;;
        "~/"*) echo "$HOME/${identity_file#~/}" ;;
        *) echo "$identity_file" ;;
    esac
}

normalize_identity_path() {
    local identity_file="$1"
    [ -z "$identity_file" ] && return 0

    local expanded
    expanded=$(expand_identity_path "$identity_file")

    case "$expanded" in
        /*)
            echo "$expanded"
            ;;
        *)
            local dir="${expanded%/*}"
            local base="${expanded##*/}"
            if [ "$dir" = "$expanded" ]; then
                dir="."
            fi

            local abs_dir
            if abs_dir=$(cd "$dir" 2>/dev/null && pwd -P); then
                echo "$abs_dir/$base"
            else
                echo "$(pwd -P)/$expanded"
            fi
            ;;
    esac
}

identity_path_candidates() {
    local identity_file="$1"
    [ -z "$identity_file" ] && return 0

    local expanded
    expanded=$(expand_identity_path "$identity_file")

    case "$expanded" in
        /*)
            printf '%s\n' "$expanded"
            ;;
        */*)
            normalize_identity_path "$expanded"
            ;;
        *)
            printf '%s\n' "$(pwd -P)/$expanded"
            [ -n "${HOME:-}" ] && printf '%s\n' "$HOME/.ssh/$expanded"
            [ -n "${HOME:-}" ] && printf '%s\n' "$HOME/$expanded"
            ;;
    esac
}

resolve_identity_path() {
    local identity_file="$1"
    [ -z "$identity_file" ] && return 0

    local candidate
    while IFS= read -r candidate; do
        [ -n "$candidate" ] || continue
        if [ -f "$candidate" ]; then
            normalize_identity_path "$candidate"
            return 0
        fi
    done < <(identity_path_candidates "$identity_file")

    return 1
}

validate_connection_target() {
    local target="$1"
    [[ -n "$target" ]] || return 1
    [[ "$target" != -* ]] || return 1
    [[ "$target" != *$'\n'* ]] || return 1
    [[ "$target" != *$'\r'* ]] || return 1
    [[ "$target" =~ ^[A-Za-z0-9._@-]+$ ]] || return 1
    [[ "$target" != *@*@* ]] || return 1

    local user=""
    local host="$target"
    if [[ "$target" == *"@"* ]]; then
        user="${target%%@*}"
        host="${target#*@}"
        validate_ssh_user "$user" || return 1
    fi

    validate_connection_host "$host"
}

validate_ssh_user() {
    local user="$1"
    [[ -n "$user" ]] || return 1
    [[ "$user" != -* ]] || return 1
    [[ "$user" =~ ^[A-Za-z0-9._-]+$ ]] || return 1
}

validate_connection_host() {
    local host="$1"
    [[ -n "$host" ]] || return 1
    [[ "$host" != -* ]] || return 1
    [[ "$host" != *$'\n'* ]] || return 1
    [[ "$host" != *$'\r'* ]] || return 1

    if [[ "$host" =~ ^[A-Za-z0-9._-]+$ ]] && is_exact_ssh_config_alias "$host"; then
        return 0
    fi

    [[ "$host" =~ ^[A-Za-z0-9.-]+$ ]] || return 1

    is_valid_ipv4 "$host" ||
        is_valid_dns_name "$host"
}

is_valid_ipv4() {
    local ip="$1"
    [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || return 1

    local -a octets
    local octet
    IFS='.' read -r -a octets <<< "$ip"
    for octet in "${octets[@]}"; do
        [[ "$octet" =~ ^[0-9]+$ ]] || return 1
        [ "$((10#$octet))" -le 255 ] || return 1
    done
}

is_valid_dns_name() {
    local host="$1"
    [ "${#host}" -le 253 ] || return 1
    [[ "$host" == *.* ]] || return 1
    [[ "$host" != *..* ]] || return 1

    local -a labels
    local label tld
    IFS='.' read -r -a labels <<< "$host"
    for label in "${labels[@]}"; do
        [ -n "$label" ] || return 1
        [ "${#label}" -le 63 ] || return 1
        [[ "$label" =~ ^[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?$ ]] || return 1
    done

    tld="${labels[$((${#labels[@]} - 1))]}"
    [[ "$tld" =~ ^[A-Za-z][A-Za-z0-9-]*$ ]] || return 1
}

is_exact_ssh_config_alias() {
    local alias="$1"
    local ssh_config="${HOME:-}/.ssh/config"
    [ -f "$ssh_config" ] || return 1

    awk -v alias="$alias" '
        tolower($1) == "host" {
            for (i = 2; i <= NF; i++) {
                if ($i == alias) {
                    found = 1
                }
            }
        }
        END { exit found ? 0 : 1 }
    ' "$ssh_config"
}

validate_identity_file() {
    local identity_file="$1"
    [ -z "$identity_file" ] && return 0
    [[ "$identity_file" != -* ]] || return 1
    [[ "$identity_file" != *$'\n'* ]] || return 1
    [[ "$identity_file" != *$'\r'* ]] || return 1
    resolve_identity_path "$identity_file" >/dev/null
}

shipglows_ssh_config_file() {
    printf '%s\n' "${SHIPGLOWS_SSH_CONFIG_FILE:-$HOME/.ssh/config}"
}

shipglows_ssh_managed_config_file() {
    printf '%s\n' "${SHIPGLOWS_SSH_MANAGED_CONFIG_FILE:-$HOME/.ssh/shipglows.conf}"
}

shipglows_ssh_target_host() {
    local target="$1"
    target="${target#*@}"
    validate_connection_host "$target" || return 1
    printf '%s\n' "$target"
}

shipglows_ssh_target_user() {
    local target="$1"
    if [[ "$target" == *"@"* ]]; then
        local user="${target%%@*}"
        validate_ssh_user "$user" || return 1
        printf '%s\n' "$user"
    fi
}

shipglows_ssh_managed_block_id() {
    local host="$1"
    printf '%s\n' "$host" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9._-]/-/g'
}

sync_standard_ssh_identity() {
    local target="$1"
    local identity_file="$2"
    local host user resolved_identity config_file managed_file ssh_dir block_id config_tmp managed_tmp

    host="$(shipglows_ssh_target_host "$target")" || return 1
    user="$(shipglows_ssh_target_user "$target")" || return 1
    resolved_identity="$(resolve_identity_path "$identity_file")" || return 1
    config_file="$(shipglows_ssh_config_file)"
    managed_file="$(shipglows_ssh_managed_config_file)"
    ssh_dir="$(dirname "$config_file")"
    block_id="$(shipglows_ssh_managed_block_id "$host")"

    [ -z "$user" ] || validate_ssh_user "$user" || return 1
    [ ! -L "$config_file" ] || return 1
    mkdir -p "$ssh_dir" || return 1
    chmod 700 "$ssh_dir" 2>/dev/null || true
    touch "$config_file" || return 1
    chmod 600 "$config_file" 2>/dev/null || true

    managed_tmp="$(mktemp "$ssh_dir/.shipglows.conf.XXXXXX")" || return 1
    if [ -f "$managed_file" ]; then
        awk -v start="# >>> ShipGlows managed host ${block_id}" -v end="# <<< ShipGlows managed host ${block_id}" '
            $0 == start { skip = 1; next }
            $0 == end { skip = 0; next }
            !skip { print }
        ' "$managed_file" > "$managed_tmp" || {
            rm -f "$managed_tmp"
            return 1
        }
    fi

    {
        [ -s "$managed_tmp" ] && printf '\n'
        printf '%s\n' "# >>> ShipGlows managed host ${block_id}"
        printf '%s\n' "Host $host"
        [ -n "$user" ] && printf '%s\n' "    User $user"
        printf '%s\n' "    IdentityFile $resolved_identity"
        printf '%s\n' "    IdentitiesOnly yes"
        printf '%s\n' "# <<< ShipGlows managed host ${block_id}"
    } >> "$managed_tmp" || {
        rm -f "$managed_tmp"
        return 1
    }
    chmod 600 "$managed_tmp" 2>/dev/null || true
    mv "$managed_tmp" "$managed_file" || {
        rm -f "$managed_tmp"
        return 1
    }

    if ! grep -Fqx "Include $managed_file" "$config_file"; then
        config_tmp="$(mktemp "$ssh_dir/.config.XXXXXX")" || return 1
        {
            printf '%s\n' "# ShipGlows managed SSH identities"
            printf '%s\n' "Include $managed_file"
            cat "$config_file"
        } > "$config_tmp" || {
            rm -f "$config_tmp"
            return 1
        }
        chmod 600 "$config_tmp" 2>/dev/null || true
        mv "$config_tmp" "$config_file" || {
            rm -f "$config_tmp"
            return 1
        }
    fi
}

ssh_public_key_type_allowed() {
    case "${1:-}" in
        ssh-ed25519|sk-ssh-ed25519@openssh.com|ecdsa-sha2-nistp256|ecdsa-sha2-nistp384|ecdsa-sha2-nistp521|sk-ecdsa-sha2-nistp256@openssh.com|ssh-rsa)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

validate_ssh_public_key_file() {
    local public_key_file="$1"
    [ -f "$public_key_file" ] && [ -r "$public_key_file" ] || return 1
    [ "$(awk 'END { print NR }' "$public_key_file")" -eq 1 ] || return 1

    local key_type key_blob key_comment
    IFS=' ' read -r key_type key_blob key_comment < "$public_key_file" || return 1
    ssh_public_key_type_allowed "$key_type" || return 1
    [[ "$key_blob" =~ ^[A-Za-z0-9+/]+={0,3}$ ]] || return 1
    command -v ssh-keygen >/dev/null 2>&1 || return 1
    ssh-keygen -lf "$public_key_file" >/dev/null 2>&1
}

ssh_public_key_blob() {
    local public_key_file="$1"
    validate_ssh_public_key_file "$public_key_file" || return 1
    awk '{ print $2 }' "$public_key_file"
}

ssh_public_key_fingerprint() {
    local public_key_file="$1"
    validate_ssh_public_key_file "$public_key_file" || return 1
    ssh-keygen -lf "$public_key_file" -E sha256 2>/dev/null | awk '{ print $2; exit }'
}

prepare_identity_public_key() {
    local identity_file="$1"
    local output_file="$2"
    local resolved_identity derived_file source_public

    resolved_identity="$(resolve_identity_path "$identity_file")" || return 1
    command -v ssh-keygen >/dev/null 2>&1 || return 1
    derived_file="$(mktemp "${TMPDIR:-/tmp}/shipglows-derived-key.XXXXXX")" || return 1
    chmod 600 "$derived_file" 2>/dev/null || true

    if ! ssh-keygen -y -f "$resolved_identity" > "$derived_file" 2>/dev/null; then
        rm -f "$derived_file"
        return 1
    fi
    validate_ssh_public_key_file "$derived_file" || {
        rm -f "$derived_file"
        return 1
    }

    source_public="${resolved_identity}.pub"
    if [ -f "$source_public" ]; then
        if ! validate_ssh_public_key_file "$source_public" ||
            [ "$(ssh_public_key_blob "$source_public")" != "$(ssh_public_key_blob "$derived_file")" ]; then
            rm -f "$derived_file"
            return 1
        fi
        cp "$source_public" "$output_file" || {
            rm -f "$derived_file"
            return 1
        }
    else
        cp "$derived_file" "$output_file" || {
            rm -f "$derived_file"
            return 1
        }
    fi

    rm -f "$derived_file"
    chmod 600 "$output_file" 2>/dev/null || true
    validate_ssh_public_key_file "$output_file"
}

shipglows_identity_target_slug() {
    local target="${1:-server}"
    target="${target#*@}"
    target="$(printf '%s' "$target" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9._-]/-/g; s/^-*//; s/-*$//')"
    printf '%s\n' "${target:-server}"
}

shipglows_available_identity_path() {
    local target="$1"
    local ssh_dir="${HOME:?}/.ssh"
    local slug base candidate suffix=1
    slug="$(shipglows_identity_target_slug "$target")"
    base="$ssh_dir/shipglows_${slug}_ed25519"
    candidate="$base"

    while [ -e "$candidate" ] || [ -e "${candidate}.pub" ]; do
        suffix=$((suffix + 1))
        [ "$suffix" -le 99 ] || return 1
        candidate="${base}_${suffix}"
    done
    printf '%s\n' "$candidate"
}

generate_shipglows_identity() {
    local target="$1"
    local identity_file="${2:-}"
    command -v ssh-keygen >/dev/null 2>&1 || return 1

    mkdir -p "$HOME/.ssh" || return 1
    chmod 700 "$HOME/.ssh" 2>/dev/null || true
    if [ -z "$identity_file" ]; then
        identity_file="$(shipglows_available_identity_path "$target")" || return 1
    else
        identity_file="$(normalize_identity_path "$identity_file")"
    fi
    [ ! -e "$identity_file" ] && [ ! -e "${identity_file}.pub" ] || return 1

    ssh-keygen -q -t ed25519 -N "" -C "shipglows:$(shipglows_identity_target_slug "$target")" -f "$identity_file" || return 1
    chmod 600 "$identity_file" 2>/dev/null || true
    chmod 644 "${identity_file}.pub" 2>/dev/null || true
    printf '%s\n' "$identity_file"
}

ssh_authorized_key_install_command() {
    cat <<'EOF'
set -eu
umask 077
IFS= read -r shipglows_public_key
[ -n "$shipglows_public_key" ]
shipglows_key_blob=$(printf '%s\n' "$shipglows_public_key" | awk '{ print $2 }')
[ -n "$shipglows_key_blob" ]
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
touch "$HOME/.ssh/authorized_keys"
chmod 600 "$HOME/.ssh/authorized_keys"
if awk -v blob="$shipglows_key_blob" '{ for (i = 1; i <= NF; i++) if ($i == blob) found = 1 } END { exit found ? 0 : 1 }' "$HOME/.ssh/authorized_keys"; then
    printf '%s\n' present
else
    if [ -s "$HOME/.ssh/authorized_keys" ]; then
        printf '\n' >> "$HOME/.ssh/authorized_keys"
    fi
    printf '%s\n' "$shipglows_public_key" >> "$HOME/.ssh/authorized_keys"
    printf '%s\n' installed
fi
EOF
}

install_remote_ssh_public_key() {
    local public_key_file="$1"
    validate_ssh_public_key_file "$public_key_file" || return 1
    [ -n "${REMOTE_HOST:-}" ] || return 1
    run_remote_ssh "$(ssh_authorized_key_install_command)" < "$public_key_file"
}

ssh_key_only_args() {
    local identity_file="$1"
    local resolved_identity
    resolved_identity="$(resolve_identity_path "$identity_file")" || return 1

    while IFS= read -r arg; do
        [ -n "$arg" ] && printf '%s\n' "$arg"
    done < <(ssh_base_args)
    printf '%s\n' \
        "-o" "ControlMaster=no" \
        "-o" "ControlPath=none" \
        "-o" "BatchMode=yes" \
        "-o" "PasswordAuthentication=no" \
        "-o" "KbdInteractiveAuthentication=no" \
        "-o" "PreferredAuthentications=publickey" \
        "-o" "PubkeyAuthentication=yes" \
        "-i" "$resolved_identity" \
        "-o" "IdentitiesOnly=yes"
}

verify_ssh_key_only() {
    local identity_file="$1"
    [ -n "${REMOTE_HOST:-}" ] || return 1
    local args=()
    while IFS= read -r arg; do
        args+=("$arg")
    done < <(ssh_key_only_args "$identity_file")
    ssh "${args[@]}" "$REMOTE_HOST" "echo shipglows-key-ok" >/dev/null
}

ssh_auth_mode() {
    local mode="${SSH_AUTH_METHOD:-key}"
    case "$mode" in
        password|key)
            printf '%s\n' "$mode"
            ;;
        *)
            printf '%s\n' "key"
            ;;
    esac
}

ssh_auth_args() {
    case "$(ssh_auth_mode)" in
        password)
            printf '%s\n' "-o" "BatchMode=no" "-o" "PreferredAuthentications=password,keyboard-interactive" "-o" "PubkeyAuthentication=no" "-o" "KbdInteractiveAuthentication=yes" "-o" "NumberOfPasswordPrompts=1"
            ;;
        *)
            printf '%s\n' "-o" "BatchMode=yes"
            ;;
    esac
}

ssh_control_path() {
    # OpenSSH appends a temporary suffix while creating the socket. Keep this
    # deliberately short for Termux and other systems with a 108-byte limit.
    local control_dir="${HOME:-.}/.s"
    mkdir -p "$control_dir" 2>/dev/null || true
    chmod 700 "$control_dir" 2>/dev/null || true
    printf '%s\n' "$control_dir/%C"
}

ssh_connection_reuse_args() {
    case "$(ssh_auth_mode)" in
        password)
            printf '%s\n' \
                "-o" "ControlMaster=auto" \
                "-o" "ControlPersist=8h" \
                "-o" "ControlPath=$(ssh_control_path)"
            ;;
    esac
}

ssh_base_args() {
    printf '%s\n' "-o" "ConnectTimeout=7" "-o" "StrictHostKeyChecking=accept-new"
}

# -----------------------------------------------------------------------------
# check_local_port_free — Check if a TCP port is free locally
# Uses lsof, falls back to ss, returns 0 if free
# -----------------------------------------------------------------------------
check_local_port_free() {
    local port="$1"
    if command -v lsof >/dev/null 2>&1 && lsof -nP -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1; then
        return 1
    fi
    if command -v ss >/dev/null 2>&1 && ss -ltn "( sport = :$port )" 2>/dev/null | grep -q ":$port"; then
        return 1
    fi
    return 0
}

validate_tcp_port() {
    local port="$1"
    [[ "$port" =~ ^[0-9]+$ ]] || return 1
    [ "$((10#$port))" -ge 1 ] && [ "$((10#$port))" -le 65535 ]
}

ssh_args() {
    while IFS= read -r arg; do
        [ -n "$arg" ] || continue
        printf '%s\n' "$arg"
    done < <(ssh_base_args)
    while IFS= read -r arg; do
        [ -n "$arg" ] || continue
        printf '%s\n' "$arg"
    done < <(ssh_auth_args)
    if [ -n "${SSH_IDENTITY_FILE:-}" ]; then
        if [ "$(ssh_auth_mode)" != "password" ]; then
            printf '%s\n' "-i" "$(resolve_identity_path "$SSH_IDENTITY_FILE" || normalize_identity_path "$SSH_IDENTITY_FILE")" "-o" "IdentitiesOnly=yes"
        fi
    fi
}

ssh_command_args() {
    while IFS= read -r arg; do
        [ -n "$arg" ] || continue
        printf '%s\n' "$arg"
    done < <(ssh_base_args)
    while IFS= read -r arg; do
        [ -n "$arg" ] || continue
        printf '%s\n' "$arg"
    done < <(ssh_connection_reuse_args)
    while IFS= read -r arg; do
        [ -n "$arg" ] || continue
        printf '%s\n' "$arg"
    done < <(ssh_auth_args)
    if [ -n "${SSH_IDENTITY_FILE:-}" ]; then
        if [ "$(ssh_auth_mode)" != "password" ]; then
            printf '%s\n' "-i" "$(resolve_identity_path "$SSH_IDENTITY_FILE" || normalize_identity_path "$SSH_IDENTITY_FILE")" "-o" "IdentitiesOnly=yes"
        fi
    fi
}

ssh_tunnel_args() {
    while IFS= read -r arg; do
        [ -n "$arg" ] || continue
        printf '%s\n' "$arg"
    done < <(ssh_base_args)

    case "$(ssh_auth_mode)" in
        password)
            while IFS= read -r arg; do
                [ -n "$arg" ] || continue
                printf '%s\n' "$arg"
            done < <(ssh_connection_reuse_args)
            printf '%s\n' "-o" "BatchMode=yes"
            ;;
        *)
            while IFS= read -r arg; do
                [ -n "$arg" ] || continue
                printf '%s\n' "$arg"
            done < <(ssh_auth_args)
            if [ -n "${SSH_IDENTITY_FILE:-}" ]; then
                printf '%s\n' "-i" "$(resolve_identity_path "$SSH_IDENTITY_FILE" || normalize_identity_path "$SSH_IDENTITY_FILE")" "-o" "IdentitiesOnly=yes"
            fi
            ;;
    esac
}

ensure_reusable_ssh_session() {
    [ "$(ssh_auth_mode)" = "password" ] || return 0
    [ -n "${REMOTE_HOST:-}" ] || return 1

    local args=()
    local check_output=""
    local open_output=""
    while IFS= read -r arg; do
        args+=("$arg")
    done < <(ssh_command_args)

    if check_output=$(ssh "${args[@]}" -O check "$REMOTE_HOST" 2>&1); then
        return 0
    fi

    echo -e "${BLUE}🔐 Ouverture de la session SSH réutilisable...${NC}" >&2
    if open_output=$(ssh "${args[@]}" -f -N "$REMOTE_HOST" 2>&1); then
        return 0
    fi

    if [ -n "$open_output" ]; then
        echo -e "${YELLOW}  Détail SSH: ${open_output//$'\n'/ }${NC}" >&2
    elif [ -n "$check_output" ]; then
        echo -e "${YELLOW}  Détail SSH: ${check_output//$'\n'/ }${NC}" >&2
    fi
    return 1
}

run_remote_ssh() {
    # Password-authenticated commands need a foreground master session first.
    # Background tunnels then attach to that session without handling a password.
    if ! ensure_reusable_ssh_session; then
        return 1
    fi

    local args=()
    while IFS= read -r arg; do
        args+=("$arg")
    done < <(ssh_command_args)
    ssh "${args[@]}" "$REMOTE_HOST" "$@"
}

# -----------------------------------------------------------------------------
# Turso helpers — shared between turso-login.sh and turso-ssh.sh
# -----------------------------------------------------------------------------
remote_quote() {
    printf '%q' "$1"
}

run_remote_bash() {
    run_remote_ssh "bash -lc $(remote_quote "$1")"
}

remote_turso_command() {
    local subcommand="$1"
    local quoted_project_dir

    if [ -n "$PROJECT_DIR" ]; then
        quoted_project_dir="$(remote_quote "$PROJECT_DIR")"
        printf 'flox activate -d %s -- turso %s' "$quoted_project_dir" "$subcommand"
    else
        printf 'turso %s' "$subcommand"
    fi
}

# -----------------------------------------------------------------------------
# open_browser_or_print — Open URL in local browser or print it
#
# Arguments:
#   $1 — OAuth URL to open
#   $2 — Label for display (e.g. "Blacksmith OAuth", "Clerk OAuth")
# -----------------------------------------------------------------------------
open_browser_or_print() {
    local oauth_url="$1"
    local label="${2:-OAuth}"
    echo -e "${BLUE}🌐 URL ${label}:${NC}"
    echo "$oauth_url"
    echo ""

    if command -v open >/dev/null 2>&1; then
        open "$oauth_url" >/dev/null 2>&1 || true
        echo -e "${GREEN}✓ Navigateur ouvert via open${NC}"
    elif command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$oauth_url" >/dev/null 2>&1 || true
        echo -e "${GREEN}✓ Navigateur ouvert via xdg-open${NC}"
    elif command -v wslview >/dev/null 2>&1; then
        wslview "$oauth_url" >/dev/null 2>&1 || true
        echo -e "${GREEN}✓ Navigateur ouvert via wslview${NC}"
    elif command -v cmd.exe >/dev/null 2>&1; then
        cmd.exe /c start "" "$oauth_url" >/dev/null 2>&1 || true
        echo -e "${GREEN}✓ Navigateur ouvert via cmd.exe${NC}"
    else
        echo -e "${YELLOW}⚠ Aucun opener auto détecté.${NC}"
        echo -e "${YELLOW}  Ouvre l'URL ci-dessus manuellement dans ton navigateur local.${NC}"
    fi
}

# -----------------------------------------------------------------------------
# load_remote_host — Load SSH connection config from saved files or fallbacks
#
# Sets: REMOTE_HOST, SSH_IDENTITY_FILE, SSH_AUTH_METHOD
# Returns: 0 on success, 1 if no host could be resolved
# -----------------------------------------------------------------------------
_load_remote_host_core() {
    shipglows_migrate_local_config || true
    REMOTE_HOST=""
    SSH_IDENTITY_FILE=""
    SSH_AUTH_METHOD="key"

    if REMOTE_HOST="$(shipglows_read_config_value current_connection 2>/dev/null)"; then
        :
    else
        REMOTE_HOST="${REMOTE_HOST:-${SHIPGLOWS_SSH_REMOTE_HOST:-${SHIPGLOWS_SSH_REMOTE_HOST:-}}}"
        if [ -z "$REMOTE_HOST" ] && grep -qE '^[[:space:]]*Host[[:space:]]+hetzner([[:space:]]|$)' "$HOME/.ssh/config" 2>/dev/null; then
            REMOTE_HOST="hetzner"
        fi
    fi

    [ -n "$REMOTE_HOST" ] || return 1
    validate_connection_target "$REMOTE_HOST" || return 1

    if SSH_IDENTITY_FILE="$(shipglows_read_config_value current_identity_file 2>/dev/null)"; then
        :
    fi
    if SSH_AUTH_METHOD="$(shipglows_read_config_value current_auth_method 2>/dev/null)"; then
        :
    fi

    validate_identity_file "$SSH_IDENTITY_FILE" || return 1
    return 0
}

shipglows_remote_pm2_ports_command() {
    local format="${1:-lines}"
    local formatter="cat"
    if [ "$format" = "comma" ]; then
        formatter="paste -sd, -"
    fi

    cat <<EOF
{
# Fast path: ShipGlows env registry (~1ms file read, no subprocess)
reg="\$HOME/.shipglows/envs.reg"
new_reg="\$HOME/.shipglows/envs.reg"
if [ -f "\$new_reg" ]; then
  reg="\$new_reg"
fi
if [ -f "\$reg" ]; then
  while IFS='|' read -r name status port path; do
    [ -n "\$name" ] || continue
    [ "\$status" = "online" ] || continue
    case "\$port" in ''|*[!0-9]*) continue ;; esac
    [ "\$port" -ge 1 ] && [ "\$port" -le 65535 ] || continue
    safe_name=\$(printf '%s' "\$name" | sed 's/[,:]/ /g')
    [ -n "\$safe_name" ] || safe_name="unknown"
    printf '%s:%s\n' "\$port" "\$safe_name"
  done < "\$reg"
fi

# Also check Flutter Web sessions
if command -v tmux >/dev/null 2>&1; then
  freg="\${SHIPGLOWS_FLUTTER_WEB_SESSIONS_FILE:-\$HOME/.shipglows/flutter-web-sessions.tsv}"
  if [ ! -f "\$freg" ]; then
    freg="\${SHIPGLOWS_FLUTTER_WEB_SESSIONS_FILE:-\${SHIPGLOWS_FLUTTER_WEB_SESSIONS_FILE:-\$HOME/.shipglows/flutter-web-sessions.tsv}}"
  fi
  if [ -f "\$freg" ]; then
    while IFS='|' read -r name port project_dir session_name; do
      [ -n "\$name" ] || continue
      case "\$port" in ''|*[!0-9]*) continue ;; esac
      [ "\$port" -ge 1 ] && [ "\$port" -le 65535 ] || continue
      [ -n "\$session_name" ] || continue
      if tmux has-session -t "\$session_name" 2>/dev/null; then
        safe_name=\$(printf '%s' "\$name" | sed 's/[,:]/ /g')
        [ -n "\$safe_name" ] || safe_name="flutter-web"
        printf '%s:%s\n' "\$port" "\$safe_name"
      fi
    done < "\$freg"
  fi
fi
} | awk -F: '!seen[\$1]++' | $formatter
EOF
}
