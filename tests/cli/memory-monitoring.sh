#!/bin/bash

# Memory pressure regression tests.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
export SHIPGLOWS_ERROR_TRAPS=false
export SHIPGLOWS_STRICT_MODE=false
source "$REPO_ROOT/cli/lib.sh"

trap - ERR 2>/dev/null || true

failures=0

expect_equal() {
    local name="$1"
    local expected="$2"
    local actual="$3"
    if [ "$actual" = "$expected" ]; then
        printf 'PASS: %s\n' "$name"
    else
        printf 'FAIL: %s (expected %s, got %s)\n' "$name" "$expected" "$actual" >&2
        failures=$((failures + 1))
    fi
}

default_thresholds="$(
    env -u SHIPGLOWS_MEM_WARN_PCT -u SHIPGLOWS_MEM_CRITICAL_PCT -u SHIPGLOWS_MEM_WARN_GB \
        -u SHIPGLOWS_SWAP_WARN_PCT -u SHIPGLOWS_SWAP_CRITICAL_PCT \
        -u SHIPGLOWS_MEM_PSI_WARN_PCT -u SHIPGLOWS_MEM_PSI_CRITICAL_PCT \
        SHIPGLOWS_ERROR_TRAPS=false SHIPGLOWS_STRICT_MODE=false \
        bash -c 'source "$1/cli/config.sh"; printf "%s|%s|%s|%s|%s|%s|%s" "$SHIPGLOWS_MEM_WARN_PCT" "$SHIPGLOWS_MEM_CRITICAL_PCT" "$SHIPGLOWS_MEM_WARN_GB" "$SHIPGLOWS_SWAP_WARN_PCT" "$SHIPGLOWS_SWAP_CRITICAL_PCT" "$SHIPGLOWS_MEM_PSI_WARN_PCT" "$SHIPGLOWS_MEM_PSI_CRITICAL_PCT"' \
        bash "$REPO_ROOT"
)"
expect_equal "default thresholds are proportional" "20|10||80|90|25|10" "$default_thresholds"

set_memory_fixture() {
    fixture_total_kb="$1"
    fixture_available_kb="$2"
    fixture_swap_total_kb="$3"
    fixture_swap_free_kb="${4:-$3}"
    fixture_psi_some_avg10="${5:-0}"
    fixture_psi_full_avg10="${6:-0}"
    mem_total_kb() { printf '%s\n' "$fixture_total_kb"; }
    mem_available_kb() { printf '%s\n' "$fixture_available_kb"; }
    mem_swap_total_kb() { printf '%s\n' "$fixture_swap_total_kb"; }
    mem_swap_free_kb() { printf '%s\n' "$fixture_swap_free_kb"; }
    mem_psi_avg10() {
        case "$1" in
            some) printf '%s\n' "$fixture_psi_some_avg10" ;;
            full) printf '%s\n' "$fixture_psi_full_avg10" ;;
            *) printf 'unknown\n' ;;
        esac
    }
}

export SHIPGLOWS_MEM_WARN_PCT=20
export SHIPGLOWS_MEM_CRITICAL_PCT=10
unset SHIPGLOWS_MEM_WARN_GB

set_memory_fixture 4194304 2097152 0
expect_equal "small VM with 50% available is healthy" "ok" "$(mem_pressure_level)"

set_memory_fixture 4194304 629145 1048576
expect_equal "15% available produces a warning" "warning" "$(mem_pressure_level)"

set_memory_fixture 4194304 209715 1048576
expect_equal "5% available is critical" "critical" "$(mem_pressure_level)"

set_memory_fixture 4194304 629145 2097152 0 99.15 65.79
expect_equal "incident pressure is critical despite RAM staying above the critical threshold" \
    "critical" "$(mem_system_pressure_level)"

set_memory_fixture 4194304 2516582 2097152 921600 0.00 0.00
expect_equal "historical swap use with healthy RAM and PSI is not critical" \
    "ok" "$(mem_system_pressure_level)"

set_memory_fixture 4194304 2516582 2097152 419430 30.00 0.00
expect_equal "sustained partial memory stalls produce a warning" \
    "warning" "$(mem_system_pressure_level)"

set_memory_fixture 4194304 629145 2097152 209715 0.00 unknown
expect_equal "nearly full swap plus low RAM stays critical without PSI" \
    "critical" "$(mem_system_pressure_level)"

export SHIPGLOWS_MEM_PSI_WARN_PCT=101
export SHIPGLOWS_MEM_PSI_CRITICAL_PCT=101
set_memory_fixture 4194304 2516582 2097152 209715 30.00 11.00
expect_equal "out-of-range PSI thresholds fall back to safe defaults" \
    "critical" "$(mem_system_pressure_level)"
export SHIPGLOWS_MEM_PSI_WARN_PCT=25
export SHIPGLOWS_MEM_PSI_CRITICAL_PCT=10

set_memory_fixture 1000000 100000 1048576
expect_equal "critical boundary is a warning at exactly 10%" "warning" "$(mem_pressure_level)"

set_memory_fixture 1000000 200000 1048576
expect_equal "warning boundary is healthy at exactly 20%" "ok" "$(mem_pressure_level)"

