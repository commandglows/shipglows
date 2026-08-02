---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-07-12"
created_at: "2026-07-12 21:16:08 UTC"
updated: "2026-07-12"
updated_at: "2026-07-12 21:18:58 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "900-shipglows-core conversation-derived execution-fidelity hardening"
owner: "Diane"
user_story: "As the ShipGlows operator, I want sg-core to convert observed execution failures into compact, mechanically proven system repairs, so critiques do not produce contradictory rules, repeated prose, or false confidence from generic audits."
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - "skills/900-shipglows-core/SKILL.md"
  - "skills/references/skill-execution-fidelity.md"
  - "skills/references/skill-instruction-layering.md"
  - "tools/audit_shipglows_skills.py"
  - "tools/test_900_shipglows_core_contract.py"
depends_on:
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "skills/references/skill-execution-fidelity.md"
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "In this conversation, sg-core initially reinforced several layers with repeated prose instead of compacting the owner contract and proving the failed scenario."
  - "The current 900 contract repeats its four-field improvement output three times and simultaneously says read-only by default while authorizing edits from operator criticism through a later exception."
  - "The generic skill audit can return no hard findings without testing whether a conversation-derived failure produces a compact repair."
next_step: "/005-sg-ship sg-core conversation fidelity hardening"
---

# Spec: SG Core Conversation Fidelity Hardening

## Title

SG Core Conversation Fidelity Hardening

## Status

ready

## User Story

As the ShipGlows operator, I want `900-shipglows-core` to convert observed execution failures into compact, mechanically proven system repairs, so critiques do not produce contradictory rules, repeated prose, or false confidence from generic audits.

## Minimal Behavior Contract

When `900-shipglows-core` receives a concrete execution critique, it treats that critique as authorization for a bounded ShipGlows repair unless the operator requests read-only analysis. Before editing, it names the pressure scenario, applies the shared Followability Gate, chooses the narrowest owner layer, and defines mechanical or scenario proof. The generic skill audit remains baseline evidence only and cannot prove the observed behavior fixed.

## Success Behavior

- One scope rule resolves audit-only versus bounded repair without an exception that contradicts the default.
- One owner section defines the reusable four-field finding output.
- Conversation-derived failures require pressure-scenario proof before completion.
- A focused automated contract test detects regression to duplicate output doctrine, stale tool naming, or generic-audit-only proof.

## Error Behavior

- If the pressure scenario cannot be made testable, the run records an explicit proof exception before editing.
- If a broad contract rewrite would be required, the run stops at the ready-spec boundary.
- Generic audit success never overrides a failing focused scenario.

## Scope In

- Compact `skills/900-shipglows-core/SKILL.md`.
- Add focused mechanical contract tests for the observed failure class.
- Update internal tool mapping and refresh trace where required.

## Scope Out

- Rewriting the generic audit engine broadly.
- Editing unrelated skills or public plugin packaging.
- Committing, pushing, or shipping.

## Constraints

- Remove more duplicated activation prose than is added.
- Keep owner-specific behavior local; reuse the existing shared Followability Gate.
- Preserve invocation name, internal-only policy, packaging rules, and security boundaries.

## Test Contract

- Primary proof: `python3 -m unittest tools.test_900_shipglows_core_contract`.
- Baseline proof: generic skill audit, budget audit, metadata lint, runtime sync, and diff check.
- Pressure scenario: given an operator critiques sg-core execution, when repair is authorized, then a fresh agent can identify the bounded edit route and focused proof without following contradictory defaults or repeated output blocks.

## Dependencies

- Local ShipGlows contracts only.
- Fresh external docs: `fresh-docs not needed`.

## Invariants

- `900-shipglows-core` remains internal-only.
- Broad edits still require a ready spec.
- Audit-only requests stay read-only.
- Generic audit output is advisory baseline evidence.

## Links & Consequences

- Upstream: operator critique and `900-shipglows-core` activation.
- Downstream: `009-sg-skill-build`, focused proof, and future skill-fidelity repairs.
- Documentation: internal code-docs map and refresh log only; no public surface change.

