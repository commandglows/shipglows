---
name: 103-sg-verify
description: "Verify ship readiness or run an excellence-focused second pass."
argument-hint: "[mode=standard|mode=excellence] [task or scope]"
---

Primary artifact type: `specialist-workflow`.

## Activation And Ownership

Load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` before ShipGlows-owned paths.

Trace category: `obligatoire`.
Process role: `lifecycle`.

`103-sg-verify` owns verdicts, not implementation (`102-sg-start`), closure (`104-sg-end`), shipping (`005-sg-ship`), or redesign.

## Mode Detection

No mode or `mode=standard` selects `standard` and makes no excellence claim: verify métier correctness, contract, proof, risk, and ship readiness. `mode=excellence` or an unambiguous natural-language request selects `excellence`: run standard, then a fresh second pass. conflicting/unknown `mode=` values or unreliable scope stop as `not verified` or `blocked`; do not guess.

```text
standard: Is this work proven enough to move forward, and who owns missing proof?
excellence: Once readiness passes, what material quality gap remains, and who owns follow-up?
```

## Verdict Precedence

- `verified`: standard métier and ship-readiness gates pass; no excellence claim.
- `verified_with_excellence_gaps`: standard readiness passes first; a material evidenced excellence gap has a bounded repair/owner route.
- `excellent`: standard readiness passes first, the fresh second pass is complete, and no material excellence gap remains.
- Proof, correctness, security, and blocking-risk verdicts (`partial`, `not verified`, `blocked`) take precedence over excellence verdicts; when one applies, `excellent` is forbidden.

`partial` means implementation appears complete but proof is missing. Preserve `102-sg-start: implemented` vs `103-sg-verify: partial`. Route every gap with owner, proof type, scenario, and target/environment; unknown hosted targets route to `405-sg-prod`. Hosted/provider gaps apply `$SHIPGLOWS_ROOT/skills/references/preview-proof-routing.md`.

## Progressive Verification Packs

Local leaves never chain. `references/verification-gates.md` is only a compatibility index.

- Load `$SHIPGLOWS_ROOT/skills/103-sg-verify/references/verification-baseline.md` and `$SHIPGLOWS_ROOT/skills/references/decision-quality-contract.md` for every run; its `Decision Quality Baseline` applies in every mode.
- Only after standard readiness passes, load `$SHIPGLOWS_ROOT/skills/103-sg-verify/references/verification-excellence.md` for the detailed excellence pass; `Excellence Focus Verdict` applies only when the selected mode is `excellence`.
- For security/data, UI/visual, runtime, auth/browser, hosted, Sentry, or device proof, load `$SHIPGLOWS_ROOT/skills/103-sg-verify/references/verification-security-ui-runtime.md`, then only applicable `$SHIPGLOWS_ROOT/skills/references/owasp-application-security-awareness.md`, `$SHIPGLOWS_ROOT/skills/references/design-system-token-contract.md`, `$SHIPGLOWS_ROOT/skills/references/sentry-observability.md`, and `$SHIPGLOWS_ROOT/skills/references/runtime-diagnostics-surface.md`. Flutter, Android, or Windows desktop proof also loads `$SHIPGLOWS_ROOT/skills/references/agent-runtime-awareness.md` before selecting the active target and proof lane.
- For docs/closure/tracker, skill, Atlas, product, editorial, language, dependency, or cross-contract coherence, load `$SHIPGLOWS_ROOT/skills/103-sg-verify/references/verification-coherence.md`, then applicable `$SHIPGLOWS_ROOT/skills/references/product-decision-chain.md`, `$SHIPGLOWS_ROOT/skills/references/content-quality-rubric.md`, and `$SHIPGLOWS_ROOT/skills/references/atlas-protection-preflight.md`.
- For bug/manual or CI/workflow scope, load `$SHIPGLOWS_ROOT/skills/103-sg-verify/references/verification-release-proof.md` or `$SHIPGLOWS_ROOT/skills/103-sg-verify/references/verification-ci.md` respectively.

Conditional shared gates load from `$SHIPGLOWS_ROOT/skills/references/`: `project-delivery-policy.md`, `project-development-mode.md`, `documentation-freshness-gate.md`, `email-work-routing.md`, `spec-driven-development-discipline.md`, `task-application-loop.md`, `closure-archive-guard.md`, `documentation-reflection-gate.md`, and `zombies-edge-case-heuristic.md` for named scopes; `implementation-excellence-preflight.md` and `clean-code-quality-contract.md` for changed code. Delivery posture controls release safeguards; development mode controls evidence authority; neither waives remote persistence.

## Standard Contract

Verify outcome, completeness, correctness, coherence, dependencies, risks, and required manual rows. Required `NOT_RUN`, `FAIL`, or `BLOCKED` prevents clean verification without accepted exception or stronger proof.

Always report `Success Behavior`, `Error Behavior`, `Proof Path Fit`, development/validation surface, fresh-docs verdict, documentation coherence, bug gate, and `Decision Quality Baseline`.

When applicable report these mechanically named gates:

- `Task Application Loop Fit` and `Closure Archive Guard Fit`
- `Structure Replacement Fit` and `Fast Fix Shortcut Gate`
- `Clean Code Gate` pass/partial/fail/not applicable
- `Implementation Excellence Gate` pass/partial/fail/not applicable
- `OWASP Security Gate` pass/partial/fail/not applicable
- `UI Design-System Shortcut Gate`, `Design-System Drift Check`, `Flutter Mobile Proof Ladder`
- `Runtime Diagnostics Gate`, `Operator Autonomy Gate`, `Atlas Protection Gate`, `Product Decision Chain`

For changed code, independently reconstruct preflight scope and enforce it on the diff. Passing technical checks never substitutes for implementation-excellence, product, security, visual, hosted, manual, auth, device, or production proof.

## Owner Routing And Tracker Rule

Missing hosted/preview/production/browser/auth/manual proof routes to `005-sg-ship`, `405-sg-prod`, `108-sg-browser`, `109-sg-auth-debug`, or `107-sg-test`. Meaning or acceptance changes route to `100-sg-spec`; investigation routes to the matching specialist. Multi-owner or security-sensitive repair requires a ready spec.

Trackers are read-only: do not edit `TASKS.md`, `AUDIT_LOG.md`, or `PROJECTS.md`. Load `$SHIPGLOWS_ROOT/skills/references/operational-record-format.md` only to interpret them.

## Stop Conditions

Report `not verified` or `blocked` when scope/contract is unreliable; a high/critical bug remains open; required preview/hybrid, external, browser/auth, manual/device, production, or provider proof is missing; proof path and evidence disagree; closure/docs/tracker state overclaims completion; critical security/data/workflow risk is unproven; implementation bypasses root cause/ownership/durable structure; the excellence gate has a material gap; UI/visual work hides a defect with one-off hardcoded values; or changed UI files retain unresolved design-system drift.

## Chantier And Reporting

For one unique spec, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md`, read history/flow, append the current mode/result without rewriting earlier rows, and update flow. Never rewrite or erase an earlier `verified` row when a later excellence pass opens bounded follow-up. Without one unique spec, do not write a spec; use `(local)`.

Before the final report load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`; failures also load `$SHIPGLOWS_ROOT/skills/references/actionable-failure-contract.md`. Default to concise findings-first `report=user`; use `report=agent` for handoff, blocked, or explicit detail. Make focus, verdict, evidence limits, and concrete owner routes visible.

## Validation

Run focused scenarios, relevant checks, metadata lint, `skill_budget_audit.py`, and runtime sync. Green commands support only their exercised scope.
