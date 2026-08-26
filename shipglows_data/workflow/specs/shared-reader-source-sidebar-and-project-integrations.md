---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.5.0"
project: "ShipGlows portfolio"
created: "2026-08-26"
created_at: "2026-08-26 12:03:34 UTC"
updated: "2026-08-26"
updated_at: "2026-08-26 19:12:00 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "public shared Flutter source sidebar and project-local Readwise Reader integrations"
owner: "Diane"
user_story: "En tant qu'operatrice de ShipGlows et ContentGlows, je veux consulter une meme bibliotheque Reader dans une interface efficace partagee, puis envoyer chaque source vers le pipeline propre au projet, afin de ne maintenir ni deux interfaces identiques ni un connecteur central qui confond leurs architectures."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "/home/claude/email-sidebar-app"
  - "/home/claude/shipglows_app/app"
  - "/home/claude/contentglows/app"
  - "/home/claude/contentglows/lab"
  - "shipglows_data/workflow/explorations/2026-08-26-shared-reader-source-sidebar.md"
  - "shipglows_data/technical/decisions/provider-agnostic-source-ingestion-with-readwise-reader-pilot.md"
  - "shipglows_data/technical/external-platforms/readwise-reader.md"
depends_on:
  - artifact: "shipglows_data/workflow/explorations/2026-08-26-shared-reader-source-sidebar.md"
    artifact_version: "1.1.0"
    required_status: draft
  - artifact: "shipglows_data/technical/decisions/provider-agnostic-source-ingestion-with-readwise-reader-pilot.md"
    artifact_version: "1.0.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Operator decision 2026-08-26: Reader is the shared hosted source library and distributor; each product owns its own minimal integration and downstream behavior."
  - "Operator decision 2026-08-26: email-sidebar-app may move from dianedef to commandglows and become public after audit."
  - "Operator decision 2026-08-26: the initial Reader connection is personal and operator-only, not a customer-facing multi-user integration."
  - "Operator decision 2026-08-26: replace the active React/Vercel preview with an interactive Flutter Web preview; retain the prototype only in Git history."
  - "Operator correction 2026-08-26: the first Flutter preview did not preserve the v0 visual language; the package preview must reproduce its full-height Gmail-like shell, global search, left navigation, dense rows, and in-place reader before consumer pins change."
  - "email-sidebar-app is a Next.js/React mock prototype whose large email-app.tsx component expresses the target interaction but has Gmail-specific concepts and placeholder handlers."
  - "ShipGlows App and ContentGlows App are Flutter applications with compatible Dart SDK constraints but separate canonical design-system authorities."
  - "ContentGlows already has IMAP-coupled newsletter ingestion, extraction, scheduling, authenticated backend surfaces, and an Idea Pool outcome."
  - "The Reader API supports document retrieval and mutations, but tag replacement semantics require safe merge behavior; Reader pages cannot be embedded as a normal cross-origin iframe."
  - "Fresh official Reader API documentation checked 2026-08-26 confirms cursor pagination, document update/delete, seen/location/tags fields, and per-token rate limits."
  - "Fresh official Readwise CLI/MCP documentation checked 2026-08-26 confirms Markdown detail retrieval and granular document tag operations."
  - "Authenticated Vercel logs for deployment dpl_BZx4aA81ziZ93nnBnygmanfTFLhn show that the restored Flutter cache contained a corrupt 255-byte Dart SDK archive; commit 2bb2807 adds bounded managed-cache validation and one rebuild attempt without changing externally supplied FLUTTER_BIN."
  - "Vercel deployment dpl_8hTwMRPEKiqqAR5qbaun5yQfZUwX rebuilt that corrupt cache, validated Flutter 3.41.7, completed the Flutter Web build, and reached Ready from exact commit 2bb2807."
next_step: "Collect operator visual acceptance on the exact 2bb2807 preview, then update consumer pins"
---

# Spec: Shared Reader Source Sidebar And Project Integrations

🟡 [ShipGlows portfolio] spec: Shared Reader Source Sidebar And Project Integrations | status: draft | path: shipglows_data/workflow/specs/shared-reader-source-sidebar-and-project-integrations.md | next: readiness review

## Title

Shared Reader Source Sidebar And Project Integrations

