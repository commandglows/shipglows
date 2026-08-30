---
name: 102-sg-start
description: "Execute ready specs or substantive local implementation tasks with guardrails."
argument-hint: <task description or TASKS.md item>
---

Primary artifact type: `specialist-workflow`.

## Canonical Paths

Load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` before ShipGlows-owned paths. Project artifacts resolve from project root.

## Chantier Tracking

Trace category: `obligatoire`.
Process role: `lifecycle`.

For one ready spec, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md`, preserve its history/flow, append the `102-sg-start` result, and update the flow. Without one unique spec, do not write a spec; use a `(local)` chantier header.

## Mission And Mode Detection

`102-sg-start` implements one bounded work item; it does not merely plan or claim verification, closure, commit, push, or ship.

Before classifying the request, load `$SHIPGLOWS_ROOT/skills/102-sg-start/references/execution-workflow.md`.

- Clear bounded direct execution with few enumerable actions/targets and no material directional choice stays outside `102-sg-start` unless explicitly invoked; execute it directly with focused proof.
- Clear bounded work uses `direct` mode with a silent mini-contract, regardless of local/remote location or model reasoning effort.
- Unknown outcomes, unbounded actions/targets, or work requiring material product, architecture, auth/data/migration/API/security, external-integration, or cross-domain direction uses `spec-first` and requires one matching `ready` spec.
- Missing or unready contract routes to `100-sg-spec` then `101-sg-ready`; do not write.

Before reading ShipGlows-owned references or running its tools, apply `$SHIPGLOWS_ROOT/skills/references/shipglows-owned-preflight.md`.

## Result And Auto-Verify Boundaries

`implemented` means planned code, docs, and tests in this skill's scope are complete. Use `partial` only when implementation itself is incomplete. Missing manual, hosted, production, Sentry, browser/auth, or device proof does not downgrade implementation; route that gap to `103-sg-verify partial` and avoid ship-ready wording. Broken local implementation checks remain `partial` or `blocked`.

Auto-verify may report `auto-verify: run` only at an explicit checkpoint when one ready spec owns the work, implementation and local checks pass, and all remaining proof is local, tool-backed, non-destructive, decision-free, and already defined. Report `auto-verify: skipped` with `owner_skill`, `scenario`, and `target_or_environment` whenever proof needs preview, production, auth/browser flow, Sentry, device/manual QA, secrets, commit, push, ship, provider action, data mutation, or another external side effect. Local auto-verify never runs `104-sg-end` or `005-sg-ship`; `001-sg-build` retains full lifecycle ownership.

## Progressive References

Load each local reference directly from this activation contract; local references never load one another.

- Before deriving an execution contract, load `references/execution-contract.md`.
- Before topology selection, load `references/execution-topology.md`, `decision-quality-contract.md`, `master-delegation-semantics.md`, and canonical model routing.
- Before first code write, load `implementation-excellence-preflight.md`; classify and emit its `🛡️ GARDE-FOUS` receipt. Load `$SHIPGLOWS_ROOT/skills/102-sg-start/references/implementation-and-proof.md` and directly applicable `task-application-loop.md`, `spec-driven-development-discipline.md`, `zombies-edge-case-heuristic.md`, `clean-code-quality-contract.md`, `design-system-token-contract.md`, or `owasp-application-security-awareness.md`.
- After approval, load `reporting-contract.md`; emit its start card once before substantive work. Before reporting, load `references/execution-report.md`; reuse it.

Conditional gates: PM2, docs, UI, diagnostics, records, Atlas, and operator evidence. Product decisions load `$SHIPGLOWS_ROOT/skills/references/product-decision-chain.md`; delivery decisions load `project-delivery-policy.md`. Before Git writes load `git-persistence-preflight.md`; development is never local-only.

## Execution Invariants

- Preserve the user-story outcome, spec/mini-contract, dependencies, invariants, linked systems, and chosen proof path.
- Before writing, resolve product/security/data/tenant/destructive/external-side-effect ambiguity; never substitute checkbox completion or the fastest patch for the accepted outcome.
- Execute bounded slices, preserve existing user changes, update durable progress only after completion, and stop when scope or authority expands.
- Passing technical checks never proves product, security, auth, hosted, production, manual, or device behavior.
- Preserve observable success/failure, documentation coherence, security controls, diagnostics, and design-system sources when applicable.
- Reclassify on scope growth; an unresolved final `Implementation Excellence Gate` prevents `implemented`.
- After milestone proof apply `git-milestone-delivery-contract.md` and `005-sg-ship checkpoint` before more writes.
- For executable work, retain the topology receipt and report `Agents: <count> · <mode>`; use the lowest-overhead capable topology, parallelize independent scopes only for net time/coverage gain, and require ready non-overlapping `Execution Batches` plus an integration owner for parallel writes.

## Stop Conditions

Stop as `blocked` or `rerouted` when no ready spec exists for non-trivial work; the contract lacks behavior, success/error, tasks, acceptance criteria, dependencies, or decisive constraints; authority or safety semantics remain ambiguous; implementation would miss the user outcome; required references are missing or contradictory; or the selected proof path cannot support the claimed result.

## Validation

- `rg -n "Trace category|Process role|Clear bounded direct execution|stays outside|implemented|partial|auto-verify: run|auto-verify: skipped|execution-workflow|execution-contract|execution-topology|implementation-and-proof|execution-report|Agents: <count>|Stop Conditions" skills/102-sg-start/SKILL.md`
- `python3 -m unittest tools.test_102_sg_start_compaction_contract tools.test_master_delegation_contract tools.test_skill_selection_proportionality tools.test_reporting_contract`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
