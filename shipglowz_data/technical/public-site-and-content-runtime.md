---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "1.6.0"
project: ShipGlowz
created: "2026-05-01"
updated: "2026-06-28"
status: reviewed
source_skill: sg-start
scope: public-site-and-content-runtime
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - shipglowz-site/
  - shipglowz_data/editorial/content-map.md
  - README.md
  - shipglowz_data/technical/operator-guides/skill-launch-cheatsheet.md
  - shipglowz_data/editorial/
depends_on:
  - artifact: "shipglowz_data/editorial/content-map.md"
    artifact_version: "0.7.0"
    required_status: draft
  - artifact: "shipglowz_data/editorial/README.md"
    artifact_version: "1.0.0"
    required_status: reviewed
supersedes: []
evidence:
  - "shipglowz_data/editorial/content-map.md and shipglowz-site directory inventory."
  - "shipglowz_data/editorial added for public-content governance and Astro schema policy."
  - "Skill modes page expanded into a public launch cheatsheet for master and supporting skill modes."
  - "shipglowz_data/technical/operator-guides/skill-launch-cheatsheet.md added as the Markdown reference for the public launch cheatsheet."
  - "Public docs page now needs to present the project governance layout decision."
  - "French locale added for primary public routes while public skill contracts remain intentionally English for agent reliability."
next_review: "2026-06-01"
next_step: "/sg-docs technical audit shipglowz-site"
---

# Public Site And Content Runtime

## Purpose

This doc covers the Astro public site under `shipglowz-site/`, public skill content, content routing, editorial governance, and the public/private documentation boundary. Read it before changing public docs, content pages, public skill descriptions, or anything that could publish internal technical details.

## Owned Files

| Path | Role | Edit notes |
| --- | --- | --- |
| `shipglowz-site/` | Astro public site | Do not publish internal-only technical docs by accident |
| `shipglowz-site/src/pages/**` | Public routes | Public copy must match product and GTM contracts |
| `shipglowz-site/src/content/articles/**` | Indexed blog article source | Keep frontmatter within the `articles` schema and claims within editorial contracts |
| `shipglowz-site/src/content/skills/**` | Public skill pages | Summarize outcomes, not internal prompt bodies; keep skill contract language in English by default for agent reliability |
| `shipglowz_data/technical/operator-guides/skill-launch-cheatsheet.md` | Markdown skill launch reference | Keep aligned with `/skill-modes`, README workflow, and public skill pages |
| `shipglowz_data/editorial/content-map.md` | Content surface and repurposing map | Update when public surfaces or routing rules change |
| `shipglowz_data/technical/decisions/project-governance-layout.md` | Canonical root-vs-shipglowz_data layout decision | Keep public docs aligned when compliance or migration rules change |
| `shipglowz_data/editorial/**` | Public-content governance | Use for claim register, page intent, editorial gate, and Astro schema policy |
| `shipglowz-site/README.md` | Site-local setup | Update when site commands or runtime change |

## Entrypoints

- `npm --prefix shipglowz-site run build`: public site build.
- `shipglowz-site/package.json`: Node.js 24 and pnpm runtime contract for the Astro site.
- `shipglowz-site/src/pages/docs.astro`: public docs overview.
- `shipglowz-site/src/pages/blog/index.astro`, `shipglowz-site/src/pages/blog/[slug].astro`: indexed blog hub and article route.
- `shipglowz-site/src/pages/skill-modes.astro`: public launch cheatsheet and skill mode tutorial.
- `shipglowz-site/src/content/articles/`: collection-backed article content.
- `shipglowz_data/technical/operator-guides/skill-launch-cheatsheet.md`: Markdown version of the launch cheatsheet.
- `shipglowz-site/src/pages/skills/index.astro`, `shipglowz-site/src/pages/skills/[slug].astro`, and `shipglowz-site/src/content/skills/`: public skill surfaces.
- `shipglowz_data/editorial/content-map.md`: source of truth for content surface roles and update triggers.
- `shipglowz_data/editorial/README.md`: editorial governance entrypoint.
- `shipglowz_data/editorial/astro-content-schema-policy.md`: runtime content schema policy.

