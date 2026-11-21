---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-21"
updated: "2026-11-21"
status: active
source_skill: 900-shipglows-core
scope: next-outcome-selection
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/references/reporting-contract.md
  - skills/references/audit-cadence-matrix.json
  - skills/011-sg-pilotage/references/priorities-playbook.md
  - skills/002-sg-maintain/references/maintenance-playbooks.md
  - shipglows_data/workflow/TASKS.md
  - shipglows_data/workflow/AUDIT_LOG.md
depends_on:
  - artifact: skills/references/reporting-contract.md
    artifact_version: "2.10.0"
    required_status: active
supersedes: []
evidence:
  - "Operator correction 2026-08-21: a mandatory SUITE must always select real business continuity and may never report that no action remains."
next_review: "2026-09-21"
next_step: none
---

# Next Outcome Selection

## Purpose

Select one concrete, evidence-backed continuation for every `🧭 SUITE`: a business-continuity decision, not a ceremonial footer. It never returns `none`, `no action required`, an empty menu, or an equivalent.

## Ordered Selection Ladder

Use the first applicable level and stop; never skip a higher level for a fresher idea.

1. **Current conversation outcome** — Continue the latest unresolved operator goal or an open chantier. If the next in-scope step is authorized and agent-runnable, perform it before final reporting, not merely suggest it.
2. **Pending proof or delivery** — Finish missing validation, review, PR, preview, commit, push, deployment evidence, documentation, or editorial alignment already required by a current or earlier chantier.
3. **Active chantier** — Resume the highest-priority active spec, bug, release, or tracked item whose dependencies are met. Preserve explicit operator pauses and blockers.
4. **Prioritized tracker** — When `shipglows_data/workflow/TASKS.md` exists, select actionable work in strict `P0 -> P1 -> P2 -> P3` order. Within a priority, prefer user or data protection, blocker removal, already-started value, or the strongest durable business impact. Never inflate severity to force a choice.
5. **Overdue audit** — Compare `shipglows_data/workflow/AUDIT_LOG.md` with `skills/references/audit-cadence-matrix.json`. When `python3 "${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/tools/project_docs_tidy_audit.py" . --check` reports `due`, pass `--trigger workflow-tidy`: a workflow backlog makes the tidy event-triggered regardless of elapsed time. Select the first applicable event-triggered, never-run, or most overdue domain from `tools/audit_cadence_status.py`; a project matrix may be stricter than the shared default.
6. **Grounded business improvement** — Use current product, business, customer, editorial, security, quality, or funnel evidence to name one bounded improvement with a clear stakeholder and outcome. Never invent busywork, urgency, public promises, or speculative expansion to fill the block.

## Output And Execution Boundary

State one next outcome and why it wins now. Name an operator action only when approval, credentials, provider access, manual judgment, or another genuine authority boundary requires it; never expose internal skill names or commands in user mode.

Selection never grants mutation authority for a new or materially expanded chantier. Authorized work continues under its existing contract; an unrelated new mutation gets its normal plan and approval. A blocked higher-level candidate does not hide independent work at the same or next level, but the report keeps the blocker as durable state.

Do not run a broad audit solely to populate `🧭 SUITE`; reading conversation state, work records, tracker, audit log, and cadence status is selection evidence. The selected audit becomes the next chantier, not hidden report work.

## Failure Conditions

- `SUITE-NULL`: `none`, `no action required`, “nothing else,” or an equivalent null continuation.
- `SUITE-SKIPPED-CONTEXT`: tracker, audit, or a new idea selected while current work or delivery proof remains unfinished.
- `SUITE-PRIORITY-INVERSION`: lower-priority tracker work selected without evidence that higher-priority work is blocked or inapplicable.
- `SUITE-STALE-AUDIT`: an audit suggestion ignores newer `AUDIT_LOG.md` evidence or the declared cadence.
- `SUITE-AUTHORITY-LEAK`: the continuation runs as though selection authorized a new mutation.
