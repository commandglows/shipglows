---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-06-27"
updated: "2026-06-27"
status: active
source_skill: 900-shipglows-core
scope: shipglows-owned-preflight
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/
  - tools/
  - templates/
  - shipglows_data/
depends_on:
  - artifact: "skills/references/canonical-paths.md"
    artifact_version: "1.2.0"
    required_status: "active"
supersedes: []
evidence:
  - "2026-06-27 hardening sweep: the same ShipGlows-owned preflight was repeated across multiple critical execution skills."
  - "Operator decision 2026-06-27: extract the repeated preflight into a shared reference and keep only compact local anchors."
next_review: "2026-07-04"
next_step: "/103-sg-verify shipglows-owned-preflight adoption"
---

# ShipGlows-Owned Preflight

Apply this doctrine before reading a ShipGlows-owned reference, running a ShipGlows-owned tool/script, or mutating/verifying a ShipGlows-owned surface.

## Preflight Order

1. Resolve `SHIPGLOWS_ROOT="${SHIPGLOWS_ROOT:-$HOME/shipglows}"`.
2. Confirm the owned parent path exists under `$SHIPGLOWS_ROOT`.
3. Confirm the target reference, tool, script, or owned surface exists at its canonical ShipGlows path.
4. Only then read, run, mutate, or verify it.

## Rules

- Do not infer `skills/`, `tools/`, `templates/`, or shared workflow-doc paths from the current project repository.
- If this preflight is still agent-runnable, do not ask the operator to inspect or run the ShipGlows-owned file instead.
- If a required ShipGlows-owned reference or tool is missing, stop and report the canonical missing path instead of continuing from memory or partial local context.
- Keep a compact local anchor in high-leverage skills so the preflight remains visible in the first activation screen even when the detailed doctrine lives here.
