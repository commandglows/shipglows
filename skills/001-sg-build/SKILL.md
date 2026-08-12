---
name: 001-sg-build
description: "Orchestrate story-to-ship product implementation."
argument-hint: "[spark|codex|mini|agents|sous-agent|no-agents] <story, bug, or goal>"
---

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/.shipglows/runtime`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Public Métier Ownership

Public label: `sg-development`. Load `$SHIPGLOWS_ROOT/skills/references/intent-to-outcome-autonomy.md` before clarification or lifecycle selection. Resolve `project -> product -> surface -> feature`; then keep outcome ownership across spec, readiness, implementation, proof, documentation, closure, and authorized ship/deploy stages without asking the operator to schedule internal skills.

## Chantier Tracking

Trace category: `obligatoire`.
Process role: `lifecycle`.

Before executing, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md`. If exactly one chantier spec is in scope, read `Skill Run History` and `Current Chantier Flow`, append a current `001-sg-build` row with result `implemented`, `partial`, `blocked`, or `rerouted`, update `Current Chantier Flow`, and open with the opening chantier header from `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`. If no unique spec exists, do not write to a spec and use a `(local)` chantier header with a short work name.

## Report Modes

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, outcome-first, and using the opening chantier header. Use `report=agent` only when explicitly requested or when `001-sg-build` is preparing an internal handoff for another agent. When invoking downstream skills for internal evidence, pass `report=agent` or `handoff` only when detailed evidence is needed.

## Master Delegation

Before choosing execution topology, load `$SHIPGLOWS_ROOT/skills/references/master-delegation-semantics.md`.

This skill owns end-to-end lifecycle orchestration through `104-sg-end` and `005-sg-ship`, with `main-only`, `delegated sequential`, `read-only parallel`, and `spec-gated parallel` as reportable execution modes.

`spark`, `codex`, `mini`, `agents`, `subagent`, and `sous-agent` force delegated sequential execution; if unavailable for file work or validation, stop/report degraded. They never mean parallel execution.

## Master Workflow Lifecycle

Before resolving lifecycle gates, load `$SHIPGLOWS_ROOT/skills/references/master-workflow-lifecycle.md`.

Use the shared skeleton for intake, work item resolution, readiness, model/topology routing, execution through owner skills, validation, verification, and post-verify closure/ship. Local sections below define `001-sg-build` routes and stop conditions only.

Before choosing a route, model, topology, mini-contract, or implementation path, load `$SHIPGLOWS_ROOT/skills/references/decision-quality-contract.md`. When an owner handoff or fix is itself a failure finding, load `$SHIPGLOWS_ROOT/skills/references/actionable-failure-contract.md` and choose the most specific owner route before implementation.

## Required References

Load `$SHIPGLOWS_ROOT/skills/001-sg-build/references/build-lifecycle-workflow.md` for the detailed execution-mode playbook, question framing, governance/documentation gates, browser evidence routing, onboarding gate, and final report templates.

Before applying any named operator profile semantics in `$ARGUMENTS`, load `$SHIPGLOWS_ROOT/skills/references/profile-activation.md` and follow its canonical resolution, precedence, fallback, reporting, and project-context rules.

Before the Blueprint Gate, load `$SHIPGLOWS_ROOT/skills/references/preferred-stacks.md`, then `$SHIPGLOWS_ROOT/skills/references/app-blueprints.md`.

Before asking a user-facing question, load `$SHIPGLOWS_ROOT/skills/references/question-contract.md`.

Before deciding whether the operator should be asked for business, product, audience, or framing input, load `$SHIPGLOWS_ROOT/skills/references/operator-partnership-contract.md`.

Before `102-sg-start`, load `$SHIPGLOWS_ROOT/skills/704-sg-model/references/model-routing.md` and choose model profile based on complexity, ambiguity, failure cost, expected duration, and topology.

Before UI, mobile, component, layout, typography, spacing, color, shadow/elevation, motion, safe-area, keyboard/IME, overlay, responsive, token, theme, or visual proof work, load `$SHIPGLOWS_ROOT/skills/references/design-system-token-contract.md` and route design-system changes through the canonical token/theme/component source.

When a product change creates or changes email copy, templates, transactional flows, provider delivery, or agent-operated mail, load `$SHIPGLOWS_ROOT/skills/references/email-work-routing.md` and only the references it selects.

## Mission

`001-sg-build` is the user-facing lifecycle orchestrator (`master-workflow`) and keeps user interaction high level while executing:

