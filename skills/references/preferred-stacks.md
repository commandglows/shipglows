---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.7.0"
project: ShipGlows
created: "2026-07-17"
updated: "2026-09-04"
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
  - skills/references/webextension-api-contract.md
depends_on: []
supersedes: []
evidence:
  - "Existing ShipGlows Auth SDK Policy: apps use Flutter, sites use Astro, backend/data uses Convex, scripts/jobs/tools use Python, and auth is mostly Clerk."
  - "Operator correction 2026-07-17: public/SEO sites habitually use Astro and application surfaces use Flutter."
  - "Operator decision 2026-07-16: Vercel is the default web host; the dedicated-server deployment matrix applies only when a separate server runtime is genuinely required."
  - "Operator clarification 2026-07-17: Astro, Vercel, and Flutter are first-recommendation defaults, and an app request should prefer one Flutter codebase for web, iOS, and Android instead of stopping at a mobile-only build."
  - "Operator decision 2026-08-05: when a project includes one browser/web extension, its default monorepo source root is ext/; plural extensions/<name>/ is deferred until a second independently shipped extension exists."
  - "Operator decision 2026-08-11: portfolio-scale free-project limits, Flutter/Windows support, server authority, and billing cliffs must be evaluated separately for identity and backend/data providers."
  - "Operator decision 2026-08-11: universal Flutter targets Web, Android, iOS, Windows, macOS, and Linux; Firebase Auth owns identity, Convex HTTP owns backend/data, and Rust is reserved for a justified native engine."
  - "Operator decision 2026-09-03: greenfield browser extensions use WXT, strict TypeScript, pnpm, Manifest V3, and multi-browser output; simple UI stays native and rich UI uses Vue 3, not React."
  - "Operator decision 2026-09-04: extension API selection uses the shared portability, lifecycle, permission, trust-boundary, and behavioral-proof contract."
  - "Operator decision 2026-09-03: greenfield Obsidian plugins use the official TypeScript and esbuild-compatible contract, support desktop and mobile by default, and add Vue 3 only for rich UI with explicit lifecycle cleanup."
  - "Operator decision 2026-08-11: Auth0 is a strong OIDC exception but fails the many-free-products default on Linux coverage, tenant isolation, and paid-plan cost."
  - "Operator correction 2026-09-04: Flutter's cross-platform capability horizon remains a strong default, while launch scope follows product intent and is never expanded by technical capability alone."
next_review: "2026-09-11"
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

### Public and SEO-sensitive websites

- Framework: Astro.
- Hosting: Vercel.
- Recommend this pair first whenever a product needs a public website; use a
  different framework or host only for a documented product constraint.
- Use Astro for public, indexable, content-led surfaces such as landing pages,
  editorial pages, public menus, product/category pages, legal pages, and help.

### Cross-platform application surfaces

- Framework: Flutter.
- Capability horizon: Flutter Web, Android, iOS, Windows, macOS, and Linux from the same application codebase.
- Hosting for the Flutter Web build: Vercel.
- Recommend Flutter's shared capability horizon for a new consumer or business
  application. This is not a launch commitment: derive launch platforms from
  explicit product intent and current business evidence. When the initial
  request names only mobile or only browser, keep other supported targets
  available for the roadmap without silently adding their design, proof,
  packaging, or release to the current scope.
- Use Flutter for authenticated or transactional application flows, dashboards,
  configuration, ordering, and other app-centric interaction.

### Combined public site and application

- Public/SEO surface: Astro on Vercel.
- Application surface: Flutter with the accepted launch targets; its broader Web, Android, iOS, Windows, macOS, and Linux capability horizon remains available. Host Flutter Web on Vercel when Web is in scope.
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

- Framework and build system: WXT with strict TypeScript and pnpm.
- Browser contract: Manifest V3 with Chromium, Edge, Vivaldi, and Firefox output from one codebase. Safari is an available later target, not an assumed launch commitment.
- UI rule: use platform-native HTML, CSS, and TypeScript for a simple popup, options page, side panel, or injected control. Add Vue 3 through WXT's Vue module when the surface needs reusable stateful components, multi-step interaction, substantial reactive state, or a rich visual experience. React is not a default or fallback.
- Architecture: keep popup, options, side-panel, background, and content-script entrypoints explicit. Vue belongs only in UI entrypoints that need it; background and content scripts remain framework-free unless a concrete rendered surface requires otherwise.
- Security: request the minimum permissions and host access required by the accepted behavior. Broad host permissions, remote code, telemetry, authentication, network services, or persistent external data require an explicit product and trust justification.
- Proof: inspect before repository execution, then validate the built artifact through the Browser Extension Lab. Compilation alone is not popup, service-worker, or content-script proof.
- API contract: load `webextension-api-contract.md` before selecting browser APIs, permissions, messaging, injection, storage, or lifecycle behavior; shared source does not imply cross-browser API parity.

