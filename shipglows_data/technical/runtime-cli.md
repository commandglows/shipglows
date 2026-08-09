---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "1.0.30"
project: ShipGlows
created: "2026-05-01"
updated: "2026-08-09"
status: reviewed
source_skill: sg-start
scope: runtime-cli
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - cli/shipglows.sh
  - cli/lib.sh
  - cli/shipglows_devserver_gum.sh
  - cli/shipglows_devserver_bash.sh
  - cli/config.sh
  - cli/windows/ShipGlows.DevServer.psm1
  - cli/windows/shipglows-devserver.ps1
  - cli/windows/install-devserver.ps1
  - CONTEXT-FUNCTION-TREE.md
depends_on:
  - artifact: "ARCHITECTURE.md"
    artifact_version: "1.0.0"
    required_status: reviewed
  - artifact: "GUIDELINES.md"
    artifact_version: "1.2.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Function inventory from cli/shipglows.sh, cli/lib.sh, cli/config.sh, and CONTEXT-FUNCTION-TREE.md."
  - "Blacksmith setup menu added for official CLI/Testbox guidance without token handling."
  - "Remote Blacksmith auth now routes to local SSH callback tunnel instead of direct server login."
  - "Blacksmith setup menu now includes SSH Access runner-debug guidance."
  - "Main menu shortened with grouped submenus."
  - "Root menu labels simplified to visible user actions without abstract section headers."
  - "Health Check system monitor now shows disk capacity alongside memory."
  - "Disk cleanup now includes protected agent-history and agent-cache cleanup choices."
  - "Disk cleanup menus now target heavier real-world dev caches and workspace build artifacts such as Gradle caches, Dart analysis cache, pub cache, node_modules, venvs, and common frontend build directories."
  - "Aggressive disk cleanup preserves PNPM homes, configured stores, and global PNPM binaries."
  - "Disk details and PM2 log cleanup/rotation added to explain and cap disk usage."
  - "Native Windows full installs a pinned checksum-verified Gum binary in the ShipGlows runtime and keeps the PowerShell menu as fallback."
  - "Native Windows clone flow installs Git and GitHub CLI, delegates browser authentication and credentials to gh, and exposes a searchable private/public repository chooser."
  - "Native Windows full installs Node LTS, pnpm and uv automatically; Flutter Web remains an explicit optional download in the interactive installer."
  - "Native Windows full migrates away the obsolete managed PowerShell profile function because PATH-backed .cmd launchers work even when profile scripts are disabled."
  - "Native Windows full offers Codex, Claude Code, OpenCode, and KiloCode as separate opt-in prompts; agent authentication remains owned by each CLI."
  - "Native Windows pnpm provisioning adds pnpm v11's global bin subdirectory to the user PATH and verifies the executable before reporting success."
  - "Main menu session identity now renders inside the top status header."
  - "Subcommand screen headers now route through a shared modular header helper."
  - "Nested menus and search selectors now preserve the ShipGlows DevServer title treatment."
  - "GitHub CLI authentication screen added for deploy-from-GitHub readiness."
  - "Turso guided setup added under Agents with local tunnel login routing and schema-check commands."
  - "Completed disk cleanup now offers x as an explicit return to the root menu."
  - "Non-Expo PM2 launch commands activate the project Flox environment at runtime; Doppler remains the outer wrapper when enabled."
  - "SHIPGLOWS_ENV_PORT can explicitly replace a persisted PM2 port and refuses collisions."
  - "Project-local .shipglows.env settings pin runtime ports and can disable automatic restart recovery."
  - "The project runtime policy file now has a closed, data-only schema so unknown settings fail loudly instead of silently restoring defaults."
next_review: "2026-06-01"
next_step: "/sg-docs technical audit runtime-cli"
---

# Runtime CLI

## Purpose

This doc covers the server-side CLI runtime: `cli/shipglows.sh`, `cli/lib.sh`, and `cli/config.sh`. It is the first technical doc to read when changing environment lifecycle, dashboard, publishing, health, PM2, Flox, Caddy, DuckDNS, session identity, or CLI menu behavior.

## Owned Files

