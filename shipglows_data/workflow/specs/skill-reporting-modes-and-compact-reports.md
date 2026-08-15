---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-05-03"
created_at: "2026-05-03 00:00:00 UTC"
updated: "2026-08-15"
updated_at: "2026-08-15 12:38:27 UTC"
status: ready
source_skill: sg-build
source_model: "GPT-5 Codex"
scope: workflow
owner: Diane
user_story: "As a ShipGlows operator, I want skills to default to concise human reports while still supporting detailed agent handoff reports on request, so standalone skill usage stays readable without losing technical traceability for internal orchestration."
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/references/reporting-contract.md
  - skills/references/chantier-tracking.md
  - skills/sg-spec/SKILL.md
  - skills/sg-ready/SKILL.md
  - skills/sg-build/SKILL.md
  - skills/sg-ship/SKILL.md
  - skills/sg-start/SKILL.md
  - skills/sg-verify/SKILL.md
  - skills/sg-end/SKILL.md
  - skills/sg-deploy/SKILL.md
  - skills/sg-skill-build/SKILL.md
  - skills/sg-bug/SKILL.md
  - skills/sg-audit*/SKILL.md
  - docs/technical/skill-runtime-and-lifecycle.md
  - shipglows_data/workflow/playbooks/spec-driven-workflow.md
depends_on:
  - artifact: "shipglows_data/technical/code-docs-map.md"
    artifact_version: "1.0.0"
    required_status: reviewed
  - artifact: "shipglows_data/technical/skill-runtime-and-lifecycle.md"
    artifact_version: "1.9.0"
    required_status: reviewed
  - artifact: "skills/references/chantier-tracking.md"
    artifact_version: "0.4.0"
    required_status: draft
supersedes: []
evidence:
  - "Wave 19 canonicalized exact dependency paths against the current repository resource graph."
  - "User decision 2026-05-03: sg-ship successful reports should collapse push, repo state, checks, and bookkeeping into one line."
  - "User decision 2026-05-03: default user reports should be concise; detailed reports should remain available for agent handoff."
  - "User decision 2026-05-03: audit skills should follow the same mechanism, with concise findings by default and fuller detail for handoff."
  - "User decision 2026-05-04: sg-ship user reports should be clearer, ordered as outcome, evidence, then limits, and include a few sober status emojis."
  - "User decision 2026-08-15: successful closure reports use a structured visual card; proof and documentation evidence each remain on one line separated by middle dots."
next_step: "none"
---

# Spec: Skill Reporting Modes And Compact Reports

## Status

ready

## User Story

As a ShipGlows operator, I want skills to default to concise human reports while still supporting detailed agent handoff reports on request, so standalone skill usage stays readable without losing technical traceability for internal orchestration.

## Minimal Behavior Contract

ShipGlows skills that produce final reports must use a shared reporting contract. Default mode is `report=user`: concise, outcome-first, ordered as outcome/evidence/limits, matched to the user's active language, and quiet on successful checks. A few sober status emojis are allowed when they improve scanning. Detailed mode is explicit through `report=agent`, `handoff`, `verbose`, or `full-report`; it is for internal orchestration, debugging, or delegated agent handoff. Skills must not try to magically infer the caller. Master skills that need detailed downstream evidence should pass the explicit handoff flag. Blocked, failed, or partial outcomes must still include enough detail to be actionable.

## Success Behavior

- Successful ship reports collapse push, repo state, checks, and bookkeeping into one status line.
- User-mode ship reports order information as outcome first, evidence second, limits last.
- User-mode labels and explanations follow the user's active language; commands, paths, hashes, and stable status values remain literal.
- User-mode reports may use a few status emojis such as `🚀`, `✅`, `⚠️`, `📝`, and `🎯` when they improve scanning, but they must not decorate every line.
- Lifecycle reports use a compact chantier block: path first, then one `Flux:` line.
- Empty `Reste a faire`, `Prochaine etape`, `Trace spec`, and verdict boilerplate are omitted in user mode.
- Audit reports remain findings-first but default to top issues, proof gaps, and next step instead of full matrices.
- Agent mode may use existing detailed templates, validation matrices, evidence lists, and handoff notes.
- Successful closure reports use four ordered blocks: `✨ RÉSULTAT`, `🧪 PREUVES`, `📚 DOCUMENTATION`, and `📦 LIVRAISON`.
- Proof and documentation content each occupy one line separated by ` · `; empty limits and next-action blocks are omitted.

