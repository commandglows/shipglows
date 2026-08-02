---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-07-09"
created_at: "2026-07-09 00:00:00 UTC"
updated: "2026-07-09"
updated_at: "2026-07-09 00:00:00 UTC"
status: ready
source_skill: 009-sg-skill-build
source_model: "GPT-5 Codex"
scope: workflow-governance
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
user_story: "En tant qu'operatrice ShipGlows qui pilote a la fois du travail technique et du contenu public, je veux un registre editorial distinct du backlog d'execution, afin que les skills ne melangent plus implementation technique et opportunites de contenu."
linked_systems:
  - shipglows_data/workflow/TASKS.md
  - shipglows_data/editorial/README.md
  - shipglows_data/editorial/ROADMAP.md
  - skills/references/operational-record-format.md
  - skills/references/editorial-content-corpus.md
  - skills/205-sg-veille/SKILL.md
  - skills/206-sg-audit-copy/SKILL.md
  - skills/207-sg-audit-copywriting/SKILL.md
  - skills/406-sg-seo/SKILL.md
  - skills/309-sg-tasks/SKILL.md
  - shipglows_data/technical/skill-runtime-and-lifecycle.md
depends_on:
  - artifact: "skills/references/operational-record-format.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "shipglows_data/editorial/content-map.md"
    artifact_version: "0.10.0"
    required_status: draft
  - artifact: "shipglows_data/editorial/README.md"
    artifact_version: "1.3.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Project tracker task dated 2026-07-07 asks for a spec-backed split between execution backlog and editorial roadmap."
  - "Recent content/repurpose work introduced durable source-faithful packs and content-owner handoffs, increasing the need for an editorial follow-up register."
  - "Current content-oriented skills still mention shipglows_data/workflow/TASKS.md for content findings, which mixes public/editorial follow-ups with technical execution work."
next_step: "/009-sg-skill-build workflow vs editorial roadmap split"
---

# Spec: Workflow vs Editorial Roadmap Split

## Title

Workflow vs Editorial Roadmap Split

## Status

Ready.

## User Story

En tant qu'operatrice ShipGlows qui pilote a la fois du travail technique et du contenu public, je veux un registre editorial distinct du backlog d'execution, afin que les skills ne melangent plus implementation technique et opportunites de contenu.

## Minimal Behavior Contract

`shipglows_data/workflow/TASKS.md` becomes the execution tracker for technical or implementation work. Public-content, repurposing, editorial, copy, SEO-content, FAQ, docs-publics, and audience-email follow-ups live in a separate operational artifact at `shipglows_data/editorial/ROADMAP.md`. Skills that currently write content follow-ups to `TASKS.md` must instead route those records to the editorial roadmap, while mixed outputs split technical records and editorial records into the appropriate files.

## Success Behavior

- A canonical editorial operational tracker exists under `shipglows_data/editorial/ROADMAP.md`.
- Shared doctrine explains when to write to `workflow/TASKS.md` versus `editorial/ROADMAP.md`.
- `205-sg-veille`, `206-sg-audit-copy`, `207-sg-audit-copywriting`, and `406-sg-seo` load the shared routing rule before tracker writes.
- `309-sg-tasks` keeps explicit ownership of execution trackers and does not claim the editorial roadmap as its default domain.
- Current ShipGlows tracker state no longer keeps the split decision as an open todo.

## Error Behavior

- If a content surface is undeclared, report `surface missing` instead of creating an editorial roadmap item that implies the surface exists.
- If one finding spans both technical execution and editorial follow-up, create paired records in both trackers instead of collapsing them into one ambiguous task.
- If the target tracker anchor is ambiguous after authoritative re-read, stop and ask rather than forcing a rewrite.

## Scope In

- Create `shipglows_data/editorial/ROADMAP.md`.
- Create one shared tracker-routing reference for execution vs editorial writes.
- Update the relevant content and audit skills to use that routing rule.
- Update the editorial and runtime doctrine docs that describe the new artifact.
- Update the current ShipGlows tracker item that requested this split.