| Path | Role | Edit notes |
| --- | --- | --- |
| `cli/shipglows.sh` | Thin CLI entrypoint that sources runtime and menu files, then calls `main` | Keep thin; do not move business logic here |
| `cli/lib.sh` | Main orchestration library for UI, validation, PM2/Flox/Caddy operations, health, deploy, publish, and actions | High blast radius; prefer focused changes and syntax checks |
| `cli/shipglows_devserver_gum.sh`, `cli/shipglows_devserver_bash.sh` | Menu frontends that render the root menu and grouped submenus | Keep frontend behavior equivalent; update both variants together |
| `cli/windows/install-devserver.ps1`, `cli/windows/shipglows-devserver.ps1` | Native Windows dependency bootstrap and DevServer frontend | Install the pinned checksum-verified Gum binary into the user runtime, prefer it for interactive choices, and preserve the plain PowerShell fallback |
| `cli/config.sh` | Central configuration defaults and validation | Keep defaults explicit and validation actionable |
| `cli/windows/ShipGlows.DevServer.psm1` | Native Windows project detection, registry, process lifecycle, ports, and logs | Keep PowerShell 5.1-compatible; never evaluate project input as code |
| `cli/windows/shipglows-devserver.ps1` | Native Windows dashboard/menu and one-shot actions | Keep menu and one-shot actions aligned |
| `cli/windows/install-devserver.ps1` | Installs the Windows launcher and developer tools | Install Node LTS, pnpm and uv idempotently; remove only ShipGlows's obsolete profile block; ask before Flutter Web or each coding-agent CLI |
| `CONTEXT-FUNCTION-TREE.md` | Navigation aid for large shell files | Update when major functions or flows move |

## Entrypoints

- `shipglows` / `sg`: installed wrappers that call `cli/shipglows.sh`.
- `cli/shipglows.sh::main`: checks prerequisites, then starts the menu or runs a
  one-shot visible menu-key path.
- `sg codex` / `sg co`: early Codex launcher shortcut that bypasses
  environment cleanup, asks for a workspace/MCP preset when needed, then
  replaces the ShipGlows process with `codex`.
- `cli/lib.sh::run_menu`: dispatches interactive menu choices to `action_*` handlers.
- `cli/lib.sh::run_menu_shortcut`: dispatches a single CLI menu-key argument such
  as `sg t` or a nested key path such as `sg m n` to the matching visible menu
  action. Path resolution starts in `MAIN_MENU_ITEMS`, then continues through
  grouped submenu item arrays when the selected action opens a nested menu.
- `cli/shipglows_devserver_gum.sh` / `cli/shipglows_devserver_bash.sh`: render the root menu from `MAIN_MENU_ITEMS`
  and grouped submenus from `ENVIRONMENT_MENU_ITEMS`, `TOOLS_WEB_MENU_ITEMS`,
  `SYSTEM_MENU_ITEMS`, and `AGENTS_CI_MENU_ITEMS`. Startup rendering should
  avoid per-item subprocesses; the Gum frontend should batch styling through
  one boxed render instead of one `gum style` call per item. The root menu uses
  a two-column layout on wide terminals and falls back to one column on narrow
  terminals. ShipGlows's own tracker overview is exposed as a dedicated root
  action instead of being nested under agents.
- `cli/shipglows_devserver_bash.sh` / `cli/shipglows_devserver_gum.sh`: render menus and use shared key input helpers
  so `x`, `Esc`, and `Backspace` act consistently for Back.
- Nested menus render their screen title through `cli/lib.sh::ui_screen_header` and
  dispatch actions in `screen` mode so child commands do not stack under the
  parent menu.
- `cli/lib.sh` UI helpers: `ui_read_choice`, `ui_run_menu_action`,
  `ui_return_back`, `ui_return_to_main_menu`, and the navigation signals define
  the reusable Back/cancel contract for nested menus, including selections made
  through `$(ui_choose ...)` command substitutions.
- `cli/lib.sh::ui_run_menu_action`: centralizes menu action dispatch. Top-level
  interactive actions run in `screen` mode so command output starts from a
  clean screen instead of below the root menu, while nested menus can keep
  `inline` behavior.
- `cli/lib.sh::ui_header`: prints the main menu status header and can embed the
  session identity block inside the same top frame.
- `cli/lib.sh::ui_screen_header`: prints consistent subcommand screen headers from
  one title plus an optional variant such as `danger` or `success`.

## Native Windows DevServer

The Windows `full` bootstrap is a separate runtime backend for machines such
as Shadow PC where WSL cannot be used. It owns only local development for
Astro, Python/FastAPI, and Flutter Web. Repositories are constrained to the
configured workspace, ports are allocated from `3000..3100`, and process
identity is checked with PID, start time, executable path, and a command
signature before stopping a process. The JSON registry is written through a
validated temporary file and atomic replacement.

