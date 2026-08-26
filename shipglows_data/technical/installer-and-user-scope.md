---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "2.26.0"
project: ShipGlows
created: "2026-05-01"
updated: "2026-08-26"
status: reviewed
source_skill: sg-start
scope: installer-and-user-scope
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - cli/install.sh
  - cli/windows/install-devserver.ps1
  - install-shipglows.ps1
  - README.md
  - local/install.sh
  - skills/references/windows-bootstrap-development-workflow.md
depends_on:
  - artifact: "README.md"
    artifact_version: "0.1.0"
    required_status: draft
  - artifact: "shipglows_data/technical/guidelines.md"
    artifact_version: "1.2.0"
    required_status: reviewed
supersedes: []
evidence:
  - "The 2026-08-26 native Windows installer provisions Doppler through its official WinGet package, requires executable version evidence, exposes a stable wrapper and redacted auth state, and never logs in, selects a project/config, or reads secrets."
  - "The 2026-08-26 native Windows toolbox adds the official Auth0 CLI through an exact stable mise/Aqua coordinate, keeps authentication operator-owned, disables CLI analytics inside only its wrapper, and preserves unrelated provider tooling when Auth0 resolution is pending."
  - "The 2026-08-26 native Windows payload includes the latest-build artifact module and profile-independent command without downloading artifacts or creating shortcuts during installation."
  - "The 2026-08-25 documentation correction aligns the official GitHub MCP with the project-local activation contract; the machine-wide installer does not enable it globally."
  - "The 2026-08-25 Windows bootstrap accepts a strict complete commit SHA directly and still resolves branch or tag names through GitHub's commit API, avoiding redundant anonymous API quota use while keeping immutable archive pinning."
  - "README installer section and cli/install.sh function inventory."
  - "The 2026-08-23 native Windows maintainer surface validates the Git origin, removes the conflicting public plugin through Codex, and verifies live skill junctions to the owner checkout without allowing all/components to escalate into that channel."
  - "The 2026-08-13 runtime documentation audit aligned the active Codex skill scope with ~/.agents/skills and added a check-before-repair Windows diagnostic."
  - "PM2 boot autostart removed from default installer contract."
  - "Turso SSH helper command wrapper added to installer-managed global commands."
  - "Turso remote login helper command wrapper added."
  - "Remote Agents menu includes Turso guidance while local menu owns the SSH tunnel flow."
  - "Short remote ShipGlows bootstrap added for clone-free install."
  - "Windows full now uses one grouped consent gate for missing Codex, Claude, OpenCode, Kilo, and Gemini CLIs; each exact version is verified and authentication remains user-owned."
  - "Unified bootstrap modes route Android Termux to local/install.sh without sudo and retain root-only full server installation."
  - "Native Windows full installs Git and GitHub CLI through WinGet, while GitHub CLI exclusively owns browser authentication and credential storage."
  - "Native Windows full installs Node LTS, pnpm, uv and a resolved Flutter commit automatically; valid external Flutter/Dart, JDK 17 and Android SDK installations are reused without replacing their environment ownership."
  - "The 2026-08-23 Flutter convergence repair ensures a validated managed SDK remains on the user and installer-process PATH, while Windows desktop readiness aggregates Flutter/Dart, Visual Studio Desktop C++, and Developer Mode."
  - "The 2026-08-23 reproducible Flutter repair converges only the official clean ShipGlows-managed checkout to the exact Flutter 3.47.1 / Dart 3.13.1 validated baseline on a named local stable branch tracking the pinned origin/shipglows-stable ref, with previous-revision rollback after failed executable validation."
  - "The 2026-08-24 Flutter 3.47 compatibility review records that AGP 8.11.1 and Gradle 8.14 are its inclusive Android floors, that the release prepares the AGP 9 built-in Kotlin transition, and that Windows Application Control trust failures are a separate diagnostic lane."
  - "The 2026-08-23 Flutter Web browser repair exposes the validated managed Playwright Chromium through CHROME_EXECUTABLE before install-time Flutter diagnostics and enforces that managed path again in the Flutter supervisor."
  - "The 2026-08-23 service-CLI convergence repair reuses exact existing FlutterFire and npm-global provider CLIs instead of reinstalling them on every full rerun."
  - "Tauri Android support is project-triggered: one explicit prompt provisions the validated Rust toolchain and Android targets through a ShipGlows-owned isolated mise config and the exact NDK through sdkmanager; runtime Rust wrappers preserve that isolation without changing global mise trust, and project migration is always a separate Codex handoff, never an installer mutation."
  - "Native Windows full configures user-global Playwright MCP only after exact-version resolution and a runnable Chromium executable check in the user cache."
  - "The 2026-08-23 Kilo convergence repair atomically completes only a parseable schema-only placeholder while preserving comments, foreign fields, providers, and secrets byte-for-byte."
  - "The 2026-08-14 capability-discovery repair makes Playwright MCP the enabled default web-QA lane and requires direct-plus-deferred current-turn discovery before an unavailable verdict."
  - "Native Windows full removes ShipGlows's obsolete managed PowerShell profile function, so profile execution-policy errors no longer affect ordinary PowerShell launches."
  - "Native Windows full makes one grouped proposal for missing coding-agent CLIs, installs only accepted tools at exact resolved versions, and leaves authentication to that CLI."
  - "Native Windows update stages and validates the complete managed payload, serializes activation, records managed paths, and restores the previous managed runtime byte-for-byte when activation or the child installer fails."
  - "Native Windows long-running installation work uses a UI-free event engine and a separate console adapter with an interactive loader or deterministic redirected-output lines."
  - "Native Windows phases now render immediately, every prompt publishes explicit awaiting-input/answer-received states, and phase work duration excludes human wait time; final trusted observation can recover from ambiguous WinGet, npm, Claude, or Codex provider exits."
  - "Native Windows interactive mode selection requires an explicit 1, 2, or 0; empty console input never starts an installation."
  - "Native Windows prepares pnpm v11's global bin PATH and explicitly allows only the selected official agent package's install script when npm fallback requires it."
  - "Native Windows places managed .cmd application wrappers before npm-generated .ps1 shims, preserving commands under restrictive execution policy."
  - "Native Windows installs collision-safe .cmd shortcuts for c, co, cor, oc, and kc without depending on the PowerShell profile."
  - "Native Windows overrides PowerShell's reserved gp alias with a guarded add-all, commit, and push workflow; raw gpush remains available without profiles."
  - "Operator decision 2026-08-11: Linux and Windows converge on ~/.shipglows/runtime, with data and design-inspiration-library as sibling private repositories."
  - "Migration audit 2026-08-11: mutable Caddy state moves from the former ~/.shipglows/runtime/caddy location to ~/.shipglows/state/caddy so it cannot collide with the canonical code checkout."
  - "Linux system pnpm CLIs now live under a world-readable ShipGlows prefix, use atomic /usr/local/bin wrappers, and must pass an execution probe before the installer reports success."
  - "Codex Playwright MCP refresh now removes only owned mcp_servers.playwright tables, preserving project trust, marketplace, plugin, notice, and other adjacent configuration across repeated installs."
  - "Linux system pnpm migration now pins both global-dir and global-bin-dir and ignores executable root-private legacy wrappers when deciding whether a managed CLI is installed."
  - "Linux full mode now rejects unsupported distributions before package installation, replaces legacy sg/shipglows symlinks atomically, selects the sparse skills surface from skill-bearing component requests, and propagates user-setup failures instead of printing a false success banner."
  - "The native Windows full-install contract packages the reproducible-environment Python control plane and schema, then exposes it through the profile-independent s launcher."
