---
artifact: contract
metadata_schema_version: "1.0"
artifact_version: "2.0.0"
project: ShipGlows
created: "2026-07-15"
updated: "2026-08-11"
status: active
source_skill: 102-sg-start
scope: design-inspiration-library
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/design-inspiration/
  - tools/capture_design_inspiration.py
  - tools/capture_design_inspiration_playwright.js
  - skills/006-sg-design/SKILL.md
  - skills/006-sg-design/references/design-inspiration-library-operations.md
  - shipglows_data/workflow/playbooks/design-inspiration-library-server-migration-playbook.md
  - skills/007-sg-content/SKILL.md
  - skills/200-sg-redact/SKILL.md
  - skills/009-sg-marketing/SKILL.md
  - skills/006-sg-design/SKILL.md
depends_on:
  - artifact: skills/references/private-data-repo-contract.md
    artifact_version: "2.0.0"
    required_status: active
supersedes: []
evidence:
  - "Ready spec sales-page-reference-library.md and its exploration source."
  - "Operator decision: source-derived captures stay outside public repositories and are consumed through a bounded, operator-selected Inspiration Gate."
  - "Operator correction: 006-sg-design exposes direct library add, approve, list, and status modes; approval must synchronize the bounded index."
  - "Operator decision 2026-08-07: a remotely synchronized corpus uses a private Git repository, Git LFS for large visual captures, and repository rotation only for a justified removal or purge."
  - "Implemented 2026-08-07: add and approval use a verified private origin fingerprint, stage only their written corpus paths, and report pending synchronization without losing local evidence."
  - "Operator request 2026-08-07: server migration is governed by a reusable install and restore playbook with a paired checklist."
  - "Operator correction 2026-08-07: taxonomy exists only when a reference is explicitly classified at approval; empty candidate tags are not a usable creative search index."
  - "Live recovery 2026-08-07: an explicit retry replaces only a failed candidate with no artifacts after a shared capture-runtime repair, preserving the prior reason in private metadata."
  - "Live capture 2026-08-07: very tall pages proportionally downscale only full-page WebP while retaining high-resolution segments; the current bundle remains a static visual snapshot and does not record animation timelines."
  - "Operator decision 2026-08-11: the separate corpus moves from ~/.shipglows/private/design-inspiration-library to the sibling path ~/.shipglows/design-inspiration-library."
next_review: "2026-08-15"
next_step: "/103-sg-verify sales-page-reference-library"
---

# Design Inspiration Library

## Purpose

This contract governs a private, cross-project library of visual composition and sales-page copy patterns. It lets design and content skills study reusable structure without confusing creative references with project-level competitor, pricing, positioning, or market intelligence.

Use `shipglows_data/business/project-competitors-and-inspirations.md` for competitor, alternative, differentiation, pricing, positioning, or market work. Use this library only for design hierarchy, page composition, persuasive sequence, proof, objection, CTA, density, rhythm, and related creative patterns.

## Canonical Paths

Public ShipGlows contract and tooling:

```text
${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/skills/references/design-inspiration-library.md
${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/skills/references/design-inspiration/
${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/tools/capture_design_inspiration.py
```

Private source-derived corpus:

```text
${SHIPGLOWS_INSPIRATION_LIBRARY_DIR:-${SHIPGLOWS_PRIVATE_DIR:-$HOME/.shipglows}/design-inspiration-library}
```

Optional remote configuration for the separate corpus:

```text
SHIPGLOWS_INSPIRATION_LIBRARY_REPO
```

The remote is configured externally and must never be hardcoded in this contract or the tool. This corpus is deliberately separate from `${SHIPGLOWS_PRIVATE_DATA_DIR:-${SHIPGLOWS_PRIVATE_DIR:-$HOME/.shipglows}/data}`, whose contract excludes durable cross-project marketing-example libraries.

## Versioning And Purge Policy

The local private corpus remains capture-capable without a remote. When it is synchronized or backed up through Git, its remote repository MUST be private.

- Git tracks `index.yaml`, `record.yaml`, `page.md`, and the corpus configuration.
- Git LFS tracks every captured WebP artifact: `full-page.webp`, `thumbnail.webp`, and `segments/*.webp`.
- The private-repo bootstrap or operator setup owns the one-time user-level Git LFS installation, `.gitattributes`, remote privacy verification, and the stored origin fingerprint; the capture command never creates or publishes a remote repository implicitly.
- `library add` and `library approve` synchronize their just-written paths when this verified setup exists. A failed or unavailable synchronization reports `pending` and never discards the local capture or approval.
- Before staging a WebP bundle, the tool checks that each generated visual path resolves to the Git LFS filter. A broken LFS rule results in `sync=pending reason=lfs_tracking_missing` rather than placing images in ordinary Git.
- A capture is an attributable snapshot. Re-captures must not silently overwrite an unrelated historic record or erase its provenance.
- Screenshots represent one captured visual state. CSS/JS animation behavior, hover transitions, scroll choreography, and time-based sequences are not preserved by the current bundle; adding that capability would require a separate frame/video artifact contract.

