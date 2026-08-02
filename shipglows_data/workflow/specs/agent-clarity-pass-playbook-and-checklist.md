---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "shipglows"
created: "2026-06-27"
created_at: "2026-06-27 00:00:00 UTC"
updated: "2026-06-27"
updated_at: "2026-06-27 00:00:00 UTC"
status: reviewed
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "agent-clarity-pass-playbook-and-checklist"
owner: "Diane"
user_story: "As the ShipGlows operator, I want a durable playbook and a reusable checklist for future agent-clarity passes, so the next sweep in six or twelve months starts from explicit method and captured lessons instead of memory."
confidence: high
risk_level: medium
security_impact: no
docs_impact: yes
linked_systems:
  - "shipglows_data/technical/skill-runtime-and-lifecycle.md"
  - "shipglows_data/technical/README.md"
  - "shipglows_data/technical/code-docs-map.md"
  - "shipglows_data/workflow/test-checklists/"
  - "shipglows_data/workflow/reviews/skill-system-hardening-register.md"
  - "shipglows_data/workflow/TASKS.md"
  - "tools/shipglows_metadata_lint.py"
depends_on:
  - artifact: "shipglows_data/technical/skill-runtime-and-lifecycle.md"
    artifact_version: "1.20.0"
    required_status: "reviewed"
  - artifact: "shipglows_data/workflow/reviews/skill-system-hardening-register.md"
    artifact_version: "0.1.0"
    required_status: "draft"
supersedes: []
evidence:
  - "2026-06-27 agent-clarity campaign completed bounded phases across owner, helper, pilotage, continuation, and residual helper surfaces."
  - "User request 2026-06-27: capture a future-facing playbook and checklist before declaring the campaign effectively closed."
  - "The current campaign learned repeatable heuristics: one operator question per skill, explicit stay-vs-handoff boundaries, explicit 'does not' lines, bounded phases, and a final transversal dedup pass."
  - "2026-06-27 bounded institutionalization slice completed with a reusable playbook, reusable checklist, indexed technical references, and a short closure review note."
next_step: "/009-sg-skill-build continue aggregate compaction after the phase-1 pilot"
---

# Title

Agent Clarity Pass Playbook And Checklist

## Status

ready

## User Story

As the ShipGlows operator, I want a durable playbook and a reusable checklist for future agent-clarity passes, so the next sweep in six or twelve months starts from explicit method and captured lessons instead of memory.

## Minimal Behavior Contract

ShipGlows must preserve the method of future clarity passes, not only the current wording outcome. The system needs one durable playbook that explains when and how to run a bounded clarity sweep, what a touched skill must expose on the first screen, how to batch work safely, how to validate, and how to capture the next lessons. It also needs one reusable checklist artifact that a future operator or agent can mark step by step during the pass.

## Success Behavior

- A technical playbook exists and explains the future clarity-pass method, batching rules, first-screen contract, validation, and after-action capture.
- A reusable checklist exists with required pass criteria and explicit statuses so a future clarity sweep can be run consistently.
- `shipglows_data/technical/README.md` points to the new playbook.
- `shipglows_data/technical/code-docs-map.md` remains coherent for future doc updates touching skill clarity doctrine.
- `TASKS.md` distinguishes the completed main clarity sweep from the new institutionalization slice.

## Error Behavior

- If the playbook stays vague and does not capture repeatable decisions from the 2026-06 campaign, reject it.
- If the checklist is too tied to one specific phase instead of a future pass, reject it.
- If the new docs imply that future passes should redo the whole corpus without bounded batching, reject it.

## Pressure Scenarios

- `FUTURE-SWEEP-COLD-START`: a new agent returns six months later and must know how to restart a clarity sweep without chat memory.
- `CLARITY-VS-COMPACTION`: a future sweep must separate role-boundary clarity from aggregate corpus compaction or other hardening work.
- `BATCH-WITHOUT-DRIFT`: a future pass must choose a small batch, update the shared taxonomy, and run a final transversal dedup check instead of editing everything at once.

## Scope In

- create one durable playbook under `shipglows_data/technical/`
- create one reusable checklist artifact under `shipglows_data/workflow/test-checklists/`
- update technical docs indexing as needed
- update task tracking to preserve campaign context

## Scope Out

- no new skill behavior changes
- no public site docs
- no broad rewrite of the existing hardening register
- no new audit tool implementation in this slice

## Test Contract

- `python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/agent-clarity-pass-playbook-and-checklist.md shipglows_data/technical/agent-clarity-pass-playbook.md shipglows_data/workflow/test-checklists/agent-clarity-pass-checklist.md shipglows_data/technical/README.md shipglows_data/technical/code-docs-map.md`
- focused `rg` checks for `operator question`, `stay here`, `hand off`, `does not`, `bounded phase`, `transversal dedup`, and `lessons`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`

## Implementation Tasks

- [x] Write the spec and bind tracker context to the institutionalization slice.
- [x] Create the durable agent-clarity pass playbook.
- [x] Create the reusable agent-clarity pass checklist.
- [x] Update technical indexes so future agents can find the playbook.
- [x] Validate metadata and close the bounded slice.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-27 | 009-sg-skill-build | GPT-5 Codex | Create institutionalization spec for future clarity passes | implemented | Write the playbook, checklist, and supporting doc indexes |
| 2026-06-27 | 009-sg-skill-build | GPT-5 Codex | Close the institutionalization slice, add a bounded review note, and return tracker focus to aggregate compaction | implemented | Continue `aggregate-skill-corpus-compaction-phase-1` |

## Current Chantier Flow

- `100-sg-spec` ✅ institutionalization spec created
- `101-sg-ready` ✅ ready via bounded continuation after the main clarity sweep
- `102-sg-start` ✅ playbook, checklist, indexes, and closure review note completed
- `103-sg-verify` ✅ metadata and budget validation passed on the bounded slice
- `104-sg-end` ✅ chantier context closed and tracker focus returned to aggregate compaction
- `005-sg-ship` ✅ bounded closure slice ready to ship
