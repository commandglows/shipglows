---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "2.14.0"
project: ShipGlows
created: "2026-05-03"
updated: "2026-08-21"
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
    artifact_version: "2.2.0"
    required_status: active
  - artifact: "skills/references/documentation-reflection-gate.md"
    artifact_version: "1.3.0"
    required_status: active
  - artifact: "skills/references/editorial-reflection-gate.md"
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decisions 2026-05-03 through 2026-08-07 define concise human reports, explicit agent handoffs, chantier-first headers, safe choices, bounded recurrence claims, and compact topology receipts."
  - "Wave 13 retained the default user decision surface here and moved conditional handoff, blocked/audit, and maintenance scenarios to direct leaves."
  - "Operator decision 2026-08-13: unfinished report choices steer business direction and short interaction controls trigger guided follow-up."
  - "Operator clarification 2026-08-15: every closure report must expose its documentation reflection instead of leaving documentation updates silent."
  - "Operator decision 2026-08-15: closure reports use a stable visual card whose proof and documentation evidence each stay on one compact line separated by middle dots."
  - "Operator decision 2026-08-15: approved substantive chantiers use a matching start card with objective, scope, expected proof, and planned documentation impact."
  - "Operator decision 2026-08-15: user reports omit file paths, file names, and technical file links unless the operator must act on the exact artifact or explicitly requests detail."
  - "Operator decision 2026-08-18: report cards summarize already-required work and must never create extra checks, research, documentation, or content merely to fill a block."
  - "Operator decision 2026-08-21: substantive code chantiers expose one compact implementation-guardrail receipt after pre-write classification."
  - "Operator decision 2026-08-16: every closure exposes a separate editorial reflection without creating ceremonial public content."
  - "Operator correction 2026-08-21: SUITE is mandatory business continuity and may never resolve to no action; it selects from unfinished conversation work, pending proof or delivery, active chantiers, tracker priority, overdue audits, then grounded improvement."
  - "Operator decision 2026-08-21: persistence reporting distinguishes local, remote backup, and deployment without adding a block when healthy delivery evidence is already clear."
  - "Operator decision 2026-08-16: completed chantiers may offer guided Approfondir and Réorienter follow-up without reopening delivery or authorizing mutation."
  - "Operator approval 2026-08-21: restart recommendations follow context quality rather than length, stabilize durable state first, and remain operator-started."
  - "Operator correction 2026-08-21: an independent outcome alone never triggers restart; user-facing language calls the restart prompt a handoff."
  - "Operator approval 2026-08-22: context health checks are lightweight at transitions and targeted only after a material degradation signal."
next_review: "2026-11-12"
next_step: none
---

# Reporting Contract

## Purpose And Direct Branches

Use this compact contract before every final ShipGlows report. Load `$SHIPGLOWS_ROOT/skills/references/final-report-timestamp.md` for Paris-time verdict rules.

Load direct branches only when their gate applies:

- explicit `report=agent`, `handoff`, `verbose`, or `full-report`: `$SHIPGLOWS_ROOT/skills/references/reporting-agent-handoff.md`;
- blocked, partial, risky, security-sensitive, audit, or unfinished user result: `$SHIPGLOWS_ROOT/skills/references/reporting-blocked-and-audit.md`;
- reporting-contract maintenance or behavioral review: `$SHIPGLOWS_ROOT/skills/references/reporting-pressure-scenarios.md`.
- any report that claims a work item is closed, complete, done, resolved, or shipped: load both `$SHIPGLOWS_ROOT/skills/references/documentation-reflection-gate.md` and `$SHIPGLOWS_ROOT/skills/references/editorial-reflection-gate.md`.

Branches never chain. Closure is the only dual-reflection case: documentation and editorial impact are mandatory and independent. The default successful `report=user` needs no branch. In `report=user`, blocked/partial/audit loads the blocked/audit leaf. In `report=agent`, load only agent-handoff: it owns detailed risks and audit handoffs too. Reporting maintenance loads the pressure scenarios plus the behavioral leaf exercised by the scenario. Otherwise load one branch maximum. The structured dependencies above validate that every leaf exists and is current; they do not make conditional leaves activation-eager.

## Report Modes

Default to `report=user`. It is a human decision surface, not a shortened agent log. Match the user's active language; keep stable commands, paths, and machine labels in English only when translation weakens traceability. State outcome first, then current-run proof, then only material limits or a genuine operator action. Do not narrate intermediate tools, lifecycle stages, routine orchestration, or internal owners.

Use `report=agent` only when explicitly requested by an orchestrator/operator or when a technical handoff genuinely needs files, commands, matrices, evidence, or unresolved gate state. Never infer caller identity from runtime state.

## User Mode

