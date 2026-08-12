---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "shipglows"
created: "2026-05-16"
created_at: "2026-05-16 14:10:00 UTC"
updated: "2026-05-16"
updated_at: "2026-05-16 14:22:00 UTC"
status: ready
source_skill: sg-spec
source_model: "GPT-5 Codex"
scope: "skill-governance-refactor"
owner: "unknown"
user_story: "As a ShipGlows operator maintaining the lifecycle workflow, I want sg-spec and sg-start compacted without losing spec-first gates, so lifecycle skills stay reliable while fitting the progressive-disclosure budget."
confidence: medium
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "skills/sg-spec/SKILL.md"
  - "skills/sg-start/SKILL.md"
  - "skills/sg-spec/references/"
  - "skills/sg-start/references/"
  - "skills/references/skill-instruction-layering.md"
  - "skills/references/skill-context-budget.md"
  - "skills/references/chantier-tracking.md"
  - "skills/references/reporting-contract.md"
  - "tools/skill_budget_audit.py"
  - "tools/shipglows_sync_skills.sh"
depends_on:
  - artifact: "shipglows_data/workflow/specs/compact-shipglows-skill-instructions-phase-3.md"
    artifact_version: "1.0.0"
    required_status: "ready"
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "0.1.0"
    required_status: "active"
  - artifact: "skills/references/skill-context-budget.md"
    artifact_version: "0.3.0"
    required_status: "active"
  - artifact: "skills/references/canonical-paths.md"
    artifact_version: "1.1.0"
    required_status: "active"
  - artifact: "skills/references/chantier-tracking.md"
    artifact_version: "0.5.0"
    required_status: "draft"
  - artifact: "skills/references/reporting-contract.md"
    artifact_version: "1.2.0"
    required_status: "active"
supersedes: []
evidence:
  - "After phase 3, skill budget audit reports only two token-risk skills: sg-spec and sg-start."
  - "sg-spec and sg-start are lifecycle gates, so their compaction needs a dedicated phase with stricter preservation of chantier semantics."
  - "skills/sg-start/SKILL.md already contains a local result-semantics clarification that must be preserved during compaction."
next_step: "none"
---

# Spec: Compact ShipGlows Skill Instructions Phase 4

## Title

Compact ShipGlows Skill Instructions Phase 4

## Status

ready

## User Story

As a ShipGlows operator maintaining the lifecycle workflow, I want `sg-spec` and `sg-start` compacted without losing spec-first gates, so lifecycle skills stay reliable while fitting the progressive-disclosure budget.

## Minimal Behavior Contract

When phase 4 runs, ShipGlows must compact the two remaining lifecycle `SKILL.md` bodies over about 5000 tokens into concise activation contracts and move long step-by-step workflow detail into skill-local references. The top-level bodies must still expose canonical path loading, chantier tracking, report modes, decision gates, stop conditions, result semantics, required references, and validation commands. The easiest edge case to miss is hiding the lifecycle gate that decides when a spec must be created or when implementation must stop.

## Success Behavior

- Preconditions: phase 3 has shipped and budget audit reports only `sg-spec` and `sg-start` as token risks.
- Trigger: a maintainer runs `/sg-start Compact ShipGlows Skill Instructions Phase 4`.
- User/operator result: no lifecycle skill remains over the approximate 5000-token body-risk threshold unless explicitly documented as an exception.
- System effect: `sg-spec` and `sg-start` activate from concise instructions while detailed behavior remains reachable through explicit local references.
- Proof of success: budget audit reports 0 token-risk skill bodies or documented exceptions; metadata lint passes; runtime sync check passes; focused `rg` checks confirm lifecycle labels, chantier tracking, reporting, result semantics, and spec-first gates remain visible.

## Error Behavior

