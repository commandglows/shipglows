#!/bin/bash
# ShipGlowz Configuration File
# Centralized configuration for all scripts

# Canonical local state directory with legacy fallback kept for migration.
export SHIPGLOWZ_STATE_DIR="${SHIPGLOWZ_STATE_DIR:-$HOME/.shipglowz}"
export SHIPFLOW_LEGACY_STATE_DIR="${SHIPFLOW_LEGACY_STATE_DIR:-$HOME/.shipflow}"
export SHIPGLOWZ_ROOT="${SHIPGLOWZ_ROOT:-${SHIPFLOW_ROOT:-$HOME/shipglowz}}"
export SHIPFLOW_ROOT="$SHIPGLOWZ_ROOT"

# ============================================================================
# DIRECTORY CONFIGURATION
# ============================================================================

# Main projects directory where environments are created
# Defaults to $HOME (works for any user: /root for root, /home/user for others)
export SHIPGLOWZ_PROJECTS_DIR="${SHIPGLOWZ_PROJECTS_DIR:-${SHIPFLOW_PROJECTS_DIR:-$HOME}}"
export SHIPFLOW_PROJECTS_DIR="$SHIPGLOWZ_PROJECTS_DIR"

# Allowed safe directories for project paths
export SHIPFLOW_SAFE_DIRS=("/root" "/home" "/opt")

# Maximum depth for searching projects
export SHIPGLOWZ_MAX_SEARCH_DEPTH="${SHIPGLOWZ_MAX_SEARCH_DEPTH:-${SHIPFLOW_MAX_SEARCH_DEPTH:-4}}"
export SHIPFLOW_MAX_SEARCH_DEPTH="$SHIPGLOWZ_MAX_SEARCH_DEPTH"

# ============================================================================
# PORT CONFIGURATION
# ============================================================================

# Port range for PM2 applications
export SHIPGLOWZ_PORT_RANGE_START="${SHIPGLOWZ_PORT_RANGE_START:-${SHIPFLOW_PORT_RANGE_START:-3000}}"
export SHIPGLOWZ_PORT_RANGE_END="${SHIPGLOWZ_PORT_RANGE_END:-${SHIPFLOW_PORT_RANGE_END:-3100}}"
export SHIPGLOWZ_PORT_MAX_ATTEMPTS="${SHIPGLOWZ_PORT_MAX_ATTEMPTS:-${SHIPFLOW_PORT_MAX_ATTEMPTS:-100}}"
export SHIPFLOW_PORT_RANGE_START="$SHIPGLOWZ_PORT_RANGE_START"
export SHIPFLOW_PORT_RANGE_END="$SHIPGLOWZ_PORT_RANGE_END"
export SHIPFLOW_PORT_MAX_ATTEMPTS="$SHIPGLOWZ_PORT_MAX_ATTEMPTS"

# ============================================================================
# SSH TUNNEL CONFIGURATION
# ============================================================================

# SSH keep-alive settings
export SHIPGLOWZ_SSH_KEEPALIVE_INTERVAL="${SHIPGLOWZ_SSH_KEEPALIVE_INTERVAL:-${SHIPFLOW_SSH_KEEPALIVE_INTERVAL:-30}}"
export SHIPGLOWZ_SSH_KEEPALIVE_MAX="${SHIPGLOWZ_SSH_KEEPALIVE_MAX:-${SHIPFLOW_SSH_KEEPALIVE_MAX:-3}}"
export SHIPFLOW_SSH_KEEPALIVE_INTERVAL="$SHIPGLOWZ_SSH_KEEPALIVE_INTERVAL"
export SHIPFLOW_SSH_KEEPALIVE_MAX="$SHIPGLOWZ_SSH_KEEPALIVE_MAX"

# Default SSH configuration
export SHIPGLOWZ_SSH_REMOTE_USER="${SHIPGLOWZ_SSH_REMOTE_USER:-${SHIPFLOW_SSH_REMOTE_USER:-root}}"
export SHIPGLOWZ_SSH_REMOTE_HOST="${SHIPGLOWZ_SSH_REMOTE_HOST:-${SHIPFLOW_SSH_REMOTE_HOST:-}}"
export SHIPFLOW_SSH_REMOTE_USER="$SHIPGLOWZ_SSH_REMOTE_USER"
export SHIPFLOW_SSH_REMOTE_HOST="$SHIPGLOWZ_SSH_REMOTE_HOST"

