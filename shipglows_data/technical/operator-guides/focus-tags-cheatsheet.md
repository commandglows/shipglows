---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "1.4.0"
project: ShipGlows
created: "2026-06-27"
updated: "2026-07-13"
status: reviewed
source_skill: 300-sg-docs
scope: focus-tags-cheatsheet
owner: unknown
confidence: high
risk_level: low
security_impact: none
docs_impact: yes
linked_systems:
  - skills/references/shipglows-terms.md
  - skills/references/private-memory-store.md
  - skills/references/entrypoint-routing.md
  - skills/references/operator-partnership-contract.md
  - skills/references/decision-quality-contract.md
  - skills/references/execution-posture-tags.md
  - skills/008-sg-customer/SKILL.md
  - shipglows_data/business/gtm.md
  - README.md
  - shipglows-site/src/pages/docs.astro
  - shipglows-site/src/pages/fr/docs.astro
  - shipglows_data/editorial/content-map.md
depends_on:
  - artifact: "skills/references/shipglows-terms.md"
    artifact_version: "1.3.0"
    required_status: active
supersedes:
  - docs/focus-tags-cheatsheet.md
evidence:
  - "Public focus-tag families requested on 2026-06-27 so the operator can recenter the agent without invoking a full skill."
  - "Focus tags are now defined canonically in skills/references/shipglows-terms.md and loaded by entrypoint-routing."
  - "Operator decision 2026-08-20: document #local, #nolocal, and #ci as execution posture tags distinct from workflow modes and recenter tags."
next_review: "2026-07-11"
next_step: "/300-sg-docs audit shipglows_data/technical/operator-guides/focus-tags-cheatsheet.md"
---

# Focus Tags Cheatsheet

Use focus tags when you want to recenter the agent fast without launching a whole new skill just to restate doctrine.

These tags are lightweight conversation cues. They do not replace owner-skill routing. They tell ShipGlows which contract to reload before it answers, routes, edits, or verifies.

## Execution Posture Tags

These tags compose with a métier command. They control permitted proof effects;
they do not choose the owner or grant authority.

| Tag | Use when you want... | Important boundary |
| --- | --- | --- |
| `#local` | proportional local proof to be permitted | does not force a build or test |
| `#nolocal` | static inspection and edits without local/application/validation workloads | result stays unverified where runtime proof is deferred |
| `#ci` | executable proof deferred to existing CI | implies `#nolocal`; does not authorize push or CI dispatch |

`#local` conflicts with `#nolocal` and `#ci`. `#nolocal #ci` is valid. Use
`shipglows <objective> #nolocal`; the older `shipglows nolocal <objective>`
form is compatibility syntax only. `shipglows auto` already implies
`#nolocal`, accepts `#ci`, and rejects `#local`.

Examples:

```text
sg-development feature onboarding #local
sg-bug fix callback #nolocal
sg-engineering verify checkout #ci
shipglows auto #ci until=18:00
```

These are agent-conversation tags. In Bash, an unquoted `#` starts a shell
comment, so do not copy them as bare native shell arguments.

## Business Recenter Tags

Use these when you want the agent to think like a business partner instead of a neutral code mechanic.

| Tag | Use when you want... | Canonical source |
| --- | --- | --- |
| `#partner` | a business-partner stance, more initiative, and less passive assistant behavior | `skills/references/operator-partnership-contract.md` |
| `#growth` | growth, distribution, conversion, leverage, and GTM usefulness to dominate the decision | `shipglows_data/business/gtm.md` |
| `#traffic` | qualified traffic, channel-to-landing fit, tracking readiness, and conversion measurement | `skills/references/operator-roles/traffic-manager.md` |
| `#acquisition` | acquisition-channel choice, source quality, funnel entry, and measurable learning | `skills/references/operator-roles/traffic-manager.md` |
| `#offer` | the offer, promise, packaging, and commercial clarity to dominate the decision | `shipglows_data/business/gtm.md` |
| `#roi` | expected impact versus effort, drag, and cost to dominate the decision | `skills/references/operator-partnership-contract.md` |
| `#funnel` | acquisition, activation, conversion, and retention flow fit to dominate the decision | `shipglows_data/business/gtm.md` |
| `#positioning` | differentiation, category framing, and market angle to dominate the decision | `shipglows_data/business/gtm.md` |
| `#distribution` | channels, SEO, affiliates, and partner-led reach to dominate the decision | `shipglows_data/business/gtm.md` |
| `#monetization` | revenue fit, paywalls, upsell paths, and pricing pressure to dominate the decision | `shipglows_data/business/business.md` |
| `#retention` | repeat usage, stickiness, and product loops to dominate the decision | `shipglows_data/business/product.md` |
| `#decision-maker` | the buyer or approver perspective to dominate the decision | `shipglows_data/business/business.md` |
| `#end-user` | real user usefulness, first success, clarity, and beginner adoption to dominate the decision | `skills/008-sg-customer/SKILL.md` |
| `#trust` | trust, public-promise discipline, claim safety, and credibility to dominate the decision | `shipglows_data/branding/branding.md` |
| `#leverage` | operator leverage, compounding impact, and drag reduction to dominate the decision | `skills/references/operator-partnership-contract.md` |
| `#founder-mode` | a founder-facing decision surface instead of technician-level back-and-forth | `skills/references/operator-partnership-contract.md` |
| `#founder` | the user as a business owner who wants useful decisions, growth, and clarity | `skills/references/operator-partnership-contract.md` |
| `#shipglows-owner` | the operator as owner of ShipGlows and adjacent assets, with portfolio-level arbitration | `skills/references/operator-partnership-contract.md` |
| `#pitch` | reload the current project's pitch file and core identity | `shipglows_data/business/portfolio-project-pitch-links.md` |
| `#portfolio` | scan the pitch links index for the best cross-project opportunity | `shipglows_data/business/portfolio-project-pitch-links.md` |

