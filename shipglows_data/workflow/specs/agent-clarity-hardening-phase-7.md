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
scope: "agent-clarity-hardening-phase-7"
owner: "Diane"
user_story: "As the ShipGlows operator, I want residual helper skills to distinguish model routing vs session naming vs transcript capture vs transcript cleaning in the first screen, so fresh agents do not confuse runtime advice, local session tags, raw export, and transcript editing."
confidence: high
risk_level: medium
security_impact: no
docs_impact: yes
linked_systems:
  - "skills/704-sg-model/SKILL.md"
  - "skills/707-name/SKILL.md"
  - "skills/800-tmux-capture-conversation/SKILL.md"
  - "skills/801-clean-conversation-transcript/SKILL.md"
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
  - "shipglows_data/workflow/specs/agent-clarity-hardening-phase-6.md"
evidence:
  - "User direction 2026-06-27: continue the transverse agent-clarity hardening campaign in bounded phases."
  - "Phase 6 clarified tracker maintenance vs continuation."
  - "Fresh agents can still confuse `704-sg-model`, `707-name`, `800-tmux-capture-conversation`, and `801-clean-conversation-transcript` because all four are helper surfaces near execution, but they own distinct first-screen jobs: choose model, tag session, export transcript, or clean transcript."
next_step: "/009-sg-skill-build continue agent-clarity hardening after the phase-7 pilot"
---

# Title

Agent Clarity Hardening Phase 7

## Status

ready

## User Story

As the ShipGlows operator, I want residual helper skills to distinguish model routing vs session naming vs transcript capture vs transcript cleaning in the first screen, so fresh agents do not confuse runtime advice, local session tags, raw export, and transcript editing.

## Minimal Behavior Contract

This phase must make residual helper boundaries obvious from the first screen. Each touched skill must answer one concrete operator question, state which artifact or decision surface it owns, and state when another skill should take over immediately.

## Success Behavior

- `704-sg-model` makes it obvious that it recommends a model policy for the current scope, but does not become the execution owner.
- `707-name` makes it obvious that it tags or renames the current session only, but does not recap or mutate project work.
- `800-tmux-capture-conversation` makes it obvious that it exports a raw transcript from tmux into Markdown, but does not clean or repurpose the transcript itself.
- `801-clean-conversation-transcript` makes it obvious that it edits one transcript for readability, but does not capture a new transcript or produce a separate content strategy artifact.
- `shipglows_data/technical/skill-runtime-and-lifecycle.md` captures the `choose / tag / capture / clean` distinction so future edits keep these helpers separate.

## Error Behavior

- If `704-sg-model` appears to own the execution or implementation path itself, reject it.
- If `707-name` appears to behave like `303-sg-resume` or `309-sg-tasks`, reject it.
- If `800-tmux-capture-conversation` appears to rewrite transcript content beyond capture/export concerns, reject it.
- If `801-clean-conversation-transcript` appears to act like capture, repurpose, or strategy planning by default, reject it.

## Pressure Scenarios

- `MODEL-VS-DO`: an agent must decide whether the user needs model routing advice or direct execution ownership.
- `NAME-VS-RESUME`: an agent must decide whether the user wants a session label or a conversational recap.
- `CAPTURE-VS-CLEAN`: an agent must decide whether the user needs a raw transcript export or a cleaned edited transcript.

## Scope In

- first-screen mission and boundary clarifications in:
  - `skills/704-sg-model/SKILL.md`
  - `skills/707-name/SKILL.md`
  - `skills/800-tmux-capture-conversation/SKILL.md`
  - `skills/801-clean-conversation-transcript/SKILL.md`
  - `shipglows_data/technical/skill-runtime-and-lifecycle.md`
- narrow task-tracker update for this phase-7 slice

## Scope Out

- public site docs
- runtime-model doctrine changes beyond boundary clarity
- transcript script rewrites
- broad normalization of all remaining helper surfaces beyond this bounded batch

## Test Contract

- `python3 tools/audit_shipglows_skills.py`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/agent-clarity-hardening-phase-7.md shipglows_data/technical/skill-runtime-and-lifecycle.md`
- `tools/shipglows_sync_skills.sh --check --skill 704-sg-model`
- `tools/shipglows_sync_skills.sh --check --skill 707-name`
- `tools/shipglows_sync_skills.sh --check --skill 800-tmux-capture-conversation`
- `tools/shipglows_sync_skills.sh --check --skill 801-clean-conversation-transcript`
- targeted `rg` checks for `answers one`, `Keep the boundary explicit`, `does not`, `capture`, `clean`, and `session`

## Implementation Tasks

- [x] Write the phase-7 spec and bind the tracker to it.
- [ ] Clarify `choose / tag / capture / clean` first-screen boundaries in `704`, `707`, `800`, and `801`.
- [ ] Refresh technical taxonomy documentation for residual helper distinctions.
- [ ] Validate audit, budget, metadata lint, runtime visibility, and targeted boundary grep checks.
- [ ] Ship the bounded phase-7 slice if validation passes.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-27 | 009-sg-skill-build | GPT-5 Codex | Create phase-7 spec and start residual-helper clarity hardening | implemented | Patch targeted skills, validate, and ship if green |

## Current Chantier Flow

- `100-sg-spec` ✅ phase-7 spec created
- `101-sg-ready` ✅ ready via bounded continuation of the active clarity hardening campaign
- `102-sg-start` 🔄 in progress on residual helper boundary clarifications
- `103-sg-verify` ⏳ pending
- `104-sg-end` ⏳ pending
- `005-sg-ship` ⏳ pending