## Error Behavior

- Failed checks, blocked ships, unresolved high-risk bugs, missing evidence, and partial verification must be explicit even in concise mode.
- A skill should include the exact failing gate, command, file, or next action when the user cannot proceed without it.
- If a master skill wants a detailed downstream report, it must request `report=agent` explicitly.

## Scope In

- Add a shared reporting reference.
- Update chantier reporting doctrine.
- Adopt the report modes in master lifecycle skills.
- Adopt the audit report mode in the `sg-audit*` family.
- Update technical and workflow docs.

## Scope Out

- Do not rewrite every historical detailed report template line by line.
- Do not remove detailed audit matrices; reserve them for agent/handoff mode.
- Do not infer user-vs-agent caller from runtime state.
- Do not change git, validation, or chantier trace semantics.

## Current Chantier Flow

| Skill | Status |
|-------|--------|
| sg-spec | ready |
| sg-ready | ready |
| sg-start | implemented |
| sg-verify | verified |
| sg-end | closed |
| sg-ship | shipped |
| 900-shipglows-core | implemented |

## Follow-up Verification: Visual Closure Card

`ZOMBIES coverage`: zero/empty limits and next-action blocks are omitted; one or many proof/documentation items stay on their single owned line; many items use ` · `; the `needs review` boundary still blocks closure; the shared contract is the interface inherited by `104-sg-end` and `005-sg-ship`; failed or skipped proof stays explicit; the smallest complete solution is one shared card plus focused owner directives and regression tests.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-03 | sg-build | GPT-5 Codex | Created reporting modes spec and implemented shared contract. | implemented | /sg-verify specs/skill-reporting-modes-and-compact-reports.md |
| 2026-05-04 04:45:00 UTC | sg-build | GPT-5 Codex | Resumed the existing reporting modes chantier, verified the bounded scope, and prepared closure through sg-end and sg-ship. | implemented | /sg-ship "Add compact skill reporting modes" |
| 2026-05-04 04:45:00 UTC | sg-verify | GPT-5 Codex | Verified shared reporting contract, lifecycle and audit skill wiring, technical/workflow docs coherence, metadata, language doctrine, and bug gate scope. | verified | /sg-end specs/skill-reporting-modes-and-compact-reports.md |
| 2026-05-04 04:45:00 UTC | sg-end | GPT-5 Codex | Closed tracker and changelog bookkeeping for compact skill reporting modes. | closed | /sg-ship "Add compact skill reporting modes" |
| 2026-05-04 04:45:00 UTC | sg-ship | GPT-5 Codex | Ran scoped checks, committed, and pushed compact skill reporting modes. | shipped | none |
| 2026-05-04 06:05:33 UTC | sg-build | GPT-5 Codex | Applied and targeted-validated a follow-up amendment for clearer user-mode ship reports with active-language labels, outcome/evidence/limits ordering, and sober status emojis. | implemented | /sg-ship "Polish sg-ship user report" |
| 2026-05-04 06:17:29 UTC | sg-ship | GPT-5 Codex | Closed and shipped the sg-ship user-report polish with scoped changelog and spec trace updates. | shipped | none |
| 2026-08-15 12:38:27 UTC | 900-shipglows-core | GPT-5 Codex | Implemented the approved visual closure card, compact one-line proof/documentation evidence, owner alignment, tests, and mapped documentation. | implemented | 103-sg-verify standard pass |
| 2026-08-15 12:38:27 UTC | 103-sg-verify | GPT-5 Codex | Verified section ordering, one-line separators, documentation closure boundary, owner inheritance, metadata, activation graph, skill audit, and context budgets. | verified | local commit |
