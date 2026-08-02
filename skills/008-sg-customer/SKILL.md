---
name: 008-sg-customer
description: "Customer journeys, activation, trust, and recovery through four explicit modes."
argument-hint: "<audit|flow|onboarding|recovery> <scope>"
---

## Canonical Paths

Before resolving a ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/shipglows`). Resolve skills, references, tools, templates, and workflow documents from that root.

## Instruction Layering

This is the compact dispatcher. Before changing it, load `$SHIPGLOWS_ROOT/skills/references/skill-instruction-layering.md`; detailed mode procedure belongs in one local playbook, not in this activation contract.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

When one active chantier spec owns the run, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md`, write its run trace, and use its chantier header. Otherwise do not write a spec. Non-trivial implementation follow-up requires `/100-sg-spec` before source changes.

## Report Modes

Before reporting, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`. Default to `report=user`; `report=agent`, `handoff`, `verbose`, and `full-report` may include the full customer contract and routing evidence.

## Mission

`008-sg-customer` is the single customer-experience owner. It turns one selected customer job into a contract or finding that makes the target user, first meaningful success, trust consequence, observable states, recovery path, documentation/editorial impact, and proof route explicit.

It is not a second onboarding skill, a visual-design owner, a copy/docs owner, an implementation lifecycle, or a proof runner.

## Modes

Use exactly one primary playbook:

| Invocation | Primary playbook | Result |
| --- | --- | --- |
| `008-sg-customer audit [scope]` | `references/customer-audit-playbook.md` | Evidence-backed customer findings and owner/proof route for an existing journey. |
| `008-sg-customer flow [feature-or-flow]` | `references/customer-flow-playbook.md` | End-User Contract for a new, changed, or shipped path. |
| `008-sg-customer onboarding [feature-or-flow]` | `references/onboarding-playbook.md` | First-success setup, progressive disclosure, defer/revisit, and setup recovery. |
| `008-sg-customer recovery [feature-or-state]` | `references/customer-recovery-playbook.md` | Safe resume, defer, or recheck path for a disrupted state. |

Natural-language input is dispatcher input, not a fifth mode: select one mode only when intent is unambiguous; otherwise ask one concise question among `audit`, `flow`, `onboarding`, and `recovery`. Bare `audit`, invalid input, and materially mixed requests never silently select or load several playbooks. Only onboarding may additionally load `references/onboarding-progress-overlay-pattern.md`, and only for an explicitly requested stepped overlay.

## Required References

- `$SHIPGLOWS_ROOT/skills/references/async-feedback-visibility-contract.md` for customer-facing loading, onboarding, save, upload, support, recovery, or any other operation with a noticeable delay.

Load only the selected mode playbook. Load shared references only when their gate applies:

- `$SHIPGLOWS_ROOT/skills/references/decision-quality-contract.md` before choosing scope, defaults, proof, or route.
- `$SHIPGLOWS_ROOT/skills/references/spec-driven-development-discipline.md` before changing behavior or defining implementation proof.
- `$SHIPGLOWS_ROOT/skills/references/master-workflow-lifecycle.md` before routing non-trivial implementation.
- `$SHIPGLOWS_ROOT/skills/references/question-contract.md` before a material question.
- `$SHIPGLOWS_ROOT/skills/references/documentation-freshness-gate.md` when current external permissions, billing, accessibility, SDK, provider, or policy behavior governs guidance.
- `$SHIPGLOWS_ROOT/skills/references/source-intake-classification.md` when external competitor or customer-feedback evidence drives an audit or recommendation.
- `$SHIPGLOWS_ROOT/shipglows_data/technical/product-behavior-intelligence.md` when first success or activation must be measured as durable value rather than shallow completion.

## Non-Negotiables And Boundaries

- Define first success as meaningful value; when a value loop matters, do not treat setup completion as activation.
- Preserve comprehension, usefulness, friction, trust, visible states, accessibility/device fit, recovery, documentation/editorial coherence, and proportional proof.
- For permissions, billing, privacy, data, integrations, external accounts, device access, or settings: state value, optionality, consequence, safe defer path, and recovery/recheck. Never coerce access, conceal effects, claim unsupported capability, or imply the app can grant an OS/provider permission.
- Route visual systems, components, tokens, layout, motion, and accessibility craft to `006-sg-design`; public/support copy and claims to `007-sg-content`; documentation architecture, governance, and metadata to `300-sg-docs`; manual QA to `107-sg-test`; non-auth browser evidence to `108-sg-browser`; and auth/session/callback diagnosis to `109-sg-auth-debug`.
- Source behavior across UI, routing, data, permissions, claims, or several surfaces requires `100-sg-spec -> 101-sg-ready -> 001-sg-build/102-sg-start`; this skill supplies the customer contract, not direct implementation.

## Stop Conditions

Stop, ask the smallest material question, or route when target user, first success, trust boundary, observable state, or proof path cannot be identified; when an external-policy freshness gate is required but unavailable; when a state is misleading or unrecoverable; or when the work would absorb unrelated dirty files.

## Validation

```bash
python3 tools/test_sg_customer_contract.py
python3 tools/skill_code_index_lint.py
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
tools/shipglows_sync_skills.sh --check --all
```

## Rules

- Do not add aliases, wrappers, or second customer/onboarding/end-user identities.
- Keep internal contracts in English and user-facing output in the active user language.
- Do not duplicate adjacent-owner procedures; name the handoff only.
