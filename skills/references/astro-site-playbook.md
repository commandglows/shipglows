---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-10-20"
updated: "2026-10-20"
status: active
source_skill: 900-shipglows-core
scope: astro-site-playbook
owner: Diane
confidence: medium
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/preferred-stacks.md
  - skills/references/web-image-performance-contract.md
  - skills/references/web-typography-contract.md
  - skills/references/blog-and-cms-experience-contract.md
  - skills/references/landing-page-experience-coherence.md
  - skills/references/editorial-content-corpus.md
  - skills/references/deploy-target-matrix.md
  - skills/010-sg-technical/references/performance-audit-playbook.md
  - skills/406-sg-seo/SKILL.md
  - skills/407-sg-translate/SKILL.md
  - skills/109-sg-auth-debug/references/astro-clerk.md
depends_on:
  - artifact: skills/references/preferred-stacks.md
    artifact_version: "1.5.1"
    required_status: active
  - artifact: skills/references/web-image-performance-contract.md
    artifact_version: "1.0.0"
    required_status: active
  - artifact: skills/references/web-typography-contract.md
    artifact_version: "1.0.0"
    required_status: active
  - artifact: skills/references/blog-and-cms-experience-contract.md
    artifact_version: "1.1.0"
    required_status: active
  - artifact: skills/references/editorial-content-corpus.md
    artifact_version: "1.5.0"
    required_status: active
supersedes: []
evidence:
  - "Operator portfolio rule: Flutter for apps, Astro on Vercel for public/SEO/content sites, Tauri as rare desktop exception, Convex for backend; React is never used."
  - "Local survey 2026-10-20 of shipglows_app/site (astro ^7.3.5, @astrojs/vercel ^11.0.11, @astrojs/sitemap, custom studio integration, en root + fr/ routes, articles collection with en/fr), contentglows/site (astro ^7.3.5, @astrojs/sitemap, @fontsource-variable/inter, no adapter, per-collection glob loaders, en/fr via locale field), dianedefores/site (astro 7.3.5 exact, @astrojs/react 7.0.0, React 19, Tailwind v4 via @tailwindcss/vite, output static, client:load x6)."
  - "Official docs fetched 2026-10-20: docs.astro.build/en/guides/upgrade-to/v7/ (Astro v7 current; Vite 8; Rust compiler stricter on HTML; compressHTML default 'jsx'; Sätteri default markdown processor; @astrojs/db removed)."
  - "Official docs fetched 2026-10-20: docs.astro.build/en/guides/content-collections/ (content.config.ts, glob/file loaders, astro/zod Zod 4, live collections in src/live.config.ts, live collections need an adapter)."
  - "Official docs fetched 2026-10-20: docs.astro.build/en/guides/internationalization/ (i18n keys, astro:i18n helpers, prefixDefaultLocale default false)."
  - "Official docs fetched 2026-10-20: docs.astro.build/en/guides/on-demand-rendering/ and /server-islands/ (output static default, prerender flag, adapter requirement for server:defer)."
  - "Official docs fetched 2026-10-20: docs.astro.build/en/guides/environment-variables/ (astro:env env.schema, context and access, PUBLIC_ governs import.meta.env only)."
  - "Official docs fetched 2026-10-20: docs.astro.build/en/guides/actions/ (defineAction, accept form, ActionError, actions are public endpoints)."
  - "Official docs fetched 2026-10-20: docs.astro.build/en/guides/images/ (Image/Picture, alt required, lazy and async defaults, image.domains and remotePatterns)."
  - "Official docs fetched 2026-10-20: docs.astro.build/en/guides/integrations-guide/vercel/ (adapter v11.0.16, isr option, middlewareMode edge, imageService)."
  - "Official docs fetched 2026-10-20: docs.astro.build/en/reference/configuration-reference/ (security.csp opt-in and not active in dev, security.checkOrigin default true, trailingSlash default ignore)."
  - "Official docs fetched 2026-10-20: docs.astro.build/en/reference/directives-reference/ (client:* directive priorities). The prefetch and cache/routeRules sections were not fully read; recheck before writing rules for them."
next_review: "2026-11-20"
next_step: "/103-sg-verify astro site playbook"
---

# Astro Site Playbook

## Purpose And When To Load

