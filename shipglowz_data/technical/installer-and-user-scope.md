---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlowz
created: "2026-05-01"
updated: "2026-07-17"
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
  - README.md
  - local/install.sh
depends_on:
  - artifact: "README.md"
    artifact_version: "0.1.0"
    required_status: draft
  - artifact: "GUIDELINES.md"
    artifact_version: "1.2.0"
    required_status: reviewed
supersedes: []
evidence:
  - "README installer section and cli/install.sh function inventory."
  - "PM2 boot autostart removed from default installer contract."
  - "Turso SSH helper command wrapper added to installer-managed global commands."
  - "Turso remote login helper command wrapper added."
  - "Remote Agents menu includes Turso guidance while local menu owns the SSH tunnel flow."
  - "Short remote ShipGlowz bootstrap added for clone-free install."
  - "Installer now supports per-agent user-space selection for Claude, Codex, OpenCode, and KiloCode, plus separate runtime/TUI choices."
  - "Unified bootstrap modes route Android Termux to local/install.sh without sudo and retain root-only full server installation."
next_review: "2026-06-01"
next_step: "/sg-docs technical audit installer"
---

# Installer And User Scope

## Purpose

This doc covers `cli/install.sh` and the root/user boundary for ShipGlowz setup. Read it before changing system dependencies, global binaries, aliases, skill links, Codex/Claude config, MCP registration, or project-local `shipglowz_data` bootstrap behavior.

## Owned Files

| Path | Role | Edit notes |
| --- | --- | --- |
| `cli/install.sh` | Root-level server bootstrap and per-user setup | Preserve idempotence and explicit root-only behavior |
| `tools/shipglowz_sync_skills.sh` | Shared Claude/Codex skill symlink sync helper | Reuse instead of duplicating skill-link repair logic |
| `README.md` | Operator install contract | Update when commands, privilege, or installed tooling changes |
| `local/install.sh`, `local/install_local.ps1` | Workstation-side setup | Keep separate from root server install assumptions |
| `install-shipglowz.sh` | Canonical remote bootstrap and local/full mode selector | Resolve mode before privilege checks; preserve user home and repository ownership |
| `tools/sync_shipglowz_public_bootstrap.sh` | WinGlowz public artifact parity | Keep the generated public shell asset byte-for-byte identical to the canonical bootstrap |
| `.env.example` | Example configuration | Keep secrets as placeholders only |

## Entrypoints

- `curl -fsSL https://www.winflowz.com/shipglowz-script | sh`: short remote bootstrap. Termux selects local mode, root selects full mode, and other interactive shells ask via `/dev/tty`.
- `install-shipglowz.sh`: canonical bootstrap. `SHIPGLOWZ_INSTALL_MODE=local|full` provides deterministic non-interactive selection when applied to the consuming `sh` process.
- `tools/sync_shipglowz_public_bootstrap.sh --check --winglowz-root <path>`: verifies that WinGlowz serves the generated canonical artifact rather than an independently maintained template.
- `sudo ./cli/install.sh`: server installer.
- `./local/install.sh`: local tunnel and remote-login installer, including Android Termux.
- `configure_command_wrappers`: installs global `shipflow`, `sf`, and helper command symlinks such as `shipflow-turso-login` and `shipflow-turso-ssh`.
- `setup_user`: per-user configuration for eligible users.
- `resolve_install_components`: interactive or env-driven selector for user-space agents (`claude`, `codex`, `opencode`, `kilocode`), ShipGlowz runtime config, and TUI.
- `configure_*_mcp`: Claude/Codex MCP provider setup. Codex MCP entries
  are registered disabled by default and enabled per session by the ShipGlowz
  launcher.
- `configure_skills`: delegates skill symlink check/repair to `tools/shipglowz_sync_skills.sh`.
- `configure_aliases`, `configure_data`: user workflow setup.

## Control Flow

```text
curl -fsSL https://www.winflowz.com/shipglowz-script | sh
  -> resolve SHIPGLOWZ_INSTALL_MODE, Termux, root, or /dev/tty choice
  -> reject ambiguous non-interactive and unsupported Termux/full combinations
  -> install bootstrap dependencies with pkg (Termux) or apt (full server)
  -> clone or update private ShipGlowz under the selected user's home
  -> stash local dirty repository changes before update
  -> local: exec user-local local/install.sh
  -> full: exec root cli/install.sh

sudo ./cli/install.sh
  -> verify root scope
  -> install system tools
  -> configure global commands
  -> collect eligible users
  -> resolve user-space component selection
  -> setup_user
  -> write aliases, skill links, MCP config, Codex config, shipglowz_data
  -> generate install report
```

## Invariants

