---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "shipglows"
created: "2026-05-03"
created_at: "2026-05-03 00:00:00 UTC"
updated: "2026-05-03"
updated_at: "2026-05-03 09:43:10 UTC"
status: ready
source_skill: sg-build
source_model: "GPT-5 Codex"
scope: "runtime-cli-local-tunnels"
owner: "unknown"
user_story: "As a ShipGlows operator developing Flutter Web from a remote VM and previewing on a Samsung phone through SSH tunnels, I want ShipGlows to launch Flutter in an interactive server-side terminal session and send hot reload commands for me, so I can iterate without waiting for Vercel builds."
risk_level: "medium"
confidence: "high"
security_impact: "low"
docs_impact: "yes"
linked_systems:
  - "lib.sh"
  - "config.sh"
  - "local/remote-helpers.sh"
  - "local/local.sh"
  - "local/dev-tunnel.sh"
  - "README.md"
  - "local/README.md"
  - "docs/technical/runtime-cli.md"
  - "docs/technical/local-tunnels-and-mcp-login.md"
depends_on:
  - artifact: "docs/technical/runtime-cli.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
  - artifact: "docs/technical/local-tunnels-and-mcp-login.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
supersedes: []
evidence:
  - "User request 2026-05-03: ShipGlows should open Flutter Web dev with hot reload from SSH instead of waiting for Vercel builds."
  - "Existing ShipGlows Flutter Web PM2 command is non-interactive, so it cannot reliably receive Flutter's r/R hot reload controls."
  - "ShipGlows local tunnels currently discover remote ports through PM2; interactive Flutter sessions need a server-side registry so the tunnel tools can expose them too."
next_step: "/sg-verify Flutter Web tmux hot reload"
---

# Spec: Flutter Web Tmux Hot Reload

## Status

ready

## User Story

As a ShipGlows operator developing Flutter Web from a remote VM and previewing on a Samsung phone through SSH tunnels, I want ShipGlows to launch Flutter in an interactive server-side terminal session and send hot reload commands for me, so I can iterate without waiting for Vercel builds.

## Minimal Behavior Contract

ShipGlows must provide a server-side Flutter Web dev action that starts `flutter run -d web-server` inside a named `tmux` session for the selected Flutter project, records the selected port, and exposes commands to send hot reload (`r`), hot restart (`R`), attach, or stop that session. Local tunnel tools must include these recorded Flutter ports in addition to PM2 ports.

## Scope In

- Add a configurable Flutter Web session registry path.
- Add server menu actions for Flutter Web dev, hot reload, hot restart, attach, and stop.
- Use project Flox provisioning before launching Flutter.
- Use `tmux` for interactive process control instead of PM2.
- Extend local tunnel port discovery to include active registered Flutter `tmux` sessions.
- Update runtime and local tunnel docs.
- Add focused shell tests for session naming and registry behavior.

## Scope Out

- Do not replace PM2-managed Flutter Web launch.
- Do not build native Android/iOS Flutter preview.
- Do not install Flutter globally by default.
- Do not change Flutter app source code.

## Acceptance Criteria

- [x] A Flutter project with a `web/` directory can be launched in `tmux` with a ShipGlows-assigned port.
- [x] ShipGlows can send `r` to the stored `tmux` session for hot reload.
- [x] ShipGlows can send `R` for hot restart.
- [x] `urls` / `tunnel` include active Flutter `tmux` ports as localhost URLs.
- [x] Static shell checks pass for touched scripts.
- [x] Docs explain that this path is for Flutter Web preview, not native Android rendering.

## Current Chantier Flow

| Step | Status | Notes |
|------|--------|-------|
| sg-spec | ready | Spec created directly from `$sg-build` intake. |
| sg-ready | ready | Scope is bounded and implementation path is explicit. |
| sg-start | implemented | Runtime, tunnel, docs, and focused tests updated. |
| sg-verify | partial | Static checks and tmux registry smoke passed; live Flutter app launch not run. |
| sg-end | pending | Not run in this turn. |
| sg-ship | pending | Not run in this turn. |

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-03 00:00:00 UTC | sg-build | GPT-5 Codex | Created ready implementation spec for Flutter Web `tmux` hot reload and local tunnel discovery. | in_progress | implement runtime and tunnel changes |
| 2026-05-03 09:43:10 UTC | sg-build | GPT-5 Codex | Implemented Flutter Web `tmux` session actions, hot reload/hot restart key sending, local tunnel discovery, documentation updates, and focused validation. | implemented | /sg-verify Flutter Web tmux hot reload |