`intake -> existing chantier check -> greenfield platform footprint -> preferred stack preset -> blueprint gate -> remaining greenfield technology decision -> spec/readiness loop -> governance corpus gate -> model routing gate -> start -> verify -> end -> ship`

It answers one operational question:

```text
What product change should be built now, and how do we carry that story from scope to verified ship without losing lifecycle discipline?
```

The objective is an excellent professional lifecycle that removes manual detours while preserving quality, security, performance, durability, and proof.

When the operator asks to create or change a product, continue through every
agent-runnable lifecycle stage. Do not stop after a spec, governance bootstrap,
or readiness finding and make the operator infer a technical next command.
Ask only for a material operator-owned decision or an external/safety approval;
otherwise resolve the next owner route and continue it.
If `governance corpus state is missing, stale, or materially insufficient`, invoke internal
`300-sg-docs update` directly and continue the same run after completion.

Generated artifacts used only for local proof are disposable unless the task explicitly requires a durable project artifact. Remove temporary build outputs, caches, and preview leftovers after the proof completes.

`102-sg-start` may continue into local, bounded verification when safe, but that is an implementation-side optimization only. Full lifecycle ownership (`103-sg-verify` routing, `104-sg-end`, and `005-sg-ship`) remains with `001-sg-build`.

Keep the boundary explicit: `001-sg-build` owns feature and product-change lifecycle orchestration, not existing-project upkeep triage, one-bug loop ownership, or deploy-only release proof after implementation is already settled.

## Explicit Invocation Preflight

Before parsing an explicit invocation, load `$SHIPGLOWS_ROOT/skills/references/skill-invocation-preflight.md`; invalid or ambiguous preflight never activates this skill.

## Execution Modes

- `main-only`: only for pure conversational output, explicit planning without mutation, or an explicit no-subagent request.
- `delegated sequential` (default): `/001-sg-build <story>` or `$001-sg-build <story>` is bounded delegation consent for the current chantier; run one bounded implementation/validation owner at a time.
- `read-only parallel`: default when at least two independent reconnaissance or evidence scopes can be assigned no-write batches; create the selected batch matrix and integrate the results.
- `spec-gated parallel`: execute non-overlapping write batches in parallel when a ready spec defines safe `Execution Batches`; otherwise write work stays delegated sequential.

When a named profile is active, let it shape route choice, sequencing, and answer framing for the current turn without bypassing lifecycle gates, proof owners, or stop conditions.

For executable work, retain a delegation receipt and report `Agents: <count> · <mode>`. Add a degradation reason when capability affects trust, coverage, timing, or proof. `Agents: not needed` is reserved for pure conversation or decision framing.

## Existing Chantier Check

Before creating any spec:

1. Search active specs in `specs/*.md` and `shipglows_data/workflow/specs/*.md` as allowed by the project layout.
2. Compare user story, expected result, linked systems, impacted files/surfaces, and `Current Chantier Flow`.
3. Prefer continuing the matching active spec.
4. Create a new spec only when promise or outcome is genuinely new.
5. If multiple specs are plausible, ask a user decision instead of guessing.

## Blueprint Gate

After work item resolution, before spec creation:

1. Apply the Greenfield Platform Footprint Rule from `$SHIPGLOWS_ROOT/skills/references/question-contract.md`; do not infer that responsive web excludes native mobile apps.
2. Load `$SHIPGLOWS_ROOT/skills/references/preferred-stacks.md` and apply compatible operator-approved presets.
3. Load `$SHIPGLOWS_ROOT/skills/references/app-blueprints.md`.
4. Read the registry at `$SHIPGLOWS_ROOT/skills/app-blueprints/README.md` for platform-compatible candidate matches.
5. For each candidate, resolve the blueprint: check local cache first, then clone from `source.repo` if set.
6. If matched, load the blueprint into the active context and pass it to downstream skills without silently overriding an accepted preset.
7. If a candidate fits the platforms but not the product archetype, use it only as a stack/conventions reference.
8. If no match, proceed without a blueprint.
9. If multiple blueprints match, ask the user to choose.

The blueprint pre-fills architecture, stack, models, routes, and conventions for `100-sg-spec` and `306-sg-scaffold`. It is not a substitute for a spec — it is a starting skeleton.

In the final report, add `Blueprint: [id] (version) — resolved from [local | cloned from <url>]` when used.

## Spec And Readiness Loop

