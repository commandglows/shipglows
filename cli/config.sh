#!/bin/bash
# ShipGlows Configuration File
# Centralized configuration for all scripts

# Canonical local state directory with legacy fallback kept for migration.
export SHIPGLOWS_STATE_DIR="${SHIPGLOWS_STATE_DIR:-$HOME/.shipglows}"
export SHIPGLOWS_LEGACY_STATE_DIR="${SHIPGLOWS_LEGACY_STATE_DIR:-$HOME/.shipglows}"
export SHIPGLOWS_ROOT="${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}"
export SHIPGLOWS_ROOT="$SHIPGLOWS_ROOT"

# Resolve private persistence once for every CLI consumer. The helper reads an
# allowlisted local config file; it never sources it as shell code.
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/private-data.sh"
shipglows_private_data_init || return 1 2>/dev/null || exit 1

# ============================================================================
# DIRECTORY CONFIGURATION
# ============================================================================

# Main projects directory where environments are created
# Defaults to $HOME (works for any user: /root for root, /home/user for others)
export SHIPGLOWS_PROJECTS_DIR="${SHIPGLOWS_PROJECTS_DIR:-${SHIPGLOWS_PROJECTS_DIR:-$HOME}}"
export SHIPGLOWS_PROJECTS_DIR="$SHIPGLOWS_PROJECTS_DIR"

# Allowed safe directories for project paths
export SHIPGLOWS_SAFE_DIRS=("/root" "/home" "/opt")

# Maximum depth for searching projects
export SHIPGLOWS_MAX_SEARCH_DEPTH="${SHIPGLOWS_MAX_SEARCH_DEPTH:-${SHIPGLOWS_MAX_SEARCH_DEPTH:-4}}"
export SHIPGLOWS_MAX_SEARCH_DEPTH="$SHIPGLOWS_MAX_SEARCH_DEPTH"

# ============================================================================
# PORT CONFIGURATION
# ============================================================================

# Port range for PM2 applications
export SHIPGLOWS_PORT_RANGE_START="${SHIPGLOWS_PORT_RANGE_START:-${SHIPGLOWS_PORT_RANGE_START:-3000}}"
export SHIPGLOWS_PORT_RANGE_END="${SHIPGLOWS_PORT_RANGE_END:-${SHIPGLOWS_PORT_RANGE_END:-3100}}"
export SHIPGLOWS_PORT_MAX_ATTEMPTS="${SHIPGLOWS_PORT_MAX_ATTEMPTS:-${SHIPGLOWS_PORT_MAX_ATTEMPTS:-100}}"
export SHIPGLOWS_PORT_RANGE_START="$SHIPGLOWS_PORT_RANGE_START"
export SHIPGLOWS_PORT_RANGE_END="$SHIPGLOWS_PORT_RANGE_END"
export SHIPGLOWS_PORT_MAX_ATTEMPTS="$SHIPGLOWS_PORT_MAX_ATTEMPTS"

# Optional one-shot port pin for env_start.  It overrides the port saved in an
# existing PM2 ecosystem file and fails on collision instead of reallocating.
export SHIPGLOWS_ENV_PORT="${SHIPGLOWS_ENV_PORT:-${SHIPGLOWS_ENV_PORT:-}}"
export SHIPGLOWS_ENV_PORT="$SHIPGLOWS_ENV_PORT"

# ============================================================================
# SSH TUNNEL CONFIGURATION
# ============================================================================

# SSH keep-alive settings
export SHIPGLOWS_SSH_KEEPALIVE_INTERVAL="${SHIPGLOWS_SSH_KEEPALIVE_INTERVAL:-${SHIPGLOWS_SSH_KEEPALIVE_INTERVAL:-30}}"
export SHIPGLOWS_SSH_KEEPALIVE_MAX="${SHIPGLOWS_SSH_KEEPALIVE_MAX:-${SHIPGLOWS_SSH_KEEPALIVE_MAX:-3}}"
export SHIPGLOWS_SSH_KEEPALIVE_INTERVAL="$SHIPGLOWS_SSH_KEEPALIVE_INTERVAL"
export SHIPGLOWS_SSH_KEEPALIVE_MAX="$SHIPGLOWS_SSH_KEEPALIVE_MAX"

