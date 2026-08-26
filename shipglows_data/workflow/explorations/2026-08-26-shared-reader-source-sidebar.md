---
artifact: exploration_report
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: "ShipGlows portfolio"
created: "2026-08-26"
updated: "2026-08-26"
status: draft
source_skill: 700-sg-explore
scope: "shared Flutter source-sidebar UI with project-local Readwise integrations"
owner: "Diane"
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "/home/claude/email-sidebar-app"
  - "/home/claude/shipglows_app/app"
  - "/home/claude/contentglows/app"
  - "/home/claude/contentglows/lab"
  - "shipglows_data/technical/decisions/provider-agnostic-source-ingestion-with-readwise-reader-pilot.md"
depends_on:
  - artifact: "shipglows_data/technical/decisions/provider-agnostic-source-ingestion-with-readwise-reader-pilot.md"
    artifact_version: "1.0.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Operator decision 2026-08-26: transfer email-sidebar-app to commandglows and make it public after a repository-history, secret, license, and publication audit."
  - "/home/claude/email-sidebar-app/email-app.tsx"
  - "/home/claude/email-sidebar-app/package.json"
  - "/home/claude/shipglows_app/app/pubspec.yaml"
  - "/home/claude/shipglows_app/shipglows_data/technical/design-system-authority.md"
  - "/home/claude/contentglows/app/pubspec.yaml"
  - "/home/claude/contentglows/shipglows_data/technical/design-system-authority.md"
  - "/home/claude/contentglows/lab/agents/sources/ingest.py"
  - "/home/claude/contentglows/lab/scheduler/scheduler_service.py"
next_step: "/100-sg-spec shared Reader source sidebar and project-local integrations"
---

# Exploration Report: Shared Reader Source Sidebar

## Context

The portfolio needs one efficient interface for reviewing sources captured in
Readwise Reader while preserving different downstream behavior in ShipGlows
and ContentGlows.

The existing `email-sidebar-app` expresses the desired three-pane interaction
well, but it is a Next.js/React v0 prototype with mock email data, Gmail-specific
presentation, local component state, and placeholder mutation handlers.
ShipGlows App and ContentGlows App are both Flutter applications, so the React
component cannot be imported into either production surface.

The architectural goal is not to share source-processing behavior. It is to
maintain the reusable source-review interaction once while each project retains
its own Readwise access, authorization tags, processing pipeline, state, and
project-owned outcomes.

## Outcome

An operator can open a consistent source inbox in ShipGlows App or ContentGlows,
review Reader documents efficiently, and invoke project-specific actions without
the two products maintaining divergent copies of the same complex interface.

The smallest valuable slice is:

1. list Reader documents selected for the current project;
2. filter and select one document;
3. preview bounded, sanitized content and provenance;
4. open the canonical document in Reader;
5. invoke the host project's `ingest` action;
6. mark seen or archive after confirmed processing;
7. expose clear loading, empty, partial-failure, and retry states.

## Architectural Boundary

```text
Readwise Reader
      |
      +----------------------+----------------------+
      |                                             |
ShipGlows local adapter                    ContentGlows local adapter
      |                                             |
      +------------- source_sidebar_flutter --------+
                         |
              shared interaction only
```

Reader remains the hosted library and distribution surface. The shared Flutter
package owns presentation behavior only. It must not authenticate with Reader,
store provider tokens, decide project routing, call agents, create Idea Pool
records, or own processing state.

## Options Compared

### Option A: Duplicate the screen in both repositories

- Why it fits: fastest first implementation and complete freedom for each app.
- What it changes: two independent Flutter ports of the same React prototype.
- Hidden risk: keyboard behavior, accessibility, responsive layout, defects,
  and interaction improvements drift immediately and must be fixed twice.
- Evidence gap: no evidence that the two interfaces need materially different
  interaction models.

### Option B: Shared Flutter UI package with local integrations

- Why it fits: both production applications use compatible Flutter and Dart
  versions, while their downstream source workflows are intentionally distinct.
- What it changes: the interaction contract is implemented once; each host
  supplies data, callbacks, authorization, and theme mappings.
- Hidden risk: an over-general package could become a second application
  framework or create design-token conflicts between the products.
- Evidence gap: representative compact, desktop, keyboard, and large-document
  layouts still require rendered proof.

### Option C: Keep the Next.js sidebar as an embedded micro-frontend

- Why it fits: preserves the existing prototype with the least visual porting.
- What it changes: both Flutter apps would embed or navigate to a separately
  deployed authenticated web application.