# Server-side registry for interactive Flutter Web tmux sessions. Local tunnel
# tools read this file over SSH to expose non-PM2 Flutter preview ports.
export SHIPGLOWZ_FLUTTER_WEB_SESSIONS_FILE="${SHIPGLOWZ_FLUTTER_WEB_SESSIONS_FILE:-${SHIPFLOW_FLUTTER_WEB_SESSIONS_FILE:-$SHIPGLOWZ_STATE_DIR/flutter-web-sessions.tsv}}"
export SHIPFLOW_FLUTTER_WEB_SESSIONS_FILE="$SHIPGLOWZ_FLUTTER_WEB_SESSIONS_FILE"

# Append-only lifecycle signal consumed by optional local tunnel watchers.
export SHIPGLOWZ_TUNNEL_EVENT_FILE="${SHIPGLOWZ_TUNNEL_EVENT_FILE:-${SHIPFLOW_TUNNEL_EVENT_FILE:-$SHIPGLOWZ_STATE_DIR/tunnel-events.log}}"
export SHIPFLOW_TUNNEL_EVENT_FILE="$SHIPGLOWZ_TUNNEL_EVENT_FILE"

# ============================================================================
# LOGGING CONFIGURATION
# ============================================================================

# Enable/disable logging (true/false)
export SHIPGLOWZ_LOGGING_ENABLED="${SHIPGLOWZ_LOGGING_ENABLED:-${SHIPFLOW_LOGGING_ENABLED:-true}}"
export SHIPFLOW_LOGGING_ENABLED="$SHIPGLOWZ_LOGGING_ENABLED"

# Log file location (defaults to user's home directory for proper permissions)
export SHIPGLOWZ_LOG_DIR="${SHIPGLOWZ_LOG_DIR:-${SHIPFLOW_LOG_DIR:-$SHIPGLOWZ_STATE_DIR/logs}}"
export SHIPGLOWZ_LOG_FILE="${SHIPGLOWZ_LOG_FILE:-${SHIPFLOW_LOG_FILE:-$SHIPGLOWZ_LOG_DIR/shipglowz.log}}"
export SHIPFLOW_LOG_DIR="$SHIPGLOWZ_LOG_DIR"
export SHIPFLOW_LOG_FILE="$SHIPGLOWZ_LOG_FILE"

# Log retention (days)
export SHIPGLOWZ_LOG_RETENTION_DAYS="${SHIPGLOWZ_LOG_RETENTION_DAYS:-${SHIPFLOW_LOG_RETENTION_DAYS:-30}}"
export SHIPFLOW_LOG_RETENTION_DAYS="$SHIPGLOWZ_LOG_RETENTION_DAYS"

# Log level (DEBUG, INFO, WARNING, ERROR)
export SHIPGLOWZ_LOG_LEVEL="${SHIPGLOWZ_LOG_LEVEL:-${SHIPFLOW_LOG_LEVEL:-INFO}}"
export SHIPFLOW_LOG_LEVEL="$SHIPGLOWZ_LOG_LEVEL"

# ============================================================================
# GITHUB CONFIGURATION
# ============================================================================

# Number of repos to list from GitHub
export SHIPGLOWZ_GITHUB_REPO_LIMIT="${SHIPGLOWZ_GITHUB_REPO_LIMIT:-${SHIPFLOW_GITHUB_REPO_LIMIT:-500}}"
export SHIPFLOW_GITHUB_REPO_LIMIT="$SHIPGLOWZ_GITHUB_REPO_LIMIT"

# ============================================================================
# WEB INSPECTOR CONFIGURATION
# ============================================================================

# Screenshot upload expiration (seconds)
export SHIPGLOWZ_SCREENSHOT_EXPIRATION="${SHIPGLOWZ_SCREENSHOT_EXPIRATION:-${SHIPFLOW_SCREENSHOT_EXPIRATION:-600}}"
export SHIPFLOW_SCREENSHOT_EXPIRATION="$SHIPGLOWZ_SCREENSHOT_EXPIRATION"

