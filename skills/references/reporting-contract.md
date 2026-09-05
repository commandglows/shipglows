---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "2.19.0"
project: ShipGlows
created: "2026-05-03"
updated: "2026-09-05"
status: active
source_skill: 001-sg-build
scope: skill-reporting-contract
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/*/SKILL.md
  - skills/references/chantier-tracking.md
  - skills/references/final-report-timestamp.md
  - skills/references/documentation-reflection-gate.md
  - skills/references/editorial-reflection-gate.md
  - skills/references/next-outcome-selection.md
  - skills/references/audit-cadence-matrix.json
  - skills/references/conversation-continuity-contract.md
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
  - "Existing reporting requirements preserved in direct start/closure leaves by the approved progressive-loading pilot. Historical evidence is in shipglows_data/technical/progressive-loading-pilot-baseline.md."
next_review: "2026-11-12"
next_step: none
---

# Reporting Contract

## Purpose And Direct Branches

Apply this contract before every final ShipGlows report. Select all applicable
rows directly here; a leaf never discovers or loads another reporting leaf.
Missing required references block the affected report; never silently omit a gate.
The structured dependencies above validate existence/version/status, not eager reads.

| Decision now | Required direct reference under `$SHIPGLOWS_ROOT/skills/references/` |
| --- | --- |
| Approved substantive chantier is actually starting | `reporting-start.md` |
| Explicit `report=agent`, `handoff`, `verbose`, or `full-report` | `reporting-agent-handoff.md` |
| Blocked, partial, risky, security-sensitive, audit, or unfinished user result | `reporting-blocked-and-audit.md` |
| Unfinished user result needs operator choices: missing decision, authority or requested steering | `strategic-choice-contract.md` |
| Claim closed, complete, done, resolved, or shipped | `reporting-closure.md`, `documentation-reflection-gate.md`, `editorial-reflection-gate.md` |
| Agent handoff lacks a qualified Context Capsule | `context-quality-contract.md` |
| No concrete continuation in the conversation or pending proof/delivery | `next-outcome-selection.md` |
| Context degradation may justify restart, or handoff starts a new conversation | `conversation-continuity-contract.md` |
| Maintenance/testing of reporting behavior | `reporting-pressure-scenarios.md` and only the exercised branches |
| Maintenance/testing of timestamp behavior | `final-report-timestamp.md` |

In `report=agent`, load only agent-handoff for report detail: it includes audit
and risk detail. Start, closure reflections and continuity are independent gates,
not waived by report mode. Branches never chain. The default successful
`report=user` needs no detail branch unless it claims closure.

## Report Modes

Default to `report=user`: outcome first, current-run proof, material limits, then
one genuine operator action. Use the active language, retaining precise machine labels. Do not narrate routine
tools, internal owners or lifecycle stages. Agent detail requires explicit
operator/orchestrator request; never infer it from caller identity or blockers.

## User Mode

Every final report, including agent mode, uses one chantier header followed by
the current Europe/Paris verdict. Start every user report with exactly:

```text
🧱 CHANTIER (<local|spec>) : <name>
🎯 VERDICT (HH:mm) : <verdict or status>
```

Use `🚧 CHANTIER` only for genuinely blocked work; `(spec)` only for exactly one
owning spec, otherwise `(local)`. Immediately before final reporting resolve the
current clock in Europe/Paris; never reuse UTC or a previous time. Display HH:mm
only, preserve UTC for machine ledgers. No trailing or duplicate chantier header.
After a numbered decision end with the options followed by
`Réponds avec le numéro, ou précise une autre option.`; append no second verdict,
timestamp or reminder.

Do not include a modified-files section in `report=user`. Omit file names, paths,
counts, and clickable technical file links unless the operator must open, edit,
or provide the exact artifact to proceed or explicitly requests detailed evidence.
Never dump matrices, phase ledgers, bulk logs or internal commands in user mode.

### Universal compact layout

After the adjacent chantier and verdict header lines, leave one blank line before the substantive response. Every user-facing report state—start, progress, partial, blocked, audit, closure, delivery, persistence, limits, context, continuation, and decision framing—uses compact labelled rows: keep the icon, translated label, optional status marker, and content together on one line, then insert exactly one blank line before the next labelled row. Use a colon after prose labels such as `✨ OBJECTIF :`, `✨ RÉSULTAT :`, or `🔨 PROGRESSION :`; status-bearing rows such as `🧪 PREUVES ✅`, `⚠️ LIMITES`, and `🧠 CONTEXTE ✅` need no colon. Separate compact items inside a row with ` · `.

Omit rows that do not apply except those mandatory for the active report state. Keep a numbered choice list contiguous as one atomic decision block: leave one blank line before it, do not insert blank lines between its options, and keep its response instruction directly after the list. Explicit `report=agent`, handoff, verbose, and full-report outputs retain the operational structure defined by `reporting-agent-handoff.md` and are exempt from this visual layout.

For ordinary user-facing progress, partial, blocked, or audit results, select only the rows that carry current value, for example:

```text
🔨 PROGRESSION : <completed outcome or current state>

🧪 PREUVES ✅ <current proof> · ⚠️ <proof gap when material>

⚠️ LIMITES <concrete blocker, risk, or remaining gap>

🧠 CONTEXTE ✅ <continuity status and conversation guidance>

🧭 SUITE ➡️ <next outcome, recovery action, or decision>
```

## Reporting Effort Ceiling

A report formats required evidence; it never creates additional checks, research,
docs or content solely for reporting. One meaningful proof suffices; example placeholders are not quotas.
Keep each compact evidence line on one line with ` · ` separators. Non-closure
progress needs only outcome, proof, material limits and a genuine next decision.

## Mandatory Next Block And Objective Continuity

Every final user report contains a `🧭 SUITE` block naming a missing action or proof
or an evidenced continuation; never omit the block; never `none`, “no action required”,
or an empty menu. Select the first applicable level: current conversation outcome,
pending proof/delivery, active chantier, P0 -> P1 -> P2 -> P3 tracker, overdue audit,
then grounded improvement. Stop at the first sufficient evidence; no broad audit
solely for reporting. The detailed selection reference is required only when the
conversation and pending delivery do not already establish the next outcome.

Continue authorized safely agent-runnable work before final reporting. Selection
never authorizes a new or materially expanded chantier. Keep the latest unresolved
goal active until proven, explicitly changed/paused, or blocked by operator-owned
authority, decision or inaccessible proof. Do not stop at an internal milestone.
When context is degraded, stabilize and deliver before recommending restart; only
the operator starts it. Length, compaction or a separate outcome alone is insufficient.

## Persistence And Claim Safety

Distinguish local, remote Git and deployment by matching proof. A commit is not a
push; a push is not a deployment. When ambiguity matters, show `📦 PERSISTANCE`
with evidence-backed Local / Git distant / Déployé states (for example `📦 PERSISTANCE ✅ Local · ✅ Git distant · ➖ Déployé`); omit this duplicate
when `📦 LIVRAISON` already makes delivery clear. Never describe modified files as
“tâche sans mutation”.

Include only checks actually run; expose failed, skipped and partial evidence.
Never expose secrets, cookies, tokens, private logs, personal data or sensitive
screenshots. A local repair is not a universal prevention guarantee: stronger claims
require an explicit invariant, matching scope and focused mechanical proof.
Count directly dispatched successful agents only; show `Agents: <count> · <mode>`
only when topology affects trust. Use semantic icons consistently, at most one per
labelled line except compact proof/delivery; never use 🏗️, 🛠️ or ⚙️ as chantier markers.

When routing is useful, put `🧭 Suite : <résultat ou décision à obtenir> — <raison courte>`
below the verdict. Never name a skill, command, lifecycle phase, delegated agent,
or internal owner in that user-facing line. Use `🧱` for the normal chantier header
and `🚧` only when the run is blocked. Compact proof may read
`✅ Tests 18/18 · 🧾 Métadonnées OK · 🔄 Sync 236/236`; include only actual proof.

Use `📂` for a dossier or scope, `🔨` for active implementation or repair,
and `📌` for a priority, decision, or next action.
