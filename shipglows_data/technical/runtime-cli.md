---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "1.37.0"
project: ShipGlows
created: "2026-05-01"
updated: "2026-09-04"
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
  - cli/environment/core.py
  - cli/environment/mise_backend.py
  - cli/environment/shipglows_environment.py
  - cli/environment/schemas/shipglows-environment-v1.schema.json
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
  - "Native Windows focused-launcher replay 2026-09-04: `shipglows.cmd` enters the managed PowerShell runtime directly or through an explicit secure bootstrap route, and the compatibility form `shipglows update runtime` normalizes to the canonical updater without locking `s.exe`."
  - "Native Windows toolbox replay 2026-09-01: machine-owned mise configuration emits a windows-x64 lock policy and the installer refreshes mise.lock after exact-version convergence."
  - "Native Windows capability snapshot 2026-08-30: the DevServer publishes the closed CLI contract for direct read-only conversational discovery and the runner."
  - "Windows managed-tool update contract 2026-08-30: ShipGlows separates runtime self-update from read-only global tool status and explicitly confirmed allowlisted developer-tool convergence."
  - "Unified update replay 2026-08-28: `shipglows update` selects the stable or linked channel, `s update status` reports the active Windows source, and a dirty linked worktree refuses bootstrap without stashing."
  - "Installed ToolGlows replay 2026-08-28: managed process identity compares UTC instants across Windows PowerShell string and PowerShell 7 DateTime JSON representations, so live projects no longer reconcile to stopped immediately after Start."
  - "Guided Windows project experience 2026-08-28: help, registration, status, dashboard, start and open describe websites, Flutter apps and CRXJS Chrome extensions with exact next actions instead of exposing internal project kinds."
  - "Installed-runtime replay 2026-08-27: registered projects are re-registered through the current detector before environment migration, preventing stale registry kinds after a new adapter is installed."
  - "Native Windows browser-extension adapter 2026-08-27: CRXJS projects with an explicit dev:chrome script use extension-specific package-manager, launch, readiness, environment and open contracts instead of generic Vite assumptions."
  - "Linux pressure rescue 2026-08-26: Health combines available RAM, swap use and optional Linux PSI, renders a critical recovery route, and can stop only revalidated confirmed Vercel CLI groups that are detached, heavy, old and free of protected processes."
  - "Native Windows Doppler boundary 2026-08-26: the installer provisions and reports the CLI for agents, while automatic DevServer secret injection remains disabled until a project-specific dev/staging contract is declared and proven."
  - "CommandGlows onboarding audit 2026-08-26: a cloned repository is preserved when registration fails, but the Windows clone command now exits with an explicit preparation failure instead of reporting command success."
  - "CLI/SaaS capability snapshot 2026-08-24: the CLI emits a bounded, closed, read-only JSON capability inventory for the runner without exposing commands, arguments, paths, ports, secrets, or credentials."
  - "Linux memory monitoring 2026-08-20: available-RAM severity now scales at 20% warning and 10% critical, preserves severity through the menu cache, and reports missing swap independently."
  - "Linux clone/start separation 2026-08-19: clone catalogues bounded surfaces as uninitialized without Flox, dependency, picker, or PM2 side effects; first explicit start initializes only the selected surface."
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
  - "Native Windows clone flow installs Git and GitHub CLI, delegates browser authentication and credentials to gh, and exposes a searchable private/public repository chooser that excludes repositories already installed in the workspace."
  - "The private-data control plane reports only redacted availability, validates a declared namespace capability, and requires an explicit clean-repository sync action."
  - "Private-data compatibility replay 2026-08-28: legacy repositories are detected and explicitly migratable, future schemas fail closed, existing clean clones can be adopted, and tracked paths are checked for Windows portability."
  - "Native Windows full resolves and validates Flutter/Dart, JDK 17 and Android command-line tools in user scope; Android terms and SDK licenses remain explicitly user-confirmed, with non-interactive runs pending."
  - "Native Windows full detects Tauri Android projects, offers exact Rust/Android targets through an isolated mise environment and the validated NDK through sdkmanager, and records older projects as migration-required without mutating them; its cargo, rustc and rustup wrappers reproduce the same isolation without mutating global mise trust."
  - "The first live Tauri Windows update exposed ambiguous provider exits, mojibake Flutter diagnostics, serialized Codex MCP path comparison, and invisible prompt gaps; regression coverage now makes final observation authoritative and renders phases plus input waits explicitly."
  - "Native Windows full migrates away the obsolete managed PowerShell profile function because PATH-backed .cmd launchers work even when profile scripts are disabled."
  - "Native Windows full installs Dart/Flutter and exact-version Playwright at machine scope, then generates agent-native MCP activation only inside registered ShipGlows project surfaces; ordinary installs preserve divergent local files, while the owner-only maintainer surface may converge recorded files and remove former ShipGlows global entries."
  - "Native Windows full permanently installs trusted WinGet mise plus Google Cloud and Doppler CLIs, owns an isolated exact-version machine toolbox for Firebase, Supabase, Convex, Vercel, Clerk and Auth0, keeps FlutterFire under Dart Pub, and uses project detection for MCP activation plus presence-only provider reporting."
  - "The Windows MCP allowlist records official discovery authority separately from execution trust; Google Cloud stays catalog-only and Supabase defaults to its official read-only remote endpoint."
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
  - "The environment control-plane foundation exposes strict inspect/plan/verify/status commands in source checkouts and refuses apply until an executable backend exists."
  - "The Windows pilot executes only approval-digest-bound jdx.mise acquisition or locked project-local Node 24 and pnpm 10 operations through fixed structured argv; the Best Fried Chicken smoke proved the real provider cycle."
  - "Independent Task 5 verification binds canonical external mise/WinGet executable paths and SHA-256 identities into approved plans, revalidates them before runner use, and treats those hashes as approved identity evidence rather than official provenance."
  - "Project-local .shipglows.env settings pin runtime ports and can disable automatic restart recovery."
  - "The project runtime policy file now has a closed, data-only schema so unknown settings fail loudly instead of silently restoring defaults."
  - "Native Windows exposes one static global development-environment file and one CLI-managed server URL file per project."
  - "Native Windows installed agent instructions now expose two-tier mutation approval with a cumulative fast path and full-plan-only remote push."
  - "Native Windows installed agent instructions now require direct-plus-deferred tool discovery before declaring a configured capability unavailable."
  - "Native Windows project discovery now uses one cached linear catalogue shared by every dashboard and picker, while the registry remains authoritative for live state."
  - "CommunityGlows regression 2026-08-24: Windows infers Node, pnpm, Cargo and Tauri from native manifests, reports Linux-only Flox explicitly, and returns semantic non-ready exit codes."
