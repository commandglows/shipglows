---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.4.0"
project: ShipGlows
created: "2026-06-29"
updated: "2026-07-11"
status: active
source_skill: 000-shipglows
scope: source-intake-classification
owner: unknown
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/000-shipglows/SKILL.md
  - skills/007-sg-content/SKILL.md
  - skills/202-sg-emailing/SKILL.md
  - skills/references/private-memory-store.md
  - shipglows_data/editorial/content-map.md
  - shipglows_data/business/business.md
  - shipglows_data/business/product.md
  - shipglows_data/branding/branding.md
  - shipglows_data/business/gtm.md
  - shipglows_data/business/portfolio-project-pitch-links.md
depends_on:
  - artifact: "shipglows_data/editorial/content-map.md"
    artifact_version: "0.9.0"
    required_status: draft
  - artifact: "shipglows_data/business/business.md"
    artifact_version: "1.2.0"
    required_status: reviewed
  - artifact: "shipglows_data/business/product.md"
    artifact_version: "1.2.0"
    required_status: reviewed
  - artifact: "shipglows_data/branding/branding.md"
    artifact_version: "1.1.0"
    required_status: reviewed
  - artifact: "shipglows_data/business/gtm.md"
    artifact_version: "1.2.0"
    required_status: reviewed
  - artifact: "shipglows_data/business/portfolio-project-pitch-links.md"
    artifact_version: "0.1.0"
    required_status: draft
  - artifact: "skills/references/private-memory-store.md"
    artifact_version: "1.1.0"
    required_status: active
supersedes: []
evidence:
  - "Operator request 2026-06-29: centralize source analysis and project/angle classification instead of repeating it in every transforming skill."
  - "Existing content and email skills need shared source intake before deciding whether to repurpose, draft, audit, classify, or route."
  - "Operator decision 2026-07-07: when a user provides an AppSumo URL, the intake should also inspect the official product site and at least one AppSumo feedback surface because questions/reviews often expose real user demand better than the deal page alone."
  - "Operator decision 2026-07-07: product, GTM, and end-user decisions may benefit from competitor customer-feedback surfaces such as AppSumo, Trustpilot, G2, or Capterra when they expose real objections, desired outcomes, and trust signals."
  - "Operator decision 2026-07-07: app-store reviews, especially Google Play Store, are a high-value qualitative source for mobile UX friction, onboarding failures, trust issues, and feature demand."
next_review: "2026-07-29"
next_step: "/103-sg-verify source-intake-classification"
---

# Source Intake Classification

## Purpose

This reference defines the shared first pass for user-provided sources: pasted emails, notes, transcripts, URLs, articles, screenshot text, feedback, docs, or other raw material.

It answers:

```text
What is this source, where does it belong, which angle is useful, and which owner skill should act next?
```

It does not replace `007-sg-content repurpose`, `202-sg-emailing`, research, copy audit, or docs owners. It prevents each of them from reinventing the same classification step.

## Trigger

Load this reference when:

- the user provides a source and asks what to do with it
- the user uses `#source`
- a skill receives an external email, URL, transcript, article, note, or competitor/content example as inspiration
- a route could be `202-sg-emailing`, `007-sg-content repurpose`, `200-sg-redact`, `203-sg-research`, `009-sg-marketing market|gtm|copy|copywriting`, `205-sg-veille`, `300-sg-docs`, or a project-specific business/content route

## Invocation Pattern

If the operator already knows what to do with the source, treat that as a routing constraint instead of rediscovering intent.

Good input shapes:

```text
#source project=Winflowz angle=email sequence
<source email>
```

```text
#source output=landing-page project=ShipGlows
<source notes>
```

```text
#source owner=202-sg-emailing goal="turn this into a 4-email launch sequence"
<source email>
```

Supported hints:

- `project=<name>`: preferred project or corpus
- `owner=<skill>`: preferred owner skill when already known
- `angle=<use>` or `output=<format>`: intended transformation or destination
- `audience=<persona>`: intended reader or segment
- `constraints=<notes>`: claim, tone, channel, compliance, or scope constraints

Hints are binding unless they conflict with safety, project truth, public-claim rules, or owner-skill boundaries. If a hint is unsafe or mismatched, report the mismatch and recommend the safer owner route.

## Required Context

Before final classification, load only the relevant canonical context:

