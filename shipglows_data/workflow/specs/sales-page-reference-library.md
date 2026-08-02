---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: "ShipGlows"
created: "2026-07-15"
created_at: "2026-07-15 07:29:01 UTC"
updated: "2026-07-15"
updated_at: "2026-07-15 16:04:23 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "gpt-5.5 high"
scope: "cross-project design and sales-page copywriting inspiration library"
owner: "Diane"
user_story: "As a ShipGlows operator, I want to capture sales pages once as structured text and complete visual references, so design and copywriting skills can retrieve rights-aware inspiration across projects without confusing it with project competitor or business-intelligence registries."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "shipglows_data/workflow/explorations/2026-07-13-sales-page-reference-library.md"
  - "skills/references/private-data-repo-contract.md"
  - "skills/references/design-inspiration-library.md"
  - "skills/references/design-inspiration/"
  - "tools/capture_design_inspiration.py"
  - "tools/capture_design_inspiration_playwright.js"
  - "tools/test_capture_design_inspiration.py"
  - "skills/006-sg-design/SKILL.md"
  - "skills/006-sg-design/references/design-inspiration-library-operations.md"
  - "skills/007-sg-content/SKILL.md"
  - "skills/200-sg-redact/SKILL.md"
  - "skills/206-sg-audit-copy/SKILL.md"
  - "skills/207-sg-audit-copywriting/SKILL.md"
  - "skills/500-sg-design-from-scratch/SKILL.md"
  - "skills/502-sg-audit-design/SKILL.md"
  - "shipglows_data/business/project-competitors-and-inspirations.md"
  - "shipglows_data/editorial/content-map.md"
  - "shipglows_data/technical/code-docs-map.md"
  - "shipglows_data/technical/skill-runtime-and-lifecycle.md"
depends_on:
  - artifact: "shipglows_data/workflow/explorations/2026-07-13-sales-page-reference-library.md"
    artifact_version: "1.2.0"
    required_status: "draft"
  - artifact: "skills/references/private-data-repo-contract.md"
    artifact_version: "1.1.1"
    required_status: "active"
  - artifact: "shipglows_data/editorial/content-map.md"
    artifact_version: "0.10.0"
    required_status: "draft"
  - artifact: "shipglows_data/business/project-competitors-and-inspirations.md"
    artifact_version: "0.1.0"
    required_status: "draft"
  - artifact: "shipglows_data/technical/code-docs-map.md"
    artifact_version: "1.7.0"
    required_status: "reviewed"
  - artifact: "shipglows_data/workflow/playbooks/spec-driven-workflow.md"
    artifact_version: "0.18.3"
    required_status: "draft"
  - artifact: "skills/references/documentation-freshness-gate.md"
    artifact_version: "1.2.0"
    required_status: "active"
supersedes: []
evidence:
  - "Exploration report 2026-07-13/2026-07-15 defines the recommended capture-bundle library and rejects Wayback-only, full mirror, text-only extraction, and business-registry reuse."
  - "Operator clarification on 2026-07-15: this is a cross-project design and sales-page copywriting library, not the project competitor/inspiration business registry."
  - "Operator decision on 2026-07-15: chosen minimum capture bundle is record.yaml, structured page.md, full-page.webp, thumbnail.webp, and automatically sliced segments; Wayback is optional."
  - "Private Data Repo Contract 1.1.1 excludes durable cross-project marketing-example libraries from ~/.shipglows/private/data, so this spec defines a separate private asset corpus."
  - "Current design and copywriting skills do not load a shared visual/copy inspiration corpus."
  - "Playwright official Python screenshots docs consulted on 2026-07-15: full-page screenshot capture is supported. Source: https://playwright.dev/python/docs/screenshots"
  - "Pillow official docs consulted on 2026-07-15: image open/save flows support file-format conversion by extension, including WebP when the runtime has WebP support. Sources: https://pillow.readthedocs.io/en/stable/handbook/tutorial.html and https://pillow.readthedocs.io/en/stable/handbook/image-file-formats.html"
next_step: "none"
---

# Spec: Sales Page Reference Library

## Title

Sales Page Reference Library

## Status

The original library was implemented, verified locally, and shipped on `origin/main`. Both post-ship corrections—the shared global Node Playwright runtime and the operator-facing `/006-sg-design library add|approve|list|status` modes—are re-verified locally and await closure and ship. No live third-party capture was run in public proof.

## User Story

As a ShipGlows operator, I want to capture sales pages once as structured text and complete visual references, so design and copywriting skills can retrieve rights-aware inspiration across projects without confusing it with project competitor or business-intelligence registries.

## Minimal Behavior Contract

The system accepts a bounded list of public sales-page URLs or one explicit URL, including `/006-sg-design library add <url>` as the normal operator-facing route. It loads each page without storing credentials or private session data, extracts visible structured page text into Markdown, captures a full-page desktop visual as `full-page.webp`, derives `thumbnail.webp` and ordered image segments automatically, and writes a searchable `record.yaml` with source, status, taxonomy, provenance, and checksums into a private rights-aware corpus. New records remain `candidate`; `/006-sg-design library approve <id>` requires a review summary plus transferable and anti-copy guidance, then atomically synchronizes `record.yaml` and `index.yaml`. An optional existing Wayback URL is retained only as metadata; no archive request is made. If capture fails or is only partial, it still records the attempted source, reason, and safe retry route without fabricating missing artifacts. The easiest edge case to miss is treating a competitor, market, or positioning reference as the same thing as this reusable creative library; this corpus is for design/copy study and must stay separate from project-local business inspiration registries.