next_review: "2026-06-01"
next_step: "/sg-docs technical audit runtime-cli"
---

# Runtime CLI

## Windows host contract

`s.cmd` and `shipglows-dev.cmd` invoke Windows PowerShell 5.1 only to run `ShipGlows.PowerShellBootstrap.ps1`. Normal CLI logic then runs exclusively under ShipGlows-managed PowerShell 7.6.5 Core x64. Direct Desktop execution and an unmanaged PowerShell Core process are refused. `SHIPGLOWS_MANAGED_PWSH` contains the exact absolute executable reused by child PowerShell work; the `PATH` is not consulted for `pwsh`. The separate collision-safe `shipglows.cmd` also enters that exact managed runtime before routing focused commands through `shipglows.ps1`; when the managed runtime is missing, its bootstrap fallback uses the explicit focused-launcher route instead of bypassing command validation. This surface owns `shipglows rename rio <name>`, `shipglows update`, `shipglows update status`, and the compatibility spelling `shipglows update runtime`, which normalizes to the canonical update action. The Rio rename path validates the title and emits exactly one UTF-8 OSC title sequence for the current terminal tab without reading Codex state.

`-Offline` is a strict no-network mode: it reuses a valid managed runtime and fails actionably when the coordinate is absent or corrupt. The portable runtime is private to `.shipglows` and does not replace Windows PowerShell or add PowerShell 7 to the user/system `PATH`.

## Purpose

This doc covers both runtime backends: the Linux server CLI and the native
Windows local DevServer. It is the first technical doc to read when changing
environment lifecycle, dashboard, project shortcuts, publishing, health,
PM2/Flox/Caddy behavior, or native Windows process and installer behavior.

## Environment control-plane foundation

Post-clone preparation adds s env prepare for bounded, deterministic diagnosis and s env prepare-apply with an exact plan digest. Apply may exclusively create a missing shipglows.environment.json; it never replaces project manifests, lockfiles, .env, secrets, or an existing ShipGlows manifest.

The native Windows provider toolbox is a machine-owned mise project, separate
from registered repositories. Its exact Firebase, Supabase, Convex, Vercel,
Clerk and Auth0 coordinates are installed first, then `mise lock --platform
windows-x64` refreshes its own integrity lock. Failure to refresh the lock is
reported without weakening the exact pins or modifying any project lockfile.

Windows clone runs the read-only diagnosis after registration. It reports healthy, safely repairable, blocking, or manual state and prints the digest-gated apply command when repair is possible; clone never applies that plan automatically.

The source CLI exposes one dependency-light contract on Unix and Windows:

```text
sg env inspect [--project PATH]
sg env plan [--project PATH]
sg env verify [--project PATH]
sg env status [--project PATH]
sg env apply [--project PATH] [--plan-digest DIGEST]
```

The managed PowerShell frontend accepts the equivalent form `s env <command> -ProjectPath PATH -PlanDigest DIGEST`. On Windows it is reachable only through the installed bootstrap and managed Core runtime; source tests may exercise the Python control plane directly but that is not proof of the installed `s env` adapter. Live adapter proof is required after runtime installation. The frontend dispatches before DevServer initialization, so inspection does not create a workspace, registry, setup marker, or menu cache. The Unix entrypoint likewise dispatches before legacy prerequisite checks.