## Implementation Tasks

- [x] Task 1: Compact the activation contract and remove contradictory/repeated rules.
- [x] Task 2: Add focused contract regression tests for the observed failure class.
- [x] Task 3: Update internal mapping and refresh trace.
- [x] Task 4: Run bounded verification and record results.

## Acceptance Criteria

- [x] AC 1: The four required system-improvement fields have one canonical definition in `900`.
- [x] AC 2: The scope gate has one unambiguous rule for audit-only versus critique-triggered repair.
- [x] AC 3: `900` states that the generic audit is baseline evidence, not focused completion proof.
- [x] AC 4: A conversation-derived failure requires a named pressure scenario and mechanical/scenario proof before editing or completion.
- [x] AC 5: Validation uses `audit_shipglows_skills.py` only and includes the focused contract test.
- [x] AC 6: The final `900` activation body is shorter than its 162-line baseline.
- [x] AC 7: Generic audit, budget, metadata, runtime sync, focused tests, and diff checks pass.

## Test Strategy

- Unit: focused Markdown contract tests.
- Contract: uniqueness and stale-name assertions.
- Integration: generic audit and runtime visibility checks.
- Manual: compare the activation path against the conversation pressure scenario.

## Risks

- Brittle prose tests: assert durable semantic markers and uniqueness, not full sentences.
- Over-compaction: preserve local scope, stop, packaging, and validation gates.
- Dirty worktree overlap: edit only the bounded files and preserve the active `300-sg-docs` changes.

## Execution Notes

- Apply `skill-instruction-layering.md` before local edits.
- Do not broaden `audit_shipglows_skills.py` merely to make the test pass.
- Keep the generic audit as baseline signal and add focused proof beside it.

## Open Questions

None

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-07-12 21:16:08 UTC | 100-sg-spec | GPT-5 Codex | Created the bounded sg-core conversation-fidelity hardening contract from the observed failure | draft | /101-sg-ready shipglows_data/workflow/specs/sg-core-conversation-fidelity-hardening.md |
| 2026-07-12 21:16:08 UTC | 101-sg-ready | GPT-5 Codex | Confirmed the user story, bounded scope, pressure scenario, proof contract, invariants, and no unresolved decisions | ready | /009-sg-skill-build shipglows_data/workflow/specs/sg-core-conversation-fidelity-hardening.md |
| 2026-07-12 21:16:30 UTC | 900-shipglows-core | GPT-5 Codex | Audited its conversation behavior and identified repeated doctrine, contradictory scope, stale validation naming, and generic-proof overclaim | supported | /009-sg-skill-build shipglows_data/workflow/specs/sg-core-conversation-fidelity-hardening.md |
| 2026-07-12 21:17:00 UTC | 009-sg-skill-build | GPT-5 Codex | Compacted the sg-core activation contract, added focused regression proof, and updated internal mapping | implemented | /307-sg-skills-refresh 900-shipglows-core |
| 2026-07-12 21:18:00 UTC | 307-sg-skills-refresh | GPT-5 Codex | Compared the bounded repair against current local governance; retained the compact repair with no external or decorative additions | refreshed | /103-sg-verify shipglows_data/workflow/specs/sg-core-conversation-fidelity-hardening.md |
| 2026-07-12 21:18:58 UTC | 103-sg-verify | GPT-5 Codex | Verified all acceptance criteria with focused tests, uniqueness checks, generic audit, budget, metadata, runtime sync, and diff checks | verified | /005-sg-ship sg-core conversation fidelity hardening |

## Current Chantier Flow

- `100-sg-spec`: done.
- `101-sg-ready`: ready.
- `009-sg-skill-build`: implemented.
- `307-sg-skills-refresh`: complete; local governance only.
- `103-sg-verify`: verified.
- `104-sg-end`: pending.
- `005-sg-ship`: not authorized.

Next step: `/005-sg-ship sg-core conversation fidelity hardening`