## Success Behavior

- Preconditions: the implementation agent has a URL or newline-delimited URL file, a configured private inspiration corpus root, browser automation available, and permission to fetch public pages for private research/reference use.
- Trigger: the operator or a ShipGlows skill runs the capture workflow for one or more sales-page URLs, or a design/copy skill enters the Inspiration Gate and asks for a bounded shortlist from the already-captured corpus.
- User/operator result: the operator can inspect each captured reference as a folder containing `record.yaml`, structured `page.md`, `full-page.webp`, `thumbnail.webp`, and `segments/*.webp`; design and copywriting skills can shortlist references by page type, audience, style, section, copy pattern, and conversion goal.
- System effect: source-derived text and screenshots are stored only in the private inspiration corpus; the public ShipGlows repo stores only schema, taxonomy, tool code, fixtures with synthetic data, and skill integration contracts.
- Success proof: metadata lint passes for changed ShipGlows artifacts; unit tests cover record validation, safe path resolution, failure records, WebP segmentation, and index updates; an integration fixture creates a complete synthetic capture bundle; selected live smoke captures are explicitly marked as private proof and not committed.
- Silent success: not allowed. Each capture must end with a visible status in `record.yaml` and a command/report summary that names captured, partial, blocked, and failed entries.

## Error Behavior

- Expected failures: invalid URL, unsupported scheme, network timeout, blocked robots/terms signal, authentication wall, paywall, cookie wall that cannot be safely bypassed, bot challenge, redirect loop, JavaScript/lazy-load failure, excessively tall page, image conversion failure, missing WebP support, checksum mismatch, duplicate ID, target path inside a public repo, and private corpus root missing or not writable.
- User/operator response: the capture report names the failing URL, `capture_status`, reason code, whether any safe partial artifacts were written, and the next safe retry route. It never asks for credentials unless the operator explicitly requested an authenticated capture workflow.
- System effect: failures create or update `record.yaml` with `capture_status: failed`, `blocked`, `auth_required`, or `partial`; no fake `full-page.webp`, `thumbnail.webp`, or segment files are created when capture did not produce them.
- Must never happen: secrets, cookies, OAuth tokens, private headers, session storage, authenticated account pages, raw HTML mirrors, HAR dumps, private browsing profiles, or source-derived screenshots/text committed to the public ShipGlows repository.
- Silent failure: not allowed. A capture that cannot produce the minimum bundle must be represented as an explicit failure or partial record, not skipped without trace.

## Problem

ShipGlows has design, copy, copywriting-audit, and design-system skills, but no shared corpus of durable creative references. As a result, useful sales-page examples live in conversations, screenshots, ad hoc bookmarks, or project-specific competitor notes. That makes future agents rediscover visual and copy patterns from scratch, and it risks mixing two different jobs:

- project-local business intelligence: competitors, alternatives, market inspiration, differentiation, pricing, and positioning;
- cross-project creative reference: visual hierarchy, page structure, persuasive copy patterns, proof blocks, objection handling, CTAs, density, rhythm, and page-level design direction.

The exploration concluded that Wayback-only catalogs are too unreliable for visual/copy study, while full mirrors and WARC-style replay are disproportionate and riskier. The operator approved the capture-bundle direction.

## Solution

Create a private, rights-aware design and sales-page copywriting inspiration library. Each reference is a self-contained capture bundle under a private corpus root, indexed by taxonomy and consumed through an Inspiration Gate in design and copywriting skills. The public ShipGlows repo receives only the contract, schemas, capture tooling, tests, and skill integration instructions; it never stores third-party page text or screenshots.

Wayback remains optional metadata only. A Wayback URL may be attached when useful, but capture success is defined by the private bundle, not by Internet Archive replay.

## Scope In

- Define the private corpus storage contract and environment variables.
- Create the capture-bundle schema:
  - `record.yaml`
  - structured `page.md`
  - `full-page.webp`
  - `thumbnail.webp`
  - `segments/*.webp`
- Create/update a private `index.yaml` format for searchable references.
- Implement a capture tool that can process one URL or a newline-delimited URL file.
- Extract visible page structure into Markdown while excluding hidden/script/style/private/session data and identifiable cookie boilerplate where safe.
- Capture desktop full-page screenshot, derive thumbnail, and automatically slice segments.
- Record capture status, failure reason, checksums, source URL, optional Wayback URL, viewport, timestamps, taxonomy, access policy, and rights notes.
- Add an Inspiration Gate contract for design and copywriting skills.
- Integrate the gate into the relevant design and copywriting skill routes.
- Keep this library separate from app blueprints and project competitor/business-inspiration registries.
- Add validation, docs coherence updates, and handoff notes for future implementation agents.

## Scope Out

