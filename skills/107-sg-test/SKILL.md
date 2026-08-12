---
name: 107-sg-test
description: "Guide manual QA, log evidence, and update bug records."
argument-hint: "[--local|--preview|--prod|--retest BUG-ID] [flow, URL, or spec]"
---

## Canonical Paths

Load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` before ShipGlows-owned files. Project evidence resolves under the current project governance root.

## Chantier And Reporting

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

Attach to one unique spec when present; otherwise use `(local)`. Apply `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md` for trace or `Chantier potentiel`, and `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md` before the final report.

## Mission

`107-sg-test` runs one guided manual QA campaign, records actual evidence in `shipglows_data/workflow/TEST_LOG.md`, updates a durable `BUG-*.md` on failure/retest, and routes the result. One-off non-auth browser proof without durable QA records belongs to `108-sg-browser`.

## Evidence Truth Gate

Never invent test results. If neither this run's tooling nor the operator observed the behavior, status is `not run`.

Do not log pass/fail before the operator answers unless direct tool/browser evidence was collected in this run. Technical checks never impersonate required human validation. Ask only for genuinely manual/device/account/external evidence after exhausting safe agent-runnable diagnostics under `$SHIPGLOWS_ROOT/skills/references/decision-quality-contract.md`.

## Mode And Environment

Parse empty/recent scope, free text, `--local`, `--preview`, `--prod`, `--retest BUG-ID`, URL/route, or spec path. If the exact flow is unclear, ask one targeted question.

Before selecting proof, load `$SHIPGLOWS_ROOT/skills/references/project-development-mode.md` and inspect project `CLAUDE.md`/`SHIPGLOWS.md`. Preview-push changed behavior and hosted-only hybrid flows apply `$SHIPGLOWS_ROOT/skills/references/preview-proof-routing.md`; local proof there is explicitly non-authoritative. Missing deploy target routes to `405-sg-prod`; auth/session/provider/protected-route proof routes to `109-sg-auth-debug`.

## Progressive QA Packs

Local packs load directly and never chain. `$SHIPGLOWS_ROOT/skills/107-sg-test/references/manual-qa-workflow.md` is a compatibility index only.

- After scope/environment selection, load `$SHIPGLOWS_ROOT/skills/107-sg-test/references/qa-scenario-and-prompt.md` to build and present the focused protocol.
- Only after user/tool evidence exists, load `$SHIPGLOWS_ROOT/skills/107-sg-test/references/qa-records-and-routing.md` before durable writes, bug transitions, and the final report.

Load at most one local pack before the first substantive action.

## Scenario Contract

Use, in order: matching ready spec, bug record for retest, generated manual checklist, recent relevant diff/commits/tasks, then docs that clarify expected behavior. A declared checklist is authoritative and parsed with `$SHIPGLOWS_ROOT/tools/shipglows_checklist_status.py`.

Extract entry point, success/error behavior, environment, risky edge, constraints, and required evidence. Non-trivial behavior loads `$SHIPGLOWS_ROOT/skills/references/zombies-edge-case-heuristic.md`; several letters may share a scenario, because coverage matters more than seven ceremonial tests.

Email content, received rendering, delivery/authentication, provider events, or agent-triggered email loads `$SHIPGLOWS_ROOT/skills/references/email-work-routing.md` before defining proof. A ShipGlows-managed PM2 restart, crash loop, or `.shipglows.env` recovery loads `$SHIPGLOWS_ROOT/skills/references/project-runtime-policy.md` before naming expected recovery behavior.

Normal flow: `generate protocol -> collect evidence -> log evidence -> route next step`.

## Durable And Security Boundaries

`TEST_LOG.md` stores compact scenario history and pointers, never long logs. Failure or retest updates `shipglows_data/workflow/bugs/BUG-ID.md`; optional `BUGS.md` changes only when it already exists or the project workflow generates it.

Redact tokens, cookies, headers, private payloads/emails, PII, HAR, and sensitive screenshots. Large redacted evidence goes under `test-evidence/BUG-ID/`. Never commit or push.

On a crash, error boundary, 5xx, runtime exception, or visible support/Sentry event, load `$SHIPGLOWS_ROOT/skills/references/runtime-diagnostics-surface.md` and `$SHIPGLOWS_ROOT/skills/references/sentry-observability.md` before recording evidence. Collect safe reachable diagnostics before asking the operator.

Allowed transitions: `open -> needs-info|needs-repro`; `open|fix-attempted -> fixed-pending-verify` only after passing retest; failed retest returns to `open`. Never mark `closed` directly; `closed-without-retest` requires explicit visible reason and residual risk.

## Stop Conditions

Stop when expected behavior materially changes product/security/data/money/permissions/destructive effects; required preview/hosted target is unavailable; user/tool evidence is absent; required checklist rows remain unresolved; or evidence cannot be stored safely after redaction.

## Final Report

Before evidence, output only the manual test card. After evidence and durable writes, report the observed result, environment, record status, proof limit, and next action in the user's language. Do not claim closed/verified/shipped.

## Validation

Run `tools/test_107_sg_test_compaction_contract.py`, ZOMBIES, proof consumers, metadata, budget, and runtime-sync checks.