# ImgBB API key (optional). Leave empty unless the operator explicitly opts in
# to client-side screenshot uploads.
export SHIPGLOWZ_IMGBB_API_KEY="${SHIPGLOWZ_IMGBB_API_KEY:-${SHIPFLOW_IMGBB_API_KEY:-}}"
export SHIPFLOW_IMGBB_API_KEY="$SHIPGLOWZ_IMGBB_API_KEY"

# ============================================================================
# PERFORMANCE CONFIGURATION
# ============================================================================

# Enable PM2 data caching (reduces subprocess overhead)
export SHIPGLOWZ_PM2_CACHE_ENABLED="${SHIPGLOWZ_PM2_CACHE_ENABLED:-${SHIPFLOW_PM2_CACHE_ENABLED:-true}}"
export SHIPFLOW_PM2_CACHE_ENABLED="$SHIPGLOWZ_PM2_CACHE_ENABLED"

# Cache TTL in seconds
export SHIPGLOWZ_PM2_CACHE_TTL="${SHIPGLOWZ_PM2_CACHE_TTL:-${SHIPFLOW_PM2_CACHE_TTL:-5}}"
export SHIPFLOW_PM2_CACHE_TTL="$SHIPGLOWZ_PM2_CACHE_TTL"

# Prefer jq over python for JSON parsing (faster)
export SHIPGLOWZ_PREFER_JQ="${SHIPGLOWZ_PREFER_JQ:-${SHIPFLOW_PREFER_JQ:-true}}"
export SHIPFLOW_PREFER_JQ="$SHIPGLOWZ_PREFER_JQ"

# Enable environment list caching (reduces filesystem scans)
export SHIPGLOWZ_ENV_LIST_CACHE_ENABLED="${SHIPGLOWZ_ENV_LIST_CACHE_ENABLED:-${SHIPFLOW_ENV_LIST_CACHE_ENABLED:-true}}"
export SHIPFLOW_ENV_LIST_CACHE_ENABLED="$SHIPGLOWZ_ENV_LIST_CACHE_ENABLED"

# Cache TTL in seconds
export SHIPGLOWZ_LIST_CACHE_TTL="${SHIPGLOWZ_LIST_CACHE_TTL:-${SHIPFLOW_LIST_CACHE_TTL:-5}}"
export SHIPFLOW_LIST_CACHE_TTL="$SHIPGLOWZ_LIST_CACHE_TTL"

# ============================================================================
# HEALTH MONITORING CONFIGURATION
# ============================================================================

# Enable crash loop detection in dashboard
export SHIPGLOWZ_HEALTH_CHECK_ENABLED="${SHIPGLOWZ_HEALTH_CHECK_ENABLED:-${SHIPFLOW_HEALTH_CHECK_ENABLED:-true}}"
export SHIPFLOW_HEALTH_CHECK_ENABLED="$SHIPGLOWZ_HEALTH_CHECK_ENABLED"

# Restart count above which an app is considered in a crash loop
export SHIPGLOWZ_CRASH_LOOP_THRESHOLD="${SHIPGLOWZ_CRASH_LOOP_THRESHOLD:-${SHIPFLOW_CRASH_LOOP_THRESHOLD:-10}}"
export SHIPFLOW_CRASH_LOOP_THRESHOLD="$SHIPGLOWZ_CRASH_LOOP_THRESHOLD"

# Uptime (seconds) below which a running app is considered unstable
export SHIPGLOWZ_UNSTABLE_UPTIME_SECS="${SHIPGLOWZ_UNSTABLE_UPTIME_SECS:-${SHIPFLOW_UNSTABLE_UPTIME_SECS:-30}}"
export SHIPFLOW_UNSTABLE_UPTIME_SECS="$SHIPGLOWZ_UNSTABLE_UPTIME_SECS"

# Known error patterns to auto-diagnose (pipe-separated)
# Each entry: "pattern|human-readable label|auto-fix hint"
export SHIPFLOW_KNOWN_ERROR_PATTERNS=(
    "Unable to acquire lock|Stale lock file (.next/dev/lock)|Remove .next/dev/lock and restart"
    "EADDRINUSE|Port already in use|Kill process on port or change PORT"
    "Cannot find module|Missing dependency|Run npm install / pnpm install"
    "not found$|Command not found (missing dependency or PATH)|Run npm install / pnpm install in project dir"
    "ENOSPC|Disk full or inotify limit|Free disk space or increase fs.inotify.max_user_watches"
    "content collection.*frontmatter\|zod.*validation\|ZodError|Invalid content file (empty or bad frontmatter)|Fix or rename file with _ prefix"
    "SyntaxError|Syntax error in source code|Check recent file changes"
    "ExperimentalWarning.*fetch|Node.js fetch warning (non-fatal)|Ignorable — upgrade Node.js if persistent"
)