next_review: "2026-06-01"
next_step: "/sg-docs technical audit installer"
---

# Installer And User Scope

## Portable PowerShell ownership

The full Windows installer owns `%USERPROFILE%\.shipglows\toolchains\powershell`; it acquires only the pinned PowerShell 7.6.5 win-x64 archive from the fixed official GitHub release URL and activates it only after SHA-256 and runtime probes pass. Acquisition is per-user, portable, lock-protected, staged, and rollback-safe. It does not use MSI, WinGet, the registry, or a `PATH` entry for `pwsh`. `DownloadOnly` validates and packages the module, manifest and bootstrap but does not acquire or activate the toolchain.

For native Windows installer development and agent handoff, follow
`skills/references/windows-bootstrap-development-workflow.md`. It defines the
canonical clone/runtime/project layout and the branch-to-bootstrap validation
sequence required before merging installer changes into `main`.

## Purpose

This doc covers `cli/install.sh` and the root/user boundary for ShipGlows setup. Read it before changing system dependencies, global binaries, aliases, skill links, Codex/Claude config, MCP registration, or project-local `shipglows_data` bootstrap behavior.

## Owned Files

| Path | Role | Edit notes |
| --- | --- | --- |
| `cli/install.sh` | Root-level server bootstrap and per-user setup | Preserve idempotence and explicit root-only behavior |
| `tools/shipglows_sync_skills.sh` | Shared Claude/Codex skill symlink sync helper | Reuse instead of duplicating skill-link repair logic |
| `README.md` | Operator install contract | Update when commands, privilege, or installed tooling changes |
| `local/install.sh`, `local/install_local.ps1` | Workstation-side setup | Keep separate from root server install assumptions |
| `install-shipglows.sh` | Canonical remote bootstrap and local/full mode selector | Resolve mode before privilege checks; preserve user home and repository ownership |
| `install-shipglows.ps1` | Canonical Windows mode/surface selector and archive bootstrap | Keep interactive mode explicit and automation deterministic through `-InstallMode` and `-InstallSurface` |
| `cli/windows/install-devserver.ps1` | Native Windows full installer | Keep user-scoped tools, wrappers, PATH changes, prompts, and collision handling idempotent |
| `tools/sync_shipglows_public_bootstrap.sh` | ShipGlows public artifact parity | Keep the generated public shell and PowerShell assets byte-for-byte identical to the canonical bootstraps |
| `.env.example` | Example configuration | Keep secrets as placeholders only |

