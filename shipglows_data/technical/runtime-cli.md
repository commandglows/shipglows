---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "1.9.2"
project: ShipGlows
created: "2026-05-01"
updated: "2026-08-15"
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
  - skills/references/agent-runtime-awareness.md
  - CONTEXT-FUNCTION-TREE.md
depends_on:
  - artifact: "shipglows_data/technical/architecture.md"
    artifact_version: "1.0.0"
    required_status: reviewed
  - artifact: "shipglows_data/technical/guidelines.md"
    artifact_version: "1.2.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Runtime layout migration 2026-08-11: mutable user-mode Caddy state now defaults to ~/.shipglows/state/caddy, leaving ~/.shipglows/runtime available for the canonical code checkout."
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
  - "Native Windows full resolves and validates Flutter/Dart, JDK 17 and Android command-line tools in user scope; Android terms and SDK licenses remain explicitly user-confirmed, with non-interactive runs pending."
  - "Native Windows full migrates away the obsolete managed PowerShell profile function because PATH-backed .cmd launchers work even when profile scripts are disabled."
  - "Native Windows full prepares Dart/Flutter and exact-version Playwright MCP for installed agents; existing JSON/JSONC is preserved and reported pending when no safe native update is proven."
  - "Native Windows pnpm provisioning adds pnpm v11's global bin subdirectory to the user PATH and verifies the executable before reporting success."
  - "Native Windows installs priority .cmd wrappers for npm-family and coding-agent commands so restrictive PowerShell execution policies cannot select blocked .ps1 shims."
  - "Native Windows resolves supported nested menu shortcuts such as s m n inside the PATH-backed launcher, without requiring a PowerShell profile."
  - "Native Windows installs collision-safe .cmd shortcuts for c, co, cor, oc and kc after their managed agent command targets are available."
  - "Main menu session identity now renders inside the top status header."
  - "Subcommand screen headers now route through a shared modular header helper."
  - "Nested menus and search selectors now preserve the ShipGlows DevServer title treatment."
  - "GitHub CLI authentication screen added for deploy-from-GitHub readiness."
  - "Turso guided setup added under Agents with local tunnel login routing and schema-check commands."
  - "Completed disk cleanup now offers x as an explicit return to the root menu."
  - "Non-Expo PM2 launch commands activate the project Flox environment at runtime; Doppler remains the outer wrapper when enabled."
  - "Linux Flox discovery now records environment_root and launch_path separately, respects nested Flox boundaries, migrates the legacy registry idempotently, and rejects ambiguous launch targets."
  - "SHIPGLOWS_ENV_PORT can explicitly replace a persisted PM2 port and refuses collisions."
  - "Project-local .shipglows.env settings pin runtime ports and can disable automatic restart recovery."
  - "The project runtime policy file now has a closed, data-only schema so unknown settings fail loudly instead of silently restoring defaults."
  - "Native Windows exposes one static global development-environment file and one CLI-managed server URL file per project."
  - "Native Windows installed agent instructions now expose two-tier mutation approval with a cumulative fast path and full-plan-only remote push."
  - "Native Windows installed agent instructions now require direct-plus-deferred tool discovery before declaring a configured capability unavailable."
  - "Native Windows project discovery now uses one cached linear catalogue shared by every dashboard and picker, while the registry remains authoritative for live state."
next_review: "2026-06-01"
next_step: "/sg-docs technical audit runtime-cli"
---

# Runtime CLI

## Purpose

This doc covers both runtime backends: the Linux server CLI and the native
Windows local DevServer. It is the first technical doc to read when changing
environment lifecycle, dashboard, project shortcuts, publishing, health,
PM2/Flox/Caddy behavior, or native Windows process and installer behavior.

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
| `cli/windows/install-devserver.ps1` | Installs the Windows launcher and developer tools | Install Node LTS, pnpm, uv, Flutter and the Android path idempotently; preserve explicit Android license/UAC confirmations; configure installed agents only |
| `CONTEXT-FUNCTION-TREE.md` | Navigation aid for large shell files | Update when major functions or flows move |

The Windows launcher also owns the profile-independent shortcut paths that
have a native equivalent: `s d`, `s e`, `s m r`, `s m t`, `s m o`, `s m l`,
and `s m n`. Navigation selects a registered project and opens a child
PowerShell in that directory; it does not attempt to mutate the parent shell.
Linux-only Flox, PM2 and Caddy paths remain unavailable rather than being
silently remapped.

The installer also creates profile-independent, collision-safe agent shortcuts:
`c -> claude`, `co -> codex`, `cor -> codex resume`, `oc -> opencode`, and
`kc -> kilocode`. Each shortcut calls the managed command in the same runtime
directory. If Windows already resolves that short name to another command,
ShipGlows preserves the existing owner and reports the conflict.

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

## Linux Flox environment boundaries