Linux-only Flox, PM2, Caddy, autossh, and the interactive `urls` menu are not
emulated on Windows. The full installer prepares Git, GitHub CLI, Node LTS
(including npm), pnpm and uv. It asks before downloading Flutter Web, then
clones the stable SDK into the user-local ShipGlows directory and enables web
support. pnpm's configured global bin directory (the `bin` subdirectory of
`PNPM_HOME` on pnpm v11) is created, added to the user `PATH`, and checked with
`pnpm --version` before the installer reports success. It also asks separately,
with `no` as the default, before installing
Codex, Claude Code, OpenCode, or KiloCode. It stores no agent credentials and
never initiates authentication: the selected CLI owns its own first-run login.
Flutter is launched in a visible process because PowerShell 5.1 does not
provide a tmux-equivalent session manager.
- `cli/lib.sh::ui_box_header` (deprecated: use `ui_screen_header` or `ui_text_center`): prints fixed-width boxed CLI headers so left and
  right borders stay aligned across dashboard, logs, health, and success blocks.
- `cli/lib.sh::env_start`, `env_stop`, `env_restart`, `env_remove`: core environment lifecycle.
- A project may commit a data-only runtime policy file named `.shipglows.env`.
  Its closed schema accepts blank lines, comments, and only
  `SHIPGLOWS_ENV_PORT=<1024-65535>` and `SHIPGLOWS_AUTO_REPAIR=true|false`.
  The file is never sourced as shell code and must contain neither secrets nor
  general dotenv configuration. Unknown or malformed entries fail the launch
  loudly, so a typo cannot silently restore a safety-sensitive default. When
  the file is absent, ShipGlows dynamically allocates the port and enables
  automatic recovery. A port setting pins the generated PM2 port; a value of
  `SHIPGLOWS_AUTO_REPAIR=false` makes `env_restart` show the relevant PM2 logs,
  offer Codex repair, return failure, and never regenerate the runtime through
  `env_start` after a failed restart or PM2 crash loop. A one-shot process
  environment value for `SHIPGLOWS_ENV_PORT` takes precedence.
- `env_start` detects Astro projects and sets `ASTRO_DEV_BACKGROUND=0` in their
  generated PM2 environment. Astro 7 automatically detaches `astro dev` when
  it detects an AI coding agent; PM2 is already the supervisor, so Astro must
  remain in the foreground to avoid supervising a short-lived launcher.
- `cli/lib.sh::env_remove` also stops project-scoped Flutter Web tmux sessions,
  unregisters the local Flox environment, synchronizes Caddy and the durable
  environment registry, and rejects absolute directories that are not Flox
  projects before deletion. It also terminates TCP listeners whose process cwd
  is the project directory or one of its descendants. Non-listening shells and
  tools are deliberately preserved; failure to stop a matched listener aborts
  before deleting the project tree. Listener discovery is rescanned until a
  bounded stable quiescence window is reached, so supervisors cannot hide a
  respawn behind one snapshot. Before every TERM or KILL, ShipGlows revalidates
  the PID start time and cwd from `/proc` to avoid signalling a reused PID or a
  process that moved outside the project scope.
- `cli/lib.sh::list_pm2_app_names`, `list_all_stop_targets`, and
  `pm2_stop_app_by_name`: PM2 stop safety helpers used to stop both
  disk-discovered environments and PM2-only orphan entries.
- `cli/lib.sh::action_flutter_web`: interactive Flutter Web preview through `tmux`
  with hot reload/hot restart control.
- `cli/lib.sh::action_blacksmith_setup`: guided official-first Blacksmith setup
  screen for CLI presence, local auth status, GitHub App guidance, runner tags,
  SSH Access debugging guidance, and Testbox init commands. It prints required
  terminal commands instead of running interactive install/auth/project mutation
  steps automatically, and routes remote Blacksmith auth through the local
  tunnel menu.
- `cli/lib.sh::action_turso_setup`: guided Turso setup screen under Agents. It
  reports CLI/auth status through `turso auth whoami`, routes browser login to
  the local `urls` Turso helper, and prints ContentFlow schema-check commands
  without reading or storing Turso tokens.
- `cli/lib.sh::action_codex_launcher`: interactive Codex launcher for choosing a
  workspace and enabling selected MCP providers for the new Codex session only.
- `cli/lib.sh::action_mcp_menu`: grouped MCP/Codex menu that routes to the Codex
  launcher or the local OAuth tunnel instructions.
