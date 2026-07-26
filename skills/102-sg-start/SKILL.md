---
name: 102-sg-start
description: "Execute ready specs or substantive local implementation tasks with guardrails."
argument-hint: <task description or TASKS.md item>
---

Primary artifact type: `specialist-workflow`.

## Canonical Paths

Before resolving any ShipGlowz-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipglowz`). ShipGlowz tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Instruction Layering

This `SKILL.md` is the activation contract. Before editing or expanding this skill, load `$SHIPFLOW_ROOT/skills/references/skill-instruction-layering.md` and keep bulky workflow detail in skill-local references.

## Chantier Tracking

Trace category: `obligatoire`.
Process role: `lifecycle`.

Before executing from a ready spec, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md`, read the spec's `Skill Run History` and `Current Chantier Flow`, and preserve that flow in the execution contract. When a unique spec is used, append a current `102-sg-start` row with result `implemented`, `partial`, `blocked`, or `rerouted`, update `Current Chantier Flow`, and open the report with the opening chantier header from `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`. If the task is direct or no unique chantier spec is identified, do not write to a spec; use a `(local)` chantier header with a short work name.

Result semantics:
- Use `implemented` when the planned code, docs, and tests within `102-sg-start` scope were completed, even if runtime, manual, hosted, production, Sentry, or device-only verification remains pending.
- Use `partial` only when implementation work itself is incomplete, intentionally deferred, or some planned files or tasks could not be finished.
- Missing manual QA, hosted preview proof, Sentry dashboard evidence, production verification, or device-only validation must not downgrade `102-sg-start` from `implemented` to `partial`; record those gaps for `103-sg-verify` instead.
- When local implementation is complete but those gaps stay pending, avoid closure/ship-ready wording and route the next owner or proof step explicitly. Apply `$SHIPFLOW_ROOT/skills/references/preview-proof-routing.md` when deployed proof is required.
- If local checks fail because the implementation is broken, use `partial` or `blocked` depending on whether the fix can continue. If checks fail because the environment cannot run a proof surface outside `102-sg-start` scope, keep `implemented` and route to `103-sg-verify partial`.

Auto-verify semantics:
- When a unique ready spec is in scope and the only remaining lifecycle proof is local, tool-backed, non-destructive verification, `102-sg-start` may run that local verification itself at an explicit checkpoint, end-of-conversation handoff, `SGEND`/`104-sg-end`, `SGSHIP`/`005-sg-ship`, or on explicit operator request, and report `auto-verify: run`. Eligibility alone does not authorize mid-conversation checks.
- Do not auto-verify when proof needs preview, production, auth/browser flows, Sentry, device testing, manual QA, secret access, a user decision, commit, push, ship, or any external side effect; report `auto-verify: skipped` with the exact owner route instead.
- Local auto-verify never means `104-sg-end`, `005-sg-ship`, or full lifecycle orchestration; `001-sg-build` remains the owner of full `103-sg-verify -> 104-sg-end -> 005-sg-ship` continuation.

Any temporary build output, cache, or scratch preview created during implementation or auto-verify is disposable unless the task explicitly requires a durable project artifact. Remove it before ending the run.

## Report Modes

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, outcome-first, and using the opening chantier header. Use `report=agent`, blocked, handoff, verbose, or full report only when detailed evidence is needed.

## Required References

Load only the references needed for the active run:

- `references/execution-workflow.md`: detailed task identification, scope triage, execution contract, model/delegation choice, implementation loop, validation, spec trace, and final report rules.
- `$SHIPFLOW_ROOT/skills/references/task-application-loop.md`: required before task-by-task implementation to preserve target selection, context loading, progress semantics, stop conditions, and proof routing.
- `$SHIPFLOW_ROOT/skills/references/decision-quality-contract.md`: required before selecting direct mode, model, topology, implementation path, or fallback. Bounded implementation is allowed; shortcut quality or shortcut excellence is not.
- `$SHIPFLOW_ROOT/skills/references/operational-record-format.md`: required before creating or mutating task, audit, or `spec:` operational records in `TASKS.md`, `AUDIT_LOG.md`, or spec summary sections.
- `$SHIPFLOW_ROOT/skills/references/spec-driven-development-discipline.md`: required before implementation when the task changes behavior, fixes a bug, changes a skill contract, or needs a proof path. Choose `test-first`, `regression-first`, `scenario-first`, `evidence-first`, or `exception-with-proof` before editing and report the chosen proof path.
- `$SHIPFLOW_ROOT/skills/references/design-system-token-contract.md`: required before UI, mobile, component, layout, typography, spacing, color, shadow/elevation, motion, safe-area, keyboard/IME, overlay, responsive, token, theme, or visual proof work.
- `$SHIPFLOW_ROOT/skills/references/documentation-freshness-gate.md`: required only when the task depends on framework, SDK, service, API, auth/session, build, migration, cache, routing, or integration behavior.
- `$SHIPFLOW_ROOT/skills/references/project-development-mode.md`: required before deriving the execution contract for project validation surface.
- `$SHIPFLOW_ROOT/skills/references/runtime-diagnostics-surface.md`: required when the task touches a runtime app, support/error handling, settings, auth callbacks, deploy proof, Sentry, browser debugging, or log collection.
- Supabase, Sentry, auth-debug, browser, or model-routing references only when the workflow reference triggers their gate.