- Hidden risk: additional deployment, authentication, navigation, offline,
  responsiveness, accessibility, token, and failure boundaries for one panel.
- Evidence gap: no product need justifies a separately deployed source-review
  application.

## Recommendation

Choose Option B. Transfer `dianedef/email-sidebar-app` to the `commandglows`
organization, make it public only after a repository-history, secret, license,
and publication audit, keep it as the visual and interaction reference, and add
a versioned Flutter package to that repository under a path such as:

```text
email-sidebar-app/
├── app/                         # preserved Next.js reference
├── email-app.tsx                # preserved reference implementation
└── packages/
    └── source_sidebar_flutter/  # canonical reusable Flutter component
```

Both applications can consume the package through a pinned Git reference and
package subpath. The transferred repository remains named `email-sidebar-app`
during the pilot; renaming is not required to prove the architecture. Any
retained v0 integration must be relinked and validated after the transfer.

## Shared Package Responsibilities

The package should own:

- responsive list/detail composition;
- source selection and multi-selection presentation;
- keyboard focus, navigation, and shortcuts;
- search/filter controls whose behavior is supplied by the host;
- preview container and provenance presentation;
- action affordances for open, ingest, mark seen, archive, and delete;
- confirmation UI for destructive actions;
- loading, empty, error, retry, disabled, and processing states;
- accessible semantics and focus restoration;
- shared widget, interaction, and golden-test fixtures.

The package should expose a small provider-neutral presentation model, for
example:

```text
SourceSidebarItem
- id
- title
- authorOrPublisher
- summary
- publishedAt
- sourceType
- tags
- seen
- location
- processingState
- canonicalExternalUrl
```

It should accept host-provided callbacks or a narrow controller port:

```text
loadPage(query)
loadDetails(id)
openExternal(id)
ingest(id)
markSeen(ids)
archive(ids)
delete(ids)
```

The package must not expose Readwise tokens, API response objects, tag mutation
semantics, or project-agent concepts in its public interface.

## Host Responsibilities

### ShipGlows App

- select documents through the ShipGlows Reader tag convention;
- retrieve bounded Markdown or document details;
- pass the selected source to the appropriate source/veille/content agent flow;
- preserve source provenance in the resulting governed derivative;
- decide and apply ShipGlows-specific processed state.

### ContentGlows

- select documents through the ContentGlows Reader tag convention;
- expose Reader data to Flutter through authenticated backend endpoints;
- transform selected sources into ContentGlows newsletter/source input;
- create project-scoped ideas or invoke the selected content pipeline;
- preserve per-user and per-project ownership;
- decide and apply ContentGlows-specific processed state.

## Design-System Contract

The shared package owns interaction structure, not portfolio-wide visual tokens.
ShipGlows App and ContentGlows retain separate canonical design-system
authorities.

The package must therefore:

- consume Material semantic roles from `Theme.of(context)`;
- accept a bounded semantic style adapter for layout roles that cannot be
  expressed through standard Material themes;
- avoid brand colors, typography, spacing, radius, shadow, breakpoint, and
  motion literals in host screens;
- let each app build the adapter only from its own canonical tokens;
- prove the same behaviors under both host themes without claiming identical
  resolved visual values.

## Delivery Lots

### Lot 0: Freeze the useful prototype contract

- inventory the interactions worth preserving from `email-sidebar-app`;
- remove Gmail-only concepts from the target contract: compose, reply, sent,
  drafts, shopping, and personal mailbox categories;
- retain the high-value pattern: navigation, dense source list, reading pane,
  selection, search, and bulk actions;
- produce desktop and compact state references before porting.

Exit evidence: approved state and interaction inventory with explicit non-goals.

### Lot 1: Build the provider-neutral Flutter package

- create the package and its public presentation model;
- implement fake in-memory data and callback ports;
- implement responsive list/detail behavior and core states;
- implement keyboard and accessibility behavior;
- establish package versioning and changelog rules.

Exit evidence: widget tests, semantics tests, keyboard tests, and representative
goldens independent of either production backend.

### Lot 2: Pilot in ContentGlows

ContentGlows is the strongest first pilot because it already has an authenticated
Flutter application, backend integration endpoints, newsletter ingestion, an
Idea Pool, project context, and visible processing outcomes.

- add server-side Reader credential handling;
- add bounded list/detail/action endpoints;
- adapt Reader documents into the existing newsletter/idea workflow;
- mount the shared sidebar with ContentGlows theme mappings;
- retain IMAP as inactive fallback until the Reader pilot succeeds.