Git LFS content is versioned as content-addressed objects: changing a capture creates a new object while older commits can still refer to the prior one. This is normal version history, not a ban on changing or deleting a reference.

When a source owner requests removal, or when a justified corpus purge is required:

1. remove the source-derived artifacts locally and retain only the legally safe tombstone, if any;
2. create a replacement private repository from the still-authorized corpus, without the removed assets or history;
3. switch the externally configured remote to that replacement repository; and
4. delete the old remote repository and known local clones/backups that contain the removed bundle.

Do not rotate repositories routinely. Rotate only for a takedown, a deliberate purge, or material storage cleanup. Rotation removes the managed remote history; it cannot guarantee deletion from independently downloaded copies or a provider's internal backup-retention window.

For server replacement, use `shipglows_data/workflow/playbooks/design-inspiration-library-server-migration-playbook.md` and its paired checklist. They restore Git LFS once per server user, the private corpus checkout, the local origin fingerprint, and dry-run proof without recording the private remote in shared documentation.

## Public And Private Boundary

The public repository may contain only:

- this contract, schemas, and synthetic examples;
- capture and validation code;
- synthetic fixtures using reserved invalid domains;
- skill-loading and consumption rules.

The private corpus may contain attributed source-derived `page.md` text and WebP images. It must not contain credentials, cookies, authorization headers, browser profiles, localStorage, sessionStorage, HAR, video, traces, raw HTML mirrors, WARC/WACZ archives, or authenticated account content.

The capture tool must refuse a source-derived output root under `$SHIPGLOWS_ROOT`, another Git working tree, or a public plugin/cache path. Synthetic fixture mode is allowed only with `--fixture --no-network` and a temporary output root. A capture failure must remain visible and must not fabricate an image or text artifact that was not produced.

## Corpus Layout

```text
design-inspiration-library/
├── index.yaml
└── references/
    └── <reference-id>/
        ├── record.yaml
        ├── page.md
        ├── full-page.webp
        ├── thumbnail.webp
        └── segments/
            ├── 001.webp
            ├── 002.webp
            └── ...
```

`record.yaml` is the source of truth for one reference. `index.yaml` contains bounded searchable summaries, never page text or embedded images. Segment order follows the page from top to bottom. The default desktop viewport is 1440 x 900. The default segment height is 1600 px with 160 px overlap; both values must be recorded.

The schemas and synthetic sample live in `skills/references/design-inspiration/`.

## Record Contract

Every `record.yaml` contains:

- identity and lifecycle: `schema_version`, `id`, `lifecycle_status`, creation/update timestamps;
- provenance: original URL, normalized URL, final URL, capture timestamp, optional Wayback URL, and access status;
- capture facts: engine, viewport, full-page flag, segment height/overlap, warnings, unsupported elements, and explicit reason code/message when incomplete;
- taxonomy: page type, audience, styles, sections, copy patterns, and conversion goals;
- curation: summary, transferable patterns, and what must not be copied;
- rights: private-research purpose, attribution, redistribution, long-verbatim reuse, takedown, and notes;
- artifacts: relative paths or `null` for every expected artifact;
- SHA-256 checksums for every artifact that actually exists plus a deterministic bundle checksum.

The original private URL may remain in `record.yaml` for attribution and reproducibility. Console output and reports redact query strings by default.

## Status Values

Lifecycle status:

- `candidate`: captured or proposed but not reviewed as direction;
- `approved`: reviewed and eligible for Inspiration Gate shortlists;
- `rejected`: unsuitable, irrelevant, or rights-risky;
- `blocked`: retained as a minimal record but not consumable;
- `removed`: source-derived artifacts deleted; only a legally safe tombstone may remain.

Capture status:

- `captured`: complete minimum bundle exists;
- `partial`: at least one genuine artifact exists, but the minimum bundle is incomplete;
- `failed`: no usable capture bundle was produced;
- `blocked`: automation, owner policy, bot challenge, or access policy prevented capture;
- `auth_required`: the source requires credentials or a private session; no authenticated capture was attempted;
- `rejected`: capture intentionally refused for scope or rights reasons;
- `removed`: captured artifacts were removed.

Access status is one of `public`, `authenticated`, `paywalled`, `blocked`, or `unknown`.

## Taxonomy

Use bounded, lower-case slug values:

- `page_type`: `sales-page`, `landing-page`, `product-page`, `pricing-page`, `checkout-page`, `waitlist-page`, `webinar-page`, `lead-magnet`, `other`;
- `audience`: role, maturity, market, or buying-context tags;
- `styles`: visual tone and density such as `minimal`, `editorial`, `technical`, `premium`, `playful`, `dense`, `high-contrast`;
- `sections`: structural blocks such as `hero`, `features`, `proof`, `testimonials`, `pricing`, `faq`, `objections`, `comparison`, `cta`;
- `copy_patterns`: `problem-agitation`, `before-after`, `mechanism`, `proof-sequence`, `objection-handling`, `risk-reversal`, `cta-rhythm`;
- `conversion_goals`: `purchase`, `trial`, `demo`, `signup`, `waitlist`, `download`, `contact`.