The default standalone source shape is `entrypoints/` for WXT-owned popup, options, side-panel, background, and content-script entrypoints; `components/` for shared Vue UI; `lib/` for framework-free domain and extension logic; and `public/` for static assets. Configure WXT browser startup as disabled in the committed project configuration so the ShipGlows managed session and isolated Lab remain the browser-profile authorities. Production artifacts remain in WXT's browser-specific `.output/<browser>-mv3/` directories.

Use CRXJS only as a documented exception for an existing Vite architecture whose integration cost or constraints make WXT unsuitable. Do not make the operator choose between WXT, CRXJS, Vue, or native DOM when the approved preset and requested experience resolve the answer.

### Obsidian plugins

- Foundation: the official `obsidian` TypeScript API, strict TypeScript, pnpm, and an esbuild-compatible build that emits the supported Obsidian artifact set.
- Platform contract: support Obsidian desktop and mobile by default. Set `isDesktopOnly: true` only when a verified Node.js or Electron capability is essential to the accepted behavior and no portable Obsidian API path exists.
- UI rule: use Obsidian components, DOM helpers, icons, commands, views, settings patterns, and CSS variables for simple or host-native interaction. Add Vue 3 for dashboards, rich views, complex settings, multi-step modals, or other substantial reactive interfaces. React is not a default or fallback.
- Lifecycle: mount each Vue application inside a container owned by an Obsidian view, modal, or settings surface; retain the application handle and unmount it deterministically when that surface closes and when the plugin unloads. Vue never owns commands, vault access, persistence, or plugin registration outside the Obsidian lifecycle.
- Styling: inherit Obsidian theme variables and interaction conventions before adding product-specific tokens. A visually rich Vue surface must remain accessible and coherent across supported themes and viewport classes.
- Proof: build only through the reviewed project command, then prove artifact integrity, host loading, requested interaction, diagnostics, and cleanup separately in the disposable Obsidian Lab.

The default source shape is `src/main.ts` for the official plugin entrypoint, `src/domain/` for host-independent behavior, `src/obsidian/` for commands and adapters, `src/ui/` for native views, and `src/ui/vue/` only when the rich-interface threshold is met. The repository root retains `manifest.json`, `versions.json`, and optional `styles.css`; the approved build emits `main.js` there for host and BRAT compatibility.

Do not add Vue to a plugin whose accepted experience is fully served by native Obsidian controls. Do not ask the operator to choose the rendering framework when the native-versus-rich threshold resolves it.

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

1. Establish the launch platform footprint and separately record the credible roadmap capability horizon.
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
  Flutter for those launch targets, with its web build on Vercel; other Flutter
  targets remain capabilities rather than implied launch deliverables.
- `PSP-003 site plus app`: a product needing public SEO pages and transactional
  web/mobile experiences defaults to Astro plus Flutter, not Next.js plus
  Flutter and not Flutter for the SEO surface.
- `PSP-004 backend exception`: when the baseline backend lacks suitable official
  platform support or creates material transactional risk, compare a justified
  alternative and obtain the operator's product-level decision.
- `PSP-005 mobile launch with broader horizon`: a new app described for iOS or
  Android uses Flutter's shared codebase while the named mobile surface remains
  the launch commitment. Web and other supported targets stay visible as a
  capability horizon until product evidence or an operator decision adds them.
- `PSP-006 free portfolio`: a provider is not recommended from its headline
  free price alone; project/deployment count, pooled quotas, pause/hard-stop or
  metered behavior, and server-authority needs are recorded first.
- `PSP-007 auth is not data`: Firebase Auth may authenticate a Flutter product
  backed by Convex; Firestore is selected only from an independent data decision.
- `PSP-008 sparse browser extension`: a greenfield extension request with no technical direction receives the WXT, strict TypeScript, pnpm, Manifest V3, multi-browser preset; native UI is used unless the accepted experience crosses the rich-interface threshold, where Vue 3 is added.
- `PSP-009 sparse Obsidian plugin`: a greenfield plugin request with no technical direction receives the official TypeScript and esbuild-compatible foundation, desktop-plus-mobile support, and native Obsidian UI unless a rich reactive surface justifies Vue 3.
