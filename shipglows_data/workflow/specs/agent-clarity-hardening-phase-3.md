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
scope: "agent-clarity-hardening-phase-3"
owner: "Diane"
user_story: "As the ShipGlows operator, I want helper and pilotage skills to distinguish explain vs summarize vs continue in the first screen, so fresh agents do not confuse help output with real lifecycle continuation."
confidence: high
risk_level: medium
security_impact: no
docs_impact: yes
linked_systems:
  - "skills/302-sg-help/SKILL.md"
  - "skills/303-sg-resume/SKILL.md"
  - "skills/706-continue/SKILL.md"
  - "shipglows_data/technical/skill-runtime-and-lifecycle.md"
  - "shipglows_data/workflow/TASKS.md"
  - "tools/audit_shipglows_skills.py"
  - "tools/skill_budget_audit.py"
depends_on:
  - artifact: "skills/references/reporting-contract.md"
    artifact_version: "1.4.0"
    required_status: "active"
  - artifact: "skills/references/chantier-tracking.md"
    artifact_version: "0.5.0"
    required_status: "draft"
supersedes:
  - "shipglows_data/workflow/specs/agent-clarity-hardening-phase-2.md"
evidence:
  - "User direction 2026-06-27: the next gain sought is clarity for agents."
  - "Phase 2 clarified master-vs-owner routing; the next ambiguity cluster is helper-vs-pilotage behavior around help, resume, and continue."
  - "Fresh agents can still confuse explanation, conversation recap, and real chantier continuation when reading 302, 303, and 706."
next_step: "/009-sg-skill-build continue agent-clarity hardening after the phase-3 pilot"
---

# Title

Agent Clarity Hardening Phase 3

## Status

ready

## User Story

As the ShipGlows operator, I want helper and pilotage skills to distinguish explain vs summarize vs continue in the first screen, so fresh agents do not confuse help output with real lifecycle continuation.

## Minimal Behavior Contract

This phase must make helper-vs-pilotage boundaries obvious from the first screen of the main meta-workflow skills. Each touched skill must answer one concrete operator question, state the artifact or decision surface it owns, and state when another skill should take over immediately.

## Success Behavior

- `302-sg-help` makes it obvious that it explains and routes, but does not continue a chantier or mutate durable state.
- `303-sg-resume` makes it obvious that it summarizes only the visible conversation, not repo state or hidden execution truth.
- `706-continue` makes it obvious that it moves the currently resolved work item forward, not that it provides generic help or a passive recap.
- `shipglows_data/technical/skill-runtime-and-lifecycle.md` captures the helper/pilotage distinction so future skill edits do not reintroduce ambiguity.

## Error Behavior

- If a helper skill appears to own lifecycle continuation, reject it.
- If `706-continue` appears to be only a summary surface, reject it.
- If wording duplicates deep playbooks instead of clarifying first-screen routing, reject it.

## Pressure Scenarios

- `HELP-VS-CONTINUE`: the operator asks what to do next and an agent must decide whether to explain options or actually advance the chantier.
- `RESUME-VS-TRUTH`: an agent is tempted to use `303-sg-resume` as durable state truth instead of a conversation-only recap.
- `CONTINUE-VS-REROUTE`: an agent sees "continue" and must determine whether to keep the current work item moving or route to a new owner because the next step is actually a different lifecycle lane.

## Scope In

- first-screen mission and boundary clarifications in:
  - `skills/302-sg-help/SKILL.md`
  - `skills/303-sg-resume/SKILL.md`
  - `skills/706-continue/SKILL.md`
  - `shipglows_data/technical/skill-runtime-and-lifecycle.md`
- narrow task-tracker update for this phase-3 slice

## Scope Out

- public site docs
- broad normalization of all helper skills
- new shared references unless repetition becomes material
- any lifecycle semantic change outside explain/resume/continue routing

## Test Contract

- `python3 tools/audit_shipglows_skills.py`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/agent-clarity-hardening-phase-3.md shipglows_data/technical/skill-runtime-and-lifecycle.md`
- `tools/shipglows_sync_skills.sh --check --skill 302-sg-help`
- `tools/shipglows_sync_skills.sh --check --skill 303-sg-resume`
- `tools/shipglows_sync_skills.sh --check --skill 706-continue`
- targeted `rg` checks for `answers one`, `conversation only`, `does not`, `continue`, and `route`

## Implementation Tasks

- [x] Write the phase-3 spec and bind the tracker to it.
- [ ] Clarify explain/resume/continue first-screen boundaries in `302`, `303`, and `706`.
- [ ] Refresh technical taxonomy documentation for helper vs pilotage distinctions.
- [ ] Validate audit, budget, metadata lint, runtime visibility, and targeted routing grep checks.
- [ ] Ship the bounded phase-3 slice if validation passes.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-27 | 009-sg-skill-build | GPT-5 Codex | Create phase-3 spec and start helper/pilotage clarity hardening | implemented | Patch targeted skills, validate, and ship if green |

## Current Chantier Flow

- `100-sg-spec` ✅ phase-3 spec created
- `101-sg-ready` ✅ ready via bounded continuation of the active clarity hardening campaign
- `102-sg-start` 🔄 in progress on helper/pilotage boundary clarifications
- `103-sg-verify` ⏳ pending
- `104-sg-end` ⏳ pending
- `005-sg-ship` ⏳ pending