The Linux backend treats each directory containing `.flox` as an environment
root, but no longer assumes that it is also the application working directory.
Discovery resolves one native application from `package.json`, `pubspec.yaml`,
`pyproject.toml`, `requirements.txt`, `Cargo.toml`, or `go.mod`. A direct
application wins; otherwise exactly one nested launch target is required.

A nested directory containing its own `.flox` is an independent environment
boundary. Its subtree is excluded from its parent's launch-target search. If a
parent environment contains several remaining launchable applications,
ShipGlows reports the ambiguity and does not register or start one
alphabetically.

The Linux registry stores five fields:

`name|status|port|environment_root|launch_path`

Four-field legacy entries remain readable long enough to preserve a
last-known-good snapshot. The next registry synchronization migrates them
atomically and idempotently. PM2 runs with `cwd=launch_path`; dependency and
application commands run from that directory; `flox activate --dir` always
receives `environment_root`. Destructive environment operations continue to
target the environment root, never only the nested application directory.

## Native Windows DevServer

The Windows `full` bootstrap is a separate runtime backend for machines such
as Shadow PC where WSL cannot be used. It owns only local development for
Astro, Python/FastAPI, and Flutter Web. Repositories are constrained to the
configured workspace, ports are allocated from `3000..3100`, and process
identity is checked with PID, start time, executable path, and a command
signature before stopping a process. The JSON registry is written through a
validated temporary file and atomic replacement.

The native Windows backend does not activate, parse, or derive project
boundaries from Flox. It discovers supported applications from native manifests
such as `package.json`, `pubspec.yaml`, `pyproject.toml`, and
`requirements.txt`, including nested monorepo launch paths. `.flox` has no
effect on Windows dependencies, variables, launch commands, ports, or project
identity.

All Windows menus consume the same catalogue produced by one linear workspace
scan. The discovery index is cached in memory and atomically at
`%LOCALAPPDATA%\ShipGlows\DevServer\project-index.json` with its schema,
workspace, scanner version, generation time, and a five-minute TTL. It is only
an acceleration layer: invalid or stale cache data is ignored, refresh forces a
rebuild, and clone/register/unregister invalidate both cache layers. Registry
entries win when discovery and runtime state overlap, so the registry remains
the authority for status, ports, logs, and process identity.

The catalogue identity is the canonical runnable `launchPath`. Display names
are the launch path relative to the workspace with `/` separators, or the full
canonical path outside the workspace. Navigation shows only that name; lifecycle
pickers may project status, kind, and port. Every picker maps its displayed row
back to the exact identity and revalidates the current manifest before acting.
A `package.json` without `scripts.dev` is ignored as a non-runnable surface.