## Status

Ready as of 2026-08-26 and implemented on dedicated branches. The repository is
public under `commandglows`, the native Flutter package and both host adapters
are pushed, and the package preview has been rebuilt after operator visual
correction. Local package/demo analysis, tests, Web build, token-drift checks,
and four inspected Flutter captures pass at commit `182c919`. Vercel rejected
the matching deployment because its restored Flutter cache contained a corrupt
Dart SDK archive. Commit `2bb2807` detected that restored corruption, removed
only the guarded managed `flutter-3.41.7` cache, recloned it once, validated
Flutter, completed the Web build, and reached a matching Ready preview. Hosted
operator acceptance, consumer repinning, the real Reader-token pilot,
accessibility proof, review, and merge remain pending.

## User Story

En tant qu'operatrice de ShipGlows et ContentGlows, je veux consulter une meme
bibliotheque Reader dans une interface efficace partagee, puis envoyer chaque
source vers le pipeline propre au projet, afin de ne maintenir ni deux
interfaces identiques ni un connecteur central qui confond leurs architectures.

## Minimal Behavior Contract

Both Flutter products render the same versioned, provider-neutral source-review
package while supplying different data and action adapters. Reader remains the
hosted source library. ContentGlows maps selected Reader documents into its
newsletter/Idea Pool pipeline; ShipGlows maps them into its source and agent
flows. A document may be selected for both products and processed independently.
Successful ingest adds only the current project's processed tag; it does not
archive or delete the Reader document. Explicit archive and delete actions are
confirmed, observable, and performed through the owning host adapter. Reader
credentials never enter the public package or a Flutter client build.

## Success Behavior

- Preconditions: the operator has a valid Reader token in the host's trusted
  secret store; the source has the appropriate project-ready tag; the host can
  identify the current operator and destination project or agent flow.
- Trigger: the operator opens the source sidebar, selects a Reader document,
  and invokes the host-provided ingest action.
- ContentGlows result: a traceable, idempotent project-owned Idea Pool or
  newsletter-pipeline outcome is created through the existing local workflow.
- ShipGlows result: the selected Markdown and provenance reach the selected
  governed source/veille/content agent flow.
- Reader result: the adapter preserves unrelated tags and applies only the
  current project's processed tag after downstream success.
- Silent success: prohibited. The UI shows processing and terminal state, and
  the host records a redacted source/action/result audit event.

## Error Behavior

- Expected failures include missing or revoked token, Reader timeout or rate
  limit, malformed response, deleted document, stale pagination, tag conflict,
  oversized content, unsafe HTML, backend authorization failure, downstream
  pipeline failure, duplicate delivery, archive/delete failure, and offline UI.
- The selected source remains retryable after an ingest failure and receives no
  processed tag until the downstream commit succeeds.
- The UI retains or safely resets selection, explains the recoverable failure,
  and exposes retry without duplicating a committed outcome.
- Archive/delete failure is reported distinctly from ingest success. Delete
  always requires explicit confirmation and is never a side effect of ingest.
- Must never happen: exposing the Reader token or raw source content in public
  source, client bundles, analytics, crash reports, or logs; treating source
  instructions as trusted agent instructions; replacing unrelated Reader tags;
  processing one project and hiding the document from the other project.

## Problem

Reader already provides capture, reading, organization, and a common library,
so a central cross-project ingestion service would duplicate its distribution
role. However, ShipGlows and ContentGlows do not use sources in the same way and
cannot share downstream processing code. Duplicating the sidebar in both Flutter
repositories would also duplicate its responsive, keyboard, accessibility, and
state-management maintenance. The existing `email-sidebar-app` demonstrates the
desired dense three-pane workflow but is a Gmail-shaped React mock rather than a
reusable production component.

## Solution

Transfer `dianedef/email-sidebar-app` to the public `commandglows` organization
after a full publication audit. Preserve the Next.js prototype in Git history
as the original interaction reference, make `packages/source_sidebar_flutter`
the canonical reusable Flutter package, and deploy a synthetic Flutter Web demo
that consumes it directly. The package owns only presentation models and interactions.
Each host owns Reader authentication, API translation, authorization, project
routing, mutation safety, persistence, and downstream work.

Use project-specific selection and completion tags:

