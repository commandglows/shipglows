---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "shipglows"
created: "2026-06-27"
created_at: "2026-06-27 00:00:00 UTC"
updated: "2026-06-27"
updated_at: "2026-06-27 00:00:00 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "agent-clarity-hardening-phase-1"
owner: "Diane"
user_story: "As the ShipGlows operator, I want core skill boundaries and next-owner routing to stay obvious to fresh agents under pressure, so they do not confuse implement vs verify vs close vs ship, or manual QA vs browser vs auth debugging."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "skills/000-shipglows/SKILL.md"
  - "skills/005-sg-ship/SKILL.md"
  - "skills/102-sg-start/SKILL.md"
  - "skills/103-sg-verify/SKILL.md"
  - "skills/104-sg-end/SKILL.md"
  - "skills/107-sg-test/SKILL.md"
  - "skills/108-sg-browser/SKILL.md"
  - "skills/109-sg-auth-debug/SKILL.md"
  - "shipglows_data/workflow/TASKS.md"
  - "tools/audit_shipglows_skills.py"
  - "tools/skill_budget_audit.py"
depends_on:
  - artifact: "skills/references/skill-execution-fidelity.md"
    artifact_version: "1.2.0"
    required_status: "active"
  - artifact: "skills/references/spec-driven-development-discipline.md"
    artifact_version: "1.5.0"
    required_status: "active"
  - artifact: "skills/references/reporting-contract.md"
    artifact_version: "1.4.0"
    required_status: "active"
evidence:
  - "User direction 2026-06-27: the primary objective is not more compaction, but more clarity for agents."
  - "Recent hardening improved preflight and proof routing, but the next systemic gain is first-screen owner clarity on high-confusion boundaries."
  - "Pressure scenarios remain highest on lifecycle sequencing (`102` vs `103` vs `104` vs `005`) and proof-lane selection (`107` vs `108` vs `109`)."
supersedes: []
next_step: "/009-sg-skill-build continue agent-clarity hardening after the phase-1 pilot"
---

# Title

Agent Clarity Hardening Phase 1

## Status

ready

## User Story

As the ShipGlows operator, I want core skill boundaries and next-owner routing to stay obvious to fresh agents under pressure, so they do not confuse implement vs verify vs close vs ship, or manual QA vs browser vs auth debugging.

## Minimal Behavior Contract

This phase must make the next owner mechanically obvious from the first screen of the highest-risk skills. Each touched skill must answer one concrete operator question, state what it owns, and state what it does not own when that boundary is easy to confuse under pressure.

## Success Behavior

- `000-shipglows` gives a deterministic route bias when the ambiguity is between lifecycle-adjacent owners or proof-adjacent owners.
- `102-sg-start`, `103-sg-verify`, `104-sg-end`, and `005-sg-ship` each expose a one-question contract and a clean owner boundary.
- `108-sg-browser` and `109-sg-auth-debug` keep one-screen clarity about when they must reroute instead of continuing.
- A fresh agent can infer the next owner from the top section without reading deep examples or references.

## Error Behavior

- If added wording makes a skill longer but not more decisive, reject it.
- If two touched skills still appear to own the same next action, verification fails.
- If a routing cue belongs in a shared reference rather than a local contract, extract it only when the local skill can still stay decisive on the first screen.

## Pressure Scenarios

- `LIFECYCLE-ORDER-AMBIGUITY`: an agent implemented the change and must decide between `103`, `104`, and `005` without overstating proof or closure.
- `VERIFY-VS-END`: an agent sees passing local checks and is tempted to close the task before proof gaps are routed.
- `QA-LANE-CONFUSION`: an agent needs proof and must choose between browser proof, auth-safe proof, and guided manual QA.
- `ROUTER-EARLIEST-OWNER`: `000-shipglows` must prefer the earliest unresolved owner instead of routing to a later lifecycle skill just because the user said "finish" or "check".

## Scope In

- first-screen mission and boundary clarifications in:
  - `skills/000-shipglows/SKILL.md`
  - `skills/005-sg-ship/SKILL.md`
  - `skills/102-sg-start/SKILL.md`
  - `skills/103-sg-verify/SKILL.md`
  - `skills/104-sg-end/SKILL.md`
  - `skills/108-sg-browser/SKILL.md`
  - `skills/109-sg-auth-debug/SKILL.md`
- narrow task-tracker update for this chantier

## Scope Out

- broad whole-corpus wording normalization
- public site docs
- new shared references unless repetition is proven
- changes to proofs, checks, or lifecycle semantics already settled in prior hardening work

## Test Contract

- `python3 tools/audit_shipglows_skills.py`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `tools/shipglows_sync_skills.sh --check --skill 000-shipglows`
- `tools/shipglows_sync_skills.sh --check --skill 005-sg-ship`
- `tools/shipglows_sync_skills.sh --check --skill 102-sg-start`
- `tools/shipglows_sync_skills.sh --check --skill 103-sg-verify`
- `tools/shipglows_sync_skills.sh --check --skill 104-sg-end`
- `tools/shipglows_sync_skills.sh --check --skill 108-sg-browser`
- `tools/shipglows_sync_skills.sh --check --skill 109-sg-auth-debug`
- targeted `rg` checks for `answers one question`, `does not own`, `next owner`, and route-order cues

## Implementation Tasks

- [ ] Write the phase-1 spec and bind the tracker to it.
- [ ] Clarify lifecycle sequencing in `000`, `102`, `103`, `104`, and `005`.
- [ ] Clarify proof-lane boundaries in `108` and `109`.
- [ ] Validate audit, budget, runtime visibility, and targeted route-order grep checks.
- [ ] Ship the bounded phase-1 slice if validation passes.
