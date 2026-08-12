---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
created_at: "2026-08-12 15:20:00 UTC"
updated: "2026-08-12"
updated_at: "2026-08-12 15:20:00 UTC"
status: ready
source_skill: 100-sg-spec
source_model: gpt-5-codex
scope: progressive-skill-activation-compaction-wave-5
owner: Diane
confidence: high
user_story: "As a ShipGlows maintainer, I want helper and discovery/closure/research owners to keep exploration, closure, and report synthesis efficient with only the necessary immediate doctrine loaded."
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/700-sg-explore
  - skills/104-sg-end
  - skills/203-sg-research
  - skills/references/skill-instruction-layering.md
depends_on:
  - artifact: skills/references/skill-instruction-layering.md
    artifact_version: "1.3.0"
    required_status: active
  - artifact: shipglows_data/workflow/specs/progressive-lifecycle-activation-compaction-wave-4.md
    artifact_version: "1.1.0"
    required_status: reviewed
supersedes: []
evidence:
  - "700 currently embeds full exploration workflow and report procedures in activation body."
  - "104 currently exposes full tracker/changelog closure steps in activation body and lacks explicit compacted contract segmentation."
  - "203 currently keeps full research workflow in body and does not clearly separate execution playbook from activation contract."
next_step: none
---

# Title

Progressive skill activation compaction - wave 5

# Status

Ready.

# Minimal Behavior Contract

`700`, `104`, and `203` keep only activation-critical boundaries in their local `SKILL.md` and move optional posture, workflow, bookkeeping, and reporting detail to bounded skill-local references.

## Scope In

- Compact `700-sg-explore` so exploration posture and report persistence behavior are bounded by `Required References`.
- Compact `104-sg-end` while preserving report-step compatibility and closure status semantics.
- Compact `203-sg-research` with explicit source, freshness, and report-template flow.
- Add dedicated compactness contracts for all three owners.

## Scope Out

- Shared doctrine refactors in `skills/references/*`.
- Installed catalog overage and full dependency graph reduction.
- Public routing or wrapper behavior changes.
- Marketing, SEO, or enterprise research macro-owners (`009`, `205` etc.).

## Constraints

- Keep one local reference per activation gate where possible.
- Preserve explicit stop conditions that prevent implementation, false completion, or unsourced claims.
- Preserve required `### Step 5 — Report` / `### Rules` block in 104 to keep reporting contract compatibility.
- No local reference may load another local reference directly.

## Test Contract

- Scenario-first proof with new owner-contract tests for each updated skill.
- `203` and `700` must still load their required shared references when material questions, freshness, or claims imply.
- Closure contract remains aligned with `test_reporting_contract` expectations.

## Invariants

- `700-sg-explore` never mutates implementation, task trackers, or ship state.
- `104-sg-end` never claims proof it does not own and keeps completion language bounded by evidence.
- `203-sg-research` emits source-backed research and explicit uncertainty when evidence conflicts.

## Execution Batches

- Batch A - `skills/700-sg-explore/**`, `tools/test_700_sg_explore_compaction_contract.py`.
- Batch B - `skills/104-sg-end/**`, `tools/test_104_sg_end_compaction_contract.py`.
- Batch C - `skills/203-sg-research/**`, `tools/test_203_sg_research_compaction_contract.py`.

## Acceptance Criteria

- [ ] activation contract targets:
  - `700 <= 1400` tokens estimated,
  - `104 <= 1600` tokens estimated,
  - `203 <= 1300` tokens estimated.
- [ ] one local playbook per owner, no local ref chaining.
- [ ] all new and adapted owner tests validate required headings, guardrails, and markers.
- [ ] `test_reporting_contract` remains aligned for `104-sg-end`.
- [ ] no public routing, catalog, or dependency-graph changes in this wave.

## Documentation Coherence

Update only this spec and refresh notes unless the implementation changes any user-facing promises.

## Implementation Tasks

- [ ] Execute Batch A.
- [ ] Execute Batch B.
- [ ] Execute Batch C.
- [ ] Integrate and close.
