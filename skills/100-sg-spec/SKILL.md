---
name: 100-sg-spec
description: "Write specs with user stories, contracts, risks, and plans."
argument-hint: "[optional: description de ce qu'on veut construire]"
---

Primary artifact type: `master-workflow`.

## Canonical Paths

Load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` before resolving ShipGlows-owned files. Project artifacts resolve from the current project root.

## Chantier And Reporting

Trace category: `obligatoire`.
Process role: `lifecycle`.

For a spec-first chantier, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md`; initialize `created_at`, `updated_at`, `source_model`, `Skill Run History`, and `Current Chantier Flow`. Preserve a supplied `Chantier potentiel` intake. Before the final report load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`. Default to concise `report=user`; detailed contract evidence belongs to `report=agent`.

## Mission

`100-sg-spec` creates or repairs one durable implementation contract. It owns spec quality and chantier initialization, not readiness approval, implementation, verification, closure, or shipping.

## Scope Gate

- New non-trivial work or a `Chantier potentiel` creates/updates a durable spec.
- Blueprint intake uses its explicit blueprint before project-specific authoring.
- Small deterministic work with no durable coordination value uses `(local)` and routes directly.
- Missing actor, trigger, result, scope, security/data policy, or operator-owned business/product truth requires one targeted question.

Never create process weight that does not reduce ambiguity, coordination friction, or maintenance burden.

## Progressive Spec Packs

Local packs load directly and never chain. `$SHIPGLOWS_ROOT/skills/100-sg-spec/references/spec-creation-workflow.md` is a compatibility index only.

- For durable spec work, first load `$SHIPGLOWS_ROOT/skills/100-sg-spec/references/spec-intake-and-investigation.md`.
- After the intake is decision-complete, load `$SHIPGLOWS_ROOT/skills/100-sg-spec/references/spec-contract-authoring.md`.
- After a complete draft exists, load `$SHIPGLOWS_ROOT/skills/100-sg-spec/references/spec-review-and-persistence.md` for adversarial review, persistence, and reporting.

Load at most one local pack before the first substantive decision.

## Conditional Authorities

Always apply `$SHIPGLOWS_ROOT/skills/references/decision-quality-contract.md`. Before a material operator question load `$SHIPGLOWS_ROOT/skills/references/question-contract.md` and `$SHIPGLOWS_ROOT/skills/references/operator-partnership-contract.md`. Product decisions load `$SHIPGLOWS_ROOT/skills/references/product-decision-chain.md`.

Load exact applicable authorities: `$SHIPGLOWS_ROOT/skills/references/design-system-token-contract.md`, `$SHIPGLOWS_ROOT/skills/references/documentation-freshness-gate.md`, `$SHIPGLOWS_ROOT/skills/references/app-blueprints.md`, `$SHIPGLOWS_ROOT/skills/references/preferred-stacks.md`, `$SHIPGLOWS_ROOT/skills/references/atlas-cartography-lifecycle.md`, `$SHIPGLOWS_ROOT/skills/references/zombies-edge-case-heuristic.md`, and `$SHIPGLOWS_ROOT/skills/references/owasp-application-security-awareness.md`.

When a material application journey, navigation model, common interaction, onboarding, recovery path, or visual direction needs external experience evidence, load `$SHIPGLOWS_ROOT/skills/references/ux-reference-intelligence.md` and the shared `$SHIPGLOWS_ROOT/skills/references/ux-reference-connectors.md`. Persist only selected observations and product-native principles; source catalogs and checklists never become requirements by themselves.

Use `$SHIPGLOWS_ROOT/shipglows_data/technical/product-behavior-intelligence.md` for activation, retention, behavioral analytics, or product-usage GTM proof; `$SHIPGLOWS_ROOT/skills/references/sentry-observability.md` for runtime specs; and `$SHIPGLOWS_ROOT/skills/references/operational-record-format.md` before a `spec:` summary mutation. Before editing this skill, use `$SHIPGLOWS_ROOT/skills/references/skill-instruction-layering.md`.

## Contract Invariants

- A fresh agent can implement the ready spec without conversation history: user story, minimal behavior, success/error behavior, scope, ordered tasks, acceptance criteria, proof, risks, links, docs, and execution notes are explicit.
- Non-trivial behavior retains compact `ZOMBIES coverage`; irrelevant categories state why they are not applicable.
- Product-facing work names governed truth, canonical public URLs, delivery model, affected decision/Atlas IDs, `before → after`, preserved invariants, and claim-proof obligations when applicable.
- UI work names design-system authority and its validation path before implementation.
- Greenfield work records platform footprint, applies compatible preferred stacks, and obtains operator agreement only for material uncovered technology choices.
- Internet-facing or privileged work retains an `OWASP Security Gate`; auth, tenant, data, money, destructive, public-claim, and external-doc ambiguities resolve before readiness.
- The spec is durable and autonomous, contains no `TBD`, and never edits `TASKS.md`, `AUDIT_LOG.md`, or legacy `PROJECTS.md`.

## Stop Conditions

Stop when a material product, platform, security, data, tenant, external-side-effect, provider-lock-in, or workflow-integrity decision is missing; the requested tasks do not satisfy the user story; a required authority is missing/contradictory; or the final contract would rely on hidden assumptions or untestable acceptance criteria.

## Validation

- Run `tools/test_100_sg_spec_compaction_contract.py` plus reporting, OWASP, ZOMBIES, guided-product, metadata, budget, and runtime-sync checks.
- A passing structural check never proves spec content ready; `101-sg-ready` owns that verdict.
