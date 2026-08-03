---
name: 004-sg-deploy
description: "Orchestrate release checks, ship, deploy, proof, and verify."
argument-hint: [optional: project, URL, --preview, --prod, skip-check, no-changelog]
---

Primary artifact type: `master-workflow`.

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/shipglows`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `obligatoire`.
Process role: `lifecycle`.

Before deploying a spec-first chantier, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md`, then read the spec's `Skill Run History` and `Current Chantier Flow` when a unique spec exists. Append a current `004-sg-deploy` row with result `deployed`, `partial`, `blocked`, or `rerouted`, update `Current Chantier Flow`, and open the report with the opening chantier header from `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

If no unique chantier spec is identified, do not write to a spec; use a `(local)` chantier header with a short work name.

## Report Modes

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, evidence-first, and using the opening chantier header. Blocked user reports remain plain-language and end with safe recovery choices. For `report=agent` or explicit handoff, use `$SHIPGLOWS_ROOT/skills/004-sg-deploy/references/deploy-report-template.md`.

## Mission

`004-sg-deploy` is the release confidence orchestrator.

It answers one operational question:

```text
What bounded release scope should be shipped and proven now, and what proof owners must run before we can trust that release?
```

It runs the release path:

```text
scope -> 105-sg-check -> 005-sg-ship -> 405-sg-prod -> 108-sg-browser/109-sg-auth-debug/107-sg-test -> 103-sg-verify -> 304-sg-changelog
```

The goal is fewer manual commands, not fewer gates. `004-sg-deploy` must not treat a passing check, pushed commit, deployment status, or `200 OK` as proof that the release works.

## Scope Gate

Orchestrate existing skills; do not duplicate their internals.

- `105-sg-check` owns typecheck, lint, build, tests, and optional repair.
- `005-sg-ship` owns staging, commit, push, and pre-ship bug risk.
- `405-sg-prod` owns deployment discovery, provider state, build logs, runtime logs, live health, Sentry runtime correlation when configured, and Blacksmith Run History/Logs/Metrics/SSH escalation.
- `108-sg-browser` owns non-auth page-level browser proof after the deployment URL is known.
- `109-sg-auth-debug` owns login, OAuth, cookies, sessions, callbacks, tenants, and protected-route proof.
- `107-sg-test` owns guided manual QA, durable `shipglows_data/workflow/TEST_LOG.md`, bug files under `shipglows_data/workflow/bugs/*.md`, and optional `shipglows_data/workflow/BUGS.md` triage updates.
- `103-sg-verify` owns final user-story and coherence verification.
- `304-sg-changelog` owns release-note generation.

Route back before continuing when implementation scope is still unsettled:

- new feature or product change still needs build ownership -> `001-sg-build`
- project upkeep or broad maintenance triage still dominates -> `002-sg-maintain`
- one bug lifecycle still dominates the risk story -> `003-sg-bug`

Route to a narrower skill instead of continuing when the user clearly asks only for commit/push, deployed state/logs, one page assertion, auth diagnosis, or durable manual QA.

## Mode Detection

Before parsing an explicit invocation, load `$SHIPGLOWS_ROOT/skills/references/skill-invocation-preflight.md`; invalid or ambiguous preflight never activates this skill.

Parse `$ARGUMENTS`:

- empty -> deploy the current project and current bounded release scope.
- `skip-check` -> skip `105-sg-check` only; keep ship, prod, proof, and verify gates explicit.
- `no-changelog` -> skip the optional changelog route.
- `--preview` -> prefer preview/staging deploy proof.
- `--prod` -> prefer production deploy proof and keep destructive/manual test steps read-only unless approved.
- URL -> use it as the deploy or browser-proof target after checking whether `405-sg-prod` still needs to confirm deployment truth.
- project name -> pass it to `405-sg-prod` and any downstream proof skill.

If one narrower ask is already the whole job, do not keep the operator inside `004-sg-deploy`.

