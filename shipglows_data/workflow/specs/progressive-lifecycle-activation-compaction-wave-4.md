---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-12"
created_at: "2026-08-12 14:11:00 UTC"
updated: "2026-08-12"
updated_at: "2026-08-12 14:53:00 UTC"
status: reviewed
source_skill: 100-sg-spec
source_model: gpt-5-codex
scope: progressive-lifecycle-activation-compaction-wave-4
owner: Diane
confidence: high
user_story: "As a ShipGlows maintainer, I want build and verify to load lifecycle and verification detail only at the relevant gate while keeping orchestration and verdict safety immediately visible."
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/001-sg-build
  - skills/103-sg-verify
  - skills/references/master-workflow-lifecycle.md
  - skills/references/master-delegation-semantics.md
  - tools/
depends_on:
  - artifact: skills/references/skill-instruction-layering.md
    artifact_version: "1.3.0"
    required_status: active
  - artifact: shipglows_data/workflow/specs/progressive-skill-activation-compaction-wave-3.md
    artifact_version: "1.1.0"
    required_status: reviewed
supersedes: []
evidence:
  - "2026-08-12 read-only audit: 103 body is about 4.4k tokens and its baseline closure about 25.7k because five large references are effectively always loaded."
  - "2026-08-12 read-only audit: 001 body is about 3.9k tokens and its first-route closure about 26.9k because lifecycle and its local workflow load before routing."
  - "Operator continuation 2026-08-12: keep improving skill efficiency; inventory overage and the global dependency graph remain deferred."
next_step: none
---

# Title

Progressive lifecycle activation compaction - wave 4

# Status

Reviewed.

# Minimal Behavior Contract

`001` remains the story-to-ship orchestrator and `103` remains the verification verdict owner. Their activation bodies keep owner boundaries, lifecycle/result semantics, route selection, safety stops, and report contracts. Detailed topology, greenfield, proof, excellence, coherence, and report procedures load only after the corresponding route or gate is selected.

# Scope In

- Compact `001-sg-build` and its local lifecycle playbook into bounded one-level route references.
- Compact `103-sg-verify` and split verification gates into baseline plus conditional excellence/security/UI/runtime/coherence packs.
- Add focused scenario contracts and minimally adapt direct consumer tests.
- Refresh log, metadata lint, fidelity/budget audits, and Codex runtime sync.

# Scope Out

- Shared lifecycle/delegation doctrine compaction.
- Installed full-catalog budget overage or dependency graph.
- Public routing, aliases, invocation names, wrappers, or catalog composition.
- Other wave candidates (`700`, `104`, `203`, `600`, shared mega-references).

# Constraints

- Preserve exact strings mechanically consumed by existing reporting, excellence, clean-code, OWASP, ZOMBIES, guided-discovery, and delegation tests.
- No local reference may load another local reference.
- Critical verdict precedence, high/critical bug gates, tracker read-only rule, lifecycle continuation, ship authority, and UI/security proof stops remain local.
- Before-first-route loading must decrease; moving prose without delaying loaders is not success.

# Test Contract

Proof path: `scenario-first`.

- `BUILD-EARLY-REROUTE`, `BUILD-READY-SPEC`, `BUILD-GREENFIELD`, `BUILD-PROOF-OWNER`, `BUILD-CONTINUE-THROUGH-SHIP`.
- `VERIFY-STANDARD`, `VERIFY-EXCELLENCE`, `VERIFY-EXTERNAL-PROOF`, `VERIFY-HIGH-RISK-BLOCK`, `VERIFY-TRACKER-READONLY`, `VERIFY-SKILL-COHERENCE`.
- Body targets: `001 <= 2000`, `103 <= 1900` estimated tokens.
- Baseline first-decision closure is mechanically estimated and must be lower than the measured pre-change path.

# Invariants

- `001` never makes the operator manually schedule internal lifecycle owners after successful stages.
- `103` never turns partial, missing, stale, external, visual, auth, security, or production evidence into verified.
- Technical checks never substitute for product, security, visual, hosted, manual, or production proof.
- Neither compaction changes public promises or owner routing.

# Execution Batches

- Batch A - `skills/001-sg-build/**`, new `tools/test_001_sg_build_compaction_contract.py`, minimal direct 001 consumer adaptations.
- Batch B - `skills/103-sg-verify/**`, new `tools/test_103_sg_verify_compaction_contract.py`, minimal direct 103 consumer adaptations.
- Batch C - read-only consumer/pressure audit across existing tests; no file writes.
- Batch D - integration docs, refresh, validation, closure, commit, and push; parent only.

# Acceptance Criteria

- [x] Both activation bodies meet targets with local critical gates intact.
- [x] Early reroute and standard verification avoid unrelated route packs.
- [x] Local references are bounded, direct, metadata-valid, and non-chained.
- [x] Owner scenarios and existing direct consumers pass.
- [x] Fidelity, implicit budget, metadata, runtime sync, and diff checks pass.
- [x] No public-routing, inventory-overage, graph, or shared-doctrine change occurs.

# Documentation Coherence

Update this spec and the refresh log only unless a public promise changes. Fresh external docs are not required for local instruction packaging.

# Implementation Tasks

- [x] Execute and validate Batch A.
- [x] Execute and validate Batch B.
- [x] Integrate Batch C findings.
- [x] Refresh, verify, close, commit, and push after combined proof passes.

# Skill Run History

| Timestamp UTC | Skill | Mode | Outcome |
|---|---|---|---|
| 2026-08-12 14:11:00 | 100-sg-spec | create | Wave-4 lifecycle compaction contract created from the measured wave-3 audit. |
| 2026-08-12 14:11:00 | 101-sg-ready | review | Ready: owner boundaries, verdict gates, pressure scenarios, targets, and non-overlapping batches are explicit. |
| 2026-08-12 14:25:00 | 102-sg-start | execute | Parallel write batches compacted build and verify into direct conditional route packs. |
| 2026-08-12 14:45:00 | 900-shipglows-core | refresh | Independent compatibility review restored exact preflight, domain authority, canonical path, and topology loaders. |
| 2026-08-12 14:52:00 | 103-sg-verify | verify | Owner/consumer scenarios, metadata, fidelity, budget, sync, and diff checks passed; one optional Codex-runtime test remains environment-skipped. |
| 2026-08-12 14:53:00 | 104-sg-end | close | Lifecycle compaction closed without public routing, graph, inventory, or shared-doctrine changes. |

# Current Chantier Flow

`100-sg-spec -> 101-sg-ready -> 102-sg-start -> 900 refresh -> 103-sg-verify -> 104-sg-end -> 005-sg-ship (next)`