# ============================================================================
# DISK SPACE CONFIGURATION
# ============================================================================

# Low disk warning threshold in GB (shows alert in menu header)
export SHIPGLOWZ_DISK_WARN_GB="${SHIPGLOWZ_DISK_WARN_GB:-${SHIPFLOW_DISK_WARN_GB:-5}}"
export SHIPFLOW_DISK_WARN_GB="$SHIPGLOWZ_DISK_WARN_GB"

# Menu status cache TTL in seconds (free space + update counts)
export SHIPGLOWZ_MENU_STATUS_CACHE_TTL="${SHIPGLOWZ_MENU_STATUS_CACHE_TTL:-${SHIPFLOW_MENU_STATUS_CACHE_TTL:-120}}"
export SHIPFLOW_MENU_STATUS_CACHE_TTL="$SHIPGLOWZ_MENU_STATUS_CACHE_TTL"

# ============================================================================
# MEMORY (RAM) MONITORING CONFIGURATION
# ============================================================================

# Low memory warning threshold in GB (shows alert in menu header)
export SHIPGLOWZ_MEM_WARN_GB="${SHIPGLOWZ_MEM_WARN_GB:-${SHIPFLOW_MEM_WARN_GB:-4}}"
export SHIPFLOW_MEM_WARN_GB="$SHIPGLOWZ_MEM_WARN_GB"

export SHIPGLOWZ_DISK_CRITICAL_GB="${SHIPGLOWZ_DISK_CRITICAL_GB:-${SHIPFLOW_DISK_CRITICAL_GB:-3}}"
export SHIPGLOWZ_DISK_HIGH_GB="${SHIPGLOWZ_DISK_HIGH_GB:-${SHIPFLOW_DISK_HIGH_GB:-5}}"
export SHIPGLOWZ_DISK_WARN_PCT="${SHIPGLOWZ_DISK_WARN_PCT:-${SHIPFLOW_DISK_WARN_PCT:-85}}"
export SHIPGLOWZ_DISK_HIGH_PCT="${SHIPGLOWZ_DISK_HIGH_PCT:-${SHIPFLOW_DISK_HIGH_PCT:-90}}"
export SHIPGLOWZ_DISK_CRITICAL_PCT="${SHIPGLOWZ_DISK_CRITICAL_PCT:-${SHIPFLOW_DISK_CRITICAL_PCT:-95}}"
export SHIPFLOW_DISK_CRITICAL_GB="$SHIPGLOWZ_DISK_CRITICAL_GB"
export SHIPFLOW_DISK_HIGH_GB="$SHIPGLOWZ_DISK_HIGH_GB"
export SHIPFLOW_DISK_WARN_PCT="$SHIPGLOWZ_DISK_WARN_PCT"
export SHIPFLOW_DISK_HIGH_PCT="$SHIPGLOWZ_DISK_HIGH_PCT"
export SHIPFLOW_DISK_CRITICAL_PCT="$SHIPGLOWZ_DISK_CRITICAL_PCT"

# Hours after which a process is flagged as "long-running" in System Monitor
export SHIPGLOWZ_PROCESS_LONG_RUNNING_HOURS="${SHIPGLOWZ_PROCESS_LONG_RUNNING_HOURS:-${SHIPFLOW_PROCESS_LONG_RUNNING_HOURS:-24}}"
export SHIPFLOW_PROCESS_LONG_RUNNING_HOURS="$SHIPGLOWZ_PROCESS_LONG_RUNNING_HOURS"

# Number of top processes to show in System Monitor
export SHIPGLOWZ_MONITOR_TOP_N="${SHIPGLOWZ_MONITOR_TOP_N:-${SHIPFLOW_MONITOR_TOP_N:-15}}"
export SHIPFLOW_MONITOR_TOP_N="$SHIPGLOWZ_MONITOR_TOP_N"

# ============================================================================
# TOOL REQUIREMENTS
# ============================================================================