- `contentglows-ready` and `contentglows-processed`;
- `shipglows-ready` and `shipglows-processed`.

A source may carry both ready tags. Processing adds the corresponding processed
tag without automatic archive. Reader archive and delete remain explicit library
actions because they affect the shared corpus.

## Scope In

- Publication audit, organization transfer, and public-repository hardening for
  `email-sidebar-app`, with the external mutation executed only after approval.
- Preservation of the original Next.js prototype in Git history as a design
  reference, with no active React build or deployment surface.
- A synthetic, credential-free Flutter Web preview deployed from the package
  repository for operator review.
- A versioned `packages/source_sidebar_flutter` package consumed through a
  pinned Git revision and package path by both Flutter apps.
- Provider-neutral list, selection, preview, search/filter presentation, loading,
  empty, partial-error, retry, processing, archive, and delete-confirmation UI.
- Keyboard navigation, accessible semantics, focus restoration, responsive
  list/detail composition, text scaling, reduced motion, and both host themes.
- ContentGlows server-side Reader adapter, operator authorization, bounded API,
  local source normalization, idempotent Idea Pool/newsletter integration, and
  retained IMAP fallback.
- ShipGlows trusted-runtime Reader adapter and handoff to existing governed
  source classification and agent flows.
- Safe Reader tag merge, mark-seen, archive, and confirmed delete mutations.
- Per-project provenance, processing status, redacted audit, retry, and dedupe.
- Documentation and decision corrections across the affected repositories.

## Scope Out

- Reimplementing Reader's Library, Feed, reader, highlights, search index, or
  newsletter-subscription management.
- Embedding the Reader web application in an iframe.
- A central cross-project ingestion or processing service.
- Shared ShipGlows/ContentGlows agent logic or persistence.
- Customer OAuth, customer-provided Reader accounts, multi-tenant Reader token
  management, billing, entitlement, or customer support in this horizon.
- Email compose, reply, drafts, sent mail, contacts, or general Gmail behavior.
- Automatic archive or delete after ingest; batch delete in the first release.
- Deleting the existing IMAP implementation or migrating historical sources.
- Mirroring the complete Reader library or storing raw corpus content in Git.

## Constraints

- Reader is the source-of-record library; hosts persist only the minimum local
  provenance and derivative state required by their own workflows.
- The package public API contains no Reader response types, credentials, tag
  semantics, product routing, agents, Idea Pool concepts, or network client.
- Initial package model is bounded to `id`, `title`, `authorOrPublisher`,
  `summary`, `publishedAt`, `sourceType`, `tags`, `seen`, `location`,
  `processingState`, and `canonicalExternalUrl`.
- Initial host port is bounded to `loadPage`, `loadDetails`, `openExternal`,
  `ingest`, `markSeen`, `archive`, and `delete`; capability flags hide actions a
  host cannot safely provide.
- All Reader access and mutations run server-side or in a trusted local runtime.
  Flutter receives no token and no mutation authority beyond authenticated host
  endpoints.
- ContentGlows Reader routes are restricted to the configured operator identity
  and must not imply general customer availability.
- Source Markdown and HTML are untrusted. Preview is sanitized; agent prompts
  delimit source material and forbid it from changing tools, instructions,
  destination, ownership, or mutation policy. Preview rendering blocks remote
  images, tracking pixels, scripts, active embeds, and automatic external loads.
- `openExternal` accepts only a host-validated canonical HTTPS Reader URL. The
  public package never launches an arbitrary source-provided scheme or URL.
- Content and previews are bounded by explicit host configuration. Pagination,
  timeouts, backoff, and rate-limit handling are mandatory; unbounded library
  synchronization is prohibited.
- Reader tag writes preserve unrelated tags using a conflict-aware read/merge/
  write operation or a proven granular mutation. A stale write must fail and
  retry, not silently remove concurrent tags.
- Ingest uses a stable host-owned idempotency key derived from Reader document
  identity, destination, project, and pipeline contract version.
- Host persistence distinguishes `downstream_committed` from
  `reader_state_synced`. If the derivative commits but the processed-tag write
  fails, retry performs only the missing Reader synchronization and cannot run
  the downstream pipeline a second time.