## Entrypoints

- `curl -fsSL https://shipglows.com/shipglows-script | sh`: short remote bootstrap. Termux selects local mode, root selects full mode, and other interactive shells ask via `/dev/tty`.
- Native Windows without WSL uses the same endpoint with `?format=powershell`; it accepts an already-complete strict 40-character SHA directly, resolves branch or tag names through GitHub's canonical commit API, validates the resulting SHA, and extracts only that immutable public archive without Git. It supports `local` or `full`. Interactive mode selection requires `1`, `2`, or `0`; an empty answer only repeats the prompt. Before changing an existing runtime, the bootstrap stages and syntax-validates the complete managed payload, classifies the operation as install/update/repair/no-op, takes a per-runtime lock, and activates only the manifest-owned files transactionally. Failure restores the prior managed file and directory tree; third-party package-manager changes already completed remain outside that rollback boundary. Full adds the native Astro/Python/Flutter DevServer, Gum, Git, GitHub CLI, Node LTS, pnpm, uv and Flutter without `sudo`, `autossh`, Flox, PM2, or mandatory `ssh-agent`. It reuses validated external Flutter/Dart, JDK 17 and Android SDK paths without replacing `JAVA_HOME`, `ANDROID_HOME`, `ANDROID_SDK_ROOT` or `PATH`; managed user-scope installs are used only when a valid existing tool is absent. An interactive x64 run asks about the emulator only when the emulator, Android 36 image, and named AVD are not already complete; a partial state offers repair. Uncertain acceleration produces a warning instead of suppressing the choice. Acceptance installs missing components with visible progress, while non-interactive runs never infer consent. Android terms and official license prompts remain explicit system/legal confirmations. Every high-level phase renders immediately, each question exposes awaiting-input/answer-received states, and phase work duration excludes human wait time. A second grouped proposal installs only missing large IDE outcomes: current Android Studio, and Visual Studio Community 2022 with the native desktop C++ workload for Flutter Windows. Existing complete installations skip the proposal, partial Visual Studio installs are repaired, progress remains visible and `--norestart` forbids an automatic reboot. Firebase authentication, project choice, billing and remote-device reservation stay user-owned inside Android Studio. One grouped agent proposal installs missing or version-drifted Codex, Claude, OpenCode, Kilo and Gemini CLIs only after consent and at exact resolved versions; non-interactive execution preserves them pending and authentication remains user-owned. Bounded workspace detection prepares exact-version Firebase, FlutterFire, Convex, Vercel, Supabase and Clerk CLIs, then Dart/Flutter, Playwright, Firebase, Convex and Clerk MCP definitions for installed agents. Provider exit codes are not treated as final truth: bounded re-observation recognizes an exact existing CLI, trusted `mise` calendar-version output, Claude MCP re-read, or decoded Codex MCP JSON after an ambiguous exit. The official GitHub MCP is declared in the project's local MCP configuration and activated per project, not registered globally by the installer. Gemini MCP entries use its official user-scope CLI, then local `settings.json` verification without connecting; its global context uses `.gemini/GEMINI.md`. `gh` exclusively owns GitHub credentials; Clerk project linking, SDK injection, environment retrieval and authentication remain explicit project actions. A parseable OpenCode or Kilo file containing only its exact `$schema` is a replaceable placeholder and is completed through an atomic file replacement; any comment, foreign field, provider, or secret keeps the file byte-preserved and records MCP setup as pending. Developer Mode is detected read-only; ShipGlows may open its official Windows settings page after consent but never changes policy or registry values. `SHIPGLOWS_CODEX_PERMISSION_MODE=workspace|full|keep` keeps Codex permission behavior deterministic for automation.
- The machine provider toolbox also installs the official Auth0 CLI through the exact stable `aqua:auth0/auth0-cli` mise coordinate. Auth0 runs natively on Windows with no WSL dependency; its wrapper scopes `AUTH0_CLI_ANALYTICS=false` to the child process, and installation never starts login. Project scanning recognizes `@auth0/*`, `auth0`, and `auth0_flutter`; Auth0 MCP, Deploy CLI, SDK injection, tenant changes, and credential storage remain out of scope.
- Native Windows provisions Doppler through the vendor-recommended `Doppler.Doppler` WinGet package and accepts readiness only after `doppler --version` succeeds. A stable runtime wrapper makes the verified binary available to agents; the installer never starts login, setup, secret access, application execution, or MCP configuration. `s a` uses only a redacted `me` status that ignores inherited token environment variables plus explicit login/logout. Project detection records only manifest/script presence, and installation failure leaves other provider tools usable.
- Native Windows keeps internal source and command wrappers under `%USERPROFILE%\.shipglows\runtime`; the parent `.shipglows` directory stays hidden and may also contain sibling private data repositories. User repositories live directly under `%USERPROFILE%\ShipGlows`; migration removes only legacy `bin`, `cli`, and `local` runtime directories and removes the old visible `workspace` directory only when it is empty.
- The public bootstrap treats the presence of `wsl.exe` only as evidence that the Windows launcher exists. It does not claim that the WSL runtime or a distribution is installed, and it does not execute WSL because the native Windows path has no WSL dependency.
- A validated ShipGlows-managed Flutter SDK reconverges its `bin` directory into both the persistent user `PATH` and the active installer process on every full rerun. It fetches the exact ShipGlows-validated Flutter 3.47.1 / Dart 3.13.1 commit into the pinned `origin/shipglows-stable` ref and uses a named local `stable` tracking branch. Updating that baseline is an intentional source-controlled maintenance operation rather than a side effect of rerunning the installer. Convergence is restricted to the exact managed root, official Flutter origin, and a clean tracked tree; failed post-checkout executable validation restores and revalidates the previous revision. Valid external SDKs remain process-local and are never upgraded. The environment report keeps Visual Studio Desktop C++ readiness separate and reports the aggregate Flutter Windows desktop toolchain as ready only when Flutter/Dart, that workload, and Developer Mode all validate. A momentary missing Dart executable during a cache replacement requires bounded command revalidation before corruption is reported.
- The Flutter 3.47.1 baseline sits exactly on the Android compatibility floor used by projects with AGP 8.11.1 and Gradle 8.14; Flutter accepts those versions while warning toward AGP 9.0.1 and Gradle 9.1. AGP 9 changes Kotlin integration and can conflict with legacy `kotlin-android` application, so a future baseline or Android toolchain migration must be decided and proved together rather than inferred from `pubspec.lock` alone. Diagnose Windows Application Control refusal of unsigned Dart binaries separately from AGP/Gradle compatibility. The canonical thresholds and upstream evidence live in `shipglows_data/technical/external-platforms/flutter.md`.
- Native Windows full reuses the runnable Chromium installed for its managed Playwright runtime as Flutter Web's browser by persisting `CHROME_EXECUTABLE` for the user and current installer process before the Android/Flutter diagnostic phase. The Flutter supervisor revalidates that the executable exists under `%LOCALAPPDATA%\ms-playwright`, rejects reparse paths, and forwards it only for the `chrome` device; explicit `web-server` mode remains browser-independent.
- Native Windows `full` defaults to the project-development `runtime` surface. The explicit `maintainer` surface (interactive option 3 or `-InstallSurface maintainer`; `developer` and `contributor` are input-only compatibility aliases) clones the complete branch namespace or validates the editable ShipGlows checkout at `%USERPROFILE%\ShipGlows\shipglows`, removes enabled public ShipGlows plugins through the Codex CLI, links the public Codex catalogue to that checkout, and persists that exact validated root as current-user `SHIPGLOWS_ROOT`. Generic `full`, `all`, `skills`, and legacy `corpus` values never select this owner-only channel. Existing repositories are never updated or switched implicitly; origin and required-file validation must pass first. State and environment persistence fail closed and restore the prior channel state when convergence cannot complete.
- Native Windows full copies the exact `cli/environment` Python package and schema into `%USERPROFILE%\.shipglows\runtime\cli\environment`. The installed `s` launcher resolves that tree directly and exposes `s env inspect|plan|verify|status|apply` without a PowerShell profile. Read-only environment commands dispatch before DevServer initialization and therefore do not create its workspace, registry or menu cache.
- Native Windows packages `ShipGlows.BuildArtifacts.psm1` and `shipglows-build-artifacts.ps1` so successful project build agents can publish cached Local or CI access later. Installation itself never downloads a build artifact, creates a build shortcut, launches an executable, or installs an APK.
- `install-shipglows.sh`: canonical Unix bootstrap. `SHIPGLOWS_INSTALL_MODE=local|full` provides deterministic non-interactive selection when applied to the consuming `sh` process. Without an explicit surface, `SHIPGLOWS_INSTALL_COMPONENTS=all|skills|corpus` selects the canonical sparse `skills` checkout automatically; `corpus` remains an input-only compatibility alias. The public Unix bootstrap does not expose the owner-only maintainer checkout.
- `tools/sync_shipglows_public_bootstrap.sh --check [--site-root <path>]`: verifies that the ShipGlows site serves generated canonical artifacts rather than independently maintained templates.
- `sudo ./cli/install.sh`: server installer.
- `./local/install.sh`: local tunnel and remote-login installer, including Android Termux.
- `configure_command_wrappers`: installs real global wrappers for `shipglows` and `sg`, plus helper command symlinks such as `shipglows-turso-login` and `shipglows-turso-ssh`.
- `setup_user`: per-user configuration for eligible users.
- `resolve_install_components`: interactive or env-driven selector for user-space agents (`claude`, `codex`, `opencode`, `kilocode`), ShipGlows runtime config, and TUI.
- `configure_*_mcp`: Claude/Codex MCP provider setup. Codex MCP entries are
  registered disabled by default and enabled per session by the ShipGlows
  launcher, except Playwright MCP, which stays globally enabled as the default
  browser-proof lane.
