---
name: 001-sg-build
description: "Orchestrate story-to-ship product implementation."
argument-hint: "[spark|codex|mini|agents|sous-agent|no-agents] <story, bug, or goal>"
---

## Canonical Paths

Before resolving ShipGlows-owned files, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/.shipglows/runtime`). Project artifacts resolve from the current project root.

## Public Métier Ownership

Public label: `sg-development`. `001-sg-build` owns product-change orchestration from outcome intake through readiness, implementation, proof, documentation, closure, and authorized ship. It does not own existing-project upkeep (`002-sg-maintain`), a single bug loop (`003-sg-bug`), already-implemented release confidence (`004-sg-deploy`), or narrow proof (`107-sg-test`, `108-sg-browser`, `109-sg-auth-debug`, `405-sg-prod`).

Load `$SHIPGLOWS_ROOT/skills/references/intent-to-outcome-autonomy.md` before clarification or lifecycle selection. Keep interaction outcome-level; do not ask the operator to schedule internal owners.

## Chantier And Reporting

Trace category: `obligatoire`.
Process role: `lifecycle`.

Before execution, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md`. Continue one matching active spec and update its history/flow; without a unique spec, do not write one and use a `(local)` chantier header. Before the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`. Default `report=user` is concise and outcome-first; detailed internal evidence is `report=agent` or handoff only.

## Mission And Early Route

Answer: what product change should be built now, and how is it carried to verified ship without losing lifecycle discipline?

Before parsing an explicit invocation, load `$SHIPGLOWS_ROOT/skills/references/skill-invocation-preflight.md`; invalid or ambiguous preflight never activates this skill.

Before selecting the route, load `$SHIPGLOWS_ROOT/skills/001-sg-build/references/build-lifecycle-workflow.md`. Check existing chantier ownership before creating a spec. Route dominant maintenance, bug, release, or proof work early; do not load greenfield or delivery packs for an early reroute.

For a product change, continue every safe agent-runnable stage. Do not stop after spec, governance bootstrap, readiness, implementation, or verification and make the operator infer the next internal command. Ask only for a material operator decision or external/safety approval.

## Delegation And Lifecycle Policy

Before topology selection, load `$SHIPGLOWS_ROOT/skills/references/master-delegation-semantics.md`, `$SHIPGLOWS_ROOT/skills/references/master-workflow-lifecycle.md`, and `$SHIPGLOWS_ROOT/skills/references/decision-quality-contract.md`.

`main-only` is conversational/no-agent work. `no-agents` selects main-only/no-subagent execution when compatible, but never bypasses lifecycle, readiness, proof, or ship gates. Delegated sequential is the mutation default. Two or more independent read-only scopes use `read-only parallel`; parallel writes require a ready spec with non-overlapping `Execution Batches` and one integration owner. `spark`, `codex`, `mini`, `agents`, `subagent`, and `sous-agent` force delegated sequential execution; unavailable requested delegation reports degraded or stops. Retain a receipt and report `Agents: <count> · <mode>`.

## Progressive Route Packs

Local references are loaded directly here and never chain locally.

- For a greenfield product only, load `$SHIPGLOWS_ROOT/skills/001-sg-build/references/build-greenfield-route.md`; resolve platform footprint, preferred stack, blueprint, and material technology decisions before freezing the spec.
- After route selection and before implementation readiness, load `$SHIPGLOWS_ROOT/skills/001-sg-build/references/build-readiness-route.md` for spec/readiness, governance, documentation, profiles, questions, and model gates.
- Once the contract is ready, load `$SHIPGLOWS_ROOT/skills/001-sg-build/references/build-delivery-route.md` for `102-sg-start`, proof ownership, verification, onboarding, closure, and ship.

Conditional shared loaders remain conditional: `$SHIPGLOWS_ROOT/skills/references/question-contract.md` and `$SHIPGLOWS_ROOT/skills/references/operator-partnership-contract.md` before a material question; `$SHIPGLOWS_ROOT/skills/references/profile-activation.md` for named profiles; `$SHIPGLOWS_ROOT/skills/references/design-system-token-contract.md` for UI; `$SHIPGLOWS_ROOT/skills/references/email-work-routing.md` for email work; `$SHIPGLOWS_ROOT/skills/references/actionable-failure-contract.md` for a failure handoff.

## Readiness And Proof Owners

Non-trivial work must pass `100-sg-spec -> 101-sg-ready` before `102-sg-start`; allow one bounded correction loop, otherwise stop. A trivial local mini-contract is allowed only when decision quality and safety are clear.

Proof routing remains explicit: `108-sg-browser` for non-auth browser evidence; `109-sg-auth-debug` for auth/session/provider/protected-route evidence; `405-sg-prod` for hosted runtime/deployment truth; `107-sg-test` for durable manual QA. Preview-required modes ship before hosted proof. `102-sg-start` local auto-verify is only an implementation optimization; `001-sg-build` still owns `103-sg-verify -> 104-sg-end -> 005-sg-ship`.

After verification passes, orchestrate `104-sg-end` and bounded `005-sg-ship`; never stage `all-dirty`/`ship-all` without explicit authority and never commit or push directly from this skill. Do not make the user manually run closure or ship after success unless a named stop condition blocks continuation.

## Stop Conditions

Stop, ask, or reroute for ambiguous spec ownership; failed readiness; overlapping or unprepared parallel writes; unavailable requested delegation; unresolved governance; material business/audience/product facts; permission/data/security ambiguity; changed behavior without decision; unresolved docs freshness; insufficient proof; unrelated dirty ship scope; blueprint conflict; or an assumed platform/technology choice that changes cost, control, portability, maintenance, provider lock-in, or supported platforms. UI work with design-system drift or a quick-fix shortcut also stops.

## Rules And Validation

Preserve user changes, root-cause quality, technical/editorial coherence, and authorized ship scope. Temporary proof artifacts are disposable unless explicitly durable.

- `python3 -m unittest tools.test_001_sg_build_compaction_contract tools.test_master_delegation_contract tools.test_reporting_contract`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `python3 tools/shipglows_metadata_lint.py skills/001-sg-build/references/*.md`