- Public-repository audit covers the full Git history, ignored/untracked files,
  credentials, personal data, source fixtures, licensed assets/fonts, package
  metadata, CI, deployment variables, v0 linkage, and dependency licenses.
- The repository transfer and visibility change are external state mutations
  requiring an explicit execution-time approval and recorded before/after proof.
- Package consumers pin an immutable commit or release tag; floating branches
  are prohibited. Breaking public API changes require a major version.
- The existing IMAP code is preserved as an inactive documented fallback during
  the pilot and receives no parallel feature expansion.
- Preserve unrelated dirty work in every repository.

## Test Contract

- `surface`: public GitHub repository, Flutter package, ContentGlows Flutter and
  backend, ShipGlows Flutter/trusted runtime, Reader API, project pipelines.
- `proof_profile`: `cross-repository-security-sensitive-ui-integration`.
- `proof_order`: publication audit -> package unit/widget/semantics/goldens ->
  host adapter unit/contract tests -> host auth and idempotency integration ->
  synthetic Reader smoke -> real operator pilot -> cross-project scenario.
- Manual checklist path:
  `shipglows_data/workflow/test-checklists/shared-reader-source-sidebar-and-project-integrations.md`.
- Required scenarios: `empty-library`, `single-document`, `paginated-library`,
  `large-document`, `keyboard-only`, `compact-layout`, `both-host-themes`,
  `reader-timeout-retry`, `downstream-failure-no-processed-tag`,
  `contentglows-idea-pool`, `shipglows-agent-handoff`, `dual-project-tags`,
  `safe-tag-merge`, `explicit-archive`, `confirmed-delete`,
  `operator-auth-denied`, `prompt-injection-sentinel`, and `redacted-telemetry`.
- Required evidence: zero-exit automated suites, package analyzer, representative
  Flutter goldens, auth-scoping tests, mutation fixtures, idempotent reruns,
  redacted real-Reader pilot receipts, and `git diff --check` in modified repos.
- Visual proof is required for compact, medium, expanded, light, dark, 200% text,
  loading, empty, error, selected, processing, and delete-confirmation states in
  both host themes. Goldens complement rather than replace interactive keyboard
  and screen-reader checks.

## Dependencies

- Active Readwise Reader plan, personal API token, stable Reader API access, and
  documented mutation behavior available during implementation.
- `email-sidebar-app` ownership access under `dianedef`, plus permission to
  transfer to `commandglows` and make public.
- GitHub organization policies, secret scanning, branch protection, releases,
  and any retained v0 project linkage.
- Compatible Flutter/Dart constraints in `/home/claude/shipglows_app/app` and
  `/home/claude/contentglows/app`.
- Each app's canonical design-system authority and semantic theme mapping.
- ContentGlows authenticated backend, scheduler, newsletter extraction, Idea
  Pool, project context, and existing email-source service.
- ShipGlows source intake classification and governed skill/agent handoff.
- Fresh-docs gate: implementation must recheck the official Reader API/MCP
  documentation for authentication, pagination, rate limits, content fields,
  location/state mutations, delete semantics, and tag replacement immediately
  before coding; current observations are architectural evidence, not a frozen
  vendor contract.
- Fresh-docs verdict: `fresh-docs checked` on 2026-08-26 against the official
  Reader API, Readwise CLI/MCP, and Reader changelog. The chosen design follows
  cursor pagination, documented `seen`/`location`/`tags` updates, document
  deletion, Markdown detail retrieval, and published per-token rate limits.

## OWASP Security Gate

- Top 10:2025 categories considered: A01 authorization, A02 configuration, A03
  supply chain, A04 secret/transport handling, A05 HTML/URL/prompt injection,
  A06 abuse/replay/rate design, A08 package and state integrity, A09 redacted
  logging, and A10 timeout/partial-failure recovery.
- Trust boundaries: public Flutter package -> authenticated host -> personal
  Reader API -> project-owned pipeline. The source body and every Reader field
  are untrusted; the operator identity, destination, mutation, and idempotency
  state remain host-owned.
- Selected ASVS v5.0.0 requirements: `v5.0.0-1.3.1` for untrusted HTML
  sanitization, `v5.0.0-13.2.4` for external-resource allowlisting,
  `v5.0.0-13.3.1` for backend secret management, `v5.0.0-16.2.5` for sensitive
  log handling, and `v5.0.0-16.5.1` for non-disclosing error responses.
