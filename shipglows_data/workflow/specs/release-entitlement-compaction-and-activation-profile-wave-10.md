---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-12"
created_at: "2026-08-12 17:05:00 UTC"
updated: "2026-08-12"
updated_at: "2026-08-12 17:14:00 UTC"
status: reviewed
source_skill: 100-sg-spec
source_model: gpt-5.6
scope: release-entitlement-compaction-and-activation-profile-wave-10
owner: Diane
confidence: high
user_story: "As a ShipGlows maintainer, I want release and entitlement skills compacted with explicit measurable reference gates rather than prose-inferred dependency loading."
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/004-sg-deploy
  - skills/601-sg-product-entitlements
  - tools/skill_activation_budget.py
  - tools/skill_invocation_check.py
depends_on:
  - artifact: shipglows_data/workflow/specs/canonical-skill-activation-graph-and-core-compaction-wave-9.md
    artifact_version: "1.1.0"
    required_status: reviewed
supersedes: []
evidence:
  - "004 loaded seven shared/local references before execution and had a ~2.4k-token body."
  - "601 duplicated a ~4.4k-token entitlement doctrine inside a ~2.1k-token body."
  - "Wave 9 intentionally deferred reference-activation profiles until a measured pilot."
next_step: "/005-sg-ship release entitlement compaction and activation profile wave 10"
---

# Title

Release and entitlement compaction with activation profiles — wave 10

# Status

Reviewed.

# User Story

As a ShipGlows maintainer, I want release and entitlement skills compacted with explicit measurable reference gates rather than prose-inferred dependency loading.

# Minimal Behavior Contract

`004` retains ordered release truth, production safety, evidence, verification, and reporting boundaries. `601` retains identity/entitlement separation, fail-closed authorization, provider/code/mirror safety, and owner routing. Registry profiles declare body, baseline, and named gates; runtime loaders remain authoritative.

# Success Behavior

- `004` body <=1,600 tokens and defers release/proof/lifecycle packs to their gates.
- `601` body <=1,400 tokens and reuses canonical entitlement doctrine.
- Profile accounting counts shared paths once and reports baseline, each gate, and worst case.
- Selected explicit invocations block on a broken declared profile.

# Error Behavior

Missing profile paths, missing deployment truth/proof, unsafe production mutation, stale provider truth, or ambiguous authorization blocks instead of falling back to memory.

# Scope In

- `skills/004-sg-deploy/**`
- `skills/601-sg-product-entitlements/**`
- registry activation-profile pilot and tooling/tests
- directly affected technical doctrine, this spec, refresh log

# Scope Out

- general profiles for all skills
- shared mega-reference compaction
- installed discovery-budget remediation

# Constraints

- Same registry; no second dependency file.
- No prose parsing.
- Runtime loaders remain the execution contract.

# Test Contract

Release gate order, proof and reporting, production safety, entitlement fail-closed behavior, profile path failure, unique accounting, direct-script execution, existing owner consumers, metadata/fidelity/budget/sync.

# Dependencies

Wave 9 reviewed and pushed. Fresh docs not needed because provider behavior is unchanged.

# Invariants

- A push/deploy/HTTP response is not release proof.
- Identity never grants entitlement by itself.
- Broken selected profiles block preflight.
- Shared references are counted once.

# Links & Consequences

Public `sg-release`, expert entitlement routing, lifecycle masters, OWASP, reporting, and engineering ownership depend on these contracts.

# Documentation Coherence

Context budget, layering, invocation preflight, runtime lifecycle, and code-docs map describe the bounded profile pilot.

# Edge Cases

- `skip-check` cannot skip ship/deploy/proof/verify.
- Hosted proof lacks a matching deploy target.
- Activation code is persisted client-side.
- Mirror remains active after revoke.
- Direct script execution has a different Python import root than module execution.

# Implementation Tasks

- [x] Compact `004` and activate its release/proof references.
- [x] Compact `601` around canonical entitlement doctrine.
- [x] Add two registry profiles, profile accounting, and selected-profile preflight.
- [x] Add scenario contracts and update technical doctrine.

# Acceptance Criteria

- [x] Body token targets pass.
- [x] Profile audit and direct invocation preflight pass.
- [x] Safety, proof, reporting, ownership, and compatibility consumers pass.
- [x] Metadata, fidelity, budget, runtime sync, and diff checks pass.

# Test Strategy

Owner scenarios, profile unit/direct CLI tests, existing consumers, then repository audits.

# Risks

Profiles could become a second runtime authority; doctrine explicitly keeps runtime loaders authoritative and profiles accounting-only.

# Execution Notes

The pilot exposes large shared baseline/gate references as measured future candidates; it does not auto-split them.

# Open Questions

Generalize only after another pilot confirms the schema and shared-reference costs are reduced.

# Skill Run History

| Timestamp UTC | Skill | Mode | Outcome |
|---|---|---|---|
| 2026-08-12 17:05:00 | 100-sg-spec | create | Wave 10 contract created from measured release and entitlement closure. |
| 2026-08-12 17:06:00 | 101-sg-ready | review | Ready: runtime/profile authority and security/proof boundaries are explicit. |
| 2026-08-12 17:10:00 | 102-sg-start | execute | Compacted both skills and implemented two explicit activation profiles with accounting. |
| 2026-08-12 17:12:00 | 900-shipglows-core | refresh | Restored reporting compatibility and fixed direct-script import portability. |
| 2026-08-12 17:14:00 | 103-sg-verify | verify | Owner/profile/consumer tests, metadata, fidelity, budget, and runtime sync passed. |
| 2026-08-12 17:14:00 | 104-sg-end | close | Wave 10 closed as reviewed; shared mega-refs and discovery budget remain separate. |

# Current Chantier Flow

`100-sg-spec -> 101-sg-ready -> 102-sg-start -> 900 refresh -> 103-sg-verify -> 104-sg-end -> 005-sg-ship (next)`
