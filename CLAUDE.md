# CLAUDE.md

Guidance for Claude Code when working in this repository.

---

## Project Overview

**ShipGlows** — CLI dev environment manager for servers. Automates deployment with **Flox** (isolation), **PM2** (processes), **Caddy** (HTTPS reverse proxy). Provides SSH tunnel access + public HTTPS URLs via DuckDNS.

---

## Architecture

### Core Files

- **cli/shipglows.sh** — Main entry point (interactive menu)
- **cli/lib.sh** — Central library (ports, PM2 cache, Flox, Caddy, validation, logging)
- **cli/config.sh** — All settings via env vars (ports, SSH, logging, cache TTL)
- **cli/install.sh** — Server setup (Node.js, PM2, Flox, Caddy, gh, skills symlinks)

### Key Patterns

**Env Registry** (`~/.shipglows/envs.reg`) — Zero-subprocess dashboard data:
```bash
ensure_registry()    # Lazy refresh only when the registry is missing, invalidated, or stale
scan_flox_projects() # Shared bounded scanner; emits and prunes each matched .flox
registry_sync()      # Atomically rebuild from one Flox scan + one PM2 snapshot
registry_update()    # Atomically update one env entry after lifecycle mutations
# Format: name|status|port|path per line
# A valid last-known snapshot survives refresh or lock failures
```

`lib.sh` sourcing must not call PM2 or scan Flox. Cache-populating internals use
destination-variable APIs (`pm2_data_load`, `environment_index_load`,
`resolve_project_path_into`) in the parent shell; stdout wrappers exist only
for compatibility and must not be used when later calls need the same cache.

**PM2 Health Scan** — File-read health check, no subprocess:
```bash
pm2_health_scan()  # Reads ~/.pm2/dump.pm2 (~1ms), warns on >10 restarts
# Runs at lib.sh source time + after env_start + refresh_menu_status_cache_sync (every 120s)
```

**Port Allocation** — Anti-collision in 3000-3100 range:
```bash
find_available_port()  # Checks active ports + PM2-reserved ports
```

**Idempotent Operations** — No check-then-act races:
```bash
pm2 delete "app" 2>/dev/null || true  # Safe to retry
```

**Input Validation** — `validate_project_path()` blocks `..`, `;`, `&`, `|`, `$`, backticks.

**JSON Parsing** — Prefers jq (2-5x faster), falls back to python3.

**Dashboard** — Numbered `[ 1]...[N]` layout with legend `🟢 online 🟡 stopped 🔴 error ⚪ unknown`:
```bash
show_dashboard()  # Reads envs.reg, displays environments + action bar
# Action bar: [n] [s] [e] [o] [k] [x] — single-keypress (s/k/digits), multi-step (e/o + number)
# Stdin drain: read -t 0.01 -n 10000 after action bar prevents key leakage to main menu
```

**Auto-Install Guards** — Fail-safe dependency recovery:
```bash
# Node.js: checks node_modules exists + non-empty; runs pnpm/npm install if missing
# Python: checks venv/bin/python3 exists; creates venv + pip install -r requirements if missing
# Doppler: tests connectivity; disables if unreachable
```

**Port Display** — `localhost:PORT` (no protocol prefix), `Port:` without double-colon.

---

## Common Tasks

```bash
# Launch menu
sg                    # or: shipglows, or: ./cli/shipglows.sh

# Install dependencies (run as root)
sudo ./cli/install.sh

# Run tests
./tests/cli/input-validation.sh       # Input validation
./tests/cli/config-logging-cache.sh   # Caching, logging, config
./tests/cli/json-error-handling.sh    # jq, error handling

# Source library functions
source cli/lib.sh
env_start "myapp"     # Start environment (auto-installs deps, creates venv, validates doppler)
env_stop "myapp"      # Stop (idempotent, silent)
env_remove "myapp"    # Remove (destructive)
get_pm2_status "myapp"
get_port_from_pm2 "myapp"
registry_sync         # Force rebuild envs.reg from pm2
registry_update "name" "status" "port" "path"  # Update single entry
show_dashboard        # Display dashboard (reads envs.reg, 0 subprocesses)
```

---

## Critical Rules

1. **Always invalidate cache** after PM2 state changes (`invalidate_pm2_cache`)
2. **Don't parse JS with grep** — use `node -e "require(...)"`
3. **Don't use relative paths** — validation requires absolute paths
4. **Don't manually edit ecosystem.config.cjs** — regenerated on each start
5. **Use idempotent operations** — `pm2 delete || true`, not check-then-act
6. **Do not run Android release builds on Linux ARM64** — on `aarch64`/`arm64` hosts, do not run `flutter build apk --release`, `flutter build appbundle --release`, `./gradlew assembleRelease`, or `./gradlew bundleRelease`; route APK/AAB release builds to Blacksmith or another Linux x64 CI runner. Local Flutter work is limited to `flutter analyze`, `flutter test`, and `flutter build web --release`.
7. **Keep reference clones and caches hidden** — use `~/.local/share/.go`, `~/.local/share/.fzf`, and `~/.local/share/.keyboard` instead of visible top-level `~/go`, `~/fzf`, or `~/keyboard` directories.

---

## Framework Auto-Configuration

| Framework | Detection | Port Config |
|-----------|-----------|-------------|
| Astro | package.json | `server.port = PORT` in config |
| Vite | package.json | `--port $PORT --host` |
| Next.js | package.json | `-p $PORT` (automatic) |
| Nuxt | package.json | `--port $PORT` |
| Vue CLI | `@vue/cli-service` in package.json | `vue-cli-service serve --port $PORT --host 0.0.0.0` |
| Expo | package.json | Tunnel mode, no fixed port |
| Python/FastAPI | venv/bin/python3 | Via uvicorn in ecosystem config |

## Renamed Environments

| Original | Renamed | Path | Purpose |
|----------|---------|------|---------|
| `app` | `shipglows_app` | `/home/claude/shipglows_app/shipglows_app/` | Flutter dashboard (CI only) |
| `site` | `shipglows-site` | `/home/claude/shipglows_app/site/` | ShipGlows marketing site (Astro) |
| `contentflowz-app` (flox) | `shipglows-app` | — | Flox env for shipglows_app |

---

## File Structure

```
shipglows/
├── cli/
│   ├── shipglows.sh            # Main menu
│   ├── lib.sh                  # Core library
│   ├── config.sh               # Configuration
│   ├── install.sh              # Server installation
│   ├── shipglows_devserver_bash.sh
│   └── shipglows_devserver_gum.sh
├── shipglows.sh                # Compatibility launcher
├── lib.sh                      # Compatibility launcher
├── config.sh                   # Compatibility launcher
├── install.sh                  # Compatibility launcher
├── skills/                     # ShipGlows skill library
├── .claude/statusline-starship.sh  # Status bar
├── local/                      # SSH tunnel scripts
│   ├── dev-tunnel.sh
│   ├── local.sh
│   └── install.sh
├── injectors/web-inspector.js  # Browser inspector
└── tests/                      # Test suites grouped by ownership
```
