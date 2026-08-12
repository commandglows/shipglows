---
name: 106-sg-fix
description: "Triage and repair bugs, regressions, and failing behavior."
argument-hint: <bug description, error message, or failing behavior>
---

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/.shipglows/runtime`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

Primary artifact type: `specialist-workflow`.

## Instruction Layering

This `SKILL.md` is the activation contract. Before editing or expanding this skill, load `$SHIPGLOWS_ROOT/skills/references/skill-instruction-layering.md` and keep bulky workflow detail in skill-local references.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active `specs/*.md` chantier is identified, append the current run to `Skill Run History`, update `Current Chantier Flow` when the run changes the chantier state, and open the report with the opening chantier header. If no unique chantier is identified, do not write to any spec; use a `(local)` chantier header with a short work name.

## Chantier Potential Intake

Apply the chantier-potential threshold from `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md` before the final report.
For `106-sg-fix`, use it when the bug reveals non-trivial future work beyond a direct bounded repair and no unique chantier already owns that work.

## Required References

Before any fix attempt, load:

- `$SHIPGLOWS_ROOT/skills/references/spec-driven-development-discipline.md`
- `$SHIPGLOWS_ROOT/skills/references/project-runtime-policy.md` when the bug involves a ShipGlows-managed PM2 startup failure or crash loop.
- `$SHIPGLOWS_ROOT/skills/references/decision-quality-contract.md`
- `$SHIPGLOWS_ROOT/skills/references/task-application-loop.md`
- `$SHIPGLOWS_ROOT/skills/references/zombies-edge-case-heuristic.md` when the bug involves non-trivial behavior, state, boundaries, interfaces, or exceptional paths.
- `$SHIPGLOWS_ROOT/skills/references/clean-code-quality-contract.md` before materially modifying code.
- `$SHIPGLOWS_ROOT/skills/references/owasp-application-security-awareness.md` when a direct fix touches an internet-facing or privileged surface.
- `$SHIPGLOWS_ROOT/skills/106-sg-fix/references/bug-fix-workflow.md`

Load `$SHIPGLOWS_ROOT/skills/references/design-system-token-contract.md` before UI, mobile, component, layout, typography, spacing, color, shadow/elevation, motion, safe-area, keyboard/IME, overlay, responsive, token, theme, or visual bug fixes.

Load `$SHIPGLOWS_ROOT/skills/references/documentation-freshness-gate.md` when the bug may depend on current framework, SDK, service, API, auth/session, build, migration, cache, routing, or integration behavior.

Load `$SHIPGLOWS_ROOT/skills/references/project-development-mode.md` before deciding how the fix can be retested.

Load `$SHIPGLOWS_ROOT/skills/references/atlas-protection-preflight.md` when the target project owns an Atlas registry. Run it before the first fix write; do not use a bug report as implicit permission to change a Gold/Diamond target.

Load only the relevant Supabase, Sentry, runtime diagnostics, auth-debug, or browser references when the detailed workflow triggers those gates.

## ShipGlows-Owned Preflight

Apply `$SHIPGLOWS_ROOT/skills/references/shipglows-owned-preflight.md` before reading ShipGlows-owned references, running ShipGlows-owned tools/scripts, or checking ShipGlows-owned bug-memory/runtime surfaces.
For `106-sg-fix`, this preflight also applies before creating or updating durable ShipGlows-owned bug memory.

## Mission

Use bug language, not session language.

`106-sg-fix` answers one question: `Ce bug est-il assez clair et borné pour un correctif direct sûr ?`

`106-sg-fix` is the bug-oriented entrypoint that decides whether the issue should be fixed directly now or go through a spec-first path before implementation. Goal: close small, clear bugs efficiently without breaking the user promise, product coherence, security posture, performance expectations, maintainability, or durability.

## Proof Path

Choose a bug proof path before patching:

- `regression-first` when reproduction and a practical failing regression test exist.
- `evidence-first` when the only reliable proof is browser/manual/runtime evidence.
- `exception-with-proof` when automated regression is impractical; record why, the root cause hypothesis, and the alternate proof.

For non-trivial bugs, use ZOMBIES to challenge the reproduction and regression scope. Do not patch only the observed happy-path instance when zero, many, boundary, interface, or exceptional variants share the same root cause.

## Routing Rule

Direct fix path is allowed only for small, local, clear bugs with obvious expected behavior, low ambiguity, no migration/auth/data contract change, and no material risk to permissions, visibility, workflow integrity, or external side effects.

`106-sg-fix` may repair directly only when the bug is small, clear, and low-risk.

Spec-first path is required for multi-file or cross-system impact, unclear expected behavior, likely edge cases, migration/data/auth/perf implications, or ambiguity that could materially change behavior, scope, or security.

Direct fix never means quick-fix shortcut. Apply the `Fast Fix Shortcut Ban`: root cause, owner boundary, durable structure, and proof path must remain intact.

A direct fix must also pass the proportional `Clean Code Gate`: do not hide the symptom behind vague naming, added branching, swallowed errors, dead compatibility code, or a premature abstraction.

UI, IME, keyboard, overlay, responsive, spacing, typography, color, motion, target-size, or layout bugs are direct-fix eligible only when the bounded professional repair preserves the project's design-system source of truth and passes changed-file drift evidence. Do not hardcode one-off visual values to make a bug disappear. If the correct repair requires token/theme/component/measurement changes, route through `006-sg-design` or spec-first rather than accepting drift.

## Bug Intake

If `$ARGUMENTS` is provided, use it. If empty, ask: `Quel bug veux-tu corriger ?`

Always reconstruct the bug as a tiny user story: actor, trigger, broken behavior, expected outcome/user value. Ask targeted clarification only when the missing answer changes visible behavior, scope, permission boundary, destructive side effects, retries, failure handling, data exposure, tenant isolation, or security posture.

Before asking the operator for logs, reproduction detail, screenshots, status, or validation, apply `$SHIPGLOWS_ROOT/skills/references/operator-last-resort-evidence.md`.

## BUG-ID And Bug Memory

Direct bug fixes still require durable bug memory. `106-sg-fix` must finish with a bug reference and one Markdown bug file under `shipglows_data/workflow/bugs/*.md` unless the issue is a narrow minor exception.

Minor exceptions are limited to typo/copy-only fixes, purely cosmetic visual defects with no state/permission/data/interaction consequence, or duplicates of an already-tracked `BUG-ID` with no new diagnosis or fix history. Never use the exception for auth, data, workflow, permission, API, redirect, cache, payment, external effect, or stateful UI bugs.

A minor exception only waives creation of a new durable bug file. It still
requires evidence before the fix, a post-fix retest, and verification routing.
For a user-visible visual defect, technical checks may support `implemented`,
but do not call it resolved, fixed, verified, or closed until a person validates
the rendered result. If that validation is unavailable, report the concrete
proof gap and route it through the owner named by the shared proof discipline.

When a `BUG-ID` exists, open `shipglows_data/workflow/bugs/BUG-ID.md` right before intake and treat it as source of truth. If no bug file exists and no exception applies, create or reserve a new durable bug record before or during the direct fix flow using the procedure in `bug-fix-workflow.md`.

## Security And Data Gates

Force `spec-first` if any unresolved point could change who can see/do the action, what data becomes visible/editable/deletable/triggerable, whether the workflow can be bypassed/replayed/left inconsistent, or whether external systems, billing, notifications, jobs, or automations behave differently.

Direct fixes must preserve security-by-default: do not rely on UI-only protection, validate untrusted inputs where relevant, preserve auth/authz checks and tenant/resource boundaries, and prevent obvious replay, double-submit, stale-state, or invalid-order issues when relevant.

For applicable fixes, preserve or repair the selected `OWASP Security Gate`; a fixed local repro does not close access-control, integrity, logging, or exceptional-condition risk without matching evidence.

## Execution

If `direct`, apply the shared task application loop to implement the bounded professional repair one repair slice at a time, attach it to durable bug memory, append a `Fix Attempts` row after the actual attempt, run relevant checks, and keep the bug status no stronger than `fix-attempted` until retest evidence exists.

For a qualifying visual minor exception, record `minor exception` rather than
creating a bug file, but preserve the same evidence -> fix-attempted -> retest
-> fixed-pending-verify -> verify order. A person validates the rendered result
in the retest phase; no static or transport check can promote the repair beyond
`implemented` on its own.

If `spec-first`, do not code; route to `/100-sg-spec`, `/101-sg-ready`, then `/102-sg-start`.

If `diagnostic only`, do not code; route to `109-sg-auth-debug`, `108-sg-browser`, or a concrete next step as appropriate.

Before asking the operator for logs, reproduction detail, screenshots, status, or validation, apply `$SHIPGLOWS_ROOT/skills/references/operator-last-resort-evidence.md`.

For runtime errors, error boundaries, 5xx, crashes, or visible support states, use the app's diagnostics/log-copy surface when reachable. Confirm the copied text starts with commit/build plus Paris/UTC build time, and treat missing or unsafe diagnostics as part of the bug evidence posture.

For a ShipGlows-managed PM2 crash loop, read the project runtime policy before attempting recovery. When `SHIPGLOWS_AUTO_REPAIR=false`, collect bounded PM2 logs and offer Codex repair; do not call or recommend `env_start` as automatic recovery.

## Stop Conditions

- Ambiguity changes product meaning, data handling, permissions, security, destructive behavior, or external side effects.
- A direct fix would repeat patch attempts without reproduction evidence and a cause-root hypothesis.
- A practical regression/evidence path cannot be named.
- Durable bug memory would be required but cannot be safely created or updated.
- Preview-push validation is required and no matching deployment target is available.
- Fresh external docs are required and unresolved.

## Final Report

Use the report shape in `bug-fix-workflow.md`: classification, reason, user story, bug reference/file, trace exception, proof path, root cause hypothesis, product/docs coherence, fresh docs, Sentry evidence, diagnostics/logs evidence, operator autonomy, development mode, preview gate, security posture, bug status transition, retest evidence, action, next step, and scope estimate.

## Rules

- Prefer direct path for truly small and clear bugs; prefer spec-first when ambiguity could create rework or risk.
- A direct fix must defend product coherence and security posture, not only pass the local repro.
- A direct fix must not bypass durable process, root cause, owner routing, shared structure, or proof.
- A direct visual fix must defend design-system coherence; unexplained hardcoded sizes, offsets, breakpoints, z-indexes, colors, font sizes, spacings, animation timings, IME/keyboard insets, or overlay positions are not acceptable proof of repair.
- For UI/design fixes, run `python3 "${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/tools/design_system_drift_check.py" --changed --format markdown` or route the gap explicitly; unresolved new drift keeps the bug at most `fix-attempted`.
- Do not close a bug without retest evidence in `shipglows_data/workflow/bugs/BUG-ID.md`.
- For a visual minor exception, do not use resolved/fixed/verified/closed language until a person validates the rendered result; otherwise report only `implemented` plus the proof gap.
- Do not treat a local retest as closure evidence when project mode requires Vercel preview-push validation.

## Validation

Validate this skill after edits with:

- `rg -n "Trace category|Process role|Chantier Potential|ShipGlows-Owned Preflight|canonical ShipGlows path|spec-driven-development-discipline|project-runtime-policy|decision-quality-contract|task-application-loop|Direct fix|Spec-first|BUG-ID|Stop Conditions|bug-fix-workflow|operator for logs|bug memory|runtime surface" skills/106-sg-fix/SKILL.md`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `python3 tools/shipglows_metadata_lint.py skills/106-sg-fix/references/bug-fix-workflow.md`
