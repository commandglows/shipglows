---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-07-11"
created_at: "2026-07-11 12:05:00 UTC"
updated: "2026-07-11"
updated_at: "2026-07-11 17:00:59 UTC"
status: ready
source_skill: 009-sg-skill-build
source_model: "GPT-5 Codex"
scope: workflow-governance
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
user_story: "En tant qu'operatrice ShipGlows qui initialise ou adopte des projets avec des surfaces publiques, je veux que le backlog editorial operationnel soit cree automatiquement quand il est applicable, afin que les skills de contenu trouvent tout de suite le bon registre sans me faire repasser manuellement sur chaque repo."
linked_systems:
  - skills/305-sg-init/SKILL.md
  - skills/305-sg-init/references/bootstrap-workflow.md
  - skills/300-sg-docs/SKILL.md
  - skills/300-sg-docs/references/mode-playbooks.md
  - skills/300-sg-docs/references/bootstrap-starter-templates.md
  - skills/references/editorial-content-corpus.md
  - skills/references/task-registry-routing.md
  - shipglows_data/editorial/README.md
  - shipglows_data/editorial/ROADMAP.md
  - shipglows_data/workflow/specs/workflow-vs-editorial-roadmap-split.md
depends_on:
  - artifact: "shipglows_data/workflow/specs/workflow-vs-editorial-roadmap-split.md"
    artifact_version: "1.0.0"
    required_status: "ready"
  - artifact: "skills/references/editorial-content-corpus.md"
    artifact_version: "1.4.0"
    required_status: "active"
  - artifact: "skills/references/task-registry-routing.md"
    artifact_version: "1.0.0"
    required_status: "active"
supersedes: []
evidence:
  - "The tracker split between execution backlog and editorial roadmap is already documented, but bootstrap workflow still only guarantees the editorial governance corpus and not the operational companion."
  - "The init workflow reports `shipglows_data/editorial` state yet does not explicitly create or report `shipglows_data/editorial/ROADMAP.md` when public surfaces exist."
  - "Operator decision on 2026-07-11: the missing piece is the automatable creation process for this file in projects that need it."
next_step: "/103-sg-verify editorial roadmap bootstrap for governed projects"
---

# Spec: Editorial Roadmap Bootstrap for Governed Projects

## Title

Editorial Roadmap Bootstrap for Governed Projects

## Status

Ready.

## User Story

En tant qu'operatrice ShipGlows qui initialise ou adopte des projets avec des surfaces publiques, je veux que le backlog editorial operationnel soit cree automatiquement quand il est applicable, afin que les skills de contenu trouvent tout de suite le bon registre sans me faire repasser manuellement sur chaque repo.

## Minimal Behavior Contract

When `305-sg-init` or `300-sg-docs` bootstraps editorial governance for a project with detected public/editorial surfaces, the workflow must also create or explicitly report the state of `shipglows_data/editorial/ROADMAP.md`. That file remains an operational tracker, not a governance artifact, but it should exist by default alongside the editorial corpus whenever the project is expected to accumulate public-content follow-up. If no public/editorial surfaces are detected, the workflow must skip the roadmap explicitly instead of creating noise.

## Success Behavior

- `305-sg-init` creates `shipglows_data/editorial/ROADMAP.md` when public/editorial surfaces are detected and `shipglows_data/editorial/` can be written safely.
- `300-sg-docs` bootstrap/update/editorial flows treat the roadmap as the operational companion to the editorial governance corpus.
- Bootstrap starter templates describe the minimal default content for `shipglows_data/editorial/ROADMAP.md`.
- Final bootstrap reporting names the roadmap state explicitly, instead of hiding it inside the broader editorial-governance status.
- Existing projects with public/editorial surfaces but a missing roadmap are treated as recoverable bootstrap or update work, not as an implicit manual task.

## Error Behavior

- If no public/editorial surfaces are detected, report `shipglows_data/editorial/ROADMAP.md: skipped - no editorial surfaces detected`.
- If `shipglows_data/editorial/` exists but the roadmap cannot be created safely, report the file as `blocked` and route to `/300-sg-docs editorial`.
- If a project is internal-only and no durable public-content work applies, do not create the roadmap just because `shipglows_data/workflow/TASKS.md` exists.
- Do not let the roadmap become a second governance corpus or a surrogate for missing public surface declarations.

## Scope In

- Add explicit roadmap bootstrap rules to `305-sg-init` bootstrap workflow.
- Add a starter template contract for `shipglows_data/editorial/ROADMAP.md`.
- Update `300-sg-docs` playbooks so editorial bootstrap/update understands when to create or preserve the roadmap.
- Update the editorial-content corpus reference if needed so owner skills know the roadmap should exist after bootstrap on applicable projects.