- `configure_skills`: delegates skill symlink check/repair to `tools/shipglows_sync_skills.sh`.
- `configure_aliases`, `configure_data`: user workflow setup.

## Control Flow

```text
curl -fsSL https://shipglows.com/shipglows-script | sh
  -> resolve SHIPGLOWS_INSTALL_MODE, Termux, root, or /dev/tty choice
  -> reject ambiguous non-interactive and unsupported Termux/full combinations
  -> infer the sparse skills surface when the selected components require public skills
  -> install bootstrap dependencies with pkg (Termux) or apt (full server)
  -> download and extract the public ShipGlows archive under the selected user's home
  -> local: exec user-local local/install.sh
  -> full: exec root cli/install.sh

sudo ./cli/install.sh
  -> verify root scope
  -> accept Ubuntu/Debian or a derivative declaring that compatibility
  -> install system tools
  -> collect eligible users
  -> resolve user-space component selection
  -> fail before user setup when a requested skill corpus is absent
  -> atomically replace global shipglows/sg wrappers without following legacy symlinks
  -> setup_user
  -> write aliases, skill links, MCP config, Codex config, shipglows_data
  -> generate install report
```

## Invariants

- Server install is root-level and should fail clearly without root.
- Server full mode supports Ubuntu, Debian, and derivatives declaring either family in `ID_LIKE`; other Linux distributions fail before package installation.
- The remote bootstrap must resolve the mode before enforcing privileges. `local` never requires `sudo`; `full` preserves the root boundary and runs through `cli/install.sh` as root.
- Android Termux always selects or accepts only `local`, even if `sudo` or `tsu` happens to be installed.
- Prompts read `/dev/tty`, never the script pipeline's standard input. Ambiguous non-interactive runs fail with explicit mode commands.
- The public code repository is downloaded without Git on native Windows; Linux/Termux paths may still use Git when their local installer requires it. No bootstrap path asks for or logs GitHub credentials.
- The ShipGlows site's generated shell and PowerShell bootstraps must remain byte-for-byte identical to `install-shipglows.sh` and `install-shipglows.ps1`; drift is a validation failure.
- Daily work should run under an operational user, not by forcing all state into root.
- The installer installs the PM2 binary but must not configure PM2 boot
  autostart by default; environments should start explicitly under the
  operator user.
