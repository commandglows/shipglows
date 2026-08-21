---
artifact: editorial_content_context
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-05-01"
updated: "2026-08-21"
status: reviewed
source_skill: sg-start
scope: blog-and-article-surface-policy
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
content_surfaces:
  - future_blog
  - future_articles
  - public_site
claim_register: docs/editorial/claim-register.md
page_intent: docs/editorial/page-intent-map.md
linked_systems:
  - CONTENT_MAP.md
  - docs/editorial/public-surface-map.md
  - site/src/pages/
  - site/src/content.config.ts
depends_on:
  - artifact: "shipglows_data/editorial/content-map.md"
    artifact_version: "0.3.0"
    required_status: draft
supersedes: []
evidence:
  - "Current site/src/pages inventory includes `/blog` and `/fr/blog` routes."
  - "site/src/content.config.ts declares an `articles` collection."
  - "Operator correction 2026-08-21: every new or materially updated ShipGlows article must include its EN/FR translation."
next_review: "2026-06-01"
next_step: "/sg-verify ShipGlows Editorial Content Governance Layer for AI Agents"
---

# Blog And Article Surface Policy

## Current Decision

ShipGlows now has a declared indexed blog surface backed by an Astro content collection:

- content collection: `site/src/content/articles/`
- schema owner: `site/src/content.config.ts`
- English routes: `site/src/pages/blog/index.astro`, `site/src/pages/blog/[slug].astro`
- French routes: `site/src/pages/fr/blog/index.astro`, `site/src/pages/fr/blog/[slug].astro`

ShipGlows also keeps declared standalone editorial article routes under `site/src/pages/`, including:

- `site/src/pages/why-not-just-prompts.astro`
- `site/src/pages/remote-mcp-oauth-tunnel.astro`
- localized peers under `site/src/pages/fr/`

Agents may add new indexed articles through the declared `articles` collection when the topic fits the blog surface, or update standalone editorial pages when the topic clearly matches their narrower route intent and source-of-truth constraints.

Every new or materially updated indexed article requires a paired English and French article in the same workstream. Both peers share one `articleKey`, use their own locale-native `slug`, map each other through `alternateSlug`, keep publication state and material claims aligned, and receive substantive source-faithful translation rather than placeholder or literal copy. Missing or stale EN/FR parity blocks readiness, closure, and delivery; the absence of a peer is never evidence that the article is intentionally monolingual.

Agents must still not invent parallel article content under undeclared paths such as `posts/`, ad hoc `site/src/content/blog/`, or a second article system outside the declared collection and routes.

## Required Response When Blog Is Requested

If a user requests blog, article, newsletter, or long-form editorial output and no declared surface exists for that topic, report:

```text
surface missing: blog
```

Then propose the next safe step:

- `/sg-spec ShipGlows blog/article surface` when the request implies a second article system, RSS, CMS, newsletter delivery, search, or publishing behavior outside the declared blog collection and routes.
- A draft-only content pack in chat or a non-runtime governance artifact when the user only wants strategy or outlines.
- A specific existing declared editorial route when the idea belongs in an existing long-form Astro page instead of a new blog surface.
- A specific existing public surface when the idea belongs in FAQ, docs overview, pricing, landing page, README, or a public skill page instead of a new article.

## What A Future Blog Surface Must Declare

A separate spec or explicit surface decision must define:

- route path, such as an Astro route under `site/src/pages/`
- content collection path, if using Markdown or MDX
- `site/src/content.config.ts` schema fields
- rendering route and `getCollection()` / `getStaticPaths()` behavior when dynamic pages are used
- source contracts for claims
- target audience and page intent
- publication validation, including `pnpm --dir shipglows-site build`
- internal link rules from `CONTENT_MAP.md`
- claim review through `docs/editorial/claim-register.md`

## Stop Conditions

Stop before writing article files when:

- the topic does not fit either the declared blog collection or a declared standalone editorial route
- no Astro route exists for the requested article surface
- no content collection schema accepts the proposed frontmatter
- the request would publish sensitive claims without evidence
- the article would expose internal-only technical details
- the work would require adding CMS, RSS, search, analytics, or newsletter tooling outside a ready spec

## Allowed Work Before A Blog Exists

Agents may still:

- produce an article brief in chat when the user asks for draft-only strategy
- add or edit content in the declared `articles` collection
- update a declared standalone editorial article route whose page intent already exists
- add a governance note to `shipglows_data/editorial/` under an explicit contract
- route the idea to existing FAQ, docs, README, landing, pricing, or public skill surfaces
- create a spec for a broader publishing system beyond the current blog

## Maintenance Rule

Update this policy when a blog path, article surface, content collection, newsletter repository surface, RSS route, or CMS integration is explicitly declared.