- `cli/lib.sh::action_github_auth`: official GitHub CLI login/status screen for
  repository listing and deploy-from-GitHub readiness. It delegates token
  handling to `gh` and must not read or store GitHub tokens.
- `cli/lib.sh::deploy_github_project`: starts a freshly cloned repository from
  its authoritative absolute path, rather than through the lazy environment
  registry that can predate the new `.flox` directory.
- `cli/lib.sh::action_reboot_vm`: explicit confirmed VM reboot action from the
  system menu. It supports `SHIPGLOWS_REBOOT_DRY_RUN=1` for smoke checks.
- `cli/lib.sh::mcp_cleanup_menu`: health-menu cleanup for local MCP process
  groups. It lists provider/RAM/uptime/parent Codex evidence and stops only a
  confirmed process group.
- `cli/lib.sh::action_health`: renders the system monitor with RAM, disk, swap,
  process, and PM2 health first, then uses explicit one-key actions for cleanup
  commands. It must not route destructive cleanup options through
  searchable/default-select menus.
- `cli/lib.sh::disk_cleanup_menu`: one-key disk cleanup flow for old Codex/Claude
  history files, agent caches/logs, safe dev caches, and heavier regenerated
  dev state. The light tier targets low-risk package/tool caches; the
  aggressive tier also removes large regenerated state such as Gradle caches,
  Dart analysis cache, pub cache, selected local editor/agent state, and
  common workspace artifacts (`node_modules`, `venv`, `.dart_tool`, build
  directories). It shows estimated recoverable space and protects auth,
  config, skills, memories, source trees, recent agent histories, PNPM homes,
  configured PNPM stores, and PNPM global binaries. After a completed cleanup,
  `x` returns directly to the root menu instead of leaving the operator at a
  generic submenu pause.
- `cli/lib.sh::disk_usage_details_menu`: read-only disk usage detail view for the
  largest PM2 log files, `$HOME` entries, project/work directories, and root
  filesystem entries.
- `cli/lib.sh::cleanup_pm2_logs_with_rotation`: truncates PM2 daemon/app logs and
  configures `pm2-logrotate` (`max_size=50M`, `retain=5` by default) so PM2
  logs cannot refill the disk unchecked.
- Command submenus that can start, stop, restart, launch, or clean up runtime
  state should use explicit one-key choices or confirmations; `ui_filter_choose`
  is reserved for longer data-selection lists and flushes pending input before
  opening the filter. The shared input flush now waits for a short quiet window
  on `/dev/tty` instead of a single immediate drain so fast `key + Enter`
  sequences from one-key menus do not leak into the next searchable selector.
- `cli/lib.sh::refresh_user_caddy_from_pm2` and
  `sync_caddy_after_pm2_change`: user-mode Caddy lifecycle helpers. They write
  runtime config under the operator's `~/.shipglows/runtime/caddy`, refresh
  routes from online PM2 apps, and stop Caddy when no PM2 app is online.
- `cli/lib.sh::action_publish`: public exposure through Caddy and DuckDNS.

## Control Flow

```text
cli/shipglows.sh
  -> source cli/lib.sh
  -> main
  -> check_prerequisites
  -> run_menu OR run_menu_shortcut
  -> action_* handler
  -> PM2 / Flox / user Caddy / optional DuckDNS side effect
```

For projects detected from `pubspec.yaml`, runtime provisioning is explicit:
- `dart` projects must ensure Dart packages in project Flox before launch.
- `flutter` projects must ensure Flutter packages in project Flox before launch.
- existing `.flox` environments are repaired idempotently for Dart/Flutter
  runtime packages before startup continues.
- runtime override variables are treated as untrusted input and validated as
  simple Flox package tokens before any `flox install` call.

Flutter Web has two runtime paths:
- PM2-managed launch remains available through the normal environment lifecycle.
- A `package.json` without a supported JS framework or exact runnable `dev` /
  `start` script must not block `pubspec.yaml` detection; mixed Flutter +
  Convex projects still use the Flutter Web command.
- Interactive preview uses `tmux` from `action_flutter_web`, starts
  `flutter run -d web-server --web-hostname 0.0.0.0 --web-port <port>` inside
  the project Flox environment, records the session in
  `SHIPGLOWS_FLUTTER_WEB_SESSIONS_FILE`, and sends `r`/`R` to that session for
  hot reload or hot restart.
