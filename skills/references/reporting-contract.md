---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.10.0"
project: ShipGlows
created: "2026-05-03"
updated: "2026-07-18"
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
  - specs/
depends_on:
  - artifact: "specs/skill-reporting-modes-and-compact-reports.md"
    artifact_version: "1.1.0"
    required_status: ready
  - artifact: "skills/references/final-report-timestamp.md"
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "User decision 2026-05-03: concise user reports by default, detailed agent reports by explicit mode."
  - "User decision 2026-05-04: user reports should organize ship status as outcome, evidence, then limits, match the user's active language, and allow a few sober status emojis."
  - "User decision 2026-05-05: final reports need a visible Paris-time verdict timestamp as a shared reporting brick, not duplicated per skill."
  - "User decision 2026-06-09: human-launched skills may keep technical evidence internally or in report=agent, but their default report must stay short, readable, and useful to a non-developer operator."
  - "User decision 2026-06-10: routine subagent orchestration should not be narrated to the user; results matter more than process."
  - "User decision 2026-07-15: the timestamped verdict is the opening line; the response and any decision options follow, with no trailing verdict footer."
  - "User decision 2026-07-15: use a small semantic emoji vocabulary for verdicts, routes, and decisions so reports scan quickly without visual noise."
  - "User decision 2026-07-16: default skill reports must omit modified-file sections, file names, paths, and counts."
  - "User decision 2026-07-16: every skill report opens with a one-line local/spec chantier name immediately before the timestamped verdict; user reports no longer end with a chantier block."
  - "User decision 2026-07-16: the visible verdict marker contains Paris time only (`HH:mm`), without the calendar date."
  - "User decision 2026-07-16: successful validation evidence should be compacted into one emoji-labelled line with middle-dot separators."
  - "User decision 2026-07-16: use 🧱 for a normal chantier, reserve 🚧 for a blocked run, and use 📂, 🔨, and 📌 only for scope, active work, and priority or decision context."
  - "Operator correction 2026-07-18: every final report that returns control while a chantier remains unfinished must offer plain-language choices and hide internal skills, commands, stages, owners, and agent topology."
next_review: "2026-06-04"
next_step: "/103-sg-verify shipglows-skill-reporting-and-proof-hardening"
---

# Reporting Contract

## Purpose

This reference defines the default final-report shape for ShipGlows skills.

The goal is to reduce user-facing noise without weakening traceability. Successful runs should be short. Failed, blocked, partial, or security-sensitive runs should include enough detail to act safely.

Before applying this contract, load `$SHIPGLOWS_ROOT/skills/references/final-report-timestamp.md`. Its verdict-header rule is part of this reporting contract and applies to both `report=user` and `report=agent`.

## Report Modes

Default mode is `report=user`.

Use `report=user` when:

- the skill is launched directly by the operator
- no explicit report mode is provided
- the run succeeds, partially succeeds, or blocks and the user only needs outcome, proof summary, material limits, and a real next step

Use `report=agent` when:

- an orchestrator needs a handoff report for another agent
- the user asks for `handoff`, `verbose`, `full-report`, or `agent report`
- the next step depends on detailed file lists, validation matrices, evidence, or unresolved gate state

Do not infer caller identity from runtime state. If a master skill wants a detailed downstream report, it must pass `report=agent` or an equivalent explicit handoff flag.

Human-launched user mode is not a simplified agent report. It is a decision surface for a human operator. It must translate internal gates into the user's active language and expose only the information needed to trust the outcome or choose the next action.

User-facing reports should default to result-first phrasing. Avoid narrating intermediate actions, tool sequences, or step-by-step execution unless the user explicitly asked for process detail or the report is blocked/partial and the action path matters.

## User Mode

Keep the final report compact and outcome-first.

Match the user's active language for user-facing labels and explanatory
sentences. Stable commands, file paths, status values, and machine-readable
contract labels may stay in English when translation would weaken traceability.

Default user-mode reports must fit this shape unless the skill has a stricter local format:

1. `🧱 CHANTIER (<local|spec>) : <name>` as the first visible line
2. `🎯 VERDICT (HH:mm) : <status>` immediately below it
3. outcome and proof summary or check summary
4. limits only when they affect trust, risk, or next action
5. a numbered plain-language choice block whenever the chantier remains unfinished and control returns to the operator

