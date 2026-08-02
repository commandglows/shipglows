---
artifact: specification
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: shipglows
created: "2026-05-08"
updated: "2026-05-08"
status: ready
source_skill: sg-build
scope: user-mode-caddy-lifecycle
owner: unknown
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - lib.sh
  - config.sh
  - install.sh
  - docs/technical/runtime-cli.md
  - CONTEXT.md
  - CONTEXT-FUNCTION-TREE.md
depends_on: []
supersedes: []
evidence:
  - "Operator decision: Caddy should belong to the ShipGlows/PM2 lifecycle, not remain as a long-running root service."
next_step: "/sg-verify user-mode Caddy lifecycle"
---

# User-Mode Caddy Lifecycle

## User Story

As a ShipGlows operator, I want Caddy to run under the current user and only while ShipGlows PM2 environments are running, so stopping environments frees memory and logs without leaving a root service active for days.

## Contract

- ShipGlows starts a user-owned Caddy process after PM2 launches a non-Expo app.
- User Caddy writes runtime config, PID, storage, and logs under `~/.shipglows/runtime/caddy` by default.
- User Caddy listens on a non-privileged local port by default.
- ShipGlows refreshes user Caddy routes from online PM2 apps.
- When no PM2 app is online, ShipGlows stops user Caddy.
- The legacy system Caddy service is not the normal runtime path; it may be stopped when no PM2 app is online.
- SSH, tmux server, shells, and system services other than the explicitly managed Caddy service remain protected from broad cleanup.

## Acceptance Criteria

- [x] Given an app starts through `env_start`, when PM2 reaches online or launching, then user Caddy starts or refreshes with a route to that app.
- [x] Given an app stops through `env_stop`, when at least one PM2 app remains online, then user Caddy refreshes routes.
- [x] Given the last PM2 app stops, then user Caddy stops.
- [x] Given Health aggressive cleanup runs, then user Caddy and legacy Caddy are considered cleanup targets only when no PM2 app is online.
- [x] Given install runs as root, then system Caddy is not left enabled/running by default after installation.

## Validation

```bash
bash -n shipglows.sh lib.sh config.sh install.sh
SHIPGLOWS_USER_CADDY_DRY_RUN=1 bash -lc 'source ./lib.sh; refresh_user_caddy_from_pm2'
SHIPGLOWS_AGGRESSIVE_CLEANUP_DRY_RUN=1 bash -lc 'source ./lib.sh; aggressive_cleanup_menu'
python3 tools/shipglows_metadata_lint.py specs/user-mode-caddy-lifecycle.md docs/technical/runtime-cli.md CONTEXT.md CONTEXT-FUNCTION-TREE.md
```

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-08 12:33:00 UTC | sg-build | GPT-5 | Added user-mode Caddy lifecycle, tied Caddy sync to PM2 start/stop/stop-all, disabled default system Caddy in installer, and updated runtime docs. | implemented | /sg-verify user-mode Caddy lifecycle |

## Current Chantier Flow

sg-spec ✅ -> sg-ready ✅ -> sg-start ✅ -> sg-verify ✅ -> sg-end pending -> sg-ship pending
