---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.2"
project: "shipglows"
created: "2026-06-28"
created_at: "2026-06-28 00:00:00 UTC"
updated: "2026-06-28"
updated_at: "2026-06-28 00:00:00 UTC"
status: reviewed
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "agent-clarity-public-docs-handoffs-phase-2"
owner: "Diane"
user_story: "As the ShipGlows operator, I want public and repo-visible help surfaces to state clear handoff boundaries, so fresh agents and humans know when a surface explains, routes, invokes, or owns execution across help docs, runtime docs, and cheatsheets."
confidence: high
risk_level: medium
security_impact: no
docs_impact: yes
linked_systems:
  - "skills/302-sg-help/SKILL.md"
  - "skills/302-sg-help/references/help-catalog.md"
  - "shipglows_data/technical/skill-runtime-and-lifecycle.md"
  - "README.md"
  - "shipglows_data/workflow/playbooks/spec-driven-workflow.md"
  - "shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md"
  - "shipglows_data/workflow/TASKS.md"
  - "tools/shipglows_metadata_lint.py"
depends_on:
  - artifact: "shipglows_data/workflow/specs/agent-clarity-hardening-phase-7.md"
    artifact_version: "1.0.0"
    required_status: "ready"
  - artifact: "shipglows_data/workflow/specs/agent-clarity-pass-playbook-and-checklist.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
supersedes: []
evidence:
  - "User clarification 2026-06-28: phase 2 should cover public/docs handoff clarity, not only internal skill first-screen wording."
  - "Existing internal clarity work closed skill-boundary phases and a reusable playbook, but no bounded chantier yet owns public/docs handoff clarity across help, runtime docs, README, workflow doctrine, and cheatsheets."
  - "TASKS.md already contains a related runtime-discovery backlog item for OpenCode and KiloCode pages; that item is part of the broader public/docs clarity surface, not the whole chantier."
next_step: "/300-sg-docs shipglows skills runtime docs"
---

# Title

Agent Clarity Public Docs Handoffs Phase 2

## Status

reviewed

## User Story

As the ShipGlows operator, I want public and repo-visible help surfaces to state clear handoff boundaries, so fresh agents and humans know when a surface explains, routes, invokes, or owns execution across help docs, runtime docs, and cheatsheets.

## Minimal Behavior Contract

This phase must make public and repo-visible guidance say the same thing about skill handoffs. Touched surfaces must distinguish explanation from execution, runtime invocation from user-visible commands, and helper routing from lifecycle ownership. The chantier stays documentation-first: it clarifies promises and examples without silently changing workflow ownership.

## Success Behavior

- `skills/302-sg-help/SKILL.md` and `skills/302-sg-help/references/help-catalog.md` make the help boundary and next-owner routing explicit in examples that fresh agents are likely to copy.
- `shipglows_data/technical/skill-runtime-and-lifecycle.md` documents the public/docs handoff taxonomy so future edits preserve `explains vs routes vs invokes vs owns execution`.
- `README.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md`, and `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md` use coherent wording for runtime invocation, skill discovery, and owner-skill handoff.
- The existing OpenCode/KiloCode runtime-pages backlog item is kept explicitly nested under this phase instead of floating as an isolated docs note.

## Error Behavior

- If a doc surface implies that a helper skill continues work it only explains, reject it.
- If runtime docs present internal runtime calls such as `skill({ name: "shipglows" })` as manual operator commands, reject it.
- If examples blur `000-shipglows`, `302-sg-help`, `706-continue`, or owner lifecycle skills, reject it.
- If this phase silently expands into public marketing rewrite or unrelated skill hardening, reject it.

## Pressure Scenarios

- `HELP-VS-DO`: a fresh agent reads help output and must know whether to answer, route, or execute.
- `RUNTIME-VS-USER-COMMAND`: a runtime page must explain what the user types versus what the runtime does internally.
- `CHEATSHEET-VS-OWNERSHIP`: a quick cheatsheet must stay short without hiding which owner skill takes over next.
- `PUBLIC-DOC-DRIFT`: README, workflow doctrine, and runtime docs must not drift into contradictory invocation stories.

