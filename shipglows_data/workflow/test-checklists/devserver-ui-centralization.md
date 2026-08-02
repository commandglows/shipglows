---
artifact: test_checklist
metadata_schema_version: "1.0"
artifact_version: "1.0.1"
project: ShipGlows
created: "2026-07-17"
updated: "2026-07-17"
status: active
source_skill: 102-sg-start
scope: devserver-startup-cache-shell-ui
owner: unknown
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - cli/lib.sh
  - tests/cli/devserver-startup-cache.sh
  - shipglows_data/workflow/specs/devserver-ui-centralization.md
depends_on: []
supersedes: []
evidence:
  - "Automated CLI suites and five-run startup/picker benchmarks executed on 2026-07-17."
  - "Real TTY proof executed for gum and Bash fallback selection/cancellation, buffered-input drain, navigate cancellation, and isolated empty state on 2026-07-17."
next_step: "/104-sg-end Optimize DevServer startup, caches, and shell UI"
---

# DevServer startup, cache, and shell UI checklist

## Automated proof

- [x] `bash -n` passes for the shared library, launcher, and both menu frontends.
- [x] Lazy sourcing performs no PM2 fetch and creates no registry.
- [x] Flox discovery returns each fixture project once and prunes nested `.flox` content.
- [x] PM2, environment, and path consumers reuse parent-shell snapshots.
- [x] Mutations invalidate PM2 and dependent registry/index state.
- [x] Atomic external registry replacement refreshes the in-memory index.
- [x] Failed or lock-busy refresh preserves a valid registry and returns within the configured bound.
- [x] CLI suites pass: startup/cache, config/cache, JSON/error handling, input validation, menu navigation.
- [x] Five-run medians meet targets: source `0.13s`, real `s x` `0.19s`, `m n` picker `0.30s`, `m r` picker `0.58s`.

## Real TTY proof

- [x] Gum path: `s m r` opens promptly; Ctrl-C cancellation returns without restart or error.
- [x] Bash fallback: `s m r` preserves the shared source order, selects the same exact environment value, and `x` cancels before filtering.
- [x] Navigate path: `s m n` opens promptly and Ctrl-C cancellation does not change directories.
- [x] Buffered input is drained without auto-selecting the next widget; an idle widget has no fixed 120ms delay.
- [x] Empty environment state returns a concise recoverable message and no widget.

## Safety

- [x] Automated fixtures use isolated state and project roots.
- [x] No real start, restart, rename, remove, or project deletion was used as test proof.
- [x] Registry temporary files are created beside the target, permissioned, validated, and atomically replaced.
