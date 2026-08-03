---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "shipglows"
created: "2026-05-03"
created_at: "2026-05-03 18:25:50 UTC"
updated: "2026-05-03"
updated_at: "2026-05-03 19:10:22 UTC"
status: superseded
source_skill: sg-spec
source_model: "GPT-5 Codex"
scope: "feature"
owner: "Diane"
user_story: "As a ShipGlows operator maintaining an existing project, I want one lightweight maintenance entrypoint to review bugs, dependencies, docs, checks, audits, migrations, and security posture, so I can decide the next maintenance action without manually stitching together every specialist skill."
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - "skills/sg-maintain/SKILL.md"
  - "skills/sg-maintain/agents/openai.yaml"
  - "site/src/content/skills/sg-maintain.md"
  - "skills/sg-help/SKILL.md"
  - "skills/sg-bug/SKILL.md"
  - "skills/sg-deps/SKILL.md"
  - "skills/sg-docs/SKILL.md"
  - "skills/sg-check/SKILL.md"
  - "skills/sg-audit-code/SKILL.md"
  - "skills/sg-audit/SKILL.md"
  - "skills/sg-migrate/SKILL.md"
  - "skills/sg-tasks/SKILL.md"
  - "skills/references/chantier-tracking.md"
  - "skills/references/reporting-contract.md"
  - "README.md"
  - "shipglows_data/workflow/playbooks/spec-driven-workflow.md"
  - "docs/technical/skill-runtime-and-lifecycle.md"
depends_on:
  - artifact: "shipglows_data/workflow/playbooks/spec-driven-workflow.md"
    artifact_version: "0.11.0"
    required_status: "draft"
  - artifact: "skills/references/chantier-tracking.md"
    artifact_version: "0.4.0"
    required_status: "draft"
  - artifact: "skills/references/reporting-contract.md"
    artifact_version: "1.0.0"
    required_status: "active"
supersedes: []
superseded_by: "specs/sg-maintain-master-lifecycle-skill.md"
evidence:
  - "User decision 2026-05-03: sg-adopt does not add enough beyond sg-init/sg-docs/sg-migrate/sg-deps."
  - "User requested sg-maintain as a bounded maintenance pass that can review dependencies, documentation, audits, and important security concerns without becoming too large."
  - "Existing security coverage is split between sg-deps for dependency and supply-chain risk and sg-audit-code for auth, permissions, trust boundaries, secrets, reliability, and abuse resistance."
  - "Validation passed on 2026-05-03: metadata lint, skill budget audit, runtime skill sync check, diff check, and Astro site build including /skills/sg-maintain."
next_step: "Superseded by specs/sg-maintain-master-lifecycle-skill.md"
---

# Spec: sg-maintain Project Maintenance Skill

## Title

sg-maintain Project Maintenance Skill

## Status

superseded

This spec is superseded by `specs/sg-maintain-master-lifecycle-skill.md`, which promotes `sg-maintain` from a lightweight router to a lifecycle master skill.

## User Story

As a ShipGlows operator maintaining an existing project, I want one lightweight maintenance entrypoint to review bugs, dependencies, docs, checks, audits, migrations, and security posture, so I can decide the next maintenance action without manually stitching together every specialist skill.

## Minimal Behavior Contract

`sg-maintain` is an orchestrator, not a replacement for specialist skills. It must inspect maintenance state, classify the top maintenance needs, and route to owner skills: `sg-bug`, `sg-deps`, `sg-docs`, `sg-check`, `sg-audit-code`, `sg-audit`, `sg-migrate`, and `sg-tasks`.

Default mode must stay read-only and concise. Full and security modes may propose deeper work, but must ask before heavy audits or write-capable phases.

## Success Behavior

- Preconditions: the current directory is a project or the user requests global maintenance from a workspace.
- Trigger: the user invokes `/sg-maintain`, `$sg-maintain`, or asks for project maintenance health.
- User/operator result: the operator gets a prioritized maintenance action list, each with the owning skill and reason.
- System effect: the skill reads existing project evidence and routes work without duplicating specialist internals.
- Success proof: the report names bug risk, dependency posture, docs/governance drift, check coverage, audit freshness, migration candidates, and security posture when evidence exists.
- Silent success: not allowed. Missing evidence must be reported as a proof gap.

## Non-Goals

- Do not create `sg-adopt` as part of this chantier.
- Do not create a separate `sg-audit-security` yet.
- Do not auto-fix code, update dependencies, rewrite docs, close bugs, mutate trackers, commit, or push.
- Do not treat a quiet maintenance pass as a security sign-off.

## Security Position

Security maintenance is routed through existing owners:

- `sg-deps` for vulnerability, supply-chain, license, package drift, and config posture.
- `sg-audit-code` for authn/authz, tenant boundaries, secrets, trust boundaries, webhooks, destructive actions, secure failure modes, and abuse resistance.

`sg-maintain security` should make these routes explicit and report missing security evidence honestly.

## Acceptance Criteria

- [x] AC 1: Given the operator invokes `sg-maintain`, when no mode is provided, then the skill performs a concise read-only maintenance triage and returns top owner-skill actions.
- [x] AC 2: Given the operator invokes `sg-maintain security`, then the skill routes security posture through `sg-deps` and `sg-audit-code` rather than inventing a separate security audit.
- [x] AC 3: Given full maintenance would launch heavy or write-capable phases, then the skill asks before running them.
- [x] AC 4: Given public skill discovery changes, then the public skill page and help/workflow docs mention `sg-maintain`.
- [x] AC 5: Given runtime skill visibility matters, then Claude and Codex skill symlinks can be checked through the shared sync helper.

## Validation Plan

- `python3 tools/shipglows_metadata_lint.py specs/sg-maintain-project-maintenance-skill.md README.md shipglows_data/workflow/playbooks/spec-driven-workflow.md docs/technical/skill-runtime-and-lifecycle.md skills/references/chantier-tracking.md`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `tools/shipglows_sync_skills.sh --repair --skill sg-maintain`
- `tools/shipglows_sync_skills.sh --check --skill sg-maintain`
- `pnpm --dir shipglows-site build`

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-03 18:25:50 UTC | sg-spec | GPT-5 Codex | Created ready spec for sg-maintain project maintenance skill | ready | /sg-start sg-maintain |
| 2026-05-03 18:25:50 UTC | sg-start | GPT-5 Codex | Implemented sg-maintain skill contract, public page, and documentation/help integration | implemented | /sg-verify sg-maintain project maintenance skill |
| 2026-05-03 18:32:12 UTC | sg-verify | GPT-5 Codex | Ran metadata lint, skill budget audit, runtime sync check, diff check, and site build for sg-maintain | passed | none |

## Current Chantier Flow

- `sg-spec`: done, ready spec created.
- `sg-ready`: ready by direct spec gate for this bounded skill request.
- `sg-start`: implemented.
- `sg-verify`: passed.
- `sg-end`: not launched.
- `sg-ship`: not launched.

Next step: none
