---
artifact: editorial_content_context
metadata_schema_version: "1.0"
artifact_version: "1.6.0"
project: ShipGlows
created: "2026-05-01"
updated: "2026-08-22"
status: reviewed
source_skill: sg-start
scope: page-intent-map
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
content_surfaces:
  - public_site
  - public_skill_pages
  - faq_support
claim_register: docs/editorial/claim-register.md
page_intent: docs/editorial/page-intent-map.md
linked_systems:
  - site/src/pages/
  - site/src/components/
  - site/src/content/skills/
  - skills/references/decision-quality-contract.md
depends_on:
  - artifact: "shipglows_data/business/business.md"
    artifact_version: "1.5.0"
    required_status: reviewed
  - artifact: "shipglows_data/business/product.md"
    artifact_version: "1.6.0"
    required_status: reviewed
  - artifact: "shipglows_data/branding/branding.md"
    artifact_version: "1.3.0"
    required_status: reviewed
  - artifact: "shipglows_data/business/gtm.md"
    artifact_version: "1.6.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Inventory of current Astro pages and shared public components."
  - "Skill modes route expanded into a launch cheatsheet for master and supporting skill modes."
  - "Decision-quality positioning added to landing, docs, FAQ, why-not-prompts, skill modes, and selected public skill pages."
  - "shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md added as the Markdown reference behind the public skill modes route."
  - "ShipGlows EN/FR runtime pages declared as the canonical server/local bootstrap and native Windows DevServer surfaces; `/install` routes keep the Codex plugin as their primary intent."
  - "Positioning decision SG-BIZ-2026-08-13-01 makes business-aware outcome ownership the landing-page lead and environment delivery supporting proof."
  - "The 2026-08-19 installer alignment keeps EN/FR runtime pages exact about Ubuntu/Debian support, corpus selection, and the canonical public repository."
  - "Operator decision 2026-08-22 makes the shared human-agent business framework the category and the identity-impact-technical tagline the primary landing ambition."
next_review: "2026-09-13"
next_step: "Test whether the EN/FR landing communicates shared human-agent use, cross-métier breadth, and outcome caveats without requiring technical context"
---

# Page Intent Map

## Purpose

This map states the job of each public Astro page so agents can update copy without changing the page's role by accident.

## Route Intent