# Critical tools (script fails if missing)
export SHIPGLOWZ_REQUIRED_TOOLS=("pm2" "node")
export SHIPFLOW_REQUIRED_TOOLS=("${SHIPGLOWZ_REQUIRED_TOOLS[@]}")

# Optional tools (warnings only)
# jq is preferred over python3 for JSON parsing (faster)
export SHIPGLOWZ_OPTIONAL_TOOLS=("flox" "git" "jq" "python3")
export SHIPFLOW_OPTIONAL_TOOLS=("${SHIPGLOWZ_OPTIONAL_TOOLS[@]}")

# ============================================================================
# FLOX CONFIGURATION
# ============================================================================

# Default Flox packages to install for each project type
export SHIPGLOWZ_FLOX_NODEJS_PACKAGES="${SHIPGLOWZ_FLOX_NODEJS_PACKAGES:-${SHIPFLOW_FLOX_NODEJS_PACKAGES:-nodejs}}"
export SHIPGLOWZ_FLOX_PYTHON_PACKAGES="${SHIPGLOWZ_FLOX_PYTHON_PACKAGES:-${SHIPFLOW_FLOX_PYTHON_PACKAGES:-python3}}"
export SHIPGLOWZ_FLOX_RUST_PACKAGES="${SHIPGLOWZ_FLOX_RUST_PACKAGES:-${SHIPFLOW_FLOX_RUST_PACKAGES:-rustc cargo}}"
export SHIPGLOWZ_FLOX_GO_PACKAGES="${SHIPGLOWZ_FLOX_GO_PACKAGES:-${SHIPFLOW_FLOX_GO_PACKAGES:-go}}"
export SHIPGLOWZ_FLOX_DART_PACKAGES="${SHIPGLOWZ_FLOX_DART_PACKAGES:-${SHIPFLOW_FLOX_DART_PACKAGES:-dart}}"
export SHIPGLOWZ_FLOX_FLUTTER_PACKAGES="${SHIPGLOWZ_FLOX_FLUTTER_PACKAGES:-${SHIPFLOW_FLOX_FLUTTER_PACKAGES:-flutter@3.41.5-sdk-links}}"
export SHIPFLOW_FLOX_NODEJS_PACKAGES="$SHIPGLOWZ_FLOX_NODEJS_PACKAGES"
export SHIPFLOW_FLOX_PYTHON_PACKAGES="$SHIPGLOWZ_FLOX_PYTHON_PACKAGES"
export SHIPFLOW_FLOX_RUST_PACKAGES="$SHIPGLOWZ_FLOX_RUST_PACKAGES"
export SHIPFLOW_FLOX_GO_PACKAGES="$SHIPGLOWZ_FLOX_GO_PACKAGES"
export SHIPFLOW_FLOX_DART_PACKAGES="$SHIPGLOWZ_FLOX_DART_PACKAGES"
export SHIPFLOW_FLOX_FLUTTER_PACKAGES="$SHIPGLOWZ_FLOX_FLUTTER_PACKAGES"

# ============================================================================
# VALIDATION CONFIGURATION
# ============================================================================

# Regex for valid environment names. ShipGlowz-created project/environment names
# are lowercase by convention to keep paths, PM2 apps, and aliases consistent.
export SHIPFLOW_ENV_NAME_REGEX="^[a-z0-9._-]+$"

# Regex for dangerous path characters
export SHIPFLOW_DANGEROUS_CHARS_REGEX='[\;\&\|\$\`]'

# ============================================================================
# CADDY CONFIGURATION
# ============================================================================

# ============================================================================
# SECRETS / CREDENTIAL CACHE CONFIGURATION
# ============================================================================

# Directory for storing cached credentials (chmod 700)
export SHIPGLOWZ_SECRETS_DIR="${SHIPGLOWZ_SECRETS_DIR:-${SHIPFLOW_SECRETS_DIR:-$SHIPGLOWZ_STATE_DIR}}"
export SHIPFLOW_SECRETS_DIR="$SHIPGLOWZ_SECRETS_DIR"

# Doppler integration mode:
# - auto: use Doppler when local/scoped project config is detected
# - always: always wrap app launch with doppler run if doppler is installed
# - never: never use Doppler automatically
export SHIPGLOWZ_DOPPLER_MODE="${SHIPGLOWZ_DOPPLER_MODE:-${SHIPFLOW_DOPPLER_MODE:-auto}}"
export SHIPFLOW_DOPPLER_MODE="$SHIPGLOWZ_DOPPLER_MODE"