- Required proof: operator-denial tests, secret/bundle scans, sanitized preview
  fixtures, URL allowlist tests, idempotency/replay tests, redacted telemetry,
  dependency lock review, and explicit Reader outage/partial-success scenarios.
- Residual gap: no local Flutter SDK is callable in the current Linux runtime;
  Flutter analyze/test/goldens require an existing compatible CI or later
  callable Flutter runtime. This limits proof, not the implementation contract.

## Invariants

- One shared UI implementation; two project-owned integrations and outcomes.
- Reader remains usable independently of either product.
- A dual-tag source remains independently processable by both projects.
- Project success adds only that project's processed tag and never archives or
  deletes the shared source automatically.
- A failed downstream commit never creates a successful processed marker.
- Reruns cannot duplicate committed Idea Pool items or ShipGlows derivatives.
- A committed derivative remains discoverable even when Reader state sync fails;
  recovery completes the missing mutation without repeating business processing.
- Unrelated Reader tags survive every mutation initiated by either host.
- Credentials stay outside public Git history, Flutter bundles, logs, analytics,
  crash reports, UI models, source text, and agent prompts.
- Raw corpus content and personal Reader metadata never enter the public repo.
- Untrusted source text cannot select tools, destinations, permissions, tags,
  project ownership, or destructive actions.
- The shared package cannot become a third design-system authority.
- IMAP remains recoverable until the Reader pilot's acceptance evidence exists.

## Links & Consequences

- The existing provider-agnostic ingestion decision must be revised: Reader is
  the agnostic distribution layer; project-local adapters replace the proposed
  central `SourceEnvelope` connector for this workflow.
- The existing source-analysis spec remains relevant to downstream analysis but
  must not require a central Reader service or active IMAP-first development.
- Public package changes become a three-repository coordination concern. Version
  pinning and release notes are required before either host upgrades.
- Reader library-level archive/delete affects both products and therefore stays
  an explicit operator action, while processed tags are project-local state.
- If customer Reader accounts become a product requirement, that work needs a
  separate product, auth, privacy, tenancy, entitlement, and support spec.

## Documentation Coherence

- Update the exploration report and this spec together if the ownership or
  package boundary changes.
- Revise the provider-agnostic source-ingestion decision to record Reader as the
  shared library/distributor and each repo as the integration owner.
- Update ShipGlows architecture/source-intake docs with its Reader adapter,
  project tags, provenance, and agent handoff.
- Update ContentGlows architecture, source settings, newsletter ingestion, Idea
  Pool, and fallback docs with its operator-only Reader boundary.
- Add public README, license, security policy, contribution/release guidance,
  package API docs, supported Flutter constraints, screenshots, and migration
  notes to `email-sidebar-app` before advertising it as reusable.
- Record the exact immutable package revision consumed by both apps.
- Documentation is part of acceptance; stale claims that a central connector or
  IMAP-first path is active block completion.

## Edge Cases

- **Z — Zero:** no configured token, no Reader results, no matching project tag,
  empty content, or a deleted selected document produces a useful empty/recovery
  state rather than a crash or indefinite spinner.
- **O — One:** one document can be previewed, ingested, marked seen, explicitly
  archived, or explicitly deleted without relying on bulk behavior.
- **M — Many:** pagination, rapid selection, multi-selection display, duplicate
  deliveries, and a source tagged for both projects preserve stable selection,
  ordering, dedupe, and independent outcomes.
- **B — Boundary:** maximum preview/content size, 200% text, narrow viewport,
  long unbroken titles, expired token, rate limit, and last-page deletion are
  bounded and recoverable.
- **I — Integration:** package/host callback cancellation, backend/Reader partial
  failure, stale tag state, lost connectivity, package-version mismatch, and
  downstream commit succeeded but mutation failed are observable and retryable.
- **E — Error:** malformed payloads, unsafe HTML, prompt injection, 401/403/404,
  429, timeout, Reader 5xx, delete conflict, and audit-write failure cannot be
  presented as success or leak sensitive data.
