---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.8.0"
project: ShipGlows
created: "2026-05-05"
updated: "2026-07-28"
status: active
source_skill: manual
scope: final-report-timestamp
owner: Diane
confidence: high
risk_level: low
security_impact: none
docs_impact: yes
linked_systems:
  - skills/references/reporting-contract.md
  - skills/references/chantier-tracking.md
  - skills/*/SKILL.md
  - templates/*.md
depends_on: []
supersedes: []
evidence:
  - "Operator decision 2026-09-03: the two opening lines remain adjacent, followed by one blank line before compact labelled report rows."
  - "User request 2026-05-05: final reports need a visible Paris-time verdict timestamp so stale verdicts after crash or resume are not mistaken for current state."
  - "User decision 2026-07-15: verdicts appear first as a compact timestamped heading so the operator can read the response and any decision options without a trailing status block."
  - "User decision 2026-07-16: the chantier local/spec name is the first line and the timestamped verdict follows immediately below it."
  - "User decision 2026-07-16: show only Europe/Paris time (`HH:mm`) in the verdict header and omit the calendar date."
  - "User decision 2026-07-16: use 🧱 for normal chantier headers and reserve 🚧 for a genuinely blocked verdict."
  - "Operator correction 2026-07-18: user-facing route context describes the outcome or decision, never an internal owner, skill, command, or lifecycle stage."
  - "Operator correction 2026-07-28: a report accidentally displayed UTC despite the Paris-time contract; add an execution-time safeguard at the shared timestamp source."
next_review: "2026-06-05"
next_step: "/103-sg-verify final report timestamp contract"
---

# Final Report Opening Headers

Every ShipGlows final report places a concise, visible verdict in Europe/Paris local time immediately after the chantier header. The verdict remains an opening heading, not a trailing footer.

## Required Opening

Use this two-line opening for every final report:

```text
🧱 CHANTIER (<local|spec>) : <name>
🎯 VERDICT (HH:mm) : <verdict or status>
```

Use the literal `VERDICT` label prefixed by `🎯` for user-facing reports, including reports that would otherwise use a named verdict label. Named internal status fields may remain in agent-mode artifacts.

For a genuinely blocked verdict, replace the first marker only:

```text
🚧 CHANTIER (<local|spec>) : <name>
🎯 VERDICT (HH:mm) : bloqué
```

## Rules

- Use `Europe/Paris` local time, not UTC, for the visible report timestamp.
- Immediately before writing a final report, resolve the current clock in the `Europe/Paris` timezone (for example, `TZ=Europe/Paris date +%H:%M`); never reuse a UTC clock reading or an earlier intermediate timestamp.
- The displayed time is when the verdict or final status is pronounced, not when the task started.
- Display only `HH:mm`; do not include the calendar date in the verdict header.
- Keep UTC timestamps for internal ledgers, specs, run histories, and machine-readable artifacts that already require UTC.
- Put exactly one chantier header before the verdict; follow `reporting-contract.md` for local/spec selection and naming.
- Keep the chantier and verdict lines adjacent, then leave exactly one blank line before the first compact labelled report row.
- Keep `🧱` for normal, successful, partial, or in-progress runs; use `🚧` only when the verdict is blocked.
- Put the substantive response immediately below the verdict: result, proof, limits, and any decision question.
- When route context helps the operator understand the next action, add `🧭 Suite : <outcome or decision> — <short reason>` directly below the verdict. Never name an internal owner, skill, command, lifecycle stage, or delegated agent there.
- Do not append a second verdict, timestamp, reminder, or commentary after the response. When a numbered decision is required, the final visible content must be the options followed by `Réponds avec le numéro, ou précise une autre option.`
- If a skill has no natural verdict, use a concise status such as `rapport terminé` or `non applicable`.