- Public marketing page or public gallery for the captured references.
- Storing source-derived third-party text or screenshots in the public ShipGlows repository.
- Reusing `shipglows_data/business/project-competitors-and-inspirations.md` as the library.
- Autonomous scraping of arbitrary sites outside an explicit URL list or operator-confirmed curation flow.
- Full interactive mirroring, raw HTML replay, WARC/WACZ storage, or local hosting of third-party pages.
- Automated copy reuse, cloning, derivative page generation, or imitation of protected expression.
- Mandatory third-party bookmarking, moodboard, gallery, or inspiration-service accounts.
- Authenticated capture as a default workflow.
- Periodic refresh scheduling. This spec may define on-demand refresh metadata, but recurring crawling is a separate chantier.
- Mobile capture as a required minimum. It remains optional per reference when responsive behavior materially matters.

## Constraints

- Owned write surface for this `100-sg-spec` run is only `shipglows_data/workflow/specs/sales-page-reference-library.md`.
- Future implementation must preserve unrelated dirty work and must not modify the exploration report unless a later docs owner explicitly authorizes it.
- Public repo files may contain contracts, schemas, tests, synthetic fixtures, and tooling only.
- The private corpus root is not `~/.shipglows/private/data/`, because the active private-data contract explicitly excludes durable cross-project marketing-example libraries there.
- The canonical private corpus root is:

```text
${SHIPGLOWS_INSPIRATION_LIBRARY_DIR:-${SHIPGLOWS_PRIVATE_DIR:-$HOME/.shipglows/private}/design-inspiration-library}
```

- If the private corpus is versioned, its remote must be configured externally, for example with `SHIPGLOWS_INSPIRATION_LIBRARY_REPO`; the remote must not be hardcoded in shared doctrine or tools.
- Capture tooling must refuse to write source-derived captures inside `$SHIPGLOWS_ROOT`, a project repository, or any public plugin/cache path unless a test fixture mode uses synthetic content.
- The tool must not persist browser storage, cookies, localStorage, sessionStorage, HAR files, video, traces, or raw HTML by default.
- The tool must redact URL query parameters from logs by default while keeping the original URL in private `record.yaml` when needed for attribution and reproducibility.
- Generated outputs from skills may summarize patterns and cite source IDs/URLs, but must not reproduce long source text or redistribute screenshots.
- Implementation must be sequential. Do not invent parallel batches; shared skill contracts, docs maps, and capture tooling are integration-sensitive files.

## Test Contract

### Surface

- Stack/surface: ShipGlows skill contracts, Python CLI/tooling, private local asset corpus, browser capture.
- Primary proof mode: mixed.
- Proof order: schema/unit tests -> synthetic capture integration -> metadata lint -> skill contract rg checks -> private live smoke capture with redacted report -> readiness/verification.
- Proof owner routing: `105-sg-check` for local checks, `103-sg-verify` for final coherence, and `108-sg-browser` only if a later implementation needs independent browser-observable proof of a UI/tooling surface. The capture tool itself is not a replacement for `108-sg-browser` product proof.

### Manual checklist

- Needed: yes, for the first real operator corpus import or any live smoke using third-party pages.
- Checklist path: `shipglows_data/workflow/test-checklists/sales-page-reference-library.md`
- Required scenario coverage:
  - public static sales page capture
  - lazy-loaded page capture after scroll
  - blocked/auth-required page
  - duplicate URL or duplicate ID
  - private target path refusal
  - Inspiration Gate shortlist without operator selection
  - Inspiration Gate after operator-selected reference IDs
- Exception with proof: full manual review of all forty initial references is not required for implementation validation if the operator has not supplied the final URL list in this chantier. The implementation must prove the workflow with synthetic fixtures and a small operator-approved/private live sample, then leave batch import as an explicit run command.

### Required evidence stack

- Automated/unit checks:
  - `python3 -m unittest tools.test_capture_design_inspiration`
  - `python3 tools/capture_design_inspiration.py --fixture tools/fixtures/design-inspiration/sample-sales-page.html --output "$TMPDIR/shipglows-inspiration-test" --id sample-sales-page --no-network`
  - `python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/sales-page-reference-library.md`
- Contract checks:
  - `rg -n "Inspiration Gate|design-inspiration-library|SHIPGLOWS_INSPIRATION_LIBRARY_DIR|record.yaml|full-page.webp|thumbnail.webp|segments" skills tools shipglows_data/technical README.md`
- Private live smoke:
  - run against one or two public pages only when the operator or implementation context supplies safe URLs;
  - store proof under the private corpus, not in the public repo;
  - report only redacted status, paths, checksums, and source IDs.
- Device/native proof: not required because this is a desktop capture and skill-integration workflow, not a mobile UI feature.

## Dependencies

- Runtime:
  - Python 3.
  - Browser automation, preferably Playwright.
  - Image processing, preferably Pillow with WebP support, or a documented fallback to a maintained WebP encoder.
  - YAML read/write support through an existing project-approved dependency or a small dependency explicitly added with validation.