# Default SSH configuration
export SHIPGLOWS_SSH_REMOTE_USER="${SHIPGLOWS_SSH_REMOTE_USER:-${SHIPGLOWS_SSH_REMOTE_USER:-root}}"
export SHIPGLOWS_SSH_REMOTE_HOST="${SHIPGLOWS_SSH_REMOTE_HOST:-${SHIPGLOWS_SSH_REMOTE_HOST:-}}"
export SHIPGLOWS_SSH_REMOTE_USER="$SHIPGLOWS_SSH_REMOTE_USER"
export SHIPGLOWS_SSH_REMOTE_HOST="$SHIPGLOWS_SSH_REMOTE_HOST"

# Server-side registry for interactive Flutter Web tmux sessions. Local tunnel
# tools read this file over SSH to expose non-PM2 Flutter preview ports.
export SHIPGLOWS_FLUTTER_WEB_SESSIONS_FILE="${SHIPGLOWS_FLUTTER_WEB_SESSIONS_FILE:-${SHIPGLOWS_FLUTTER_WEB_SESSIONS_FILE:-$SHIPGLOWS_STATE_DIR/flutter-web-sessions.tsv}}"
export SHIPGLOWS_FLUTTER_WEB_SESSIONS_FILE="$SHIPGLOWS_FLUTTER_WEB_SESSIONS_FILE"

# Append-only lifecycle signal consumed by optional local tunnel watchers.
export SHIPGLOWS_TUNNEL_EVENT_FILE="${SHIPGLOWS_TUNNEL_EVENT_FILE:-${SHIPGLOWS_TUNNEL_EVENT_FILE:-$SHIPGLOWS_STATE_DIR/tunnel-events.log}}"
export SHIPGLOWS_TUNNEL_EVENT_FILE="$SHIPGLOWS_TUNNEL_EVENT_FILE"

# Private, machine-readable project catalog consumed by the cloud runner and
# the user-mode preview proxy. It is never a public API payload.
export SHIPGLOWS_CLI_PROJECT_CATALOG_FILE="${SHIPGLOWS_CLI_PROJECT_CATALOG_FILE:-$SHIPGLOWS_STATE_DIR/cli-project-catalog.v1.json}"
export SHIPGLOWS_CLI_PROJECT_CATALOG_MAX_PROJECTS="${SHIPGLOWS_CLI_PROJECT_CATALOG_MAX_PROJECTS:-256}"
export SHIPGLOWS_CLI_PROJECT_CATALOG_MAX_BYTES="${SHIPGLOWS_CLI_PROJECT_CATALOG_MAX_BYTES:-1048576}"
export SHIPGLOWS_CLI_CAPABILITIES_FILE="${SHIPGLOWS_CLI_CAPABILITIES_FILE:-$SHIPGLOWS_STATE_DIR/cli-capabilities.v1.json}"
export SHIPGLOWS_CLI_CAPABILITIES_MAX_BYTES="${SHIPGLOWS_CLI_CAPABILITIES_MAX_BYTES:-65536}"
export SHIPGLOWS_PREVIEW_DOMAIN="${SHIPGLOWS_PREVIEW_DOMAIN:-preview.shipglows.com}"
export SHIPGLOWS_CLOUD_MODE="${SHIPGLOWS_CLOUD_MODE:-false}"
export SHIPGLOWS_CLI_PROJECT_CATALOG_FILE SHIPGLOWS_CLI_PROJECT_CATALOG_MAX_PROJECTS
export SHIPGLOWS_CLI_PROJECT_CATALOG_MAX_BYTES SHIPGLOWS_CLI_CAPABILITIES_FILE
export SHIPGLOWS_CLI_CAPABILITIES_MAX_BYTES SHIPGLOWS_PREVIEW_DOMAIN SHIPGLOWS_CLOUD_MODE

# ============================================================================
# LOGGING CONFIGURATION
# ============================================================================

# Enable/disable logging (true/false)
export SHIPGLOWS_LOGGING_ENABLED="${SHIPGLOWS_LOGGING_ENABLED:-${SHIPGLOWS_LOGGING_ENABLED:-true}}"
export SHIPGLOWS_LOGGING_ENABLED="$SHIPGLOWS_LOGGING_ENABLED"

# Log file location (defaults to user's home directory for proper permissions)
export SHIPGLOWS_LOG_DIR="${SHIPGLOWS_LOG_DIR:-${SHIPGLOWS_LOG_DIR:-$SHIPGLOWS_STATE_DIR/logs}}"
export SHIPGLOWS_LOG_FILE="${SHIPGLOWS_LOG_FILE:-${SHIPGLOWS_LOG_FILE:-$SHIPGLOWS_LOG_DIR/shipglows.log}}"
export SHIPGLOWS_LOG_DIR="$SHIPGLOWS_LOG_DIR"
export SHIPGLOWS_LOG_FILE="$SHIPGLOWS_LOG_FILE"