export SHIPGLOWS_MEM_WARN_PCT=5
export SHIPGLOWS_MEM_CRITICAL_PCT=10
set_memory_fixture 4194304 629145 1048576
expect_equal "invalid threshold ordering falls back safely" "warning" "$(mem_pressure_level)"
export SHIPGLOWS_MEM_WARN_PCT=20
export SHIPGLOWS_MEM_CRITICAL_PCT=10

set_memory_fixture 4194304 2097152 0
mem_long_running_processes() { :; }
mcp_process_groups() { :; }
ps() { :; }
alerts="$(mem_alerts)"
expect_equal "missing swap is reported separately" \
    "warning|Swap is not configured; memory spikes have no swap buffer" \
    "$alerts"

set_memory_fixture 4194304 2097152 1048576
expect_equal "healthy memory with swap emits no memory alert" "" "$(mem_alerts)"

set_memory_fixture 4194304 629145 1048576
SHIPGLOWS_SECRETS_DIR="$(mktemp -d)"
MENU_STATUS_CACHE_FILE="$SHIPGLOWS_SECRETS_DIR/menu-status.cache"
UPDATE_CACHE_APT=0
UPDATE_CACHE_NPM=0
UPDATE_CACHE_PNPM=0
UPDATE_CACHE_PIP=0
UPDATE_CACHE_RUSTUP=0
updates_refresh_cache() { UPDATE_CACHE_TOTAL=0; }
disk_free_human() { printf '10G\n'; }
disk_is_low_space() { return 1; }
pm2_health_scan() { :; }
mem_long_running_processes() { :; }
register_temp_file() { :; }
refresh_menu_status_cache_sync
expect_equal "menu cache preserves warning severity" "low_mem=warning" \
    "$(grep '^low_mem=' "$MENU_STATUS_CACHE_FILE")"

warning_header="$(print_memory_pressure_warning warning)"
critical_header="$(print_memory_pressure_warning critical)"
expect_equal "warning header uses non-critical wording" "yes" \
    "$(case "$warning_header" in *'Memory pressure rising.'*) echo yes ;; *) echo no ;; esac)"
expect_equal "critical header is explicit" "yes" \
    "$(case "$critical_header" in *'Emergency rescue'*) echo yes ;; *) echo no ;; esac)"
expect_equal "healthy header remains silent" "" "$(print_memory_pressure_warning ok)"

id() {
    case "$1" in
        -u) printf '1000\n' ;;
        -un) printf 'claude\n' ;;
        *) return 1 ;;
    esac
}
ps() {
    case "$*" in
        *"pid=,ppid=,pgid=,uid=,tty=,etimes=,rss=,comm=,args="*)
            cat <<'EOF'
100 1 4242 1000 ? 3600 1048576 MainThread node /usr/local/lib/shipglows/pnpm/global/node_modules/vercel/dist/vc.js inspect redacted-target
101 1 4343 1000 ? 3600 1048576 MainThread node /usr/local/lib/shipglows/pnpm/global/node_modules/vercel/dist/vc.js list
102 1 4444 1000 pts/1 3600 1048576 MainThread node /usr/local/lib/shipglows/pnpm/global/node_modules/vercel/dist/vc.js inspect interactive-target
103 50 4545 1000 ? 3600 1048576 MainThread node /usr/local/lib/shipglows/pnpm/global/node_modules/vercel/dist/vc.js inspect parent-alive
104 1 4646 2000 ? 3600 1048576 MainThread node /usr/local/lib/shipglows/pnpm/global/node_modules/vercel/dist/vc.js inspect another-user
EOF
            ;;
        *"pgid=,uid=,tty=,comm=,args="*)
            cat <<'EOF'
4242 1000 ? MainThread node /usr/local/lib/shipglows/pnpm/global/node_modules/vercel/dist/vc.js inspect redacted-target
4343 1000 ? codex codex
4444 1000 pts/1 MainThread node /usr/local/lib/shipglows/pnpm/global/node_modules/vercel/dist/vc.js inspect interactive-target
4646 2000 ? MainThread node /usr/local/lib/shipglows/pnpm/global/node_modules/vercel/dist/vc.js inspect another-user
EOF
            ;;
        *) : ;;
    esac
}

expect_equal "only the safe detached Vercel group is eligible for rescue" \
    "4242|1|1048576|3600|vercel|100" "$(orphaned_dev_tool_groups)"

orphaned_dev_tool_groups() { printf '%s\n' '4242|1|1048576|3600|vercel|100'; }
export SHIPGLOWS_EMERGENCY_RESCUE_DRY_RUN=1
expect_equal "emergency rescue revalidates then emits TERM only in dry-run" \
    "kill -TERM -4242" "$(stop_orphaned_dev_tool_group 4242 'vercel')"
if stop_orphaned_dev_tool_group 9999 'unknown' >/dev/null 2>&1; then
    printf 'FAIL: emergency rescue accepted a stale process group\n' >&2
    failures=$((failures + 1))
else
    printf 'PASS: emergency rescue rejects a stale process group\n'
fi
unset SHIPGLOWS_EMERGENCY_RESCUE_DRY_RUN

rm -rf "$SHIPGLOWS_SECRETS_DIR"

if [ "$failures" -ne 0 ]; then
    exit 1
fi

printf 'All memory monitoring tests passed.\n'