Start every user report with exactly:

```text
🧱 CHANTIER (<local|spec>) : <name>
🎯 VERDICT (HH:mm) : <verdict or status>
```

Use `🚧 CHANTIER` instead of `🧱 CHANTIER` only for a genuinely blocked verdict. Use `(spec)` only when exactly one spec owns the run; otherwise derive a short stable `(local)` name. Do not expose spec paths, trace metadata, or a trailing chantier block.

After approval and at the true start of a substantive chantier, render this card once. Do not use it while approval is pending or for a branch-free micro-action.

```text
✨ OBJECTIF
<one compact outcome promise>

📐 PÉRIMÈTRE
✅ <in scope> · ➖ <material out of scope>

🛡️ GARDE-FOUS
✅ <applicable mandatory implementation rules>

🧪 PREUVES ATTENDUES
✅ <proof 1> · <proof 2> · <proof 3>

📖 DOCUMENTATION PRÉVUE
✅ Impactée · <mapped documentation scope>
```

Use `🎯 VERDICT (HH:mm) : 🚀 Démarré` in the header. Translate labels and explanatory text into the user's active language while preserving the main icons. Keep the content beneath scope, expected proof, and planned documentation each on exactly one line; the guardrails line follows the same rule and uses ` · `. Objective, scope, expected proof, and planned documentation are always mandatory. `🛡️ GARDE-FOUS` is additionally mandatory for substantive authored or materially modified code and follows `implementation-excellence-preflight.md`; omit it for `IEP-MICRO-EDIT` and non-code chantiers. Add `🧭 APPROCHE` only when the strategy materially improves operator understanding.

The planned documentation line uses exactly one of: `✅ Impactée · <scope included in the chantier>`, `➖ Non impactée · <concrete reason>`, or `⚠️ À confirmer · <surface>`. It is a plan, not a closure claim; only the closure card may use `updated`, `not impacted`, or `needs review`.

## Reporting Effort Ceiling

A report card formats evidence and decisions already required by the chantier; it never expands the work merely to populate a block. Do not run an extra check or audit, perform new research, create documentation or content, or manufacture detail solely for reporting. Required implementation proof, documentation, editorial work, and safety gates remain required for the chantier itself.

One meaningful proof is enough when it supports the verdict; example placeholders such as `<proof 1> · <proof 2> · <proof 3>` illustrate formatting, not a quota. Keep prose content to one sentence per block and keep compact evidence blocks to one line. Prefer an honest short status or concrete `not impacted` reason over filler.

For another progress report, keep only:

1. completed outcome;
2. compact proof/check summary;
3. limits that change trust or the next decision;
4. a real operator decision/action only when required.

For every successful closure report, render this stable card after the header. Keep the icon and translated section label on their own line. Keep the content beneath `🧪 PREUVES` on exactly one line and separate proof items with ` · `. Keep the content beneath `📖 DOCUMENTATION` on exactly one line and the content beneath `✏️ ÉDITORIAL` on exactly one line; separate each status, scope, or reason with ` · `.

```text
✨ RÉSULTAT
<one compact outcome paragraph>

🧪 PREUVES
✅ <proof 1> · <proof 2> · <proof 3>

📖 DOCUMENTATION
✅ updated · <aligned documentation scope>

✏️ ÉDITORIAL
➖ not impacted · <concrete reason>

📦 LIVRAISON
✅ Commit local : `<sha>` · ➖ Push : non effectué
```

Translate the five labels and explanatory text into the user's active language while preserving the main icons, the ` · ` separator, stable status values, hashes, and machine labels. `✨ RÉSULTAT`, `🧪 PREUVES`, `📖 DOCUMENTATION`, `✏️ ÉDITORIAL`, and `📦 LIVRAISON` are mandatory for closure; `⚠️ LIMITES` is conditional; `🧭 SUITE` is mandatory. Delivery remains truthful when Git is irrelevant, for example `➖ Aucun commit ni push · tâche sans mutation`. Never use that form for modified files, including documentation.

## Mandatory Next Block

Every final user report contains a `🧭 SUITE` block. It names one concrete evidence-backed next outcome, missing action or proof, or operator decision and is never `none`, “no action required,” an empty ceremonial menu, or a semantic equivalent. Before writing it, load and apply `skills/references/next-outcome-selection.md`: current conversation work and pending delivery beat active chantiers; active chantiers beat `P0 -> P1 -> P2 -> P3` tracker work; tracker work beats an overdue audit; only then select a grounded business improvement. Keep the result useful and concise, never omit the block, and never invent urgency or authority. When numbered choices follow, the block introduces the decision they resolve.

