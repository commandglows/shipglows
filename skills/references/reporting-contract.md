---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "2.20.0"
project: ShipGlows
created: "2026-05-03"
updated: "2026-09-06"
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

## Direct Branches

Before every final ShipGlows report, select applicable branches directly below.
Leaves never load one another; missing required references block the affected
report. Metadata dependencies validate existence/version/status, not eager reads.
All references resolve under `$SHIPGLOWS_ROOT/skills/references/`.

| Decision now | Required reference |
| --- | --- |
| Approved substantive chantier actually starts | `reporting-start.md` |
| Explicit `report=agent`, `handoff`, `verbose`, or `full-report` | `reporting-agent-handoff.md` |
| Blocked, partial, risky, security-sensitive, audit, or unfinished user result | `reporting-blocked-and-audit.md` |
| Unfinished user result needs operator choices: decision, authority or requested steering | `strategic-choice-contract.md` |
| Claim closed, complete, done, resolved, or shipped | `reporting-closure.md`, `documentation-reflection-gate.md`, `editorial-reflection-gate.md` |
| Agent handoff lacks a qualified Context Capsule | `context-quality-contract.md` |
| Neither conversation nor pending proof/delivery establishes a concrete continuation | `next-outcome-selection.md` |
| Degraded context may justify restart, or handoff starts a conversation | `conversation-continuity-contract.md` |
| Maintain/test reporting behavior | `reporting-pressure-scenarios.md` plus exercised branches only |
| Maintain/test timestamps | `final-report-timestamp.md` |

Agent mode loads only agent-handoff for detail, including audit/risk; start,
closure reflections and continuity remain independent gates. Successful default
user mode needs no detail branch unless claiming closure.

## Modes And Header

Default `report=user`: outcome, current-run proof, material limits, then one
genuine operator action. Use the active language and precise machine labels;
omit routine tools, internal owners and lifecycle narration. Agent detail requires
explicit operator/orchestrator request, never caller identity or blockers.

Every final report, including agent mode, begins with one chantier header and
current Europe/Paris verdict; user reports start exactly:

```text
🧱 CHANTIER (<local|spec>) : <name>
🎯 VERDICT (HH:mm) : <verdict or status>
```

Use `🚧 CHANTIER` only when genuinely blocked; `(spec)` only with exactly one
owning spec, otherwise `(local)`. Resolve the current Europe/Paris clock
immediately before final reporting: display HH:mm, never reuse UTC or an earlier
time; machine ledgers retain UTC. No trailing/duplicate chantier header.

## Compact User Layout

For every user-facing report state, keep adjacent header/verdict lines, then
one blank line before the body. Each applicable labelled row keeps icon,
translated label, optional status and content on one line; exactly one blank
line separates rows. Prose labels take a colon (`✨ OBJECTIF :`,
`✨ RÉSULTAT :`, `🔨 PROGRESSION :`); status rows need none
(`🧪 PREUVES ✅`, `⚠️ LIMITES`, `🧠 CONTEXTE ✅`). Separate compact items
with ` · `. Omit irrelevant rows, never those mandatory for the active state.

Keep numbered choices contiguous: one blank line before, none between options,
then immediately `Réponds avec le numéro, ou précise une autre option.`
End there: no second verdict, timestamp or reminder. Agent/handoff/verbose/
full-report output instead uses `reporting-agent-handoff.md` operational layout.

User mode has no modified-files section, matrices, phase ledgers, bulk logs or
internal commands. Omit filenames, paths, counts and technical file links unless
the operator must open/edit/provide that artifact to proceed or requests detailed
evidence. Select only rows carrying current value for progress, partial, blocked
and audit results.

Use semantic icons consistently, at most one per labelled line except compact
proof/delivery. Never use 🏗️, 🛠️ or ⚙️ as chantier markers.
`📂` denotes dossier/scope, `🔨` implementation/repair, `📌` priority/decision/next action.
When routing helps, put
`🧭 Suite : <résultat ou décision à obtenir> — <raison courte>` below the verdict;
that line never names a skill, command, lifecycle phase, delegated agent or owner.

## Effort And Continuation

Format required evidence without new checks, research, docs or content solely
for reporting. One meaningful proof suffices; placeholders are not quotas.
Non-closure progress needs only outcome, proof, material limits and a genuine
next decision.

Every final user report needs `🧭 SUITE`: a missing action/proof or evidenced
continuation, never omitted, `none`, “no action required” or an empty menu.
Use the first sufficient evidence in this order: conversation outcome, pending
proof/delivery, active chantier, P0 -> P1 -> P2 -> P3 tracker, overdue audit,
grounded improvement. No broad reporting-only audit. Load detailed selection
only if conversation and pending delivery do not establish the next outcome.

Continue authorized safely agent-runnable work before final reporting, beyond
internal milestones. Selection grants no new/materially expanded chantier.
Keep the latest unresolved goal active until proven, explicitly changed/paused,
or blocked by operator-owned authority/decision or inaccessible proof. With
degraded context, stabilize and deliver before recommending restart; only the
operator starts it. Length, compaction or a separate outcome alone is insufficient.

## Persistence And Claim Safety

Prove local work, remote Git and deployment separately: commit is not push,
push is not deployment. Where ambiguity matters, show `📦 PERSISTANCE` with
evidenced Local / Git distant / Déployé states; omit it if `📦 LIVRAISON` already
clarifies delivery. Modified files never mean “tâche sans mutation”.

Report only checks actually run; expose failed, skipped and partial evidence.
Never expose secrets, cookies, tokens, private logs, personal data or sensitive
screenshots. Local repair proves no universal prevention: stronger claims need
an explicit invariant, matching scope and focused mechanical proof.
Count only directly dispatched successful agents; show
`Agents: <count> · <mode>` only when topology affects trust.
