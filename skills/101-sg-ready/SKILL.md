---
name: 101-sg-ready
description: "Validate spec readiness, user-story fit, and secure scope."
argument-hint: "<spec path or task name>"
---

Primary artifact type: `specialist-workflow`.

## Canonical Paths

Load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` before resolving ShipGlows-owned files. Project artifacts resolve from the current project root.

## Chantier And Reporting

Trace category: `obligatoire`.
Process role: `lifecycle`.

For one unique spec, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md`, append a `101-sg-ready` result (`ready`, `not ready`, or `blocked`), and update `Current Chantier Flow`. Load `$SHIPGLOWS_ROOT/skills/references/operational-record-format.md` before mutating a `spec:` summary line. Before reporting load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`; default to concise verdict-first `report=user` and keep full checklists in `report=agent`.

## Mission

`101-sg-ready` decides whether one existing spec is safe for `102-sg-start`. It owns readiness and scope integrity, not implementation, proof completion, closure, or shipping.

## Scope Gate

Resolve exactly one spec from a path or task/title. If none or several remain plausible, report `not ready` and route to explicit selection or `100-sg-spec`; do not infer from conversation history. Bounded metadata/status/trace mutation is allowed. Generic planning and product discovery are rejected.

## Progressive Readiness Packs

Local packs load directly and never chain. `$SHIPGLOWS_ROOT/skills/101-sg-ready/references/readiness-review-playbook.md` is a compatibility index only.

- Every resolved spec loads `$SHIPGLOWS_ROOT/skills/101-sg-ready/references/readiness-baseline.md`.
- Load `$SHIPGLOWS_ROOT/skills/101-sg-ready/references/readiness-risk-review.md` only for adversarial, security/data, product, platform, Atlas, UI, dependency, or external-behavior risk.
- After the verdict is determined, load `$SHIPGLOWS_ROOT/skills/101-sg-ready/references/readiness-transition-and-report.md` before any status/metadata/trace mutation or report.

Load at most one local pack before the first substantive decision.

## Conditional Authorities

Load `$SHIPGLOWS_ROOT/skills/references/product-decision-chain.md` for product decisions. Load applicable `$SHIPGLOWS_ROOT/skills/references/documentation-freshness-gate.md`, `$SHIPGLOWS_ROOT/skills/references/preferred-stacks.md`, `$SHIPGLOWS_ROOT/skills/references/atlas-protection-preflight.md`, `$SHIPGLOWS_ROOT/skills/references/design-system-token-contract.md`, and `$SHIPGLOWS_ROOT/skills/references/owasp-application-security-awareness.md`. Inspect project `CLAUDE.md`/`SHIPGLOWS.md`; ShipGlows contract/copy work also reads `shipglows_data/technical/guidelines.md` when present.

Load `$SHIPGLOWS_ROOT/skills/references/context-quality-contract.md` when target/outcome authority, freshness, conflict, memory, or handoff sufficiency is material. A `context_partial`, `context_conflict`, or `context_stale` gap that affects implementation prevents `ready`.

For a material adopted-repository spec, obtain or refresh one bounded capsule through `301-sg-context` before the substantive verdict. Preserve its evidence states and fallback gaps; a small exact spec may use the cheaper targeted path.

## Readiness Verdict

A spec is `ready` only when a fresh agent can implement it without blocking ambiguity, generous inference, missing proof, hidden linked-system consequences, or unresolved security/product/platform decisions.

Keep these gates local:

- required structure, autonomous user-story and observable success/error contracts;
- ordered actionable tasks, acceptance criteria, proof path, proportional ZOMBIES coverage, risks, linked consequences, docs coherence, and execution notes;
- greenfield platform footprint before narrowing a new application to one mobile or browser target, and compatible preferred stacks before blueprint/provider commitment;
- operator agreement for material cost/control/maintenance/portability/lock-in choices;
- product/Atlas/design authority and preserved dimensions when affected;
- an applicable `OWASP Security Gate` for internet-facing or privileged work;
- current official/primary evidence when freshness applies.

Small later verification deltas may receive a bounded mini-readiness check from `103-sg-verify`; this does not transfer initial readiness ownership.

## Stop Conditions

Report `not ready` or `blocked` when the spec is not unique; a required section, proof contract, consequence, documentation gate, or material behavior/security decision is missing; platform exclusions are inferred; a compatible preset is ignored; an operator-owned technology choice is frozen silently; or a fresh agent would need conversation history or optimistic assumptions.

## Validation

- Run `tools/test_101_sg_ready_compaction_contract.py` plus reporting, OWASP, guided-product, metadata, budget, and runtime-sync checks.
- A mechanical pass cannot override a substantive `not ready` finding.