- `shipglows_data/business/business.md` when audience, buyer, market, or monetization matters
- `shipglows_data/business/product.md` when product fit, user problem, workflow, or non-goals matter
- `shipglows_data/branding/branding.md` when voice, trust posture, vocabulary, or claim boundaries matter
- `shipglows_data/business/gtm.md` when offer, CTA, funnel, distribution, or positioning matters
- `shipglows_data/editorial/content-map.md` when public content, repurposing, docs, FAQ, article, landing page, or skill-page placement matters
- `shipglows_data/business/portfolio-project-pitch-links.md` when choosing between several portfolio projects matters
- `skills/references/private-memory-store.md` when cached private pitch contents or a temporary unassigned-source record could change classification

Do not load every corpus by default. Load the smallest set that changes classification quality.

## Portfolio Project Index

When the source could belong to more than one project, load `shipglows_data/business/portfolio-project-pitch-links.md` before choosing the project. Use it as an index, not as a substitute for each project's own business, product, brand, or GTM docs.

Project selection should consider:

- explicit project hint from the operator
- audience match
- product/problem match
- business angle match
- source vocabulary and channel
- whether the pitch entry is `reviewed`, `candidate`, `stale`, or `archived`

If the index points to a project pitch URL, use that URL only as routing context unless the task requires deeper project truth. Do not infer private details beyond what the pitch and local governed docs support.

## Private Memory Store

When portfolio routing needs reusable pitch contents, use the private memory contract in `skills/references/private-memory-store.md`.

The approved private root is:

```text
${SHIPGLOWS_PRIVATE_ROOT:-${SHIPGLOWS_PRIVATE_ROOT:-$HOME/.shipglows/private/data}}
```

Use `${SHIPGLOWS_PRIVATE_ROOT:-${SHIPGLOWS_PRIVATE_ROOT:-$HOME/.shipglows/private/data}}/projects/` for cached project files and summaries. Use `${SHIPGLOWS_PRIVATE_ROOT:-${SHIPGLOWS_PRIVATE_ROOT:-$HOME/.shipglows/private/data}}/source-cache/` only as a redacted, short-retention holding area while the source remains unassigned or awaits review.

Do not cache raw source text in `$SHIPGLOWS_ROOT`, project repos, public specs, public docs, or generated files under version control.

## Cache Policy

Do not create a public repo cache of fetched pitch content, pasted sources, private emails, customer text, or source excerpts.

Allowed durable state in the public ShipGlows repo:

- the portfolio index of project names, pitch URLs, short routing notes, statuses, and source-of-truth pointers
- source-intake doctrine and routing rules
- redacted summaries inside specs or reports when a lifecycle skill explicitly owns them

Not allowed in the public ShipGlows repo:

- copied email examples from the operator's inbox
- private pitch contents fetched from another repo
- customer or audience source material
- unredacted screenshots, transcripts, or notes
- generated cache files containing source text

If a source needs temporary private review before its destination is known, use `${SHIPGLOWS_PRIVATE_ROOT:-${SHIPGLOWS_PRIVATE_ROOT:-$HOME/.shipglows/private/data}}/source-cache/` under the rules in `skills/references/private-memory-store.md`. Once the project is known, persist only the justified derivative in the project's governed repository: repurpose packs use `skills/references/repurpose-pack-storage.md`; audience sequences use `skills/references/email-sequence-storage.md`.

## Classification Output

Return a compact classification before transforming the source:

```text
Source type: <email | article | transcript | note | URL | feedback | competitor example | unknown>
Primary project or corpus: <project | ShipGlows | portfolio scan needed | unknown>
Best angle: <email sequence | repurpose | draft | audit | research | market study | docs | FAQ | landing page | backlog | unknown>
Intent hint: <operator-provided action | none>
Owner skill: <skill name>
Why: <one sentence>
Risks: <claims | copyright | brand voice | consent | public surface | source freshness | none>
Next action: <direct action or owner route>
Persistence: <ephemeral | private review until YYYY-MM-DD | project artifact path>
```

Use `unknown` when the source cannot be classified safely. Ask one targeted question only when the missing answer changes project, audience, claim safety, compliance, or owner skill.

## Routing Rules

- Email or campaign example intended for an audience sequence -> `202-sg-emailing`.
- Source that should become several content formats -> `007-sg-content repurpose <source>` when surface/governance matters.
- Source that needs a new original article, guide, or editorial -> `200-sg-redact` after content surface and claim gates.
- Source that needs better existing content -> `201-sg-enrich`.
- Source that is mainly external trend, competitor, product, market, or keyword signal -> `205-sg-veille`, `203-sg-research`, or `009-sg-marketing market` once the study question is settled.
- Source that should become docs, README, help, FAQ, or governance content -> `300-sg-docs` or `007-sg-content` depending on lifecycle scope.
- Source that is mainly copy quality, offer, CTA, persuasion, or positioning critique -> `009-sg-marketing copy`, `copywriting`, or `gtm` according to the stated review target.
- Source that requires a product, pricing, public claim, content-surface, or multi-step implementation decision -> `100-sg-spec` through the relevant master skill.

