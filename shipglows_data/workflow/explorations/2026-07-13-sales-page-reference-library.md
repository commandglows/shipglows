---
artifact: exploration_report
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: "ShipGlows"
created: "2026-07-13"
updated: "2026-07-15"
status: draft
source_skill: 700-sg-explore
scope: "sales-page-reference-library"
owner: "unknown"
confidence: high
risk_level: medium
security_impact: no
docs_impact: yes
linked_systems:
  - skills/references/design-inspiration-library.md
  - skills/references/design-inspiration/
  - skills/006-sg-design/SKILL.md
  - skills/200-sg-redact/SKILL.md
  - skills/206-sg-audit-copy/SKILL.md
  - skills/207-sg-audit-copywriting/SKILL.md
  - skills/500-sg-design-from-scratch/SKILL.md
  - skills/502-sg-audit-design/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Existing ShipGlows template library and app-blueprint registry"
  - "Operator clarification on 2026-07-15: this is a cross-project design and sales-page copywriting library, not the project competitor/inspiration business registry."
  - "Operator decision on 2026-07-15: prefer a simple capture bundle containing extracted text and a full-page visual capture over a Wayback-centered workflow."
  - "Current design and copywriting skills do not load a shared visual/copy inspiration corpus."
  - "Internet Archive Help Center: Wayback Machine general information"
  - "Internet Archive Help Center: Using the Wayback Machine"
  - "Internet Archive Save Page Now interface"
next_step: "/sg-spec sales-page-reference-library"
---

# Exploration Report: Sales-page reference library

## Starting Question

How should ShipGlows store and expose roughly forty sales-page references so that both copywriting and visual design remain inspectable over time?

The operator clarified on 2026-07-15 that this corpus is a reusable, cross-project design and sales-page copywriting library. It is intentionally separate from project-local competitor and market-inspiration registries.

## Context Read

- `templates/` - existing document artifact templates; useful precedent for a structured record format.
- `skills/references/app-blueprints.md` - existing pattern for a registry plus local cache plus external durable source.
- `skills/app-blueprints/README.md` - existing registry shape and resolution-order precedent.
- `shipglows_data/editorial/content-map.md` - public/private content routing and documentation-impact rules.
- `CLAUDE.md`, `shipglows_data/technical/context.md`, `README.md` - repository constraints and canonical documentation layout.

## Internet Research

