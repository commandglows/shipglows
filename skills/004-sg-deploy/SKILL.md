---
name: 004-sg-deploy
description: "Orchestrate release checks, ship, deploy, proof, and verify."
argument-hint: [optional: project, URL, --preview, --prod, skip-check, no-changelog]
---

Primary artifact type: `master-workflow`.

## Canonical Paths

Load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` before ShipGlows-owned files. Project artifacts resolve from the current project root.

## Public Métier, Chantier, And Reporting

Public label: `sg-release`. Load `$SHIPGLOWS_ROOT/skills/references/intent-to-outcome-autonomy.md` before clarification or release routing. Resolve `project -> product -> surface -> feature` and own one bounded release through checks, ship authorization, deployment truth, proof, verification, and closure.

Trace category: `obligatoire`. Process role: `lifecycle`. Attach to one unique spec when present and apply `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md`; otherwise use `(local)`. Load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md` before the final report. Blocked user reports remain plain-language and offer only safe recovery choices. Detailed handoff loads `$SHIPGLOWS_ROOT/skills/004-sg-deploy/references/deploy-report-template.md`.

## Mission And Scope Gate

`004-sg-deploy` answers: what bounded scope can be shipped and proven now? It orchestrates existing owners and never treats a green check, push, deploy status, or `200 OK` as product proof.

Route narrower requests directly: checks `105`, commit/push `005`, deployed state/logs `405`, non-auth browser `108`, auth/session `109`, durable manual QA `107`, verification `103`, changelog `304`. Route unsettled feature scope to `001`, maintenance dominance to `002`, and one dominant defect to `003`.

## Mode Detection And Preflight

Before explicit invocation, load `$SHIPGLOWS_ROOT/skills/references/skill-invocation-preflight.md`. Parse empty/current scope, `skip-check`, `no-changelog`, `--preview`, `--prod`, URL, or project name. `skip-check` skips only `105`; all later gates remain. Production proof is read-only unless mutation is explicitly approved.

A deploy-target recommendation loads `$SHIPGLOWS_ROOT/skills/references/deploy-target-matrix.md` and remains advisory. Before choosing local/preview/hybrid/production proof, load `$SHIPGLOWS_ROOT/skills/references/project-development-mode.md`; hosted proof loads `$SHIPGLOWS_ROOT/skills/references/preview-proof-routing.md`.

## Progressive Release Packs

The accounting profile lives in `skill-invocation-registry.json`; runtime loaders here remain authoritative. Local packs load directly and never chain.

- After scope, target, and risk are known, load `$SHIPGLOWS_ROOT/skills/004-sg-deploy/references/release-confidence-workflow.md`.
- After `405` confirms deployment truth, load `$SHIPGLOWS_ROOT/skills/004-sg-deploy/references/release-proof-routing.md`.
- Only after a multi-stage release route is selected, load `$SHIPGLOWS_ROOT/skills/references/master-workflow-lifecycle.md` and `$SHIPGLOWS_ROOT/skills/references/master-delegation-semantics.md`.

Load at most one local playbook before the first substantive action.

Conditional authorities: `actionable-failure-contract.md` for failure reports; `sentry-observability.md` for runtime/Sentry evidence; `owasp-application-security-awareness.md` for internet-facing or privileged change; `email-work-routing.md` for sending/provider mutation; `shipglows_data/technical/blacksmith.md` for Blacksmith-built release artifacts.

## Gate Order And Verdict Boundary

Keep this order: bounded scope/risk → `105-sg-check nofix` unless skipped → `005-sg-ship` → `405-sg-prod` → required `108`/`109`/`107` proof → `103-sg-verify` → optional `304-sg-changelog`.

Record commit/branch/ship mode, matching target URL/provider state, objective-matched proof, verification verdict, and changelog decision. Missing deployment or required proof keeps the result `partial` or `blocked`; never claim `deployed` before final verification.

Independent read-only release/CI/runtime evidence may parallelize under the shared matrix. Ship, deploy, tracker, and production mutations remain sequential unless ready non-overlapping `Execution Batches` exist.

## Safety And Stop Conditions

Stop for ambiguous scope; unrelated dirty files; failed checks without authorized skip; blocked ship/push; unmatched, failed, pending, or partial deployment truth; unresolved high/critical release risk; missing browser/auth/manual proof; failed verification; stale public docs; secret/private evidence exposure; production data mutation without approval; or missing required pack/target.

Never print secrets, cookies, tokens, credentials, private headers/payloads/URLs, raw HAR/Sentry/runtime logs, production PII, or sensitive screenshots. Unsafe proof reroutes to a safe environment, explicit approval, or manual evidence.

## Validation

Run `tools/test_004_sg_deploy_compaction_contract.py`, delegation/reporting/OWASP consumers, activation-profile audit, metadata, fidelity, budget, and runtime sync.