- **S — Simple first:** the first vertical slice supports one document, one host
  action, and fake data before pagination, bulk mutation, or the second host is
  added; ContentGlows is the first production pilot.

## Implementation Tasks

1. **Audit and prepare the public repository.** Inventory the full Git history,
   secrets, personal/source data, licenses, dependencies, assets, CI, v0 linkage,
   remotes, redirects, and organization policy. Produce an explicit safe/unsafe
   publication verdict and transfer runbook. Do not transfer or publish without
   execution-time approval. Validate with history-aware secret and license scans,
   clean-tree review, build/tests, and recorded GitHub before/after metadata.
2. **Freeze the interaction contract.** Convert the React prototype into a state
   and shortcut inventory; retain navigation, dense list, reading pane, search,
   selection, and source actions; reject Gmail compose/reply/draft concepts.
   Validate approved desktop/compact references and explicit non-goals.
3. **Create `source_sidebar_flutter`.** Implement the bounded presentation model,
   capabilities, controller/callback port, fake repository, state machine, and
   public API. Validate analyzer, formatting, unit tests, API docs, semver policy,
   and a sample host independent of Reader.
4. **Implement interaction and design-system compliance.** Add responsive panes,
   keyboard/focus behavior, semantics, sanitizable preview slot, confirmations,
   and all loading/error states. Consume only host semantic themes/adapters.
   Validate widget, semantics, keyboard, golden, text-scale, reduced-motion, and
   both-host-theme evidence.
5. **Build the ContentGlows Reader boundary.** Store the personal token only in
   server secrets; restrict endpoints to the configured operator; implement
   bounded list/detail/action translation, pagination, redacted telemetry, and
   safe mutations. Validate unauthorized access, token absence, API fixtures,
   rate limits, retries, sanitization, and no secret in Flutter artifacts.
6. **Decouple ContentGlows ingestion from IMAP shape.** Introduce the smallest
   local `NewsletterSourceDocument`-style port so Reader and preserved IMAP input
   reuse extraction, project context, Idea Pool persistence, provenance, and
   idempotency. Validate equivalent synthetic inputs, partial failures, duplicate
   reruns, correct project ownership, and inactive fallback recovery.
7. **Pilot the package in ContentGlows.** Pin the package revision, map canonical
   ContentGlows tokens, connect list/detail/actions, and prove one real Reader
   newsletter reaches the correct Idea Pool/project outcome before its processed
   tag is applied. Capture visual, auth, mutation, and provenance evidence.
8. **Integrate ShipGlows.** Add its trusted-runtime Reader adapter, pin the same
   package, map ShipGlows tokens, and connect ingest to governed source
   classification and selected agent dispatch. Prove a real source produces a
   traceable derivative without exposing credentials or bypassing review rules.
9. **Harden shared state and mutations.** Implement conflict-aware tag merging,
   independent dual-project processing, mark-seen, explicit archive, confirmed
   single delete, cancellation, timeouts, and partial-success recovery. Validate
   concurrent/stale tag fixtures and the full dual-project manual scenario.
10. **Publish and pin the package.** After approved repository transfer/public
    switch, establish branch protection, release tag/changelog, immutable package
    pins, dependency-update flow, and consumer compatibility matrix. Validate a
    clean checkout of both apps against the exact public revision.
11. **Restore documentation coherence.** Apply every documentation consequence
    above, including correcting the central-connector decision and recording IMAP
    as inactive fallback. Validate metadata, links, diff checks, and terminology
    searches across all affected repos.
12. **Run cross-repository acceptance.** Execute automated suites and the manual
    checklist with one ContentGlows source, one ShipGlows source, and one dual-tag
    source. Record failures, redacted receipts, versions, commits, and screenshots;
    do not claim completion while any mandatory scenario lacks proof.

## Acceptance Criteria

- `email-sidebar-app` is public under `commandglows` only after its full-history
  publication audit passes and the approved transfer proof is recorded.
- Both Flutter apps consume the same immutable `source_sidebar_flutter` version;
  neither contains a forked copy of its widgets or interaction state machine.
- The package imports no Reader client and contains no product-specific models,
  routes, credentials, tags, agents, Idea Pool code, or brand literals.
- ContentGlows proves one real operator Reader newsletter becomes one correctly
  scoped, traceable, idempotent downstream outcome.