- Fresh external docs:
  - `fresh-docs checked` for Playwright full-page screenshot support using official Playwright Python screenshots docs on 2026-07-15: `https://playwright.dev/python/docs/screenshots`.
  - `fresh-docs checked` for Pillow image open/save behavior using official Pillow docs on 2026-07-15: `https://pillow.readthedocs.io/en/stable/handbook/tutorial.html` and `https://pillow.readthedocs.io/en/stable/handbook/image-file-formats.html`.
  - Internet Archive behavior is treated as optional metadata and was already researched in the exploration report; implementation must not depend on Wayback success.
- Document contracts:
  - `shipglows_data/workflow/explorations/2026-07-13-sales-page-reference-library.md` is the primary decision source.
  - `skills/references/private-data-repo-contract.md` governs what not to store under `~/.shipglows/private/data/`.
  - `shipglows_data/business/project-competitors-and-inspirations.md` defines the separate business registry that this library must not reuse.
  - `shipglows_data/editorial/content-map.md` and `shipglows_data/technical/code-docs-map.md` govern docs/editorial impact.
- Metadata gaps:
  - No material gap blocks the spec. The exact forty initial URLs are not present in the exploration report; the implementation must accept a URL file at run time and prove the workflow with fixtures/private smoke before batch import.

## Invariants

- The captured corpus is a private research/reference aid, not a redistribution surface.
- Each reference keeps original attribution: source URL, capture timestamp, access status, optional Wayback URL, and rights notes.
- The public ShipGlows repo never contains third-party screenshots, extracted third-party page text, raw HTML mirrors, cookies, or private browsing data.
- Inspiration discovery is not approval to imitate. A skill must present a bounded shortlist and require operator selection before treating references as design direction.
- Selected reference IDs must be recorded in the active spec, design artifact, or copy artifact so future agents can recover the decision.
- New references start as `candidate`; reviewed references become `approved`; unusable or rights-risky references become `rejected` or `blocked`.
- A reference with incomplete capture is searchable only if its `capture_status` and missing artifacts are explicit.
- The library remains separate from app blueprints, content repurpose packs, and project-level competitor/inspiration registries.

## Links & Consequences

- Upstream systems:
  - Exploration report supplies the chosen direction and rejected paths.
  - Private data contract supplies the negative storage boundary.
  - Design and copywriting skills supply the consumption routes.
- Downstream systems:
  - `006-sg-design`, `500-sg-design-from-scratch`, and `502-sg-audit-design` can use the Inspiration Gate for visual direction, page composition, design critique, and redesign references.
  - `200-sg-redact`, `206-sg-audit-copy`, and `207-sg-audit-copywriting` can use the Inspiration Gate for offer-page structure, proof sequencing, objection handling, CTA rhythm, and persuasion pattern comparison.
  - `007-sg-content` can route landing/sales-page copy tasks toward the copywriting gate without loading the whole corpus.
  - `300-sg-docs` may need to update technical docs and README after implementation because this introduces a new official private asset corpus and capture tool.
- Cross-cutting checks:
  - security/privacy: no secrets, sessions, cookies, authenticated data, private screenshots, or public repo leakage;
  - copyright: no public redistribution, no long verbatim source reuse in generated outputs, attribution retained, takedown/removal route documented;
  - performance/storage: compressed WebP outputs, segment limits, checksum-based dedupe, and no unbounded recurring crawler;
  - docs: code-docs-map and skill-runtime docs must describe the new tool and private corpus boundary.

## Documentation Coherence

Implementation must produce a Documentation Update Plan. Expected impacted docs/surfaces:

- `skills/references/design-inspiration-library.md`: new canonical shared contract for storage, taxonomy, capture bundle, Inspiration Gate, and rights policy.
- `skills/references/design-inspiration/README.md`: schema/catalog reference if the implementation chooses a folder for schemas/examples.
- `shipglows_data/technical/code-docs-map.md`: add mapping for `tools/capture_design_inspiration.py`, tests, and the new skill reference family.
- `shipglows_data/technical/skill-runtime-and-lifecycle.md`: describe the Inspiration Gate as a bounded support route for design/copy skills.
- `README.md`: mention the private inspiration corpus only if the implementation makes it an official operator-facing capability; do not publish captured examples.
- `shipglows_data/editorial/content-map.md`: update only if public content routing or skill launch guidance changes.
- Public site/docs: no default update, because the captured corpus is private. Public documentation may explain the capability later without exposing sources.

No update is required to `shipglows_data/business/project-competitors-and-inspirations.md` except a later optional cross-link or note if `300-sg-docs` decides the separation needs to be more discoverable.

## Edge Cases

- A URL requires login: mark `access_status: authenticated` and `capture_status: auth_required`; do not store credentials or attempt authenticated capture unless an explicit future workflow authorizes it.
- A URL blocks automation or shows a bot challenge: mark `capture_status: blocked`, keep source attribution, and do not bypass with stealth tooling.
- A page has cookie banners: dismiss only obvious non-destructive banners when safe; otherwise record banner presence and avoid hiding meaningful content.
- A page lazy-loads content: scroll from top to bottom once with bounded waits before screenshot and extraction.
- A page is extremely tall: capture full page when practical; if browser/image limits are hit, use viewport screenshots stitched or segment capture with `capture_status: partial` and reason.
- A page contains videos, carousels, animations, or interactive calculators: capture the default loaded state and record unsupported interactive elements in `record.yaml`.
- A page changes after capture: the library stores capture timestamp and must not treat the entry as current product truth.
- A page has terms/copyright restrictions or takedown request: mark as `rejected`, `blocked`, or `removed`; delete source-derived artifacts when required and keep only a minimal private tombstone if legally safe.
- Duplicate pages or redirects: normalize source URL, store final URL separately, and deduplicate by canonical ID plus checksums without losing attribution.
- A skill finds a new useful reference during unrelated work: it may report the URL and rationale, but must not promote it into the curated corpus unless curation is in scope or the operator confirms.