- [Wayback Machine General Information](https://help.archive.org/help/wayback-machine-general-information/) - Accessed 2026-07-13 - confirms that standard HTML archives well, while forms and JavaScript-dependent functionality may fail.
- [Using the Wayback Machine](https://help.archive.org/help/using-the-wayback-machine/) - Accessed 2026-07-13 - confirms stable citation links, Save Page Now's single-page scope, missing assets, robots exclusions, and incomplete captures.
- [Save Page Now](https://web.archive.org/save/) - Accessed 2026-07-13 - confirms options for outlinks and screenshots, with some extra features requiring an account.

## Problem Framing

Two distinct artifacts must not be conflated:

- `shipglows_data/business/.../project-competitors-and-inspirations.md` records project-local market, competitor, differentiation, and business inspiration.
- the proposed design inspiration library records reusable visual composition, landing-page structure, persuasive copy patterns, and page-level creative references for ShipGlows skills across projects.

The library needs two different kinds of value:

1. a durable visual reference that can be opened in a browser;
2. a searchable learning record explaining offer, audience, promise, proof, objections, CTA, page structure, and design patterns.

Wayback can provide the first layer, but it should not be treated as the only copy of the second layer or as a guaranteed full-site backup.

## Option Space

### Option A: Wayback-only catalog

- Summary: store the original URL and a selected Wayback URL for every page.
- Pros: minimal storage, public access, easy sharing, no need to republish third-party pages.
- Cons: captures can be incomplete; JavaScript, forms, images, fonts, videos, and third-party assets can disappear or fail; Save Page Now is page-scoped and not a general backup service.

### Option B: Capture-bundle reference library (recommended)

- Summary: extract the visible page text and create a full-page screenshot, automatic image segments, and a small metadata record. Keep the original URL and make Wayback optional.
- Pros: simple to capture and consume; preserves both copy and visual hierarchy; independent of future page changes; no replay system to maintain.
- Cons: source-derived text and screenshots need private, rights-aware storage; compressed images still consume meaningful space.

### Option C: Full local mirror or self-hosted replay

- Summary: crawl and host HTML/assets locally, potentially with WARC/WACZ tooling.
- Pros: strongest control over visual availability and offline use.
- Cons: highest legal, technical, storage, and maintenance cost; replaying interactive pages is difficult; risks turning a reference corpus into unauthorized redistribution.

## Comparison

| Criterion | Wayback-only | Capture bundle | Full mirror |
|---|---:|---:|---:|
| Initial effort | low | medium | high |
| Visual fidelity | variable | good enough with screenshot fallback | potentially high |
| Copy/search value | low | high | medium |
| Offline resilience | low | medium | high |
| Maintenance | low-medium | medium | high |
| Rights exposure | lower | medium | higher |

## Emerging Recommendation

Use one self-contained capture bundle per page. This replaces the previous Wayback-centered recommendation:

```text
design-inspiration/<reference-id>/
├── record.yaml              # source, date, tags, viewport, status, provenance
├── page.md                  # visible text with headings, links, buttons, and section order
├── full-page.webp           # desktop screenshot after the page has fully loaded
├── thumbnail.webp           # lightweight catalog preview
└── segments/                # automatic slices for reliable agent vision
    ├── 001.webp
    ├── 002.webp
    └── ...
```

`full-page.webp` covers the operator's full-page photograph, screenshot, and scrolling-page capture requirement as one artifact. The slices are generated automatically from it; they are not a separate manual capture workflow. A mobile capture remains optional for references where responsive behavior materially matters.

Extract structured Markdown rather than an unformatted text dump so agents retain the hierarchy of headlines, paragraphs, lists, buttons, labels, and links. Exclude hidden text, scripts, styles, cookie boilerplate when safely identifiable, and private/authenticated data.

Do not save or replay full third-party HTML by default. Keep source-derived text and images in a private, rights-aware asset corpus rather than the public ShipGlows repository. Keep the shared ShipGlows contract, taxonomy, and skill-loading rules under `$SHIPGLOWS_ROOT/skills/references/`. The exact private asset location must be defined in the spec because the current `~/.shipglows/private/data/` contract explicitly excludes durable cross-project marketing-example libraries.

Each `record.yaml` should contain: `id`, original URL, capture timestamp, viewport, page type, audience, style and conversion tags, source status, access status, optional Wayback URL, and checksums for captured artifacts. Human analysis such as offer, proof, objections, CTA sequence, visual patterns, and “what to borrow / what not to copy” can be added during curation without blocking initial capture.

### Account and access policy

- The canonical ShipGlows library must work without an account on a third-party inspiration service.
- External tools such as bookmarking, moodboard, or gallery services may be optional capture/discovery interfaces, never the source of truth.
- If a source requires authentication, an agent may only access it through an explicitly authorized connector/session; credentials, cookies, and account exports must never be stored in the catalog.
- A reference that other skills cannot open should be marked `access: authenticated` and should include a public fallback when one exists.

### Skill consumption policy

Add an `Inspiration Gate` to the design and copywriting routes rather than loading the whole corpus for every task:

1. Trigger it for new visual direction, landing/sales-page creation, major redesign, offer-page copy, or an explicit inspiration request.
2. Filter `index.yaml` by page type, audience, style, section, copy pattern, and conversion goal.
3. Present a bounded shortlist of source links with the reason each reference fits the current task.
4. Require an operator selection before treating a reference as design direction; discovery is not approval to imitate.
5. Record selected reference IDs in the task spec or design/copy artifact so later agents can recover the decision.

Routine bug fixes, token migrations, accessibility remediation, and narrow audits should not trigger external inspiration discovery unless the user asks for it.

When an agent discovers a useful new page, it should share the link and rationale with the current user. It should only promote the page into the curated library when the task explicitly includes curation or the operator confirms that the reference should be kept. New entries start as `candidate`; reviewed entries become `approved`.

For the initial links, the intake pass should load the page, scroll through it once to trigger lazy-loaded content, extract visible structured text, capture the full desktop page, create the thumbnail and image segments, and record failures explicitly. A Wayback link may be added when useful, but capture success must not depend on it.

## Non-Decisions

- Whether the corpus should become a public ShipGlows website surface.
- Which bounded, rights-aware evidence store should hold selected screenshots; the existing private-data repository contract excludes durable cross-project marketing-example libraries.
- Whether the shared catalog itself is public or distributed only with a private ShipGlows installation.
- Which optional external discovery/bookmarking service, if any, should feed the candidate queue.
- Whether the forty URLs should be refreshed periodically or only on demand.

## Rejected Paths

- Wayback as the primary capture workflow - more moving parts than the expected benefit, while replay remains unreliable for visual assets and interactive pages.
- Full scraping as the default - disproportionate maintenance and rights risk for an inspiration library.
- Text-only extraction - loses the visual hierarchy, composition, density, and interaction cues the library is meant to study.
- Full HTML/WARC mirroring - unnecessary for the intended design and copywriting analysis.
- Reusing the project competitor/inspiration registry - mixes market intelligence with reusable creative references and prevents clean skill routing.
- Making a third-party account mandatory - creates access, portability, privacy, and agent-authentication dependencies.

## Risks And Unknowns

- A page may be blocked by robots, owner request, authentication, paywall, or technical constraints.
- A capture may replay missing assets or redirect to the live site for unavailable links; each entry needs a visible capture-status field.
- Copyright and terms may limit stored screenshots, copied text, or redistribution; the default corpus should remain a research/analysis aid and retain attribution and source links.
- A page can change materially after capture; record capture time and avoid treating the reference as current product truth.

## Redaction Review

- Reviewed: yes
- Sensitive inputs seen: none
- Redactions applied: none
- Notes: report contains only repository structure, public documentation links, and design recommendations.

## Decision Inputs For Spec

- User story seed: As an operator, I can capture a sales page once as structured text and a complete visual reference, then let ShipGlows skills retrieve it for future design and copywriting work.
- Scope in seed: capture-bundle schema, structured visible-text extraction, full-page screenshot, automatic image segmentation, thumbnail, private asset location, global registry, Inspiration Gate, candidate-to-approved workflow, skill integrations, taxonomy, rights/attribution fields, and validation of the initial URLs.
- Scope out seed: public marketing page, autonomous scraping of arbitrary sites, full interactive mirroring, automated copy reuse.
- Invariants/constraints seed: preserve original attribution; separate reference corpus from app blueprints; do not rely on Wayback as the only backup; keep metadata searchable; do not expose secrets or private browsing data.
- Validation seed: every initial entry has a source URL, capture status, timestamp, Wayback URL or documented failure, classification, and copy/design analysis; sample replays are checked manually.

## Handoff

- Recommended next command: `/sg-spec sales-page-reference-library`
- Why this next step: the direction is sufficiently clear to define the entry schema and intake workflow, but storage visibility and refresh policy still need an explicit operator decision.

## Exploration Run History

| Date UTC | Prompt/Focus | Action | Result | Next step |
|----------|--------------|--------|--------|-----------|
| 2026-07-13 | Wayback-backed sales-page reference library | Read repository patterns and official Internet Archive guidance; compared three storage models | Hybrid registry + Wayback + fallback evidence appeared to be the strongest initial default | `/sg-spec sales-page-reference-library` |
| 2026-07-15 | Clarify cross-project design/copy library and skill access | Separated the corpus from business intelligence; defined global storage, account policy, Inspiration Gate, and curation behavior | Global ShipGlows reference corpus with optional discovery services and bounded skill loading | `/sg-spec sales-page-reference-library` |
| 2026-07-15 | Simplify capture and preservation | Replaced the Wayback-centered model with text extraction plus full-page screenshot, thumbnail, and automatic image segments | Capture bundle is the preferred minimum viable library; Wayback is optional | `/sg-spec sales-page-reference-library` |
