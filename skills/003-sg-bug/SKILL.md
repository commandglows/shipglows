---
name: 003-sg-bug
description: "Intake, fix, retest, and ship bugs."
argument-hint: [optional: BUG-ID | bug summary | --fix BUG-ID | --retest BUG-ID | --verify BUG-ID | --ship BUG-ID]
---

Primary artifact type: `master-workflow`.

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/shipglows`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active `specs/*.md` chantier is identified, append the current run to `Skill Run History`, update `Current Chantier Flow` when the run changes the chantier state, and open the report with the opening chantier header. If no unique chantier is identified, do not write to any spec; use a `(local)` chantier header with a short work name.

## Report Modes

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, outcome-first, and using the opening chantier header. Use `report=agent`, explicit handoff, or an explicitly verbose request when another agent needs detailed bug state, evidence paths, internal routes, or lifecycle state. A blocked user report remains plain-language and ends with safe recovery choices.

## Master Delegation

Before choosing execution topology, load `$SHIPGLOWS_ROOT/skills/references/master-delegation-semantics.md`.

This skill follows that reference; local nuances below only narrow it. Bug-loop orchestration defaults to delegated sequential for bug-file/state checks, evidence gathering, fix attempts, retests, verification, closure preparation, and ship preparation when subagents are available. Parallel bug work requires ready `Execution Batches`.

## Master Workflow Lifecycle

Before resolving bug lifecycle state, load `$SHIPGLOWS_ROOT/skills/references/master-workflow-lifecycle.md`.

Use the shared bug work item model: one Markdown bug file under `shipglows_data/workflow/bugs/*.md` is the source of truth for one bug work item. `shipglows_data/workflow/BUGS.md`, when present, is only an optional compact/generated/triage view and must not override the bug file.

## Proof-First Bug Gate

Before routing to fix, retest, verify, or ship-risk claims, load `$SHIPGLOWS_ROOT/skills/references/spec-driven-development-discipline.md`. Bug work uses a `regression-first` proof path when reproduction and an automated regression surface are practical; otherwise it must record `evidence-first` or `exception-with-proof` with concrete reproduction, root cause hypothesis, and retest evidence.

For user-visible visual bugs, preserve evidence -> fix-attempted -> retest ->
fixed-pending-verify -> verify. Technical checks may support `implemented`, but
must not call it resolved, fixed, verified, or closed until a person validates
the rendered result in the post-fix retest phase. A minor exception only waives
creation of a durable bug file; it does not waive this proof route.

## Chantier Potential Intake

Apply the chantier-potential threshold from `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md` before the final report.
For `003-sg-bug`, use it when the bug reveals non-trivial future work beyond the current bug lifecycle and no unique chantier already owns that work.

## Context

- Current directory: !`pwd`
- Current date: !`date '+%Y-%m-%d'`
- Project name: !`basename $(pwd)`
- Git branch: !`git branch --show-current 2>/dev/null || echo "unknown"`
- Git status: !`git status --short 2>/dev/null || echo "Not a git repo"`
- ShipGlows development mode: !`rg -n "ShipGlows Development Mode|development_mode|validation_surface|ship_before_preview_test|post_ship_verification|deployment_provider" CLAUDE.md SHIPGLOWS.md 2>/dev/null || echo "No project development mode documented"`
- Bug files: !`find shipglows_data/workflow/bugs -maxdepth 1 -type f -name "BUG-*.md" 2>/dev/null | sort | tail -40 || echo "No canonical bugs directory"`
- Optional bug triage view: !`tail -80 shipglows_data/workflow/BUGS.md 2>/dev/null || echo "No shipglows_data/workflow/BUGS.md"`
- Recent test log: !`tail -60 shipglows_data/workflow/TEST_LOG.md 2>/dev/null || echo "No shipglows_data/workflow/TEST_LOG.md"`

## Mission

`003-sg-bug` is the professional bug loop lifecycle executor.

It answers one operational question:

```text
What is the next safe step in this one bug's lifecycle, and how do we carry it from evidence to verified ship without overstating closure?
```

It orchestrates the lifecycle through owner skills and bounded subagents:

```text
intake -> 107-sg-test -> bug file -> 106-sg-fix -> 107-sg-test --retest -> 103-sg-verify -> 005-sg-ship
```

The goal is fewer manual decisions and fewer manual commands, not weaker gates. When scope, evidence, and risk are clear, `003-sg-bug` should keep executing the lifecycle in delegated sequential mode instead of ending with a command for the operator to run next.

`003-sg-bug` must not treat a bug as closed just because code changed, a retest was requested, a deploy succeeded, or the operator wants to move on.

Its dominant job is bug-work-item state interpretation and continuation. Keep the boundary explicit: `003-sg-bug` owns one bug lifecycle at a time, not generic project maintenance, direct code-fix ownership, or broad release orchestration.

If the dominant job is broader than one bug loop, route instead of staying here:

- project-wide upkeep, dependency posture, docs drift, or audit backlog -> `002-sg-maintain`
- new feature or product-story implementation -> `001-sg-build`
- bounded release confidence after implementation is already settled -> `004-sg-deploy`

## Ownership Boundaries

Orchestrate existing skills; do not duplicate their internals.

- `107-sg-test` owns guided manual QA, failed-test capture, `shipglows_data/workflow/TEST_LOG.md`, bug files under `shipglows_data/workflow/bugs/*.md`, optional `shipglows_data/workflow/BUGS.md` triage updates, and retests.
- `106-sg-fix` owns bug diagnosis, direct/spec-first repair routing, and fix attempts.
- `109-sg-auth-debug` owns auth, OAuth, sessions, callbacks, cookies, tenants, and protected-route browser diagnosis.
- `108-sg-browser` owns narrow non-auth browser evidence.
- `103-sg-verify` owns closure, user-story coherence, and remaining bug-risk verification.
- `005-sg-ship` owns commit/push and pre-ship bug-risk reporting.
- `003-sg-bug` owns status interpretation, safety gates, execution topology, lifecycle continuation, owner-skill routing, integration of downstream evidence, and final bug-loop reporting.

Delegate or route to a narrower skill when that skill owns the phase. Stop with a next command only when a stop condition, missing approval, unavailable subagent, unavailable proof surface, or explicit user request prevents continuing in the current run.

## Mode Detection

Parse `$ARGUMENTS`:

- empty -> inspect `shipglows_data/workflow/bugs/*.md` and optional `shipglows_data/workflow/BUGS.md`, then continue or recommend the highest-priority safe bug action.
- `BUG-YYYY-MM-DD-NNN` -> read the bug file first, use the optional compact index only as secondary context, interpret status, and continue through the next lifecycle step when safe.
- free text -> decide whether this is an observed failure needing `107-sg-test`, a narrow actionable bug needing `106-sg-fix`, or an ambiguous defect needing `100-sg-spec`; continue through that owner when safe.
- `--fix BUG-ID` -> delegate to `106-sg-fix BUG-ID` after confirming the bug file exists.
- `--retest BUG-ID` -> delegate to `107-sg-test --retest BUG-ID`.
- `--verify BUG-ID` -> delegate to `103-sg-verify BUG-ID`.
- `--ship BUG-ID` -> verify bug state first; delegate to `005-sg-ship BUG-ID` only when the bug state does not block clean shipping.
- `--close BUG-ID` -> refuse direct closure unless the bug file contains passing retest evidence or an explicit `closed-without-retest` exception path is chosen.

If arguments include multiple bug IDs, ask which one to handle first unless the user explicitly requests a dashboard summary.

## Step 1 — Load Bug State

When a `BUG-ID` is present:

1. Open `shipglows_data/workflow/bugs/BUG-ID.md` immediately before interpreting status.
2. Re-read optional `shipglows_data/workflow/BUGS.md` only if present, as secondary triage context.
3. Extract:
   - title, status, severity, next step
   - reproduction, expected behavior, observed behavior
   - evidence and redaction status
   - diagnosis notes
   - fix attempts
   - retest history
   - linked spec, task, commit, or release scope when present
4. If `shipglows_data/workflow/BUGS.md` and the bug file disagree, prefer the bug file for detailed evidence but report the inconsistency and route to the safest next step.

If optional `shipglows_data/workflow/BUGS.md` references a missing bug file:

- keep or report the index row without treating it as durable proof
- classify state as `needs-info`
- continue through `107-sg-test --retest BUG-ID` or `106-sg-fix BUG-ID` only if enough context remains to make that safe
- otherwise ask for recovery context

If a bug file exists without an index row:

- report the optional index gap
- continue through `107-sg-test --retest BUG-ID` or `106-sg-fix BUG-ID` after confirming the bug file frontmatter and status are usable

## Step 2 — Interpret Status

Use canonical professional bug states:

- `open`: continue through `106-sg-fix BUG-ID`, or through evidence gathering when reproduction is weak.
- `needs-info`: ask for the missing environment, observed behavior, expected behavior, or evidence.
- `needs-repro`: continue through `107-sg-test --retest BUG-ID`, `108-sg-browser`, or `109-sg-auth-debug` based on the missing proof.
- `in-diagnosis`: continue through `106-sg-fix BUG-ID` unless another skill is actively running.
- `fix-attempted`: continue through `107-sg-test --retest BUG-ID`; do not verify or ship as clean yet.
- `fixed-pending-verify`: continue through `103-sg-verify BUG-ID`.
- `closed`: report no action unless the user is investigating a regression or release notes.
- `closed-without-retest`: report residual risk and continue through `107-sg-test --retest BUG-ID` if closure confidence matters.
- `duplicate`: route to the canonical bug ID; do not fork work.
- `wontfix`: report the decision and only reopen if the product decision changed.

Severity changes routing:

- `critical` or `high`: do not ship as clean while status is `open`, `needs-info`, `needs-repro`, `in-diagnosis`, or `fix-attempted`.
- `medium` or `low`: shipping may proceed only with explicit partial-risk wording when verification has not closed the loop.

## Step 3 — Choose Evidence Path

Run the evidence owner before fixing when the missing proof matters:

- Auth, OAuth, cookies, sessions, callbacks, tenants, protected routes -> `/109-sg-auth-debug [BUG-ID or title]`
- Non-auth route, visible state, console, network, screenshot, or page assertion -> `/108-sg-browser [URL or scope] [objective]`
- Full user flow, human confirmation, durable test record, or retest -> `/107-sg-test [scope]` or `/107-sg-test --retest BUG-ID`
- Runtime crash, error boundary, 5xx, visible Sentry/support event ID, production exception, or copyable diagnostics/logs -> load `$SHIPGLOWS_ROOT/skills/references/sentry-observability.md` and `$SHIPGLOWS_ROOT/skills/references/runtime-diagnostics-surface.md`, then attach a redacted Sentry issue/event pointer or copied diagnostic summary to the bug evidence when available
- Unclear expected behavior, permission contract, data contract, or product rule -> `/100-sg-spec [bug title]`

Do not invent reproduction results, browser evidence, screenshots, account roles, console logs, or user confirmations.

Before marking a bug `needs-info`, apply the Operator Autonomy Standard from `$SHIPGLOWS_ROOT/skills/references/decision-quality-contract.md`: gather safe evidence yourself from bug files, specs, git diff, browser/app diagnostics, copyable logs, local checks, PM2/server logs, or visible runtime output. Ask the operator only for a real decision, credential/secret, unavailable environment, device/manual-only proof, or unsafe action.

Set the bug proof path before dispatching the owner skill:

- `regression-first`: reproduction exists and a failing automated regression test is practical before the fix.
- `evidence-first`: the reliable proof is browser, manual, runtime, copied diagnostics/logs, Sentry/PM2, screenshot, or retest evidence.
- `exception-with-proof`: automated regression is impractical; the bug file or report must say why and name the alternate proof.

If the bug has repeated fix attempts without root cause evidence, route to deeper diagnosis instead of another patch.

## Step 4 — Apply Development Mode Gate

Read `$SHIPGLOWS_ROOT/skills/references/project-development-mode.md` and the project-local `## ShipGlows Development Mode` section in `CLAUDE.md` or `SHIPGLOWS.md`.

- `local`: local retests and browser checks can be authoritative when the bug is local.
- `vercel-preview-push`: apply `$SHIPGLOWS_ROOT/skills/references/preview-proof-routing.md`; for bug retests, the downstream proof owner is typically `/107-sg-test --preview --retest BUG-ID`.
- `hybrid`: require the preview-push sequence for hosted-only bugs: auth callbacks, OAuth redirect URLs, webhooks, deployment env vars, edge/serverless runtime, Vercel routing, preview/prod data, or bugs that reproduce only remotely.
- missing mode with Vercel signals: classify as `unknown-vercel` and do not claim preview retest authority.

## Step 5 — Ship And Closure Gate

For `--ship BUG-ID`:

1. Read the bug file and optional index.
2. If severity is high/critical and status is not `fixed-pending-verify`, `closed`, `duplicate`, or `wontfix`, block clean shipping.
3. If status is `fixed-pending-verify`, continue through `103-sg-verify BUG-ID` first.
4. If status is `closed`, `duplicate`, or `wontfix`, continue through `005-sg-ship BUG-ID` only if the code scope is otherwise bounded.
5. If user explicitly accepts partial-risk shipping, continue through `005-sg-ship BUG-ID` with a risk note; do not claim bug closure.

For `--close BUG-ID`:

- `closed` requires passing retest evidence in `Retest History` plus verification-compatible state.
- `closed-without-retest` requires visible reason, residual risk, and operator-facing exception text.
- If neither condition is met, continue through `107-sg-test --retest BUG-ID` or `103-sg-verify BUG-ID` when safe.

## Security And Evidence Rules

- Never print or persist raw secrets, tokens, cookies, private keys, raw auth headers, private payloads, production PII, or sensitive screenshots.
- Never print or persist raw Sentry payloads, breadcrumbs, replay contents, copied diagnostic payloads, headers, private URLs, user lists, or PII; keep only redacted issue/event pointers, commit/build header status, and short summaries.
- Keep `shipglows_data/workflow/TEST_LOG.md` and optional `shipglows_data/workflow/BUGS.md` compact.
- Keep full detail in `shipglows_data/workflow/bugs/BUG-ID.md`.
- Store only redacted large evidence under `test-evidence/BUG-ID/`.
- Reject evidence paths that escape the repo with `..`.
- Do not use UI visibility as proof of authorization.

## Stop Conditions

Stop and report `blocked` when:

- the requested `BUG-ID` is malformed
- the bug file is missing or too inconsistent for safe routing
- the user requests closure without retest evidence or a valid exception
- the next action could mutate production or destructive data without explicit approval
- sensitive evidence is unredacted
- a clean ship is requested while high/critical bug state is still unresolved
- the project development mode requires preview evidence that has not gone through the preview-proof route

## Final Report

```text
🧱 CHANTIER (local|spec) : [nom]
🎯 VERDICT (HH:mm) : [corrigé | partiel | bloqué | aucune action]

[État du bug, résultat observable et preuve compacte]
[Risque, preuve manquante ou limite de sécurité seulement si elle compte]

## Chantier potentiel

Chantier potentiel: [oui/non/incertain]
Titre proposé: [title or None]
Raison: [short reason]
Sévérité: [P0/P1/P2/P3/unknown]
Formalisation recommandée: [oui/non] — [raison courte]

[Si le chantier reste ouvert, terminer par deux ou trois choix numérotés en
langage simple. Un blocage reçoit des choix de récupération sûrs. Ne jamais
exposer un skill, une commande, un propriétaire, un chemin de bug/spec, un
mode d'exécution ou un flux.]
```

In `report=agent`, include the bug identifier and durable record, classification,
development mode, proof path, redacted diagnostics, security posture, internal
owner route, lifecycle state, remaining evidence, and exact next command.

## Rules

- Execute the bug loop through owner skills and bounded subagents; do not repair code directly inside the `003-sg-bug` master thread.
- Do not write bug files directly except to report routing gaps; use `107-sg-test` or `106-sg-fix` for durable bug mutations.
- Do not close bugs from intent, code diff, deployment status, or optimistic wording.
- Do not route preview/manual/browser retests before the preview-proof route when project mode requires deployed evidence.
- Follow the shared master delegation reference for delegated sequential defaults and spec/batch-gated parallelism.
- Prefer continuing the next safe lifecycle action over ending with a broad report when a bug is actionable and no stop condition blocks execution.
- Ask only when the missing answer changes severity, status, destructive risk, closure, or ship risk.
- Do not commit or push.