- `inspect` validates and normalizes sources, then resolves PATH presence only for the fixed trusted probe registry. It launches no tool process, performs no network or state write, and disables Python bytecode generation for the source CLI path. Unknown repository capability names remain `unknown` and are never resolved or executed.
- `plan` returns stable operation ordering and a SHA-256 digest over source, platform, architecture, ownership and declared effects. Outside the exact pilot it marks every operation non-executable. For an explicit Windows Node 24 plus pnpm 10/mise contract it performs bounded read-only backend/version observations through the structured runner, distinguishes the official `jdx.mise` acquisition from project-tool installation, and never combines acquisition with tool installation in one approval.
- `verify` may run five-second structured `--version` probes only for the fixed trusted tool registry. The mise pilot first requires `mise --locked which <tool>` ownership, then probes both the PowerShell consumer and a separate agent-child consumer through `mise --locked exec -- node --version` and `mise --locked exec -- pnpm --version`, with every current auto-install setting disabled. It records `mise_project` ownership and exact locked/observed versions without putting a full executable path in the Markdown attestation. Verify then atomically replaces the record under `%LOCALAPPDATA%\ShipGlows\Environment` on Windows or `${XDG_STATE_HOME:-~/.local/state}/shipglows/environment` on Unix. A successful generic probe with no version evidence is `degraded`; unsupported constraints remain `unknown`. Unix state directories/files are forced to `0700`/`0600`; abandoned locks become recoverable after the bounded stale interval. Tests may override the root with `SHIPGLOWS_ENVIRONMENT_STATE_ROOT`.
- `status` reads the last complete record and makes stale evidence `drifted` or `unknown`; corrupt or partial JSON is never trusted.
- `apply` requires an explicit `--plan-digest`; omission or any digest/source/config/lock/backend drift exits with code `3` before mutation. The exact Windows pilot reconstructs only `winget install --id jdx.mise --exact --source winget --disable-interactivity`, `mise --locked install node`, or `mise --locked install pnpm` from adapter semantics. Acquisition is a separate plan and conservatively declares network, download, consent and possible privilege effects. It sets process-local `MISE_SAFE=1`, removes inherited `MISE_*` controls from the child, disables hooks/config environments/all auto-install modes/system-dependency installation, selects only `mise.toml`, fences discovery at the project parent, isolates global/system config, preserves `PATH`, and never executes `pnpm install`, persisted argv, or repository task/hook/template strings. A zero-byte WinGet App Execution Alias is never hashed as executable proof: ShipGlows resolves and binds the registered Desktop App Installer package binary instead. All other capabilities/backends exit `no_active_backend`.

`shipglows.environment.json` is strict JSON using schema ID `shipglows.environment/v1`: duplicate keys, non-finite numbers, unknown fields, unsupported majors, control-character paths, escaping references and symlink escapes fail closed. JSON inputs are capped at 1 MiB, runtime-policy input at 64 KiB, referenced source hashing at 8 MiB and persisted state reads at 4 MiB. `.shipglows.env` remains separate. In addition to `SHIPGLOWS_ENV_PORT` and `SHIPGLOWS_AUTO_REPAIR`, native Windows Flutter accepts the bounded `SHIPGLOWS_FLUTTER_DEVICE=chrome|web-server` and `SHIPGLOWS_DART_DEFINE_FILE=<project-relative-path>` policies.

Without an explicit ShipGlows manifest, Windows also infers Node and pnpm constraints from `package.json#engines.node` and `package.json#packageManager`. A detected `src-tauri/Cargo.toml` or `@tauri-apps/cli` adds Cargo and Tauri requirements; they remain blocked with Rust setup guidance until their toolchain is observable, and no install is started by inspect, plan, verify, or status. A native `.flox/env/manifest.toml` is retained as source evidence but reported incompatible on Windows instead of becoming a capability owner. `verify` and `status` return code `4` for an inferred or explicit project whose observed state is not `ready`; a genuinely unmanaged project remains a valid zero-exit inspection target.

The pilot requires root `mise.toml` to contain only `[tools] node = "24"` and `pnpm = "10"`, rejects alternate local/early mise configuration, and requires `mise.lock` to pin one exact `core:node` entry and one exact `aqua:pnpm/pnpm` entry. Each Windows artifact URL must match the exact version, architecture and official Node or pnpm release authority/path, with a checksum value in the supported format. If `package.json#packageManager` exists, it must equal `pnpm@<exact locked version>`; its absence remains valid because the ShipGlows manifest and mise lock already declare ownership. Injected fixtures remain synthetic; the approved Best Fried Chicken smoke additionally acquired mise 2026.8.2 and converged Node 24.19.0 plus pnpm 10.34.5 from their locked official release coordinates without installing application dependencies. `--offline` maps to `MISE_OFFLINE=1`: already installed exact mise-managed tools are ready, while any missing install blocks because mise documents downloaded archives as an unsupported offline cache and recommends retaining the installs directory. Existing global Node, pnpm and persistent `PATH` remain outside this owner. A `mise.exe` or `winget.exe` resolved from inside the repository or outside the adapter's canonical package-manager roots is never invoked; executable path and SHA-256 identity are approval-bound and revalidated before apply runner use.

Current official authorities checked for this pilot are mise's [Windows installation](https://mise.jdx.dev/installing-mise.html#windows-winget), [`mise exec`](https://mise.jdx.dev/cli/exec.html), [`mise.lock`](https://mise.jdx.dev/dev-tools/mise-lock.html), [direct Node plus pnpm project configuration](https://mise.jdx.dev/demo), [configuration cascade and overrides](https://mise.jdx.dev/configuration.html), [safe mode](https://mise.jdx.dev/continuous-integration.html#running-against-untrusted-config-safe-mode), and [offline/cache settings](https://mise.jdx.dev/configuration/settings.html#offline).

The native Windows full-install contract packages the closed `cli/environment` Python tree and schema under `%USERPROFILE%\.shipglows\runtime\cli\environment`. The installed launcher in `runtime\bin` resolves that path; the source launcher resolves its sibling source tree. Both dispatch `s env` before importing the DevServer module. Bootstrap extraction uses an exact file allowlist, rejects incomplete packages, and validates the installed Python sources/schema before claiming success. The isolated installer proof invokes the installed launcher with `inspect` from an unmanaged temporary project and requires no workspace, registry, menu cache, profile, Android/Flutter installation, authentication or network mutation.

The same full installer packages `ShipGlows.WslTurso.psm1` and the pinned Turso Cloud consumer. WSL and Turso use separate consent and readiness gates; Turso requires initialized Ubuntu, uses fixed argv and verified archives, and leaves authentication user-owned.

