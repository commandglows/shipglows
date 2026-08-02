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
scope: "agent-clarity-hardening-phase-4"
owner: "Diane"
user_story: "As the ShipGlows operator, I want entrypoint and context/status helper skills to distinguish route vs prime vs report in the first screen, so fresh agents do not confuse starting work with preparing context or reporting state."
confidence: high
risk_level: medium
security_impact: no
docs_impact: yes
linked_systems:
  - "skills/000-shipglows/SKILL.md"
  - "skills/301-sg-context/SKILL.md"
  - "skills/308-sg-status/SKILL.md"
  - "shipglows_data/technical/skill-runtime-and-lifecycle.md"
  - "shipglows_data/workflow/TASKS.md"
  - "tools/audit_shipglows_skills.py"
  - "tools/skill_budget_audit.py"
depends_on:
  - artifact: "skills/references/reporting-contract.md"
    artifact_version: "1.4.0"
    required_status: "active"
  - artifact: "skills/references/entrypoint-routing.md"
    artifact_version: "1.0.0"
    required_status: "active"
supersedes:
  - "shipglows_data/workflow/specs/agent-clarity-hardening-phase-3.md"
evidence:
  - "User direction 2026-06-27: the hardening campaign should keep improving agent clarity."
  - "Phase 3 clarified helper-vs-pilotage around help, resume, and continue."
  - "Fresh agents can still confuse `000-shipglows`, `301-sg-context`, and `308-sg-status` because all three are non-writing helper surfaces near the top of the taxonomy."
next_step: "/009-sg-skill-build continue agent-clarity hardening after the phase-4 pilot"
---

# Title

Agent Clarity Hardening Phase 4

## Status

ready

## User Story

As the ShipGlows operator, I want entrypoint and context/status helper skills to distinguish route vs prime vs report in the first screen, so fresh agents do not confuse starting work with preparing context or reporting state.

## Minimal Behavior Contract

This phase must make entrypoint-helper boundaries obvious from the first screen. Each touched skill must answer one concrete operator question, state what artifact or decision surface it owns, and state when another skill should take over immediately.

## Success Behavior

- `000-shipglows` makes it obvious that it routes or answers directly, but does not prime context or act as a status dashboard.
- `301-sg-context` makes it obvious that it prepares focused context before work, but does not own routing or lifecycle execution.
- `308-sg-status` makes it obvious that it reports portfolio git/sync state, but does not route project work or continue a chantier.
- `shipglows_data/technical/skill-runtime-and-lifecycle.md` captures the `route / prime / report` distinction so future edits keep these surfaces separate.

## Error Behavior

- If `000-shipglows` appears to own broad context priming or dashboard reporting, reject it.
- If `301-sg-context` appears to choose or execute the final lifecycle owner by itself, reject it.
- If `308-sg-status` appears to mutate trackers or act like `706-continue`, reject it.

## Pressure Scenarios

- `ROUTE-VS-PRIME`: an agent must decide whether the user wants a route to the right skill or a context bootstrap before known work.
- `PRIME-VS-DO`: an agent sees `301-sg-context` and wrongly turns it into actual execution instead of bounded prep.
- `STATUS-VS-ACTION`: an agent sees repo health questions and must decide whether to report state only or launch a maintenance/workflow owner.

## Scope In

- first-screen mission and boundary clarifications in:
  - `skills/000-shipglows/SKILL.md`
  - `skills/301-sg-context/SKILL.md`
  - `skills/308-sg-status/SKILL.md`
  - `shipglows_data/technical/skill-runtime-and-lifecycle.md`
- narrow task-tracker update for this phase-4 slice

## Scope Out

- public site docs
- broad normalization of all helper skills
- new shared references unless repetition becomes material
- any lifecycle semantic change outside route/prime/report boundaries

## Test Contract

- `python3 tools/audit_shipglows_skills.py`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/agent-clarity-hardening-phase-4.md shipglows_data/technical/skill-runtime-and-lifecycle.md`
- `tools/shipglows_sync_skills.sh --check --skill 000-shipglows`
- `tools/shipglows_sync_skills.sh --check --skill 301-sg-context`
- `tools/shipglows_sync_skills.sh --check --skill 308-sg-status`
- targeted `rg` checks for `answers one`, `route`, `prime`, `report`, `does not`, and `Keep the boundary explicit`

## Implementation Tasks

- [x] Write the phase-4 spec and bind the tracker to it.
- [ ] Clarify route/prime/report first-screen boundaries in `000`, `301`, and `308`.
- [ ] Refresh technical taxonomy documentation for entrypoint-helper distinctions.
- [ ] Validate audit, budget, metadata lint, runtime visibility, and targeted routing grep checks.
- [ ] Ship the bounded phase-4 slice if validation passes.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-27 | 009-sg-skill-build | GPT-5 Codex | Create phase-4 spec and start entrypoint/context/status clarity hardening | implemented | Patch targeted skills, validate, and ship if green |

## Current Chantier Flow

- `100-sg-spec` ✅ phase-4 spec created
- `101-sg-ready` ✅ ready via bounded continuation of the active clarity hardening campaign
- `102-sg-start` 🔄 in progress on route/prime/report boundary clarifications
- `103-sg-verify` ⏳ pending
- `104-sg-end` ⏳ pending
- `005-sg-ship` ⏳ pending
