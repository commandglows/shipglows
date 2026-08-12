---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-12"
created_at: "2026-08-12 17:05:00 UTC"
updated: "2026-08-12"
updated_at: "2026-08-12 17:09:00 UTC"
status: reviewed
source_skill: 100-sg-spec
source_model: gpt-5.6
scope: shared-activation-cores-and-entitlement-doctrine-wave-12
owner: Diane
confidence: high
user_story: "As a ShipGlows maintainer, I want high-fan-out lifecycle and entitlement doctrine loaded progressively without weakening execution, authorization, or proof gates."
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/004-sg-deploy
  - skills/601-sg-product-entitlements
  - skills/references/master-workflow-lifecycle.md
  - skills/references/master-delegation-semantics.md
  - skills/references/product-entitlements-playbook.md
  - skills/references/skill-invocation-registry.json
depends_on:
  - artifact: shipglows_data/workflow/specs/release-entitlement-compaction-and-activation-profile-wave-10.md
    artifact_version: "1.1.0"
    required_status: reviewed
supersedes: []
evidence:
  - "The 004 multi-stage gate currently adds about 8.5k tokens from two shared references."
  - "The 601 entitlement gate currently adds about 4.4k tokens even when only one doctrine branch is needed."
next_step: "/005-sg-ship shared activation cores and entitlement doctrine wave 12"
---

# Title

Shared activation cores and entitlement doctrine — wave 12

# Status

Reviewed.

# User Story

As a ShipGlows maintainer, I want high-fan-out lifecycle and entitlement doctrine loaded progressively without weakening execution, authorization, or proof gates.

# Minimal Behavior Contract

Keep existing detailed lifecycle and delegation authorities compatible. Add compact decision cores for the release pilot, with full doctrine loaded only for detailed lifecycle or topology resolution. Keep entitlement invariants in the primary playbook and route ledger, ingestion, and support/proof procedures to direct conditional leaves.

# Success Behavior

- The ordinary `004` multi-stage decision loads compact lifecycle/delegation cores, not both detailed references.
- Detailed references remain addressable and authoritative when their explicit gate fires.
- `601` loads one compact primary doctrine, then at most one direct branch before action.
- Activation profiles measure every new gate without prose inference or duplicate counting.

# Error Behavior

Missing cores/leaves, ambiguous topology, unsafe parallel writes, duplicate ledgers, stale provider truth, or incomplete entitlement proof blocks instead of falling back to memory.

# Scope In

- compact shared lifecycle/delegation decision cores
- `004` progressive loaders and activation profile
- compact entitlement primary doctrine and direct leaves
- `601` progressive loaders and activation profile
- focused contracts, technical doctrine, spec, refresh log

# Scope Out

- bulk migration of every lifecycle consumer
- deletion or semantic replacement of the detailed shared references
- provider-policy changes
- automatic dependency inference from prose

# Constraints

- Runtime loaders remain authoritative; registry profiles remain accounting/preflight metadata.
- No local or shared leaf chains to another leaf.
- Security, authorization, proof, and mutation stops remain visible before action.

# Test Contract

Lifecycle core route/gate semantics, delegation topology/batch/receipt semantics, detailed-reference compatibility, entitlement identity/provider/ledger separation, provider/code safety, backend fail-closed behavior, support/proof scenarios, profile path validity, unique accounting, metadata/fidelity/budget/sync.

# Dependencies

Wave 10 and the canonical activation graph are reviewed and pushed.

# Invariants

- Identity never grants product access.
- Parallel writes require ready non-overlapping execution batches.
- A deployment status or UI state is never sufficient product proof.
- Detailed authorities remain directly loadable when risk or ambiguity requires them.

# Implementation Tasks

- [x] Add lifecycle and delegation decision cores and route `004` progressively.
- [x] Split entitlement procedure into direct ledger, ingestion, and support/proof leaves.
- [x] Update activation profiles and scenario-first contracts.
- [x] Refresh technical doctrine and close with measured evidence.

# Acceptance Criteria

- [x] Normal `004` multi-stage selected cost decreases from about 8,486 to 1,290 tokens.
- [x] Entitlement primary doctrine is about 1,368 estimated tokens.
- [x] Focused and compatibility contracts pass.
- [x] Metadata, fidelity, discovery budget, profile audit, graph, and runtime sync pass.

# Test Strategy

Focused unit contracts first, existing consumers second, repository audits and runtime sync last.

# Risks

Over-compaction could hide topology or authorization stops; activation-critical rules stay in cores or the `601` body/primary doctrine.

# Skill Run History

| Timestamp UTC | Skill | Mode | Outcome |
|---|---|---|---|
| 2026-08-12 17:05:00 | 100-sg-spec | create | Wave 12 contract created from measured activation-profile costs. |
| 2026-08-12 17:05:00 | 101-sg-ready | review | Ready: compatibility, security, proof, and accounting boundaries are explicit. |
| 2026-08-12 17:06:00 | 102-sg-start | execute | Added compatibility-preserving decision cores and three direct entitlement branches. |
| 2026-08-12 17:08:00 | 900-shipglows-core | refresh | Preserved detailed authorities, tightened direct-loader followability, and recorded profile costs. |
| 2026-08-12 17:09:00 | 103-sg-verify | verify | 83 focused/transverse tests, graph, metadata, fidelity, budget, profile, and Codex runtime sync passed. |
| 2026-08-12 17:09:00 | 104-sg-end | close | Wave 12 closed as reviewed; bulk consumer migration remains a later measured decision. |

# Current Chantier Flow

`100-sg-spec -> 101-sg-ready -> 102-sg-start -> 900 refresh -> 103-sg-verify -> 104-sg-end -> 005-sg-ship (next)`
