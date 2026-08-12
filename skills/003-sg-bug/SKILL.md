---
name: 003-sg-bug
description: "Intake, fix, retest, and ship bugs."
argument-hint: [optional: BUG-ID | bug summary | --fix BUG-ID | --retest BUG-ID | --verify BUG-ID | --ship BUG-ID]
---

Primary artifact type: `master-workflow`.

## Canonical Paths

Load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` before resolving ShipGlows-owned files. `$SHIPGLOWS_ROOT` defaults to `$HOME/.shipglows/runtime`; project artifacts resolve from the current project root.

## Public Métier Ownership

Public label: `sg-bug`. Load `$SHIPGLOWS_ROOT/skills/references/intent-to-outcome-autonomy.md` before clarification or lifecycle routing. Resolve `project -> product -> surface -> feature` and retain ownership through proportional proof and authorized closure or ship.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

Load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md` before reporting when exactly one spec-first chantier owns the run. Otherwise use a `(local)` chantier header and do not mutate a spec. Apply its chantier-potential threshold when the bug reveals non-trivial future work not already owned by a chantier.

## Report Modes

Load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md` before reporting. Default to concise, outcome-first `report=user`; use `report=agent` only for an explicit handoff or detailed request. Blocked user reports stay plain-language and offer safe recovery choices.

## Mission

`003-sg-bug` owns one bug work item's lifecycle and answers: what is its real state, and what is the next safe action toward verified ship?

```text
intake -> 107-sg-test -> bug file -> 106-sg-fix -> 107-sg-test --retest -> 103-sg-verify -> 005-sg-ship
```

It interprets state, selects proof, delegates each phase to its owner, integrates evidence, and continues while safe. It does not own generic maintenance, direct code repair, or broad release orchestration; route those to `002-sg-maintain`, `001-sg-build`, or `004-sg-deploy` respectively.

## Ownership Boundaries

- `107-sg-test`: reproduction, durable bug record, manual QA, and retest.
- `106-sg-fix`: diagnosis and repair.
- `109-sg-auth-debug`: auth, session, callback, cookie, tenant, and protected-route evidence.
- `108-sg-browser`: narrow non-auth browser evidence.
- `103-sg-verify`: closure and remaining-risk verification.
- `005-sg-ship`: bounded commit and push.
- `003-sg-bug`: one-bug state interpretation, safety gates, topology, routing, continuation, and final integration.

Do not repair code or write bug records directly in this master thread. Use the phase owner. Stop with a next command only when an actual stop condition, unavailable proof surface, missing approval, unavailable agent, or explicit user request prevents continuation.

## Required References

Always load `$SHIPGLOWS_ROOT/skills/references/skill-invocation-preflight.md` before parsing explicit input.

Load at most one local playbook before the first substantive action:

- Bug selection, bug-file/index reconciliation, or lifecycle-state interpretation -> `$SHIPGLOWS_ROOT/skills/003-sg-bug/references/bug-state-routing.md`.
- Missing evidence, reproduction, proof-path, diagnostics, or development-mode decision -> `$SHIPGLOWS_ROOT/skills/003-sg-bug/references/bug-evidence-routing.md`.
- `--verify`, `--ship`, `--close`, or closure-risk reporting -> `$SHIPGLOWS_ROOT/skills/003-sg-bug/references/bug-closure-playbook.md`.

Load `$SHIPGLOWS_ROOT/skills/references/master-delegation-semantics.md` only before choosing execution topology. Load `$SHIPGLOWS_ROOT/skills/references/master-workflow-lifecycle.md` before interpreting durable bug state. Load `$SHIPGLOWS_ROOT/skills/references/spec-driven-development-discipline.md` before fix, retest, verification, or closure claims.

A missing required playbook blocks its mode. Local playbooks map to shared doctrine; they do not replace it or chain to another local playbook.

## Mode Detection

- empty -> inspect canonical bug files and recommend or continue the highest-priority safe action.
- one `BUG-ID` -> read its bug file first, interpret state, and continue safely.
- free text -> route an observed failure to `107-sg-test`, a narrow actionable repair to `106-sg-fix`, or an ambiguous product contract to `100-sg-spec`.
- `--fix BUG-ID` -> require the bug file, then delegate to `106-sg-fix`.
- `--retest BUG-ID` -> delegate to `107-sg-test --retest`.
- `--verify BUG-ID` -> delegate to `103-sg-verify`.
- `--ship BUG-ID` -> apply the ship gate before delegating to `005-sg-ship`.
- `--close BUG-ID` -> require passing retest evidence or an explicit `closed-without-retest` exception.

Malformed input never activates a mode. If multiple bug IDs are present, ask which one to handle first unless the user explicitly requested a read-only dashboard.

## Lifecycle Gates

The bug file under `shipglows_data/workflow/bugs/*.md` is authoritative; an optional `BUGS.md` index never overrides it.

- `open`, `needs-repro`, `needs-info`, `in-diagnosis` -> gather missing proof or diagnose before closure.
- `fix-attempted` -> retest; repeated attempts without root-cause evidence require deeper diagnosis.
- `fixed-pending-verify` -> verify before closure or clean ship.
- `closed`, `duplicate`, `wontfix` -> no repair; preserve canonical linkage or decision.
- `closed-without-retest` -> expose residual risk and retest when confidence matters.

For user-visible visual bugs, preserve `evidence -> fix-attempted -> retest -> fixed-pending-verify -> verify`. Technical checks may support `implemented`, but must not call it resolved, fixed, verified, or closed until a person validates the rendered result. A minor exception may waive only the durable bug file, never this proof route.

High or critical bugs in `open`, `needs-info`, `needs-repro`, `in-diagnosis`, or `fix-attempted` block clean shipping. Medium or low unresolved bugs require explicit partial-risk wording. User acceptance of partial-risk ship never closes the bug.

## Security And Evidence Gate

Never print or persist raw secrets, tokens, cookies, keys, auth headers, private payloads, production PII, raw Sentry data, replay contents, or sensitive screenshots. Keep only redacted pointers and short summaries; reject evidence paths containing `..`. UI visibility is not authorization.

Before declaring `needs-info`, gather all safe agent-accessible evidence. Ask the operator only for a real decision, credential, unavailable environment, manual-only proof, or unsafe action.

## Stop Conditions

Stop and report `blocked` when:

- the BUG-ID is malformed, missing, or too inconsistent for safe routing;
- required evidence or a required local/shared reference is unavailable;
- closure lacks passing retest evidence and no explicit valid exception exists;
- evidence is sensitive and unredacted;
- production or destructive mutation lacks explicit approval;
- clean ship is requested while a high/critical bug remains unresolved;
- required preview proof has not followed the project preview route.

## Final Report

In user mode, report observable state, compact proof, and only material risk under the shared chantier/verdict header. Keep internal owners, commands, paths, and lifecycle mechanics out of the user report. Add the chantier-potential decision required by chantier tracking.

In `report=agent`, include BUG-ID, durable record, classification, development mode, proof path, redacted diagnostics, security posture, internal route, lifecycle state, remaining evidence, and exact next command.

## Validation

After edits, run the owner contract, visual-proof contract, master-delegation contract, reporting contract, skill audit, budget audit, and runtime sync check.

## Rules

- Execute through owner skills and bounded agents; never overstate closure from intent, code diff, checks, or deployment alone.
- Parallelize independent read-only evidence by default; mutations remain sequential unless a ready spec defines non-overlapping write batches.
- Continue the next safe lifecycle action instead of handing agent-runnable work back to the operator.
- Ask only when the answer changes severity, state, destructive risk, closure, or ship risk.
- Do not commit or push.
