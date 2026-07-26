---
name: 103-sg-verify
description: "Verify ship readiness or run an excellence-focused second pass."
argument-hint: "[mode=standard|mode=excellence] [task or scope]"
---

Primary artifact type: `specialist-workflow`.

## Canonical Paths

Before resolving any ShipGlowz-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipglowz`). ShipGlowz tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Instruction Layering

This `SKILL.md` is the activation contract. Load `$SHIPFLOW_ROOT/skills/references/skill-instruction-layering.md` before execution; keep local verdict semantics and verification dimensions here, and load detailed gate playbooks from references.

## Chantier Tracking

Trace category: `obligatoire`.
Process role: `lifecycle`.

Before verifying a spec-first chantier, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md`, then read the spec's `Skill Run History` and `Current Chantier Flow` when a unique spec exists. Append a current `103-sg-verify` row with result `verified`, `verified_with_excellence_gaps`, `excellent`, `not verified`, `partial`, or `blocked`, update `Current Chantier Flow`, and open the report with the opening chantier header from `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`. If no unique spec is available, do not write to a spec; use a `(local)` chantier header with a short work name.

Verification semantics:

- `partial`: implementation appears complete but required proof is missing (manual QA, preview/prod proof, browser/auth proof, Sentry pointer, device-only validation). Each missing proof gap must be routed to a concrete next owner (`405-sg-prod`, `108-sg-browser`, `109-sg-auth-debug`, `107-sg-test`, `005-sg-ship`, etc.) with proof type, scenario, and target/environment when knowable; if target/environment is unknown, route to `405-sg-prod` with explicit target discovery task and do not claim readiness.
- Never downgrade completed `102-sg-start` implementation semantics only because verification evidence is incomplete.
- Keep the distinction explicit: `102-sg-start: implemented` vs `103-sg-verify: partial`.
- Record the selected `mode=standard|excellence` in the history action and the matching verdict in the result. Never rewrite or erase an earlier `verified` row when a later excellence pass opens bounded follow-up.

When `103-sg-verify` partial is caused by hosted/deployed/provider proof, the next routing contract is mandatory:

- `103-sg-verify`: when deploy-backed proof is needed, apply `$SHIPFLOW_ROOT/skills/references/preview-proof-routing.md` and route the matching proof owner with target and scenario.


Before judging implementation quality, load `$SHIPFLOW_ROOT/skills/references/decision-quality-contract.md`. Verification must fail or report partial when the work merely takes the fastest/easiest path and leaves correctness, security, performance, maintainability, durability, excellence, or proof quality below the accepted contract.
When reporting any failure state, load `$SHIPFLOW_ROOT/skills/references/actionable-failure-contract.md` and include the concrete owner route for each evidence-backed issue.

## Report Modes

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, findings-first when verification fails, opening chantier header.
Use `report=agent` for handoff, blocked runs, or explicit verbose request.

## Mode Detection

Parse the request before selecting checks:

- No mode or `mode=standard` selects `standard`: run métier correctness, contract, proof, risk, and ship-readiness gates. A standard pass may return `verified` but makes no excellence claim.
- `mode=excellence` or an unambiguous natural-language request for an excellence pass selects `excellence`: run the standard gates first, then load the detailed excellence pass in `references/verification-gates.md` and perform a fresh second pass beyond the acceptance criteria.
- No reliable scope, or conflicting/unknown `mode=` values, stops with the existing `not verified` or `blocked` semantics; do not guess.

Verdict precedence:

- `verified`: standard métier and ship-readiness gates pass; no excellence claim is made.
- `verified_with_excellence_gaps`: standard readiness passes first, but the explicit excellence pass finds at least one material gap with evidence and a bounded repair or owner route.
- `excellent`: standard readiness passes first, the fresh second pass is complete, and no material excellence gap remains.
- Proof, correctness, security, and blocking-risk results (`partial`, `not verified`, `blocked`) take precedence over excellence verdicts; when one applies, `excellent` is forbidden.
- Always make the selected focus and verdict visible in the report; standard success must not be presented as excellence.

## Mission

`103-sg-verify` judges proof quality and ship-readiness, then challenges merely adequate work when excellence mode is explicit. It may repair stable bounded local issues, but scope-changing, specialist, hosted-proof, product-decision, or security-sensitive gaps must be routed to their owner. Keep verification verdict ownership distinct from `102-sg-start` implementation, `104-sg-end` closure, and `005-sg-ship` commit/push.

`103-sg-verify` answers the question selected by its focus:

```text
standard: Is this work proven enough to move forward, and who owns missing proof?
excellence: Once readiness passes, what material quality gap remains, and who owns follow-up?
```

## Context

