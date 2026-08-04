---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "0.9.0"
project: ShipGlows
created: "2026-04-27"
updated: "2026-08-03"
status: draft
source_skill: 102-sg-start
scope: chantier-tracking
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - shipglows_data/workflow/specs/
  - skills/*/SKILL.md
  - skills/000-shipglows/SKILL.md
  - skills/004-sg-deploy/SKILL.md
  - skills/002-sg-maintain/SKILL.md
  - skills/006-sg-design/SKILL.md
  - skills/references/reporting-contract.md
  - skills/references/final-report-timestamp.md
  - skills/references/master-workflow-lifecycle.md
depends_on:
  - artifact: "shipglows_data/workflow/specs/specs-as-chantier-registry.md"
    artifact_version: "1.0.0"
    required_status: "ready"
supersedes: []
evidence:
  - "Spec specs-as-chantier-registry.md defines shipglows_data/workflow/specs/ as the global chantier registry."
  - "shipglows added as the primary helper router; selected owner skills own durable state and chantier tracing."
  - "004-sg-deploy added as a lifecycle release orchestrator."
  - "002-sg-maintain promoted from recurring maintenance source-de-chantier to lifecycle master skill."
  - "Compact user-facing reporting contract added with explicit agent handoff mode."
  - "Master workflow lifecycle reference added: bug work items use shipglows_data/workflow/bugs/*.md as source of truth; shipglows_data/workflow/BUGS.md is optional/generated/triage view."
  - "Final report timestamp moved into a shared reporting brick loaded through reporting-contract.md."
  - "006-sg-design added as an obligatoire lifecycle master skill."
  - "003-sg-bug clarified as bug lifecycle execution through owner skills and bounded subagents."
  - "900-shipglows-core consolidated as the lifecycle core audit and packaging owner."
  - "User decision 2026-07-16: replace the trailing user-mode chantier block with a local/spec chantier name header before the verdict."
  - "User decision 2026-07-16: the verdict header displays Paris time only, without the date."
  - "User decision 2026-07-16: normal chantier headers use 🧱 and 🚧 is reserved for genuinely blocked runs."
  - "Operator correction 2026-07-18: chantier-potential reporting must not make operators launch or interpret internal workflow commands."
  - "2026-08-03 pilotage consolidation moved tasks, backlog, priorities, review, and Codex-session management under 011-sg-pilotage while preserving the pilotage process role."
next_review: "2026-05-27"
next_step: "/103-sg-verify Specs as chantier registry"
---

# Chantier Tracking Doctrine

`shipglows_data/workflow/specs/` is the global registry for spec-first chantiers. Do not create a separate registry in `TASKS.md`, `AUDIT_LOG.md`, `PROJECTS.md` (legacy/compat only), or root `specs/`.

## Two-Axis Classification

Chantier tracking has two separate axes. Do not collapse them into one label.

Trace category answers: may this skill write a run trace into an existing chantier spec?

- `obligatoire`: lifecycle spec-first skills. When a unique chantier spec is identified, read the spec, append or update `Skill Run History`, update `Current Chantier Flow`, and open the user report with the `(spec)` chantier header from `skills/references/reporting-contract.md`.
- `conditionnel`: cross-cutting skills. Trace only when the run is attached to one unique chantier spec. If no unique spec is available, do not write to any spec and use a `(local)` chantier header. Final output still follows `skills/references/reporting-contract.md`.
- `non-applicable`: helper/session/discovery skills. Do not write to specs and use a `(local)` chantier header for the current goal. Non-applicable for spec trace does not forbid non-spec durable artifacts when a skill contract allows them (for example `700-sg-explore` and `exploration_report`).

Process role answers: can this skill originate, support, steer, or merely inspect a chantier?

- `lifecycle`: creates, readies, executes, verifies, closes, or ships a unique chantier.
- `source-de-chantier`: may reveal work that deserves a new spec when no unique chantier exists.
- `support-de-chantier`: helps execute or document a chantier but should not normally originate one.
- `pilotage`: manages priorities, backlog, tasks, review, or continuation; can route to `100-sg-spec` on explicit user intent, but does not turn every planning note into a chantier.
- `helper`: read-only or session helper; does not propose a chantier unless the user explicitly asks to formalize one.

`source-de-chantier` is not a trace category. A skill can be `conditionnel` for spec writes and `source-de-chantier` for intake.

## Chantier Potential Threshold

A source skill must evaluate the standard `seuil` for chantier potential before its final report when it finds future work outside a single direct fix.

Use `Chantier potentiel: oui` when at least one of these is true:

- P0/P1 severity, production incident, security/data risk, auth/session breakage, deployment breakage, or critical dependency exposure.
- Multiple files (`plusieurs fichiers`), projects, domains, teams, or workflow phases are affected.
- A product, technical, architecture, migration, pricing, permission, data-retention, or tenant-boundary decision is required.
- The work needs staged execution, rollback/retry planning, validation by another skill, or user/operator confirmation.
- The finding cannot be completed safely as an immediate local fix in the current run.

Use `Chantier potentiel: non` when the finding is a narrow local fix, the current chantier already owns the work, the report is informational only, or the evidence is too weak for a spec. Still name the reason.

Use `Chantier potentiel: incertain` when the evidence is incomplete or the severity/scope is unclear. Name the missing proof and route to exploration, retest, or explicit user selection.

Never open a chantier for every micro-finding, never attach to an ambiguous spec, and never create a new spec directly from a source skill. The next durable step is `/100-sg-spec ...`.

## Chantier Potentiel Block

Source skills should add this block after their findings when its decision detail is useful:

```text
## Chantier potentiel

Chantier potentiel: oui | non | incertain
Titre propose: <short chantier title or None>
Raison: <why this does or does not cross the threshold>
Severite: P0 | P1 | P2 | P3 | unknown
Scope: <files/projects/domains/workflows affected>
Evidence:
- <finding, command, file, URL, or observed behavior>
Formalisation recommandée: oui | non - <short reason>
Choix proposes: <two or three plain-language outcomes when the chantier remains open>
```

The report still opens with the shared chantier header. If the source skill is already attached to one unique chantier and the findings remain inside that chantier, use `Chantier potentiel: non` and point back to the current lifecycle next step.

## Role Matrix

| Skill group | Trace category | Process role | Source threshold |
|-------------|----------------|--------------|------------------|
| `100-sg-spec`, `101-sg-ready`, `001-sg-build`, `002-sg-maintain`, `006-sg-design`, `004-sg-deploy`, `102-sg-start`, `103-sg-verify`, `104-sg-end`, `005-sg-ship`, `900-shipglows-core` | `obligatoire` | `lifecycle` | Not a source; continue or create the owned chantier through the lifecycle gates. |
| `400-sg-audit`, `010-sg-technical` | `conditionnel` | `source-de-chantier` | Major audit/technical findings, P0/P1, cross-domain P2 clusters, breaking migration risk, or fixes needing a spec. |
| `109-sg-auth-debug`, `405-sg-prod`, `105-sg-check`, `107-sg-test`, `106-sg-fix`, `003-sg-bug` | `conditionnel` | `source-de-chantier` | Incidents, failing flows, bug files, bug lifecycle execution, or validation failures beyond a direct fix. |
| `009-sg-marketing`, `205-sg-veille`, `203-sg-research` | `conditionnel` | `source-de-chantier` | Strategic or research output that requires a product, content, architecture, or implementation decision. |
| `300-sg-docs`, `201-sg-enrich`, `200-sg-redact`, `306-sg-scaffold`, `304-sg-changelog`, `305-sg-init` | `conditionnel` | `support-de-chantier` | Route to a source or `/100-sg-spec` only when the user explicitly asks to formalize follow-up work. |
| `011-sg-pilotage`, `706-continue` | `conditionnel` | `pilotage` | Do not create a chantier from every note; route only when the user or evidence requires a durable spec. |
| `000-shipglows`, `301-sg-context`, `704-sg-model`, `302-sg-help`, `308-sg-status`, `303-sg-resume`, `700-sg-explore`, `707-name` | `non-applicable` | `helper` | Not a source; can recommend or directly hand off to the lifecycle next step when useful. `000-shipglows` routes only; selected owner skills own durable state and chantier tracing. `700-sg-explore` may write `exploration_report` artifacts but still must not write chantier spec history. |

## Spec Write Rules

- Before writing, identify exactly one `shipglows_data/workflow/specs/*.md` file with ShipGlows frontmatter. Root `specs/*.md` files are migration sources only and should be routed through `/300-sg-docs migrate-layout`.
- If matching is ambiguous, stop and ask for an explicit spec instead of guessing.
- Preserve all existing metadata and contract sections.
- Add `Skill Run History` if it is missing, using this table:

```markdown
## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
```

- Use the best available model label. If the runtime does not expose it, use `unknown` or the operator-provided name.
- Never invent past runs. Only record the current run or facts already present in the spec/report.

## Final Report Header

Load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md` before producing final output. That contract also loads the shared final-report timestamp brick. Use the two-line opening in `report=user`; add fuller metadata only in `report=agent`, blocked runs, or handoffs that need trace state.

Local user-mode opening:

```text
🧱 CHANTIER (local) : <short work name>
🎯 VERDICT (HH:mm) : <verdict>
```

Spec-owned user-mode opening:

```text
🧱 CHANTIER (spec) : <spec title>
🎯 VERDICT (HH:mm) : <verdict>
```

If the run is genuinely blocked, use `🚧 CHANTIER` in place of `🧱 CHANTIER`.
An open, partial, or in-progress chantier keeps `🧱` unless the verdict itself
is blocked.

Use the spec title rather than its path. If no unique spec owns the run, use
`local` and name the current bounded goal; do not surface internal `non trace`
or `non applicable` states in `report=user`.

Detailed agent-mode metadata may follow the report body when needed:

```text
## Chantier metadata

Skill courante: <skill>
Chantier: <spec path | non applicable | non trace>
Trace spec: ecrite | non ecrite | non applicable
Flux:
- 100-sg-spec: <status>
- 101-sg-ready: <status>
- 102-sg-start: <status>
- 103-sg-verify: <status>
- 104-sg-end: <status>
- 005-sg-ship: <status>

Reste a faire:
- <item or None>

Prochaine etape:
- <command or explicit none>
```