# Log retention (days)
export SHIPGLOWS_LOG_RETENTION_DAYS="${SHIPGLOWS_LOG_RETENTION_DAYS:-${SHIPGLOWS_LOG_RETENTION_DAYS:-30}}"
export SHIPGLOWS_LOG_RETENTION_DAYS="$SHIPGLOWS_LOG_RETENTION_DAYS"

# Log level (DEBUG, INFO, WARNING, ERROR)
export SHIPGLOWS_LOG_LEVEL="${SHIPGLOWS_LOG_LEVEL:-${SHIPGLOWS_LOG_LEVEL:-INFO}}"
export SHIPGLOWS_LOG_LEVEL="$SHIPGLOWS_LOG_LEVEL"

# ============================================================================
# GITHUB CONFIGURATION
# ============================================================================

# Number of repos to list from GitHub
export SHIPGLOWS_GITHUB_REPO_LIMIT="${SHIPGLOWS_GITHUB_REPO_LIMIT:-${SHIPGLOWS_GITHUB_REPO_LIMIT:-500}}"
export SHIPGLOWS_GITHUB_REPO_LIMIT="$SHIPGLOWS_GITHUB_REPO_LIMIT"

# ============================================================================
# WEB INSPECTOR CONFIGURATION
# ============================================================================

# Screenshot upload expiration (seconds)
export SHIPGLOWS_SCREENSHOT_EXPIRATION="${SHIPGLOWS_SCREENSHOT_EXPIRATION:-${SHIPGLOWS_SCREENSHOT_EXPIRATION:-600}}"
export SHIPGLOWS_SCREENSHOT_EXPIRATION="$SHIPGLOWS_SCREENSHOT_EXPIRATION"

# ImgBB API key (optional). Leave empty unless the operator explicitly opts in
# to client-side screenshot uploads.
export SHIPGLOWS_IMGBB_API_KEY="${SHIPGLOWS_IMGBB_API_KEY:-${SHIPGLOWS_IMGBB_API_KEY:-}}"
export SHIPGLOWS_IMGBB_API_KEY="$SHIPGLOWS_IMGBB_API_KEY"

# ============================================================================
# PERFORMANCE CONFIGURATION
# ============================================================================

# Enable PM2 data caching (reduces subprocess overhead)
export SHIPGLOWS_PM2_CACHE_ENABLED="${SHIPGLOWS_PM2_CACHE_ENABLED:-${SHIPGLOWS_PM2_CACHE_ENABLED:-true}}"
export SHIPGLOWS_PM2_CACHE_ENABLED="$SHIPGLOWS_PM2_CACHE_ENABLED"

# Cache TTL in seconds
export SHIPGLOWS_PM2_CACHE_TTL="${SHIPGLOWS_PM2_CACHE_TTL:-${SHIPGLOWS_PM2_CACHE_TTL:-5}}"
export SHIPGLOWS_PM2_CACHE_TTL="$SHIPGLOWS_PM2_CACHE_TTL"

# Prefer jq over python for JSON parsing (faster)
export SHIPGLOWS_PREFER_JQ="${SHIPGLOWS_PREFER_JQ:-${SHIPGLOWS_PREFER_JQ:-true}}"
export SHIPGLOWS_PREFER_JQ="$SHIPGLOWS_PREFER_JQ"

# Enable environment list caching (reduces filesystem scans)
export SHIPGLOWS_ENV_LIST_CACHE_ENABLED="${SHIPGLOWS_ENV_LIST_CACHE_ENABLED:-${SHIPGLOWS_ENV_LIST_CACHE_ENABLED:-true}}"
export SHIPGLOWS_ENV_LIST_CACHE_ENABLED="$SHIPGLOWS_ENV_LIST_CACHE_ENABLED"

# Cache TTL in seconds
export SHIPGLOWS_LIST_CACHE_TTL="${SHIPGLOWS_LIST_CACHE_TTL:-${SHIPGLOWS_LIST_CACHE_TTL:-5}}"
export SHIPGLOWS_LIST_CACHE_TTL="$SHIPGLOWS_LIST_CACHE_TTL"

# ============================================================================
# HEALTH MONITORING CONFIGURATION
# ============================================================================

