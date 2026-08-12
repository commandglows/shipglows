---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-12"
created_at: "2026-08-12 13:52:00 UTC"
updated: "2026-08-12"
updated_at: "2026-08-12 14:01:00 UTC"
status: reviewed
source_skill: 100-sg-spec
source_model: gpt-5-codex
scope: progressive-skill-activation-compaction-wave-3
owner: Diane
confidence: high
user_story: "As a ShipGlows maintainer, I want start, docs, and fix to load only the doctrine needed at the current gate so activation stays efficient without weakening lifecycle or mutation safety."
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/102-sg-start
  - skills/300-sg-docs
  - skills/106-sg-fix
  - skills/references/skill-instruction-layering.md
  - tools/
depends_on:
  - artifact: skills/references/skill-instruction-layering.md
    artifact_version: "1.3.0"
    required_status: active
  - artifact: skills/references/skill-context-budget.md
    artifact_version: "1.0.0"
    required_status: active
  - artifact: shipglows_data/workflow/specs/progressive-skill-activation-compaction-wave-2.md
    artifact_version: "1.1.0"
    required_status: reviewed
supersedes: []
evidence:
  - "2026-08-12 parallel read-only audit: 102 loads about 17k tokens before a direct decision and about 31k on common ready-spec paths."
  - "2026-08-12 parallel read-only audit: 300 always loads both governance and all mode playbooks, producing an avoidable local closure of about 11.6k tokens."
  - "2026-08-12 parallel read-only audit: 106 loads more than 17k tokens before mutation and repeats its local bug workflow."
  - "Operator continuation 2026-08-12: continue progressive skill efficiency work; installed-inventory overage and the global dependency graph remain deferred."
next_step: none
---

# Title

Progressive skill activation compaction - wave 3

# Status

Reviewed.

# User Story

As a ShipGlows maintainer, I want start, docs, and fix to load only the doctrine needed at the current gate so activation stays efficient without weakening lifecycle or mutation safety.

# Minimal Behavior Contract

Each owner body remains an independently followable activation contract. Mandatory references are limited to what is needed before the first decision; topology, mode, mutation, proof, and reporting detail load only at their explicit gate. A normal invocation loads no unrelated mode playbook.

# Scope In

- Compact `102-sg-start`, including decomposition of its monolithic execution workflow.
- Compact `300-sg-docs`, replacing the always-loaded mode compendium with bounded family routing.
- Compact `106-sg-fix`, deferring spec, decision, mutation, and proof references until their gates.
- Add focused scenario contracts and minimally adapt existing consumer tests.
- Refresh log, metadata lint, fidelity/budget audits, and runtime sync.

# Scope Out

- Installed full-catalog budget overage.
- Global dependency graph or activation manifest.
- Compaction of shared canonical references.
- Public routing, invocation names, catalog composition, or wrapper behavior.
- `001`, `103`, `600`, `700`, `104`, and `203`; these remain measured candidates for later waves.

# Constraints

- Keep activation-critical owner boundaries, stop conditions, verdict/result semantics, and mechanically consumed phrases local.
- Local references stay one level deep and split by decision gate, not by arbitrary length.
- A read-only or triage path must not load mutation-only doctrine.
- Preserve all existing names, modes, handoffs, public promises, and security rules.
- Parallel writes are limited to the non-overlapping batches below; the parent is the sole integrator.

# Test Contract

Proof path: `scenario-first`.

- `START-DIRECT`, `START-SPEC-FIRST`, `START-AUTO-VERIFY-ELIGIBLE`, `START-AUTO-VERIFY-SKIPPED`, `START-MALFORMED-REF`.
- `DOCS-SIMPLE`, `DOCS-GOVERNANCE`, `DOCS-PRIVATE-PROJECT`, `DOCS-PREFLIGHT`, `DOCS-ONE-FAMILY`.
- `FIX-DIAGNOSTIC-ONLY`, `FIX-DIRECT-BEFORE-WRITE`, `FIX-SPEC-FIRST`, `FIX-AMBIGUITY`, `FIX-VISUAL-PROOF`.
- Body targets: `102 <= 1600`, `300 <= 1600`, `106 <= 1500` estimated tokens.
- First-decision paths must prove that conditional references are not eagerly loaded.

# Invariants

- `102` owns execution of one ready work item and never upgrades partial or external proof to verified.
- `300` preserves content and governance authority according to its selected mode and always applies preflight before mutation.
- `106` never writes before classification, authority, proof-path, and applicable safety gates; visual resolution still requires rendered human validation.
- Passing technical checks never becomes product, security, auth, hosted, or production proof.

# Execution Batches

- Batch A - `skills/102-sg-start/**`, `tools/test_102_sg_start_compaction_contract.py`, and minimal existing `102` test adaptations.
- Batch B - `skills/300-sg-docs/**`, `tools/test_300_sg_docs_compaction_contract.py`, and minimal existing `300` test adaptations.
- Batch C - `skills/106-sg-fix/**`, `tools/test_106_sg_fix_compaction_contract.py`, and minimal existing `106` test adaptations.
- Batch D - integration docs, global validation, closure, commit, and push; parent only.

# Acceptance Criteria

- [x] All three activation bodies meet their token targets and retain local critical gates.
- [x] Direct/triage/simple modes avoid unrelated heavy references before the first decision.
- [x] New references are bounded, directly routed, metadata-valid, and do not chain locally.
- [x] Existing consumer tests and three new owner contracts pass.
- [x] Fidelity, implicit discovery budget, reference checks, sync, and diff checks pass.
- [x] No catalog-overage, dependency-graph, public-routing, or invocation behavior changes.

# Documentation Coherence

Update this spec and the refresh log only unless implementation discovers a changed public promise. No README or public help change is expected.

# Risks

- Over-extraction could allow execution or mutation before a safety gate is loaded.
- Moving prose without changing eager loaders would reduce body size but not activation cost.
- Exact-string tests can preserve phrases while losing sequence semantics; scenario tests must assert loading order and stop behavior.
- Splitting `102`'s execution workflow can create missing or cyclic links unless each route is mechanically checked.

# Implementation Tasks

- [x] Execute Batch A and validate `102` independently.
- [x] Execute Batch B and validate `300` independently.
- [x] Execute Batch C and validate `106` independently.
- [x] Integrate, refresh, verify, close, commit, and push only after combined evidence passes.

# Skill Run History

| Timestamp UTC | Skill | Mode | Outcome |
|---|---|---|---|
| 2026-08-12 13:52:00 | 100-sg-spec | create | Wave-3 contract created from three parallel read-only audits. |
| 2026-08-12 13:52:00 | 101-sg-ready | review | Ready: bounded owners, critical gates, scenario proof, token targets, and non-overlapping write batches are explicit. |
| 2026-08-12 13:54:00 | 102-sg-start | execute | Three write batches compacted start, docs, and fix while making their first-decision references conditional. |
| 2026-08-12 14:00:00 | 900-shipglows-core | refresh | Followability review repaired the docs mission/preflight signals and confirmed local critical gates plus direct one-level loaders. |
| 2026-08-12 14:01:00 | 103-sg-verify | verify | Owner and consumer tests, metadata, fidelity, budget, runtime sync, and diff checks passed. |
| 2026-08-12 14:01:00 | 104-sg-end | close | Wave closed without catalog, public routing, inventory-overage, or dependency-graph changes. |

# Current Chantier Flow

`100-sg-spec -> 101-sg-ready -> 102-sg-start -> 900 refresh -> 103-sg-verify -> 104-sg-end -> 005-sg-ship (next)`