Load this playbook when a ShipGlows task creates, edits, audits, upgrades, deploys or explains an Astro site: public marketing pages, editorial or blog surfaces, documentation, SEO landing pages, multilingual content, or a small on-demand route that the site itself owns.

Do not load it for Flutter apps (use the flutter:* skills), Tauri desktop, Convex backend code, or Clerk troubleshooting alone (use `109-sg-auth-debug`, which links back here for Astro specifics).

This playbook owns Astro structure, configuration, rendering mode, islands, content schemas, routing, the Astro side of images and fonts, Vercel adapter use, and Astro upgrades. It links rather than duplicates:

- performance budgets, Core Web Vitals and phase checklists: `skills/010-sg-technical/references/performance-audit-playbook.md` (Phase 2 Astro);
- image pipeline and proof: `skills/references/web-image-performance-contract.md`;
- font pipeline, fallback and proof: `skills/references/web-typography-contract.md`;
- SEO audits, remediation and indexation decisions: `skills/406-sg-seo/SKILL.md` and its references;
- blog/CMS product experience: `skills/references/blog-and-cms-experience-contract.md`;
- landing-page coherence and copy sequence: `skills/references/landing-page-experience-coherence.md`;
- editorial truth, claims and content map: `skills/references/editorial-content-corpus.md`;
- translation audit and sync: `skills/407-sg-translate/SKILL.md`;
- Clerk on Astro: `skills/109-sg-auth-debug/references/astro-clerk.md`;
- hosting lane choice: `skills/references/deploy-target-matrix.md` (Vercel is the web default).

## Non-Negotiable ShipGlows Rules

These rules win over any Astro tutorial, skill default, scaffold template or agent habit.

1. Dev servers only through `shipglows-dev` (alias `s`): `s start -ProjectPath <p>`, `s open -ProjectPath <p>`, `s stop -ProjectPath <p>`, `s status`. Never run `npm run dev`, `pnpm dev` or `astro dev` by hand. Read the project's `ENVIRONMENT.md` before any local-server or tool-dependent work.
2. No `astro build`, `npm run build` or `pnpm build` unless the operator explicitly asks. Build-dependent proof becomes a stated proof gap with the exact command the operator can approve.
3. `astro check`, type checks, lint, tests and `astro sync`-style validation run only on explicit request or on a confirmed bug. No lint or test before commit.
4. Content-only changes (articles, Markdown, MDX, frontmatter, copy, skill pages) are never proved by a build. Their proof is frontmatter conformity with the declared collection schema, locale-peer parity, and editorial quality. See the Content Proof section.
5. Doppler only through `doppler run -- <project-declared command>` for a scope the project declares as dev or staging. Never print, persist or download secret values. Never use a production scope without explicit approval.
6. CI is manual. Never add push, pull_request or schedule triggers to an Astro workflow, and never run `gh workflow run` without operator agreement.
7. Never React. No `@astrojs/react`, `react`, `preact`, `solid-js`, Radix, shadcn-style component kits or framework islands for React-family code in new work. Interactive islands use vanilla `<script>` modules, Web Components, or the project's already-approved light framework (Vue 3 only where a rich reactive surface justifies it, matching the preset policy).
8. Git and GitHub persistence follows `$SHIPGLOWS_ROOT/skills/references/mutation-git-authority.md`; the operator's own instructions (for example no branches, worktrees or pull requests) take precedence.

## Project Structure

Use this layout for a ShipGlows Astro site. Source paths are relative to the site root (`site/` in a monorepo).

```text
site/
  astro.config.mjs           # single config; no environment-specific branching beyond env reads
  package.json               # packageManager pinned; engines matching the project
  tsconfig.json              # extends astro/tsconfigs/strict
  src/
    content.config.ts        # the ONLY collection registry (Astro 5+ location)
    content/<collection>/    # Markdown/MDX entries; one folder per collection
    pages/                   # routes; locale folders mirror routing policy
    layouts/                 # one BaseLayout owns head, metadata, skip link, CSP-compatible scripts
    components/              # presentational .astro components; islands only where justified
    styles/                  # global tokens and base; component CSS scoped in .astro
    i18n/                    # UI strings and locale helpers (no copy inside components)
    integrations/            # local integrations only; reviewed like production code
    data/                    # static typed data, not secrets
    env.d.ts                 # astro/client reference plus astro:env typings when used
  public/                    # unprocessed static files (robots, fonts only if not handled by the pipeline, icons)
```