## Owned Files

| Path | Role | Edit notes |
| --- | --- | --- |
| `cli/shipglows.sh` | Thin CLI entrypoint that sources runtime and menu files, then calls `main` | Keep thin; do not move business logic here |
| `cli/lib.sh` | Main orchestration library for UI, validation, PM2/Flox/Caddy operations, health, deploy, publish, and actions | High blast radius; prefer focused changes and syntax checks |
| `cli/shipglows_devserver_gum.sh`, `cli/shipglows_devserver_bash.sh` | Menu frontends that render the root menu and grouped submenus | Keep frontend behavior equivalent; update both variants together |
| `cli/windows/install-devserver.ps1`, `cli/windows/shipglows-devserver.ps1`, `cli/windows/shipglows.ps1` | Native Windows dependency bootstrap, DevServer frontend, and focused ShipGlows commands | Install the pinned checksum-verified Gum binary into the user runtime, prefer it for interactive choices, preserve the plain PowerShell fallback, and keep `rename rio` isolated from Codex state |
| `cli/config.sh` | Central configuration defaults and validation | Keep defaults explicit and validation actionable |
| `cli/windows/ShipGlows.DevServer.psm1` | Native Windows project detection, registry, process lifecycle, ports, and logs | Execute only in managed PowerShell 7 Core; never evaluate project input as code |
| `cli/windows/shipglows-devserver.ps1` | Native Windows dashboard/menu and one-shot actions | Keep menu and one-shot actions aligned |
| `cli/windows/install-devserver.ps1`, `cli/windows/ShipGlows.McpCatalog.json` | Installs the Windows launcher, machine CLI toolbox, and selectively activated MCP definitions | Install Node LTS, pnpm, uv, Flutter, trusted mise, Google Cloud CLI, exact provider CLIs and the Android path idempotently; isolate machine/project/Tauri mise configs; preserve explicit Android license/UAC confirmations and user-owned authentication |
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

The Linux backend separates repository discovery from runtime initialization.
Cloned Git repositories are scanned from native `package.json`, `pubspec.yaml`,
`pyproject.toml`, `requirements.txt`, `Cargo.toml`, or `go.mod` manifests without
creating `.flox`, installing dependencies, opening a picker, or starting PM2.
Each discovered surface enters the registry as `uninitialized`.

An explicit start reuses an owning Flox environment when one exists. Otherwise
it initializes `.flox` in the selected launch surface only, changes that entry
to `stopped`, and continues through dependency setup and PM2 startup. A clone is
therefore never also an implicit start.

A nested directory containing its own `.flox` is an independent environment
boundary. Its subtree is excluded from its parent's launch-target search. Every
bounded monorepo surface is catalogued separately, while an ambiguous root path
is never resolved to one surface alphabetically.

## CLI/SaaS capability snapshot

After a successful Linux project-catalog refresh, the CLI also refreshes
`$SHIPGLOWS_STATE_DIR/cli-capabilities.v1.json`. This snapshot is a bounded,
versioned inventory for the SaaS runner; it is not a remote-command transport.
Its schema is `shipglows.cli-capabilities.v1`, its capability identifiers come
from a closed 30-entry set shared with the runner contract, and every entry has
one of four closed states: `available`, `unavailable`, `degraded`, or `disabled`.

Read-only capabilities derive availability only from already-defined CLI
functions. Authorized actions are advertised as disabled with
`approvalRequired`; operator-only functions are disabled with `operatorOnly`.
The document contains no command, argument, path, port, secret, or credential
payload. Generation rejects unknown or duplicate identifiers, invalid states,
invalid reason codes, and output beyond
`SHIPGLOWS_CLI_CAPABILITIES_MAX_BYTES` (64 KiB by default). It writes a private
candidate in the state directory, atomically replaces the published snapshot,
and preserves the previous valid snapshot if generation fails.

The native Windows CLI publishes the same schema at
`%LOCALAPPDATA%\ShipGlows\DevServer\cli-capabilities.v1.json`, or at the
absolute `SHIPGLOWS_CLI_CAPABILITIES_FILE` override. Every bounded CLI launch
refreshes it atomically before dispatch, and `s capabilities` prints the
validated snapshot. Agent conversations read the file directly through the
runtime-awareness contract; they do not start the CLI. The Windows inventory
uses the same 30 identifiers and marks unsupported Windows behaviors with the
stable `unsupportedWindows` reason code.

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
Astro, Vite, browser extensions, Python/FastAPI, and Flutter Web. Repositories are constrained to the
configured workspace, ports are allocated from `3000..3100`, and process
identity is checked with PID, start time, executable path, and a command
signature before stopping a process. The JSON registry is written through a
validated temporary file and atomic replacement.

### Guided project experience

The Windows CLI presents supported repositories as user-facing experiences,
not as internal detector kinds:

| Detected surface | Status shown to the user | Start/Open outcome |
| --- | --- | --- |
| Astro, Vite, or Python/FastAPI | `Web project` and `URL :<port>` | Start prepares the local server; Open launches its loopback URL. |
| Flutter Web | `Flutter app` and `App :<port>` | Start prepares the managed headless session; Open switches to the visible managed Chrome session. |
| CRXJS Chrome extension | `Chrome extension`, `HMR :<port>`, and `dist\chrome` | Start prepares Manifest V3 plus HMR; Open launches `chrome://extensions` and the unpacked output folder. |