Unknown values may be added as conservative slugs, but skills must filter rather than expand the taxonomy during unrelated work.

Capture creates a conservative candidate with `page_type: sales-page` and empty tags. Approval must explicitly classify the reference with a valid page type and at least one `style`, `section`, `copy_pattern`, and `conversion_goal`; `audience` remains optional. The reviewing skill may propose tags from the private bundle, but must not silently approve an unclassified reference.

If a page exceeds the WebP maximum dimension, `full-page.webp` is proportionally downscaled and the record records a warning; ordered segments retain the original capture scale for detailed study.

## Rights And Copyright Policy

- Keep the corpus private for research, analysis, and reference.
- Retain source attribution and capture time.
- Do not publish or redistribute screenshots or extracted page text.
- Summarize transferable principles; do not reproduce long source passages, protected expression, layouts, illustrations, or distinctive branding.
- Discovery is not permission to imitate. Every selected reference must state what to borrow and what not to copy.
- Respect source terms, owner requests, robots/access signals, and takedown requests. Do not use stealth or bypass controls.
- For removal, delete source-derived artifacts when required, retain only the minimum private tombstone that is legally safe, and follow the Versioning And Purge Policy when the corpus was synchronized through Git/LFS.
- Wayback is optional attribution metadata, never a capture-success dependency.

## Capture And Promotion Workflow

1. Capture only an explicit URL or bounded newline-delimited input list. The tool default limit is 50 URLs per run.
2. New entries start as `candidate` and retain source attribution.
3. Capture public content in a fresh ephemeral browser context without credentials or persisted storage. Scroll once with bounded waits for lazy loading.
4. Record `captured`, `partial`, `failed`, `blocked`, or `auth_required` explicitly. Never invent missing artifacts.
5. Retry only an explicitly named `candidate` whose prior capture failed, was blocked, or required authentication and produced no artifacts. Store the prior attempt's status and reason in the replacement record; never overwrite a successful or partial capture.
6. Review taxonomy, rights notes, transferable patterns, and anti-copy guidance before promotion.
7. Promote to `approved` only after operator review. Set `rejected`, `blocked`, or `removed` when appropriate.
8. If a skill discovers a useful URL outside a curation task, report its redacted URL and rationale; do not add it to the corpus until curation is in scope or the operator confirms.

The normal operator entrypoint is `/006-sg-design library add <public-url>`, followed by `/006-sg-design library approve <reference-id>`. Use `/006-sg-design library retry <reference-id>` only after a failed candidate's capture runtime was repaired. The curation tool, not a hand edit, writes retry/promotion metadata and synchronizes `index.yaml`. `library list` and `library status` read only the bounded index. See `skills/006-sg-design/references/design-inspiration-library-operations.md` for the activation contract.

Live capture reuses the server-wide Playwright Node installation: `node` and the global `playwright` CLI must be in `PATH`, and Chromium must exist in Playwright's shared browser cache. The Python tool resolves the `playwright` Node package from that CLI (including a CLI provided by global `@playwright/test`) and never requires the Python Playwright API or a per-project browser install. If discovery fails, repair the shared server installation indicated by the reason code: `playwright_cli_unavailable`, `node_unavailable`, `playwright_package_unavailable`, or `playwright_browser_unavailable`.

## Inspiration Gate

Trigger the gate for new visual direction, landing/sales-page creation, offer-page copy, major redesign, CTA/proof/objection sequencing, or an explicit inspiration request. Do not trigger it for routine fixes, token-only migrations, accessibility remediation, or narrow audits unless the operator asks.

The gate is bounded:

1. Read `index.yaml`, not every bundle.
2. Filter by the current page type, audience, style, section, copy pattern, and conversion goal.
3. Keep only `approved` entries by default; label any deliberately shown `candidate`.
4. Present at most five reference IDs with source links and one-sentence fit rationales.
5. Require operator selection before loading detailed `record.yaml`, `page.md`, thumbnails, or segments and before treating any reference as direction.
6. Record selected reference IDs in the active spec, design artifact, copy artifact, or audit decision context.
7. Summarize patterns and anti-copy constraints. Never paste long source text or redistribute screenshots.

If no reference is selected, continue from project/product/brand evidence without silently choosing one. Market, pricing, positioning, competitor, or differentiation analysis routes to the project competitor/inspiration registry instead.

## Validation

```bash
python3 tools/shipglows_metadata_lint.py skills/references/design-inspiration-library.md skills/references/design-inspiration/README.md
rg -n "capture_status|rights|checksum|candidate|approved|record.yaml|index.yaml" skills/references/design-inspiration
python3 -m unittest tools.test_capture_design_inspiration
```