# Enable crash loop detection in dashboard
export SHIPGLOWS_HEALTH_CHECK_ENABLED="${SHIPGLOWS_HEALTH_CHECK_ENABLED:-${SHIPGLOWS_HEALTH_CHECK_ENABLED:-true}}"
export SHIPGLOWS_HEALTH_CHECK_ENABLED="$SHIPGLOWS_HEALTH_CHECK_ENABLED"

# Restart count above which an app is considered in a crash loop
export SHIPGLOWS_CRASH_LOOP_THRESHOLD="${SHIPGLOWS_CRASH_LOOP_THRESHOLD:-${SHIPGLOWS_CRASH_LOOP_THRESHOLD:-10}}"
export SHIPGLOWS_CRASH_LOOP_THRESHOLD="$SHIPGLOWS_CRASH_LOOP_THRESHOLD"

# Uptime (seconds) below which a running app is considered unstable
export SHIPGLOWS_UNSTABLE_UPTIME_SECS="${SHIPGLOWS_UNSTABLE_UPTIME_SECS:-${SHIPGLOWS_UNSTABLE_UPTIME_SECS:-30}}"
export SHIPGLOWS_UNSTABLE_UPTIME_SECS="$SHIPGLOWS_UNSTABLE_UPTIME_SECS"

# Known error patterns to auto-diagnose (pipe-separated)
# Each entry: "pattern|human-readable label|auto-fix hint"
export SHIPGLOWS_KNOWN_ERROR_PATTERNS=(
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
export SHIPGLOWS_DISK_WARN_GB="${SHIPGLOWS_DISK_WARN_GB:-${SHIPGLOWS_DISK_WARN_GB:-5}}"
export SHIPGLOWS_DISK_WARN_GB="$SHIPGLOWS_DISK_WARN_GB"

# Menu status cache TTL in seconds (free space + update counts)
export SHIPGLOWS_MENU_STATUS_CACHE_TTL="${SHIPGLOWS_MENU_STATUS_CACHE_TTL:-${SHIPGLOWS_MENU_STATUS_CACHE_TTL:-120}}"
export SHIPGLOWS_MENU_STATUS_CACHE_TTL="$SHIPGLOWS_MENU_STATUS_CACHE_TTL"

# ============================================================================
# MEMORY (RAM) MONITORING CONFIGURATION
# ============================================================================

# Available-memory thresholds. Percentages scale across VM sizes; the legacy
# absolute GiB threshold remains available only when explicitly configured.
export SHIPGLOWS_MEM_WARN_PCT="${SHIPGLOWS_MEM_WARN_PCT:-20}"
export SHIPGLOWS_MEM_CRITICAL_PCT="${SHIPGLOWS_MEM_CRITICAL_PCT:-10}"
export SHIPGLOWS_MEM_WARN_GB="${SHIPGLOWS_MEM_WARN_GB:-}"
export SHIPGLOWS_MEM_WARN_PCT SHIPGLOWS_MEM_CRITICAL_PCT SHIPGLOWS_MEM_WARN_GB

export SHIPGLOWS_DISK_CRITICAL_GB="${SHIPGLOWS_DISK_CRITICAL_GB:-${SHIPGLOWS_DISK_CRITICAL_GB:-3}}"
export SHIPGLOWS_DISK_HIGH_GB="${SHIPGLOWS_DISK_HIGH_GB:-${SHIPGLOWS_DISK_HIGH_GB:-5}}"
export SHIPGLOWS_DISK_WARN_PCT="${SHIPGLOWS_DISK_WARN_PCT:-${SHIPGLOWS_DISK_WARN_PCT:-85}}"
export SHIPGLOWS_DISK_HIGH_PCT="${SHIPGLOWS_DISK_HIGH_PCT:-${SHIPGLOWS_DISK_HIGH_PCT:-90}}"
export SHIPGLOWS_DISK_CRITICAL_PCT="${SHIPGLOWS_DISK_CRITICAL_PCT:-${SHIPGLOWS_DISK_CRITICAL_PCT:-95}}"
export SHIPGLOWS_DISK_CRITICAL_GB="$SHIPGLOWS_DISK_CRITICAL_GB"
export SHIPGLOWS_DISK_HIGH_GB="$SHIPGLOWS_DISK_HIGH_GB"
export SHIPGLOWS_DISK_WARN_PCT="$SHIPGLOWS_DISK_WARN_PCT"
export SHIPGLOWS_DISK_HIGH_PCT="$SHIPGLOWS_DISK_HIGH_PCT"
export SHIPGLOWS_DISK_CRITICAL_PCT="$SHIPGLOWS_DISK_CRITICAL_PCT"

# Hours after which a process is flagged as "long-running" in System Monitor
export SHIPGLOWS_PROCESS_LONG_RUNNING_HOURS="${SHIPGLOWS_PROCESS_LONG_RUNNING_HOURS:-${SHIPGLOWS_PROCESS_LONG_RUNNING_HOURS:-24}}"
export SHIPGLOWS_PROCESS_LONG_RUNNING_HOURS="$SHIPGLOWS_PROCESS_LONG_RUNNING_HOURS"

# Number of top processes to show in System Monitor
export SHIPGLOWS_MONITOR_TOP_N="${SHIPGLOWS_MONITOR_TOP_N:-${SHIPGLOWS_MONITOR_TOP_N:-15}}"
export SHIPGLOWS_MONITOR_TOP_N="$SHIPGLOWS_MONITOR_TOP_N"

# ============================================================================
# TOOL REQUIREMENTS
# ============================================================================

# Critical tools (script fails if missing)
export SHIPGLOWS_REQUIRED_TOOLS=("pm2" "node")
export SHIPGLOWS_REQUIRED_TOOLS=("${SHIPGLOWS_REQUIRED_TOOLS[@]}")

# Optional tools (warnings only)
# jq is preferred over python3 for JSON parsing (faster)
export SHIPGLOWS_OPTIONAL_TOOLS=("flox" "git" "jq" "python3")
export SHIPGLOWS_OPTIONAL_TOOLS=("${SHIPGLOWS_OPTIONAL_TOOLS[@]}")

# ============================================================================
# FLOX CONFIGURATION
# ============================================================================

# Default Flox packages to install for each project type
export SHIPGLOWS_FLOX_NODEJS_PACKAGES="${SHIPGLOWS_FLOX_NODEJS_PACKAGES:-${SHIPGLOWS_FLOX_NODEJS_PACKAGES:-nodejs}}"
export SHIPGLOWS_FLOX_PYTHON_PACKAGES="${SHIPGLOWS_FLOX_PYTHON_PACKAGES:-${SHIPGLOWS_FLOX_PYTHON_PACKAGES:-python3}}"
export SHIPGLOWS_FLOX_RUST_PACKAGES="${SHIPGLOWS_FLOX_RUST_PACKAGES:-${SHIPGLOWS_FLOX_RUST_PACKAGES:-rustc cargo}}"
export SHIPGLOWS_FLOX_GO_PACKAGES="${SHIPGLOWS_FLOX_GO_PACKAGES:-${SHIPGLOWS_FLOX_GO_PACKAGES:-go}}"
export SHIPGLOWS_FLOX_DART_PACKAGES="${SHIPGLOWS_FLOX_DART_PACKAGES:-${SHIPGLOWS_FLOX_DART_PACKAGES:-dart}}"
export SHIPGLOWS_FLOX_FLUTTER_PACKAGES="${SHIPGLOWS_FLOX_FLUTTER_PACKAGES:-${SHIPGLOWS_FLOX_FLUTTER_PACKAGES:-flutter@3.41.5-sdk-links}}"
export SHIPGLOWS_FLOX_NODEJS_PACKAGES="$SHIPGLOWS_FLOX_NODEJS_PACKAGES"
export SHIPGLOWS_FLOX_PYTHON_PACKAGES="$SHIPGLOWS_FLOX_PYTHON_PACKAGES"
export SHIPGLOWS_FLOX_RUST_PACKAGES="$SHIPGLOWS_FLOX_RUST_PACKAGES"
export SHIPGLOWS_FLOX_GO_PACKAGES="$SHIPGLOWS_FLOX_GO_PACKAGES"
export SHIPGLOWS_FLOX_DART_PACKAGES="$SHIPGLOWS_FLOX_DART_PACKAGES"
export SHIPGLOWS_FLOX_FLUTTER_PACKAGES="$SHIPGLOWS_FLOX_FLUTTER_PACKAGES"

# ============================================================================
# VALIDATION CONFIGURATION
# ============================================================================

# Regex for valid environment names. ShipGlows-created project/environment names
# are lowercase by convention to keep paths, PM2 apps, and aliases consistent.
export SHIPGLOWS_ENV_NAME_REGEX="^[a-z0-9._-]+$"

# Regex for dangerous path characters
export SHIPGLOWS_DANGEROUS_CHARS_REGEX='[\;\&\|\$\`]'

# ============================================================================
# CADDY CONFIGURATION
# ============================================================================

# ============================================================================
# SECRETS / CREDENTIAL CACHE CONFIGURATION
# ============================================================================

# Directory for storing cached credentials (chmod 700)
export SHIPGLOWS_SECRETS_DIR="${SHIPGLOWS_SECRETS_DIR:-${SHIPGLOWS_SECRETS_DIR:-$SHIPGLOWS_STATE_DIR}}"
export SHIPGLOWS_SECRETS_DIR="$SHIPGLOWS_SECRETS_DIR"

# Doppler integration mode:
# - auto: use Doppler when local/scoped project config is detected
# - always: always wrap app launch with doppler run if doppler is installed
# - never: never use Doppler automatically
export SHIPGLOWS_DOPPLER_MODE="${SHIPGLOWS_DOPPLER_MODE:-${SHIPGLOWS_DOPPLER_MODE:-auto}}"
export SHIPGLOWS_DOPPLER_MODE="$SHIPGLOWS_DOPPLER_MODE"

# ============================================================================
# CADDY CONFIGURATION
# ============================================================================

# Caddyfile location
export SHIPGLOWS_CADDYFILE="${SHIPGLOWS_CADDYFILE:-/etc/caddy/Caddyfile}"

# ShipGlows-managed user-mode Caddy runtime. This is the default runtime proxy
# path for development environments; the system Caddy service remains a legacy
# public HTTPS path only.
export SHIPGLOWS_RUNTIME_DIR="${SHIPGLOWS_RUNTIME_DIR:-${SHIPGLOWS_RUNTIME_DIR:-$SHIPGLOWS_SECRETS_DIR/state}}"
export SHIPGLOWS_USER_CADDY_ENABLED="${SHIPGLOWS_USER_CADDY_ENABLED:-${SHIPGLOWS_USER_CADDY_ENABLED:-true}}"
export SHIPGLOWS_USER_CADDY_BIND="${SHIPGLOWS_USER_CADDY_BIND:-${SHIPGLOWS_USER_CADDY_BIND:-127.0.0.1}}"
export SHIPGLOWS_USER_CADDY_PORT="${SHIPGLOWS_USER_CADDY_PORT:-${SHIPGLOWS_USER_CADDY_PORT:-8080}}"
export SHIPGLOWS_USER_CADDY_DIR="${SHIPGLOWS_USER_CADDY_DIR:-${SHIPGLOWS_USER_CADDY_DIR:-$SHIPGLOWS_RUNTIME_DIR/caddy}}"
export SHIPGLOWS_USER_CADDYFILE="${SHIPGLOWS_USER_CADDYFILE:-${SHIPGLOWS_USER_CADDYFILE:-$SHIPGLOWS_USER_CADDY_DIR/Caddyfile}}"
export SHIPGLOWS_USER_CADDY_PID_FILE="${SHIPGLOWS_USER_CADDY_PID_FILE:-${SHIPGLOWS_USER_CADDY_PID_FILE:-$SHIPGLOWS_USER_CADDY_DIR/caddy.pid}}"
export SHIPGLOWS_USER_CADDY_LOG_FILE="${SHIPGLOWS_USER_CADDY_LOG_FILE:-${SHIPGLOWS_USER_CADDY_LOG_FILE:-$SHIPGLOWS_USER_CADDY_DIR/caddy.log}}"
export SHIPGLOWS_USER_CADDY_STDOUT_FILE="${SHIPGLOWS_USER_CADDY_STDOUT_FILE:-${SHIPGLOWS_USER_CADDY_STDOUT_FILE:-$SHIPGLOWS_USER_CADDY_DIR/stdout.log}}"
export SHIPGLOWS_USER_CADDY_STORAGE_DIR="${SHIPGLOWS_USER_CADDY_STORAGE_DIR:-${SHIPGLOWS_USER_CADDY_STORAGE_DIR:-$SHIPGLOWS_USER_CADDY_DIR/storage}}"
export SHIPGLOWS_RUNTIME_DIR="$SHIPGLOWS_RUNTIME_DIR"
export SHIPGLOWS_USER_CADDY_ENABLED="$SHIPGLOWS_USER_CADDY_ENABLED"
export SHIPGLOWS_USER_CADDY_BIND="$SHIPGLOWS_USER_CADDY_BIND"
export SHIPGLOWS_USER_CADDY_PORT="$SHIPGLOWS_USER_CADDY_PORT"
export SHIPGLOWS_USER_CADDY_DIR="$SHIPGLOWS_USER_CADDY_DIR"
export SHIPGLOWS_USER_CADDYFILE="$SHIPGLOWS_USER_CADDYFILE"
export SHIPGLOWS_USER_CADDY_PID_FILE="$SHIPGLOWS_USER_CADDY_PID_FILE"
export SHIPGLOWS_USER_CADDY_LOG_FILE="$SHIPGLOWS_USER_CADDY_LOG_FILE"
export SHIPGLOWS_USER_CADDY_STDOUT_FILE="$SHIPGLOWS_USER_CADDY_STDOUT_FILE"
export SHIPGLOWS_USER_CADDY_STORAGE_DIR="$SHIPGLOWS_USER_CADDY_STORAGE_DIR"

# ============================================================================
# SESSION IDENTITY CONFIGURATION
# ============================================================================

# Session directory for storing identity files
export SHIPGLOWS_SESSION_DIR="${SHIPGLOWS_SESSION_DIR:-${SHIPGLOWS_SESSION_DIR:-$SHIPGLOWS_SECRETS_DIR/session}}"
export SHIPGLOWS_SESSION_DIR="$SHIPGLOWS_SESSION_DIR"

# Enable/disable session identity display
export SHIPGLOWS_SESSION_ENABLED="${SHIPGLOWS_SESSION_ENABLED:-${SHIPGLOWS_SESSION_ENABLED:-true}}"
export SHIPGLOWS_SESSION_ENABLED="$SHIPGLOWS_SESSION_ENABLED"

export SHIPGLOWS_MCP_CLEANUP_DRY_RUN="${SHIPGLOWS_MCP_CLEANUP_DRY_RUN:-${SHIPGLOWS_MCP_CLEANUP_DRY_RUN:-0}}"
export SHIPGLOWS_USER_CADDY_DRY_RUN="${SHIPGLOWS_USER_CADDY_DRY_RUN:-${SHIPGLOWS_USER_CADDY_DRY_RUN:-0}}"
export SHIPGLOWS_AGGRESSIVE_CLEANUP_DRY_RUN="${SHIPGLOWS_AGGRESSIVE_CLEANUP_DRY_RUN:-${SHIPGLOWS_AGGRESSIVE_CLEANUP_DRY_RUN:-0}}"
export SHIPGLOWS_GITHUB_AUTH_DRY_RUN="${SHIPGLOWS_GITHUB_AUTH_DRY_RUN:-${SHIPGLOWS_GITHUB_AUTH_DRY_RUN:-0}}"
export SHIPGLOWS_RESTART_VERIFY_SECS="${SHIPGLOWS_RESTART_VERIFY_SECS:-${SHIPGLOWS_RESTART_VERIFY_SECS:-12}}"
export SHIPGLOWS_REBOOT_DRY_RUN="${SHIPGLOWS_REBOOT_DRY_RUN:-${SHIPGLOWS_REBOOT_DRY_RUN:-0}}"
export SHIPGLOWS_CODEX_DRY_RUN="${SHIPGLOWS_CODEX_DRY_RUN:-${SHIPGLOWS_CODEX_DRY_RUN:-0}}"
export SHIPGLOWS_CLERK_LOGIN_TIMEOUT_SECONDS="${SHIPGLOWS_CLERK_LOGIN_TIMEOUT_SECONDS:-${SHIPGLOWS_CLERK_LOGIN_TIMEOUT_SECONDS:-600}}"
export SHIPGLOWS_BLACKSMITH_LOGIN_TIMEOUT_SECONDS="${SHIPGLOWS_BLACKSMITH_LOGIN_TIMEOUT_SECONDS:-${SHIPGLOWS_BLACKSMITH_LOGIN_TIMEOUT_SECONDS:-600}}"
export SHIPGLOWS_MCP_LOGIN_TIMEOUT_SECONDS="${SHIPGLOWS_MCP_LOGIN_TIMEOUT_SECONDS:-${SHIPGLOWS_MCP_LOGIN_TIMEOUT_SECONDS:-600}}"
export SHIPGLOWS_TURSO_LOGIN_TIMEOUT_SECONDS="${SHIPGLOWS_TURSO_LOGIN_TIMEOUT_SECONDS:-${SHIPGLOWS_TURSO_LOGIN_TIMEOUT_SECONDS:-600}}"
export SHIPGLOWS_TURSO_CONFIG_DIR="${SHIPGLOWS_TURSO_CONFIG_DIR:-${SHIPGLOWS_TURSO_CONFIG_DIR:-$HOME/.config/turso}}"
export SHIPGLOWS_TURSO_REMOTE_PROJECT_DIR="${SHIPGLOWS_TURSO_REMOTE_PROJECT_DIR:-${SHIPGLOWS_TURSO_REMOTE_PROJECT_DIR:-}}"
export SHIPGLOWS_FZF_HEIGHT="${SHIPGLOWS_FZF_HEIGHT:-${SHIPGLOWS_FZF_HEIGHT:-70%}}"
export SHIPGLOWS_MCP_CLEANUP_DRY_RUN="$SHIPGLOWS_MCP_CLEANUP_DRY_RUN"
export SHIPGLOWS_USER_CADDY_DRY_RUN="$SHIPGLOWS_USER_CADDY_DRY_RUN"
export SHIPGLOWS_AGGRESSIVE_CLEANUP_DRY_RUN="$SHIPGLOWS_AGGRESSIVE_CLEANUP_DRY_RUN"
export SHIPGLOWS_GITHUB_AUTH_DRY_RUN="$SHIPGLOWS_GITHUB_AUTH_DRY_RUN"
export SHIPGLOWS_RESTART_VERIFY_SECS="$SHIPGLOWS_RESTART_VERIFY_SECS"
export SHIPGLOWS_REBOOT_DRY_RUN="$SHIPGLOWS_REBOOT_DRY_RUN"
export SHIPGLOWS_CODEX_DRY_RUN="$SHIPGLOWS_CODEX_DRY_RUN"
export SHIPGLOWS_CLERK_LOGIN_TIMEOUT_SECONDS="$SHIPGLOWS_CLERK_LOGIN_TIMEOUT_SECONDS"
export SHIPGLOWS_BLACKSMITH_LOGIN_TIMEOUT_SECONDS="$SHIPGLOWS_BLACKSMITH_LOGIN_TIMEOUT_SECONDS"
export SHIPGLOWS_MCP_LOGIN_TIMEOUT_SECONDS="$SHIPGLOWS_MCP_LOGIN_TIMEOUT_SECONDS"
export SHIPGLOWS_TURSO_LOGIN_TIMEOUT_SECONDS="$SHIPGLOWS_TURSO_LOGIN_TIMEOUT_SECONDS"
export SHIPGLOWS_TURSO_CONFIG_DIR="$SHIPGLOWS_TURSO_CONFIG_DIR"
export SHIPGLOWS_TURSO_REMOTE_PROJECT_DIR="$SHIPGLOWS_TURSO_REMOTE_PROJECT_DIR"
export SHIPGLOWS_FZF_HEIGHT="$SHIPGLOWS_FZF_HEIGHT"

# ============================================================================
# ERROR HANDLING CONFIGURATION
# ============================================================================

# Enable strict error handling (set -euo pipefail equivalent)
export SHIPGLOWS_STRICT_MODE="${SHIPGLOWS_STRICT_MODE:-false}"

# Enable error traps (cleanup on failure)
export SHIPGLOWS_ERROR_TRAPS="${SHIPGLOWS_ERROR_TRAPS:-true}"

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

# Print configuration (for debugging)
shipglows_print_config() {
    echo "ShipGlows Configuration:"
    echo "  Projects Dir: $SHIPGLOWS_PROJECTS_DIR"
    echo "  Port Range: $SHIPGLOWS_PORT_RANGE_START-$SHIPGLOWS_PORT_RANGE_END"
    echo "  Logging: $SHIPGLOWS_LOGGING_ENABLED"
    echo "  Log File: $SHIPGLOWS_LOG_FILE"
    echo "  Log Level: $SHIPGLOWS_LOG_LEVEL"
    echo "  PM2 Cache: $SHIPGLOWS_PM2_CACHE_ENABLED"
}

# Validate configuration
shipglows_validate_config() {
    local errors=0

    if [ ! -d "$SHIPGLOWS_PROJECTS_DIR" ]; then
        echo "ERROR: Projects directory does not exist: $SHIPGLOWS_PROJECTS_DIR"
        ((errors++))
    fi

    if [ "$SHIPGLOWS_PORT_RANGE_START" -ge "$SHIPGLOWS_PORT_RANGE_END" ]; then
        echo "ERROR: Invalid port range"
        ((errors++))
    fi

    if [ "$SHIPGLOWS_LOGGING_ENABLED" = "true" ]; then
        mkdir -p "$SHIPGLOWS_LOG_DIR" 2>/dev/null || {
            echo "WARNING: Cannot create log directory: $SHIPGLOWS_LOG_DIR"
        }
    fi

    return $errors
}
