---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-18"
updated: "2026-08-18"
status: active
source_skill: 900-shipglows-core
scope: blog-and-cms-experience
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/006-sg-design/SKILL.md
  - skills/007-sg-content/SKILL.md
  - skills/406-sg-seo/SKILL.md
  - skills/references/editorial-content-corpus.md
  - skills/references/design-system-token-contract.md
  - skills/references/human-centered-interaction-heuristics.md
  - skills/references/public-author-and-social-identity-contract.md
  - tools/test_blog_and_cms_experience_contract.py
depends_on:
  - artifact: skills/references/editorial-content-corpus.md
    artifact_version: "1.4.0"
    required_status: active
  - artifact: skills/references/design-system-token-contract.md
    artifact_version: "1.2.0"
    required_status: active
  - artifact: skills/references/human-centered-interaction-heuristics.md
    artifact_version: "1.0.0"
    required_status: active
  - artifact: skills/references/public-author-and-social-identity-contract.md
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-18: blog and CMS experience needs a reusable authority comparable to shared authentication and license UI contracts."
  - "Audit 2026-08-18: existing editorial governance owns claims, schemas, and publication operations but not a provider-neutral product experience and adapter boundary."
next_review: "2027-02-18"
next_step: "/103-sg-verify blog-and-cms-experience-contract"
---

# Blog And CMS Experience Contract

## Purpose And Ownership

Define the reusable public contract for a ShipGlows blog or article system, whether its content comes from files, an Astro content collection, a headless CMS, or another project-approved source.

This contract owns the cross-project article model, experience anatomy, lifecycle semantics, accessibility floor, discovery outputs, adapter boundary, portability, and proof posture. It does not replace project editorial truth, product and brand authorities, claim review, the project design system, SEO specialist doctrine, authentication, authorization, or provider-specific security guidance.

Owner boundaries:

- Project editorial governance owns why the surface exists, who it serves, what may be claimed, and which content is canonical.
- This contract owns what any compliant blog/CMS surface must preserve across implementations.
- The project design system owns visual tokens, typography, layout primitives, motion, and component styling.
- `007-sg-content` owns the governed content lifecycle and publication intent.
- `006-sg-design` owns component composition, responsive behavior, accessibility, and rendered proof.
- `406-sg-seo` owns discovery audits, remediation, and specialist interpretation.
- `public-author-and-social-identity-contract.md` owns authorId resolution, public person/project identity, photos, contact details, and official social profiles.
- Authentication identifies an editor; server-side authorization decides who may preview, edit, schedule, publish, archive, or redirect.

## Project Adoption Declaration

Before implementation, each project declares:

1. the canonical content authority and repository or provider boundary;
2. the public blog index and article route families;
3. supported locales and locale-pair behavior;
4. the stable article identity and slug/redirect policy;
5. required core components and selected Optional modules;
6. publication, correction, archive, redirect, and deletion semantics;
7. media authority, sanitization boundary, cache and freshness posture;
8. preview and editorial authorization boundary;
9. sitemap, feed, structured data, and analytics posture when present;
10. the project checks and rendered proof required before publication.

A project may begin with Markdown or a content collection. A CMS is not a maturity requirement. The smallest compliant adapter and component set is preferred until real editorial operations justify more infrastructure.

## Canonical Content Model

The source may use different field names, but its adapter must resolve the following meanings without parallel hand-maintained truth.