Short usage note: use `#pitch` for one project’s identity, and `#portfolio` when you want the wider portfolio view before answering.

## Content Recenter Tags

Use these when the issue is mostly about message shape, reader understanding, or content-surface fit.

| Tag | Use when you want... | Canonical source |
| --- | --- | --- |
| `#cta` | the next action to be clearer and stronger | `shipglows_data/business/gtm.md` |
| `#clarity` | readability, explicit structure, and less vague wording | `shipglows_data/branding/branding.md` |
| `#faq` | objections, reassurance, and friction-killing answers | `shipglows_data/business/gtm.md` |
| `#voice` | tone and brand-language discipline | `shipglows_data/branding/branding.md` |
| `#audience` | the target persona and sophistication level to dominate the decision | `shipglows_data/business/business.md` |
| `#source` | classify an incoming source, project fit, useful angle, risks, and next owner skill | `skills/references/source-intake-classification.md` |
| `#private-memory` | use the approved private cache for project pitches or reusable source memory | `skills/references/private-memory-store.md` |
| `#repurpose` | the best downstream format or surface for an existing source | `shipglows_data/editorial/content-map.md` |
| `#pillar` | pillar-page role and semantic structure to dominate the decision | `shipglows_data/editorial/content-map.md` |
| `#seo-intent` | search intent and query-to-page fit to dominate the decision | `shipglows_data/editorial/content-map.md` |

## Governance Recenter Tags

Use these when the issue is mostly about documentation truth, ownership, and system coherence.

| Tag | Use when you want... | Canonical source |
| --- | --- | --- |
| `#rules` | the full ShipGlows project-governance rule set to dominate the decision | `skills/references/project-governance-rules.md` |
| `#docs` | strict documentation-governance compliance to dominate the decision | `skills/references/documentation-governance-rules.md` |
| `#canon` | the canonical source of truth to dominate the decision | `shipglows_data/technical/code-docs-map.md` |
| `#drift` | divergence between code, docs, and public surfaces to dominate the decision | `shipglows_data/technical/code-docs-map.md` |
| `#owner` | artifact or decision ownership to dominate the decision | `skills/references/canonical-paths.md` |
| `#freshness` | document or claim recency to dominate the decision | `shipglows_data/editorial/content-map.md` |
| `#traceability` | trace links between decision, source, implementation, and proof | `shipglows_data/workflow/playbooks/spec-driven-workflow.md` |
| `#entrypoint` | the fastest correct entrypoint doc or workflow to dominate the decision | `AGENT.md` |
| `#contract` | non-optional rules and invariants to dominate the decision | `skills/references/decision-quality-contract.md` |
| `#public-docs` | public-facing docs and external readability to dominate the decision | `shipglows_data/editorial/content-map.md` |
| `#internal-docs` | internal operator truth and execution-facing docs to dominate the decision | `shipglows_data/technical/context.md` |
| `#single-source` | one authoritative artifact instead of duplicated explanations | `shipglows_data/technical/code-docs-map.md` |

## Execution Discipline Tags

Use these when you want to tighten how the agent executes, not just what it optimizes for.

| Tag | Use when you want... | Canonical source |
| --- | --- | --- |
| `#quality` | the quality bar, anti-shortcut doctrine, and bounded excellence to dominate the decision | `skills/references/decision-quality-contract.md` |
| `#vfbf` | a quick, bounded, traceable execution pass that stays narrow and leaves a durable trace | `skills/references/decision-quality-contract.md` |
| `#scope` | the narrowest justified owner layer and bounded scope to dominate the decision | `skills/references/decision-quality-contract.md` |
| `#ship` | ship readiness, checks, proof, closure, and release discipline to dominate the decision | `skills/004-sg-deploy/SKILL.md` |
| `#routing` | owner-skill selection and direct handoff rules to dominate the decision | `skills/references/entrypoint-routing.md` |
| `#proof` | proof paths, validation proportion, and evidence-backed claims to dominate the decision | `skills/references/spec-driven-development-discipline.md` |
| `#no-drift` | staying on target, choosing, and acting without exploratory drift to dominate the decision | `skills/references/entrypoint-routing.md` |

## System Recenter Tags

Use these when the current conversation risks drifting toward the wrong repository or the wrong abstraction layer.