`s help`, `s status`, the dashboard, the picker and post-registration output
share those terms. Clone and manual registration end with the exact next
command. The complete non-interactive lifecycle is
`s start -ProjectPath <path>`, `s status -ProjectPath <path>`,
`s open -ProjectPath <path>`, then `s stop -ProjectPath <path>`.
The interactive menu exposes the same actions, including `Open / load project`.
If Open targets a stopped project, it identifies the selected experience and
returns the exact Start command instead of reporting an ambiguous missing URL.

An extension's reserved port belongs to the Vite/CRXJS hot-module-reload
channel; it is not a website URL. After Open, the operator still enables
Developer mode, chooses Load unpacked, and selects `dist\chrome`. ShipGlows
opens the relevant tools but never silently installs an extension into a
personal Chrome profile. Current automatic detection is deliberately bounded
to a declared `@crxjs/vite-plugin` dependency plus an explicit `dev:chrome`
script; unsupported extension stacks are not presented as automatically
managed.

The native Windows backend does not activate, parse, or derive project
boundaries from Flox. It discovers supported applications from native manifests
such as `package.json`, `pubspec.yaml`, `pyproject.toml`, and
`requirements.txt`, including nested monorepo launch paths. `.flox` has no
effect on Windows dependencies, variables, launch commands, ports, or project
identity.

Dependency setup passes native package-manager arguments as explicit string arrays: `package-lock.json` and `npm-shrinkwrap.json` select the single `ci` token, while projects without an npm lock use `install`. A pnpm lockfile keeps pnpm, and an exact `packageManager: pnpm@x.y.z` declaration is executed through Corepack so ShipGlows does not substitute its machine-wide pnpm version. A versioned per-project state below the DevServer runtime records an invariant digest of relevant manifests, lockfiles, exact manager, arguments and artifact strategy only after the package manager succeeds, the expected framework package plus manager/Python/Dart artifacts exist, and the inputs still match their pre-install digest. A bounded interprocess lock serializes setup; the previous state is invalidated before a required attempt, so an unsupported schema, changed execution plan, moving inputs, missing artifacts, or a failed/partial attempt cannot be reused.

A Node surface is classified as `browser-extension` before generic Vite only
when it declares `@crxjs/vite-plugin` and an explicit `dev:chrome` script.
Start runs that script with ShipGlows' reserved loopback HMR port. Readiness
requires the managed process, its listener, and a fresh valid Manifest V3 under
`dist/chrome`; an old package
or an HTTP response alone cannot mark the extension running. Open launches the
browser extension manager beside the generated unpacked directory and never
silently installs into a personal browser profile.

During a full Windows runtime installation, every still-present registered
project is re-registered through the current detector before its managed
environment block is rewritten. This keeps registry kind, launch metadata and
`ENVIRONMENT.md` aligned when a newly installed ShipGlows version introduces a
more specific project kind such as `browser-extension`.

Managed Windows servers are created through `Win32_Process.Create`, outside the one-shot CLI process handle tree, so a caller capturing stdout/stderr receives EOF after readiness. Before launching a child, the WMI wrapper creates a named Windows Job Object with `KILL_ON_JOB_CLOSE`, assigns itself, and fails closed if either operation fails; Node, Astro, Python, Flutter and their descendants therefore share a durable termination boundary. After its direct command exits, the wrapper remains alive while another job member exists, including a Node child created with detached spawn and `unref`. Detached and Flutter wrappers use only the exact absolute `SHIPGLOWS_MANAGED_PWSH` executable already validated by the bootstrap; they never accept `powershell.exe`, discover `pwsh.exe` through `PATH`, or fall back to System32. The registry stores the wrapper PID, command-line fragment and Job Object identity. Readiness requires both verified wrapper identity and the service probe. Stop terminates the exact job (or the verified legacy tree), then marks `stopped` only after both process identity and the assigned listener have disappeared; unproved extinction preserves the live registry state and returns an error. The Flutter supervisor token is read by that wrapper from its existing owner-only token file and is never embedded in the encoded command.

All Windows menus consume the same catalogue produced by one linear workspace
scan. The discovery index is cached in memory and atomically at
`%LOCALAPPDATA%\ShipGlows\DevServer\project-index.json` with its schema,
workspace, scanner version, and generation time. A structurally valid older
index is displayed immediately; in the interactive menu, an index older than
five minutes is rebuilt by a background job that also reconciles live process
state, then adopted on the next dashboard render. The first render therefore
uses the last registry snapshot without waiting on WMI/CIM; lifecycle actions
still revalidate the selected process before mutation. Explicit refresh remains
synchronous. Clone/register/unregister retain
the last usable index and mark it stale instead of forcing a blocking rescan.
Generation timestamps are invariant round-trip `DateTimeOffset` values under
Windows PowerShell 5.1 and managed PowerShell Core, regardless of active locale.
Invalid schema, scanner, workspace, timestamp, or JSON fails closed and triggers
an atomic synchronous rebuild because its identities cannot be trusted. Registry
entries win when discovery and runtime state overlap, so the registry remains
the authority for status, ports, logs, and process identity.