Rules:

- Keep one canonical content registry. Do not create `src/content/config.ts` next to `src/content.config.ts`.
- `src/generated/` holds machine output. Never hand-edit it; regenerate through the project's declared script. Generated shell or installer artifacts stay out of the components tree.
- Test folders (`tests/`) belong to the project. Do not add a test runner for a content-only change.
- Do not commit `.env*` files holding real values. `.env.example` lists names only.
- Observed drift (`shipglows_app/site` includes a `src/integrations/studioPreview` integration; `contentglows/site` keeps `src/config/site.ts` reading `import.meta.env` directly). Both are accepted for their projects. New sites follow the structure above.

## Config And Integrations

- Set `site` to the canonical origin in every project. Canonical URLs, sitemap entries and absolute links derive from it. Never hardcode a production origin inside components.
- Set `trailingSlash` explicitly (`'never'` is the observed ShipGlows default in `contentglows/site`). Sitemap, canonicals and internal links must use the same policy. The Astro default is `'ignore'`, which is not acceptable as an implicit choice.
- Set `output` explicitly in every config even when it matches the default (`'static'`). A missing `output` is not a decision record.
- Declare `compressHTML` deliberately. Astro 7 changed the default to `'jsx'`. Inline-element spacing can change; treat any text-spacing change as visual regression.
- Use `redirects` in config for permanent path moves (observed pattern in `shipglows_app/site`: 301 entries for retired pricing and skill names). Each redirect entry must trace to a real moved URL. Do not use redirects to hide broken links.
- Keep integrations minimal. Required by default: `@astrojs/sitemap` for indexable sites. Add `@astrojs/vercel` only when the site needs on-demand features (see Rendering Mode). Add any other integration only with a named need and a rendered-proof plan.
- A custom integration that injects preview, studio or debug UI must be excluded from production output by a verifiable rule. `shipglows_app/site` pairs its studio integration with a production-exclusion assertion in its build script; that assertion runs only when the operator asks for a build.
- Sitemap filters must exclude `noindex` pages, draft and preview routes, tag listings that are intentionally thin, and placeholder pages. Observed `contentglows/site` pattern: a `NOINDEX_PATHS` set kept in sync with page-level `noindex`. Adopt the same pattern: one list, one owner, a comment naming the pages.
- `sitemap` `lastmod` comes from frontmatter dates, never from the build clock. Pages without a real date get no `lastmod`.
- Vite plugins (Tailwind v4 via `@tailwindcss/vite`, path aliases) are configured under `vite:`. Keep alias configuration in one place. Observed `dianedefores/site` uses an `@/` alias resolved from the config directory; that is acceptable, but do not add a second alias scheme.

## Content Collections And Schemas

Astro 7 uses the Content Layer. Collections load through loaders and validate through Zod.

- Define every collection in `src/content.config.ts` with `defineCollection({ loader, schema })`. Export one `collections` object.
- Loaders: `glob({ pattern, base })` for folders of Markdown or MDX; `file()` for one JSON or YAML list. Use the narrowest pattern that excludes drafts folders you do not want loaded, and prefer schema-level `draft` filtering for files that must stay in the repo.
- Import Zod from `astro/zod` (Zod 4). Do not install a separate Zod for content schemas.
- Use `reference()` for cross-collection links (for example, a skill page pointing at related skills) instead of free-text slugs. Free-text slugs are allowed only when the target is external to the collection set.
- Use one canonical date field per collection, for example `publishDate` for articles and `lastUpdated` as optional. Reject alias fields (`pubDate`, `date`, `publishDate` at once) in the schema. The observed `contentglows` schema accepts several aliases and maps them through a transform; that is a drift risk and not the ShipGlows pattern for new collections.
- Required fields are the minimum truthful set: title, description or summary, date, locale (where multilingual), stable identity (`translationKey` or equivalent), and status (`draft` boolean). Optional fields need a documented consumer.
- Stable identity: every multilingual pair shares one `translationKey` (observed `contentglows` naming). The observed `shipglows_app` articles use `articleKey` and `alternateSlug`. Both express identity; new collections use `translationKey`. Migrate an existing project only when the operator approves it.
- Drafts: a `draft: true` entry must be filtered explicitly in every listing, sitemap, feed, tag page, related-content query and RSS output. The schema flag alone hides nothing.
- Sorting: `getCollection()` order is not guaranteed. Sort in code by the canonical date with an explicit tiebreaker (slug).
- Rendering: use `render(entry)` for Markdown/MDX bodies. Static routes use `getStaticPaths()` for dynamic segments. Do not call `getEntry()` in a loop from a listing page; query once and filter.
- Live collections (`src/live.config.ts`, `defineLiveCollection`) read remote data per request and need an adapter. Use them only for content that must be fresh at request time. Build-time content stays in the standard collections.
- Any change to a schema requires restarting the dev session or syncing the content layer through the managed session. Do not edit the data store files under `.astro/`.