- Server install is root-level and should fail clearly without root.
- The remote bootstrap must resolve the mode before enforcing privileges. `local` never requires `sudo`; `full` preserves the root boundary and runs through `cli/install.sh` as root.
- Android Termux always selects or accepts only `local`, even if `sudo` or `tsu` happens to be installed.
- Prompts read `/dev/tty`, never the script pipeline's standard input. Ambiguous non-interactive runs fail with explicit mode commands.
- The private repository requires pre-existing authorized GitHub access. Errors must not recommend putting a token in the remote URL or log credentials.
- WinGlowz's generated public bootstrap must remain byte-for-byte identical to `install-shipglowz.sh`; drift is a validation failure.
- Daily work should run under an operational user, not by forcing all state into root.
- The installer installs the PM2 binary but must not configure PM2 boot
  autostart by default; environments should start explicitly under the
  operator user.
- The installer installs the Caddy binary for ShipGlowz use, but disables the
  default system `caddy.service`; normal environment proxying is launched later
  by ShipGlowz in user mode and tied to PM2 app lifecycle.
- Existing user config must be preserved outside ShipGlowz-managed blocks.
- User-space agent CLI install is selection-based. `claude`, `codex`,
  `opencode`, and `kilocode` may be installed independently.
- The current user-space agent install path uses `pnpm add -g` inside
  `PNPM_HOME`, so the installer follows the package registry version current at
  install time instead of shipping pinned local binaries.
- The system Node.js install path targets Node.js 24.x through the NodeSource
  `setup_24.x` bootstrap before installing `nodejs`.
- Symlinks and aliases should be idempotent and updated consistently. The managed bash aliases include `shipflow`/`sf`/`s`, Claude/Codex launch shortcuts, reload helpers, and `ch` for clearing the current terminal plus tmux pane history (`clear; tmux clear-history`).
- Helper command wrappers under `/usr/local/bin` should point back to scripts in
  `$SHIPFLOW_ROOT`; do not duplicate helper logic into generated files.
- ShipGlowz skill runtime entries under `~/.claude/skills` and `~/.codex/skills` are symlinks to `$SHIPFLOW_ROOT/skills/<name>`.
- Codex MCP registrations should default to `enabled = false`; normal Codex
  sessions stay lightweight, and ShipGlowz launches MCP-enabled sessions with
  temporary `-c mcp_servers.<name>.enabled=true` overrides.
- Runtime skill link repair blocks on non-symlink targets by default; installer compatibility may pass `--backup-existing` to move collisions aside explicitly.
- Installer errors should stop before partial or misleading success.
- `cli/install.sh` provides Flox/system tooling; Flutter/Dart runtimes are provisioned per project Flox environment unless the operator explicitly uses optional global SDK install.

## Failure Modes

- Live downloads or package installers can fail partially; messages must identify the failing step.
- `--only` or component-scoped install paths can leave stale aliases or symlinks if final synchronization is skipped.
- Missing runtime tools should produce direct diagnostics, not secondary shell errors.
- When only some agents are selected, verification and reporting must show
  unselected agents as intentionally skipped rather than failed.
- Missing Playwright Chromium runtime libraries can still break a
  Playwright-enabled Codex launch; the installer records the local Chromium
  path while keeping Playwright MCP disabled until explicitly requested.
- Incorrect user targeting can install private workflow config for the wrong account.

## Security Notes

- Do not paste tokens, private MCP credentials, or shell config secrets into docs.
- Treat root-level writes and `/usr/local` changes as high-impact.
- Preserve non-destructive validation paths for installer changes.

## Validation

```bash
sh -n install-shipglowz.sh
bash -n cli/install.sh local/install.sh local/turso-login.sh local/turso-ssh.sh
bash tests/install/bootstrap-mode-selection.sh
tools/sync_shipglowz_public_bootstrap.sh --check --winglowz-root /home/claude/winglowz
bash -n tools/shipglowz_sync_skills.sh tests/skills/runtime-sync.sh
bash tests/skills/runtime-sync.sh
tools/shipglowz_sync_skills.sh --check --all
rg -n "resolve_install_components|install_ai_agent_clis_for_user|verify_ai_agent_clis_for_user|configure_aliases|configure_skills|configure_data|setup_user|collect_target_users|configure_codex|shipflow-turso-login|shipflow-turso-ssh" cli/install.sh local/
```

For behavioral changes, prefer a disposable host/container or a narrowly scoped installer dry run before claiming install success.

## Reader Checklist

- `cli/install.sh` changed -> review this doc and `README.md`.
- Alias/symlink behavior changed -> check local and server install docs, plus `tools/shipglowz_sync_skills.sh --check --all`.
- MCP config changed -> check provider docs references and remote login docs.
- Playwright MCP config changed -> confirm Linux ARM64 keeps using the local
  Playwright Chromium executable instead of a Google Chrome stable channel, and
  that Codex still writes the provider as disabled by default.
- User targeting changed -> check installer ownership specs.

## Maintenance Rule

Update this doc when install privilege, user targeting, package/tool list, symlink/alias behavior, MCP setup, Codex/Claude config, or `shipglowz_data` bootstrap behavior changes.