## Invariants

- `shipglowz_data/technical/` is internal-only in v1.
- The Astro site runtime is pinned to Node.js 24.x as declared in `shipglowz-site/package.json`.
- Public site copy must not expose private implementation details, private URLs, tokens, internal logs, or operator-only instructions.
- Public claims must be backed by product, business, brand, GTM, workflow docs, or observed behavior.
- Public claims that touch sensitive areas must pass the editorial claim register.
- Public skill pages should not duplicate full `SKILL.md` implementation prompts.
- Public skill content under `shipglowz-site/src/content/skills/*.md` intentionally remains in English even when the surrounding public UI is localized. These pages are public explanations, but they also mirror operational skill contracts consumed by agents, which follow the English source more reliably.
- `shipglowz-site/src/content/skills/*.md` must preserve `shipglowz-site/src/content.config.ts`; do not add ShipGlowz governance metadata unless the schema accepts it.
- The declared indexed blog surface uses `shipglowz-site/src/content/articles/**` plus `/blog` and `/fr/blog` routes.
- New indexed article content must preserve the `articles` schema declared in `shipglowz-site/src/content.config.ts`.
- Standalone long-form editorial pages under `shipglowz-site/src/pages/` are valid article-like surfaces when they already have declared route intent in `shipglowz_data/editorial/page-intent-map.md`.
- Public docs must describe root `BUSINESS.md`, `CONTENT_MAP.md`, `CONTEXT.md`, and similar files as legacy migration sources, not compliant final locations.

## Failure Modes

- Adding `shipglowz_data/technical/` to public routing leaks internal details.
- Public docs can drift from README/workflow doctrine if only one surface is updated.
- Skill descriptions can promise capabilities not present in internal skill contracts.
- Localizing skill contract content can create drift between the public page and the agent-facing English source. Translate navigation and explanatory framing first; translate individual skill bodies only after an explicit product decision and source-alignment plan.
- Astro content collection frontmatter can break the build if agents add fields outside the schema.
- Agents can still invent parallel blog/article systems unless the declared `articles` collection is treated as the canonical indexed surface.
- Agents can also misread standalone editorial pages as interchangeable with indexed blog content; keep the distinction explicit.
- Build output under `shipglowz-site/dist` and dependencies under `shipglowz-site/node_modules` should not be treated as source docs.

## Security Notes

- Never publish secrets, private logs, credentials, OAuth callback internals, private hostnames, or sensitive install reports.
- Keep internal/public boundaries explicit in `shipglowz_data/editorial/content-map.md`.
- Check generated public pages for accidental internal links when promoting documentation.

## Validation

```bash
pnpm --dir shipglowz-site build
rg -n "shipglowz_data/technical|docs/technical|internal-only|secret|token|credential" shipglowz-site/src shipglowz_data/editorial/content-map.md
rg -n "Editorial Update Plan|Claim Impact Plan|surface missing|Astro content schema" shipglowz_data/editorial
```

Review any sensitive-keyword matches manually; generic warnings are allowed, real secrets are not.

## Reader Checklist

- `shipglowz-site/` changed -> check this doc and `shipglowz_data/editorial/content-map.md`.
- Public content or claim changed -> check `shipglowz_data/editorial/` and the claim register.
- Runtime content changed -> check `shipglowz-site/src/content.config.ts` and `shipglowz_data/editorial/astro-content-schema-policy.md`.
- Blog routes or article content changed -> check `shipglowz_data/editorial/blog-and-article-surface-policy.md` and `shipglowz_data/editorial/page-intent-map.md`.
- Public docs route changed -> check README and workflow docs for consistency.
- Governance layout copy changed -> check `shipglowz_data/technical/decisions/project-governance-layout.md`, `skills/300-sg-docs/SKILL.md`, and `tools/shipglowz_metadata_lint.py`.
- Internal technical docs mentioned publicly -> confirm the link is not publishing internal content.

## Maintenance Rule

Update this doc when public routes, skill content, content surface roles, editorial governance, build commands, runtime content schemas, or internal/public documentation boundaries change.