- ShipGlows proves one real Reader source reaches the intended governed agent
  flow with stable provenance.
- A dual-tag source can complete in either order; each project records its own
  processed state and neither automatically archives or deletes the source.
- Reader tag mutation preserves unrelated and concurrently added tags or fails
  visibly without destructive replacement.
- Ingest failure remains retryable and cannot apply a false processed marker.
- Explicit archive and confirmed single delete report their independent outcome.
- Tokens and raw corpus content are absent from public history, client builds,
  logs, telemetry, screenshots, fixtures, and agent-control instructions.
- Both host themes meet required responsive, keyboard, semantics, text-scale,
  loading, error, confirmation, and visual proof scenarios.
- IMAP remains documented and recoverable but inactive for new development.
- Architecture, decision, external-platform, package, and host documentation
  describe the deployed boundaries without stale central-connector claims.

## Test Strategy

Start with the package using fake data so interaction correctness is independent
of Reader and either app. Add deterministic Reader response/mutation fixtures to
each host, including pagination, 401, 404, 429, 5xx, timeout, stale tags, unsafe
HTML, and oversized Markdown. Test authorization and idempotency at the backend
boundary before any live token smoke. Then prove ContentGlows end to end, repeat
with ShipGlows, and finish with the dual-tag scenario and explicit mutations.
Use only synthetic content in automated/public fixtures; real-source evidence is
redacted and stored outside public repositories.

The readiness review must convert task validation clauses into exact repository
commands and checklist evidence paths after inspecting the implementation-time
toolchains. Vendor API assertions must be refreshed against official Reader
documentation immediately before adapter work.

## Risks

- Publicizing the existing repository may expose material retained in history,
  not just the current tree. Mitigation: history-aware audit and explicit gate.
- A shared package can accumulate host policy and become a hidden central app.
  Mitigation: narrow presentation-only API and dependency tests.
- Reader API or MCP capabilities may change or differ. Mitigation: official-docs
  freshness gate, adapter contract tests, and preserved IMAP fallback.
- Read/merge/write tags can race and remove another project's state. Mitigation:
  conflict detection, bounded retry, granular mutation when proven, and tests.
- Raw newsletters can carry tracking data, hostile HTML, or prompt injection.
  Mitigation: sanitize, block remote loads, validate outbound URLs, bound,
  delimit, redact, and deny source-controlled tools.
- Git dependency availability can block both products. Mitigation: immutable
  release pins, compatibility policy, and planned cache/vendor recovery.
- Operator-only endpoints can accidentally become customer-visible. Mitigation:
  explicit authorization, absent UI entitlement, denial tests, and docs.
- Reader account/library failure affects both projects. Mitigation: retry,
  observability, source-local idempotency, Reader-native access, and IMAP fallback.
- Visual parity may be mistaken for identical branding. Mitigation: shared
  interaction semantics with separate host-owned token adapters and goldens.

## Execution Notes

- Work in dependency order: public-repo audit and interaction contract, package,
  ContentGlows pilot, ShipGlows integration, mutation hardening, publication,
  documentation, then cross-repo acceptance.
- The audit can prepare the transfer, but execution must pause for approval before
  changing GitHub ownership or visibility because those are external mutations.
- Keep real Reader tokens and source content in private runtime stores only. Use
  synthetic fixtures for tests and screenshots whenever possible.
- The ContentGlows local normalization port is intentionally small; do not revive
  a shared cross-repository `SourceEnvelope` service through implementation drift.
- Do not auto-archive after processing in this horizon. Reconsider only with a
  separate shared-library lifecycle decision backed by dual-project evidence.
- Do not commit, push, release, transfer, or publish merely because this spec is
  accepted; those actions execute only under the operator-approved chantier.
- First reads are the three repositories' `AGENT.md`/`AGENTS.md`, canonical app
  architecture and design-system authorities, the prototype component, existing
  ContentGlows source routes/services, and active ShipGlows runtime boundary.
- Exact local checks are `flutter analyze`, `flutter test`, and
  `flutter build web --release` for the package preview and both apps when Flutter
  is callable, focused ContentGlows `pytest` for new Reader routes/services, and
  metadata lint plus `git diff --check` for governed documents.

## Open Questions