## Active Work Continuation Rule

Do not end a user-facing report with a pending internal stage, a command, or a
technical “next step” when the operator asked ShipGlows to carry out the work
and the next action is still agent-runnable. Continue the active owner workflow
through its safe gates instead.

For a lifecycle request such as “create my app”, `spec created`, `governance
initialized`, `readiness pending`, or `implementation not started` is progress,
not a user-facing stopping point. The final answer must either:

- report the completed user outcome; or
- ask one plain-language, numbered decision that only the operator can make;
- explain a real external/safety block and exactly what the operator must
  provide or approve.

Never make the operator infer that they must re-invoke the next lifecycle
skill, read an internal spec, or decide whether the agent should continue. A
“Next step” line is permitted only when it names a concrete operator action
that is genuinely required now; otherwise omit it and continue autonomously.

Pressure scenario `SSRP-006 active lifecycle`: given an operator asks to build
or change a product, when a spec, governance, readiness, implementation,
verification, closure, or ship stage remains agent-runnable, then the owner
skill proceeds through that stage rather than reporting it as a task for the
operator.

## Objective Continuity Rule

Treat the operator's latest unresolved goal as the active conversation
objective. Every response, owner handoff, progress update, and final report
must either advance that objective, remove a real blocker, or ask the one
operator-owned decision that unlocks it. Do not turn intermediate milestones
into new implicit objectives for the operator.

Keep the objective active until one of these conditions is true:

- the promised outcome is genuinely complete and the matching proof has run;
- a material decision, approval, credential, or manual-only fact is required
  from the operator;
- the operator explicitly replaces, narrows, pauses, or abandons the goal.

When the operator changes subject to critique the execution itself, treat that
as a bounded system-improvement objective. Repair it, prove the repair, then
resume the prior product objective unless the operator explicitly abandons it.

Pressure scenario `SSRP-007 directed conversation`: given an operator says
“create my application”, when a lifecycle milestone completes, then the agent
uses that milestone only to choose and execute the next owner action; it does
not make the operator restart, interpret, or steer the workflow.

When routing is relevant to the operator, add one concise line directly below the verdict in plain language:

```text
🧭 Suite : <résultat ou décision à obtenir> — <raison courte>
```

Never name a skill, command, lifecycle phase, delegated agent, or internal owner
in that user-facing line. Those details belong to `report=agent`.

## Unfinished Chantier Choice

When a user-facing final report leaves a chantier unfinished, end the message
with a numbered, plain-language choice block. This gives the operator a visible
way to steer the objective without making them operate ShipGlows internals.

Use the smallest truthful set of two or three options. When no material
decision is missing, offer this default shape:

```text
1. ✅ Continuer comme prévu — le travail continue avec la priorité actuelle.
2. 🧭 Réorienter — indique ce que tu veux changer ou privilégier.
3. ⏸ Mettre en pause — le chantier reste conservé pour plus tard.

Réponds avec le numéro ou indique une autre direction.
```

Rules:

- This applies to every final user-facing message for an open, partial, or
  otherwise unfinished chantier, including a status update that returns control
  to the operator. Routine in-flight commentary may remain informational while
  agents continue work.
- If a material business, product, safety, scope, release, or risk decision is
  actually required, replace the generic choices with that specific numbered
  decision and its recommended option.
- The choices must describe outcomes, priority, scope, or pause/continue
  consequences. They must never expose skill names, slash commands, lifecycle
  labels, agent topology, or ask the operator to launch internal work.
- A completed chantier does not receive this block. A blocked unfinished
  chantier receives specific safe recovery choices instead of generic continue.

Do not include full checklists, validation matrices, phase ledgers, file inventories, raw command output, or lifecycle internals in successful user-mode reports. Keep that detail in the durable artifact or use `report=agent`.

Do not include a modified-files section in `report=user`. Omit modified file
names, paths, or counts even when the list would be short. Summarize the
product, documentation, or technical surface changed only when that context
helps the operator understand the outcome. Detailed file evidence belongs in
the durable artifact or in an explicitly requested `report=agent` handoff.

Do not report routine subagent orchestration in user mode. Mention it only when availability, degraded execution, model override status, cost/risk, or topology changes trust or the user's next decision.