- Current directory: !`pwd`
- Current date: !`date '+%Y-%m-%d'`
- Project name: !`basename $(pwd)`
- Git branch: !`git branch --show-current 2>/dev/null || echo "unknown"`
- Git diff stat: !`git diff HEAD --stat 2>/dev/null || echo "no changes"`
- Recent commits: !`git log --oneline -10 2>/dev/null || echo "no commits"`

## Verification Contract

Verify ship-readiness across six dimensions:

1. User story outcome
2. Completeness
3. Correctness
4. Coherence
5. Dependencies
6. Risks

7. Manual checklist gate: required rows are `PASS` or explicitly exception-handled; unresolved `NOT_RUN`/`FAIL`/`BLOCKED` required rows block clean verification.

Mandatory explicit checks:

- `Success Behavior` pass/partial/fail/not demonstrated
- `Error Behavior` pass/partial/fail/not demonstrated
- `Proof Path Fit` pass/partial/fail/not chosen: test-first, regression-first, scenario-first, evidence-first, or exception-with-proof matches the changed surface
- `Task Application Loop Fit` pass/partial/fail/not applicable: implementation inspected target state, loaded required context, applied bounded slices without checkbox-only drift, updated durable progress after actual completion, and routed proof gaps without conflating implementation and verification
- `Closure Archive Guard Fit` pass/partial/fail/not applicable: closure, tracker, changelog, docs, bug, spec, skill-runtime, or archive state does not claim stronger completion than implementation, proof, source-of-truth sync, and collision checks support
- `Structure Replacement Fit` pass/partial/fail: the chosen implementation or workflow change reduces current friction, ambiguity, latency, or maintenance burden when that was part of the stated problem; reject decorative new layers that add churn without operator leverage.
- `Fast Fix Shortcut Gate` pass/partial/fail: implementation does not bypass root cause, owner routing, shared structure, documentation, or required proof to make a symptom disappear.
- `Flutter Mobile Proof Ladder` pass/partial/fail/not applicable: widget tests -> agent-run Flutter Web smoke through `108-sg-browser`/`109-sg-auth-debug` -> APK/device proof order is respected for Flutter mobile UI work
- `Bug Gate` (clear/partial-risk/blocks ship/not assessed)
- `UI Design-System Shortcut Gate` pass/partial/fail/not applicable: UI, IME, keyboard, overlay, responsive, spacing, typography, color, motion, target-size, layout, or component work does not rely on unexplained one-off hardcoded visual values; any unavoidable literal is named, scoped, platform-bound, and proven.
- `Design-System Drift Check` pass/partial/fail/not applicable: changed UI/design files were scanned with `tools/design_system_drift_check.py --changed` or equivalent specialist evidence, and any findings are resolved or justified by the canonical token/theme/component source.
- `Runtime Diagnostics Gate` pass/partial/fail/not applicable: runtime projects preserve or add Sentry, safe diagnostics/log-copy, and commit/build + Paris/UTC build-time header, or document a valid static-site exception.
- `Operator Autonomy Gate` pass/partial/fail: the agent used available safe tools, files, browser/app diagnostics, logs, and checks before asking the operator; any user request is limited to a real decision, secret, unavailable environment, device/manual-only proof, or unsafe side effect.
- project development mode and validation surface
- fresh external docs verdict (`fresh-docs checked|not needed|gap|conflict`)
- documentation coherence verdict
- language doctrine verdict for ShipGlowz artifacts
- `Decision Quality Baseline` verdict: pass/partial/fail for the primary metrics and shared excellence quality bar in `decision-quality-contract.md`; this applies in every mode.
- `Excellence Focus Verdict`: report `verified_with_excellence_gaps` or `excellent` only when the selected mode is `excellence`.
- editorial score gate verdict when a spec/workflow requires content quality proof

## Required References

Always load:

1. `$SHIPFLOW_ROOT/skills/103-sg-verify/references/verification-gates.md`
2. `$SHIPFLOW_ROOT/skills/references/project-development-mode.md`
3. `$SHIPFLOW_ROOT/skills/references/documentation-freshness-gate.md`
4. `$SHIPFLOW_ROOT/skills/references/spec-driven-development-discipline.md`
5. `$SHIPFLOW_ROOT/skills/references/decision-quality-contract.md`
6. `$SHIPFLOW_ROOT/skills/references/task-application-loop.md` when scope includes task-by-task implementation, direct fixes, skill contract edits, tracker progress, or progress/completion semantics.
7. `$SHIPFLOW_ROOT/skills/references/closure-archive-guard.md` when scope includes tracker closure, changelog framing, done/closed wording, archived artifacts, docs/source-of-truth sync, or full-close shipping.
8. `$SHIPFLOW_ROOT/skills/references/documentation-reflection-gate.md` when verification can imply a milestone or user-facing completion.
8. `$SHIPFLOW_ROOT/skills/references/design-system-token-contract.md` when scope includes UI, mobile, component, layout, typography, spacing, color, shadow/elevation, motion, safe-area, keyboard/IME, overlay, responsive, token, theme, or visual proof work.
9. `$SHIPFLOW_ROOT/skills/references/content-quality-rubric.md` when scope includes an editorial score or content quality gate.