If an in-scope continuation is already authorized and safely agent-runnable, continue it before final reporting. When selection reaches a new or materially expanded chantier, state the next outcome and preserve its normal approval boundary; selection itself never authorizes mutation.

When useful context has become insufficiently reliable, load `conversation-continuity-contract.md`. Stabilize and deliver the current work before recommending restart, then state that only the operator can open the new conversation and provide the required handoff. Length, compaction, or an independent outcome alone never justifies this recommendation.

## Persistence Evidence

When interruption recovery, local-only work, remote ambiguity, or deployment distinction materially affects trust, add this compact block:

```text
📦 PERSISTANCE
✅ Local · ✅ Git distant · ➖ Déployé
```

Report only evidence-backed states. A commit may still be local; a successful push supports `Git distant` but never `Déployé`; deployed status requires matching provider evidence. Omit this additional block on the healthy silent path when `📦 LIVRAISON` already communicates the same truth.

The documentation line uses exactly one of: `✅ updated · <scope>`, `➖ not impacted · <concrete reason>`, or `⚠️ needs review · <surface>`. A material `needs review` result forbids closure or shipping language. Non-closure progress reports omit the documentation block unless its status materially affects trust.

The editorial line independently uses the same three status values. A material editorial `needs review` result forbids closure or shipping language. `No declared public surface` is a valid concrete `not impacted` reason; never create filler content to avoid that result.

After the mandatory `🧭 SUITE`, a completed chantier may additionally offer this compact continuation choice block only when the delivered result has a useful decision surface:

```text
1. 🔎 Approfondir — examiner davantage les opportunités, risques, hypothèses ou enseignements du résultat.
2. 🧭 Réorienter — explorer des directions alternatives concrètes à partir du résultat livré.
```

Selecting `Approfondir` or `Réorienter` starts guided follow-up, does not reopen the completed chantier, and never grants mutation approval. Omit the block when no useful continuation exists; do not append a ceremonial menu to every closure.

Do not include a modified-files section in `report=user`. Omit file names, paths, counts, and clickable technical file links. Show an exact artifact only when the operator must open, edit, or provide it to proceed, or explicitly requests detailed evidence. Do not dump checklists, matrices, phase ledgers, raw commands, bulk logs, or lifecycle internals. Durable artifacts and `report=agent` retain that evidence.

When executable work used agents, expose only `Agents: <count> · <mode>` if topology affects trust. Count directly dispatched successful agents only; routine mission detail stays internal.

## Objective Continuity

Keep the latest unresolved operator goal active until its promised outcome and matching proof are complete, a material operator-only decision/approval/credential/manual fact blocks it, or the operator explicitly replaces, narrows, pauses, or abandons it.

Do not return control merely because a spec, governance, readiness, implementation, verification, closure, or ship milestone completed while the next action is safely agent-runnable. Continue through owned gates. A `Next step` line is allowed only for a concrete operator action required now.

When routing must be visible, use plain language directly below the verdict:

```text
🧭 Suite : <résultat ou décision à obtenir> — <raison courte>
```

Never name a skill, command, lifecycle phase, delegated agent, or internal owner in that user-facing line.

## Compact Validation And Status Vocabulary

Combine successful current-run checks on one line. Closure cards place this compact line beneath `🧪 PREUVES`:

```text
✅ Tests 18/18 · 🧾 Métadonnées OK · 🔄 Sync 236/236
```

Include only evidence actually run. Do not disguise warnings, failures, skips, or proof gaps as success. Prefer `All checks passed ✅`, `✅ Checks passed: <short list>`, `Checks skipped: <reason>`, or `Checks failed: <check>` as applicable.

Use at most one semantic emoji per labelled line except the compact proof and delivery lines:

- `🧱` for the normal chantier header;
- `🚧` only when the run is blocked;
- `📂` for a dossier or scope;
- `🔨` for active implementation or repair;
- `📌` for a priority, decision, or next action;
- `🎯` verdict, `✨` objective/result, `📐` scope, `🧪` proof, `📖` documentation, `✏️` editorial, `📦` delivery, `🧭` route/approach, `✅` passed/recommended, `⚠️` risk, `➖` neutral/not applicable, `🚀` started/shipped, `🧾` metadata, `🔄` sync.

Do not use `🏗️`, `🛠️`, or `⚙️` as chantier markers.

## Claim And Safety Boundary

Never expose secrets, cookies, tokens, private logs, personal data, or sensitive screenshots. Report only the cause/context tested and known recurrence conditions. A local repair is not a permanent or universal guarantee. Such a prevention claim requires an explicit invariant, scope exactly matching the claim, and focused mechanical proof; generic lint, build, or audit is insufficient.

If a result is blocked, partial, risky, security-sensitive, an audit, or unfinished, load the conditional blocked/audit branch before finalizing.
