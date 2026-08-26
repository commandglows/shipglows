---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-26"
updated: "2026-08-26"
status: reviewed
source_skill: 900-shipglows-core
scope: rio-tab-rename-command
owner: Diane
user_story: "As the ShipGlows operator using Rio on Windows, I want one ShipGlows command to rename the current Rio tab without changing Codex session state."
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - cli/windows/shipglows.ps1
  - cli/windows/install-devserver.ps1
  - install-shipglows.ps1
  - tests/windows/rio-tab-rename.ps1
depends_on: []
supersedes: []
evidence:
  - "Operator decision 2026-08-26: expose shipglows rename rio <name> by reusing the ShipGlows command surface rather than a personal shell-only shortcut."
next_step: "Implement and verify the focused Windows command."
---

# Rio Tab Rename Command

## Status

Verified locally — focused behavior, integrated Windows contracts, packaging,
and documentation are coherent; real installed-Rio proof remains the final
delivery step.

## User Story

As the ShipGlows operator using Rio on Windows, I want to run
`shipglows rename rio "Session name"` so the current Rio tab receives a clear
manual title without changing a Codex conversation title or another tab.

## Behavior Contract

- The exact public grammar is `shipglows rename rio <name>`.
- The name is formed from all remaining arguments, preserving spaces and Unicode.
- A valid name emits exactly one OSC window-title sequence to standard output and exits zero.
- Empty names, names longer than 120 Unicode characters, control characters, unknown targets, and unknown commands fail without emitting OSC.
- The command does not inspect or mutate Codex state, other sessions, project files, credentials, permissions, or remote state.

## Scope

- Add the native Windows `shipglows` command entrypoint.
- Package and install it through the existing full Windows bootstrap.
- Add focused command and packaging proof.
- Keep the existing Linux CLI unchanged in this Windows tranche.

## Proof Contract

- Proof path: test-first with a focused PowerShell process fixture.
- Pressure scenario `RIO-RENAME-CURRENT-TAB-ONLY`: a valid Unicode name produces
  only `ESC ] 0 ; <name> BEL`; invalid input produces no escape sequence.
- Installer contract: the source script is staged, copied into the active bin,
  and wrapped as `shipglows.cmd` without replacing a foreign command. The exact
  companion `runtime/bin/shipglows.ps1` is recognized as owned rather than
  misclassified as a collision during installation.

## ZOMBIES Coverage

- Z: missing or whitespace-only title fails without OSC.
- O: one ordinary title emits one exact sequence.
- M: multiple title arguments join into one title; repeated calls remain independent.
- B: 120 characters pass, 121 fail, and control characters fail.
- I: CMD wrapper -> PowerShell entrypoint -> Rio OSC standard-output boundary is explicit.
- E: unsupported grammar and unsafe input fail with a non-zero exit and actionable error.
- S: one entrypoint and one focused router avoid a profile function or terminal-specific installation layer.

## Acceptance Criteria

- [x] `shipglows rename rio "Nom de session"` emits the exact Rio title sequence.
- [x] Unicode and spaces are preserved.
- [x] Unsafe and unsupported input emits no OSC sequence.
- [x] The full Windows installer packages and installs `shipglows` for a fresh shell.
- [x] Focused tests, PowerShell parsing, and Git hygiene pass.
- [ ] Exact-scope changes are committed and pushed without the unrelated dirty business document.

## Current Chantier Flow

- `100-sg-spec`: complete — bounded behavior and proof contract recorded.
- `101-sg-ready`: ready — exact grammar, ownership, safety, and proof are resolved.
- `102-sg-start`: complete — command, wrapper, bootstrap packaging, and mapped docs implemented.
- `103-sg-verify`: complete — focused and integrated Windows contracts pass.
- `104-sg-end`: pending.
- `005-sg-ship`: pending.