# ============================================================================
# CADDY CONFIGURATION
# ============================================================================

# Caddyfile location
export SHIPFLOW_CADDYFILE="${SHIPFLOW_CADDYFILE:-/etc/caddy/Caddyfile}"

# ShipGlowz-managed user-mode Caddy runtime. This is the default runtime proxy
# path for development environments; the system Caddy service remains a legacy
# public HTTPS path only.
export SHIPGLOWZ_RUNTIME_DIR="${SHIPGLOWZ_RUNTIME_DIR:-${SHIPFLOW_RUNTIME_DIR:-$SHIPGLOWZ_SECRETS_DIR/runtime}}"
export SHIPGLOWZ_USER_CADDY_ENABLED="${SHIPGLOWZ_USER_CADDY_ENABLED:-${SHIPFLOW_USER_CADDY_ENABLED:-true}}"
export SHIPGLOWZ_USER_CADDY_BIND="${SHIPGLOWZ_USER_CADDY_BIND:-${SHIPFLOW_USER_CADDY_BIND:-127.0.0.1}}"
export SHIPGLOWZ_USER_CADDY_PORT="${SHIPGLOWZ_USER_CADDY_PORT:-${SHIPFLOW_USER_CADDY_PORT:-8080}}"
export SHIPGLOWZ_USER_CADDY_DIR="${SHIPGLOWZ_USER_CADDY_DIR:-${SHIPFLOW_USER_CADDY_DIR:-$SHIPGLOWZ_RUNTIME_DIR/caddy}}"
export SHIPGLOWZ_USER_CADDYFILE="${SHIPGLOWZ_USER_CADDYFILE:-${SHIPFLOW_USER_CADDYFILE:-$SHIPGLOWZ_USER_CADDY_DIR/Caddyfile}}"
export SHIPGLOWZ_USER_CADDY_PID_FILE="${SHIPGLOWZ_USER_CADDY_PID_FILE:-${SHIPFLOW_USER_CADDY_PID_FILE:-$SHIPGLOWZ_USER_CADDY_DIR/caddy.pid}}"
export SHIPGLOWZ_USER_CADDY_LOG_FILE="${SHIPGLOWZ_USER_CADDY_LOG_FILE:-${SHIPFLOW_USER_CADDY_LOG_FILE:-$SHIPGLOWZ_USER_CADDY_DIR/caddy.log}}"
export SHIPGLOWZ_USER_CADDY_STDOUT_FILE="${SHIPGLOWZ_USER_CADDY_STDOUT_FILE:-${SHIPFLOW_USER_CADDY_STDOUT_FILE:-$SHIPGLOWZ_USER_CADDY_DIR/stdout.log}}"
export SHIPGLOWZ_USER_CADDY_STORAGE_DIR="${SHIPGLOWZ_USER_CADDY_STORAGE_DIR:-${SHIPFLOW_USER_CADDY_STORAGE_DIR:-$SHIPGLOWZ_USER_CADDY_DIR/storage}}"
export SHIPFLOW_RUNTIME_DIR="$SHIPGLOWZ_RUNTIME_DIR"
export SHIPFLOW_USER_CADDY_ENABLED="$SHIPGLOWZ_USER_CADDY_ENABLED"
export SHIPFLOW_USER_CADDY_BIND="$SHIPGLOWZ_USER_CADDY_BIND"
export SHIPFLOW_USER_CADDY_PORT="$SHIPGLOWZ_USER_CADDY_PORT"
export SHIPFLOW_USER_CADDY_DIR="$SHIPGLOWZ_USER_CADDY_DIR"
export SHIPFLOW_USER_CADDYFILE="$SHIPGLOWZ_USER_CADDYFILE"
export SHIPFLOW_USER_CADDY_PID_FILE="$SHIPGLOWZ_USER_CADDY_PID_FILE"
export SHIPFLOW_USER_CADDY_LOG_FILE="$SHIPGLOWZ_USER_CADDY_LOG_FILE"
export SHIPFLOW_USER_CADDY_STDOUT_FILE="$SHIPGLOWZ_USER_CADDY_STDOUT_FILE"
export SHIPFLOW_USER_CADDY_STORAGE_DIR="$SHIPGLOWZ_USER_CADDY_STORAGE_DIR"