Exit evidence: one real Reader newsletter can be selected, previewed, ingested
into the correct project, traced into the Idea Pool, and safely marked processed
without exposing the Reader token to Flutter.

### Lot 3: Integrate ShipGlows App

- add its local Reader retrieval and mutation boundary;
- mount the same shared component with ShipGlows theme mappings;
- connect `ingest` to ShipGlows source classification and agent dispatch;
- preserve the selected source identity in the governed derivative.

Exit evidence: one Reader source reaches the selected ShipGlows agent flow and
produces a traceable project-owned derivative.

### Lot 4: Harden the shared interaction

- validate compact, medium, and expanded layouts;
- validate light, dark, text scaling, keyboard-only, and reduced-motion states;
- validate large documents, pagination, partial failures, retries, and stale
  selection behavior;
- add bulk mark-seen/archive only after single-document behavior is proven;
- add delete only with explicit confirmation and recoverability messaging.

Exit evidence: both host suites consume the same pinned package version and pass
their theme, interaction, security-boundary, and integration tests.

### Lot 5: Retire provisional paths deliberately

- decide whether the Next.js prototype remains an active design laboratory or
  becomes archived reference evidence;
- stop new IMAP feature work after Reader proves the accepted scenarios;
- preserve the IMAP implementation as a documented inactive fallback;
- update the Reader and source-ingestion decisions to reflect project-local
  adapters plus a shared UI package, not a central cross-project connector.

Exit evidence: canonical architecture and decision records match the deployed
ownership boundaries; no obsolete path is presented as active.

## Acceptance Scenarios

1. A source tagged for ContentGlows appears only in its default project view and
   can be turned into project-owned ideas.
2. A source tagged for ShipGlows can be passed to the correct agent flow with
   its Reader identity and URL retained.
3. A source tagged for both projects can be processed independently by both;
   one project's completion does not hide it prematurely from the other.
4. A failed ingestion leaves the Reader document available for retry and does
   not mark it successfully processed.
5. Archiving occurs only after the intended processing boundary succeeds.
6. Delete requires explicit confirmation and is never implied by ingest.
7. Reader credentials remain server-side or in the local trusted runtime and
   never enter Flutter builds, logs, source text, or prompts.
8. Newsletter HTML or Markdown is treated as untrusted input before rendering
   or agent use.
9. The package renders and remains keyboard-operable in both products without
   introducing a competing design-system authority.

## Risks and Unknowns

- The React prototype is visually useful but contains more mailbox behavior
  than the source-review product needs; copying it literally would inflate the
  package and preserve irrelevant Gmail metaphors.
- Reader tag updates through the API can replace the complete tag list if used
  carelessly; host adapters must use safe read/merge/write or granular mutation
  operations.
- Reader documents may contain hostile HTML or prompt-like instructions; both
  rendering and agent boundaries require sanitization and source labeling.
- Package releases can block host upgrades if the public API is too broad;
  begin with the proven MVP actions and add capabilities only from both-host
  evidence.
- ContentGlows currently couples newsletter ingestion to IMAP-shaped email
  objects in more than one path; the Reader pilot should introduce the smallest
  local source port that avoids duplicating the extraction pipeline.
- The exact Reader authentication model for a multi-user ContentGlows product
  remains outside this pilot. The accepted first horizon is a personal
  operator-only connection and must not silently become a general customer
  integration.
- Publishing the prototype can expose secrets, licensed assets, private content,
  or sensitive Git history even when the current tree looks safe; the full
  history and publication boundary require proof before visibility changes.
- Moving the repository can break consumers, badges, automation, or its v0
  linkage; these dependencies must be inventoried and retested after transfer.

## Non-Goals

- rebuilding the full Reader reading experience;
- embedding the private Reader web application;
- creating a central cross-project ingestion service;
- sharing ShipGlows and ContentGlows processing logic;
- duplicating Reader's library or full-text search index;
- supporting email compose, reply, send, drafts, or general mailbox management;
- deleting the preserved IMAP implementation during the pilot.

## Horizon Decision

The first horizon is resolved as a personal operator-only Reader connection for
the current portfolio. Customer-facing per-user Reader connections are outside
scope. This proves the workflow without prematurely creating customer OAuth,
entitlement, support, privacy, and multi-tenant obligations.

## Handoff

The direction is sufficiently clear for a cross-repository implementation spec.
The spec should own package extraction, ContentGlows-first integration,
ShipGlows integration, security boundaries, package release/versioning, proof,
documentation updates, and the explicit decision correction.

This exploration contains no implementation proof and does not claim the
package, Reader adapters, or integrations are ready, verified, or shipped.
