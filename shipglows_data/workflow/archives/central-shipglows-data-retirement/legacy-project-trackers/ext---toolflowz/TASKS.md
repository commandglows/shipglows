# Tasks — ext---toolflowz

> **Priority:** 🔴 P0 blocker · 🟠 P1 high · 🟡 P2 normal · 🟢 P3 low · ⚪ deferred
> **Status:** 📋 todo · 🔄 in progress · ✅ done · ⛔ blocked · 💤 deferred

---

## Setup

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Review project structure and configure environment | 📋 todo |

---

## Backlog

| Pri | Task | Status |
|-----|------|--------|

---

## Audit Findings
<!-- Populated by /sg-audit — dated sections added automatically -->

### Audit: Deps

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Patch the direct/runtime and build-server CVEs without jumping majors: `vue-i18n` >=11.1.2, Vite >=6.4.2, PostCSS >=8.5.10, then rerun `pnpm audit` and extension builds | ✅ done |
| 🔴 | Remove unused `vuefire` or prove Firebase is intentionally used; current install pulls critical `protobufjs` and vulnerable `undici` through `vuefire -> firebase` | ✅ done |
| 🟠 | Patch dev/test/packaging transitive risks in `jsdom/form-data`, `web-ext/node-forge`, `@playwright/test`, `sass/immutable`, and Vite plugins pulling `h3`, `tar`, `svgo`, `rollup`, `minimatch`, and `defu` | ✅ done |
| 🟠 | Clean dependency hygiene after type/build verification: remove unused PrimeVue 4 packages (`@primevue/core`, `@primevue/icons`) from a PrimeVue 3 app, redundant `@types/*`, and unused config-only packages flagged by depcheck | 📋 todo |
| 🟠 | Add dependency governance: `.nvmrc` or `engines`, `packageManager`, Dependabot/Renovate, and review `.npmrc` settings (`shamefully-hoist=true`, `strict-peer-dependencies=false`) | 🔄 in progress — `engines`, `packageManager`, overrides note, and `.npmrc` review done; update automation still open |
| 🟡 | Route breaking upgrades through `/sg-migrate`: PrimeVue 3→4, Vite 6→8, Vitest 0.34→4, Pinia 2→3, Vue Router 4→5, TypeScript 5→6, Tailwind 3→4, FormKit 1→2, web-ext 8→10 | 📋 todo |
| 🟠 | Resolve global `pnpm run typecheck` failures outside the dependency-security chantier, then rerun build/audit/typecheck together | ✅ done |

### Audit: Code

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Bundle PrimeVue/PrimeIcons styles locally instead of loading `cdn.jsdelivr.net` from the content script and theme store | ✅ done |
| ✅ | Replace direct project `innerHTML`/`v-html` insertion paths with DOM construction, plain text rendering, or sanitized fragments for reader/Gmail/feed/changelog surfaces | ✅ done |
| ✅ | Add Firefox `data_collection_permissions.required: ["none"]` so manifest lint no longer flags missing data-collection disclosure | ✅ done |
| 🟠 | Design a narrower permission model for `manifest.config.ts`: redundant `host_permissions`, `scripting`, `activeTab`, and `webNavigation` removed; static `<all_urls>` content-script match intentionally remains for the toolbar product model | ✅ done |
| 🟠 | Configure or remove FormKit's bundled icon CDN fallback so packaged extension code cannot fetch `https://cdn.jsdelivr.net/npm/@formkit/icons...` at runtime, or prove the fallback is unreachable | ✅ done |
| 🟠 | Replace the single 800x800 `src/assets/logo.png` manifest icon mapping with correctly sized 16/24/32/128 assets for Firefox review | ✅ done |
| 🟡 | Split or lazy-load heavy content-script dependencies; the built all-page content script is still about 886 KB minified | 📋 todo |
| 🟡 | Add meaningful tests for bridge payload validation, reader sanitizer behavior, Better Gmail DOM insertion, and manifest/store-review policy checks | 🔄 in progress — manifest permission/icon/dependency policy tests added; bridge/sanitizer/Gmail tests remain |
| 🟡 | Add ShipGlows metadata contracts (`BUSINESS.md`, `BRANDING.md`, `GUIDELINES.md`) or migrate existing docs into the expected schema so future audits are not capped by proof gaps | 📋 todo |