| Tag | Use when you want... | Canonical source |
| --- | --- | --- |
| `#shipglows` | the internal ShipGlows system, not the current project repo | `skills/references/entrypoint-routing.md` |
| `#shupflow` | the same thing as `#shipglows`, with a typo-tolerant fast alias | `skills/references/entrypoint-routing.md` |
| `#shipglows-core` | ShipGlows hardening, execution fidelity, or internal doctrine work | `skills/900-shipglows-core/SKILL.md` |

## Technical Navigation Hint Tags

Use these when you want the agent to treat a word as an indexed technical feature term before broad search.

| Tag | Use when you want... | Canonical source |
| --- | --- | --- |
| `#feature:<term>` | explicit behavior-index navigation for a technical term while keeping the free-text request active; for example, `#feature:swipe` | `skills/references/entrypoint-routing.md` |

## Recommended Combos

Use these when you do not want to build the tag set from scratch.

| Goal | Recommended tags | Use when you want... |
| --- | --- | --- |
| Make the offer clearer | `#offer #cta #clarity` | the page or message to make the value proposition and next action obvious |
| Push growth instead of local optimization | `#partner #growth #roi` | the agent to choose the highest-leverage move, not the easiest technical move |
| Choose an acquisition bet | `#traffic #acquisition #funnel` | the agent to rank channels by qualified intent, landing fit, and measurement readiness |
| Improve onboarding and real usability | `#end-user #clarity #quality` | the solution to become easier to understand, safer, and more useful for normal users |
| Fix objection-heavy copy | `#faq #trust #clarity` | the message to answer doubts directly without sounding slippery |
| Improve discoverability | `#seo-intent #pillar #distribution` | the content or structure to align better with search intent and distribution paths |
| Classify a source before acting | `#source #audience #cta` | an email, URL, transcript, note, or example to be sorted into the right project, angle, and owner skill |
| Classify a source across projects | `#source #portfolio #audience` | the source could fit several projects and should be matched against the portfolio pitch index first |
| Reuse cached private context | `#source #private-memory #portfolio` | the source or project pitch should be matched against the approved private cache instead of refetching public URLs |
| Rework content from an existing source | `#repurpose #audience #cta` | one source to be turned into the right surface for the right reader and action |
| Recenter on business buyer logic | `#decision-maker #offer #monetization` | the work to speak to the approver, the budget owner, or the buyer |
| Recenter on the founder perspective | `#founder #growth #clarity` | the work to assume business-owner responsibility and optimize for useful decisions |
| Recenter on your portfolio view | `#shipglows-owner #partner #no-drift` | the work to arbitrate across ShipGlows and other assets without losing scope |
| Recenter on the project identity | `#pitch #partner #clarity` | the work to reload the project's core pitch when the agent starts losing the plot |
| Recenter on portfolio opportunity | `#portfolio #growth #partner` | the work to scan for useful cross-project leverage and transfer patterns |
| Improve retention logic | `#retention #end-user #funnel` | the work to focus on repeat usage, activation continuity, and product loops |
| Repair doc drift at the right layer | `#canon #drift #single-source` | the agent to fix the source of truth first instead of patching duplicate surfaces |
| Recenter on governance compliance | `#rules #canon #owner` | the agent to reload the full governed-project rule set before deciding what is missing, duplicated, or non-compliant |
| Recenter on documentation compliance | `#docs #canon #internal-docs` | the agent to enforce documentation architecture, metadata, and canonical placement before patching local surfaces |
| Choose the right doc surface | `#owner #entrypoint #public-docs` | the question is mostly where a message or contract should live publicly |
| Recenter on internal operator truth | `#owner #entrypoint #internal-docs` | the issue belongs in internal docs, technical contracts, or execution-facing guidance |
| Tighten execution without wandering | `#quality #scope #no-drift` | the agent to choose a bounded, high-quality route and stop exploring |
| Prepare a ship-ready answer | `#ship #proof #quality` | the work to end with checks, evidence, and release discipline instead of advice only |
| Work on ShipGlows itself | `#shipglows #proof #contract` | the target is the internal ShipGlows system and the output should strengthen doctrine or proofability |
| Harden ShipGlows behavior | `#shipglows-core #contract #no-drift` | the goal is execution fidelity, routing discipline, or internal hardening |

## Quick Examples

```text
#partner #growth
This flow is technically fine but not helping conversion enough.
```

```text
#offer #cta #clarity
The page explains a lot but still does not make the offer obvious.
```

```text
#end-user #quality
This solves the bug but still feels too hard for a normal user.
```

```text
#faq #trust #seo-intent
Turn this objection-heavy draft into something users can find and believe.
```

```text
#canon #drift #public-docs
Recenter on the source of truth and fix the docs that are now out of sync.
```

```text
#shipglows #proof
Work on the ShipGlows system itself and make the contract more testable.
```

```text
#founder-mode #growth #no-drift
Do the most useful thing for adoption and stop wandering.
```

## Default Rule

If you use one or more focus tags, ShipGlows should reload those canonical documents first and keep them as high-priority context for the current turn.

If you combine several tags, ShipGlows should merge them in the narrowest coherent way instead of treating them as conflicting by default. The explicit execution-posture conflicts above are the exception and must be rejected.
