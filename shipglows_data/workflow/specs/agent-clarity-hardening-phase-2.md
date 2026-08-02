---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.1"
project: "shipglows"
created: "2026-06-27"
created_at: "2026-06-27 00:00:00 UTC"
updated: "2026-07-17"
updated_at: "2026-07-17 14:20:26 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "agent-clarity-hardening-phase-2"
owner: "Diane"
user_story: "As the ShipGlows operator, I want agents to distinguish master orchestrators from phase owners and specialist audits in the first screen, so they route to the earliest correct owner instead of staying too long in the wrong skill."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "skills/001-sg-build/SKILL.md"
  - "skills/002-sg-maintain/SKILL.md"
  - "skills/003-sg-bug/SKILL.md"
  - "skills/004-sg-deploy/SKILL.md"
  - "skills/400-sg-audit/SKILL.md"
  - "skills/010-sg-technical/SKILL.md"
  - "skills/010-sg-technical/references/technical-audit-playbook.md"
  - "skills/010-sg-technical/references/performance-audit-playbook.md"
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
supersedes:
  - "shipglows_data/workflow/specs/agent-clarity-hardening-phase-1.md"
evidence:
  - "User direction 2026-06-27: the main objective is more clarity for agents."
  - "Phase 1 clarified lifecycle-adjacent proof owners; the next ambiguity cluster is master-vs-owner routing across build, maintain, bug, deploy, and audit."
  - "Fresh-agent pressure remains high when one request could be misread as feature work, maintenance, bug-loop ownership, release proof, or a specialist audit."
next_step: "/009-sg-skill-build continue agent-clarity hardening after the phase-2 pilot"
---

# Title

Agent Clarity Hardening Phase 2

## Status

ready

## User Story

As the ShipGlows operator, I want agents to distinguish master orchestrators from phase owners and specialist audits in the first screen, so they route to the earliest correct owner instead of staying too long in the wrong skill.

## Minimal Behavior Contract

This phase must make master-vs-owner boundaries mechanically obvious from the first screen of the most confusable orchestration skills. Each touched skill must answer one concrete operator question, state the lane it owns, and state when another owner should take over immediately.

## Success Behavior

- `001-sg-build` makes it obvious that it owns feature lifecycle orchestration, not maintenance triage, standalone bug loops, or deploy-only proof.
- `002-sg-maintain` makes it obvious that it owns existing-project upkeep selection and continuation, not feature delivery, single-bug ownership, or release-confidence ownership.
- `003-sg-bug` makes it obvious that it owns one bug loop at a time, not broad maintenance or release orchestration.
- `004-sg-deploy` makes it obvious that it owns bounded release confidence after implementation, not feature implementation or generic maintenance.
- `400-sg-audit` makes it obvious that it owns broad audit planning/consolidation, while `$010-sg-technical audit <target>` and `$010-sg-technical performance <target>` own specialist depth when the technical lane is already clear.
- A fresh agent can infer whether to stay in the master skill or route directly to the narrower owner without reading deep examples.

## Error Behavior

- If added wording increases overlap between two skills, reject it.
- If a touched master skill still appears to own the downstream specialist's internals, verification fails.
- If a routing cue is generic enough to fit every skill, it does not belong in this phase.

## Pressure Scenarios

- `BUILD-VS-MAINTAIN`: the operator asks to "clean up" or "improve" a project and an agent must decide whether the work is upkeep or feature delivery.
- `BUG-VS-DEPLOY`: the operator mentions a failure near release time and an agent must decide whether the dominant job is bug-loop ownership or release-confidence proof.
- `MASTER-VS-OWNER`: an agent sees a master skill name and incorrectly stays there instead of routing to the earliest narrower owner.
- `AUDIT-MASTER-VS-SPECIALIST`: an agent wants a code or performance review and must decide whether to start with `400-sg-audit` or route directly to `$010-sg-technical audit <target>` or `$010-sg-technical performance <target>`.

## Scope In

- first-screen mission and boundary clarifications in:
  - `skills/001-sg-build/SKILL.md`
  - `skills/002-sg-maintain/SKILL.md`
  - `skills/003-sg-bug/SKILL.md`
  - `skills/004-sg-deploy/SKILL.md`
  - `skills/400-sg-audit/SKILL.md`
  - `skills/010-sg-technical/SKILL.md`
  - `skills/010-sg-technical/references/technical-audit-playbook.md`
  - `skills/010-sg-technical/references/performance-audit-playbook.md`
- narrow task-tracker update for this phase-2 slice

## Scope Out

- broad wording normalization across the whole corpus
- public site docs
- new shared references unless first-screen duplication becomes material
- any change to lifecycle semantics, proof standards, or audit scoring doctrine

## Test Contract

- `python3 tools/audit_shipglows_skills.py`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `tools/shipglows_sync_skills.sh --check --skill 001-sg-build`
- `tools/shipglows_sync_skills.sh --check --skill 002-sg-maintain`
- `tools/shipglows_sync_skills.sh --check --skill 003-sg-bug`
- `tools/shipglows_sync_skills.sh --check --skill 004-sg-deploy`
- `tools/shipglows_sync_skills.sh --check --skill 400-sg-audit`
- `tools/shipglows_sync_skills.sh --check --skill 010-sg-technical`
- targeted route checks for `$010-sg-technical audit <target>` and `$010-sg-technical performance <target>`
- targeted `rg` checks for `answers one`, `route directly`, `stay`, `owns`, and `not`

## Implementation Tasks

- [x] Write the phase-2 spec and bind the tracker to it.
- [x] Clarify master-vs-owner routing in `001`, `002`, `003`, and `004`.
- [x] Clarify audit-master vs specialist routing in `400`, `401`, and `403`.
- [x] Validate audit, budget, runtime visibility, and targeted routing grep checks.
- [ ] Ship the bounded phase-2 slice if validation passes.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-27 | 009-sg-skill-build | GPT-5 Codex | Create phase-2 spec and start first-screen owner-boundary hardening | implemented | Patch targeted skills, validate, and ship if green |

## Current Chantier Flow

- `100-sg-spec` ✅ phase-2 spec created
- `101-sg-ready` ✅ ready via bounded continuation of the active clarity hardening campaign
- `102-sg-start` ✅ first-screen owner-boundary clarifications landed
- `103-sg-verify` 🔄 validation green; final verify/ship decision pending
- `104-sg-end` ⏳ pending
- `005-sg-ship` ⏳ pending
