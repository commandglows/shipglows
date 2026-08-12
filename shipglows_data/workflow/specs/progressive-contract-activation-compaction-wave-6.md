---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-12"
created_at: "2026-08-12 15:40:00 UTC"
updated: "2026-08-12"
updated_at: "2026-08-12 16:15:39 UTC"
status: reviewed
source_skill: 100-sg-spec
source_model: gpt-5.6
scope: progressive-contract-activation-compaction-wave-6
owner: Diane
confidence: high
user_story: "As a ShipGlows maintainer, I want spec creation and readiness to load only the contract detail needed at each gate while preserving strict product, security, proof, and lifecycle decisions."
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/100-sg-spec
  - skills/101-sg-ready
  - skills/references/skill-instruction-layering.md
  - tools/
depends_on:
  - artifact: shipglows_data/workflow/specs/progressive-skill-activation-compaction-wave-5.md
    artifact_version: "1.1.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Measured 100 body ~3.3k tokens plus eager local workflow ~6.6k tokens."
  - "Measured 101 body ~2.7k tokens plus eager local readiness workflow ~3.7k tokens."
  - "107 and 108 remain next-wave candidates, but their local references are already bounded near 2k tokens."
next_step: none
---

# Title

Progressive contract activation compaction — wave 6

# Status

Reviewed.

# User Story

As a ShipGlows maintainer, I want spec creation and readiness to load only the contract detail needed at each gate while preserving strict product, security, proof, and lifecycle decisions.

# Minimal Behavior Contract

`100-sg-spec` remains the durable contract author and `101-sg-ready` remains the strict readiness verdict owner. Each keeps routing, safety, result semantics, and conditional authorities in its activation body while detailed intake, authoring, review, risk, transition, and reporting procedures load only after the corresponding gate is selected. Missing references or material ambiguity stop rather than falling back to memory.

# Success Behavior

- Direct/local routing does not load spec-authoring packs.
- Spec creation loads intake before authoring and review/persistence only after a complete draft exists.
- Readiness loads baseline first; adversarial/security and transition/report packs load only at their gates.
- Existing reporting, OWASP, ZOMBIES, product, platform, metadata, and chantier consumers remain compatible.

# Error Behavior

- Missing or malformed local pack blocks the affected route.
- No contract is called ready through generous inference.
- Compaction never removes operator-owned product/technology decisions, security gates, proof requirements, or lifecycle ownership.

# Scope In

- `skills/100-sg-spec/**`
- `skills/101-sg-ready/**`
- focused owner and consumer tests
- this spec and `skills/REFRESH_LOG.md`

# Scope Out

- `107-sg-test` and `108-sg-browser` implementation
- dependency graph and preflight extension
- shared-reference compaction
- public routing and installed catalog

# Constraints

- Bodies target at most 1,700 tokens.
- At most one local pack loads before the first substantive decision.
- Local references do not chain to local references.
- Compatibility index files remain on disk for direct readers.

# Test Contract

- scenario-first owner tests for direct route, spec intake, authoring, readiness baseline, risk/security review, transition, missing refs, and reporting compatibility
- existing reporting, OWASP, ZOMBIES, guided product discovery, lifecycle, invocation, metadata, budget, and sync checks

# Dependencies

- `skill-instruction-layering.md` v1.3.0
- Wave 5 reviewed state
- fresh-docs not needed: this is local instruction packaging

# Invariants

- `100` never implements or approves readiness.
- `101` never implements, verifies completion, closes, or ships.
- A ready verdict requires a fresh agent to implement without blocking ambiguity.
- Security/product/platform/proof gaps cannot be hidden by compaction.

# Links & Consequences

- `001-sg-build`, `102-sg-start`, `103-sg-verify`, reporting tests, and expert invocation remain consumers.
- `107/108` become the next candidate tranche after this wave.

# Documentation Coherence

Update this spec and refresh log only; public behavior is unchanged.

# Edge Cases

- No spec candidate or several plausible candidates.
- Atomic work that should route locally without spec ceremony.
- Greenfield platform/stack decision missing operator agreement.
- Internet-facing scope without an OWASP gate.
- Existing compatibility reader opens the former monolithic workflow path.

# Implementation Tasks

- [x] Compact `100` into direct intake, authoring, and review/persistence packs.
- [x] Compact `101` into baseline, risk, and transition/report packs.
- [x] Add owner scenario contracts and preserve direct consumers.
- [x] Run metadata, fidelity, budget, sync, and diff checks.

# Acceptance Criteria

- [x] `100` and `101` bodies are each <=1,700 estimated tokens.
- [x] First-decision local closure is materially smaller than baseline.
- [x] Compatibility index files remain present and non-eager.
- [x] Critical product, platform, OWASP, ZOMBIES, proof, status, and reporting strings remain mechanically covered.
- [x] No public-routing, graph, or catalog change occurs.

# Test Strategy

Focused unit contracts first, existing consumers second, then metadata/fidelity/budget/runtime sync.

# Risks

- Over-extraction could hide a readiness blocker or operator decision.
- Compatibility tests directly read legacy local workflow paths.
- A compact pack could duplicate shared doctrine and create drift.

# Execution Notes

Keep decisions and stops local. Put checklists/templates in direct leaf references. Preserve legacy paths as small compatibility indexes, never as eager execution dependencies.

# Open Questions

None.

# Skill Run History

| Timestamp UTC | Skill | Mode | Outcome |
|---|---|---|---|
| 2026-08-12 15:40:00 | 100-sg-spec | create | Wave 6 contract created and made ready from measured activation costs. |
| 2026-08-12 15:40:00 | 101-sg-ready | review | Ready: scope, invariants, pressure scenarios, targets, and compatibility boundaries are explicit. |
| 2026-08-12 16:05:00 | 102-sg-start | execute | Compacted both owners into direct leaf packs and retained compatibility indexes. |
| 2026-08-12 16:12:00 | 900-shipglows-core | refresh | Restored exact canonical authority loaders and verified semantic preservation against former contracts. |
| 2026-08-12 16:15:39 | 103-sg-verify | verify | Owner and consumer contracts, metadata, fidelity, budget, and Codex runtime sync passed. |
| 2026-08-12 16:15:39 | 104-sg-end | close | Wave 6 closed as reviewed; 107/108 remain the measured next tranche. |

# Current Chantier Flow

`100-sg-spec -> 101-sg-ready -> 102-sg-start -> 900 refresh -> 103-sg-verify -> 104-sg-end -> 005-sg-ship (next)`
