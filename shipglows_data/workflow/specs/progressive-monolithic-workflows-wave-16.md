---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: reviewed
source_skill: 100-sg-spec
scope: progressive-monolithic-workflows-wave-16
owner: Diane
confidence: high
user_story: "As a ShipGlows maintainer, I want five costly workflows to load only the phase needed for the current decision while preserving their safety and proof contracts."
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/200-sg-redact/
  - skills/201-sg-enrich/
  - skills/400-sg-audit/
  - skills/405-sg-prod/
  - skills/109-sg-auth-debug/
  - skills/references/skill-invocation-registry.json
depends_on:
  - artifact: shipglows_data/workflow/specs/shared-baseline-core-compaction-wave-15.md
    artifact_version: "1.0.0"
    required_status: reviewed
supersedes: []
evidence:
  - "The five selected workflows each cost roughly 5,870 to 7,196 estimated tokens and are loaded monolithically."
  - "Wave 16 replaces the five monoliths with 672 to 827-token compatibility cores and direct non-chaining leaves."
  - "Five explicit activation profiles measure selected baselines from 2,097 to 3,544 estimated tokens."
next_step: "/005-sg-ship progressive monolithic workflows wave 16"
---

# Progressive Monolithic Workflows — Wave 16

## Status

Reviewed. Implementation, refresh, verification, and closure are complete; shipping is next.

## Minimal Behavior Contract

Preserve each established workflow path as a compact compatibility core or index. Keep activation-critical ownership, authority, security, proof, and stop decisions in the skill body or core. Move phase and scenario procedure into direct conditional leaves that never chain to siblings.

## Scope

- `200-sg-redact/references/redaction-workflow.md`
- `201-sg-enrich/references/enrichment-workflow.md`
- `400-sg-audit/references/audit-master-workflow.md`
- `405-sg-prod/references/production-verification-workflow.md`
- `109-sg-auth-debug/references/auth-debug-workflow.md`
- focused owner, activation-profile, metadata, graph, fidelity, budget, and runtime-sync proof

## Acceptance Criteria

- [x] Each compatibility workflow is materially smaller and routes bounded direct leaves.
- [x] No new local leaf loads a sibling leaf.
- [x] Security, redaction, tenant, production, auth, evidence, and mutation stops remain activation-visible.
- [x] Existing consumers keep the canonical workflow paths.
- [x] Focused and transversal tests, graph, metadata, fidelity, budget, and Codex sync pass.

## Tasks

- [x] Compact redact and enrich workflows.
- [x] Compact audit and production verification workflows.
- [x] Compact auth-debug workflow.
- [x] Register truthful activation profiles and measurements.
- [x] Refresh documentation, verify, and close; leave commit and push to the shipping gate.

## Measured Result

| Owner | Compatibility core before | Compatibility core after | Selected baseline after |
|---|---:|---:|---:|
| `200-sg-redact` | 7,196 | 827 | 2,222 |
| `201-sg-enrich` | 6,607 | 808 | 2,097 |
| `400-sg-audit` | 6,524 | 672 | 2,961 |
| `405-sg-prod` | 6,189 | 727 | 2,821 |
| `109-sg-auth-debug` | 5,870 | 799 | 3,544 |

Each of the five new activation profiles declares the owner body, its true mandatory baseline, and bounded gates for direct leaves. Leaves remain independently selectable and never load sibling leaves.

## Skill Run History

| Timestamp UTC | Skill | Mode | Outcome |
|---|---|---|---|
| 2026-08-12 | 100-sg-spec | create | Wave 16 contract created for five monolithic workflows. |
| 2026-08-12 | 101-sg-ready | review | Ready: owners, invariants, compatibility paths, budgets, and proof are explicit. |
| 2026-08-12 | 102-sg-start | execute | Five compatibility cores and their bounded direct leaves implemented. |
| 2026-08-12 | 900-shipglows-core | refresh | Activation profiles, documentation, metadata, and focused contracts refreshed. |
| 2026-08-12 | 103-sg-verify | verify | Focused owner, profile, graph, metadata, budget, fidelity, and sync proof passed. |
| 2026-08-12 | 104-sg-end | close | Acceptance criteria closed with shipping retained as the next lifecycle gate. |

## Current Chantier Flow

`100-sg-spec -> 101-sg-ready -> 102-sg-start -> 900 refresh -> 103-sg-verify -> 104-sg-end -> 005-sg-ship (next)`
