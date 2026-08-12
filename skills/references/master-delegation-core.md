---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 900-shipglows-core
scope: master-delegation-core
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/004-sg-deploy/SKILL.md
  - skills/references/master-delegation-semantics.md
depends_on: []
supersedes: []
evidence:
  - "Wave 12 measured the detailed delegation reference as too costly for an ordinary topology choice."
next_review: "2026-11-12"
next_step: none
---

# Master Delegation Core

Use this core for the first topology decision. Load detailed `skills/references/master-delegation-semantics.md` when model application, degraded execution, nested receipts, overlapping ownership, or batch construction needs rules not resolved here.

## Topology Decision

- Use `main-only` for one narrow action where delegation adds no meaningful evidence or isolation.
- Run two or more independent read-only scopes in parallel by default under a selected matrix that names scope, read-only constraint, requested evidence, and integration owner.
- Use `delegated sequential` for mutations by default.
- Use `write-batch parallel` only when a ready spec defines non-overlapping `Execution Batches`, dependency order, per-batch validation, and one integration owner before dispatch.
- Use `degraded` when requested delegation or model application is unavailable; report the limitation and never claim it was applied.

Subagents receive a bounded mission, owned and forbidden files, proof obligation, stop conditions, and return contract. The main orchestrator resolves conflicts, integrates changes, runs final validation, and owns the final claim.

## Safety And Receipt

Stop for ambiguous scope, unavailable required delegation, overlapping writes, missing ready batches, unresolved permissions/data/destructive/closure/staging/ship changes, or unrelated dirty files.

Executable work retains `topology`, `agents_dispatched`, `model_status`, the applicable `read_only_batch_matrix` or `write_execution_batches`, and `integration_result`. Count only directly dispatched successful agents. User reporting emits `Agents: <count> · <main-only|delegated sequential|read-only parallel|write-batch parallel|degraded>` when topology matters.

