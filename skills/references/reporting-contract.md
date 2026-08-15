---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "2.2.0"
project: ShipGlows
created: "2026-05-03"
updated: "2026-08-15"
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
depends_on:
  - artifact: "skills/references/final-report-timestamp.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/reporting-agent-handoff.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/reporting-blocked-and-audit.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "skills/references/reporting-pressure-scenarios.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "skills/references/documentation-reflection-gate.md"
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decisions 2026-05-03 through 2026-08-07 define concise human reports, explicit agent handoffs, chantier-first headers, safe choices, bounded recurrence claims, and compact topology receipts."
  - "Wave 13 retained the default user decision surface here and moved conditional handoff, blocked/audit, and maintenance scenarios to direct leaves."
  - "Operator decision 2026-08-13: unfinished report choices steer business direction and short interaction controls trigger guided follow-up."
  - "Operator clarification 2026-08-15: every closure report must expose its documentation reflection instead of leaving documentation updates silent."
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
- any report that claims a work item is closed, complete, done, resolved, or shipped: `$SHIPGLOWS_ROOT/skills/references/documentation-reflection-gate.md`.

Branches never chain. The default successful `report=user` needs no branch. In `report=user`, blocked/partial/audit loads the blocked/audit leaf. In `report=agent`, load only agent-handoff: it owns detailed risks and audit handoffs too. Reporting maintenance loads the pressure scenarios plus the one behavioral leaf exercised by the scenario. Otherwise load one branch maximum. The structured dependencies above validate that every leaf exists and is current; they do not make conditional leaves activation-eager.

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

After the header, keep only:

1. completed outcome;
2. compact proof/check summary;
3. limits that change trust or the next decision;
4. a real operator decision/action only when required.

For every closure report, include the documentation reflection as one compact visible line: `Documentation reflection: updated`, `not impacted — <concrete reason>`, or `needs review — <surface>`. A material `needs review` result forbids closure or shipping language. Non-closure progress reports omit this line unless the documentation status materially affects trust.

Do not include a modified-files section in `report=user`. Omit modified file names, paths, or counts. Do not dump checklists, matrices, phase ledgers, raw commands, bulk logs, or lifecycle internals. Durable artifacts and `report=agent` retain that evidence.

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

Combine successful current-run checks on one line when useful:

```text
✅ Tests 18/18 · 🧾 Métadonnées OK · 🔄 Sync 236/236
```

Include only evidence actually run. Do not disguise warnings, failures, skips, or proof gaps as success. Prefer `All checks passed ✅`, `✅ Checks passed: <short list>`, `Checks skipped: <reason>`, or `Checks failed: <check>` as applicable.

Use at most one semantic emoji per labelled line except the compact validation line:

- `🧱` for the normal chantier header;
- `🚧` only when the run is blocked;
- `📂` for a dossier or scope;
- `🔨` for active implementation or repair;
- `📌` for a priority, decision, or next action;
- `🎯` verdict, `🧭` route, `✅` passed/recommended, `⚠️` risk, `🚀` shipped, `📝` docs, `🧾` metadata, `🔄` sync.

Do not use `🏗️`, `🛠️`, or `⚙️` as chantier markers.

## Claim And Safety Boundary

Never expose secrets, cookies, tokens, private logs, personal data, or sensitive screenshots. Report only the cause/context tested and known recurrence conditions. A local repair is not a permanent or universal guarantee. Such a prevention claim requires an explicit invariant, scope exactly matching the claim, and focused mechanical proof; generic lint, build, or audit is insufficient.

If a result is blocked, partial, risky, security-sensitive, an audit, or unfinished, load the conditional blocked/audit branch before finalizing.