# ============================================================================
# SESSION IDENTITY CONFIGURATION
# ============================================================================

# Session directory for storing identity files
export SHIPGLOWZ_SESSION_DIR="${SHIPGLOWZ_SESSION_DIR:-${SHIPFLOW_SESSION_DIR:-$SHIPGLOWZ_SECRETS_DIR/session}}"
export SHIPFLOW_SESSION_DIR="$SHIPGLOWZ_SESSION_DIR"

# Enable/disable session identity display
export SHIPGLOWZ_SESSION_ENABLED="${SHIPGLOWZ_SESSION_ENABLED:-${SHIPFLOW_SESSION_ENABLED:-true}}"
export SHIPFLOW_SESSION_ENABLED="$SHIPGLOWZ_SESSION_ENABLED"

export SHIPGLOWZ_MCP_CLEANUP_DRY_RUN="${SHIPGLOWZ_MCP_CLEANUP_DRY_RUN:-${SHIPFLOW_MCP_CLEANUP_DRY_RUN:-0}}"
export SHIPGLOWZ_USER_CADDY_DRY_RUN="${SHIPGLOWZ_USER_CADDY_DRY_RUN:-${SHIPFLOW_USER_CADDY_DRY_RUN:-0}}"
export SHIPGLOWZ_AGGRESSIVE_CLEANUP_DRY_RUN="${SHIPGLOWZ_AGGRESSIVE_CLEANUP_DRY_RUN:-${SHIPFLOW_AGGRESSIVE_CLEANUP_DRY_RUN:-0}}"
export SHIPGLOWZ_GITHUB_AUTH_DRY_RUN="${SHIPGLOWZ_GITHUB_AUTH_DRY_RUN:-${SHIPFLOW_GITHUB_AUTH_DRY_RUN:-0}}"
export SHIPGLOWZ_RESTART_VERIFY_SECS="${SHIPGLOWZ_RESTART_VERIFY_SECS:-${SHIPFLOW_RESTART_VERIFY_SECS:-12}}"
export SHIPGLOWZ_REBOOT_DRY_RUN="${SHIPGLOWZ_REBOOT_DRY_RUN:-${SHIPFLOW_REBOOT_DRY_RUN:-0}}"
export SHIPGLOWZ_CODEX_DRY_RUN="${SHIPGLOWZ_CODEX_DRY_RUN:-${SHIPFLOW_CODEX_DRY_RUN:-0}}"
export SHIPGLOWZ_CLERK_LOGIN_TIMEOUT_SECONDS="${SHIPGLOWZ_CLERK_LOGIN_TIMEOUT_SECONDS:-${SHIPFLOW_CLERK_LOGIN_TIMEOUT_SECONDS:-600}}"
export SHIPGLOWZ_BLACKSMITH_LOGIN_TIMEOUT_SECONDS="${SHIPGLOWZ_BLACKSMITH_LOGIN_TIMEOUT_SECONDS:-${SHIPFLOW_BLACKSMITH_LOGIN_TIMEOUT_SECONDS:-600}}"
export SHIPGLOWZ_MCP_LOGIN_TIMEOUT_SECONDS="${SHIPGLOWZ_MCP_LOGIN_TIMEOUT_SECONDS:-${SHIPFLOW_MCP_LOGIN_TIMEOUT_SECONDS:-600}}"
export SHIPGLOWZ_TURSO_LOGIN_TIMEOUT_SECONDS="${SHIPGLOWZ_TURSO_LOGIN_TIMEOUT_SECONDS:-${SHIPFLOW_TURSO_LOGIN_TIMEOUT_SECONDS:-600}}"
export SHIPGLOWZ_TURSO_CONFIG_DIR="${SHIPGLOWZ_TURSO_CONFIG_DIR:-${SHIPFLOW_TURSO_CONFIG_DIR:-$HOME/.config/turso}}"
export SHIPGLOWZ_TURSO_REMOTE_PROJECT_DIR="${SHIPGLOWZ_TURSO_REMOTE_PROJECT_DIR:-${SHIPFLOW_TURSO_REMOTE_PROJECT_DIR:-}}"
export SHIPGLOWZ_FZF_HEIGHT="${SHIPGLOWZ_FZF_HEIGHT:-${SHIPFLOW_FZF_HEIGHT:-70%}}"
export SHIPFLOW_MCP_CLEANUP_DRY_RUN="$SHIPGLOWZ_MCP_CLEANUP_DRY_RUN"
export SHIPFLOW_USER_CADDY_DRY_RUN="$SHIPGLOWZ_USER_CADDY_DRY_RUN"
export SHIPFLOW_AGGRESSIVE_CLEANUP_DRY_RUN="$SHIPGLOWZ_AGGRESSIVE_CLEANUP_DRY_RUN"
export SHIPFLOW_GITHUB_AUTH_DRY_RUN="$SHIPGLOWZ_GITHUB_AUTH_DRY_RUN"
export SHIPFLOW_RESTART_VERIFY_SECS="$SHIPGLOWZ_RESTART_VERIFY_SECS"
export SHIPFLOW_REBOOT_DRY_RUN="$SHIPGLOWZ_REBOOT_DRY_RUN"
export SHIPFLOW_CODEX_DRY_RUN="$SHIPGLOWZ_CODEX_DRY_RUN"
export SHIPFLOW_CLERK_LOGIN_TIMEOUT_SECONDS="$SHIPGLOWZ_CLERK_LOGIN_TIMEOUT_SECONDS"
export SHIPFLOW_BLACKSMITH_LOGIN_TIMEOUT_SECONDS="$SHIPGLOWZ_BLACKSMITH_LOGIN_TIMEOUT_SECONDS"
export SHIPFLOW_MCP_LOGIN_TIMEOUT_SECONDS="$SHIPGLOWZ_MCP_LOGIN_TIMEOUT_SECONDS"
export SHIPFLOW_TURSO_LOGIN_TIMEOUT_SECONDS="$SHIPGLOWZ_TURSO_LOGIN_TIMEOUT_SECONDS"
export SHIPFLOW_TURSO_CONFIG_DIR="$SHIPGLOWZ_TURSO_CONFIG_DIR"
export SHIPFLOW_TURSO_REMOTE_PROJECT_DIR="$SHIPGLOWZ_TURSO_REMOTE_PROJECT_DIR"
export SHIPFLOW_FZF_HEIGHT="$SHIPGLOWZ_FZF_HEIGHT"