- Environment removal stops any registered Flutter Web session for the target
  project before deleting its working tree.

Node framework launch detection reads declared package dependencies rather than
matching arbitrary `package.json` text. With a local `pnpm-lock.yaml`, known
framework binaries use `pnpm exec`; Vue CLI projects are detected through
`@vue/cli-service` and run with an explicit port and `0.0.0.0` host. Generic
project scripts continue to use `pnpm dev` because they are npm scripts, not
package binaries.

## Invariants

- PM2 is the execution state source.
- `invalidate_pm2_cache` must run after PM2 mutations.
- User-mode Caddy follows PM2 online state: environment start refreshes routes,
  environment stop refreshes or stops it, and Stop All stops it when no PM2 app
  remains online.
- The system Caddy service is a legacy/public HTTPS path and should not be left
  running when no PM2 app is online.
- Stop flows must cover PM2 entries even when their project directories are no
  longer resolvable from disk, then persist the stopped state with PM2.
- Remove flows must stop project-scoped interactive sessions, synchronize Caddy
  after PM2 changes, and rebuild the durable environment registry before
  reporting success.
- Generated PM2 ecosystem configs for dev servers must bound automatic restart
  loops so broken commands cannot fill logs indefinitely.
- Generated PM2 ecosystem configs for non-Expo projects must export the
  ShipGlows-assigned port and run the detected command through `flox activate`
  at runtime. When Doppler is enabled, it remains the outer wrapper so secrets
  are injected before the runtime command and ShipGlows's port export still
  wins over a Doppler-provided `PORT`.
- `env_restart` must confirm that PM2 remains `online` during its stability
  window before reporting success or advertising the application's localhost
  URL.
- Project paths must be validated and absolute before runtime use.
- Port allocation must avoid active socket collisions and PM2 hidden collisions.
- User-visible success and failure should be observable.
- Project tracking initialization must keep ShipGlows-owned `TASKS.md` under
  `SHIPGLOWS_DATA_DIR` and must not create project-local `TASKS.md` symlinks.
  Legacy symlinks from older ShipGlows versions should be removed when they
  point into `shipglows_data`.
- Root interactive menu actions should be dispatched through
  `ui_run_menu_action` in `screen` mode; grouped submenus may use `inline` when
  they already own their screen lifecycle.
- Back/cancel paths should signal parent redraw through the shared UI helpers
  instead of returning like completed actions.
- Subcommand screen headers should use `ui_screen_header` rather than
  hand-counted rules or direct `ui_box_header` calls.
- Generated ecosystem/runtime config is not the hand-edited source of truth.
- PM2 identities for generic monorepo surfaces are derived as
  `<parent-project>_<role>` for `app`, `site`, `lab`, and `worker`; already
  specific directory names remain unchanged. Every lifecycle operation must
  use the same centralized derivation.
- Codex MCP providers are off by default; the runtime launcher enables selected
  providers with session-only config overrides and must not persistently flip
  `~/.codex/config.toml`.
- Dart/Flutter runtime provisioning failures must stop startup before PM2 launch.
- Flutter Web `tmux` preview sessions are interactive developer sessions, not
  PM2-managed production-like processes.

## Failure Modes

- Missing prerequisites should produce an actionable error before secondary failures.
- Unknown shortcut arguments should fail visibly with the available visible root menu keys.
- Invalid shortcut paths should fail visibly with the offending argument
  position instead of silently falling through to the interactive menu.
- Back actions should redraw the parent menu directly instead of requiring an
  extra pause keypress.
- Back/cancel state can be lost when a selector runs inside Bash command
  substitution unless the shared skip-next-pause signal is used.
- PM2 cache drift can make dashboard, health, and port decisions wrong.
- Disk-only environment discovery can miss stale PM2 entries; stop flows should
  union project-discovered environments with PM2 app names.
- Unbounded PM2 autorestart can turn a missing directory, missing dependency, or
  failing dev command into a restart storm and log growth incident.
- A successful `pm2 restart` command alone is not runtime proof: a process can
  enter `waiting restart` immediately afterwards, so the menu must report the
  failed stabilization and point to its PM2 logs.
- User-mode Caddy startup failures must not block PM2 app startup, but they must
  be visible with the runtime log path.
- Caddy/DuckDNS publishing failures must not be reported as successful public exposure.
- Broad shell parsing can misread structured state; use `jq`, Node, or existing structured helpers where available.
- Invalid Dart/Flutter package overrides (paths, shell fragments, option-like tokens) must be rejected before invoking `flox install`.
- Missing `tmux` should block only the interactive Flutter Web preview path and
  produce an actionable operator message.
