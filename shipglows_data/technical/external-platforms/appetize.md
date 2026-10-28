---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-10-24"
updated: "2026-10-24"
status: draft
source_skill: sg-docs
scope: external-platform-appetize
owner: Diane
confidence: medium
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/documentation-freshness-gate.md
  - shipglows_data/workflow/explorations/2026-10-24-remote-native-app-testing-agents.md
  - shipglows_data/technical/external-platforms/doppler.md
depends_on:
  - artifact: "shipglows_data/technical/external-platforms/README.md"
    artifact_version: "1.1.0"
    required_status: "draft"
supersedes: []
evidence:
  - "Vendor docs read on 2026-10-24: AI agents getting started, sessions, pricing."
  - "Installed on the Windows host on 2026-10-24: @appetize/cli 0.25.1 (global npm), Claude skill at ~/.claude/skills/appetize."
next_review: "2026-11-24"
next_step: "/sg-docs technical audit"
---

# Appetize Platform Note

## Purpose

Appetize runs iOS simulators and Android emulators in the cloud and exposes them to coding agents through
a headless CLI and a REST API. ShipGlows uses it to exercise Flutter (and later Tauri Android) builds on iOS
and Android without a Mac or a local emulator.

## Source Map

| Need | Source |
| --- | --- |
| Agent CLI quick start | https://docs.appetize.io/ai-agents/getting-started.md |
| Sessions, logs, network | https://docs.appetize.io/ai-agents/sessions.md |
| Automation (inspect, tap, selectors) | https://docs.appetize.io/ai-agents/automation.md |
| Screenshots and recordings | https://docs.appetize.io/ai-agents/screenshots-and-recordings.md |
| Development loop (hot reload) | https://docs.appetize.io/guides-and-samples/development-loop.md |
| REST API | https://docs.appetize.io/rest-api |
| Pricing | https://site.appetize.io/pricing |
| Full corpus for agents | https://docs.appetize.io/llms-full.txt |

Freshness evidence on 2026-10-24:

- CLI is in beta; command names and flags may change. Installed version: 0.25.1. Node 22+ required.
- Free plan: single user, 2 active devices, 30 minutes refilled monthly. Starter 59 $/mo: 500 min then 0.06 $/min.
- Builds accepted: Android `.apk`/`.apks`; iOS simulator `.app` zipped (`.zip`, `.tar.gz`). iOS builds must be compiled on macOS (cloud builder).
- `session start <device-id> --target <buildId>` prints JSON; later commands act on the current session. Logs under `~/.appetize/cli/sessions/<name>/`.
- `appetize skill install --scope user --agent claude` installs the Claude skill `appetize` (done on this host).

## Secrets and Boundaries

- `APPETIZE_API_TOKEN` (format `tok_…`) lives in Doppler `dotfiles/dev`. Run the CLI as
  `doppler run --project dotfiles --config dev -- appetize …`. Never export it in a profile or print it.
- Account and token creation are operator-only actions (organization settings in the Appetize dashboard).
- Sessions burn the monthly quota while open: always finish with `appetize session stop`; prefer `--json`.

## ShipGlows Decision Rules

- Android lane from Windows: an explicitly requested debug APK is uploaded with `appetize build upload <apk> --wait`, then run on `pixel7` (or another id from `appetize device list --platform android`).
- iOS lane: needs a cloud macOS build (Codemagic or EAS Build) producing a zipped simulator `.app`; without that artifact the iOS session cannot start.
- Hot reload on Appetize works through a development server reachable by the device (tunnel); it is a later phase, not part of the free-tier bootstrap.
- Proof language: a session screenshot proves the screen state, not login or protected access; apply the usual auth evidence rules.

## Typical agent sequence

```bash
doppler run --project dotfiles --config dev -- appetize device list --platform ios
doppler run --project dotfiles --config dev -- appetize build upload ./app-debug.apk --wait
doppler run --project dotfiles --config dev -- appetize session start pixel7 --target <buildId> --json
doppler run --project dotfiles --config dev -- appetize inspect
doppler run --project dotfiles --config dev -- appetize tap --select-text 'Log in'
doppler run --project dotfiles --config dev -- appetize screenshot after-login
doppler run --project dotfiles --config dev -- appetize session stop
```