- If a lifecycle decision rule cannot be safely moved, keep it local and document the exception.
- If `sg-spec` loses source-de-chantier intake or ready-spec criteria, verification fails.
- If `sg-start` loses spec-first routing, execution contract, result semantics, or verification handoff rules, verification fails.
- Must never happen: rename skills, change invocation keys, weaken chantier traceability, remove report contract loading, or delete the existing `sg-start` result-semantics clarification.

## Scope In

- Compact `skills/sg-spec/SKILL.md`.
- Compact `skills/sg-start/SKILL.md`.
- Create skill-local lifecycle workflow references as needed.
- Preserve the existing `sg-start` result-semantics clarification.
- Update this spec's run history and flow through `sg-start`, `sg-verify`, `sg-end`, and `sg-ship`.

## Scope Out

- Changing user-facing skill names, descriptions, or invocation keys.
- Changing lifecycle policy beyond moving detailed instructions into references.
- Updating unrelated skills already compacted in phases 1-3.
- Fixing the separate CLI menu navigation bug.

## Constraints

- Use `skills/references/skill-instruction-layering.md` before editing.
- Resolve ShipGlows-owned paths from `${SHIPGLOWS_ROOT:-$HOME/shipglows}`.
- Keep `Trace category: obligatoire` and `Process role: lifecycle` visible in both top-level skill bodies.
- Keep `reporting-contract.md`, `chantier-tracking.md`, and `canonical-paths.md` load requirements visible.
- Keep lifecycle stop conditions local enough that an agent cannot start coding from an unready spec.
- References must pass metadata lint.

## Implementation Tasks

- [x] Create local references for the long `sg-spec` and `sg-start` workflows.
- [x] Rewrite each `SKILL.md` as a concise activation contract that points to the new reference.
- [x] Preserve `sg-start` result semantics in the compact top-level body.
- [x] Run budget audit, metadata lint, runtime sync, and focused lifecycle `rg` checks.
- [x] Update changelog and this spec's run history.
- [x] Commit and push the phase 4 changes.

## Acceptance Criteria

- [x] `python3 tools/skill_budget_audit.py --skills-root skills --format markdown` reports 0 hard violations, 0 warnings, and no body-size token risks, or a documented exception.
- [x] `python3 tools/shipglows_metadata_lint.py` passes for changed spec/reference artifacts.
- [x] `tools/shipglows_sync_skills.sh --check --all` passes.
- [x] `rg` confirms both lifecycle skills still expose canonical paths, chantier tracking, report modes, required references, and validation.
- [x] `rg` confirms `sg-start` still exposes `implemented` vs `partial` semantics.

## Skill Run History

| Timestamp | Skill | Model | Action | Result | Next |
|---|---|---|---|---|---|
| 2026-05-16 14:10:00 UTC | sg-spec | GPT-5 Codex | Created phase 4 lifecycle compaction spec | ready | /sg-start Compact ShipGlows Skill Instructions Phase 4 |
| 2026-05-16 14:18:00 UTC | sg-start | GPT-5 Codex | Compacted lifecycle skill activation bodies and moved detailed workflows to local references | implemented | /sg-verify Compact ShipGlows Skill Instructions Phase 4 |
| 2026-05-16 14:18:00 UTC | sg-verify | GPT-5 Codex | Ran budget audit, metadata lint, runtime sync, and focused lifecycle gate checks | verified | /sg-end Compact ShipGlows Skill Instructions Phase 4 |
| 2026-05-16 14:18:00 UTC | sg-end | GPT-5 Codex | Updated changelog and prepared phase 4 for shipping | closed | /sg-ship Compact ShipGlows Skill Instructions Phase 4 |
| 2026-05-16 14:22:00 UTC | sg-ship | GPT-5 Codex | Committed and pushed phase 4 lifecycle compaction to origin/main | shipped | none |

## Current Chantier Flow

- sg-explore: completed
- sg-spec: ready
- sg-ready: ready
- sg-start: implemented
- sg-verify: verified
- sg-end: closed
- sg-ship: shipped
- Next step: none
