---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.5.2"
project: ShipGlows
created: "2026-07-17"
updated: "2026-10-20"
status: active
source_skill: 900-shipglows-core
scope: preferred-stack-presets
owner: Diane
confidence: high
risk_level: medium
security_impact: no
docs_impact: yes
linked_systems:
  - skills/references/question-contract.md
  - skills/references/app-blueprints.md
  - skills/001-sg-build/SKILL.md
  - skills/100-sg-spec/SKILL.md
  - skills/101-sg-ready/SKILL.md
  - skills/references/identity-provider-selection.md
  - skills/references/backend-data-provider-selection.md
  - skills/references/cross-platform-runtime-selection.md
  - skills/references/browser-extension-lab.md
  - skills/references/obsidian-plugin-workflow.md
depends_on: []
supersedes: []
evidence:
  - "2026-10-07: selectively recovered the 2026-09-03 extension and Obsidian presets from dev; Windows runtime capabilities and historical validation are not imported."
  - "Existing ShipGlows Auth SDK Policy: apps use Flutter, sites use Astro, backend/data uses Convex, scripts/jobs/tools use Python, and auth is mostly Clerk."
  - "Operator correction 2026-07-17: public/SEO sites habitually use Astro and application surfaces use Flutter."
  - "Operator decision 2026-07-16: Vercel is the default web host; the dedicated-server deployment matrix applies only when a separate server runtime is genuinely required."
  - "Operator clarification 2026-07-17: Astro, Vercel, and Flutter are first-recommendation defaults, and an app request should prefer one Flutter codebase for web, iOS, and Android instead of stopping at a mobile-only build."
  - "Operator decision 2026-08-05: when a project includes one browser/web extension, its default monorepo source root is ext/; plural extensions/<name>/ is deferred until a second independently shipped extension exists."
  - "Operator decision 2026-08-11: portfolio-scale free-project limits, Flutter/Windows support, server authority, and billing cliffs must be evaluated separately for identity and backend/data providers."
  - "Operator decision 2026-08-11: universal Flutter targets Web, Android, iOS, Windows, macOS, and Linux; Firebase Auth owns identity, Convex HTTP owns backend/data, and Rust is reserved for a justified native engine."
  - "Operator decision 2026-08-11: Auth0 is a strong OIDC exception but fails the many-free-products default on Linux coverage, tenant isolation, and paid-plan cost."
next_review: "2026-11-07"
next_step: "none"
---

# Preferred Stack Presets

## Purpose

This reference records operator-approved ShipGlows technology defaults. Apply
these presets after the product platform footprint is known and before
blueprint matching or a broad greenfield technology comparison.

A preferred stack preset is not an app blueprint:

- a preset records the default technology direction approved by the operator;
- a blueprint is a validated app-archetype skeleton extracted from a shipped
  product and may additionally provide models, routes, folders, and conventions.

Do not make the operator repeatedly approve a preset already covering the
requested surfaces. Ask only about material product consequences that remain
uncovered, or about a justified exception.

These are first-recommendation defaults, not merely options that must appear in
a comparison. When they fit the product, lead with them, explain the resulting
surface split in plain language, and continue without asking the operator to
rediscover ShipGlows's habitual stack.

## Canonical Defaults

### Not used in the portfolio

- React, Next.js, React Native, Expo and Svelte are not used and are rejected for every surface. No ShipGlows project depends on them; do not propose them as options, comparison rows or defaults.
- Vue 3 is kept only for the Tauri webview (rare desktop exception) and for rich reactive UI inside the browser-extension and Obsidian presets below.

### Public and SEO-sensitive websites

- Framework: Astro.
- Hosting: Vercel.
- Recommend this pair first whenever a product needs a public website; use a
  different framework or host only for a documented product constraint.
- Use Astro for public, indexable, content-led surfaces such as landing pages,
  editorial pages, public menus, product/category pages, legal pages, and help.

### Cross-platform application surfaces

- Framework: Flutter.
- Targets: Flutter Web, Android, iOS, Windows, macOS, and Linux from the same application codebase.
- Hosting for the Flutter Web build: Vercel.
- Recommend the shared six-platform footprint first for a new consumer
  or business application, even when the initial request names only a mobile
  app or only a browser app. Narrow the targets only when the operator states a
  durable product reason or a verified platform constraint makes one target
  unsuitable.
- Use Flutter for authenticated or transactional application flows, dashboards,
  configuration, ordering, and other app-centric interaction.

### Combined public site and application

- Public/SEO surface: Astro on Vercel.
- Application surface: Flutter Web on Vercel plus Android, iOS, Windows, macOS, and Linux builds.
- Keep one backend and data authority for catalog, identity, permissions,
  availability, prices, orders, and other shared business state.
- Define an explicit navigation boundary between the Astro site and Flutter app
  while preserving brand, accessibility, analytics, and deep-link continuity.

#### Expected source layout

When the operator accepts the Astro plus Flutter preset with a shared backend, the expected source layout is:

- `site/` for the Astro public/SEO surface
- `app/` for the Flutter ordering application
- `backend/` for the shared backend authority
- `ext/` for the default single browser/web extension, when present
- `packages/contracts/` when typed cross-surface contracts are versioned separately

Do not create a plural `extensions/` umbrella for a single extension. If a
second independently shipped extension is added later, migrate to
`extensions/<extension-name>/` and update the monorepo governance and build
contracts together.

