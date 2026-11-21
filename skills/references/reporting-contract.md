---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "2.22.0"
project: ShipGlows
created: "2026-05-03"
updated: "2026-11-21"
status: active
source_skill: 001-sg-build
scope: skill-reporting-contract
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems: []
depends_on:
  - artifact: "skills/references/final-report-timestamp.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/reporting-agent-handoff.md"
    artifact_version: "1.2.0"
    required_status: active
  - artifact: "skills/references/reporting-blocked-and-audit.md"
    artifact_version: "1.2.0"
    required_status: active
  - artifact: "skills/references/reporting-pressure-scenarios.md"
    artifact_version: "2.3.0"
    required_status: active
  - artifact: "skills/references/documentation-reflection-gate.md"
    artifact_version: "1.4.0"
    required_status: active
  - artifact: "skills/references/editorial-reflection-gate.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/reporting-start.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/reporting-closure.md"
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Operator correction 2026-09-03: a green merge-ready owned PR remains active delivery; reconciliation and proven cleanup precede returning control."
  - "shipglows_data/technical/progressive-loading-pilot-baseline.md"
next_review: "2026-11-12"
next_step: none
---

# Reporting Contract

## Select The Response

Select before loading leaves; work-report conditions take precedence:

- **Simple question:** one missing factual input; no approval implied.
- **Record confirmation:** save or duplicate-check a supplied internal record; reread, then confirm saved/already present. Never imply future work ran or is done.
- **Work report:** technical work, chantier/spec closure, evidence-dependent status, failed/uncertain writes, mixed execution, material/security/permission decisions, audit, or requested detailed report/handoff.

Simple responses skip reporting leaves, header, clock, status card and next-action search; owner authorization, format, duplicate, fresh-read, privacy and attached-spec tracing still apply. Recording completion is not chantier closure.

## Purpose And Direct Branches

Select every applicable row; leaves never load other reporting leaves. Missing references block reporting. Metadata checks existence/version/status, not eager reads.

| Decision now | Required direct reference under `$SHIPGLOWS_ROOT/skills/references/` |
| --- | --- |
| Approved substantive chantier is actually starting | `reporting-start.md` |
| Explicit `report=agent`, `handoff`, `verbose`, or `full-report` | `reporting-agent-handoff.md` |
| Blocked, partial, risky, security-sensitive, audit, or unfinished result | `reporting-blocked-and-audit.md` |
| Unfinished user result needs operator choices: decision, authority or steering | `strategic-choice-contract.md` |
| Claim underlying work or a chantier closed, complete, done, resolved, or shipped | `reporting-closure.md`, `documentation-reflection-gate.md`, `editorial-reflection-gate.md` |
| Agent handoff lacks a qualified Context Capsule | `context-quality-contract.md` |
| No concrete continuation in the conversation or pending proof/delivery | `next-outcome-selection.md` |
| Context degradation may justify restart, or handoff starts a new conversation | `conversation-continuity-contract.md` |
| Maintenance/testing of reporting behavior | `reporting-pressure-scenarios.md` and only the exercised branches |
| Maintenance/testing of timestamp behavior | `final-report-timestamp.md` |

In `report=agent`, load only agent-handoff for audit/risk detail; start, closure reflections and continuity stay independent and mandatory when triggered.

## Work Report Modes

Default `report=user`: outcome, current proof, material limits, next action; active language, precise machine labels, no tool or lifecycle narration. Agent detail requires explicit request, not caller identity or blockers.

## User Mode

Every final work report, agent mode included, starts with this header and current Europe/Paris verdict:

```text
🧱 CHANTIER (<local|spec>) : <name>
🎯 VERDICT (HH:mm) : <verdict or status>
```

`🚧 CHANTIER` only when blocked; `(spec)` for one owning spec, else `(local)`. Resolve Europe/Paris HH:mm just before reporting, never reused or UTC; no repeated header. After a numbered decision, end with the options and `Réponds avec le numéro, ou précise une autre option.`, then nothing.

In `report=user`, omit modified-file lists, paths, counts and technical links unless needed for operator action or explicitly requested. Never dump matrices, phase ledgers, bulk logs or internal commands.

### Universal compact layout

All work-report states use labelled rows after adjacent headers and one blank line. Keep icon, translated label, optional status and content on one line; one blank line between rows. Prose labels take a colon; status labels (`🧪 PREUVES ✅`) do not. Separate compact items with ` · `; omit inapplicable rows unless mandated. Keep choices contiguous after one blank line, response instruction immediately below. Explicit `report=agent`, handoff, verbose and full-report follow `reporting-agent-handoff.md` instead of this visual layout.

## Reporting Effort Ceiling

A report formats existing required evidence; never create checks, research, docs or content solely for reporting. One meaningful proof suffices; examples are not quotas. Progress reports need outcome, proof, limits and a genuine next decision.

## Mandatory Next Block And Objective Continuity

Every final user work report contains a `🧭 SUITE` block naming a missing action or proof, or an evidenced continuation; never omit the block, never `none` or an empty menu. Take the first sufficient source: current conversation, pending proof/delivery, active chantier, P0 -> P1 -> P2 -> P3 tracker, overdue audit, then grounded improvement; no broad audit just for reporting. Load next-outcome selection only when the conversation and pending delivery provide no next outcome.

An owned, merge-ready pull request with required checks passing remains active in-scope delivery, not a next-step suggestion: before returning control, under standing Git/GitHub stewardship authority, attempt reconciliation into the resolved integration branch, then apply proven-integrated temporary-artifact cleanup. Report a next action only for the exact blocking protection, review, conflict, check, ownership or cleanup fact. Never stop merely because the pull request was opened or became green.

Continue authorized, safely agent-runnable work before the final report; selection never authorizes new or expanded work. Keep the latest unresolved goal active until proven, changed, paused, or blocked by operator-owned authority, decision or inaccessible proof; never stop at an internal milestone. Stabilize and deliver before suggesting a restart, which only the operator starts; length, compaction or a separate outcome alone is insufficient.

## Persistence And Claim Safety

Commit, push and deployment require separate proof. When delivery is ambiguous, show `📦 PERSISTANCE ✅ Local · ✅ Git distant · ➖ Déployé` with actual states, unless `📦 LIVRAISON` explains them. Never describe modified files as “tâche sans mutation”. Include only checks actually run; expose failed, skipped and partial evidence. Never expose secrets, cookies, tokens, private logs, personal data or sensitive screenshots.

A local repair is not a universal prevention guarantee; stronger claims need an explicit invariant, matching scope and focused mechanical proof. Show `Agents: <count> · <mode>` only when topology affects trust (directly dispatched successful agents). One icon per label, except compact proof/delivery.

Useful routing: `🧭 Suite : <résultat ou décision à obtenir> — <raison courte>` below the verdict. Never name a skill, command, lifecycle phase, delegated agent, or internal owner in that line. Use `🧱` for the normal chantier header, `🚧` only when the run is blocked, `📂` for a dossier or scope, `🔨` for active implementation or repair, and `📌` for a priority, decision, or next action; never 🏗️, 🛠️ or ⚙️ as chantier markers.