The entrypoint dispatches `help`, `exit`, and environment-control commands
before normal DevServer initialization. Authentication and GitHub/update tools
are resolved only when their actions are entered; the Windows menu does not
load the mobile installer module.

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
`pnpm --version` before the installer reports success. Missing Codex, Claude
Code, OpenCode, Kilo and Gemini CLIs are offered once as a grouped interactive
exact-version installation; authentication is never started. Installed agents receive bounded MCP preparation. OpenCode v2 uses
`mcp.servers`; Kilo prefers `kilo` and detects legacy `kilocode`. Existing
JSON/JSONC remains byte-identical and pending if no proven native edit is safe.
The installer stores no credentials or initiates authentication. Every full
install prepares exact Firebase, Convex, Vercel, Supabase and Clerk CLIs in an
isolated machine `mise` toolbox, FlutterFire through Dart Pub, and Google Cloud
CLI through WinGet. Bounded project detection writes agent-native project
configuration and activates only matching Dart, Playwright, official Firebase,
Convex, Clerk, read-only Supabase, Vercel and read-only GitHub MCP entrypoints.
The generated machine-specific files are kept outside commits through each
repository's local Git exclude file. Google Cloud MCPs remain catalog-only until
explicitly selected. `gh` remains the sole GitHub credential owner. Neither Clerk nor GitHub authentication,
project linking, SDK injection or secret retrieval is started. The environment
report records installed and ready/pending MCP state separately for each agent.
Developer Mode remains read-only; the installer can only offer to open the
official Windows settings surface.
The interactive Windows runtime adds `s a` and a root **Authentication** entry.
It reports only redacted states and delegates connect/reconnect/logout to each
official CLI; logout is confirmed, Gemini owns its interactive flow, and Convex
is labelled project-scoped. Credentials and provider output are never copied to
ShipGlows state. Full installation owns one exact user-scope `playwright`
package outside projects, verifies its declared Chromium revision, and exposes
both `playwright` and its bundled `playwright cli` entrypoint through runtime
PATH wrappers.
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
account, normalizes local HTTPS/SSH origins to case-insensitive `owner/repository`
identities, and removes already installed repositories before rendering. Multiple
runnable surfaces in one monorepo therefore hide one repository exactly once, and
a successful clone disappears from the next picker immediately. The picker explicitly
clones the selected repository's HTTPS URL. It therefore
does not inherit a separate GitHub CLI preference for SSH or depend on a local
SSH configuration; GitHub CLI still owns authentication and credential storage,
and configures Git's HTTPS credential helper before each picker clone.
If a repository is outside the Windows DevServer's supported Astro, Vite,
browser-extension, Python, and Flutter Web project kinds, cloning still succeeds and is kept in the workspace;
the CLI keeps the clone, reports the preparation failure, and exits non-zero
rather than removing the clone or presenting the combined clone-and-register
operation as successful.
The Windows launcher resolves only shortcut paths with a native equivalent:
dashboard (`s d`), interactive start (`s e`), restart/stop/stop-all/logs under
`s m ...`, and project navigation (`s m n`). Navigation opens a child
PowerShell in the selected discovered or registered project because a subprocess cannot
change the parent shell's working directory; `exit` returns to the original
shell. Unsupported Linux server paths fail with guidance instead of being
silently remapped.

## Explicit private-data control plane

`shipglows private-data status` and `doctor` (or the Windows `s private-data`
equivalent) expose only whether the durable private repository is configured,
available, clean, and manifest-valid. They never print its path, remote, Git
identity, filenames, or content. `capability <namespace> <read|write>` verifies
that an explicit request matches a declared namespace in the private repository's
data-only manifest; it does not read the namespace itself. `connect --repo` and
`open` are dry plans until `--apply`: connection accepts only an explicit
credential-free HTTPS or SSH URL, can adopt a matching clean existing clone,
and persists configuration only after validation, while opening invokes the
local file manager without printing the path. A repository without a manifest
is diagnosed as legacy and requires an explicit `migrate --manifest ...
--apply`; malformed or unknown future schemas fail closed. Doctor also rejects
tracked paths that are not portable to Windows. `sync <pull|push>` is a dry plan unless `--apply` is present, then refuses
a dirty repository or missing upstream and uses only fast-forward pull or
ordinary push. None of these commands is run by installation, startup, generic
context discovery, or a skill without an explicit private-data request.
The explicit Windows DevServer `s u` / `s update` path downloads the public
bootstrap over HTTPS for the stable channel, or selects the checked clean
upstream branch of a linked developer checkout. `shipglows update` is the
cross-platform canonical entrypoint and `shipglows update status` is read-only;
on Unix `s u` remains the system-package update action. On Windows, dirty linked
checkouts fail closed with a focused inspection and retry path, and
an interactive update attempt exits the menu instead of redrawing the project
catalog after success or failure. The Windows path resolves
an immutable source commit, stages and validates the full
managed payload, then classifies the target as `install`, `update`, `repair`, or
`no-op`. Activation is serialized per runtime and transactionally replaces only
the paths recorded in the mode-scoped `.shipglows-runtime-files.<mode>.json`; a child-installer failure
restores the previous managed files and directory tree byte-for-byte. The
rollback does not reverse third-party package-manager side effects that completed
before a later failure. Existing valid external SDKs and tools remain owned by
the user. Interactive full mode makes one grouped proposal for missing or
version-drifted coding-agent CLIs, installs only accepted exact versions, and
never infers upgrade consent in non-interactive mode. This is the supported
refresh path; the already-installed `cli/windows/install-devserver.ps1` only
copies its current local source and must not be treated as a network updater.