| Route | File | Audience | Job | Primary CTA | Source of truth | Update trigger | Shared-file risk |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `/` | `site/src/pages/index.astro` plus homepage components | Solo founders and small teams evaluating a shared framework for human and agent work | Lead with ShipGlows as a business framework for humans and agents; present distinctive identity, business impact, and solid technical execution as ambition; then show governed truth, métier ownership, bounded chantiers, proof, and supporting delivery capabilities | Skills hub, docs, pricing, GitHub | `shipglows_data/business/business.md`, `shipglows_data/business/product.md`, `shipglows_data/business/gtm.md`, `shipglows_data/branding/branding.md`, `skills/references/decision-quality-contract.md` | Offer, audience, workflow, proof, pricing, FAQ, quality positioning, or claim changes | High: homepage components are reused and claim-heavy |
| `/about` | `site/src/pages/about.astro` | Visitors asking why the framework exists and whether humans can use it directly | Explain how humans and agents work from shared truth across identity, brand, content, product, technology, growth, delivery, and proof | Docs or GitHub | `shipglows_data/business/business.md`, `shipglows_data/business/product.md`, `shipglows_data/branding/branding.md` | Mission, audience, positioning, proof posture | Medium |
| `/contact` | `site/src/pages/contact.astro` | Visitors who want a direct next step | Give a simple contact path without inventing support promises | Contact method or GitHub | `GTM.md`, `BRANDING.md` | Sales/support channel changes | Low |
| `/docs` | `site/src/pages/docs.astro` | Public evaluators and operators orienting in docs | Explain context docs, decision contracts, public skills, and governance without exposing internal-only detail | Skills hub and GitHub docs | `README.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md`, `CONTENT_MAP.md`, `docs/editorial/README.md`, `skills/references/decision-quality-contract.md` | New artifact, content governance, technical docs layer, workflow doctrine, quality positioning, or docs routing changes | High: public/private boundary |
| `/fr/docs` | `site/src/pages/fr/docs.astro` | French-speaking public evaluators and operators orienting in docs | Explain context docs, decision contracts, public skills, and governance in French without exposing internal-only detail | Skills hub and GitHub docs | `README.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md`, `CONTENT_MAP.md`, `docs/editorial/README.md`, `skills/references/decision-quality-contract.md` | New artifact, content governance, technical docs layer, workflow doctrine, quality positioning, or docs routing changes | High: public/private boundary |
| `/blog` | `site/src/pages/blog/index.astro` | Visitors browsing long-form editorial thinking | List indexed ShipGlows articles and explain when the editorial surface goes deeper than docs or FAQs | Blog article pages and docs | `shipglows_data/editorial/content-map.md`, `shipglows_data/editorial/blog-and-article-surface-policy.md`, `PRODUCT.md`, `GTM.md`, `BRANDING.md` | New article system behavior, blog strategy, schema changes, or public editorial framing changes | High: indexed editorial surface |
| `/install` | `site/src/pages/install.astro` | New Codex users who want the shortest install path | Explain the marketplace command, plugin-directory install step, and first-run command for the public `shipglows` plugin; expose the separate Windows runtime installer only as a secondary path | Install the Codex plugin; secondary link to `/shipglows` for the Windows DevServer | `README.md`, `plugins/shipglows/README.md`, `plugins/shipglows/assets/docs-links.json`, `shipglows_data/technical/codex-plugin-packaging.md`, `shipglows_data/technical/operator-guides/windows-devserver.md` | Marketplace source, plugin install flow, first-run command, public packaging posture, bootstrap destination, or Windows DevServer availability changes | High: plugin and runtime install claims must remain distinct and exact |
| `/fr/install` | `site/src/pages/fr/install.astro` | French-speaking Codex users who want the shortest install path | Explain the public `shipglows` plugin install flow in French; expose the separate Windows runtime installer only as a secondary path | Installer le plugin Codex ; lien secondaire vers `/fr/shipglows` pour le DevServer Windows | Same contracts as `/install`, plus locale parity | English install intent changes, French install copy changes, bootstrap destination, or Windows DevServer availability changes | High: locale parity and install claims |
| `/shipglows` | `site/src/pages/shipglows.astro` | Operators installing ShipGlows on a server or a local machine, including native Windows | Own the canonical server/local bootstrap and native Windows DevServer installation guidance without presenting it as the Codex plugin install | Run or copy the appropriate bootstrap command | `install-shipglows.sh`, `install-shipglows.ps1`, `README.md`, `shipglows_data/technical/operator-guides/windows-devserver.md`, verified installer behavior | Bootstrap command or endpoint, install mode, supported platform, dependency set, Windows DevServer capability, launcher, or agent option changes | High: executable commands and platform claims |
| `/fr/shipglows` | `site/src/pages/fr/shipglows.astro` | French-speaking operators installing ShipGlows on a server or a local machine, including native Windows | Own the localized canonical bootstrap and native Windows DevServer guidance with parity to the English surface | Lancer ou copier la commande bootstrap adaptée | Same contracts as `/shipglows`, plus locale parity | English source intent, French wording, bootstrap command or endpoint, install mode, supported platform, dependency set, Windows DevServer capability, launcher, or agent option changes | High: executable commands, locale parity, and platform claims |
| `/dotfiles` | `site/src/pages/dotfiles.astro` | Operators installing the ShipGlows user environment | Explain the canonical dotfiles bootstrap and its supported environments | Run or copy `https://shipglows.com/dotfiles-script` | Dotfiles bootstrap source, runtime documentation and verified installer behavior | Bootstrap endpoint, supported environment, repository ownership or install behavior changes | High: executable command claims |
| `/fr/dotfiles` | `site/src/pages/fr/dotfiles.astro` | French-speaking operators installing the ShipGlows user environment | Explain the localized canonical dotfiles bootstrap with parity to the English surface | Lancer ou copier `https://shipglows.com/dotfiles-script` | Same contracts as `/dotfiles`, plus locale parity | English source intent, French wording, endpoint or install behavior changes | High: executable commands and locale parity |
| `/faq` | `site/src/pages/faq.astro` | Visitors with recurring objections or scope questions | Answer common questions directly and safely | Skill modes, docs | `PRODUCT.md`, `GTM.md`, `BRANDING.md`, `README.md`, `skills/references/decision-quality-contract.md` | New objection, product scope change, pricing/support claim, quality positioning, skill behavior change | High: compact claims can drift |
| `/pricing` | `site/src/pages/pricing.astro` | Visitors evaluating commercial fit | Present pricing as a current hypothesis, not a settled model | Docs, BUSINESS.md | `BUSINESS.md`, `GTM.md`, `BRANDING.md` | Business model, packaging, paid offer, proof, or pricing claim changes | High: pricing claims are sensitive |
| `/remote-mcp-oauth-tunnel` | `site/src/pages/remote-mcp-oauth-tunnel.astro` | Operators dealing with remote Codex and local OAuth callbacks | Explain why local callback routing needs a temporary SSH path | Local guide and repo docs | `local/README.md`, `README.md`, `specs/local-mcp-oauth-tunnel-login.md`, `docs/technical/local-tunnels-and-mcp-login.md` | Tunnel behavior, OAuth callback, local install, security boundary, or MCP docs changes | High: security/privacy wording |
| `/skill-modes` | `site/src/pages/skill-modes.astro` | Operators choosing skill entrypoints or confused by skill arguments | Explain which master/support skill to launch and how plain task arguments differ from mode switches | Skills hub, relevant skill pages | `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md`, `skills/*/SKILL.md`, `README.md` | Skill inventory, argument modes, mode detection, lifecycle routing | Medium |
| `/skills` | `site/src/pages/skills/index.astro` | Visitors choosing a workflow move | Present the public skill catalog by category and use case | Skill detail pages | `site/src/content/skills/*.md`, `skills/*/SKILL.md`, `PRODUCT.md` | Skill inventory, category, featured status, public promise | High: generated from content collection |
| `/skills/[slug]` | `site/src/pages/skills/[slug].astro` | Visitors evaluating one skill | Render one public skill promise and related workflow context | Skills hub, GitHub skills | `site/src/content/skills/*.md`, `skills/*/SKILL.md`, `site/src/content.config.ts` | Skill behavior, public description, argument modes, related skills, schema changes | High: route depends on `getCollection` and `getStaticPaths` |
| `/blog/[slug]` | `site/src/pages/blog/[slug].astro` | Visitors reading one indexed editorial article | Render one collection-backed article with stable locale mapping and source-bounded editorial reasoning | Blog hub and docs | `site/src/content/articles/*.md`, `site/src/content.config.ts`, `shipglows_data/editorial/blog-and-article-surface-policy.md`, product/brand/GTM contracts | Article content, frontmatter schema, locale pairing, or blog routing changes | High: route depends on `getCollection`, `render`, and content schema |
| `/why-not-just-prompts` | `site/src/pages/why-not-just-prompts.astro` | Visitors comparing ShipGlows to stronger prompting | Explain why context, contracts, and verification are the product wedge | Docs or skills | `PRODUCT.md`, `GTM.md`, `BRANDING.md` | Positioning, objection handling, proof language | Medium |

