---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "2.3.2"
project: ShipGlows
created: "2026-05-01"
updated: "2026-08-15"
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
  - "README installer section and cli/install.sh function inventory."
  - "The 2026-08-13 runtime documentation audit aligned the active Codex skill scope with ~/.agents/skills and added a check-before-repair Windows diagnostic."
  - "PM2 boot autostart removed from default installer contract."
  - "Turso SSH helper command wrapper added to installer-managed global commands."
  - "Turso remote login helper command wrapper added."
  - "Remote Agents menu includes Turso guidance while local menu owns the SSH tunnel flow."
  - "Short remote ShipGlows bootstrap added for clone-free install."
  - "Installer now supports per-agent user-space selection for Claude, Codex, OpenCode, and KiloCode, plus separate runtime/TUI choices."
  - "Unified bootstrap modes route Android Termux to local/install.sh without sudo and retain root-only full server installation."
  - "Native Windows full installs Git and GitHub CLI through WinGet, while GitHub CLI exclusively owns browser authentication and credential storage."
  - "Native Windows full installs Node LTS, pnpm, uv and a resolved Flutter commit automatically; valid external Flutter/Dart, JDK 17 and Android SDK installations are reused without replacing their environment ownership."
  - "Native Windows full configures user-global Playwright MCP only after exact-version resolution and a runnable Chromium executable check in the user cache."
  - "The 2026-08-14 capability-discovery repair makes Playwright MCP the enabled default web-QA lane and requires direct-plus-deferred current-turn discovery before an unavailable verdict."
  - "Native Windows full removes ShipGlows's obsolete managed PowerShell profile function, so profile execution-policy errors no longer affect ordinary PowerShell launches."
  - "Native Windows full asks separately before each optional coding-agent CLI and leaves authentication to that CLI."
  - "Native Windows interactive mode selection requires an explicit 1, 2, or 0; empty console input never starts an installation."
  - "Native Windows prepares pnpm v11's global bin PATH and explicitly allows only the selected official agent package's install script when npm fallback requires it."
  - "Native Windows places managed .cmd application wrappers before npm-generated .ps1 shims, preserving commands under restrictive execution policy."
  - "Native Windows installs collision-safe .cmd shortcuts for c, co, cor, oc, and kc without depending on the PowerShell profile."
  - "Native Windows overrides PowerShell's reserved gp alias with a guarded add-all, commit, and push workflow; raw gpush remains available without profiles."
  - "Operator decision 2026-08-11: Linux and Windows converge on ~/.shipglows/runtime, with data and design-inspiration-library as sibling private repositories."
  - "Migration audit 2026-08-11: mutable Caddy state moves from the former ~/.shipglows/runtime/caddy location to ~/.shipglows/state/caddy so it cannot collide with the canonical code checkout."
next_review: "2026-06-01"
next_step: "/sg-docs technical audit installer"
---

# Installer And User Scope

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
| `install-shipglows.ps1` | Canonical Windows mode selector and archive bootstrap | Keep interactive mode explicit and automation deterministic through `-InstallMode` |
| `cli/windows/install-devserver.ps1` | Native Windows full installer | Keep user-scoped tools, wrappers, PATH changes, prompts, and collision handling idempotent |
| `tools/sync_shipglows_public_bootstrap.sh` | ShipGlows public artifact parity | Keep the generated public shell and PowerShell assets byte-for-byte identical to the canonical bootstraps |
| `.env.example` | Example configuration | Keep secrets as placeholders only |

## Entrypoints

- `curl -fsSL https://shipglows.com/shipglows-script | sh`: short remote bootstrap. Termux selects local mode, root selects full mode, and other interactive shells ask via `/dev/tty`.
- Native Windows without WSL uses the same endpoint with `?format=powershell`; it resolves the requested branch, tag, or SHA through GitHub's canonical commit API, validates the returned 40-character SHA, and extracts only that immutable public archive without Git. It supports `local` or `full`. Interactive mode selection requires `1`, `2`, or `0`; an empty answer only repeats the prompt. Full adds the native Astro/Python/Flutter DevServer, Gum, Git, GitHub CLI, Node LTS, pnpm, uv and Flutter without `sudo`, `autossh`, Flox, PM2, or mandatory `ssh-agent`. It reuses validated external Flutter/Dart, JDK 17 and Android SDK paths without replacing `JAVA_HOME`, `ANDROID_HOME`, `ANDROID_SDK_ROOT` or `PATH`; managed user-scope installs are used only when a valid existing tool is absent. An interactive x64 run asks about the emulator only when the emulator, Android 36 image, and named AVD are not already complete; a partial state offers repair. Uncertain acceleration produces a warning instead of suppressing the choice. Acceptance installs missing components with visible progress, while non-interactive runs never infer consent. Android terms and official license prompts remain explicit system/legal confirmations. A second grouped proposal installs only missing large IDE outcomes: current Android Studio, and Visual Studio Community 2022 with the native desktop C++ workload for Flutter Windows. Existing complete installations skip the proposal, partial Visual Studio installs are repaired, progress remains visible and `--norestart` forbids an automatic reboot. Firebase authentication, project choice, billing and remote-device reservation stay user-owned inside Android Studio. Agent CLIs are detected, not installed or authenticated. `SHIPGLOWS_CODEX_PERMISSION_MODE=workspace|full|keep` keeps Codex permission behavior deterministic for automation.
- Native Windows keeps internal source and command wrappers under `%USERPROFILE%\.shipglows\runtime`; the parent `.shipglows` directory stays hidden and may also contain sibling private data repositories. User repositories live directly under `%USERPROFILE%\ShipGlows`; migration removes only legacy `bin`, `cli`, and `local` runtime directories and removes the old visible `workspace` directory only when it is empty.
- `install-shipglows.sh`: canonical bootstrap. `SHIPGLOWS_INSTALL_MODE=local|full` provides deterministic non-interactive selection when applied to the consuming `sh` process.
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
  -> install bootstrap dependencies with pkg (Termux) or apt (full server)
  -> download and extract the public ShipGlows archive under the selected user's home
  -> local: exec user-local local/install.sh
  -> full: exec root cli/install.sh

sudo ./cli/install.sh
  -> verify root scope
  -> install system tools
  -> configure global commands
  -> collect eligible users
  -> resolve user-space component selection
  -> setup_user
  -> write aliases, skill links, MCP config, Codex config, shipglows_data
  -> generate install report
```

## Invariants

- Server install is root-level and should fail clearly without root.
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
- Native Windows resolves an absolute `npx.cmd`, resolves a concrete Playwright
  MCP version from the package authority, installs that exact version, and
  requires a discovered local Chromium executable before writing the owned
  `mcp_servers.playwright` table. It preserves unrelated Codex keys and MCP
  servers and never writes Playwright dependencies into user projects.
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

```bash
sh -n install-shipglows.sh
bash -n cli/install.sh local/install.sh local/turso-login.sh local/turso-ssh.sh
bash tests/install/bootstrap-mode-selection.sh
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