## Implementation Tasks

- [ ] Task 1: Create the shared Inspiration Gate and storage contract.
  - File: `skills/references/design-inspiration-library.md`
  - Action: Define purpose, storage/public-vs-private policy, environment variables, capture-bundle schema, status values, taxonomy, rights/copyright policy, source promotion workflow, and skill-consumption rules.
  - User story link: Gives fresh agents one canonical contract for capturing and using references safely.
  - Depends on: None.
  - Validate with: `python3 tools/shipglows_metadata_lint.py skills/references/design-inspiration-library.md`
  - Notes: This file must not include real third-party page text, screenshots, or private corpus contents.

- [ ] Task 2: Add schema/examples for synthetic-only validation.
  - File: `skills/references/design-inspiration/README.md`, `skills/references/design-inspiration/record.schema.yaml`, `skills/references/design-inspiration/index.schema.yaml`, `skills/references/design-inspiration/sample-record.yaml`
  - Action: Create schema references and a synthetic sample record showing required fields, capture statuses, checksums, taxonomy, and rights notes.
  - User story link: Makes the record format implementable and testable without exposing real references.
  - Depends on: Task 1.
  - Validate with: `rg -n "capture_status|rights|checksum|candidate|approved|record.yaml|index.yaml" skills/references/design-inspiration`
  - Notes: Samples must use fake URLs such as `https://example.invalid/...`.

- [ ] Task 3: Implement safe private path resolution and corpus bootstrap.
  - File: `tools/capture_design_inspiration.py`
  - Action: Add CLI arguments for `--url`, `--input`, `--id`, `--output`, `--status-only`, `--no-network`, and `--fixture`; resolve the default corpus root from `SHIPGLOWS_INSPIRATION_LIBRARY_DIR`; refuse public-repo targets; create `index.yaml` and `references/<id>/` only under the approved private root.
  - User story link: Ensures source-derived assets go to the right private corpus and not the public repo.
  - Depends on: Tasks 1-2.
  - Validate with: `python3 tools/capture_design_inspiration.py --help`
  - Notes: Logs must redact query strings by default.

- [ ] Task 4: Implement structured visible-text extraction.
  - File: `tools/capture_design_inspiration.py`
  - Action: Load a page or synthetic fixture, remove scripts/styles/hidden nodes, preserve headings, paragraphs, lists, buttons, forms labels, nav labels, links, and section order into `page.md`; exclude safely identifiable cookie boilerplate and private/authenticated content.
  - User story link: Preserves searchable copy and structure for copywriting skills.
  - Depends on: Task 3.
  - Validate with: `python3 -m unittest tools.test_capture_design_inspiration -k text`
  - Notes: Do not store raw HTML by default.

- [ ] Task 5: Implement visual capture, WebP conversion, thumbnail, and automatic segments.
  - File: `tools/capture_design_inspiration.py`
  - Action: Use browser automation for desktop full-page capture, convert to `full-page.webp`, derive `thumbnail.webp`, slice ordered `segments/001.webp`, `segments/002.webp`, etc., and compute checksums.
  - User story link: Preserves the visual hierarchy and gives vision-capable agents reliable slices.
  - Depends on: Task 4.
  - Validate with: `python3 -m unittest tools.test_capture_design_inspiration -k image`
  - Notes: Default segment height should be bounded, for example 1600px with a small overlap, and recorded in `record.yaml`.

- [ ] Task 6: Implement failure records, duplicate handling, and index updates.
  - File: `tools/capture_design_inspiration.py`
  - Action: Write explicit `record.yaml` statuses for captured, partial, failed, blocked, auth_required, rejected, and removed; update `index.yaml`; detect duplicate IDs/URLs/checksums without overwriting unrelated entries.
  - User story link: Makes failures and partial captures observable rather than invisible.
  - Depends on: Tasks 3-5.
  - Validate with: `python3 -m unittest tools.test_capture_design_inspiration -k status`
  - Notes: Failure records must not fabricate missing artifacts.

- [ ] Task 7: Add unit tests and synthetic fixture.
  - File: `tools/test_capture_design_inspiration.py`, `tools/fixtures/design-inspiration/sample-sales-page.html`
  - Action: Cover path refusal, schema validation, structured text extraction, screenshot fixture mode, WebP generation, segment naming, checksum generation, duplicate detection, and failure statuses.
  - User story link: Gives the implementation a repeatable proof path without real third-party content.
  - Depends on: Tasks 3-6.
  - Validate with: `python3 -m unittest tools.test_capture_design_inspiration`
  - Notes: Fixture content must be synthetic and safe to commit.