| Meaning | Contract |
| --- | --- |
| Stable article ID | Project-owned immutable identity used for reconciliation and migrations; distinct from path and provider identity. |
| Provider record ID | Optional adapter metadata; never the only durable public identity. |
| Current slug | Locale-specific, validated public path segment governed by the project URL policy. |
| Redirect history | Prior public URLs and their explicit destinations or gone behavior. |
| Title and summary | Human-readable public text with declared length/display handling, never a substitute for identity. |
| Body | Structured or sanitized rich content that preserves semantic headings, lists, figures, tables, code, quotations, and links. |
| Publication status | One of the declared lifecycle states below, resolved by the adapter rather than inferred from a timestamp alone. |
| Published and updated times | Public history; corrections do not silently rewrite original publication truth. |
| Correction history | Optional public or internal record according to project policy, preserved during migrations. |
| Author and attribution | Stable `authorId`/`authorIds` resolved through the public identity registry; missing author uses its declared portfolio default. |
| Locale relationship | Explicit translation key or stable group identity; never guessed only from matching slugs. |
| Taxonomy | Project-governed categories/tags with stable identifiers when used for URLs or filtering. |
| Hero and inline media | Project-approved asset references with dimensions, alternatives, credit, crop/focal intent, and failure behavior. |
| Discovery metadata | Canonical title/description, canonical URL intent, social media, indexation, and structured-data inputs derived from canonical fields. |
| Provenance | Source authority, revision/version, and last verified synchronization evidence required by the project. |

Unknown or absent values stay unknown or absent. Adapters never fabricate an author, publication date, translation, taxonomy, claim, image alternative, or public state merely to satisfy a template.

## Experience Anatomy

### Required core

- **Blog index:** identifies the surface, exposes published entries in deterministic order, and represents the zero-result state honestly.
- **Article card:** uses a real heading/link relationship, concise summary, relevant metadata, resilient media behavior, and no nested interactive controls.
- **Article page:** exposes one logical h1, article landmarks and metadata, readable body content, canonical language, and a reliable way back to the surrounding surface.
- **Publication feedback:** distinguishes missing, unavailable, unpublished, retired, and redirected content rather than collapsing them into a false generic success page.

### Optional modules

- Table of contents for sufficiently structured long content.
- Author profile or contributor list when authorship is a meaningful public feature.
- Taxonomy filters, search, or archive navigation when the corpus justifies them.
- Related content based on declared deterministic rules, never undisclosed sensitive profiling.
- Pagination or progressive loading with crawlable and accessible navigation semantics.
- Sharing controls that work without dark patterns or mandatory tracking.
- Reading progress, reactions, comments, newsletter conversion, or personalization only under separate product, privacy, data, and accessibility authority.

Every selected module defines its empty, loading, error, and retired states. Optional modules must not block reading the article or make the required core dependent on client-side JavaScript when the project promises an indexable public document.

## Publication Lifecycle

Adapters map provider-specific states onto these public meanings:

- **Draft:** editable, incomplete, not publicly addressable or indexable.
- **In review:** awaiting an authorized editorial decision; still private.
- **Scheduled:** approved for a future instant; not treated as Published before that instant and successful delivery.
- **Published:** current canonical public version eligible for declared discovery outputs.
- **Corrected:** published with an explicit meaningful update or correction posture; original history remains truthful.
- **Archived:** intentionally removed from active discovery while retained according to project policy.
- **Redirected or gone:** old identity resolves through an approved redirect or explicit gone response rather than an unrelated fallback.

Preview is a view of a non-public revision, not a publication state. A preview must show its environment/revision clearly, use non-public authorization, resist indexing, and never be mistaken for the current production artifact.

Publishing is successful only when the intended revision is available at the intended canonical route and its required metadata/discovery outputs agree. A CMS dashboard success badge alone is not proof of public delivery.

## Accessibility And Reading Experience

- Preserve semantic document structure: one logical h1, ordered heading levels, lists, quotations, figures/captions, table headers, code semantics, and meaningful link text.
- Preserve reading order across visual layouts; sidebars, Table of contents, related content, ads, and calls to action do not interrupt the article's semantic sequence unexpectedly.
- Keep keyboard access and visible focus for all interactive controls, including filters, pagination, disclosure widgets, sharing, media controls, and embedded content.
- Support text resizing and 200% zoom without clipped prose, overlapping controls, forced horizontal page scrolling, or loss of functionality; wide code/tables receive bounded local overflow or an equivalent accessible presentation.
- Use project token authority for contrast, spacing, type, focus, and targets; body copy remains comfortably readable rather than optimized only for promotional density.
- Respect reduced motion and do not make reading, navigation, or meaning depend on animation.
- Provide media alternatives and useful images-off behavior; decorative media stays ignorable and informative media keeps meaningful text alternatives or transcripts.
- Keep dates, reading direction, quotations, names, numerals, and labels correct for the resolved locale and long localized labels.
- Announce meaningful asynchronous result changes without stealing focus; restore focus deliberately after overlays or route-level controls.

