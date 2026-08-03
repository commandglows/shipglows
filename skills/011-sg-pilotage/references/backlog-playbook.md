---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-03"
updated: "2026-08-03"
status: active
source_skill: 011-sg-pilotage
scope: pilotage-backlog-mode
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/011-sg-pilotage/SKILL.md
  - shipglows_data/workflow/BACKLOG.md
  - shipglows_data/workflow/TASKS.md
depends_on:
  - artifact: skills/references/operational-record-format.md
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Transferred from 701-sg-backlog under the approved pilotage consolidation."
next_step: "$011-sg-pilotage backlog"
---

# Backlog Mode Playbook

## Outcome

Capture, defer, review, clean, or promote future work without pretending it is active execution or calculating a hidden priority. Use `shipglows_data/workflow/BACKLOG.md` for deferred project work and `shipglows_data/workflow/TASKS.md` only when a confirmed promotion or deferral changes active work.

## Mode Grammar

- `backlog add <item>` records a bounded idea with date, context, category, and known dependency.
- `backlog defer [item]` moves confirmed non-current work from the active tracker with a reason and review trigger.
- `backlog review` identifies up to three credible promotion candidates and explains the changed context or completed prerequisite.
- `backlog clean` identifies obsolete, duplicated, or completed-elsewhere items.
- bare `backlog` asks which one of these backlog outcomes is wanted when the intended action cannot be inferred safely.

An idea too vague to record cleanly routes to `700-sg-explore`. Active execution-order questions route to `priorities`; retrospective questions route to `review`. This mode does not rank active work, calculate a hidden P0, or execute promoted tasks.

At a workspace root or when several projects are credible targets, load the question contract and ask for one project scope before reading or writing a backlog. Portfolio output is derived from local project backlogs and never creates a central control-plane backlog.

## Write Safety

Load `$SHIPGLOWS_ROOT/skills/references/operational-record-format.md` before mutating task/backlog records and `$SHIPGLOWS_ROOT/skills/references/question-contract.md` before project, deletion, or promotion questions.

Treat initial snapshots as informational. Immediately before any mutation, authoritatively re-read every affected tracker, apply the smallest possible patch, then re-read the result. If an anchor moved, re-read once and recompute; if ambiguity remains, write nothing.

When the project backlog does not exist, create it only for an explicit add/defer action and preserve a readable structure such as `Future Features`, `Technical Debt`, `Ideas & Research`, `Deferred`, and `Discarded`.

## Action Rules

### Add

Record why the idea matters, when it was added, its category, and known prerequisites. Do not activate it implicitly.

### Defer

Preserve the task's context, add a deferral reason and review milestone, then remove only the confirmed active record. Verify both target states after the bounded two-file mutation.

### Review And Promote

Recommend promotion only when context changed, prerequisites completed, or strategic relevance increased. Require explicit selection before moving an item. After promotion, make `$011-sg-pilotage priorities` the explicit later route when active ranking is needed.

### Clean

Explain every candidate first. Load the question contract and confirm before deleting or discarding. Preserve removed items in a dated `Discarded` section with a reason; direct deletion without this confirmation is forbidden.

### Harvest Explicit TODOs

During an explicit backlog review, scan bounded code paths for significant `TODO` or `FIXME` markers and record only credible non-duplicates with their project-relative file/line evidence. Do not broaden a simple add/defer request into a repository-wide code audit.

## Output

Report additions, deferrals, promotions, preserved discarded evidence, untouched items, and the next relevant mode. Never describe backlog capture as execution or prioritization.