- The installer installs the Caddy binary for ShipGlows use, but disables the
  default system `caddy.service`; normal environment proxying is launched later
  by ShipGlows in user mode and tied to PM2 app lifecycle.
- Existing user config must be preserved outside ShipGlows-managed blocks.
- Global `shipglows` and `sg` wrappers are installed by same-directory atomic replacement, so an old symlink is replaced rather than its target being overwritten.
- A requested skill corpus must exist before command or user configuration begins. Any per-user setup failure must produce a non-zero installer exit and an incomplete report/banner.
- Codex autonomy uses the current permission-profile keys: standard mode writes
  `approval_policy = "on-request"` with `default_permissions = ":workspace"`;
  permissive mode writes `approval_policy = "never"` with
  `default_permissions = ":danger-full-access"`. Both installers remove an old
  top-level `sandbox_mode` while preserving unrelated TOML content.
- User-space agent CLI install is selection-based. `claude`, `codex`,
  `opencode`, and `kilocode` may be installed independently.
- Windows full applies the same selection principle: every coding agent has an
  individual `[y/N]` prompt, and a non-interactive full install skips agents
  rather than guessing consent. It prefers pnpm and falls back to npm if pnpm
  cannot make the global executable available. The installer adds pnpm v11's
  configured global `bin` directory to the user `PATH`. When npm fallback is
  required for an agent with a postinstall hook, only that selected package is
  passed through npm's scoped `--allow-scripts=<package>` control.