- [ ] Task 8: Integrate the Inspiration Gate into design skills.
  - File: `skills/006-sg-design/SKILL.md`, `skills/500-sg-design-from-scratch/SKILL.md`, `skills/502-sg-audit-design/SKILL.md`
  - Action: Add a bounded gate that triggers for new visual direction, landing/sales-page design, major redesign, and explicit inspiration requests; filter by taxonomy; present a shortlist; require operator selection before treating references as direction.
  - User story link: Lets design work benefit from the corpus without accidental imitation.
  - Depends on: Task 1.
  - Validate with: `rg -n "Inspiration Gate|design-inspiration-library|operator selection|reference IDs" skills/006-sg-design/SKILL.md skills/500-sg-design-from-scratch/SKILL.md skills/502-sg-audit-design/SKILL.md`
  - Notes: Do not load the whole corpus by default.

- [ ] Task 9: Integrate the Inspiration Gate into content and copywriting skills.
  - File: `skills/007-sg-content/SKILL.md`, `skills/200-sg-redact/SKILL.md`, `skills/206-sg-audit-copy/SKILL.md`, `skills/207-sg-audit-copywriting/SKILL.md`
  - Action: Add the gate for sales-page creation, offer-page copy, copywriting audits, CTA/proof/objection sequencing, and explicit inspiration requests; require source IDs in resulting specs/artifacts when references are selected.
  - User story link: Gives copywriting workflows searchable structure and persuasion patterns without copying source text.
  - Depends on: Task 1.
  - Validate with: `rg -n "Inspiration Gate|design-inspiration-library|copy pattern|reference IDs|operator selection" skills/007-sg-content/SKILL.md skills/200-sg-redact/SKILL.md skills/206-sg-audit-copy/SKILL.md skills/207-sg-audit-copywriting/SKILL.md`
  - Notes: Generated copy must summarize patterns and avoid long verbatim source reuse.

- [ ] Task 10: Update technical documentation and docs map.
  - File: `shipglows_data/technical/code-docs-map.md`, `shipglows_data/technical/skill-runtime-and-lifecycle.md`
  - Action: Map the new tool/reference family, validation commands, docs update triggers, and skill-consumption boundary.
  - User story link: Keeps future agents from missing the new official corpus and validation path.
  - Depends on: Tasks 1-9.
  - Validate with: `python3 tools/shipglows_metadata_lint.py shipglows_data/technical/code-docs-map.md shipglows_data/technical/skill-runtime-and-lifecycle.md`
  - Notes: These shared docs are sequential integration files; edit after implementation is coherent.

- [ ] Task 11: Update operator-facing docs only where justified.
  - File: `README.md`, optionally `shipglows_data/editorial/content-map.md`
  - Action: Add a concise mention of the private inspiration corpus if the implementation makes it an official operator-facing capability; keep public docs free of captured references.
  - User story link: Helps operators discover the feature without exposing private/source-derived assets.
  - Depends on: Task 10.
  - Validate with: `python3 tools/shipglows_metadata_lint.py README.md shipglows_data/editorial/content-map.md`
  - Notes: If no public/operator docs change is warranted, record `no editorial impact` with reason in the implementation report.

- [ ] Task 12: Run final validation and hand off to verification.
  - File: all changed files from Tasks 1-11, plus private smoke output outside the repo if safe URLs are supplied.
  - Action: Run metadata lint, unit tests, synthetic capture, targeted rg checks, docs coherence checks, and optional private live smoke.
  - User story link: Proves the library is usable by fresh agents and safe for rights-aware private storage.
  - Depends on: Tasks 1-11.
  - Validate with: commands listed in Test Strategy.
  - Notes: Do not commit private corpus assets; report only redacted private proof.

## Acceptance Criteria