## SEO, Discovery, And Localization

- Each public article resolves one project-owned canonical URL. Query, preview, filter, tracking, provider, and temporary deployment URLs do not become canonical accidentally.
- Emit hreflang only for real, public, reciprocal locale variants. Include x-default only when the project has a genuine default/fallback destination.
- An absent, draft, stale, or invalid locale variant is omitted; never fabricate a translation or route users silently to content in another language.
- Derive title, description, canonical, social metadata, publication dates, author meaning, indexation, and structured data from canonical fields through one adapter path.
- Structured data must match visible content and actual organization/person/product authority; it never upgrades a claim or publication state.
- Only eligible Published content enters the production sitemap, feeds, related-content indexes, and internal discovery surfaces.
- Draft, preview, private, scheduled-before-release, duplicate, and retired content follows the declared noindex/exclusion policy.
- Redirects, canonical URL changes, merges, and removals update internal links, sitemap, feeds, hreflang, related content, and structured references coherently.
- Pagination, filtering, search, and infinite-scroll adaptations preserve crawlable destinations when organic discovery is part of the product intent.

## CMS Adapter And Portability

The CMS is an adapter and editorial workbench. It is not automatically the source of product truth, public identity, URL policy, claim authority, authorization, or rendered behavior.

Each adapter owns:

- provider/file field mapping into the canonical meanings;
- validation and normalization at ingestion/build/read boundaries;
- publication-state resolution and time-zone handling;
- stable project-owned identity reconciliation;
- rich-content rendering and sanitize/allowlist enforcement;
- asset URL, dimensions, alternatives, credit, and expiry handling;
- locale relationships and taxonomy mapping;
- cache and freshness metadata;
- deterministic query ordering, pagination, and duplicate detection;
- preview revision and public revision separation;
- provider failure translation into declared product states.

Portability requires an exportable representation of canonical fields, media references, locale relationships, publication/correction history, and a redirect manifest. A provider migration changes the adapter first. It must not silently change public IDs, URLs, author meaning, claims, timestamps, taxonomy identity, translation relationships, or indexation intent.

Compatibility aliases and mirrors are time-bounded migration mechanisms with one owner and removal condition. They never become a second writable authority.

## Freshness, Caching, And Failure

Projects declare whether public delivery is build-time, cached, stale-while-revalidate, request-time, or hybrid, plus the maximum acceptable staleness for corrections and removals.

- Cache keys include every field that can change public output, including locale and publication revision.
- A remote outage may serve a last verified public artifact only when project policy permits and the UI/operations do not claim newer state.
- Preview/editor failure remains distinct from public reader availability.
- A missing record, duplicate slugs, inconsistent locale graph, invalid rich content, expired private asset, or mismatched revision fails validation or produces the declared safe state.
- Retries and webhook/build events are idempotent where they can trigger publication.
- Publication evidence identifies the revision, adapter/source, route, and time without retaining secrets or private payloads.

## Privacy, Security, And Editorial Access

- Public rendering uses allowlisted content structures and trusted sanitization appropriate to the framework; raw provider HTML is not trusted by default.
- Embeds, scripts, iframes, forms, remote images, and downloads follow project CSP, privacy, consent, accessibility, and provenance policy.
- Preview tokens, draft API responses, internal notes, private media URLs, editor email addresses, provider metadata, credentials, and unpublished claims never enter public HTML, metadata, screenshots, fixtures, logs, or reports.
- Draft and preview content must not be indexable, enumerable through public APIs, or discoverable from production feeds, sitemaps, search, related-content queries, or predictable unauthorized routes.
- Editor authentication is distinct from server-side authorization for preview, edit, approve, schedule, publish, archive, redirect, and delete actions.
- High-impact actions preserve actor, revision, time, and outcome auditability according to project privacy and retention policy.