For a greenfield product with material technology choices not covered by an
accepted preferred preset or blueprint, apply the Greenfield Technology Decision Rule from
`$SHIPGLOWS_ROOT/skills/references/question-contract.md` before allowing the
spec to freeze architecture, hosting, data, payment, or material provider
choices. Present one researched recommendation at the product-consequence
level and ask one bundled numbered decision; keep low-level implementation
choices agent-owned.

For non-trivial work, run or route through `100-sg-spec`, then `101-sg-ready`, and do not run `102-sg-start` until the spec is `ready`. If readiness fails, apply one correction pass and rerun readiness; stop after the bounded loop with `blocked` or a user decision.

For trivial and local work that is safe without a full spec, allow a direct mini-contract only when the decision-quality contract is satisfied.

When the chosen workflow schema requires more than one artifact before implementation, keep creating the remaining required artifacts in order until the work is truly apply-ready. Do not stop after the first valid spec if the schema still requires design, tasks, or another prerequisite artifact for the same change.

## Proof Owner Routing

Do not treat browser/manual proof as generic:

- `108-sg-browser`: non-auth browser evidence.
- `109-sg-auth-debug`: auth/session/callback/cookie/provider/tenant/protected-route issues.
- `405-sg-prod`: hosted deployment/runtime truth, logs, serverless/edge behavior, or live deployment health.
- `107-sg-test`: durable manual QA scripts, retests, and structured test logs.

In `vercel-preview-push` or preview-required `hybrid` mode, ship first, then route to `405-sg-prod`, then to the downstream proof owner.

If the dominant job is not product implementation lifecycle, route early instead of staying in `001-sg-build`:

- existing-project upkeep, dependency/docs/security cleanup, or broad maintenance backlog -> `002-sg-maintain`
- one bug work item with its own evidence/fix/retest loop -> `003-sg-bug`
- bounded release confidence for already-implemented work -> `004-sg-deploy`
- direct narrow proof only -> `107-sg-test`, `108-sg-browser`, `109-sg-auth-debug`, or `405-sg-prod`

## Stop Conditions

Stop and ask or reroute when:

- spec ownership is ambiguous
- a matched blueprint contradicts the user's explicit requirement (ask before overriding)
- readiness does not pass
- requested parallel writes have no ready safe `Execution Batches`
- file ownership overlaps in a parallel plan
- subagent mode was requested but unavailable or not applied for file work, validation, closure, or ship preparation
- governance corpus state is missing/stale and unresolved
- a missing operator-owned business, audience, or framing fact materially changes behavior and no safe default exists
- a greenfield technology direction would set material ongoing cost, control, maintenance, portability, or provider lock-in without operator agreement
- a greenfield platform footprint that changes credible framework or architecture options has been assumed, or a major platform has been placed out of scope without operator evidence
- a change would alter existing behavior without explicit decision
- proposed execution would act as a quick-fix shortcut instead of preserving root cause, owner routing, shared structure, and proof
- proposed UI/design execution would add or tolerate visual values outside the centralized design-system source without drift-check evidence and a named exception
- permission/data/security semantics remain ambiguous
- docs freshness is required and unresolved
- verification is insufficient for the promised user outcome
- ship scope includes unrelated dirty files and user did not authorize it

## Final Report

Apply `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`. The default user-facing report is concise; the detailed phase report is reserved for `report=agent`, blocked runs, or explicit handoff. Use `build-lifecycle-workflow.md` for the full user-mode and agent-mode templates.

## Rules

- Orchestrate; do not duplicate every atomic skill.
- Preserve user changes and avoid unrelated refactors.
- Keep technical and editorial coherence gates explicit.
- Follow `$SHIPGLOWS_ROOT/skills/references/master-delegation-semantics.md`.
- Do not commit or push directly from `001-sg-build`; delegate closure and ship through `104-sg-end` and `005-sg-ship`.
- Do not make the user manually run `104-sg-end` or `005-sg-ship` after successful verification unless a named stop condition blocks automatic orchestration.
- Treat `102-sg-start` auto-verify as an allowed local optimization only; do not interpret it as automatic completion of lifecycle orchestration.

## Validation

Validate this skill after edits with:

- `rg -n "Trace category|Process role|Master Delegation|Master Workflow Lifecycle|Existing Chantier Check|Greenfield Platform Footprint|Greenfield Technology Decision|Stop Conditions|Final Report|build-lifecycle-workflow" skills/001-sg-build/SKILL.md`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `python3 -m unittest tools.test_master_delegation_contract`
- `python3 tools/shipglows_metadata_lint.py skills/001-sg-build/references/build-lifecycle-workflow.md`