- [ ] AC 1: Given the shared contract is opened, when a fresh agent reads it, then it can identify the public repo files, private corpus path, forbidden storage locations, capture bundle fields, status values, and skill-consumption rules.
- [ ] AC 2: Given a synthetic sales page fixture, when the capture tool runs in fixture/no-network mode, then it writes `record.yaml`, `page.md`, `full-page.webp`, `thumbnail.webp`, and ordered `segments/*.webp`.
- [ ] AC 3: Given a page cannot be captured, when the tool exits, then it writes an explicit failure or partial status without creating fake visual artifacts.
- [ ] AC 4: Given an output path inside `$SHIPGLOWS_ROOT` or another public repo, when capture would write source-derived assets there, then the tool refuses by default.
- [ ] AC 5: Given a URL with query parameters, when command output/logs are produced, then query parameters are redacted unless explicitly writing the private `record.yaml`.
- [ ] AC 6: Given duplicate URL or ID input, when capture runs, then it does not overwrite an unrelated reference and records the duplicate condition.
- [ ] AC 7: Given a reference is captured, when checksums are recalculated, then `record.yaml` matches the generated artifacts.
- [ ] AC 8: Given the private corpus has multiple entries, when a skill uses the Inspiration Gate, then it filters to a bounded shortlist instead of loading every `page.md` and every image.
- [ ] AC 9: Given a skill discovers a reference during unrelated work, when curation is not in scope, then it reports the URL/rationale but does not promote it into the library without operator confirmation.
- [ ] AC 10: Given a design or copy skill uses selected references, when it produces a spec/design/copy artifact, then selected reference IDs are recorded as decision context.
- [ ] AC 11: Given a project-level competitor or market-inspiration task, when an agent needs differentiation, market, pricing, or competitor context, then it routes to `shipglows_data/business/project-competitors-and-inspirations.md` instead of this creative corpus.
- [ ] AC 12: Given generated copy or design guidance references captured pages, when it is reported, then it summarizes transferable patterns and avoids long verbatim source reuse or screenshot redistribution.
- [ ] AC 13: Given docs are updated, when metadata lint and targeted rg checks run, then the new tool/reference family is discoverable in the technical docs map and skill runtime docs.
- [ ] AC 14: Given no final forty-URL list is present in the repo, when implementation validation runs, then the feature is still provable with synthetic fixtures and an optional private live sample; batch import remains a run-time operation using `--input`.
- [x] AC 15: Given implementation completes, when `103-sg-verify` runs, then it can verify storage safety, source-derived asset separation, skill integration, capture behavior, and docs coherence against this spec.
- [x] AC 16: Given an operator invokes `/006-sg-design library add <public URL>`, when the private capture succeeds, then the skill reports a candidate reference ID and one approval action without writing source material to the public repository.
- [x] AC 17: Given an operator invokes `/006-sg-design library approve <reference-id>` with a review summary, transferable pattern, and anti-copy constraint, then the candidate becomes `approved` and `index.yaml` is synchronized without normal manual YAML editing.
- [x] AC 18: Given a Wayback URL is supplied or known, when a reference is added, then it is retained as optional metadata and no Internet Archive request is required or performed.

## Test Strategy

- Unit:
  - `python3 -m unittest tools.test_capture_design_inspiration`
  - cover schema, path safety, URL normalization, status transitions, extraction transforms, image slicing, thumbnail generation, checksum generation, duplicate handling, and redacted logging.
- Integration:
  - synthetic no-network fixture capture into a temporary directory;
  - metadata lint for all changed ShipGlows artifacts;
  - targeted `rg` checks for Inspiration Gate integration across design and copywriting skills.
- Manual/private:
  - one or two safe public URL captures only if the operator or implementation context supplies URLs;
  - proof stays in the private corpus root;
  - final report includes redacted statuses, not raw source text or screenshots.
- Verification:
  - `/103-sg-verify sales-page-reference-library` must compare changed files, validation output, private-proof redaction, docs impact, and storage boundaries against this spec.

## Risks

- Security impact: yes. The workflow touches third-party pages, URLs, browser automation, local filesystem writes, screenshots, and extracted text. Mitigation: private corpus outside public repos, no credentials/cookies/session storage, path refusal, redacted logs, no HAR/video/traces/raw HTML by default, and explicit authenticated-capture exclusion.
- Copyright/terms risk: high. Screenshots and extracted visible text are source-derived third-party material. Mitigation: private research/reference use, attribution, optional Wayback link, no public redistribution, no long verbatim reuse, takedown/removal status, and no raw HTML mirror/replay.
- Product risk: medium. A reference library can bias agents toward imitation. Mitigation: Inspiration Gate shortlist plus operator selection, selected reference IDs, and "what to borrow / what not to copy" fields.
- Maintenance risk: medium. A large private corpus can become stale or heavy. Mitigation: compressed WebP, checksums, statuses, candidate/approved lifecycle, no recurring crawler in this spec, and on-demand refresh only.
- Performance/storage risk: medium. Full-page screenshots and segments can be large. Mitigation: WebP compression, thumbnails, segment bounds, dedupe, and private path outside the public repo.
- Docs risk: high. New official tool/reference family must be mapped so future agents do not bypass the storage or rights policy.

## Execution Notes

- Read first:
  - `shipglows_data/workflow/specs/sales-page-reference-library.md`
  - `shipglows_data/workflow/explorations/2026-07-13-sales-page-reference-library.md`
  - `skills/references/private-data-repo-contract.md`
  - `shipglows_data/business/project-competitors-and-inspirations.md`
  - `shipglows_data/technical/code-docs-map.md`
  - `shipglows_data/editorial/content-map.md`
  - target skill files named in Implementation Tasks.
- Safe sequential implementation order:
  1. shared contract and schemas;
  2. capture tool path/bootstrap;
  3. extraction and image generation;
  4. tests/fixtures;
  5. design skill integration;
  6. copy/content skill integration;
  7. technical/docs map updates;
  8. operator-facing docs only if justified;
  9. validation and verification handoff.
- Do not define `Execution Batches` for this chantier. The target files are shared contracts, skills, tools, and docs maps; sequencing is safer and clearer.
- Recommended implementation model/topology: `001-sg-build` delegated sequential, then `101-sg-ready -> 102-sg-start -> 105-sg-check -> 103-sg-verify -> 104-sg-end -> 005-sg-ship` only after readiness passes.
- Stop conditions:
  - a future implementation cannot keep source-derived assets out of public repos;
  - the private corpus path conflicts with `private-data-repo-contract.md`;
  - authenticated capture becomes required for the minimum workflow;
  - WebP generation cannot be made deterministic enough for tests and no maintained fallback is chosen;
  - skill integration would load the entire corpus by default;
  - implementation would reuse project competitor/business registry as the creative corpus;
  - validation requires storing unredacted screenshots/text/logs in public artifacts.