Windows exposes a separate global developer-tool surface through
`shipglows tools status|update` and `s tools status|update`. Status is read-only:
it shows the declared ShipGlows-owned scope, asks WinGet for its available
upgrade preview, and compares installed npm/pnpm versions with exact stable
registry coordinates. Update requires an interactive confirmation and invokes
the already-installed full convergence engine without downloading or switching
the ShipGlows source channel. WinGet mutations are restricted to the exact
allowlist for Git, GitHub CLI, Node LTS, mise, uv, Google Cloud CLI, and Doppler;
npm and pnpm targets are resolved and installed as exact registry versions.
Normal convergence then repairs and verifies managed wrappers, coding agents,
service CLIs, Playwright, MCP configuration, and the environment report. The
route never uses `winget upgrade --all` and never changes project manifests,
lockfiles, dependencies, `node_modules`, credentials, SDK licences, IDEs,
Windows Update, or restart policy.

On Windows, the DevServer header immediately renders the cached ShipGlows
runtime status and refreshes it asynchronously at most once per six hours.
`shipglows-version.json` is the canonical SemVer release coordinate; the
installer records it with the immutable source commit. Green means current,
orange means a patch or linked-source update is available, and red means a
minor or major release was missed. A failed network check preserves the last
valid cache and never blocks the menu; an available update points to `s update`.

The native full installer composes a UI-free operation engine with a console
adapter. The engine emits stable started/progress/completed/failed/timed-out
events and never reads input, writes host output, chooses colors, or invokes an
interactive selector. It also emits phase and awaiting-input transitions. The
console adapter owns consent prompts, renders the current phase immediately,
prints an explicit input-wait state, and renders a time-aware spinner for captured long-running work; redirected/non-interactive
output receives deterministic start and terminal lines without animation.
Phase timing is suspended across the input boundary and resumes only after the
console reports that an answer was received, so elapsed time never includes a
human consent pause.
Quick probes remain silent, while agent/service CLI installs, captured MCP
configuration, Flutter/Android preparation, Playwright packages and browser
preparation use the visible operation boundary.
Captured Flutter readiness diagnostics are summarized to the validated
toolchain, licence, and device states when they succeed. On failure, the
console prints only a cleaned, actionable excerpt bounded to three lines and
480 characters; it still reports the failed operation and never silently
converts diagnostic failure into success. Full `flutter doctor -v` and
`flutter devices` output remains captured for evaluation rather than dumped to
the normal installer console.
Provider command exit codes are provisional until bounded final observation:
trusted `mise`, an exact runnable service CLI, native Claude re-read, and decoded
Codex MCP JSON may establish convergence after an ambiguous provider exit.
Trusted mise observation accepts the native autonomous calendar version emitted
by current Windows builds, including output accompanied by separate warnings.

### Development environment and project URL

The Windows full installer writes `%USERPROFILE%\.shipglows\environment.md`.
It records the stable host facts: Windows, PowerShell, Codex CLI installation,
Python, Flutter/Dart, Android toolchain/license/device readiness, emulator package,
named-AVD and acceleration readiness, the next Android action when setup is pending, Playwright
configuration, Android Studio, Flutter Windows C++ readiness, Firebase Device
Streaming state and the native ShipGlows DevServer. The installer also
maintains bounded native instruction blocks for detected agents: Codex
`~/.codex/AGENTS.md`, Claude `~/.claude/CLAUDE.md`, OpenCode
`~/.config/opencode/AGENTS.md`, Kilo `~/.config/kilo/AGENTS.md`, and Gemini
`~/.gemini/GEMINI.md`. Existing
instructions outside the block remain unchanged. The shared block points to this
file, prefers a purpose-built callable tool, checks direct and deferred discovery,
and redirects uncertain capability state to `$shipglows context` instead of
embedding a stale machine-specific tool list. It does not wrap agent commands.
That block treats a clear bounded request as authority for its few coherent
enumerable actions and targets when the agent need not choose a material
direction, never for a chantier. Targeted file modifications, exact-scope
commits, ordinary resolved pushes, and small explicit sequences execute without
another prompt. Local versus remote and model reasoning effort never change the
classification. Bounded agent-proposed actions or almost-clear intent use fast
validation; unknown, unbounded, or materially directional work uses the full
plan. Force push and destructive or irreversible actions retain stricter gates.

For each registered project, the Windows CLI maintains a bounded ShipGlows block
inside the visible, versioned `<project-root>\ENVIRONMENT.md`. It preserves any
existing project content and records the manager, project kind, durable assigned port and
canonical loopback URL. Browser extensions instead record that a normal page URL is not applicable and name their unpacked Chrome directory. The Windows registry remains authoritative for live
status, so start and stop do not create tracked-document churn. `s open` uses
the active registry entry instead of guessing from repository scripts.
For an extension, that managed block also records the complete operator route:
Start, Open, enable Chrome Developer mode, choose Load unpacked, select
`dist\chrome`, then Stop. It repeats that personal-profile installation always
requires an explicit user action.

The managed block carries the explicit schema
`shipglows-project-environment/v2`. An unversioned legacy ShipGlows block is
treated as `legacy/v0` and upgraded automatically on registration, start, or
installer reconciliation; v1 is accepted and upgraded by the same bounded writer. Rewriting v2 is byte-idempotent and preserves all
content outside the managed markers. Unknown future schemas, incomplete
markers, and duplicated blocks fail closed without changing the file.