- Native Windows writes managed `.cmd` wrappers for `npm`, `npx`, `corepack`,
  `pnpm` and every installed coding-agent command into the ShipGlows runtime,
  then places that runtime first in the user `PATH`. This avoids npm-generated
  `.ps1` shims when the host forbids PowerShell script execution, without
  weakening the machine's execution policy. A blocked shim beside a verified
  user-scoped `.cmd` launcher is renamed to a unique `shipglows-disabled`
  backup rather than deleted. System-owned shims outside the user profile are
  left unchanged because the user-scoped runtime wrapper already takes PATH
  priority and the installer must not mutate protected package files.
- For each detected coding agent, native Windows atomically maintains a bounded
  ShipGlows block in the agent's official global instruction file: Codex
  `.codex\AGENTS.md`, Claude `.claude\CLAUDE.md`, OpenCode
  `.config\opencode\AGENTS.md`, and Kilo `.config\kilo\AGENTS.md`. Content outside
  the block is preserved, unavailable agents receive no file, and malformed
  managed markers fail closed. Dynamic tool facts stay in
  `.shipglows\environment.md`; the instruction block only defines discovery,
  callability, purpose-built-tool preference, and `$shipglows context` recovery.
- Native Windows keeps convenience commands independent from `$PROFILE`.
  `s.cmd` and `shipglows-dev.cmd` launch the DevServer with `-NoProfile` and a
  process-scoped execution-policy bypass. When the names are unclaimed, the
  installer creates `c -> claude`, `co -> codex`, `cor -> codex resume`,
  `oc -> opencode`, and `kc -> kilocode` as `.cmd` wrappers that call the
  managed agent commands in the same runtime directory. Existing command
  owners are preserved with a visible warning.
- PowerShell reserves `gp` as the read-only all-scope `Get-ItemProperty` alias,
  so the full Git shortcut is installed as a managed current-user profile
  function when persistent profile policy permits it. It stages all changes,
  commits with an explicit or generated message, then pushes; every step stops
  the sequence on failure. `gpush.cmd` remains a profile-independent raw-push
  fallback on locked hosts.
- The current user-space agent install path uses `pnpm add -g` inside
  `PNPM_HOME`, so the installer follows the package registry version current at
  install time instead of shipping pinned local binaries. `PNPM_HOME` itself is
  on `PATH` because pnpm writes global executables there; its legacy `bin`
  subdirectory remains a compatibility fallback. Global packages with a build
  hook are approved individually through pnpm's `--allow-build` option.