## Proof Matrix

| Claim | Minimum proof |
| --- | --- |
| Canonical model is implemented | Schema/adapter validation for required and optional fields, unknown values, duplicate identity, and invalid state. |
| Core reading experience works | Build/type checks plus rendered desktop/mobile, keyboard, focus, zoom, images-off/media fallback, and semantic inspection. |
| Discovery is coherent | Inspect canonical, hreflang, indexation, social metadata, structured data, sitemap/feed eligibility, redirects, and internal links for representative states. |
| Lifecycle is truthful | Prove draft, preview, scheduled, published, corrected, archived, and redirected/gone behavior without using production secrets. |
| CMS integration is safe | Contract tests at the adapter boundary, authorization tests, sanitization tests, and redacted failure evidence. |
| Migration is portable | Compare canonical exports/resolved values and redirect manifest before and after adapter replacement. |
| Provider failure is resilient | Exercise timeout/unavailable/stale/partial payload paths and confirm the declared last verified public artifact or safe error posture. |

Do not claim a CMS migration, accessible reading experience, SEO parity, or production publication complete from schema validation alone. Rendered, route, metadata, and provider-boundary claims require matching evidence.

## Pressure Scenarios

### BLOG-CMS-ADAPTER-SWAP

Move a representative corpus from files/Astro to a headless CMS, or between providers. Compare stable IDs, resolved canonical fields, URLs, redirect manifest, locale graph, authorship, timestamps, corrections, claims, media, taxonomy, and discovery intent. Only adapter-owned differences may change.

### BLOG-CMS-DRAFT-LEAK

Send Draft, In review, Scheduled, malformed, and preview-only records through public queries, caches, sitemap/feed generation, related-content selection, social metadata, and predictable routes. None may leak preview tokens, internal notes, private media URLs, editor data, unpublished claims, or indexable pages.

### BLOG-CMS-LOCALE-GAP

Remove, unpublish, stale, or corrupt one locale variant. The alternate link, locale selector, sitemap, and structured references omit it consistently, never fabricate a translation, and keep the current article usable.

### BLOG-CMS-RETIRED-CONTENT

Correct, archive, merge, redirect, and remove representative articles. Verify route status, public history, internal links, sitemap/feed, locale graph, related content, cache invalidation, and analytics interpretation follow the declared policy.

### BLOG-CMS-PROVIDER-OUTAGE

Exercise timeout, authorization failure, rate limiting, unavailable assets, partial records, and stale caches. Preserve the allowed last verified public artifact or safe error state, and never report an unverified revision as published.

### BLOG-CMS-ACCESSIBLE-READING

Render long localized content containing code, a wide table, figures, embedded media, a Table of contents, calls to action, and Related content. Verify semantics, reading order, keyboard, focus, 200% zoom, reflow, reduced motion, media alternatives, images-off behavior, and long-label handling.

## Stop Conditions

Stop, refine the project contract, or report partial when:

- no canonical content authority, public route family, stable identity, or publication-state mapping is declared;
- a CMS/provider selection would change cost, lock-in, security, data residency, workflow, or product behavior without operator authority;
- project editorial truth, public claims, URL policy, locale behavior, archive semantics, or permissions are missing or contradictory;
- the implementation creates a second writable content authority or duplicates metadata across templates;
- draft/preview isolation, sanitization, authorization, redirect safety, or private-data handling is uncertain;
- required rendered, discovery, migration, or provider-failure proof is unavailable for the completion claim;
- unrelated project, provider, dependency, deployment, publication, commit, or push scope would be required.

## Maintenance Rule

Update this shared contract when the cross-project article model, lifecycle, adapter boundary, accessibility floor, discovery invariants, security posture, or proof requirements change. Keep provider- and framework-specific mappings in project or platform references. Do not copy this contract into each project; project authorities declare adoption, intentional differences, and adapter details.
