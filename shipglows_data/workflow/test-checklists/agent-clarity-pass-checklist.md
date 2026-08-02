---
artifact: test_checklist
metadata_schema_version: "1.0"
artifact_version: "1.0.1"
project: ShipGlows
created: "2026-06-27"
updated: "2026-07-15"
status: active
source_skill: 009-sg-skill-build
scope: agent-clarity-pass
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - shipglows_data/technical/agent-clarity-pass-playbook.md
  - shipglows_data/technical/skill-runtime-and-lifecycle.md
  - shipglows_data/workflow/specs/agent-clarity-pass-playbook-and-checklist.md
depends_on:
  - artifact: "shipglows_data/technical/agent-clarity-pass-playbook.md"
    artifact_version: "1.0.0"
    required_status: "active"
supersedes: []
evidence:
  - "Checklist created after the 2026-06 multi-phase clarity campaign to make future sweeps repeatable."
next_step: "/900-shipglows-core build start the next bounded agent-clarity phase with this checklist"
---

# Agent Clarity Pass Checklist

## Usage

Use this checklist for the next ShipGlows agent-clarity pass.

- Reset statuses or copy the file into a pass-specific checklist if you want a
  durable run record.
- Treat `Required = yes` rows as mandatory for calling the pass complete.
- Add concrete notes and evidence pointers when a row fails or blocks.

## Scenarios

| Scenario ID | Surface | Scenario | Required | Expected | Status | Observed | Evidence pointer | Notes | Bug Link |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ACP-001 | Intake | The ambiguity is described as a real pressure scenario, not a vague cleanup wish. | yes | The pass names the confused skills, the likely wrong action, and the operational reason to fix it. | NOT_RUN |  |  |  |  |
| ACP-002 | Scope | The pass is split into a bounded batch rather than a broad corpus rewrite. | yes | The active phase touches only the smallest justified cluster of skills. | NOT_RUN |  |  |  |  |
| ACP-003 | Skill contract | Each touched skill answers one operator question on the first screen. | yes | The first screen contains an explicit operator question per touched skill. | NOT_RUN |  |  |  |  |
| ACP-004 | Skill contract | Each touched skill states what it owns. | yes | Artifact/decision/state ownership is explicit near the mission. | NOT_RUN |  |  |  |  |
| ACP-005 | Skill contract | Each touched skill exposes `Keep the boundary explicit`. | yes | Nearby roles and immediate handoffs are visible. | NOT_RUN |  |  |  |  |
| ACP-006 | Skill contract | Each touched skill says what it does not own. | yes | A clear `does not` sentence prevents role creep. | NOT_RUN |  |  |  |  |
| ACP-007 | Shared taxonomy | The shared taxonomy doc was updated when family wording changed. | yes | `shipglows_data/technical/skill-runtime-and-lifecycle.md` reflects the same boundaries as the local skills. | NOT_RUN |  |  |  |  |
| ACP-008 | Separation | The pass stayed separate from compaction or unrelated hardening. | yes | No unrelated corpus-compaction or bootstrap refactor was mixed into the batch. | NOT_RUN |  |  |  |  |
| ACP-009 | Validation | Audit, budget, metadata, and runtime visibility checks were run. | yes | Required validation commands are green or explicitly blocked with evidence. | NOT_RUN |  |  |  |  |
| ACP-010 | Transversal audit | A short final scan looked for duplicate or contradictory role claims. | yes | No duplicate role bullet or unresolved overlap remains after the batch. | NOT_RUN |  |  |  |  |
| ACP-011 | Learning capture | The pass records at least one reusable lesson for the next sweep. | yes | A playbook, review note, or spec update captures the lesson instead of leaving it in chat memory only. | NOT_RUN |  |  |  |  |
| ACP-012 | Closure | The tracker distinguishes the clarity campaign from follow-up institutionalization or unrelated work. | no | `TASKS.md` keeps the campaign context readable for future return. | NOT_RUN |  |  |  |  |

## Evidence

Fill this section during a future pass with:

- validation command pointers
- the active spec path
- the shared taxonomy diff if relevant
- the final transversal audit note