- Root-installed server CLIs use the dedicated world-readable pnpm prefix
  `/usr/local/lib/shipglows/pnpm`; `/usr/local/bin` contains only atomic
  wrappers into that prefix. Installer health checks execute each CLI's
  `--version` probe, so a stale wrapper or an inaccessible root-private target
  is a failure rather than a false `present` status.
- System package installation passes explicit PNPM `global-dir` and
  `global-bin-dir` values on every invocation. Presence and health are checked
  against the managed prefix itself, so root access to an older wrapper under
  `/root` cannot suppress migration into the shared prefix.
- The system Node.js install path targets Node.js 24.x through the NodeSource
  `setup_24.x` bootstrap before installing `nodejs`.
- Symlinks, wrappers, and aliases should be idempotent and updated consistently. The managed bash aliases include `shipglows`/`sg`/`s`, Claude/Codex launch shortcuts, reload helpers, and `ch` for clearing the current terminal plus tmux pane history (`clear; tmux clear-history`).
- The real `/usr/local/bin/shipglows` and `/usr/local/bin/sg` wrappers execute
  `$SHIPGLOWS_ROOT/cli/shipglows.sh`; they must not be direct symlinks because
  the CLI resolves sibling files from `BASH_SOURCE`. Other helper wrappers may
  point back to scripts in `$SHIPGLOWS_ROOT`; do not duplicate helper logic.
- ShipGlows skill runtime entries under `~/.claude/skills` for Claude and `~/.agents/skills` for Codex link to `$SHIPGLOWS_ROOT/skills/<name>`. Unix uses symbolic links; native Windows uses directory junctions.
- Codex MCP registrations should default to `enabled = false`; the user-global
  Playwright browser capability is the explicit exception and stays enabled so
  standalone Codex CLI sessions can use browser proof in every project. Other
  MCPs continue to use temporary `-c mcp_servers.<name>.enabled=true` overrides.
- Playwright refresh removes only `mcp_servers.playwright` and its nested
  tables. Managed marker migration must never consume adjacent Codex project,
  marketplace, plugin, notice, or third-party MCP configuration, including
  entries that Codex inserted before an old trailing marker.
- Native Windows resolves an absolute `npx.cmd`, resolves a concrete Playwright
  MCP version from the package authority, installs that exact version, and
  requires a discovered local Chromium executable before writing the owned
  `mcp_servers.playwright` table. It preserves unrelated Codex keys and MCP
  servers and never writes Playwright dependencies into user projects.
- Native Windows additionally installs exact managed `playwright` and
  `@playwright/cli` packages under `%LOCALAPPDATA%\ShipGlows\node-tools`, exposes
  `playwright` and `playwright-cli` through runtime wrappers, reads the stable
  package's `browsers.json`, and requires its exact Chromium revision before
  motion is reported ready. MCP ownership and browser revision remain separate.
- Exact existing FlutterFire, Vercel, Clerk, Firebase, and other npm-global
  service CLIs are re-observed before installation and skipped when their
  executable proves the resolved version. Version drift still triggers bounded
  exact-version convergence.
- `s a` owns authentication orchestration, not credentials: bounded status
  checks are redacted, official interactive CLI flows own login, logout requires
  confirmation, Gemini uses its interactive CLI, Convex remains project-scoped,
  and Auth0 uses only `tenants list --json-compact --no-input`, `login`, and
  `logout`. The installer never records Auth0 domain, audience, client ID,
  tenant, token, secret, command output, or callback configuration.
- Doppler authentication uses only `me --json --no-check-version --no-read-env`,
  `login --no-check-version --no-read-env`, and
  `logout --no-check-version --no-read-env`. Credentials remain owned by
  Doppler and the Windows keychain; ShipGlows never reads a token or secret.
- Installed/configured capability and current-turn callability remain separate.
  Agents inspect directly exposed tools and the host's deferred/searchable
  catalog (`ALL_TOOLS`, `tool_search`, or equivalent) before reporting
  Playwright `not exposed`; a safe read-only probe establishes `callable`.
- Runtime skill link repair blocks on non-symlink targets by default; installer compatibility may pass `--backup-existing` to move collisions aside explicitly.
- Installer errors should stop before partial or misleading success.
- `cli/install.sh` provides Flox/system tooling; Flutter/Dart runtimes are provisioned per project Flox environment unless the operator explicitly uses optional global SDK install.

### Runtime skill visibility diagnostic