## Scope In

- bounded clarity pass for:
  - `skills/302-sg-help/SKILL.md`
  - `skills/302-sg-help/references/help-catalog.md`
  - `shipglows_data/technical/skill-runtime-and-lifecycle.md`
  - `README.md`
  - `shipglows_data/workflow/playbooks/spec-driven-workflow.md`
  - `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md`
- task-tracker clarification linking the broader phase and the OpenCode/KiloCode runtime-pages slice

## Scope Out

- no new workflow ownership changes in `skills/000-shipglows`, `001-sg-build`, or other execution skills unless docs reveal a contradiction that must be split into a separate chantier
- no public site redesign or broad marketing rewrite
- no plugin packaging or runtime code changes
- no aggregate compaction work

## Test Contract

- `python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/agent-clarity-public-docs-handoffs-phase-2.md shipglows_data/technical/skill-runtime-and-lifecycle.md README.md shipglows_data/workflow/playbooks/spec-driven-workflow.md shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md skills/302-sg-help/references/help-catalog.md`
- targeted `rg` checks for `explains`, `routes`, `invokes`, `owns execution`, `skill({ name: "shipglows" })`, `OpenCode`, `KiloCode`, and `continue`
- focused drift scan across the touched surfaces for contradictory skill-invocation examples

## Implementation Tasks

- [x] Write a bounded phase-2 spec for public/docs handoff clarity and distinguish it from internal clarity hardening.
- [x] Clarify `302-sg-help` and its help catalog so examples expose the correct owner boundary.
- [x] Align runtime docs, README, workflow doctrine, and cheatsheet wording on invocation versus ownership.
- [x] Fold the OpenCode/KiloCode runtime-pages backlog item under this phase with explicit tracker wording.
- [x] Validate metadata and drift checks for the bounded docs slice.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-28 | 009-sg-skill-build | GPT-5 Codex | Create phase-2 spec for public/docs handoff clarity and bind the runtime-pages backlog slice under it | implemented | Run the documentation-owner pass through `300-sg-docs` |
| 2026-06-28 | 300-sg-docs | GPT-5 Codex | Align help/docs/runtime wording on explains vs routes vs invokes vs owns execution, fix numeric runtime examples, and clarify OpenCode/KiloCode invocation semantics | implemented | Run `/103-sg-verify agent-clarity-public-docs-handoffs-phase-2` |
| 2026-06-28 | 103-sg-verify | GPT-5 Codex | Verify public/docs handoff clarity across help, runtime docs, README, workflow doctrine, cheatsheet, and spec-linked tracker wording | verified | Run `/104-sg-end agent-clarity-public-docs-handoffs-phase-2` |
| 2026-06-28 | 104-sg-end | GPT-5 Codex | Close the bounded public/docs handoff-clarity slice, mark the main tracker item done, and leave runtime-specific public pages as a linked follow-up | closed | Run `/005-sg-ship agent-clarity-public-docs-handoffs-phase-2` |
| 2026-06-28 | 005-sg-ship | GPT-5 Codex | Ship the bounded public/docs handoff-clarity changes on `main` with metadata, skill visibility, and budget checks passing | shipped | Run `/300-sg-docs shipglows skills runtime docs` |

## Current Chantier Flow

- `100-sg-spec` ✅ phase-2 spec created
- `101-sg-ready` ✅ ready with bounded public/docs scope
- `102-sg-start` ✅ bounded public/docs alignment completed
- `103-sg-verify` ✅ verification passed with metadata, sync, budget, and targeted drift scans
- `104-sg-end` ✅ bounded public/docs closure completed and tracker status aligned
- `005-sg-ship` ✅ pushed on `main`
