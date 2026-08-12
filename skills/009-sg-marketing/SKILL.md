---
name: 009-sg-marketing
description: "Research markets and produce GTM, positioning, copy, and copy audits."
argument-hint: "<market|gtm|copy|copywriting> <target> | help"
---

# Marketing

## Canonical Paths

Before resolving ShipGlows-owned files, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/.shipglows/runtime`). ShipGlows tools, shared references, local playbooks, templates, and workflow docs resolve from `$SHIPGLOWS_ROOT`; project artifacts resolve from the current project root.

## Public Métier Ownership

Public label: `sg-marketing`. Load `$SHIPGLOWS_ROOT/skills/references/intent-to-outcome-autonomy.md` before clarification or mode selection. Resolve `project -> product -> surface -> feature`, ask only for missing operator-owned market or promise decisions, and carry the marketing outcome through evidence, recommendations, affected artifacts, validation, and closure.

## Instruction Layering

This `SKILL.md` is the compact activation contract. Before editing or expanding it, load `$SHIPGLOWS_ROOT/skills/references/skill-instruction-layering.md`. Keep detailed procedure, scoring, templates, and provider guidance in the selected local playbook.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

Before the final report, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md`. If attached to exactly one active spec, trace this run there; otherwise do not write a spec. Evaluate the standard `Chantier potentiel` threshold when findings imply non-trivial future work without a unique owner.

## Report Modes

Before the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, findings-first for audits and evidence limits, outcome-first for support runs, and in the user's active language. Use `report=agent`, `handoff`, `verbose`, or `full-report` only when detailed evidence is needed.

## Mission

`009-sg-marketing` is the sole public marketing-audit and market-study entrypoint. It selects exactly one explicit mode and one bounded local playbook; it is not an editorial lifecycle, research, SEO, veille, email, drafting, or implementation master.

## Mode Detection

Before parsing an explicit invocation, load `$SHIPGLOWS_ROOT/skills/references/skill-invocation-preflight.md`; invalid or ambiguous preflight never activates this skill.

Load `$SHIPGLOWS_ROOT/skills/references/decision-quality-contract.md` before selecting a mode or scope.

Parse `$ARGUMENTS` exactly:

- `market <target>` -> load `references/market-study-playbook.md` for demand, competitors, keywords, monetization, brand/domain, AI visibility, and a data-backed go/no-go view.
- `gtm <target>` -> load `references/gtm-audit-playbook.md` for positioning, offer, funnel, trust, analytics, launch readiness, and product/claim coherence.
- `copy <target>` -> load `references/copy-audit-playbook.md` for clarity, tone, readability, CTA, microcopy, friction, claim evidence, and public-surface coherence.
- `copywriting <target>` -> load `references/copywriting-audit-playbook.md` for persona, offer, objections, persuasion sequence, proof, conversion strategy, and message-market fit.
- `help` -> list these modes and their examples; do not load a substantive playbook.

Bare input, an unknown mode, `audit` without a subtype, malformed mode/name input, or a substantive mode without a target is safe: list the four modes and one example each. For `market` without a target, ask for a niche, product idea, or market question; do not infer one from the repository.

Never guess between `copy` and `copywriting`: `copy` asks whether wording is clear, credible, and usable; `copywriting` asks whether an offer persuades its intended buyer. When both concerns are material and no first mode was named, ask one focused routing question. Do not run all modes automatically.

## Conditional Shared Gates

Load only gates required by the selected mode:

- `market` and `gtm`: load `$SHIPGLOWS_ROOT/skills/references/source-intake-classification.md` when competitor pages, marketplaces, external reviews, or raw sources materially affect the analysis. Load `$SHIPGLOWS_ROOT/shipglows_data/technical/product-behavior-intelligence.md` only when behavior-to-value, activation, retention, or feature-value proof is needed; it is draft, so state its confidence limit rather than elevating it to settled proof.
- `copy` and `copywriting`: load `$SHIPGLOWS_ROOT/skills/references/content-quality-rubric.md` for rubric-scored outputs and `$SHIPGLOWS_ROOT/skills/references/task-registry-routing.md` before durable follow-up writes. For sales/offer, CTA/proof/objection comparison, or explicit inspiration, load `$SHIPGLOWS_ROOT/skills/references/design-inspiration-library.md`; filter at most five private reference IDs, require operator selection before loading bundles, and use transferable patterns rather than source phrasing.
- `copywriting` landing gate: after the `copywriting` playbook is selected, load `$SHIPGLOWS_ROOT/skills/references/landing-page-copywriting-framework.md` only for landing, sales, or offer targets or explicit section-flow or repetition work on the bounded target. A non-landing target without that need does not load it; this remains one local playbook plus shared doctrine, not another mode or marketing pass.
- Any public-content, mapped-documentation, runtime-content, README, or public-doc change: load `$SHIPGLOWS_ROOT/skills/references/editorial-content-corpus.md` and/or `$SHIPGLOWS_ROOT/skills/references/technical-docs-corpus.md` as their gates require. Report the applicable Editorial, Claim Impact, and Documentation Update Plans.

## Boundaries And Reroutes

- `007-sg-content` remains the editorial lifecycle owner. Do not create an implicit chain of marketing modes.
- Generic cited research -> `203-sg-research`; raw URL/source triage as the primary unmet need -> `205-sg-veille`; SEO -> `406-sg-seo`; email sequences -> `202-sg-emailing`.
- Drafting, enrichment, publishing, documentation, or implementation requests route to their existing owner unless an active unique chantier explicitly owns bounded remediation under the selected mode.
- `copy` may flag persuasion issues but does not silently become `copywriting`; `copywriting` may flag clarity issues but does not duplicate a full copy audit.

## Core Safety Rules

- Do not invent market size, keywords, competitors, pricing, revenue, demand, domains, customer feedback, conversion metrics, testimonials, guarantees, regulatory/security claims, or product capabilities.
- Flag unsupported claims as a proof gap, claim mismatch, needs-proof, or blocked result. Do not strengthen a promise to improve persuasion.
- Missing selected playbook, required reference, evidence, or material business/brand context produces a visible blocked or confidence-limited result. Continue only when the selected playbook permits an audit with named limits.
- Do not mutate unrelated dirty files or durable state without the selected playbook's owner contract.

## Validation

After contract edits, run:

```bash
python3 -m unittest tools.test_009_sg_marketing_contract
python3 tools/shipglows_metadata_lint.py skills/009-sg-marketing
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
```

## Rules

- Keep one public identity, four explicit modes, and exactly one local playbook per substantive mode.
- Do not add an `audit`, `strategy`, `research`, `SEO`, or `email` mode, compatibility aliases, or a second marketing lifecycle.
- Do not use the retired `009-sg-skill-build` identity as an alias, fallback, or example; it is historical only.
