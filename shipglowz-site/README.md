# ShipFlow Public Site

Astro site for the public ShipFlow website.

Live URL:

```text
https://shipflowzsite.vercel.app
```

This site is the public explanation, docs, FAQ, pricing hypothesis, blog, and skill-discovery surface for ShipFlow. It should stay aligned with the repository README, `shipglowz_data/editorial/content-map.md`, and `shipglowz_data/technical/public-site-and-content-runtime.md`.

## Commands

```bash
corepack enable
pnpm install
pnpm dev
```

Build for production:

```bash
pnpm build
pnpm preview
```

## Runtime

- Node.js 24.x
- pnpm 11.15.0 via the `packageManager` pin

## Structure

- `src/pages/index.astro` - landing page
- `src/pages/docs.astro` - public docs overview
- `src/pages/blog/index.astro` and `src/pages/blog/[slug].astro` - indexed blog hub and article pages
- `src/pages/skills/index.astro` - public skill index
- `src/pages/skills/[slug].astro` - public skill detail pages
- `src/pages/pricing.astro` - pricing hypothesis
- `src/pages/faq.astro` - public FAQ
- `src/pages/about.astro` and `src/pages/contact.astro` - trust and contact pages
- `src/pages/skill-modes.astro` - public skill launch guide
- `src/pages/remote-mcp-oauth-tunnel.astro` - remote MCP OAuth tunnel explanation
- `src/pages/why-not-just-prompts.astro` - positioning page
- standalone long-form editorial pages still live directly under `src/pages/` when they own a narrow route intent; the indexed blog now lives in `src/content/articles/` plus `/blog` routes
- `src/pages/fr/` - French public routes for the main site navigation
- `src/pages/fr/blog/index.astro` and `src/pages/fr/blog/[slug].astro` - French blog hub and article pages
- `src/content/articles/` - public long-form editorial content for the declared blog surface
- `src/content/skills/` - public skill descriptions; do not paste full internal `SKILL.md` prompts
- `src/content.config.ts` - Astro content schema; keep generated content compatible
- `src/layouts/BaseLayout.astro` - base document shell
- `src/components/` - reusable page sections
- `src/styles/global.css` - global visual system

## Content Rules

- Do not publish `shipglowz_data/technical/` as public site content.
- Do not expose secrets, private logs, credentials, private hostnames, or operator-only traces.
- Keep public claims aligned with `shipglowz_data/business/`, `shipglowz_data/editorial/`, and the current product reality.
- Keep plugin packaging claims aligned with `shipglowz_data/technical/codex-plugin-packaging.md`.
- French routes may localize navigation and explanatory framing, but skill descriptions stay in English by default because agents consume the English skill contracts more reliably.
- Run `pnpm --dir shipglowz-site build` after changing rendered site content or schemas.
