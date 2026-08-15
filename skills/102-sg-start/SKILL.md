---
name: 102-sg-start
description: "Execute ready specs or substantive local implementation tasks with guardrails."
argument-hint: <task description or TASKS.md item>
---

Primary artifact type: `specialist-workflow`.

## Canonical Paths

Before resolving ShipGlows-owned files, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/.shipglows/runtime`). Project artifacts still resolve from the current project root.

## Chantier Tracking

Trace category: `obligatoire`.
Process role: `lifecycle`.

For one ready spec, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md`, preserve its history/flow, append the `102-sg-start` result, and update the flow. Without one unique spec, do not write a spec; use a `(local)` chantier header.

## Mission And Mode Detection

`102-sg-start` implements one bounded work item; it does not merely plan or claim verification, closure, commit, push, or ship.

Before classifying the request, load `$SHIPGLOWS_ROOT/skills/102-sg-start/references/execution-workflow.md`.

- Atomic direct execution (exact string, placeholder, typo, heading-tag, or formatting replacement) stays outside `102-sg-start` unless explicitly invoked; execute it directly with focused validation.
- Small, local, clear work uses `direct` mode with a silent mini-contract.
- Non-trivial, ambiguous, multi-file, auth/data/migration/API/security, external-integration, or cross-domain work uses `spec-first` and requires one matching `ready` spec.
- Missing or unready contract routes to `100-sg-spec` then `101-sg-ready`; do not write.

Before reading ShipGlows-owned references or running its tools, apply `$SHIPGLOWS_ROOT/skills/references/shipglows-owned-preflight.md`.

## Result And Auto-Verify Boundaries

`implemented` means planned code, docs, and tests in this skill's scope are complete. Use `partial` only when implementation itself is incomplete. Missing manual, hosted, production, Sentry, browser/auth, or device proof does not downgrade implementation; route that gap to `103-sg-verify partial` and avoid ship-ready wording. Broken local implementation checks remain `partial` or `blocked`.

Auto-verify may report `auto-verify: run` only at an explicit checkpoint when one ready spec owns the work, implementation and local checks pass, and all remaining proof is local, tool-backed, non-destructive, decision-free, and already defined. Report `auto-verify: skipped` with `owner_skill`, `scenario`, and `target_or_environment` whenever proof needs preview, production, auth/browser flow, Sentry, device/manual QA, secrets, commit, push, ship, provider action, data mutation, or another external side effect. Local auto-verify never runs `104-sg-end` or `005-sg-ship`; `001-sg-build` retains full lifecycle ownership.

## Progressive References

Load each local reference directly from this activation contract; local references never load one another.

- Before deriving either a direct mini-contract or ready-spec execution contract, load `$SHIPGLOWS_ROOT/skills/102-sg-start/references/execution-contract.md`.
- Before model or agent topology selection, load `$SHIPGLOWS_ROOT/skills/102-sg-start/references/execution-topology.md`, `$SHIPGLOWS_ROOT/skills/references/decision-quality-contract.md`, `$SHIPGLOWS_ROOT/skills/references/master-delegation-semantics.md`, and the canonical model-routing reference.
- Immediately before the first write, load `$SHIPGLOWS_ROOT/skills/102-sg-start/references/implementation-and-proof.md` plus only its scope-triggered shared contracts. This includes `task-application-loop.md` for task-by-task work, `spec-driven-development-discipline.md` for behavioral/proof work, `zombies-edge-case-heuristic.md` for non-trivial behavior, `clean-code-quality-contract.md` for code, and `owasp-application-security-awareness.md` for internet-facing or privileged surfaces.
- After approval, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`; emit its start card once before substantive work. Before the final report, load `$SHIPGLOWS_ROOT/skills/102-sg-start/references/execution-report.md`; reuse it.

Conditional gates: PM2 runtime; fresh docs; development mode; UI tokens; diagnostics; operational records; Atlas; `$SHIPGLOWS_ROOT/skills/references/product-decision-chain.md` before writing when a confirmed decision or traced impact changes; and operator-last-resort evidence.

## Execution Invariants

- Preserve the user-story outcome, spec/mini-contract, dependencies, invariants, linked systems, and chosen proof path.
- Before writing, resolve product/security/data/tenant/destructive/external-side-effect ambiguity; never substitute checkbox completion or the fastest patch for the accepted outcome.
- Execute bounded slices, preserve existing user changes, update durable progress only after completion, and stop when scope or authority expands.
- Passing technical checks never proves product, security, auth, hosted, production, manual, or device behavior.
- Preserve observable success/failure, documentation coherence, security controls, diagnostics, and design-system sources when applicable.
- For executable work, retain the delegation receipt and report `Agents: <count> · <mode>`; independent read-only scopes are parallel by default, mutations delegated sequentially, and parallel writes require ready non-overlapping `Execution Batches` plus an integration owner.

## Stop Conditions

Stop as `blocked` or `rerouted` when no ready spec exists for non-trivial work; the contract lacks behavior, success/error, tasks, acceptance criteria, dependencies, or decisive constraints; authority or safety semantics remain ambiguous; implementation would miss the user outcome; required references are missing or contradictory; or the selected proof path cannot support the claimed result.

## Validation

- `rg -n "Trace category|Process role|Atomic direct execution|stays outside|implemented|partial|auto-verify: run|auto-verify: skipped|execution-workflow|execution-contract|execution-topology|implementation-and-proof|execution-report|Agents: <count>|Stop Conditions" skills/102-sg-start/SKILL.md`
- `python3 -m unittest tools.test_102_sg_start_compaction_contract tools.test_master_delegation_contract tools.test_skill_selection_proportionality tools.test_reporting_contract`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