## Editorial Article Surface Rule

ShipGlows now has two long-form editorial surface types:

- an indexed blog collection under `/blog`
- standalone Astro editorial pages with explicit route intent

Current declared standalone editorial article routes include:

- `/why-not-just-prompts`
- `/remote-mcp-oauth-tunnel`
- corresponding localized French routes when they exist

Use the blog collection for new general long-form editorial topics.

Use standalone routes when a long-form explanatory topic clearly matches an existing narrow page intent.

Do not create a second article system outside these declared surfaces without a separate blog/article surface decision.

## Component Intent

| Component | File | Job | Update trigger |
| --- | --- | --- | --- |
| Navigation | `site/src/components/NavBar.astro` | Route visitors to primary public surfaces | New primary public route, removed route, or CTA change |
| Footer | `site/src/components/Footer.astro` | Repeat the compact product promise and stable links | Positioning or primary route change |
| FAQ section | `site/src/components/FaqSection.astro` | Homepage objection handling | Product, workflow, scope, or claim change |
| Pricing hypothesis | `site/src/components/PricingHypothesis.astro` | Homepage commercial hypothesis | Business model or pricing language change |
| Docs CTA | `site/src/components/DocsCta.astro` | Drive from homepage to docs | Docs surface or artifact role change |
| Role map | `site/src/components/RoleMap.astro` | Explain workflow roles in public language | Lifecycle, reader, executor, integrator, or skill-role change |

## Page Intent Rules

- Do not make a public page the source of truth for product behavior. Public pages reflect reviewed contracts and verified behavior.
- Do not promote internal-only technical docs as public content. A public page may mention that the layer exists, but it must not publish internal operational detail.
- Do not strengthen pricing, security, privacy, compliance, AI reliability, automation, speed, savings, availability, or business outcome claims without claim-register evidence.
- If a page intent changes materially, update this file and `CONTENT_MAP.md`.

## Maintenance Rule

Update this file when a public route, shared public component, CTA, source contract, or page job changes.