## Scope Out

- Migrate historical editorial tasks from every external project repository.
- Create a new lifecycle master skill for editorial planning.
- Replace chantier specs as the source of truth for non-trivial content work.
- Add frontmatter to operational trackers.

## Constraints

- `shipglows_data/workflow/specs/` remains the chantier registry.
- Operational trackers stay plain Markdown without ShipGlows metadata frontmatter.
- The editorial roadmap must stay operational, not become a second governance corpus.
- Shared routing doctrine should live in a reusable reference first; local skill wording should only narrow it.

## Invariants

- Technical implementation backlog remains in `shipglows_data/workflow/TASKS.md`.
- Editorial/public-content backlog remains in `shipglows_data/editorial/ROADMAP.md`.
- Specs remain the source of truth for non-trivial chantiers.
- A content task does not become technical just because it is discovered during an audit.

## Implementation Tasks

- [x] Task 1: Create the shared routing contract and the editorial roadmap artifact.
- [x] Task 2: Rewire content and audit skills that currently write content follow-ups into `workflow/TASKS.md`.
- [x] Task 3: Update doctrine docs and close the open ShipGlows tracker item.

## Acceptance Criteria

- [x] AC1: `shipglows_data/editorial/ROADMAP.md` exists and is clearly operational.
- [x] AC2: a shared reference names the split between execution tracker and editorial roadmap.
- [x] AC3: the affected skills and workflow references mention the new routing rule.
- [x] AC4: `shipglows_data/workflow/TASKS.md` no longer keeps the split as an open todo.

## Test Strategy

- Metadata lint for changed governed docs and references.
- Skill budget audit after skill/reference changes.
- Focused `rg` checks for `ROADMAP.md`, `workflow/TASKS.md`, and the routing reference across affected skills.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-07-09 00:00:00 UTC | 100-sg-spec | GPT-5 Codex | Created the ready spec directly from the open tracker item and explicit operator request. | ready | /009-sg-skill-build workflow vs editorial roadmap split |
| 2026-07-09 00:00:00 UTC | 101-sg-ready | GPT-5 Codex | Confirmed the artifact path, impacted skills, routing doctrine, and validation surface are explicit. | ready | /009-sg-skill-build workflow vs editorial roadmap split |
| 2026-07-09 00:00:00 UTC | 009-sg-skill-build | GPT-5 Codex | Created the editorial roadmap artifact, added the shared tracker-routing contract, rewired affected skills, and updated doctrine. | implemented | /103-sg-verify workflow vs editorial roadmap split |
| 2026-07-09 16:10:55 UTC | 103-sg-verify | GPT-5 Codex | Verified metadata lint, skill budget audit, runtime skill visibility checks, and focused routing grep checks for the tracker split. | verified | user review or bounded ship |
| 2026-07-11 00:00:00 UTC | 009-sg-skill-build | GPT-5 Codex | Added explicit `300-sg-docs` loading and playbook language so `update` and `editorial` modes recognize `shipglows_data/editorial/ROADMAP.md` as the editorial backlog companion. | implemented | /103-sg-verify workflow vs editorial roadmap split |
| 2026-07-11 11:43:16 UTC | 103-sg-verify | GPT-5 Codex | Verified the explicit `300-sg-docs` routing update with metadata lint, skill budget audit, runtime sync, and focused grep checks for `ROADMAP.md` in `update` and `editorial` playbooks. | verified | user review or bounded ship |

## Current Chantier Flow

- `100-sg-spec`: done, ready spec created.
- `101-sg-ready`: done, readiness confirmed.
- `102-sg-start`: done via `009-sg-skill-build` bounded implementation.
- `103-sg-verify`: done, validation passed.
- `104-sg-end`: not launched.
- `005-sg-ship`: not launched.

Next step: user review or bounded ship