When the operator asks for a deploy-target recommendation rather than release proof on an already chosen target, use `skills/references/deploy-target-matrix.md` as the canonical advisory source. Keep the answer explicit that ShipGlows is advising only and that the final target still depends on project context.

## Required References

Load before execution:

- `$SHIPGLOWS_ROOT/skills/references/master-delegation-semantics.md`
- `$SHIPGLOWS_ROOT/skills/references/master-workflow-lifecycle.md`
- `$SHIPGLOWS_ROOT/skills/references/project-development-mode.md`
- `$SHIPGLOWS_ROOT/skills/references/deploy-target-matrix.md`
- `$SHIPGLOWS_ROOT/skills/references/preview-proof-routing.md`
- `$SHIPGLOWS_ROOT/skills/004-sg-deploy/references/release-confidence-workflow.md`
- `$SHIPGLOWS_ROOT/skills/004-sg-deploy/references/release-proof-routing.md`

Load conditionally:

- `$SHIPGLOWS_ROOT/skills/references/actionable-failure-contract.md` before reporting any failure state.
- `$SHIPGLOWS_ROOT/skills/references/sentry-observability.md` when Sentry evidence, runtime errors, 5xx, auth/payment/data flows, jobs, webhooks, or visible post-deploy errors affect release confidence.
- `$SHIPGLOWS_ROOT/shipglows_data/technical/blacksmith.md` when deploy, APK, AAB, or release artifacts are built through GitHub Actions on Blacksmith runners.
- `$SHIPGLOWS_ROOT/skills/004-sg-deploy/references/deploy-report-template.md` for detailed reports, blocked runs, or explicit handoff.

## Gate Order

Follow the local workflow reference and keep this gate order visible:

1. Scope and risk gate.
2. `105-sg-check nofix`, unless `skip-check` is present.
3. `005-sg-ship [bounded release scope]`.
4. `405-sg-prod [project or URL]`.
5. Proof routing through `108-sg-browser`, `109-sg-auth-debug`, or `107-sg-test`.
6. `103-sg-verify [spec or release scope]`.
7. `304-sg-changelog`, unless `no-changelog` is present or the release is not verified.

Delegated sequential execution is the default when subagents are available. Parallel release work remains blocked unless a ready spec defines safe `Execution Batches`.

## Stop Conditions

Stop and report `blocked` when:

- release scope is ambiguous
- checks fail and the user did not request a force-through path
- `005-sg-ship` blocks or push fails
- deployment state cannot be matched to the shipped commit/branch
- `405-sg-prod` reports failed, pending-timeout, or partial deployment truth
- required browser/auth/manual proof is missing
- `103-sg-verify` fails
- public docs or support copy are known stale for the changed behavior
- the release would include unrelated dirty files without explicit approval
- logs or screenshots would expose secrets or private data
- the requested action would mutate production data without explicit approval

## Validation

Required release proof:

- commit SHA, branch, ship mode, and target environment recorded after ship
- deployment URL and provider/build/runtime state confirmed before browser/auth/manual proof
- required browser/auth/manual evidence collected or explicitly reported as missing
- final `103-sg-verify` verdict recorded before any `deployed` claim
- changelog route run or explicitly skipped by `no-changelog`, internal-only scope, or partial/blocked verdict

Maintenance validation for this skill contract:

```bash
python3 tools/shipglows_metadata_lint.py skills/004-sg-deploy/references/*.md
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
rg -n "^(## Canonical Paths|## Chantier Tracking|## Report Modes|## Mission|## Scope Gate|## Mode Detection|## Required References|## Gate Order|## Stop Conditions|## Validation)" skills/004-sg-deploy/SKILL.md
```

## Rules

- Keep release truth evidence-based.
- Prefer blocking over overstating readiness.
- Use existing skills for implementation, ship, deploy, and proof internals.
- Temporary build outputs, caches, and preview leftovers used for local release proof are disposable unless the task explicitly requires a durable project artifact.
- Never print secrets, cookies, tokens, private headers, raw sensitive logs, raw Sentry payloads, breadcrumbs, replay contents, private URLs, or PII.
