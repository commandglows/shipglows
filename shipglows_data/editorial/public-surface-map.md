---
artifact: editorial_content_context
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-19"
updated: "2026-08-22"
status: reviewed
source_skill: sg-docs
scope: public-surface-map
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
content_surfaces:
  - public_site
  - repo_docs
  - public_skill_pages
  - faq_support
  - installer_endpoints
claim_register: shipglows_data/editorial/claim-register.md
page_intent: shipglows_data/editorial/page-intent-map.md
linked_systems:
  - /home/claude/shipglows_app/site/src/pages/
  - /home/claude/shipglows_app/site/src/components/
  - /home/claude/shipglows_app/site/src/content/
  - README.md
  - shipglows_data/editorial/content-map.md
  - shipglows_data/editorial/page-intent-map.md
depends_on:
  - artifact: "shipglows_data/editorial/content-map.md"
    artifact_version: "0.16.0"
    required_status: draft
  - artifact: "shipglows_data/editorial/page-intent-map.md"
    artifact_version: "1.6.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Inventory of the Astro routes, generated install endpoints, shared components, skill collection, and indexed article collection on 2026-08-19."
  - "The canonical EN/FR runtime installer surfaces are /shipglows and /fr/shipglows; /install and /fr/install remain plugin-first."
  - "The 2026-08-22 positioning update aligns primary EN/FR product pages around a business framework shared by humans and agents, with identity, impact, and technical-execution claim limits."
next_review: "2026-09-19"
next_step: none
---

# Public Surface Map

## Purpose

This map identifies ShipGlows surfaces that publish user-facing content. It
complements `content-map.md`, which owns content routing, and
`page-intent-map.md`, which owns the detailed job and CTA of each route.

## Public Surfaces

| Surface | Canonical source | Public route or output | Update trigger | Validation |
| --- | --- | --- | --- | --- |
| Primary product pages | `site/src/pages/index.astro`, `about.astro`, `contact.astro`, `pricing.astro` and their `fr/` peers | `/`, `/about`, `/contact`, `/pricing` and localized routes | Product, positioning, contact, proof, or pricing truth changes | EN/FR review, Astro check, build |
| Public documentation | `site/src/pages/docs.astro`, `focus-tags.astro`, `skill-modes.astro` and localized peers | `/docs`, `/focus-tags`, `/skill-modes` and localized routes | Documentation routing, public terminology, focus tags, or launch guidance changes | Link search, EN/FR review, build |
| Codex plugin install | `site/src/pages/install.astro`, `site/src/pages/fr/install.astro` | `/install`, `/fr/install` | Marketplace repository, plugin install flow, first command, or plugin/runtime boundary changes | Canonical command search, route tests, build |
| Runtime installer | `site/src/data/installPages.ts`, `site/src/pages/shipglows.astro`, `site/src/pages/fr/shipglows.astro` | `/shipglows`, `/fr/shipglows` | Bootstrap endpoint, mode, supported OS, runtime/corpus selection, dependencies, or Windows DevServer behavior changes | Install data tests, EN/FR review, build, production route proof |
| Raw installer endpoints | `site/src/pages/shipglows-script.ts`, `site/src/pages/dotfiles-script.ts`, `site/src/generated/` | `/shipglows-script`, `/dotfiles-script` | Canonical bootstrap bytes or response routing changes | Byte parity and HTTP response checks |
| Dotfiles installer | `site/src/pages/dotfiles.astro`, `site/src/pages/fr/dotfiles.astro` | `/dotfiles`, `/fr/dotfiles` | Dotfiles endpoint, platform support, or install behavior changes | Dotfiles parity, route tests, build |
| FAQ and explanatory guides | `site/src/pages/faq.astro`, `why-not-just-prompts.astro`, `remote-mcp-oauth-tunnel.astro` and localized peers when declared | `/faq`, `/why-not-just-prompts`, `/remote-mcp-oauth-tunnel` and localized routes | Objection, scope, security/privacy boundary, or workflow explanation changes | Claim review, link search, build |
| Skill discovery | `site/src/pages/skills/`, `site/src/content/skills/` | `/skills`, `/skills/[slug]`, `/fr/skills` | Public métier inventory, skill promise, category, CTA, or repository link changes | Content schema, route generation, build |
| Indexed editorial content | `site/src/pages/blog/`, `site/src/content/articles/` | `/blog`, `/blog/[slug]` and localized routes | Article schema, index behavior, locale pairing, or article publication changes | Content schema, locale pairing, build |
| Shared public chrome | `site/src/components/NavBar.astro`, `Footer.astro`, shared homepage and CTA components | Reused across public routes | Primary navigation, repository, global CTA, or shared promise changes | Consumer search, representative route review, build |
| Repository onboarding | `README.md`, `plugins/shipglows/README.md`, plugin hosted-doc links | GitHub and Codex plugin surfaces | Install command, repository ownership, runtime/corpus behavior, or hosted docs origin changes | Metadata/plugin validation and stale-link search |

## Invariants

- `/install` remains the Codex plugin-first route; `/shipglows` owns the machine runtime installer.
- English and French install surfaces must describe the same supported platforms and component behavior.
- Public repository links use `https://github.com/commandglows/shipglows`.
- Hosted ShipGlows documentation uses `https://shipglows.com`.
- Raw installer endpoints remain byte-identical to their canonical source files.
- Internal technical documents, private URLs, credentials, logs, and operator-only details are not public surfaces.

## Maintenance Rule

Update this map when a public route, shared public component, installer endpoint,
content collection, or repository onboarding surface is added, removed, or
changes ownership.