## ShipGlowz-Owned Preflight

Apply `$SHIPFLOW_ROOT/skills/references/shipglowz-owned-preflight.md` before reading ShipGlowz-owned references, running ShipGlowz-owned tools/scripts, or mutating ShipGlowz-owned operational records.
For `102-sg-start`, this preflight also applies before touching ShipGlowz-owned tracker or spec surfaces.

## Mode Detection

Parse `$ARGUMENTS`, available ready specs, and the latest user request.

- Atomic direct execution: an exact string, placeholder, typo, heading-tag, or formatting replacement that needs no implementation judgment stays outside `102-sg-start` unless the user explicitly invoked this skill. Execute it directly with focused validation.
- Direct mode: small, local, clear tasks may execute without a durable spec; create a silent mini-contract before editing.
- Spec-first mode: non-trivial, ambiguous, multi-file, auth/data/migration/API/security, external integration, or cross-domain work requires a ready spec before implementation.
- Existing ready spec: load `references/execution-workflow.md`, read the spec fully, derive the execution contract, then implement.
- Missing or unready spec: stop and route to `/100-sg-spec`, `/101-sg-ready`, then `/102-sg-start`.

## Core Execution Rules

`102-sg-start` answers one question:

```text
What implementation can be completed now without overstating proof, closure, or ship status?
```

- `102-sg-start` implements; it should not stop at planning when a valid execution contract exists.
- Apply the shared task application loop: identify target state, load required context, implement one bounded slice at a time, update durable progress only after completion, and route proof gaps explicitly.
- Preserve the user story outcome over task-checkbox completion.
- Preserve the spec or mini-contract as the source of truth; tests and evidence prove the contract, they do not redefine it.
- Follow the decision-quality contract: choose bounded excellent professional implementation, not the fastest/easiest patch. Speed, cost, and local convenience are secondary after correctness, security, performance, maintainability, durability, excellence, and proof quality.
- Apply the `Structure Replacement Doctrine`: when two implementation paths are quality-equivalent, prefer the one that removes repeated operator friction, hidden manual steps, ambiguity, or maintenance burden from the current structure.
- Obey the `Fast Fix Shortcut Ban`: do not bypass root cause, owner routing, shared structure, documentation, or proof to make a local symptom disappear.
- For UI, IME, keyboard, overlay, responsive, layout, spacing, typography, color, motion, or component work, obey the `UI And Design-System Shortcut Ban`: do not hardcode one-off visual values as an emergency shortcut; fix the token, theme, component primitive, layout utility, or measurement source unless a named platform-bound constant is explicitly justified and proven.
- For any UI/design implementation, run or route the changed-file drift check from `design-system-token-contract.md`. New literals outside the canonical token/theme/component source block a clean completion claim unless documented as platform-bound exceptions.
- For runtime apps, preserve or add the safe diagnostics/log-copy surface from `runtime-diagnostics-surface.md`; prefer the existing project component/helper and ensure copied diagnostics start with commit/build plus Paris/UTC build time.
- For testable behavior, prefer a `test-first` proof path. For skill/governance changes, use `scenario-first`. For UI/docs/auth/deploy/operational work, use `evidence-first`. If the strongest path is impractical, record `exception-with-proof` and the alternate evidence.
- Read only the files needed for the execution contract and linked systems that can change correctness.
- Prefer fresh-context execution for non-trivial spec-first work when available, but keep the main thread responsible for integration, validation, and user-facing truth.
- Do not weaken documentation, security, redaction, chantier, or validation gates to finish faster.
- Apply `$SHIPFLOW_ROOT/skills/references/operator-last-resort-evidence.md` before asking the operator for logs, validation status, or similar evidence.
- If implementation is complete and the next unresolved owner is proof, route to `103-sg-verify` instead of drifting into closure or ship language.
- Respect canonical source roots from `$SHIPFLOW_ROOT/skills/references/canonical-paths.md`; for monorepos using the Astro plus Flutter plus backend split, keep flat roots at the monorepo root and do not introduce nested `apps/*` layout without a documented durable exception.

## Stop Conditions

Stop and report blocked or rerouted when:

- No ready spec exists for non-trivial work.
- The spec is missing minimal behavior, success/error behavior, linked systems, explicit tasks, acceptance criteria, or decisive constraints.
- Product/security/data/tenant/destructive/external-side-effect ambiguity remains.
- The implementation path would satisfy listed tasks while missing the promised user outcome.
- Required references are missing or contradict this activation contract.

## Validation

Validate this skill after edits with:

- `rg -n "Trace category|Process role|Result semantics|Auto-verify semantics|auto-verify|implemented|partial|Report Modes|Required References|ShipGlowz-Owned Preflight|canonical ShipGlowz path|Spec-first|ready spec|references/execution-workflow|task-application-loop|spec-driven-development-discipline|test-first|evidence-first|proof path" skills/102-sg-start/SKILL.md`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `tools/shipglowz_sync_skills.sh --check --all`