Load on demand:

- `$SHIPFLOW_ROOT/skills/references/sentry-observability.md` when runtime failures/observability/deployed behavior are in scope.
- `$SHIPFLOW_ROOT/skills/references/runtime-diagnostics-surface.md` when verifying a runtime app, support/error handling, settings, auth callback, Sentry, browser-debug, log-copy, or deploy-proof surface.
- `/109-sg-auth-debug` evidence for auth/session/callback/protected-route proof.
- `/108-sg-browser` evidence for non-auth browser proof.

## ShipGlowz-Owned Preflight

Apply `$SHIPFLOW_ROOT/skills/references/shipglowz-owned-preflight.md` before reading ShipGlowz-owned references, running ShipGlowz-owned tools/scripts, or checking ShipGlowz-owned sync surfaces.
For `103-sg-verify`, this preflight also applies before verifying ShipGlowz-owned runtime visibility or skill-sync targets.

## Editorial Score Gate

When a chantier asks for an editorial score or content quality gate:

- Validate the rubric schema from `content-quality-rubric.md`: `schema_version`, `run_id`, `run_signature`, `project_id`, `surface`, `evaluator`, `input_refs`, `applied_rules_revision`, `scores`, `weights`, `status`, `blocked_reasons`, `evidence`, `recommendations`, `confidence`, `expires_at_utc`.
- Reject stale or mismatched signatures with `stale_or_mismatched_score`.
- Reject recoverable/non-final statuses as verification proof: `needs retry`, `duplicate_in_progress`, `conflicting_score_state`, `stale_or_mismatched_score`.
- Accept only final statuses: `ready`, `needs revision`, `blocked`, `publishable with caveats`.
- Treat any blocking criterion or blocking code as non-verified for ship-readiness.

## Skill Coherence Check (when scope touches ShipGlowz skills)

When verified changes include `skills/*/SKILL.md`:

- each changed skill must expose `Trace category` and `Process role`
- changed `source-de-chantier` skills must still contain chantier-potential guidance
- changed helper skills must not present themselves as chantier sources
- skill contract changes must show `scenario-first` pressure scenarios, mechanical checks, or `exception-with-proof`
- if runtime-discoverable skills changed, run `tools/shipglowz_sync_skills.sh --check --skill <name>` or `--check --all`

## Tracker Rule

`103-sg-verify` can patch code/docs when contract is stable, but shared trackers are read-only in this skill:

- do not edit `TASKS.md`, `AUDIT_LOG.md`, `PROJECTS.md` from `103-sg-verify`
- if verification only reads task, audit, or `spec:` operational records, treat `$SHIPFLOW_ROOT/skills/references/operational-record-format.md` as reader context; load it before any exceptional spec-summary repair.
- do not treat tracker frontmatter absence as defect

## Stop Conditions

Report `not verified` or `blocked` when:

- no reliable scope/work-item contract can be identified
- high/critical bug in scope is still open
- required validation surface is missing for `vercel-preview-push`/`hybrid` scope
- completion evidence does not match the chosen proof path, or no proof path was chosen for behavioral, bug, skill-contract, UI/docs/auth/deploy, or operational work
- closure, archive, tracker, changelog, or docs state would imply stronger completion than source-of-truth sync and proof evidence support
- critical security/data/workflow risk is unproven or failing
- the implementation is a shortcut that violates the decision-quality contract
- the implementation is a quick-fix shortcut that bypasses durable process, ownership, root cause, shared structure, documentation, or required proof
- UI/design work hides a defect through hardcoded sizes, offsets, breakpoints, z-indexes, colors, font sizes, spacing, animation timings, IME/keyboard insets, overlay positions, or viewport constants instead of repairing the token/theme/component/layout/measurement source of truth
- changed UI/design files have unresolved drift-check findings outside the canonical design-system source of truth

## Validation

Run focused checks based on scope and diff:

```bash
rg -n "Trace category|Process role|Success Behavior|Error Behavior|Proof Path Fit|Task Application Loop Fit|Closure Archive Guard Fit|ShipGlowz-Owned Preflight|canonical ShipGlowz path|task-application-loop|closure-archive-guard|decision quality|proof path|evidence-first|test-first|scenario-first|fresh-docs|Chantier" skills/103-sg-verify/SKILL.md
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
```