- Missing Blacksmith CLI or auth should be shown as a setup status, not as a
  runtime failure; the menu must print the official next command when an
  interactive Blacksmith step is required.
- Missing Turso CLI or auth should be shown as setup status; the server menu
  should route login to local tunnel tooling instead of asking the remote shell
  to open a browser callback directly.
- Blacksmith SSH Access is an organization/GitHub user capability, not a
  ShipGlows server install step. The runtime menu should explain where to find
  the `Setup runner` SSH command and should not attempt to write local
  workstation SSH config from the server.
- The Codex launcher should fail before `exec` when Codex is absent, a selected
  workspace is invalid, or an MCP name is malformed; it must not kill existing
  Codex conversations or MCP processes.
- MCP cleanup should target only local MCP server process groups, ask for
  confirmation, and refuse any process group that contains a `codex` process.
- Disk cleanup must not delete agent auth/config/skills/memories; history
  cleanup is retention-based. Aggressive cleanup may remove regenerated build
  artifacts inside project trees, but not source files, git data, or primary
  repository structure.
- Package-manager caches are disk cleanup targets, not RAM/process cleanup
  targets; PNPM homes and stores are explicitly protected so aggressive cleanup
  does not invalidate PNPM global binaries or downloaded packages.
- PM2 logs can dominate disk usage; disk cleanup should expose their size, offer
  a confirmed flush, and configure rotation rather than relying on manual
  operator cleanup.

## Security Notes

- Do not log tokens, DuckDNS secrets, private paths containing credentials, or raw environment values.
- Public URL publishing is externally visible and needs explicit validation.
- Destructive actions must stay idempotent and confirmation-gated where the UX expects it.
- Blacksmith credentials are detected only by local credentials-file presence;
  the runtime must not read, print, store, or transform token contents.
- Blacksmith runner SSH diagnostics must not copy raw environment values,
  tokens, cookies, signing keys, or private headers into reports.
- Turso auth status may be checked through `turso auth whoami`; token files
  under `~/.config/turso` must not be read or printed by the runtime menu.

## Validation

```bash
bash -n cli/shipglows.sh cli/lib.sh cli/config.sh
tests/cli/environment-remove.sh
tests/runtime/flox-provisioning.sh
rg -n "invalidate_pm2_cache" cli/lib.sh
printf 'x\n' | env SHIPGLOWS_PROJECTS_DIR=/tmp/shipglows-empty ./cli/shipglows.sh u
SHIPGLOWS_CODEX_DRY_RUN=1 ./cli/shipglows.sh codex --dir "$PWD" supabase playwright
printf 'x' | bash -lc 'source ./cli/lib.sh; action_health'
printf 'x\n' | bash -lc 'source ./cli/lib.sh; disk_cleanup_menu'
printf 'x\n' | bash -lc 'source ./cli/lib.sh; action_turso_setup'
SHIPGLOWS_PM2_LOG_CLEANUP_DRY_RUN=1 bash -lc 'source ./cli/lib.sh; cleanup_pm2_logs_with_rotation'
bash -lc 'source ./cli/lib.sh; disk_usage_details_menu'
SHIPGLOWS_MCP_CLEANUP_DRY_RUN=1 bash -lc 'source ./cli/lib.sh; mcp_cleanup_menu'
SHIPGLOWS_USER_CADDY_DRY_RUN=1 bash -lc 'source ./cli/lib.sh; refresh_user_caddy_from_pm2'
printf 'o\n' | SHIPGLOWS_REBOOT_DRY_RUN=1 bash -lc 'source ./cli/lib.sh; action_reboot_vm'
```

Run a focused runtime smoke for the touched behavior when practical, for example dashboard/status for read-only changes or a non-production test project for lifecycle changes.

## Reader Checklist

- `cli/shipglows.sh`, `cli/lib.sh`, or `cli/config.sh` changed -> review this doc and `code-docs-map.md`.
- Function structure moved -> update `CONTEXT-FUNCTION-TREE.md`.
- User-facing CLI behavior changed -> check `README.md` and `CONTEXT.md`.
- Publish or secret handling changed -> check security notes and public docs.

## Maintenance Rule

Update this doc when runtime entrypoints, lifecycle flows, PM2/Flox/Caddy/DuckDNS behavior, validations, or security constraints change.
