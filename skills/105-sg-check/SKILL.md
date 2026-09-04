---
name: 105-sg-check
description: "Technical checks for typecheck, lint, build, and repair."
disable-model-invocation: true
argument-hint: [fix|nofix]
---

## Canonical Paths

Load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` before resolving ShipGlows-owned files (`$SHIPGLOWS_ROOT` defaults to `$HOME/.shipglows/runtime`). Project files resolve from the current project root.

Primary artifact type: `specialist-workflow`.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

Before the final report, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md` only when attached to a unique spec-first chantier or when findings cross its chantier-potential threshold. Otherwise use a `(local)` chantier header and do not edit trackers.

## Mission

Answer: `Quels checks techniques apportent une confiance proportionnee sur cette surface ?`

Run and interpret proportional technical checks. A green result proves only the checks executed: it is not product, browser, manual-flow, security, auth, or production proof. Generated caches and scratch build outputs are disposable unless the project contract requires them.

## Scope Gate

- Accept `fix` or `nofix`; with either explicit mode, run all detected proportional checks without prompting.
- With empty arguments, derive the proportional check set from the changed surface, project instructions, manifests, lockfiles, available scripts, and risk; run it read-only as `nofix`. Do not ask the operator to select typecheck, lint, build, tests, or dependency mechanics.
- Use `bounded` checks for localized low-risk edits and `full` checks only for shared behavior, auth/data boundaries, dependency/build changes, or release risk.
- At a workspace root with multiple projects and no project markers, ask which projects to check and run selected projects sequentially.
- `nofix` is strictly read-only. In `fix`, repair root causes and rerun the failed check, for at most 3 fix cycles.
- Never install dependencies, weaken lint/type/test/build rules, trivialize assertions, or remove validation, auth, authorization, or error handling to obtain green output.

## Required References

Before choosing or interpreting checks, load `$SHIPGLOWS_ROOT/skills/references/project-development-mode.md` and inspect project instructions and lockfiles.

Then load exactly what the scenario requires:

- `$SHIPGLOWS_ROOT/skills/105-sg-check/references/check-execution-playbook.md` after the project and requested check scope are known.
- `$SHIPGLOWS_ROOT/skills/105-sg-check/references/check-repair-and-report-playbook.md` only when a check fails, is blocked, leaves a material coverage gap, or hosted proof is required.
- `$SHIPGLOWS_ROOT/skills/references/actionable-failure-contract.md` for failed or blocked checks.
- `$SHIPGLOWS_ROOT/skills/references/preview-proof-routing.md` for `vercel-preview-push` or hosted-proof `hybrid` work.
- `$SHIPGLOWS_ROOT/skills/references/project-runtime-policy.md` for ShipGlows-managed PM2 or `.shipglows.env` behavior.
- `$SHIPGLOWS_ROOT/skills/references/shipglows-owned-preflight.md` before ShipGlows-owned tools, scripts, references, or runtime-visibility checks.

## Stop Conditions

Stop mutation immediately in `nofix`. Stop after the third unsuccessful fix cycle and report an actionable owner and impact. Do not claim complete coverage when a relevant check is unavailable, registry access is blocked, runtime behavior is untested, or preview evidence is still required.

Quick dependency checks never auto-update packages and never become security sign-off. Escalate comprehensive dependency, supply-chain, license, or unclear high-risk findings to `/010-sg-technical deps <project>` or `/sg-maintenance security`.

Route browser-observable proof to `/108-sg-browser`, auth/protected proof to `/109-sg-auth-debug`, hosted truth to `/405-sg-prod`, and product-readiness judgment to `/103-sg-verify`.

## Report Modes

Report commands/checks executed, pass/fail/blocked status, repairs made, remaining failures, and proof limits. Include `Risky assumptions / gaps` whenever a relevant check was unavailable or skipped, runtime/integration coverage is absent, a security scan was partial, or warnings remain material.

For preview-required work, describe the missing hosted, browser, auth, or manual outcome in plain language and route it internally to the correct owner. Never expose internal skill commands in `report=user`. Never describe a passing `105-sg-check` run as production-ready.

## Validation

- `python3 -m unittest tools.test_105_sg_check_contract`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `tools/shipglows_sync_skills.sh --check --skill 105-sg-check`
