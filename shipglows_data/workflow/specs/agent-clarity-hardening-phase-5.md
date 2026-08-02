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
scope: "agent-clarity-hardening-phase-5"
owner: "Diane"
user_story: "As the ShipGlows operator, I want framing and pilotage skills to distinguish explore vs backlog vs priorities vs review in the first screen, so fresh agents do not confuse reflection, deferred capture, active ranking, and retrospective closure."
confidence: high
risk_level: medium
security_impact: no
docs_impact: yes
linked_systems:
  - "skills/700-sg-explore/SKILL.md"
  - "skills/701-sg-backlog/SKILL.md"
  - "skills/702-sg-priorities/SKILL.md"
  - "skills/703-sg-review/SKILL.md"
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
  - "shipglows_data/workflow/specs/agent-clarity-hardening-phase-4.md"
evidence:
  - "User direction 2026-06-27: continue the transverse agent-clarity hardening campaign to improve clarity for agents."
  - "Phase 4 clarified route vs prime vs report across entrypoint and helper surfaces."
  - "Fresh agents can still confuse framing and pilotage surfaces because `700-sg-explore`, `701-sg-backlog`, `702-sg-priorities`, and `703-sg-review` all touch planning language near `TASKS.md` without yet stating one crisp first-screen owner question."
next_step: "/009-sg-skill-build continue agent-clarity hardening after the phase-5 pilot"
---

# Title

Agent Clarity Hardening Phase 5

## Status

ready

## User Story

As the ShipGlows operator, I want framing and pilotage skills to distinguish explore vs backlog vs priorities vs review in the first screen, so fresh agents do not confuse reflection, deferred capture, active ranking, and retrospective closure.

## Minimal Behavior Contract

This phase must make framing and pilotage boundaries obvious from the first screen. Each touched skill must answer one concrete operator question, state which artifact or decision surface it owns, and state when another skill should take over immediately.

## Success Behavior

- `700-sg-explore` makes it obvious that it explores a problem or option space before commitment, but does not groom trackers or claim closure.
- `701-sg-backlog` makes it obvious that it captures or defers future work, but does not decide current execution order.
- `702-sg-priorities` makes it obvious that it ranks active work now, but does not act like a backlog dump or a retrospective.
- `703-sg-review` makes it obvious that it reconstructs what happened and what remains, but does not become the main prioritizer or ideation lane.
- `shipglows_data/technical/skill-runtime-and-lifecycle.md` captures the `explore / defer / rank / review` distinction so future edits keep these surfaces separate.

## Error Behavior

- If `700-sg-explore` appears to mutate backlog/tasks or behave like a closure review, reject it.
- If `701-sg-backlog` appears to re-rank active execution order instead of recording/defering work, reject it.
- If `702-sg-priorities` appears to become a generic idea inbox or a weekly review summary, reject it.
- If `703-sg-review` appears to own ideation or active ranking by default, reject it.

## Pressure Scenarios

- `EXPLORE-VS-TRACK`: an agent must decide whether the user needs open-ended reasoning or a durable backlog/task mutation.
- `BACKLOG-VS-PRIORITIZE`: an agent sees planning language and must decide whether the work should be deferred/captured or ranked for immediate action.
- `PRIORITIZE-VS-REVIEW`: an agent must decide whether to rank what should happen next or summarize what already happened and what remains.

## Scope In

- first-screen mission and boundary clarifications in:
  - `skills/700-sg-explore/SKILL.md`
  - `skills/701-sg-backlog/SKILL.md`
  - `skills/702-sg-priorities/SKILL.md`
  - `skills/703-sg-review/SKILL.md`
  - `shipglows_data/technical/skill-runtime-and-lifecycle.md`
- narrow task-tracker update for this phase-5 slice

## Scope Out

- public site docs
- broad normalization of all pilotage/support skills
- behavioral changes to tracker formats, reports, or review artifacts
- unrelated corpus compaction or bootstrap hardening work

## Test Contract

- `python3 tools/audit_shipglows_skills.py`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/agent-clarity-hardening-phase-5.md shipglows_data/technical/skill-runtime-and-lifecycle.md`
- `tools/shipglows_sync_skills.sh --check --skill 700-sg-explore`
- `tools/shipglows_sync_skills.sh --check --skill 701-sg-backlog`
- `tools/shipglows_sync_skills.sh --check --skill 702-sg-priorities`
- `tools/shipglows_sync_skills.sh --check --skill 703-sg-review`
- targeted `rg` checks for `answers`, `does not`, `backlog`, `priorit`, `review`, and `Keep the boundary explicit`

## Implementation Tasks

- [x] Write the phase-5 spec and bind the tracker to it.
- [ ] Clarify `explore / defer / rank / review` first-screen boundaries in `700`, `701`, `702`, and `703`.
- [ ] Refresh technical taxonomy documentation for framing and pilotage distinctions.
- [ ] Validate audit, budget, metadata lint, runtime visibility, and targeted boundary grep checks.
- [ ] Ship the bounded phase-5 slice if validation passes.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-27 | 009-sg-skill-build | GPT-5 Codex | Create phase-5 spec and start framing/pilotage clarity hardening | implemented | Patch targeted skills, validate, and ship if green |

## Current Chantier Flow

- `100-sg-spec` ✅ phase-5 spec created
- `101-sg-ready` ✅ ready via bounded continuation of the active clarity hardening campaign
- `102-sg-start` 🔄 in progress on explore/backlog/priorities/review boundary clarifications
- `103-sg-verify` ⏳ pending
- `104-sg-end` ⏳ pending
- `005-sg-ship` ⏳ pending
