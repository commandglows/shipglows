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

No mode or `mode=standard` selects `standard` and makes no excellence claim. `mode=excellence` or an unambiguous natural-language request selects `excellence`: standard, then a fresh second pass. conflicting/unknown `mode=` values or unreliable scope stop as `not verified` or `blocked`; never guess.

```text
standard: Is this work proven enough to move forward?
excellence: Once readiness passes, what material quality gap remains?
```

## Verdict Precedence

- `verified`: standard métier and ship-readiness gates pass; no excellence claim.
- `verified_with_excellence_gaps`: standard readiness passes first; a material evidenced excellence gap has a bounded repair/owner route.
- `excellent`: standard readiness passes first, the fresh second pass is complete, and no material excellence gap remains.
- `partial`, `not verified`, and `blocked` take precedence over excellence verdicts; when one applies, `excellent` is forbidden.

`partial` means complete-looking implementation lacks proof (`102-sg-start: implemented` vs `103-sg-verify: partial`). Route gaps with owner, proof type, scenario and target; unknown hosted targets go to `405-sg-prod`; hosted/provider gaps use `$SHIPGLOWS_ROOT/skills/references/preview-proof-routing.md`.

## Progressive Verification Packs

Central identity/consent/access proof loads `$SHIPGLOWS_ROOT/skills/references/identity-consent-access-contract.md`; actual Auth0 proof loads `$SHIPGLOWS_ROOT/skills/references/auth0-integration-playbook.md`. Email-work-routing selects Postmark/newsletter proof only for those surfaces, never unrelated auth/email fields.

Local leaves never chain. `references/verification-gates.md` is only a compatibility index.

- Load `$SHIPGLOWS_ROOT/skills/103-sg-verify/references/verification-baseline.md` and `$SHIPGLOWS_ROOT/skills/references/decision-quality-contract.md` for every run; its `Decision Quality Baseline` applies in every mode.
- Only after standard readiness passes, load `$SHIPGLOWS_ROOT/skills/103-sg-verify/references/verification-excellence.md` for the detailed excellence pass; `Excellence Focus Verdict` applies only when the selected mode is `excellence`.
- Security/data, UI/visual, runtime, auth/browser, hosted, Sentry, or device proof loads `$SHIPGLOWS_ROOT/skills/103-sg-verify/references/verification-security-ui-runtime.md`, then only applicable `$SHIPGLOWS_ROOT/skills/references/owasp-application-security-awareness.md`, `design-system-token-contract.md`, `sentry-observability.md`, and `runtime-diagnostics-surface.md`. Managed app launch/restart/reuse, backend-dependent tests, or Flutter, Android, or Windows desktop proof also loads `$SHIPGLOWS_ROOT/skills/references/agent-runtime-awareness.md` before choosing target and lane; Flutter proof mapping uses `flutter-quality-playbook.md`, Astro site proof uses `astro-site-playbook.md`.
- Docs/closure/tracker, skill, Atlas, product, editorial, language, dependency, or cross-contract coherence loads `$SHIPGLOWS_ROOT/skills/103-sg-verify/references/verification-coherence.md`, then applicable `$SHIPGLOWS_ROOT/skills/references/product-decision-chain.md`, `$SHIPGLOWS_ROOT/skills/references/content-quality-rubric.md`, and `$SHIPGLOWS_ROOT/skills/references/atlas-protection-preflight.md`.
- Bug/manual or CI/workflow scope loads `references/verification-release-proof.md` or `references/verification-ci.md` respectively.
- A `Capability Delta` or `specs/capabilities/` scope loads `references/living-spec-conformance.md`: verify code against the living spec too.

Conditional shared gates load from `$SHIPGLOWS_ROOT/skills/references/` for named scopes: `project-delivery-policy.md`, `project-development-mode.md`, `documentation-freshness-gate.md`, `email-work-routing.md`, `spec-driven-development-discipline.md`, `task-application-loop.md`, `closure-archive-guard.md`, `documentation-reflection-gate.md`, and `zombies-edge-case-heuristic.md`; changed code adds `implementation-excellence-preflight.md` and `clean-code-quality-contract.md`. Delivery posture controls release safeguards; development mode controls evidence authority; neither waives remote persistence.

## Standard Contract

Verify outcome, completeness, correctness, coherence, dependencies, risks, and required manual rows. Required `NOT_RUN`, `FAIL`, or `BLOCKED` prevents clean verification without accepted exception or stronger proof.

Always report `Success Behavior`, `Error Behavior`, `Proof Path Fit`, development/validation surface, fresh-docs verdict, documentation coherence, bug gate, and `Decision Quality Baseline`.

Report applicable named gates: `Task Application Loop Fit`, `Closure Archive Guard Fit`, `Structure Replacement Fit`, `Fast Fix Shortcut Gate`, `Clean Code Gate` pass/partial/fail/not applicable, `Implementation Excellence Gate` pass/partial/fail/not applicable, `OWASP Security Gate` pass/partial/fail/not applicable, `UI Design-System Shortcut Gate`, `Design-System Drift Check`, `Flutter Mobile Proof Ladder`, `Runtime Diagnostics Gate`, `Operator Autonomy Gate`, `Atlas Protection Gate`, `Product Decision Chain`.

For changed code, independently reconstruct preflight scope and enforce it on the diff. Passing technical checks never substitutes for implementation-excellence, product, security, visual, hosted, manual, auth, device, or production proof.

## Owner Routing And Tracker Rule

Missing hosted/preview/production/browser/auth/manual proof routes to `005-sg-ship`, `405-sg-prod`, `108-sg-browser`, `109-sg-auth-debug`, or `107-sg-test`. Meaning or acceptance changes route to `100-sg-spec`; investigation routes to the matching specialist. Multi-owner or security-sensitive repair requires a ready spec.

Trackers are read-only: do not edit `TASKS.md`, `AUDIT_LOG.md`, or `PROJECTS.md`. Load `$SHIPGLOWS_ROOT/skills/references/operational-record-format.md` only to interpret them.

## Stop Conditions

Report `not verified` or `blocked` when scope/contract is unreliable; a high/critical bug remains open; required preview/hybrid, external, browser/auth, manual/device, production, or provider proof is missing; proof path and evidence disagree; closure/docs/tracker state overclaims completion; critical security/data/workflow risk is unproven; implementation bypasses root cause/ownership/durable structure; the excellence gate has a material gap; UI/visual work hides a defect with one-off hardcoded values; or changed UI files retain unresolved design-system drift.

## Chantier And Reporting

For one unique spec, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md`, read history/flow, append mode/result and update flow. Never rewrite or erase an earlier `verified` row for later excellence bounded follow-up. Without one unique spec, use `(local)`; write no spec.

Final reports load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`; failures also load `$SHIPGLOWS_ROOT/skills/references/actionable-failure-contract.md`. Use findings-first `report=user`; `report=agent` needs explicit detail/handoff. Show focus, verdict, proof limits and owner routes.

## Validation

Run focused scenarios, relevant checks, metadata lint, `skill_budget_audit.py`, and runtime sync. Green commands support only their exercised scope.
