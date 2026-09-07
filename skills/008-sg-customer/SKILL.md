---
name: 008-sg-customer
description: "Customer journeys, activation, trust, and recovery through four explicit modes."
argument-hint: "<audit|flow|onboarding|recovery> <scope>"
---

## Canonical Paths

Load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (root defaults to `$HOME/.shipglows/runtime`). Shared names resolve under `$SHIPGLOWS_ROOT/skills/references/`; `references/` is engine-local.

## Ownership

`sg-experience`. Load shared `intent-to-outcome-autonomy.md` before clarification/routing: `project -> business/brand/product -> outcome -> surface -> work item`. Own diagnosis through collaboration, behavioral proof and closure.

## Layering

Before edits, load shared `skill-instruction-layering.md`; procedure belongs in playbooks.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

For one unique active owning spec, load shared `chantier-tracking.md` and use its trace/header; otherwise no spec. Non-trivial source changes require `/100-sg-spec`.

## Report Modes

Before reporting load shared `reporting-contract.md`. Default `report=user`; `report=agent`, `handoff`, `verbose`, `full-report` allow full contract/routing evidence.

## Modes

Load shared `skill-invocation-preflight.md` before invocation; invalid/ambiguous preflight blocks activation. One playbook:

| Invocation | Primary playbook |
| --- | --- |
| `008-sg-customer audit [scope]` | `references/customer-audit-playbook.md` |
| `008-sg-customer flow [feature-or-flow]` | `references/customer-flow-playbook.md` |
| `008-sg-customer onboarding [feature-or-flow]` | `references/onboarding-playbook.md` |
| `008-sg-customer recovery [feature-or-state]` | `references/customer-recovery-playbook.md` |

Ambiguous language: ask among `audit`, `flow`, `onboarding`, and `recovery`. Bare `audit`, invalid input, and materially mixed requests never silently select/load playbooks. Only onboarding may additionally load `references/onboarding-progress-overlay-pattern.md` for an explicitly requested stepped overlay; then only needed direct siblings: `onboarding-overlay-contract.md` (behavior/state/persistence), `onboarding-overlay-vue.md` or `onboarding-overlay-flutter.md` (target), `onboarding-overlay-proof-and-copy.md` (copy/proof/docs).

## References

Load at gate:

| Reference | Required before/when |
| --- | --- |
| `interface-voice-and-care.md` | Define/review user-facing interface copy/interactions. |
| `interface-voice-examples.md` | Draft/revise interface wording. |
| `consent-experience.md` | Create/change cookie banners/preferences, copy/interactions. |
| `async-feedback-visibility-contract.md` | Any noticeable customer-facing delay. |
| `decision-quality-contract.md` | Scope/default/proof/route decisions. |
| `spec-driven-development-discipline.md` | Behavior change/implementation proof. |
| `master-workflow-lifecycle.md` | Non-trivial implementation routing. |
| `question-contract.md` | A material question. |
| `documentation-freshness-gate.md` | Guidance depends on current permissions/billing/accessibility/SDK/provider/policy. |
| `source-intake-classification.md` | External competitor/customer feedback informs advice/audit. |
| `ux-reference-intelligence.md` | Needs cross-source journey conventions; shared `ux-reference-connectors.md` only before external source selection/use. |

Load `$SHIPGLOWS_ROOT/shipglows_data/technical/product-behavior-intelligence.md` for durable first-success/activation measurement.

## Boundaries

- First success is value; setup alone is not activation when a value loop matters.
- Define user, first success, trust, states, recovery, docs/editorial impact and proof route. Preserve comprehension, usefulness, friction, accessibility/device fit and coherence.
- Permissions/billing/privacy/data/integrations/external accounts/device access/settings require value, optionality, consequence, safe defer path, and recovery/recheck. Never coerce access, conceal effects, claim unsupported capability or imply the app grants OS/provider permission.
- Route visual systems/components/tokens/layout/motion/accessibility craft to `006-sg-design`; public/support copy/claims to `007-sg-content`; docs architecture/governance/metadata to `300-sg-docs`; manual QA to `107-sg-test`; non-auth browser evidence to `108-sg-browser`; auth/session/callback diagnosis to `109-sg-auth-debug`.
- UI/routing/data/permission/claim/cross-surface behavior requires `100-sg-spec -> 101-sg-ready -> 001-sg-build/102-sg-start`; supply the contract only; proof stays proportional.

## Stop Conditions

Stop/ask/route for unknown user/first success/trust/state/proof, unavailable required policy freshness, misleading/unrecoverable states or unrelated dirty work. Ask the smallest material question.

## Validation

```bash
python3 tools/test_sg_customer_contract.py
python3 tools/skill_code_index_lint.py
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
tools/shipglows_sync_skills.sh --check --all
```

## Rules

No new aliases/wrappers/customer/onboarding/end-user identities. English contracts; user-language output. Name handoffs without duplicating procedure.
