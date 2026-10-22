---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-10-21"
updated: "2026-10-21"
status: draft
source_skill: sg-docs
scope: external-platform-vue
owner: Diane
confidence: medium
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/documentation-freshness-gate.md
  - shipglows_data/technical/external-platforms/astro.md
  - shipglows_data/technical/external-platforms/typescript.md
  - templates/project_platform_usage.md
depends_on:
  - artifact: "shipglows_data/technical/external-platforms/README.md"
    artifact_version: "1.1.0"
    required_status: "draft"
supersedes: []
evidence:
  - "Operator decision 2026-10-21: Vue needs a platform note and a specialist role because Astro sites use Vue islands."
  - "Workspace evidence: GoCharbon, NoteFlowz, and claiire run Astro 5 with Vue 3 islands hydrated through client:load."
  - "Fresh external docs checked on 2026-10-21: the @astrojs/vue integration guide (v7.0.3) documents Vue 3 rendering and client-side hydration, appEntrypoint, jsx, and devtools options, powered by @vitejs/plugin-vue."
next_review: "2026-11-21"
next_step: "/sg-docs technical audit"
---

# Vue Platform Note

## Purpose

This note is the global ShipGlows cheat sheet for Vue 3 freshness checks. Use it before relying on assumptions about Vue components, the Composition API, `<script setup>`, reactivity, SFC compilation, Vite or Vue CLI dev servers, and Vue islands inside Astro sites.

It does not replace Vue or Astro documentation. It records the source map and the ShipGlows rules agents apply before changing Vue code.

## Source Map

| Need | Source |
| --- | --- |
| Vue guide | https://vuejs.org/guide/introduction.html |
| Composition API and `<script setup>` | https://vuejs.org/api/sfc-script-setup.html |
| Reactivity fundamentals | https://vuejs.org/guide/essentials/reactivity-fundamentals.html |
| Vue with TypeScript | https://vuejs.org/guide/typescript/overview.html |
| SSR and hydration | https://vuejs.org/guide/scaling-up/ssr.html |
| Astro Vue integration | https://docs.astro.build/en/guides/integrations-guide/vue/ |
| Astro framework components | https://docs.astro.build/en/guides/framework-components/ |
| Astro client directives | https://docs.astro.build/en/reference/directives-reference/#client-directives |
| Vite Vue plugin | https://github.com/vitejs/vite-plugin-vue |

Freshness evidence on 2026-10-21:

- `@astrojs/vue` (v7.0.3) renders Vue 3 components on the server and hydrates them on the client; `npx astro add vue` installs it.
- `appEntrypoint` points to a module whose default export receives the Vue `App` before rendering, which is where `app.use(...)` plugins belong.
- The integration is powered by `@vitejs/plugin-vue`; compiler options such as `isCustomElement` pass through it. `jsx: true` enables Vue JSX.

## Freshness Gate Use

Use `fresh-docs checked` for Vue decisions only after checking the relevant docs plus local `package.json`, lockfile, `vite.config.*` or `vue.config.*`, and `astro.config.*` when Vue runs inside Astro.

Use `fresh-docs gap` when the Vue, `@astrojs/vue`, or `@vitejs/plugin-vue` version affects the task and was not checked.

Use `fresh-docs conflict` when current docs contradict local docs or a planned implementation.

## ShipGlows Decision Rules

- Vue 3 only. Prefer the Composition API with `<script setup lang="ts">` unless the repository already standardizes on another style.
- In Astro, a Vue component without a `client:*` directive renders as static HTML and ships no JavaScript. Add a directive only where interactivity is needed, and pick the lightest one: `client:visible` or `client:idle` before `client:load`; `client:only="vue"` only for browser-only code.
- Island props must be serializable. Do not pass functions or class instances from `.astro` files to a hydrated Vue component.
- Islands do not share a Vue app instance or provide/inject context. Share state across islands through a small store module such as nanostores, not a global Pinia assumption.
- Register plugins (i18n, Pinia, directives) through `appEntrypoint`, never per component.
- Guard browser-only APIs (`window`, `localStorage`) behind `onMounted` or `client:only`, because Vue islands render on the server first.
- `PUBLIC_` and `VITE_` variables are client-exposed; never read secrets in Vue components.
- Hydration mismatches are defects. Server and client output must match for the same props.

## Common Project-Local Fields

A project using Vue in a non-standard way should maintain `<governance-root>/shipglows_data/technical/platforms/vue.md` with:

- Vue, `@astrojs/vue`, and build-tool versions
- runtime: Astro islands, Vite SPA, Nuxt, or Vue CLI
- `appEntrypoint` path and registered plugins
- cross-island state strategy
- hydration directive conventions
- validation commands and the browser proof route

Use `templates/project_platform_usage.md` as the starter structure.

## Validation

After a Vue island change: run the project type check and build when they apply, open the affected route in a real browser, interact with the island, and confirm no hydration warnings or console errors.

```bash
python3 tools/shipglows_metadata_lint.py shipglows_data/technical/external-platforms/vue.md
```

## Reader Checklist

- `.vue` files, `vue` or `@astrojs/vue` in `package.json`, or `vue()` in `astro.config.*` found -> load this note and the Astro note when Astro is present.
- New interactive island -> check the directive choice and prop serializability.
- Dependency upgrade touches Vue, `@astrojs/vue`, or Vite -> route to migration review with build and browser proof.

## Maintenance Rule

Update this note when Vue major versions, the Astro Vue integration, hydration directives, or ShipGlows island conventions change.
