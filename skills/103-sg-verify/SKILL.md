---
name: 103-sg-verify
description: "Verify ship readiness or run an excellence-focused second pass."
argument-hint: "[mode=standard|mode=excellence] [task or scope]"
---

Primary artifact type: `specialist-workflow`.

## Activation And Ownership

Resolve ShipGlows files from `$SHIPGLOWS_ROOT` (default `$HOME/.shipglows/runtime`) after loading `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md`. Apply `shipglows-owned-preflight.md` before its references, tools, runtime, or sync targets.

Trace category: `obligatoire`.
Process role: `lifecycle`.

`103-sg-verify` owns the verdict, not implementation (`102-sg-start`), closure (`104-sg-end`), shipping (`005-sg-ship`), or redesign. It may repair a bounded local issue only when the correct result is clear.

## Mode Detection

No mode or `mode=standard` selects `standard`: verify métier correctness, contract, proof, risk, and ship readiness; success makes no excellence claim. `mode=excellence` or an unambiguous natural-language request for an excellence pass selects `excellence`: run standard first, then a fresh second pass. conflicting/unknown `mode=` values or unreliable scope stop as `not verified` or `blocked`; do not guess.

Questions answered:

```text
standard: Is this work proven enough to move forward, and who owns missing proof?
excellence: Once readiness passes, what material quality gap remains, and who owns follow-up?
```

## Verdict Precedence

- `verified`: standard métier and ship-readiness gates pass; no excellence claim.
- `verified_with_excellence_gaps`: standard readiness passes first; a material evidenced excellence gap has a bounded repair/owner route.
- `excellent`: standard readiness passes first, the fresh second pass is complete, and no material excellence gap remains.
- Proof, correctness, security, and blocking-risk verdicts (`partial`, `not verified`, `blocked`) take precedence over excellence verdicts; when one applies, `excellent` is forbidden.

`partial` means implementation appears complete but required proof is missing. Never downgrade completed implementation semantics solely for incomplete verification: keep `102-sg-start: implemented` vs `103-sg-verify: partial`. Route every gap with owner, proof type, scenario, and target/environment when known; unknown hosted target routes to `405-sg-prod` for discovery. Hosted/provider gaps also apply `preview-proof-routing.md`.

## Progressive Verification Packs

Load local references directly; they never load one another. `references/verification-gates.md` is a compatibility index only.

- After scope and mode selection, load `references/verification-baseline.md` for every run plus `decision-quality-contract.md`. Its `Decision Quality Baseline` applies in every mode.
- Only after standard readiness passes in excellence mode, load `references/verification-excellence.md` for the detailed excellence pass and `Excellence Focus Verdict`; excellence verdicts apply only when the selected mode is `excellence`.
- Load `references/verification-security-ui-runtime.md` only for internet-facing/privileged, security/data, UI/mobile/visual, runtime, auth/browser, hosted, Sentry, or device proof. Then load only applicable shared contracts: `owasp-application-security-awareness.md`, `design-system-token-contract.md`, `sentry-observability.md`, `runtime-diagnostics-surface.md`.
- Load `references/verification-coherence.md` only for documentation/closure/tracker, skill contracts, Atlas, product decisions, editorial scores, language, dependencies, or cross-contract coherence. Then load only applicable shared contracts: `$SHIPGLOWS_ROOT/skills/references/product-decision-chain.md`, `content-quality-rubric.md` for editorial scoring, and `atlas-protection-preflight.md` for an Atlas registry.

Conditional shared gates load directly: `project-development-mode.md` whenever readiness depends on local, preview, or hybrid proof; `documentation-freshness-gate.md` for external behavior; `email-work-routing.md` when acceptance covers email copy/templates/rendering/delivery/auth/provider events/operations; `spec-driven-development-discipline.md` for behavior/proof; `task-application-loop.md` for progress; `closure-archive-guard.md` for closure; `documentation-reflection-gate.md` for milestone completion; `zombies-edge-case-heuristic.md` for non-trivial behavior; `clean-code-quality-contract.md` for changed code.

## Standard Contract

Verify user-story outcome, completeness, correctness, coherence, dependencies, risks, and required manual rows. Required `NOT_RUN`, `FAIL`, or `BLOCKED` rows prevent clean verification unless an explicit accepted exception or stronger proof artifact exists.

Always report `Success Behavior`, `Error Behavior`, `Proof Path Fit`, development/validation surface, fresh-docs verdict, documentation coherence, bug gate, and `Decision Quality Baseline`.

When applicable report these mechanically named gates:

- `Task Application Loop Fit` and `Closure Archive Guard Fit`
- `Structure Replacement Fit` and `Fast Fix Shortcut Gate`
- `Clean Code Gate` pass/partial/fail/not applicable
- `OWASP Security Gate` pass/partial/fail/not applicable
- `UI Design-System Shortcut Gate`, `Design-System Drift Check`, `Flutter Mobile Proof Ladder`
- `Runtime Diagnostics Gate`, `Operator Autonomy Gate`, `Atlas Protection Gate`, `Product Decision Chain`

Passing technical checks never substitutes for product, security, visual, hosted, manual, auth, device, or production proof.

## Owner Routing And Tracker Rule

Missing hosted/preview/production/browser/auth/manual proof routes to `005-sg-ship`, `405-sg-prod`, `108-sg-browser`, `109-sg-auth-debug`, or `107-sg-test` with scenario and target. Product meaning or acceptance changes route to `100-sg-spec` (optionally `700-sg-explore`); design, copy, code/security, or performance investigation routes to the matching specialist. Multi-owner or security-sensitive repair requires the ready-spec lifecycle.

Trackers are read-only: do not edit `TASKS.md`, `AUDIT_LOG.md`, or `PROJECTS.md`. Tracker/spec operational records may use `operational-record-format.md` as reader context; exceptional summary repair belongs to its owner.

## Stop Conditions

Report `not verified` or `blocked` when scope/contract is unreliable; a high/critical bug remains open; required preview/hybrid, external, browser/auth, manual/device, production, or provider proof is missing; proof path and evidence disagree; closure/docs/tracker state overclaims completion; critical security/data/workflow risk is unproven; implementation bypasses root cause/ownership/durable structure; UI/visual work hides a defect with one-off hardcoded values; or changed UI files retain unresolved design-system drift.

## Chantier And Reporting

For one unique spec, load `chantier-tracking.md`, read history/flow, append the current `103-sg-verify` mode and result without rewriting earlier rows, update flow, and use the opening chantier header. Never rewrite or erase an earlier `verified` row when a later excellence pass opens bounded follow-up. Without one unique spec, do not write a spec; use `(local)`.

Before the final report load `reporting-contract.md`; failures also load `actionable-failure-contract.md`. Default to concise findings-first `report=user`; use `report=agent` for handoff, blocked, or explicit detail. Make selected focus, verdict, evidence limits, and concrete owner routes visible.

## Validation

Run focused scenario contracts, relevant technical/proof checks, metadata lint for changed refs, `skill_budget_audit.py`, and the runtime sync check. A green command supports only the scope it actually exercised.
