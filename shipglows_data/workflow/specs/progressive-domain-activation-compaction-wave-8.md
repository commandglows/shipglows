---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-12"
created_at: "2026-08-12 16:30:00 UTC"
updated: "2026-08-12"
updated_at: "2026-08-12 16:36:00 UTC"
status: reviewed
source_skill: 100-sg-spec
source_model: gpt-5.6
scope: progressive-domain-activation-compaction-wave-8
owner: Diane
confidence: high
user_story: "As a ShipGlows maintainer, I want content and local-cloud sync skills to select their lane before loading lifecycle, governance, security, and proof detail."
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/007-sg-content
  - skills/600-sg-local-cloud-sync
depends_on:
  - artifact: shipglows_data/workflow/specs/progressive-proof-activation-compaction-wave-7.md
    artifact_version: "1.1.0"
    required_status: reviewed
supersedes: []
evidence:
  - "007 body measured ~3.3k tokens plus a ~2.7k eager local router and early shared lifecycle/delegation."
  - "600 body measured ~3.9k tokens and duplicated its existing doctrine and UX/security references."
next_step: "/005-sg-ship progressive domain activation compaction wave 8"
---

# Title

Progressive domain activation compaction — wave 8

# Status

Reviewed.

# User Story

As a ShipGlows maintainer, I want content and local-cloud sync skills to select their lane before loading lifecycle, governance, security, and proof detail.

# Minimal Behavior Contract

`007` preserves atomic short-circuit, explicit preflight, public-surface and claim truth, exact repurpose/capture modes, owner boundaries, and ship gates. `600` preserves loss prevention, account/tenant boundaries, merge/delete/offline policy, secret exclusion, sync-state truth, and proof-before-promise.

# Success Behavior

- `007` body <=1,800 tokens and routes before lifecycle/delegation.
- `600` body <=1,600 tokens and reuses conditional doctrine/security authorities.
- At most one local playbook loads before the first substantive action.
- Existing compatibility paths and consumer markers remain valid.

# Error Behavior

Missing surface, claim proof, account authority, merge/delete policy, provider truth, or required pack blocks rather than falling back to memory.

# Scope In

- `skills/007-sg-content/**`
- `skills/600-sg-local-cloud-sync/**`
- focused tests, this spec, refresh log

# Scope Out

- dependency graph, preflight implementation, public routing, catalog installation
- `900-shipglows-core` compaction
- changes to external product behavior

# Constraints

- Direct leaf packs; no local-reference chaining.
- Preserve lifecycle and reporting ownership.
- Validate previous exact authority loaders against the new corpus.

# Test Contract

Scenario-first tests for atomic content, repurpose aliases, undeclared surface, claims, sync loss/replay, latest-wins, secrets, entitlement, proof, reporting, and consumer compatibility.

# Dependencies

Wave 7 reviewed. Fresh external docs are not needed for local instruction packaging.

# Invariants

- Content claims never outrun source/product truth.
- Sync never silently loses or crosses account data.
- Mutation and ship remain with their established owners.

# Links & Consequences

Consumers include public `sg-content`, lifecycle/content specialists, `010-sg-technical`, and sync/product-access routes.

# Documentation Coherence

Update this spec and the refresh log only.

# Edge Cases

- Atomic wording edit explicitly invokes the public content label.
- Repurpose source requests exact verbatim preservation.
- Empty cloud belongs to a returning account.
- Latest-wins metadata is unreliable.
- Sync UI says synced before remote durability.

# Implementation Tasks

- [x] Compact `007` into lane, governance/quality, and delivery/proof packs.
- [x] Compact `600` around existing doctrine/security packs plus one proof/report leaf.
- [x] Add owner contracts and validate direct consumers.

# Acceptance Criteria

- [x] Token and first-action targets pass.
- [x] Critical claim, loss, security, ownership, and stop gates remain local.
- [x] Metadata, fidelity, budget, runtime sync, and diff checks pass.

# Test Strategy

Owner contracts, historical consumers, then metadata/fidelity/budget/runtime sync.

# Risks

Over-extraction could hide a claim blocker, allow premature lifecycle loading, or weaken account/data-loss safety.

# Execution Notes

Keep lane selection and safety local. Move editorial procedure, sync matrices, proof ladders, and report detail behind direct gates.

# Open Questions

None.

# Skill Run History

| Timestamp UTC | Skill | Mode | Outcome |
|---|---|---|---|
| 2026-08-12 16:30:00 | 100-sg-spec | create | Wave 8 contract created from measured activation costs. |
| 2026-08-12 16:30:00 | 101-sg-ready | review | Ready: content truth and sync data-safety invariants are explicit. |
| 2026-08-12 16:33:00 | 102-sg-start | execute | Compacted 007 and 600 into gated direct packs while retaining owner and safety boundaries. |
| 2026-08-12 16:34:00 | 900-shipglows-core | refresh | Compared former authority paths, activated verified sync doctrine, and restored compatibility markers. |
| 2026-08-12 16:36:00 | 103-sg-verify | verify | Owner and consumer contracts, metadata, fidelity, budget, and Codex runtime sync passed. |
| 2026-08-12 16:36:00 | 104-sg-end | close | Wave 8 closed as reviewed; core/preflight work remains separate. |

# Current Chantier Flow

`100-sg-spec -> 101-sg-ready -> 102-sg-start -> 900 refresh -> 103-sg-verify -> 104-sg-end -> 005-sg-ship (next)`