On native Windows, diagnose visibility from the ShipGlows source root before changing files or links:

```powershell
Get-ChildItem Env:SHIPGLOWS_ROOT
.\tools\shipglows_sync_skills.ps1 -Mode check -All -Runtime all -Catalog public
```

Interpret the result in this order:

1. `SHIPGLOWS_ROOT` must identify the intended ShipGlows source root, whose `skills/` directory is canonical.
2. A summary with `blocked=0` and equal `checked=<n>` / `ok=<n>` counts proves the selected filesystem links or junctions are current. Do not run `repair` in that state.
3. Missing, stale, broken, or blocked entries justify a scoped `-Mode repair`; preserve unrelated directories and non-link collisions unless explicit backup authority exists.
4. If the links are current but an already-running agent does not list the current public skills, open a new conversation or reload the agent process. Skill discovery is captured by the process/session; restarting Windows does not rewrite the history or injected skill inventory of an existing conversation.
5. Historical records may mention the former `~/.codex/skills` layout. They are provenance, not the current Codex user-skill location.

## Failure Modes

- Live downloads or package installers can fail partially; messages must identify the failing step.
- `--only` or component-scoped install paths can leave stale aliases or symlinks if final synchronization is skipped.
- Missing runtime tools should produce direct diagnostics, not secondary shell errors.
- When only some agents are selected, verification and reporting must show
  unselected agents as intentionally skipped rather than failed.
- Missing Playwright Chromium runtime libraries can still break a
  Playwright-enabled Codex launch. The installer records the local Chromium
  path and fails its Playwright readiness result rather than presenting the
  globally enabled MCP as usable without its runtime.
- Incorrect user targeting can install private workflow config for the wrong account.

## Security Notes

- Do not paste tokens, private MCP credentials, or shell config secrets into docs.
- Treat root-level writes and `/usr/local` changes as high-impact.
- Preserve non-destructive validation paths for installer changes.

## Validation

GitHub exposes one stable required-check candidate named `ShipGlows required gate` on every pull request into `main` and every push to `main`. Its deterministic path classifier reports a successful no-Windows-impact result for unrelated changes; changes to the Windows bootstrap, local installer, native Windows runtime/tests, environment control plane, runtime-skill synchronization, classifier, or workflow run the complete `tests/windows/devserver-contract.sh` contract. The workflow checks out and verifies the exact event SHA, uses read-only repository permissions, persists no checkout credential, and fails closed on invalid refs or unsafe paths.

```bash
sh -n install-shipglows.sh
bash -n cli/install.sh local/install.sh local/turso-login.sh local/turso-ssh.sh
bash tests/cli/pnpm-bootstrap.sh
bash tests/install/pnpm-global-cli-health.sh
bash tests/install/bootstrap-mode-selection.sh
bash tests/install/full-installer-paths.sh
bash tests/windows/devserver-contract.sh
tools/sync_shipglows_public_bootstrap.sh --check --site-root /home/claude/shipglows_app/site
bash -n tools/shipglows_sync_skills.sh tests/skills/runtime-sync.sh
bash tests/skills/runtime-sync.sh
tools/shipglows_sync_skills.sh --check --all
rg -n "resolve_install_components|install_ai_agent_clis_for_user|verify_ai_agent_clis_for_user|configure_aliases|configure_skills|configure_data|setup_user|collect_target_users|configure_codex|shipglows-turso-login|shipglows-turso-ssh" cli/install.sh local/
```

For behavioral changes, prefer a disposable host/container or a narrowly scoped installer dry run before claiming install success.

## Reader Checklist

- `cli/install.sh` changed -> review this doc and `README.md`.
- Alias/symlink behavior changed -> check local and server install docs, plus `tools/shipglows_sync_skills.sh --check --all`.
- Windows wrapper or shortcut behavior changed -> run the Windows static contract, then require a native PowerShell smoke before marking target behavior verified.
- MCP config changed -> check provider docs references and remote login docs.
- Playwright MCP config changed -> confirm Linux ARM64 keeps using the local
  Playwright Chromium executable instead of a Google Chrome stable channel, and
  that Codex still writes the provider as disabled by default.
- User targeting changed -> check installer ownership specs.

## Maintenance Rule

Update this doc when install privilege, user targeting, package/tool list, symlink/alias behavior, MCP setup, Codex/Claude config, or `shipglows_data` bootstrap behavior changes.