The installer reconciles every registered project. It removes only the former
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
Native Windows Flutter Web starts through `flutter run --machine -d chrome` in
a ShipGlows-owned headless Chrome profile. Readiness requires matching
`app.start` and `app.started` JSON events; HTTP or TCP availability alone never
marks it running. `s open` restarts that managed Flutter session with visible
Chrome while preserving debug/hot-reload support. The advanced
`SHIPGLOWS_FLUTTER_DEVICE=web-server` policy retains the manual Dart Debug
browser workflow. A bounded per-launch supervisor retains Flutter machine stdin
and stdout after the CLI exits. It records the last protocol event, Flutter exit
code and exit reason, and registry reconciliation requires its `running` state
instead of trusting a live wrapper alone. On Windows desktop, cleanup recognizes
only the exact current-project Debug runner declared by `BINARY_NAME`; transient
debug-connection failures receive one retry only after verified extinction.
The ordinary attachment deadline remains bounded, while an explicit active
Flutter build receives a separate ten-minute ceiling so a healthy cold Windows
compile is not terminated at the ninety-second attachment boundary. Supervisor
death still fails immediately during that extended build window. When the build
finishes, the ordinary attachment deadline starts fresh so a long compile does
not consume the VM Service connection window. Cleanup requires a stable quiet
period and reaps any strictly attributed Windows runner that appears late before
a retry or registry release. It debounces relevant `lib/**/*.dart` changes
for 500 ms and issues the allowlisted `app.restart` request; authenticated local
IPC owns only reload, stop, and open operations. Command resolution prefers the
active process `PATH`, then accepts only the complete non-reparse Flutter/Dart
pair under `%LOCALAPPDATA%\ShipGlows\flutter`; this keeps an already-open agent
usable immediately after the installer persistently updates the user `PATH`.
The Flutter supervisor applies the same stale-process recovery to the persisted
user `CHROME_EXECUTABLE`, then still requires a non-reparse executable below
the managed `%LOCALAPPDATA%\ms-playwright` root.
- `cli/lib.sh::ui_box_header` (deprecated: use `ui_screen_header` or `ui_text_center`): prints fixed-width boxed CLI headers so left and
  right borders stay aligned across dashboard, logs, health, and success blocks.
- `cli/lib.sh::env_start`, `env_stop`, `env_restart`, `env_remove`: core environment lifecycle.
- A project may commit a data-only runtime policy file named `.shipglows.env`.
  Its closed schema accepts blank lines, comments, and only
  `SHIPGLOWS_ENV_PORT=<1024-65535>` and `SHIPGLOWS_AUTO_REPAIR=true|false`.
  Native Windows Flutter additionally accepts
  `SHIPGLOWS_FLUTTER_DEVICE=chrome|web-server` and a project-contained existing
  `SHIPGLOWS_DART_DEFINE_FILE=<relative-path>`. ShipGlows passes only that path
  to `--dart-define-from-file`; it does not copy referenced values to logs.
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
- `cli/lib.sh::deploy_github_project`: clones and synchronizes every bounded
  runnable surface into the Linux registry as `uninitialized`, then returns.
  It creates no Flox state, installs no dependencies, opens no launch picker,
  and starts no PM2 process, matching the native Windows clone contract. An
  existing destination is refused and left unchanged.
- `cli/lib.sh::action_reboot_vm`: explicit confirmed VM reboot action from the
  system menu. It supports `SHIPGLOWS_REBOOT_DRY_RUN=1` for smoke checks.
- `cli/lib.sh::mcp_cleanup_menu`: health-menu cleanup for local MCP process
  groups. It lists provider/RAM/uptime/parent Codex evidence and stops only a
  confirmed process group.
- `cli/lib.sh::action_health`: renders the system monitor with RAM, disk, swap,
  process, and PM2 health first, then uses explicit one-key actions for cleanup
  commands. It must not route destructive cleanup options through
  searchable/default-select menus. Available RAM is healthy at or above 20%,
  warning below 20%, and critical below 10%; those levels remain distinct in
  the menu cache and header. The combined system level also warns at 80% swap
  use or sustained PSI memory `some` pressure, and becomes critical when PSI
  `full` reaches 10% or when swap reaches 90% while available RAM is already
  below 20%. Swap use alone never becomes a critical incident because Linux
  may retain inactive pages there after pressure has cleared. PSI is optional:
  kernels without `/proc/pressure/memory` retain the RAM/swap classification.
  `SHIPGLOWS_MEM_*`, `SHIPGLOWS_SWAP_*`, and `SHIPGLOWS_MEM_PSI_*` configure
  validated thresholds. The legacy `SHIPGLOWS_MEM_WARN_GB` applies only when
  explicitly set. Missing swap remains a separate capacity-risk warning.
- `cli/lib.sh::emergency_process_rescue_menu`: the `e` Health action lists only
  same-user Vercel CLI groups whose candidate process has PPID 1, no TTY, at
  least 100 MB RSS, and at least two minutes of age. Every member of the group
  is re-read before signaling; an unknown signature, another user, any TTY, or
  a shell, Codex, SSH, tmux, systemd, PM2, Caddy, or application process makes
  the whole group ineligible. Display output contains provider, IDs, RSS and
  age but never full arguments. The operator selects one group and confirms
  `SIGTERM`; a surviving group requires a separate confirmation for `SIGKILL`.
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
- Native Windows reports Doppler CLI readiness and presence-only project
  declaration, but does not automatically wrap DevServer commands with
  `doppler run`. Agents may use that boundary only for an explicit project-owned
  command and an unambiguous development or staging scope; production and
  implicit project/config selection remain separately authorized.
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
- Emergency process rescue must fail closed when a PID/PGID disappears,
  changes identity, gains a TTY, contains an unrecognized process, or no longer
  satisfies its same-user orphan signature. It must never generalize PPID 1
  into permission to stop arbitrary daemons or application services.
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
- Process arguments may be inspected only for a closed rescue signature; they
  must not be displayed, cached, logged, or persisted because they can contain
  private targets or credentials.
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