Deployment entrypoints such as Vercel build commands should be expressible from the monorepo root without relying on nested package discovery unless the project documents a durable exception.

### Browser extensions

- Greenfield preset: WXT, strict TypeScript, pnpm and Manifest V3.
- Derive launch browsers from the accepted product footprint; prepare distinct
  browser outputs without treating shared source as runtime parity.
- Keep simple UI native. Use Vue 3 only for rich reactive UI; keep background
  logic framework-free. React is not used.
- Use explicit popup, options, background and content-script entrypoints;
  request only the permissions justified by the accepted behavior.
- Disable WXT's automatic browser startup in the project configuration so host
  validation retains explicit ownership of disposable profiles.
- Use `browser-extension-lab.md` for build/host proof and
  `webextension-api-contract.md` for API decisions. The existing source lab
  covers scoped Chromium lifecycle diagnostics, not every supported browser.

Preserve an accepted existing stack. CRXJS remains a documented exception;
the preset alone never authorizes a migration or dependency installation.

### Obsidian plugins

- Greenfield preset: the official `obsidian` TypeScript API, strict TypeScript,
  pnpm and an esbuild-compatible artifact build.
- Support desktop and mobile by default. `isDesktopOnly: true` requires an
  essential verified Node.js or Electron dependency with no portable API path.
- Keep simple UI in Obsidian components, views, settings, DOM helpers and theme
  variables. Add Vue 3 only for rich reactive views, settings or modals.
- Mount UI inside host-owned containers and unmount it on surface close and
  plugin unload. Commands, vault access and registration remain host-owned.
- Use `src/main.ts` for the entry point, separate domain and host adapters, and
  keep the build's supported manifest, JavaScript and optional style artifacts
  explicit. Use `obsidian-plugin-workflow.md` for build, vault and host proof.

These presets select architecture, not current runtime capabilities. Missing
host-validation tooling remains a proof gap rather than an invented command.

### Supporting defaults

- Backend/data baseline: Convex through its official HTTP API from Flutter.
- Scripts, jobs, and internal tools: Python.
- Authentication baseline: Firebase Auth as the one product-wide identity
  owner, using official FlutterFire where listed and a REST/OIDC adapter on
  Linux because `firebase_auth` does not list Linux.
- Native engine baseline: none. Add Rust only for a measured native capability
  or performance requirement; keep Flutter as the UI shell.
- Backend/data provider selection: resolve through
  `backend-data-provider-selection.md`. For a portfolio of many pre-revenue
  products, Convex is the first recommendation; Firebase Auth does not imply
  Firestore.

Clerk remains valid for an existing product with release-device-proved web and
Android paths. It is inherited migration context, not the universal greenfield
default, and should not be copied into new products. Auth0 is an approved OIDC
alternative when enterprise requirements justify its official Convex
integration and paid tenant model; it is not the free-portfolio default.

These supporting defaults are starting assumptions, not universal mandates.
Provider suitability, official SDK support, transactional guarantees, legal or
payment requirements, cost, and portability may justify a different provider.
When an exception materially changes product operations or lock-in, research it
and ask one product-level decision rather than silently switching.

## Resolution Order

For greenfield work:

1. Establish launch and roadmap platform footprint.
2. Lead with and apply every compatible operator-approved preferred preset;
   presets are the first recommendation, not one neutral option among others.
3. Resolve an exact app blueprint if one exists; it may refine the preset but
   must not silently contradict it.
4. Research and ask only for material technology choices not already covered,
   including justified exceptions to a default.
5. Resolve identity and backend/data independently using their canonical
   matrices. Record project/deployment limits separately from usage quotas.
6. Record the accepted direction and remaining provider decisions in the spec.

## Pressure Scenarios

- `PSP-001 site only`: a public content or SEO site defaults to Astro on Vercel.
- `PSP-002 app only`: an application targeting web, iOS, and Android defaults to
  Flutter, with its web build on Vercel.
- `PSP-003 site plus app`: a product needing public SEO pages and transactional
  web/mobile experiences defaults to Astro plus Flutter, not Next.js plus
  Flutter and not Flutter for the SEO surface.
- `PSP-004 backend exception`: when the baseline backend lacks suitable official
  platform support or creates material transactional risk, compare a justified
  alternative and obtain the operator's product-level decision.
- `PSP-005 apparently mobile-only app`: a new app initially described only for
  iOS or Android is first framed as one Flutter codebase for Web, iOS, and
  Android; it is narrowed only from explicit product intent or verified
  platform constraints.
- `PSP-006 free portfolio`: a provider is not recommended from its headline
  free price alone; project/deployment count, pooled quotas, pause/hard-stop or
  metered behavior, and server-authority needs are recorded first.
- `PSP-007 auth is not data`: Firebase Auth may authenticate a Flutter product
  backed by Convex; Firestore is selected only from an independent data decision.
- `PSP-008 sparse browser extension`: a greenfield extension request with no technical direction receives the WXT, strict TypeScript, pnpm, Manifest V3 preset; native UI is used unless the accepted experience crosses the rich-interface threshold, where Vue 3 is added.
- `PSP-009 sparse Obsidian plugin`: a greenfield plugin request with no technical direction receives the official TypeScript and esbuild-compatible foundation, desktop-plus-mobile support, and native Obsidian UI unless a rich reactive surface justifies Vue 3.