- Static-site/runtime exception:
  - This is a local CLI/tooling and skill-contract chantier, not a deployed runtime app. Sentry, deployed diagnostics/log-copy, and Paris/UTC build-time headers are not applicable unless a later implementation adds a long-running service or public UI.

## Post-Ship Correction: Operator Library Modes

- [x] Extend `006-sg-design` with `library add <url>`, optional known `wayback <archive-url>`, `library approve <id>`, `library list`, and `library status` activation semantics.
- [x] Add curation promotion support to `tools/capture_design_inspiration.py`; require a review summary, at least one transferable pattern, and at least one anti-copy constraint before changing `candidate` to `approved`.
- [x] Synchronize the bounded private `index.yaml` atomically from `record.yaml` during approval, and add read-only list/status output.
- [x] Add synthetic tests for add metadata, promotion/index synchronization, incomplete-review refusal, and redacted list output.
- [x] Update the shared contract, help catalog, and runtime/lifecycle documentation.
- [ ] Re-run `103-sg-verify`, `104-sg-end`, and `005-sg-ship` for this correction before calling the chantier shipped.

## Open Questions

None. The storage/privacy decision is resolved by defining a separate private inspiration corpus outside `~/.shipglows/private/data/`; the absence of the final forty URLs does not block implementation because the tool must accept a run-time URL file and prove behavior with synthetic fixtures/private smoke.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-07-15 07:29:01 UTC | 100-sg-spec | gpt-5.5 high | Created canonical chantier spec from the exploration report and resolved storage/privacy against existing contracts. | draft | /101-sg-ready sales-page-reference-library |
| 2026-07-15 07:36:20 UTC | 101-sg-ready | gpt-5.5 high | Reviewed structure, exploration alignment, current repository contracts, freshness, storage/security/copyright boundaries, task/AC/test coherence, and fresh-agent executability; promoted the spec after adding explicit official-doc freshness sources. | ready | /102-sg-start sales-page-reference-library |
| 2026-07-15 08:10:29 UTC | 102-sg-start | gpt-5.5 high | Recovered the prior uncommitted implementation, preserved forbidden pre-existing edits, validated the capture tool, synthetic fixture path, metadata/docs map, skill gate integration, and skill runtime sync. | implemented | /103-sg-verify sales-page-reference-library |
| 2026-07-15 08:18:18 UTC | 103-sg-verify | gpt-5.5 high | Verified all 15 acceptance criteria, local proof stack, storage/privacy/copyright invariants, skill integration, docs coherence, runtime sync, and public-repo leakage boundaries; no live third-party capture was run. | verified | /104-sg-end sales-page-reference-library |
| 2026-07-15 08:21:38 UTC | 104-sg-end | gpt-5.4 medium | Closed the verified chantier bookkeeping, reconciled the spec status/current flow with the live dirty scope, and prepared the bounded `/005-sg-ship` handoff without touching TASKS or CHANGELOG. | closed | /005-sg-ship sales-page-reference-library |
| 2026-07-15 08:26:12 UTC | 005-sg-ship | gpt-5.4 medium | Ran bounded pre-ship checks, confirmed runtime visibility and storage-leakage constraints, and prepared the exact chantier file set for commit/push to `origin/main`. | shipped | none |
| 2026-07-15 14:41:01 UTC | 001-sg-build | gpt-5.6-sol | Replaced the Python Playwright runtime dependency with the shared global Playwright Node runtime, installed Chromium once in the current server user's shared cache, and proved a complete live browser bundle against a local synthetic page. | implemented | /103-sg-verify sales-page-reference-library shared Playwright runtime correction |
| 2026-07-15 16:04:23 UTC | 001-sg-build | gpt-5.5 codex | Implemented the operator-facing 006-sg-design library modes, safe candidate approval with atomic private-index synchronization, bounded list/status output, and optional Wayback metadata without archive creation; focused synthetic tests and metadata checks passed. | implemented | /103-sg-verify sales-page-reference-library operator library modes correction |
| 2026-07-15 16:11:28 UTC | 103-sg-verify | codex | Re-verified the shared global Node Playwright discovery/cache contract and the operator-facing library modes with scenario-first synthetic capture/promotion proof, safety boundary checks, runtime sync, metadata lint, syntax, tests, and focused contract scans. | verified | /104-sg-end sales-page-reference-library post-ship corrections |

## Current Chantier Flow

- `100-sg-spec`: done, draft spec created with no open blocking questions.
- `101-sg-ready`: ready, strict readiness review passed and freshness source links recorded.
- `102-sg-start`: implemented, including the shared-Playwright-runtime and operator-library-mode corrections; focused unit, CLI, and synthetic-browser proof passed.
- `103-sg-verify`: verified, including the shared-Playwright-runtime and operator-library-mode corrections; no external live capture was needed for this local tooling/skill contract.
- `104-sg-end`: prior release closed; correction closure is ready.
- `005-sg-ship`: prior release shipped; both verified corrections remain unshipped.

Next step: `/104-sg-end sales-page-reference-library post-ship corrections`.
