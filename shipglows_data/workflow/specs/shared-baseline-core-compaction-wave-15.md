---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
created_at: "2026-08-12 18:35:00 UTC"
updated: "2026-08-12"
updated_at: "2026-08-12 18:47:14 UTC"
status: reviewed
source_skill: 100-sg-spec
source_model: gpt-5.6
scope: shared-baseline-core-compaction-wave-15
owner: Diane
confidence: high
user_story: "As a ShipGlows maintainer, I want shared baseline doctrine to preserve its decisions while loading detailed placement, execution, and implementation procedure only when needed."
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/canonical-paths.md
  - skills/references/intent-to-outcome-autonomy.md
  - skills/references/decision-quality-contract.md
  - skills/references/skill-invocation-registry.json
  - tools/skill_activation_budget.py
depends_on:
  - artifact: shipglows_data/workflow/specs/high-traffic-activation-profiles-wave-14.md
    artifact_version: "1.0.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Wave 14 measured 010, 103, and 300 baselines at 11361, 9517, and 6791 tokens."
  - "Independent audits found separable placement, execution, scenario, and implementation detail in the three shared authorities."
next_step: "/005-sg-ship shared baseline core compaction wave 15"
---

# Title

Shared baseline core compaction — wave 15

# Status

Reviewed.

# Minimal Behavior Contract

Preserve the canonical paths of three shared authorities. Each original file becomes a compact decision core. Detailed procedure moves to direct conditional leaves that never chain to sibling leaves. Existing runtime loaders keep loading the core; explicit activation-profile gates expose the leaves without making them baseline-eager.

# Success Behavior

- `canonical-paths.md` retains root ownership, project/governance distinction, fail-closed resolution, and exact `## ShipGlows-Owned Tool Preflight`.
- `intent-to-outcome-autonomy.md` retains outcome ownership, target resolution, progressive clarification, authority boundaries, and direct execution/scenario routes.
- `decision-quality-contract.md` retains primary metrics plus exact Safety, Product, Operator Autonomy, Followability, Structure Replacement, and Fast Fix decision signals.
- Existing consumers continue through the unchanged canonical paths.
- Profile measurements demonstrate lower baselines without hiding required gates.

# Error Behavior

Missing safety/ownership/proof decisions, conditional leaves loaded eagerly, sibling chaining, compatibility-heading loss, path ambiguity, or profile/runtime drift block completion.

# Scope In

- compact cores and direct leaves for the three shared authorities
- activation-profile gates for conditional leaves
- scenario-first compatibility and budget tests
- Wave 15 trace, lifecycle docs, budget evidence, and refresh log

# Scope Out

- changing public ownership, modes, or implicit invocation
- weakening security, product, operator, proof, monorepo, or path-confinement rules
- full-corpus dependency debt
- compaction of downstream domain playbooks

# Acceptance Criteria

- [x] Canonical core ≤1,100 tokens; autonomy core ≤1,050; decision core ≤1,800.
- [x] Direct leaves exist, are mechanically routed, and never chain to siblings.
- [x] `004` and `300` selected baselines fall below 5,000 tokens.
- [x] `010` and `103` baselines fall materially and remain truthful.
- [x] Focused contracts, graph, metadata, fidelity, budget, and Codex sync pass.

# Implementation Tasks

- [x] Compact canonical paths and extract placement/runtime details.
- [x] Compact intent autonomy and extract execution plus pressure scenarios.
- [x] Compact decision quality and extract implementation discipline.
- [x] Update activation profiles and scenario contracts.
- [x] Refresh, verify, and close as reviewed; commit and push remain the ship gate.

# Measurements

Wave 15 reduces the six selected baselines to 3,128 tokens for `004`, 6,177
for `010`, 5,657 for `103`, 3,451 for `300`, 2,081 for `601`, and 2,487 for
`900`, before any conditional gate is selected. `004` and `300` now meet the
sub-5,000 activation-core target; `010` and `103` remain visible follow-up
hotspots rather than being misreported as compliant.

The retained cores own the first safe decision. Detailed runtime/private-root,
project-governance, outcome-execution, pressure-scenario, and implementation-
discipline branches remain direct conditional leaves and never chain to a
sibling leaf.

# Risks

The main risk is apparent savings caused by moving mandatory decisions behind optional gates. Every activation-critical owner, safety, path, question, and proof boundary must remain in the core. Leaves may contain procedure and pressure detail only.

# Skill Run History

| Timestamp UTC | Skill | Mode | Outcome |
|---|---|---|---|
| 2026-08-12 18:35:00 | 100-sg-spec | create | Wave 15 contract created for shared baseline core compaction. |
| 2026-08-12 18:35:00 | 101-sg-ready | review | Ready: targets, invariants, budgets, compatibility boundaries, and tests are explicit. |
| 2026-08-12 18:47:14 | 102-sg-start | implement | Compacted three shared authorities into compatibility-preserving cores and five direct conditional leaves. |
| 2026-08-12 18:47:14 | 900-shipglows-core | refresh | Reviewed path ownership, autonomy, decision quality, direct-leaf routing, and measured baseline reductions. |
| 2026-08-12 18:47:14 | 103-sg-verify | verify | Focused compatibility, non-chaining, graph, metadata, fidelity, budget, and runtime-sync contracts passed. |
| 2026-08-12 18:47:14 | 104-sg-end | close | Closed Wave 15 as reviewed; remaining 010 and 103 cost stays explicit for a later tranche. |

# Current Chantier Flow

`100-sg-spec -> 101-sg-ready -> 102-sg-start -> 900 refresh -> 103-sg-verify -> 104-sg-end -> 005-sg-ship (next)`
