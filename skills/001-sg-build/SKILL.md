---
name: 001-sg-build
description: "Orchestrate story-to-ship product implementation."
argument-hint: "[spark|codex|mini|agents|sous-agent|no-agents] <story, bug, or goal>"
---

## Canonical Paths

Before resolving ShipGlows-owned files, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/.shipglows/runtime`); project artifacts resolve from the project root. Bare shared-reference names below resolve under `$SHIPGLOWS_ROOT/skills/references/`.

## Public Métier Ownership

Public label: `sg-development`. `001-sg-build` owns product-change orchestration from intake through readiness, implementation, proof, docs, closure, and authorized ship. Upkeep is `002-sg-maintain`, one bug loop `003-sg-bug`, release confidence `004-sg-deploy`, narrow proof `107-sg-test`, `108-sg-browser`, `109-sg-auth-debug`, or `405-sg-prod`.

Before clarification or lifecycle selection, load `intent-to-outcome-autonomy.md`. Keep interaction outcome-level; never ask the operator to schedule internal owners.

## Chantier And Reporting

Trace category: `obligatoire`.
Process role: `lifecycle`.

Before execution, load `chantier-tracking.md`: continue one matching active spec and update its flow; without a unique spec, write none and use a `(local)` chantier header. Before the final report, load `reporting-contract.md`; `report=user` is concise and outcome-first, while detailed evidence is `report=agent` or handoff only.

## Mission And Early Route

Answer: which product change to build now, and how it reaches verified ship with lifecycle discipline.

Before parsing an explicit invocation, load `skill-invocation-preflight.md`; invalid or ambiguous preflight never activates this skill.

Before selecting the route, load `$SHIPGLOWS_ROOT/skills/001-sg-build/references/build-lifecycle-workflow.md`. Check chantier ownership before creating a spec; route dominant maintenance, bug, release, or proof work early, without greenfield or delivery packs.

For a product change, run every safe agent-runnable stage; never make the operator infer internal commands. Ask only for a material operator decision or external/safety approval. Once the chantier is validated, run spec -> ready -> start -> verify -> end -> milestone commits in one turn chain: no per-phase "ok", no stop on solvable obstacles (`mutation-plan-approval.md`, Approved chantier continuation).

## Delegation And Lifecycle Policy

Before topology selection, load `master-delegation-semantics.md`, `master-workflow-lifecycle.md`, and `decision-quality-contract.md`.

`main-only` is conversational/no-agent work. `no-agents` selects main-only/no-subagent execution when compatible, but never bypasses lifecycle, readiness, proof, or ship gates. Mutations default to delegated sequential execution. Two or more independent read-only scopes use `read-only parallel`; parallel writes require a ready spec with non-overlapping `Execution Batches` and one integration owner. `spark`, `codex`, `mini`, `agents`, `subagent`, and `sous-agent` force delegated sequential execution; unavailable requested delegation reports degraded or stops. Retain a receipt and report `Agents: <count> · <mode>`.

## Progressive Route Packs

Packs load directly from here and never chain.

- Greenfield product only: load `$SHIPGLOWS_ROOT/skills/001-sg-build/references/build-greenfield-route.md`; resolve platform footprint, preferred stack, blueprint, and material technology decisions before freezing the spec.
- After route selection, before implementation readiness: load `$SHIPGLOWS_ROOT/skills/001-sg-build/references/build-readiness-route.md` for spec, governance, docs, profiles, questions, and model gates.
- Once the contract is ready: load `$SHIPGLOWS_ROOT/skills/001-sg-build/references/build-delivery-route.md` for `102-sg-start`, proof, verification, onboarding, closure, and ship. Feature and refactor inherit `102-sg-start`'s pre-write classification, `🛡️ GARDE-FOUS` receipt, and final `Implementation Excellence Gate`; orchestration cannot bypass them.

Conditional loaders: `question-contract.md` and `operator-partnership-contract.md` before a material question; `profile-activation.md` for named profiles; `design-system-token-contract.md` for UI; `$SHIPGLOWS_ROOT/skills/references/email-work-routing.md` for email work; `actionable-failure-contract.md` for a failure handoff; `agent-runtime-awareness.md` before launching, restarting or reusing a managed app, selecting a backend-dependent test, or choosing build or proof lanes for Flutter, Android, Windows desktop, or Firebase Device Streaming, then apply its backend-information gate.

Before readiness, for an application change that materially changes a common journey, navigation, interaction, or visual direction, load `$SHIPGLOWS_ROOT/skills/references/ux-reference-intelligence.md` and `$SHIPGLOWS_ROOT/skills/references/ux-reference-connectors.md`; route observations to experience, design, and spec owners, never to implementation browsing.

For matching product work, load:`interactive-3d-experience-contract.md` for 3D/WebGL; `interactive-animation-runtime-contract.md` for animation runtimes; `web-image-performance-contract.md` for web images; `web-typography-contract.md` for fonts; `product-iconography-contract.md` for icons; `product-color-system-contract.md` for themes and semantic colors; `creative-asset-provenance-contract.md` when adopting or redistributing creative assets. Flutter, Astro, publishing, signed-in UI, heuristics, consent, and interface-voice loaders are listed in `build-readiness-route.md`.

## Readiness And Proof Owners

Central identity/consent/email integration: load `$SHIPGLOWS_ROOT/skills/references/identity-consent-access-contract.md` before selecting the service boundary; when the task changes or diagnoses the selected Auth0 integration, load `$SHIPGLOWS_ROOT/skills/references/auth0-integration-playbook.md` directly. Mere email fields or unrelated feature work do not activate these.

Non-trivial work must pass `100-sg-spec -> 101-sg-ready` before `102-sg-start`; allow one bounded correction loop, otherwise stop. A trivial local mini-contract is allowed only when decision quality and safety are clear.

Proof routing: `108-sg-browser` for non-auth browser evidence, `109-sg-auth-debug` for auth/session/provider/protected-route evidence, `405-sg-prod` for hosted runtime truth, `107-sg-test` for durable manual QA; preview-required modes ship before hosted proof. `102-sg-start` local auto-verify only optimizes implementation; `001-sg-build` still owns `103-sg-verify -> 104-sg-end -> 005-sg-ship`.

After verification passes, orchestrate `104-sg-end` and bounded `005-sg-ship`; never stage `all-dirty`/`ship-all` without explicit authority, and never commit or push directly from this skill. Closure and ship need no manual operator step unless a stop condition blocks them.

## Stop Conditions

Stop, ask, or reroute for ambiguous spec ownership; failed readiness; overlapping or unprepared parallel writes; unavailable requested delegation; unresolved governance; material business/audience/product facts; permission/data/security ambiguity; changed behavior without decision; unresolved docs freshness; insufficient proof; unrelated dirty ship scope; blueprint conflict; or an assumed platform/technology choice that changes cost, control, portability, maintenance, provider lock-in, or supported platforms. UI work with design-system drift or a quick-fix shortcut also stops.

## Rules And Validation

Preserve user changes, root-cause quality, technical/editorial coherence, and authorized ship scope. Temporary proof artifacts are disposable unless explicitly durable.

- `python3 -m unittest tools.test_001_sg_build_compaction_contract tools.test_master_delegation_contract tools.test_reporting_contract`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `python3 tools/shipglows_metadata_lint.py skills/001-sg-build/references/*.md`