## Scope Out

- Auto-populate roadmap tasks from old content history.
- Create the roadmap for internal-only projects with no public/editorial surfaces.
- Replace `shipglows_data/editorial/README.md` or other governance docs with tracker content.
- Introduce a scheduler or mailbox automation in this change.

## Constraints

- `shipglows_data/editorial/ROADMAP.md` stays plain operational Markdown without frontmatter.
- Creation must be evidence-based from detected public/editorial surfaces.
- `shipglows_data/workflow/TASKS.md` remains the execution tracker and is not backfilled with editorial work.
- The bootstrap path must remain compatible with monorepo-root governance rules.

## Invariants

- Editorial governance and editorial operational follow-up are distinct files with distinct roles.
- Missing editorial surfaces means the roadmap is skipped, not invented.
- `300-sg-docs` remains the owner skill for longer-term editorial governance maintenance.
- `305-sg-init` may bootstrap the file but should not become the long-term roadmap planner.

## Implementation Tasks

- [x] Task 1: Add the ready spec and explicit starter template for `shipglows_data/editorial/ROADMAP.md`.
- [x] Task 2: Update `305-sg-init` bootstrap workflow and final reporting so roadmap creation is automatic and visible.
- [x] Task 3: Update `300-sg-docs` and shared corpus references so existing-project adoption preserves the same behavior.

## Acceptance Criteria

- [x] AC1: `skills/300-sg-docs/references/bootstrap-starter-templates.md` includes a minimal template contract for `shipglows_data/editorial/ROADMAP.md`.
- [x] AC2: `skills/305-sg-init/references/bootstrap-workflow.md` explicitly creates or skips the roadmap based on editorial-surface detection.
- [x] AC3: `skills/305-sg-init` final reporting names `shipglows_data/editorial/ROADMAP.md` status directly.
- [x] AC4: `skills/300-sg-docs` editorial/bootstrap/update playbooks no longer leave roadmap creation implicit on applicable projects.

## Test Strategy

- Metadata lint for changed governed artifacts and spec files.
- Skill budget audit after skill/reference edits.
- Sync validation for touched skills.
- Focused `rg` checks for `shipglows_data/editorial/ROADMAP.md` across init/docs references.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-07-11 12:05:00 UTC | 100-sg-spec | GPT-5 Codex | Wrote a focused ready spec directly from the operator-confirmed gap in roadmap bootstrap behavior. | ready | /009-sg-skill-build editorial roadmap bootstrap for governed projects |
| 2026-07-11 12:05:00 UTC | 101-sg-ready | GPT-5 Codex | Confirmed the scope, owned files, creation rules, and validation surface are explicit enough for bounded implementation. | ready | /009-sg-skill-build editorial roadmap bootstrap for governed projects |
| 2026-07-11 12:17:00 UTC | 009-sg-skill-build | GPT-5 Codex | Added the roadmap bootstrap template, taught `305-sg-init` to create/report `shipglows_data/editorial/ROADMAP.md`, and aligned `300-sg-docs` and the editorial corpus reference with the same normalization rule. | implemented | /103-sg-verify editorial roadmap bootstrap for governed projects |
| 2026-07-11 12:21:16 UTC | 103-sg-verify | GPT-5 Codex | Verified the roadmap-bootstrap change with metadata lint, skill budget audit, runtime sync checks for `300-sg-docs` and `305-sg-init`, and focused grep checks for explicit `ROADMAP.md` bootstrap/reporting semantics. | verified | /104-sg-end editorial roadmap bootstrap for governed projects |
| 2026-07-11 12:30:00 UTC | 104-sg-end | GPT-5 Codex | Closed the chantier bookkeeping by syncing the done state into `shipglows_data/workflow/TASKS.md`, adding the changelog entry, and preserving the unshipped state for `005-sg-ship`. | closed | /005-sg-ship editorial roadmap bootstrap for governed projects |
| 2026-07-11 17:00:59 UTC | 005-sg-ship | GPT-5 Codex | Shipped the bounded roadmap-bootstrap scope to `origin/main` with metadata lint, skill budget audit, and `300-sg-docs` runtime sync checks; left unrelated dirty files out of the commit. | shipped | none |

## Current Chantier Flow

- `100-sg-spec`: done, ready spec created.
- `101-sg-ready`: done, readiness confirmed.
- `102-sg-start`: done via `009-sg-skill-build` bounded implementation.
- `103-sg-verify`: verified.
- `104-sg-end`: closed.
- `005-sg-ship`: shipped.

Next step: none