## Durable Ownership

Classify first; persist second. The selected project owns durable derivative work.

- A source-faithful content pack belongs in the selected project's `shipglows_data/workflow/repurpose-packs/`.
- An audience email sequence belongs in the selected project's `shipglows_data/workflow/email/`.
- The private `projects/` index remains routing memory only.
- `source-cache/` remains temporary and must not become a second global asset index.

If a project is unknown, return an ephemeral classification or a short private-review record. Do not write a durable shared source asset before ownership is clear.

## Marketplace Source Rule

When the user provides a marketplace listing such as AppSumo, treat the listing as one source layer, not the whole truth.

Minimum comparison set:

- the marketplace page itself
- the official product site
- at least one feedback surface from the marketplace when available, preferably founder Q&A or recent reviews

Why this rule exists:

- marketplace copy shows the packaged offer and strongest selling angle
- the official site shows the product's self-positioning, core workflow, and canonical CTA
- reviews and Q&A reveal objections, desired outcomes, confusion points, hard limitations, and wording used by real buyers

For AppSumo specifically:

- capture the deal page URL
- capture the official product URL linked from the listing when available
- inspect at least one AppSumo question or review when the task benefits from user demand, competitor insight, roadmap hints, or positioning analysis
- if the AppSumo page and official site disagree, record the disagreement explicitly instead of averaging them into one claim

Do not treat marketplace reviews or founder replies as objective proof of performance. Treat them as customer-voice and scope-signal inputs.

## Customer Feedback Surface Rule

When a task depends on what end users actually value, distrust, complain about, or praise in a competing product, inspect at least one real customer-feedback surface when available instead of relying only on the competitor's self-description.

Good customer-feedback surfaces include:

- marketplace reviews or founder Q&A such as AppSumo
- review platforms such as Trustpilot, G2, or Capterra
- app-store reviews such as Google Play Store or Apple App Store when the product has a mobile surface
- public community threads or issue discussions when they clearly contain end-user feedback

Use this rule when the task involves:

- end-user friction, trust, onboarding, or first-success analysis
- competitor-informed roadmap ideas
- GTM positioning, objections, proof, or offer clarity
- market-study work where user demand and dissatisfaction matter

Minimum expectation:

- keep the official product site as the canonical description of the product
- add at least one customer-feedback surface when it is available and materially changes the decision quality
- distinguish customer-voice signals from verified product facts
- report notable disagreement between self-positioning and customer feedback

Do not treat public reviews as representative statistics or objective proof. Use them as qualitative inputs for objections, desired outcomes, vocabulary, trust concerns, and scope limits.

## Source-Inspiration Rules

When the source is an inspiration example, such as an email the operator likes:

- extract reusable structure, angle, promise logic, proof pattern, CTA shape, sequence role, and objection handling
- do not copy distinctive phrasing, private details, testimonials, proprietary claims, or unsupported proof
- translate the useful pattern into the governed audience, product, brand, and GTM context
- preserve copyright and source-faithfulness boundaries
- surface risky tactics instead of normalizing them

For `202-sg-emailing`, this means the source can inspire a sequence pattern, but the output must be rewritten for the operator's audience and business rather than imitating the original substance.

## Stop Conditions

Stop or ask a targeted question when:

- the source could belong to multiple projects and the project choice changes the output
- the source includes sensitive, private, customer, credential, or legal material that should not be persisted or reused verbatim
- the source relies on claims, proof, testimonials, pricing, guarantees, scarcity, or compliance assumptions that are not governed locally
- the requested output would create a new public content surface that is not declared
- the user asks to copy or closely imitate protected source text instead of adapting the structure

## Validation

Validate references after edits with:

```bash
rg -n "#source|source-intake-classification|Source type|Source-Inspiration|Owner skill" skills/references/source-intake-classification.md skills/references/shipglows-terms.md skills/references/entrypoint-routing.md skills/000-shipglows/SKILL.md skills/007-sg-content/SKILL.md skills/emailing/SKILL.md shipglows_data/technical/operator-guides/focus-tags-cheatsheet.md
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
python3 tools/shipglows_metadata_lint.py skills/references/source-intake-classification.md skills/references/private-memory-store.md
```
