---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-21"
updated: "2026-09-03"
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
  - "Operator correction 2026-09-03: true completion reports `chantier clos` rather than inventing unrelated continuation."
  - "Operator correction 2026-08-21: a mandatory SUITE must always select real business continuity and may never report that no action remains."
next_review: "2026-09-21"
next_step: none
---

# Next Outcome Selection

## Purpose

Select one concrete, evidence-backed continuation for `🧭 SUITE` while work remains. The block is a business-continuity decision, not a ceremonial footer. A fully completed and delivered chantier may return the explicit terminal status `Chantier clos.`; it never disguises unfinished work as closure or invents unrelated work merely to avoid a terminal result.

## Ordered Selection Ladder

Use the first applicable level and stop. Never skip a higher level for a fresher or more interesting idea.

1. **Current conversation outcome** — Continue the latest unresolved operator goal or a previously opened chantier in the current conversation. If the next in-scope step is authorized and safely agent-runnable, perform it before final reporting rather than merely suggesting it.
2. **Pending proof or delivery** — Finish missing validation, review, PR, preview, commit, push, deployment evidence, documentation, or editorial alignment already required by the current or earlier conversational chantier.
3. **Active chantier** — Resume the highest-priority active spec, bug, release, or tracked work item whose dependencies are satisfied. Preserve explicit operator pauses and blockers.
4. **Prioritized tracker** — Read `shipglows_data/workflow/TASKS.md` when present and select actionable work in strict `P0 -> P1 -> P2 -> P3` order. Within a priority, prefer work that protects users or data, removes a blocker, completes already-started value, or has the strongest durable business impact. Do not inflate severity to force a choice.
5. **Overdue audit** — Compare `shipglows_data/workflow/AUDIT_LOG.md` with `skills/references/audit-cadence-matrix.json`. Select the first event-triggered, never-run, or most overdue applicable domain returned by `tools/audit_cadence_status.py`. A project-specific documented matrix may be stricter than the shared default.
6. **Grounded business improvement** — Use current product, business, customer, editorial, security, quality, or funnel evidence to name one bounded improvement with a clear stakeholder and outcome. Never invent busywork, unsupported urgency, a public promise, or a speculative platform expansion merely to fill the block.

If no level has an evidence-backed candidate after the current chantier, its proof, delivery, reconciliation, and owned cleanup are complete, stop the ladder and report `Chantier clos.` Do not inspect unrelated branches, trackers, audits, repositories, or product surfaces solely to manufacture continuation.

## Output And Execution Boundary

State one next outcome and why it wins now. Mention an operator action only when approval, credentials, provider access, manual judgment, or another genuine authority boundary requires it. Do not expose internal skill names or commands in user mode.

Selection never grants mutation authority for a new or materially expanded chantier. Current authorized work continues through its existing contract; a new unrelated mutation receives its normal plan and approval. A blocked higher-level candidate does not hide independent work at the same or next level, but the report must preserve the blocker as durable state.

Do not run a broad audit solely to populate `🧭 SUITE`. Reading the current conversation state, active work records, tracker, audit log, and cadence status is selection evidence. The selected audit or improvement becomes the next chantier, not hidden work inside report generation.

## Failure Conditions

- `SUITE-FALSE-CLOSURE`: `Chantier clos.` while current work, proof, delivery, reconciliation, or owned cleanup remains unfinished.
- `SUITE-INVENTED`: unrelated inventory, audit, cleanup, or improvement proposed solely because the completed chantier had no natural continuation.
- `SUITE-SKIPPED-CONTEXT`: tracker, audit, or a new idea selected while current conversational work or delivery proof remains unfinished.
- `SUITE-PRIORITY-INVERSION`: lower-priority tracker work selected without evidence that higher-priority work is blocked or inapplicable.
- `SUITE-STALE-AUDIT`: an audit suggestion ignores newer `AUDIT_LOG.md` evidence or the declared cadence.
- `SUITE-AUTHORITY-LEAK`: the chosen continuation is executed as though selection itself authorized a new mutation.
