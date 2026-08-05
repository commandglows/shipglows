#!/bin/bash
# Private-data path and local configuration resolver.
#
# This file deliberately parses a tiny KEY=value format instead of sourcing the
# operator configuration. The configuration may carry a private Git remote and
# must never become executable shell input.

shipglows_private_data_error() {
    printf 'ShipGlows private-data config: %s\n' "$*" >&2
}

shipglows_private_data_config_path() {
    printf '%s\n' "${SHIPGLOWS_PRIVATE_DATA_CONFIG_FILE:-${XDG_CONFIG_HOME:-$HOME/.config}/shipglows/private-data.env}"
}

shipglows_private_data_validate_value() {
    local key="$1"
    local value="$2"

    [ -n "$value" ] || {
        shipglows_private_data_error "$key must not be empty"
        return 1
    }

    case "$value" in
        *$'\n'*|*$'\r'*|*[[:cntrl:]]*)
            shipglows_private_data_error "$key contains a control character"
            return 1
            ;;
    esac
}

shipglows_private_data_load_config() {
    local config_file line key value mode
    config_file="$(shipglows_private_data_config_path)"

    [ -e "$config_file" ] || return 0
    [ -f "$config_file" ] && [ ! -L "$config_file" ] || {
        shipglows_private_data_error "expected a regular file at $config_file"
        return 1
    }
    [ -O "$config_file" ] || {
        shipglows_private_data_error "config file must be owned by the current user"
        return 1
    }
    mode="$(stat -c '%a' -- "$config_file" 2>/dev/null)" || {
        shipglows_private_data_error "cannot inspect config file permissions"
        return 1
    }
    case "$mode" in
        *00) ;;
        *)
            shipglows_private_data_error "config file must not be accessible by group or others"
            return 1
            ;;
    esac

    while IFS= read -r line || [ -n "$line" ]; do
        case "$line" in
            ''|'#'*) continue ;;
            *=*)
                key="${line%%=*}"
                value="${line#*=}"
                ;;
            *)
                shipglows_private_data_error "invalid line in $config_file"
                return 1
                ;;
        esac

        case "$key" in
            SHIPGLOWS_PRIVATE_DATA_REPO|SHIPGLOWS_PRIVATE_DATA_DIR)
                shipglows_private_data_validate_value "$key" "$value" || return 1
                if [ "$key" = "SHIPGLOWS_PRIVATE_DATA_REPO" ] && [ -z "${SHIPGLOWS_PRIVATE_DATA_REPO+x}" ]; then
                    export SHIPGLOWS_PRIVATE_DATA_REPO="$value"
                elif [ "$key" = "SHIPGLOWS_PRIVATE_DATA_DIR" ] && [ -z "${SHIPGLOWS_PRIVATE_DATA_DIR+x}" ]; then
                    export SHIPGLOWS_PRIVATE_DATA_DIR="$value"
                fi
                ;;
            *)
                shipglows_private_data_error "unknown key $key"
                return 1
                ;;
        esac
    done < "$config_file"
}

shipglows_private_data_init() {
    local default_private_dir
    default_private_dir="${SHIPGLOWS_PRIVATE_DIR:-${SHIPGLOWS_STATE_DIR:-$HOME/.shipglows}/private}"
    export SHIPGLOWS_PRIVATE_DIR="$default_private_dir"

    shipglows_private_data_load_config || return 1

    if [ -z "${SHIPGLOWS_PRIVATE_DATA_DIR+x}" ] && [ -n "${SHIPGLOWS_PRIVATE_ROOT:-}" ]; then
        export SHIPGLOWS_PRIVATE_DATA_DIR="$SHIPGLOWS_PRIVATE_ROOT"
    fi
    export SHIPGLOWS_PRIVATE_DATA_DIR="${SHIPGLOWS_PRIVATE_DATA_DIR:-$SHIPGLOWS_PRIVATE_DIR/data}"

    # Legacy compatibility for consumers that have not yet been refreshed.
    export SHIPGLOWS_PRIVATE_ROOT="${SHIPGLOWS_PRIVATE_ROOT:-$SHIPGLOWS_PRIVATE_DATA_DIR}"
}