When a task is complete, prefer the end state over the story of how it was completed. One short sentence about what changed is usually enough.

Use a small semantic emoji vocabulary when it improves scanning, not as
decoration. Use at most one emoji per labelled line, except for the compact
validation line defined below, and do not add emoji to ordinary prose.

The chantier and work-context vocabulary is fixed:

- `🧱` for the normal chantier header
- `🚧` only when the run is blocked
- `📂` for a dossier or scope
- `🔨` for active implementation or repair
- `📌` for a priority, decision, or next action

Do not use `🏗️`, `🛠️`, or `⚙️` as chantier markers. Other stable status markers
remain available: `🎯` for the verdict, `🧭` for route/owner, `✅` for passed or
recommended, `⚠️` for limits/risk, `🚀` for pushed/shipped, `📝` for
docs/bookkeeping, `🧾` for metadata, and `🔄` for synchronization. For decision
options, place one meaningful emoji after the option number when it helps.
Keep agent/handoff reports mostly plain except for material status markers.

### Compact Validation Line

When several successful checks support the verdict, combine them into one
short line with middle-dot separators:

```text
✅ Tests 18/18 · 🧾 Métadonnées OK · 🔄 Sync 236/236
```

Include only segments backed by the current run. Prefer `<passed>/<run>` or
`<ok>/<checked>` when totals are known; otherwise use a short `OK`. Keep labels
in the operator's active language, prevent wrapping when practical, and omit
the final period. Do not turn warnings, failures, skipped checks, or material
proof gaps into a success segment; report those separately with `⚠️`.

For ship reports, organize user-mode text as:

1. outcome: commit, branch, push, and repo state
2. evidence: checks, build proof, browser/prod/manual proof, or docs evidence
3. limits: partial validation, missing bug gate, unknown development mode, or
   remaining action

For successful ship/close flows, combine push, repo state, checks, and bookkeeping into one line when possible:

```text
🚀 Pushed to origin/main. Repo clean. ✅ Checks passed. 📝 Tasks/Changelog updated.
```

Use these check summaries:

- `All checks passed ✅` when all attempted or required checks passed.
- `✅ Checks passed: <short list>` when naming the checks is clearer than a generic success line.
- `All checks passed except: <check>, <check>` only when the run legitimately continues despite accepted or non-blocking gaps.
- `Checks skipped: <reason>` when checks were intentionally skipped.
- `Checks failed: <check>` when the run is blocked or not shipped.

Only include sections that change the user's next decision:

- result
- checks summary
- bug/security/risk gate when non-empty or relevant
- documentation/public-content gap when relevant
- next step only when it is real
- detailed chantier state only in `report=agent` when it affects the handoff

Translate internal gate names into their user consequence when possible. Prefer
`⚠️ Limites: pas de shipglows_data/workflow/BUGS.md, donc risque bug non evalue` over a bare
`Bug risk gate: not assessed` when the active user language is French.

Omit empty or redundant lines such as `Reste a faire: none`, `Prochaine etape: none`, `Trace spec: ecrite`, and `Verdict <skill>` when the heading or status already says the same thing.

If a skill is blocked, partial, risky, or security-sensitive, user mode may be longer, but it still must not dump internal machinery. Say what blocked, what evidence proves it, what action is safest, and whether the work can continue or ship.

## Agent Mode

Agent mode may include:

- files changed
- commands run
- validation matrices
- evidence references
- detailed phase gates
- documentation/editorial plans
- unresolved risks with owner and next command
- full chantier trace metadata

Agent mode must still avoid dumping raw secrets, cookies, tokens, private logs, or unnecessary bulk output.

Agent mode is the correct place for detailed readiness checklists, validation matrices, file lists, evidence tables, route rationale, and handoff notes. Master skills that need such detail from downstream skills must request `report=agent`; downstream skills must not guess that detail is wanted.

## Chantier Header

Every user-mode report starts with exactly one chantier line:

```text
🧱 CHANTIER (local) : <short work name>
```

Use `(spec)` instead of `(local)` when exactly one chantier spec owns the run:

```text
🧱 CHANTIER (spec) : <spec title>
```

When the verdict is genuinely blocked, replace only the chantier marker:

```text
🚧 CHANTIER (<local|spec>) : <name>
🎯 VERDICT (HH:mm) : bloqué
```