## Routing And i18n

Locale policy is French-first for ShipGlows-owned sites: French is the first-authoring and first-review locale for editorial work, and every public French page has an English peer (or the reverse, if the project declares English as source). The project's editorial corpus names the source locale. Do not guess it from file order.

Routing:

- New multilingual sites declare the `i18n` block in `astro.config.mjs` with `locales`, `defaultLocale`, and an explicit `routing.prefixDefaultLocale` value. The Astro default for `prefixDefaultLocale` is `false` (the default locale is unprefixed). Write the value even when it matches the default.
- Build URLs with `astro:i18n` helpers (`getRelativeLocaleUrl`, `getAbsoluteLocaleUrl`, `getAbsoluteLocaleUrlList`). Do not concatenate `/fr/` strings in components.
- Use `Astro.currentLocale` and `Astro.preferredLocale` for language-aware rendering. Do not redirect based on the browser language without a visible choice and a privacy review; a redirect that overrides a user's URL choice is a defect.
- Observed projects use folder-based locales (`src/pages/fr/...` next to `src/pages/...`) without an `i18n` block. Those projects are accepted as they are. Changing them to the `i18n` block is a migration, requires operator approval, and must keep every existing URL or redirect it explicitly.

Locale parity (the main editorial gate):

- Every public page or article in the source locale has a peer in each declared locale, or an explicit, documented gap. A missing peer is omitted from the alternate links, the language switcher and the sitemap. Never fabricate a translation and never route a user silently to another language.
- hreflang uses only real, public, reciprocal peers. Add `x-default` only when a real default destination exists.
- Use `translationKey` (or the project's identity field) for pairing. Do not pair by matching slugs.
- Translation and sync work routes to `407-sg-translate`. Mapping and gap audits use its procedure, not an ad hoc script.

UI strings: keep component copy in `src/i18n/` keyed by locale. Do not hardcode French or English labels inside `.astro` components that render for multiple locales.

## Rendering Mode

- Default: `output: 'static'`. Every page is prerendered at build time. Pages that need request-time data are the exception.
- Use on-demand rendering only with a written reason, one per route. Acceptable reasons: an authenticated area, a form handler that must write, a request-time personalization that cannot be static, a live collection, a server island that must read cookies or headers.
- Per-route opt-out: `export const prerender = false` on the page or endpoint, while the site stays `static`. Set `output: 'server'` only when most pages must render on demand, which should be rare for ShipGlows sites.
- On-demand rendering and server islands both need a server adapter. On Vercel, that is `@astrojs/vercel`. A static-only site deployed to Vercel does not need the adapter (observed `contentglows/site`).
- Vercel caching for on-demand pages: use the adapter's `isr` option (added in adapter 7.2.0) only when content can tolerate the expiration; document the `expiration`, the `bypassToken` for invalidation and the `exclude` paths that must always render fresh. Verify the exact option names in the adapter docs at adoption time.
- Vercel edge middleware is `middlewareMode: 'edge'` in the adapter options. Use it only when the middleware must run on cache hits. Default middleware runs only on cache misses; do not assume it protects cached responses.
- Server islands (`server:defer`) render dynamic fragments inside an otherwise static page. Use them for one small dynamic region (for example, a signed-in greeting). Fallback content is mandatory (`slot="fallback"`). Props must be serializable. Note that `Astro.url` inside an island is the island endpoint; read the page URL from the `Referer` header only when the design truly needs it. Keep props small: large props switch the request from a cacheable GET to a POST. Set a fixed `ASTRO_KEY` (generated with `astro create-key`) for rolling deployments or CDN caching.
- Hybrid mode is not a choice: the output mode is declared once in the config, and per-route `prerender` flags are the only exception mechanism.

## Islands And Interactivity

Default position: an Astro page ships zero client JavaScript unless an island is justified in writing.

Order of preference:

1. No JavaScript: CSS, native `<details>`, `<dialog>`, anchor navigation, form elements.
2. Inline `<script>` in an `.astro` component (bundled and deduplicated by Astro, typed, no framework). Use it for toggles, copy buttons, small menus, analytics events, consent controls.
3. Web Component (custom element) when the same behavior must survive across frameworks or be reused on pages with no Astro component tree.
4. The project's already-approved light framework island only when the interaction is a rich reactive surface. Vue 3 is the only permitted framework island in ShipGlows; it is never added for a single toggle. React is not permitted.

Directive rules when a framework island is used:

- `client:visible` is the default for below-the-fold islands. `client:idle` for non-urgent work. `client:media` for viewport-specific UI, with `client:visible` preferred when a CSS media query already hides the element. `client:load` only for above-the-fold interaction that cannot wait. `client:only="<framework>"` only when server rendering is impossible, and it needs a written reason.
- Never two island frameworks on the same page.
- Island event handlers stay short. Heavy work is deferred or chunked (INP target from the performance playbook).

Other rules:

- Do not hydrate for decoration. Animations use CSS; motion respects `prefers-reduced-motion`.
- Keyboard and focus behavior of every island is part of the component contract, not a later polish step.
- Scripts never run synchronously in `<head>` for analytics or consent. Load them after consent or interaction, using `defer` or `async`.
- Use `ClientRouter` (imported from `astro:transitions`; the older `ViewTransitions` name is unverified in this pass, so check the current export name before writing code) only when the navigation benefit outweighs the client-side cost. `transition:persist` is for stateful media that must survive navigation, not for layout polish. Prove with rendered navigation, back/forward and reduced-motion checks.
- `prefetch`: configure deliberately and do not prefetch every link on long pages. Verify the current prefetch options in the official guide before writing a prefetch rule; that guide was not fully read in this pass.

## Styling

- Tokens are the single source of visual values. A ShipGlows site consumes the project's design-token output (the observed `shipglows_app` pipeline generates tokens from `shipglows_data/design-system`) and never hand-copies color, spacing or type values into components.
- Component styles are scoped inside `.astro` `<style>` blocks. Global CSS is limited to tokens, reset, base typography and layout primitives.
- Tailwind CSS v4 through the official `@tailwindcss/vite` plugin is an accepted existing practice (observed `dianedefores/site`). New use requires the project's token file to remain the source of truth; utility classes must not bypass tokens.
- No full CSS framework imported whole. No icon font. Icons come from the project icon source as inline SVG or a sprite, with `aria-hidden` on decorative icons.
- Dark mode uses tokens with a declared `color-scheme`. Do not depend on `prefers-color-scheme` alone without a manual override where the product has one.
- Layout: a single container width and one spacing scale per site. The whole-page harmony rules in `landing-page-experience-coherence.md` apply to every landing page.

## Images And Fonts

Images (contract: `web-image-performance-contract.md`):

- Use `<Image>` and `<Picture>` from `astro:assets` for every local content image. Use `alt` on every meaningful image; Astro requires it. Decorative images use `alt=""`.
- Set `width` and `height` or an equivalent aspect ratio. Astro generates `srcset` and `sizes` when `layout` is set; verify the rendered candidate at representative widths.
- Astro defaults to `loading="lazy"` and `decoding="async"`. The LCP image overrides this explicitly: `loading="eager"` and `fetchpriority="high"`. Apply it only to the measured LCP candidate.
- Remote images are processed only from sources listed in `image.domains` or `image.remotePatterns`. Unlisted remote images render without processing. Keep the list short and reviewed.
- `image.dangerouslyProcessSVG` stays `false` unless SVG input is trusted and reviewed. SVG from users is never processed.
- Image service: Astro 7.4+ supports separate build and runtime services. Keep the default unless the image contract names a measured gap; adding a hosted optimizer needs the operator's approval and a data-processing review.
- Vercel Image Optimization through the adapter (`imageService`) is a hosting choice. It is not automatically better than the build-time pipeline; record which one serves each image class.

Fonts (contract: `web-typography-contract.md`):

- Self-host WOFF2 through the pipeline the project declares. The observed `contentglows/site` pattern (`@fontsource-variable/inter` pinned to a version) is an accepted self-hosted route. Confirm the axes, subsets and license before adoption.
- Declare `font-display` deliberately. Preload only the proven critical face. Metric-compatible fallback is required when a swap would shift layout.
- No runtime Google Fonts request unless the privacy and consent review has accepted it and CSP allows it.

## Data: Convex At Build Time Versus Runtime

- Static content comes from build-time data: collections, JSON or YAML files, or a build-time fetch from Convex through its HTTP API in frontmatter or `getStaticPaths`. Build-time reads are preferred for SEO and cacheability.
- Runtime reads (on-demand pages, server islands, actions) call Convex only for data that must be fresh per request. Each runtime read names its freshness requirement and cache policy.
- Only public Convex URLs and public client configuration may reach the browser (`PUBLIC_` names or `astro:env` public variables). Deploy keys and admin tokens never appear in an Astro project, in `import.meta.env` or in client bundles.
- Subscriptions (reactive Convex clients) are not used on static pages. An island that subscribes must be a justified interactive island and must unsubscribe when unmounted.
- A Convex outage must not break static pages: the build-time value is the fallback, and the page declares its freshness.
- Backend and data provider choice belongs to `backend-data-provider-selection.md`; this section covers only the Astro side.

## Environment Variables, Secrets And Security

- Use `astro:env` for typed configuration when the project needs validated variables. Declare them in `env.schema` with `context` (`client` or `server`) and `access` (`public` or `secret`).
  - `access: 'public'` plus `context: 'client'`: safe to ship to the browser.
  - `access: 'secret'` plus `context: 'server'`: never bundled; read only in server code.
  - Secret client variables are not supported. Do not invent a workaround.
- `import.meta.env` with the `PUBLIC_` prefix is the simple path for public values. Do not mix both systems for the same variable.
- `astro:env` is available in components, routes, middleware and modules. `astro.config.mjs` and scripts read `process.env`.
- Secrets live in Vercel environment settings and, for local development, in the project's declared Doppler dev scope through `doppler run --`. Never write them into the repo, the Markdown, the fixtures or a report.
- `security.checkOrigin` is `true` by default and protects on-demand pages from cross-origin unsafe requests. Do not disable it to make a form work; fix the origin.
- `security.csp` is opt-in (default `false`), and Astro notes it is not active in dev. Enable it when the project's script and style sources are known. Use hashes or narrow sources; do not add `'unsafe-inline'` as a shortcut. CSP proof needs a build or hosted preview, which requires operator approval; report the gap until then.
- Actions (`src/actions/index.ts`, `defineAction`): every action is a public endpoint. Validate every input with a Zod schema, check authorization inside the handler or in middleware, and use `ActionError` codes for expected failures. Form actions (`accept: 'form'`) require an on-demand page.
- Forms: no client-side-only validation as the security control; server-side validation is mandatory. Rate-limit or bot-challenge public write endpoints using the project's chosen provider; a honeypot alone is not a rate limit. Personal data collected by a form follows the consent and privacy references; do not submit a form that an observed page or link asked you to submit.
- Never place personal or sensitive data in URL query strings.
- Error pages do not reveal stack traces, environment names or internal URLs.

## Auth With Clerk

- Clerk on Astro requires an SSR adapter and server-side middleware. The Astro-specific checks, environment names (`PUBLIC_CLERK_PUBLISHABLE_KEY`, `CLERK_SECRET_KEY`), middleware placement and debug steps live in `skills/109-sg-auth-debug/references/astro-clerk.md`. Load that file; do not copy its content here.
- Reminders that bind this playbook: `clerkMiddleware()` does not protect routes by default; protection is explicit per route; signed-out marketing pages stay static when they do not need auth state.
- The Astro-Clerk reference was last reviewed 2026-04-26. Recheck the Clerk integration docs before an auth change.
- Authentication is not authorization. Server-side authorization decides who can preview, edit or publish content.

## SEO Hooks (Link, Do Not Duplicate)

Discovery audits, remediation, GSC evidence and indexation decisions belong to `skills/406-sg-seo/SKILL.md`. Astro-side hooks this playbook owns:

- Canonical URLs derive from `site` plus the trailing-slash policy in one place.
- Each indexable page sets its title, description, canonical, hreflang peers and social metadata from one shared head component fed by canonical fields.
- Each noindex page is also excluded from the sitemap. The sitemap filter and the page-level `noindex` come from the same list.
- Structured data is generated from visible canonical fields only. Author and organization identity follow `public-author-and-social-identity-contract.md`.
- Redirects are config-level 301s with a traced reason. Retired URLs with no successor return a deliberate gone or not-found response, not a generic home redirect.
- Sitemap and feeds include only Published, indexable entries.

## Handoff To The Flutter Web App

- A ShipGlows Astro site and a Flutter Web application are separate deployables with one brand and one identity owner. The handoff is an explicit navigation boundary (preferred-stacks, combined surface preset).
- Marketing pages link to the app with absolute URLs from a single config value. The app origin is never hardcoded in several components.
- The site does not embed the Flutter engine to fake an app, and the app does not render public SEO content that the site should own.
- Shared brand tokens and copy keys come from the same sources, so the handoff does not look like two products.
- Session or auth state does not pass from Astro to Flutter in URL parameters. Use the identity provider's documented flow.
- Measure the handoff: a second engine download on every navigation is a performance defect (performance playbook, Flutter Web section).

## Deployment On Vercel

- Vercel is the web default. Use `@astrojs/vercel` only when on-demand or server features are required; a static site deploys without the adapter.
- The Vercel build command and root directory are declared once in project settings. For a monorepo, the site's root is `site/`; deployment entrypoints must be expressible from the monorepo root without nested discovery surprises.
- Environment variables are set in Vercel per environment (Production, Preview, Development). Preview deployments use non-production values only.
- Deploying, promoting, aliasing and changing domains are actions the operator approves. Hosted previews are the preferred real-measurement surface for CWV and CSP proof, and creating one is still an explicit request.
- Redirects in config are the deployment-level redirect mechanism. Do not add a second redirect layer in `vercel.json` for the same paths.
- Preview deployments are not indexable: add `noindex` at the preview host level and never submit preview URLs to search.
- Do not change production DNS, domain ownership or project transfers without explicit approval.
- Hosting lane selection stays with `deploy-target-matrix.md`. An Astro site with no dedicated server runtime is never routed into the server matrix.

## Upgrades

Astro is upgraded deliberately, one major version at a time.

- Read the official upgrade guide for each major version crossed before editing. The current major is Astro 7 (upgrade guide reviewed 2026-10-20).
- Astro 7 facts to check on every upgrade: Vite 8 is the bundler, the Rust compiler is stricter about invalid HTML (unclosed tags and invalid nesting now error), `compressHTML` defaults to `'jsx'`, Sätteri is the default Markdown processor (remark and rehype plugins need porting or an explicit `unified()` route), `src/fetch.ts` is reserved for advanced routing, `@astrojs/db` is removed, and several experimental flags are stable (cache and routeRules moved out of the experimental block).
- Pin exact versions for Astro and first-party integrations used together. Keep the adapter version compatible with the Astro major.
- An upgrade is a code change. Its proof (build, check, rendered comparison) runs only when the operator approves it. Report the proof gap otherwise.
- Do not batch an upgrade with a content change or a redesign.

## Anti-Patterns

- `npm run dev` or `astro dev` launched by hand instead of `s start`.
- Running `astro build` to "check" a content edit.
- Adding `@astrojs/react`, React components, Radix or any React-family UI kit.
- A framework island for a single toggle, or `client:load` on a below-the-fold component.
- `output: 'server'` or many `prerender = false` routes added to make one form work.
- Global `<script>` in `<head>` for analytics or consent.
- Free-text slugs or copied pairs instead of `translationKey` or the project identity field.
- Multiple date aliases in a collection schema.
- Draft entries that appear in listings, sitemap, feeds or related content.
- A `noindex` page included in the sitemap, or a sitemap built from the file system instead of the publish state.
- `alt` text omitted or filled with a file name.
- LCP image left lazy, or every image marked eager.
- Remote image hosts added to `image.domains` without review, or `dangerouslyProcessSVG` enabled for untrusted SVG.
- `PUBLIC_` variables that carry secrets, or secrets read in client code.
- `security.checkOrigin` disabled to fix a form, or CSP `'unsafe-inline'` added as a shortcut.
- Hardcoded production origins or app URLs scattered across components.
- Translating a page by machine output and publishing it as the peer without the translate playbook's review.
- A Convex admin key or deploy key anywhere in the site.
- An Astro upgrade mixed with a redesign or a content campaign.
- Declaring a page "fast" or "indexable" from a passing build or a dev-server look.

## Content Proof (Content-Only Changes)

A content-only change touches Markdown, MDX, frontmatter, copy, skill pages or article bodies with no code, template, schema, configuration or component change.

Proof, and only proof:

1. Frontmatter conforms to the declared collection schema in `src/content.config.ts`, checked by reading the schema and the file. No build.
2. Locale parity: every changed entry's peer exists, shares the same `translationKey` (or project identity field), and its `locale` value is correct. Missing peers are reported as gaps.
3. Editorial quality against `content-quality-rubric.md`, the editorial corpus, the claim register for any sensitive claim, and the voice rules.
4. Dates are real, `draft` is set as intended, and no secret or private path appears in the text.

Run a build or a check only when code, templates, schema, or configuration changed in the same change, or when the operator explicitly asks. A passing build is never reported as proof of content quality.

## Definition Of Done

An Astro change is done when all of the following are true, with each proof labelled by evidence level (static, dev-session, hosted, production):

- The change fits the project structure and the collection, route and i18n policies above.
- The rendering mode is explicit, and any on-demand route or island has a written reason.
- Zero client JavaScript on content pages, or every island is justified and uses the lightest option.
- Every image has alt text, dimensions, and an explicit loading policy; the LCP candidate is identified.
- Every indexable page has a canonical, correct hreflang peers (or none), and sitemap eligibility matches its noindex state.
- Draft and preview content cannot appear in public output.
- No secret, deploy key or private URL is in the repo, the client bundle or the report.
- Dev verification happened through `s start` and `s open` when the change needs a rendered look.
- Any build, check, hosted preview or CSP proof that was not run is listed as a proof gap with the exact command or step the operator can approve.
- Git persistence followed `mutation-git-authority.md` and the operator's instructions.

## Pressure Scenarios

### ASTRO-REACT-ISLAND-REQUEST

A request asks for an interactive pricing calculator on a public page and the agent is tempted to add `@astrojs/react` because the existing `dianedefores/site` already uses React with `client:load`.

Required behavior: refuse React for the new work. Classify the calculator as an interaction: a small calculator is an inline `<script>` module or a Web Component; a rich reactive surface justifies Vue 3 only with a written reason. Use `client:visible` if a framework island is truly needed. Record the existing React usage in `dianedefores/site` as a conflict for the operator to decide on separately, and do not migrate or extend it in this change.

### ASTRO-SERVER-OUTPUT-DRIFT

A contact form on a static site fails in production with a 404 on POST. The agent is tempted to switch the whole site to `output: 'server'`, add `prerender = false` to every page, and disable `security.checkOrigin` to get the form working.

Required behavior: keep `output: 'static'`. Move the form handler to one Astro Action or one on-demand endpoint with `prerender = false`, add a server adapter only for that need, validate every input with Zod, check origin and authorization in the handler, and rate-limit the public endpoint. Do not disable `checkOrigin`. Report the rendered and hosted proof as a gap because the operator must approve a build or preview, and report the new public endpoint as a privacy and security decision for the operator.

## Stop Conditions

Stop and ask the operator, or report partial, when:

- the site's source locale, route policy, canonical origin or trailing-slash policy is unknown or contradictory;
- a rendering-mode change would affect production URLs, auth, or hosting cost;
- an integration, dependency, font, remote image host or hosted image service is needed and not already approved;
- a React or other non-approved framework is already present and the request would extend it;
- Doppler scope, a secret, or a production variable would be needed;
- the proof requires a build, check or hosted preview that the operator has not approved;
- the change would require a CI trigger or a Git effect the operator's instructions forbid.

## Related References

- `skills/references/preferred-stacks.md`
- `skills/references/deploy-target-matrix.md`
- `skills/references/web-image-performance-contract.md`
- `skills/references/web-typography-contract.md`
- `skills/references/blog-and-cms-experience-contract.md`
- `skills/references/landing-page-experience-coherence.md`
- `skills/references/editorial-content-corpus.md`
- `skills/references/public-author-and-social-identity-contract.md`
- `skills/010-sg-technical/references/performance-audit-playbook.md`
- `skills/406-sg-seo/SKILL.md`
- `skills/407-sg-translate/SKILL.md`
- `skills/109-sg-auth-debug/references/astro-clerk.md`