Linux-only Flox, PM2, Caddy, autossh, and the interactive `urls` menu are not
emulated on Windows. The full installer prepares Git, GitHub CLI, Node LTS
(including npm), pnpm, uv and Flutter, then enables web and Android support.
An interactive x64 install asks the emulator product question about installing the
Android emulator and creating `ShipGlows_API_36` only when that provisioned state
is incomplete. A complete emulator, Android 36 image, and named AVD skip the
question; a partial state offers repair. Nested-virtualization evidence changes
the warning, not the operator's ability to choose. Accepted emulator and Android
36 image downloads run with visible progress; the AVD is created before
acceleration is checked. Without hardware acceleration it remains
installed, but ShipGlows records that it is not device-ready; the documented
`-accel off -gpu software` path is diagnostic-only and may be unusably slow or
fail to boot. Non-interactive installs never prompt or infer consent.
Validated existing Flutter/Dart, JDK 17 and Android SDK paths are reused without
rewriting their environment ownership. Otherwise JDK 17 is installed first; the
Android terms are then shown before hardened ZIP extraction of command-line tools.
The Windows archive coordinate from Google's SDK repository must match the exact
filename and SHA-256 in the official Android Studio download table; SHA-1-only
repository metadata is never treated as sufficient integrity evidence.
The installer prints the resolved version and size, uses curl's visible progress
bar, bounded retries and partial-transfer resume, then announces checksum and
extraction milestones.
An idempotent rerun probes accepted-license state with only a negative fallback
input; it never turns pending consent into acceptance, while an already accepted
host can continue in non-interactive mode.
API/platform/build-tools and the emulator image use centralized Android 36
coordinates. `sdkmanager --licenses` remains explicit. Non-interactive runs
report pending and never pre-answer them. pnpm's configured global bin directory (the `bin` subdirectory of
`PNPM_HOME` on pnpm v11) is created, added to the user `PATH`, and checked with
`pnpm --version` before the installer reports success. Already-installed Codex,
Claude Code, OpenCode and Kilo receive bounded MCP preparation. OpenCode v2 uses
`mcp.servers`; Kilo prefers `kilo` and detects legacy `kilocode`. Existing
JSON/JSONC remains byte-identical and pending if no proven native edit is safe.
The installer stores no credentials or initiates authentication.
After the Android CLI preparation, one grouped Windows IDE proposal lists only
missing outcomes. `Google.AndroidStudio` provides the current Android IDE and the
Firebase Device Streaming entry point. `Microsoft.VisualStudio.2022.Community`
is installed with `Microsoft.VisualStudio.Workload.NativeDesktop` and recommended
components so Flutter can compile Windows desktop apps. Detection uses the real
`studio64.exe` and `vswhere` workload evidence; a complete rerun skips the prompt,
while a partial Visual Studio installation is repaired through the official
installer. The flow is bounded, keeps installer progress visible, passes
`--norestart`, and never infers consent in non-interactive execution. It never
starts Firebase authentication, selects a Firebase project, changes billing, or
reserves a remote device; `%USERPROFILE%\.shipglows\environment.md` records that
Device Streaming remains pending until the operator completes those steps inside
Android Studio.
The installer exposes npm, npx, Corepack, pnpm and selected coding agents
through `.cmd` wrappers in the ShipGlows runtime and moves that runtime to the
front of the active process `PATH`. User-scoped blocked `.ps1` shims beside a
verified `.cmd` launcher are preserved under a `shipglows-disabled` backup
name, so pnpm and agent command names remain usable without weakening the
execution policy.
The GitHub repository picker lists repositories accessible to the authenticated
account and explicitly clones the selected repository's HTTPS URL. It therefore
does not inherit a separate GitHub CLI preference for SSH or depend on a local
SSH configuration; GitHub CLI still owns authentication and credential storage,
and configures Git's HTTPS credential helper before each picker clone.
If a repository is outside the Windows DevServer's supported Astro, Python, and
Flutter Web project kinds, cloning still succeeds and is kept in the workspace;
the CLI reports that registration was skipped rather than removing the clone.
The Windows launcher resolves only shortcut paths with a native equivalent:
dashboard (`s d`), interactive start (`s e`), restart/stop/stop-all/logs under
`s m ...`, and project navigation (`s m n`). Navigation opens a child
PowerShell in the selected discovered or registered project because a subprocess cannot
change the parent shell's working directory; `exit` returns to the original
shell. Unsupported Linux server paths fail with guidance instead of being
silently remapped.
The explicit `s u` / `s update` path downloads the public Windows bootstrap
over HTTPS, validates its PowerShell syntax, and runs full mode against the
canonical local ShipGlows directory. This is the supported refresh path; the
already-installed `cli/windows/install-devserver.ps1` only copies its current
local source and must not be treated as a network updater.

### Development environment and project URL

The Windows full installer writes `%USERPROFILE%\.shipglows\environment.md`.
It records the stable host facts: Windows, PowerShell, Codex CLI installation,
Python, Flutter/Dart, Android toolchain/license/device readiness, emulator package,
named-AVD and acceleration readiness, the next Android action when setup is pending, Playwright
configuration, Android Studio, Flutter Windows C++ readiness, Firebase Device
Streaming state and the native ShipGlows DevServer. The installer also
maintains a bounded `~/.codex/AGENTS.md` block that points agents to this file
without wrapping the Codex command. That block also enforces explicit
post-message approval before intentional mutations: a one- or two-sentence fast
validation is available only for exact local routine readily reversible actions
that satisfy every no-harm criterion; other actions use the full plan, and
`git push` is always full-plan-only.

For each registered project, the Windows CLI maintains a bounded ShipGlows block
inside the visible, versioned `<project-root>\ENVIRONMENT.md`. It preserves any
existing project content and records the manager, durable assigned port and
canonical loopback URL. The Windows registry remains authoritative for live
status, so start and stop do not create tracked-document churn. `s open` uses
the active registry entry instead of guessing from repository scripts.

The installer migrates every registered project. It removes only the former
ShipGlows-managed `.shipglows/server.env` file and its exact `.git/info/exclude`
entry; unrelated hidden files and Git exclusions remain untouched.

For a Windows managed start, port precedence is exactly:

`requested port > process SHIPGLOWS_ENV_PORT > project .shipglows.env > persistent registry > first free 3000..3100`

The precedence method is shared; the resulting number is project-specific. A
port declared in `package.json`, Astro, or Vite is a direct-launch fallback, not
the URL of the ShipGlows-managed server. `.shipglows.env` remains the separate
optional committed runtime policy file. ChatGPT apps/connectors and Codex CLI
tools remain separate surfaces. Current-turn authority includes both directly
exposed tools and host-provided deferred/searchable catalogs; a configured tool
is not declared unavailable from the first visible list alone. `$shipglows context` reads the global document, project document and
registry in read-only mode and never launches a fallback server.
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
  mutable service state under the operator's `~/.shipglows/state/caddy`, refresh
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