# ============================================================================
# ERROR HANDLING CONFIGURATION
# ============================================================================

# Enable strict error handling (set -euo pipefail equivalent)
export SHIPFLOW_STRICT_MODE="${SHIPFLOW_STRICT_MODE:-false}"

# Enable error traps (cleanup on failure)
export SHIPFLOW_ERROR_TRAPS="${SHIPFLOW_ERROR_TRAPS:-true}"

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

# Print configuration (for debugging)
shipflow_print_config() {
    echo "ShipGlowz Configuration:"
    echo "  Projects Dir: $SHIPGLOWZ_PROJECTS_DIR"
    echo "  Port Range: $SHIPGLOWZ_PORT_RANGE_START-$SHIPGLOWZ_PORT_RANGE_END"
    echo "  Logging: $SHIPGLOWZ_LOGGING_ENABLED"
    echo "  Log File: $SHIPGLOWZ_LOG_FILE"
    echo "  Log Level: $SHIPGLOWZ_LOG_LEVEL"
    echo "  PM2 Cache: $SHIPGLOWZ_PM2_CACHE_ENABLED"
}

# Validate configuration
shipflow_validate_config() {
    local errors=0

    if [ ! -d "$SHIPGLOWZ_PROJECTS_DIR" ]; then
        echo "ERROR: Projects directory does not exist: $SHIPGLOWZ_PROJECTS_DIR"
        ((errors++))
    fi

    if [ "$SHIPGLOWZ_PORT_RANGE_START" -ge "$SHIPGLOWZ_PORT_RANGE_END" ]; then
        echo "ERROR: Invalid port range"
        ((errors++))
    fi

    if [ "$SHIPGLOWZ_LOGGING_ENABLED" = "true" ]; then
        mkdir -p "$SHIPGLOWZ_LOG_DIR" 2>/dev/null || {
            echo "WARNING: Cannot create log directory: $SHIPGLOWZ_LOG_DIR"
        }
    fi

    return $errors
}