None blocking at draft authoring. The material horizon decisions are resolved:
Reader is the shared library; integrations remain project-local; the UI package
is public and shared; ContentGlows pilots first; the connection is personal and
operator-only; IMAP is retained inactive; processing does not auto-archive.
Implementation-time discoveries that change these boundaries require a spec
revision rather than an implicit choice.

## Skill Run History

- `2026-08-26 12:03:34 UTC` — `100-sg-spec` via `sg-planning`: converted the
  accepted exploration and operator decisions into this cross-repository draft;
  no implementation or external mutation performed.
- `2026-08-26 12:08:00 UTC` — `100-sg-spec` adversarial review: added remote
  content and outbound-URL controls plus split downstream-commit/Reader-sync
  recovery; no material decision remains open.
- `2026-08-26 12:17:09 UTC` — `101-sg-ready`: ready after current official
  Reader/OWASP evidence, exact execution/proof commands, security mapping, and
  operator transfer/publication authority were confirmed.
- `2026-08-26 12:51:57 UTC` — `102-sg-start`: transferred the prototype to the
  public `commandglows/email-sidebar-app` repository; added and validated the
  provider-neutral native Flutter package; implemented and pushed project-local
  ContentGlows and ShipGlows Reader adapters and Flutter surfaces; retained IMAP
  as inactive fallback. Package and ContentGlows CI are green, focused backend,
  runtime, Flutter, and metadata checks pass. Real-account, visual/accessibility,
  PR, and merge proof remain outside this implementation run.
- `2026-08-26 15:09:39 UTC` — `102-sg-start`: replaced the active React tree and
  Vercel configuration with a synthetic Flutter Web demo consuming the shared
  package directly. Local analysis, two responsive widget scenarios, Web build,
  metadata, token-drift, shell, and JSON checks passed; commit `5258dfd` was
  pushed and Vercel deployed the matching preview successfully. Operator visual
  acceptance remains the next proof.
- `2026-08-26 17:06:00 UTC` — `006-sg-design`: accepted the operator correction
  that the first Flutter port was visually unrelated to the v0 reference;
  rebuilt the shared package as a full-height source workspace with global
  search, left navigation, dense inbox rows, in-place reader, responsive mobile
  actions, centralized semantic tokens, and explicit light/dark preview themes.
  Package/demo analysis and tests, the release Web build, design-token drift,
  metadata, diff, and staged secret checks pass. Four inspected synthetic
  captures at 1440x900 and 390x844 are committed with `182c919`. The push
  succeeded, but Vercel deployment `dpl_BZx4aA81ziZ93nnBnygmanfTFLhn` failed
  immediately and its logs require Vercel authentication; no consumer pin was
  changed before operator visual acceptance.
- `2026-08-26 17:50:00 UTC` — `003-sg-bug`: authenticated to Vercel and traced
  deployment `dpl_BZx4aA81ziZ93nnBnygmanfTFLhn` to a restored managed Flutter
  cache whose Dart SDK archive was only 255 bytes and corrupt. Added guarded
  `flutter --version` validation, exact-target cache removal, one reclone, and
  one retry in commit `2bb2807`; externally supplied `FLUTTER_BIN` remains
  untouched. The commit was pushed and Vercel deployment
  `dpl_8hTwMRPEKiqqAR5qbaun5yQfZUwX` reproduced the corruption, rebuilt the exact
  cache, completed Flutter Web, and reached `Ready`. Operator visual acceptance
  remains pending.

## Current Chantier Flow

```text
exploration accepted
        |
        v
this implementation spec (ready)
        |
        v
implementation preflight complete
        |
        v
public repository transfer complete
        |
        v
shared package -> ContentGlows adapter -> ShipGlows adapter complete on branches
        |
        v
reference-faithful Flutter rebuild pushed -> cache repair deployed Ready
        |
        v
operator visual acceptance
        |
        v
consumer repin -> live Reader pilot
        |
        v
manual UI/accessibility proof -> review and merge
```

Current next action: collect operator feedback on the Ready preview built from
exact commit `2bb2807`. Only after visual acceptance should ContentGlows and
ShipGlows move their immutable package pins. The live cross-project Reader pilot
follows; implementation is not yet merged or fully verified against the
operator's live library.
