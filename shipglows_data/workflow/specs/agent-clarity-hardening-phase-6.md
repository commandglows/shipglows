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
scope: "agent-clarity-hardening-phase-6"
owner: "Diane"
user_story: "As the ShipGlows operator, I want tracker-maintenance and continuation skills to distinguish tracker bookkeeping vs next-step continuation in the first screen, so fresh agents do not confuse updating TASKS state with advancing the active work item."
confidence: high
risk_level: medium
security_impact: no
docs_impact: yes
linked_systems:
  - "skills/309-sg-tasks/SKILL.md"
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
  - "shipglows_data/workflow/specs/agent-clarity-hardening-phase-5.md"
evidence:
  - "User direction 2026-06-27: continue the transverse agent-clarity hardening campaign in bounded phases."
  - "Phase 5 clarified explore vs backlog vs priorities vs review."
  - "Fresh agents can still confuse `309-sg-tasks` and `706-continue` because both can suggest a next step near `TASKS.md`, but one owns tracker bookkeeping while the other advances the currently resolved work item."
next_step: "/009-sg-skill-build continue agent-clarity hardening after the phase-6 pilot"
---

# Title

Agent Clarity Hardening Phase 6

## Status

ready

## User Story

As the ShipGlows operator, I want tracker-maintenance and continuation skills to distinguish tracker bookkeeping vs next-step continuation in the first screen, so fresh agents do not confuse updating TASKS state with advancing the active work item.

## Minimal Behavior Contract

This phase must make tracker-maintenance and continuation boundaries obvious from the first screen. Each touched skill must answer one concrete operator question, state which artifact or decision surface it owns, and state when another skill should take over immediately.

## Success Behavior

- `309-sg-tasks` makes it obvious that it maintains task tracker state and suggests tracker-based next steps, but does not become the default continuation owner for active execution.
- `706-continue` makes it obvious that it advances the currently resolved work item from durable evidence, but does not become a generic tracker-grooming or recap surface.
- `shipglows_data/technical/skill-runtime-and-lifecycle.md` captures the `track / continue` distinction so future edits keep these surfaces separate.

## Error Behavior

- If `309-sg-tasks` appears to own retrospective review, backlog grooming, or execution continuation by default, reject it.
- If `706-continue` appears to rewrite trackers as its primary job or behave like a recap-only helper, reject it.

## Pressure Scenarios

- `TRACK-VS-CONTINUE`: an agent must decide whether the user needs task-bookkeeping updates or the next action-ready move on the active work item.
- `CONTINUE-VS-RESUME`: an agent must decide whether to advance work or merely summarize visible thread state.
- `TASKS-VS-PILOTAGE`: an agent sees `TASKS.md` nearby and must decide whether tracker mutation is the goal or only supporting evidence.

## Scope In

- first-screen mission and boundary clarifications in:
  - `skills/309-sg-tasks/SKILL.md`
  - `skills/706-continue/SKILL.md`
  - `shipglows_data/technical/skill-runtime-and-lifecycle.md`
- narrow task-tracker update for this phase-6 slice

## Scope Out

- public site docs
- tracker-format redesign
- broad normalization of remaining pilotage/support skills
- unrelated hardening or compaction work

## Test Contract

- `python3 tools/audit_shipglows_skills.py`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/agent-clarity-hardening-phase-6.md shipglows_data/technical/skill-runtime-and-lifecycle.md`
- `tools/shipglows_sync_skills.sh --check --skill 309-sg-tasks`
- `tools/shipglows_sync_skills.sh --check --skill 706-continue`
- targeted `rg` checks for `answers one`, `Keep the boundary explicit`, `does not`, `tracker`, and `continue`

## Implementation Tasks

- [x] Write the phase-6 spec and bind the tracker to it.
- [ ] Clarify `track / continue` first-screen boundaries in `309` and `706`.
- [ ] Refresh technical taxonomy documentation for tracker-maintenance and continuation distinctions.
- [ ] Validate audit, budget, metadata lint, runtime visibility, and targeted boundary grep checks.
- [ ] Ship the bounded phase-6 slice if validation passes.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-27 | 009-sg-skill-build | GPT-5 Codex | Create phase-6 spec and start tracker/continuation clarity hardening | implemented | Patch targeted skills, validate, and ship if green |

## Current Chantier Flow

- `100-sg-spec` ✅ phase-6 spec created
- `101-sg-ready` ✅ ready via bounded continuation of the active clarity hardening campaign
- `102-sg-start` 🔄 in progress on tracker/continuation boundary clarifications
- `103-sg-verify` ⏳ pending
- `104-sg-end` ⏳ pending
- `005-sg-ship` ⏳ pending