Do not use `🚧` for partial progress, routine warnings, work in progress, or a
chantier that merely remains open.

For `(spec)`, use the human-readable spec title; fall back to the filename stem
only when no title is available. For `(local)`, derive a short stable name from
the current operator goal or bounded task. Do not expose `non trace`, `non
applicable`, a spec path, lifecycle flow, or trace metadata in the user-mode
header. Do not repeat chantier information in a trailing user-mode block.

Fuller chantier metadata remains available in `report=agent` when another
agent needs trace state.

## Audit Reports

Audit skills still report findings first.

In `report=user`, use:

```text
## Audit: <scope>

Result: <clear / issues found / blocked>
Top findings:
- <severity> <area> - <issue>

Proof gaps: <short list or none>
Chantier potentiel: <oui/non/incertain> - <reason>
[If the chantier remains open, finish with the shared numbered plain-language choices.]
```

For large global audits, keep the project/domain matrix only when it helps compare projects. Prefer top findings and systemic patterns over exhaustive per-file detail in the user-facing closeout.

In `report=agent`, include the detailed domain checklist output, scoring matrix, command evidence, assumptions, confidence limits, and handoff notes.

## Failure Rule

Concise does not mean vague. If a run is blocked, partial, or risky, include:

- the blocking gate
- the concrete evidence
- the safest next action
- whether the current work can or cannot ship

## Pressure Scenarios

Use these scenarios when changing reporting behavior or reviewing a skill report:

- `SSRP-001 human success`: a directly launched skill succeeds. The user report is concise, in the user's active language, and includes outcome, proof summary, and no checklist dump.
- `SSRP-002 human not-ready`: `101-sg-ready` finds blockers. The user report lists only blockers that require action, explains them plainly, and ends with one numbered plain-language recovery decision without naming a command or internal owner.
- `SSRP-003 human blocked safety`: a safety or security gate blocks work. The user report names the gate, summarizes redacted evidence, gives the safest next action, and does not expose secrets or bulk logs.
- `SSRP-004 agent handoff`: another skill needs detailed evidence. The caller passes `report=agent`, and the report may include checklists, matrices, files, commands, and lifecycle internals.
- `SSRP-005 proof limit`: a completion claim lacks full proof. The user report stays short but names the missing proof or explicit exception before claiming completion.
- `SSRP-008 no modified-file inventory`: a skill changes one or more files and succeeds in `report=user`. The report summarizes the outcome and proof without a modified-files heading, file names, paths, or counts; an explicitly requested `report=agent` may retain that evidence for a technical handoff.
- `SSRP-009 chantier opening`: a local task and a spec-owned task each produce a user report. The local report opens with `🧱 CHANTIER (local) : <short work name>` and the spec-owned report opens with `🧱 CHANTIER (spec) : <spec title>`; both place the verdict immediately below and omit any trailing chantier block.
- `SSRP-010 compact validation line`: tests, metadata lint, and runtime synchronization all pass. The user report emits `✅ Tests 18/18 · 🧾 Métadonnées OK · 🔄 Sync 236/236` on one line, omits unavailable segments, and reports any warning or failure separately instead of disguising it as success.
- `SSRP-011 chantier emoji semantics`: a normal run opens with `🧱 CHANTIER`; a genuinely blocked run opens with `🚧 CHANTIER`; `📂`, `🔨`, and `📌` appear only for dossier/scope, active implementation/repair, and priority/decision/next-action context respectively.
- `SSRP-012 unfinished chantier choice`: a user-facing final report leaves a chantier open. It ends with two or three numbered choices in plain language, recommends the current safe direction, and names neither a skill nor a command. A completed chantier has no choice block; a blocked chantier offers safe recovery choices.

## Verdict Header

Start every final report with the chantier line followed by the verdict:

```text
🧱 CHANTIER (<local|spec>) : <name>
🎯 VERDICT (HH:mm) : <verdict or status>
```

For a blocked verdict, use `🚧 CHANTIER` instead of `🧱 CHANTIER`.

Follow the exact placement and exception rules in `$SHIPGLOWS_ROOT/skills/references/final-report-timestamp.md`. Do not add a closing verdict or timestamp. If the report asks a numbered question, its final visible text is the options and the reply instruction.
