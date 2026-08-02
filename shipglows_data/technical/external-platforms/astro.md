---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-05-24"
updated: "2026-08-02"
status: draft
source_skill: sg-docs
scope: external-platform-astro
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/documentation-freshness-gate.md
  - shipglows_data/technical/public-site-and-content-runtime.md
  - shipglows_data/editorial/content-map.md
  - templates/project_platform_usage.md
depends_on:
  - artifact: "shipglows_data/technical/external-platforms/README.md"
    artifact_version: "0.1.0"
    required_status: "draft"
supersedes: []
evidence:
  - "Fresh external docs checked on 2026-05-24 against Astro deploy, content collections, environment variables, Firebase deploy, and v6 upgrade docs."
  - "2026-08-02 recovery-flow incident: an Astro script using define:vars emitted a classic browser script while retaining an ES-module import; a browser console smoke check caught the failure after static checks passed."
next_review: "2026-06-24"
next_step: "/sg-docs technical audit"
---

# Astro Platform Note

## Purpose

This note is the global ShipGlows/Chiclou cheat sheet for Astro-related freshness checks. Use it before relying on assumptions about Astro content collections, content schemas, `src/content.config.*`, environment variables, static vs on-demand rendering, deploy adapters, build output, major upgrades, or public-site runtime content.

It does not replace Astro documentation. It records the source map and ShipGlows rules agents should use before changing Astro code, content schemas, public site docs, deployments, or project-local Astro usage docs.

## Source Map

Primary sources for Freshness Gate:

| Need | Source |
| --- | --- |
| Astro deploy overview | https://docs.astro.build/en/guides/deploy/ |
| Content collections | https://docs.astro.build/en/guides/content-collections/ |
| Environment variables | https://docs.astro.build/en/guides/environment-variables/ |
| Deploy to Firebase Hosting | https://docs.astro.build/en/guides/deploy/firebase/ |
| Upgrade to Astro v6 | https://docs.astro.build/en/guides/upgrade-to/v6/ |
| Current docs entrypoint | https://docs.astro.build/ |

Freshness evidence on 2026-05-24:

- Astro deploy docs describe common host auto-detection, `astro build`/`npm run build`, and `dist` as the default static build output.
- Astro deploy docs distinguish static output and on-demand rendering, requiring an adapter for on-demand rendering.
- Astro content collection docs describe `src/content.config.ts` as the collection definition file for build-time consumed collections.
- Astro environment variable docs describe Vite env support and that only `PUBLIC_` variables are available to client-side code.
- Astro v6 upgrade docs state that Astro 6 drops Node 18/20 support, upgrades to Zod 4, and includes breaking changes requiring migration review.
- Astro Firebase deploy docs describe Firebase Hosting support and note experimental Firebase CLI auto-detection/configuration for Astro.

## Freshness Gate Use

Use `fresh-docs checked` for Astro decisions only after checking relevant Astro docs and local `package.json`, lockfile, `astro.config.*`, content config, and deploy provider evidence.

Use `fresh-docs gap` when:

- Astro version, adapter, content collection schema, or deploy mode affects the task but current docs/local versions were not checked.
- Runtime content is edited without checking `src/content.config.*` and the editorial content schema policy.
- Environment variables are changed without verifying server/client exposure and `PUBLIC_` naming.
- A project uses Astro but lacks `shipglows_data/technical/platforms/astro.md`.

Use `fresh-docs conflict` when current Astro docs contradict local docs, deploy assumptions, content schema assumptions, or a planned implementation.

## ShipGlows Decision Rules

- Runtime content must preserve the app's schema. Do not add ShipGlows governance frontmatter to app-rendered content collections unless the app schema accepts it.
- Public content changes must use editorial governance and Astro schema constraints together.
- `PUBLIC_` env vars are client-exposed. Treat secret env vars as server-only and never reference them in browser-executed code.
- Static builds, on-demand rendering, and adapter behavior are different proof surfaces. Know which one the project uses before validating.
- Major Astro upgrades require migration review, Node compatibility review, Zod/schema review, and full site build proof.
- Deployment provider docs may be needed in addition to Astro docs, especially for Vercel, Firebase, Netlify, Cloudflare, or Render.

## Client Script Rule

Astro `<script>` attributes can change whether a script is bundled or emitted
inline. Do not combine `define:vars` with top-level ES-module imports unless the
generated output has been verified as a module. The safe default is to pass
public runtime values through data attributes or a serialized config element,
then keep the client script as a normal Astro-bundled module.

After changing a client-side Astro script, verify both layers:

1. run the project typecheck and build;
2. open the affected route in a real browser;
3. confirm there are no parse, module-loading, hydration, or uncaught runtime
   errors in the console;
4. only then diagnose provider, session, network, or backend behavior.

Static validation can accept valid module syntax even when Astro emits that
syntax into a classic script. Browser console proof is therefore required for
client-runtime claims.

## Common Project-Local Fields

A project using Astro should maintain `<governance-root>/shipglows_data/technical/platforms/astro.md` with:

- Astro version and package manager
- rendering mode: static, server, hybrid, or adapter-specific
- deploy provider and build output
- content collection files and schema constraints
- public/runtime content boundaries
- environment variable exposure policy
- image/content/integration notes
- validation commands and preview/prod proof route

Use `templates/project_platform_usage.md` as the starter structure.

## Security Notes

- Never expose secret env vars through `PUBLIC_` or client-rendered content.
- Treat content schemas as security and build-stability boundaries when content comes from external sources or agents.
- Avoid publishing internal ShipGlows docs through Astro routes unless explicitly intended.
- Check generated output for accidental private docs, tokens, or internal-only content when public site routes change.

## Validation

```bash
python3 tools/shipglows_metadata_lint.py shipglows_data/technical/external-platforms/astro.md
rg -n "Freshness Gate|Source Map|ShipGlows Decision Rules|Client Script Rule|Maintenance Rule" shipglows_data/technical/external-platforms/astro.md
```

## Reader Checklist

- `astro`, `astro.config`, `src/content.config`, `.astro`, `getCollection`, adapter config, or Astro deploy docs found -> check for project-local Astro usage note.
- Public content changed -> check editorial corpus plus Astro content schema.
- Dependency upgrade touches Astro/Vite/Zod -> route to `010-sg-technical migrate` and require build proof.
- Env var change -> verify server/client exposure and deploy provider configuration.

## Maintenance Rule

Update this note when Astro content collections, env behavior, adapters, deploy guidance, major upgrades, Node support, Zod/schema behavior, or ShipGlows public-site proof rules change.
