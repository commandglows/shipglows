---
artifact: content_map
metadata_schema_version: "1.0"
artifact_version: "0.16.2"
project: ShipGlows
created: "2026-04-26"
updated: "2026-08-24"
status: draft
source_skill: manual
scope: content-map
owner: unknown
confidence: medium
risk_level: medium
content_surfaces:
  - site_docs
  - site_skill_pages
  - site_skill_modes
  - repo_skill_launch_cheatsheet
  - repo_docs
  - terminal_tui_docs
  - decision_contracts
  - content_quality_rubric
  - canonical_path_policy
  - editorial_governance
  - claim_register
  - page_intent
  - semantic_clusters
  - content_lifecycle
  - public_benefit_language
security_impact: none
docs_impact: yes
evidence:
  - "README.md lists the canonical project docs"
  - "site/src/pages/docs.astro exposes the public docs overview"
  - "site/src/content/skills contains public skill content"
  - "skills/007-sg-content/references/repurpose-playbook.md needs a reusable content surface map"
  - "skills/references/canonical-paths.md defines ShipGlows-owned path resolution"
  - "Corrected public skill page route paths against site/src/pages/skills/ on 2026-05-01"
  - "shipglows_data/editorial/ added as the public-content governance layer for surface impact, claims, page intent, Astro schema policy, and blog/article stop conditions"
  - "Astro `articles` collection, `/blog` and `/fr/blog` routes, and first indexed article surface declared on 2026-06-28."
  - "site/src/pages/skill-modes.astro now owns the public launch cheatsheet for master and supporting skill modes"
  - "shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md added as the standalone Markdown reference for skill launch modes"
  - "sg-content added as the master content lifecycle entrypoint."
  - "sg-local-cloud-sync added as a public skill page and skill launch surface for local-to-cloud data sync contracts."
  - "Project governance layout decision added and public docs page must explain root-vs-shipglows_data placement."
  - "Terminal TUI documentation added as an internal technical contract plus a public docs overview section."
  - "Decision-quality positioning added to public surfaces so users understand that ShipGlows optimizes quality before speed or convenience."
  - "French public routes added; public skill Markdown remains intentionally English because agents consume the skill contracts more reliably in English."
  - "Public skill discovery was curated to six domains, thirteen métier owners, and the ShipGlows router; numeric lifecycle and specialist skills remain internal expert engines."
  - "Public benefit-first language guide added so familiar reader outcomes lead public copy and technical terms remain evidence-safe second-level proof."
  - "ShipGlows EN/FR declared as the canonical public bootstrap surface for server/local installation and the native Windows DevServer; CommandGlows retains compatibility redirects."
  - "Positioning decision SG-BIZ-2026-08-13-01 establishes business-aware delivery partnership as the primary public story and environment operations as supporting proof."
  - "Product-boundary decision SG-BIZ-2026-08-14-01 establishes autonomous software, no service offer, and no current Cockpit SaaS promise."
  - "External EN/FR positioning published through commandglows/shipglows_app PR #6 and verified on shipglows.com on 2026-08-14."
  - "Public install surfaces aligned on 2026-08-19 with verified Ubuntu/Debian support, automatic skill-corpus selection, and the canonical commandglows/shipglows repository."
  - "Operator decision 2026-08-22 establishes the business framework as category, distinctive identity and impact as ambition, business partnership as behavior, and solid technical execution as a core métier promise."
  - "The 2026-08-24 sg-private addition expands current public discovery to fourteen métier owners plus the ShipGlows router while keeping private operator values outside public surfaces."
linked_artifacts:
  - "README.md"
  - "shipglows_data/business/product.md"
  - "shipglows_data/business/gtm.md"
  - "shipglows_data/branding/branding.md"
  - "shipglows_data/editorial/README.md"
  - "shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md"
  - "tui/README.md"
  - "shipglows_data/technical/terminal-tui.md"
  - "site/src/pages/docs.astro"
  - "site/src/pages/skill-modes.astro"
  - "skills/references/canonical-paths.md"
  - "skills/references/decision-quality-contract.md"
  - "skills/references/content-quality-rubric.md"
  - "shipglows_data/editorial/public-benefit-language.md"
depends_on:
  - artifact: "shipglows_data/business/product.md"
    artifact_version: "1.6.0"
    required_status: "reviewed"
  - artifact: "shipglows_data/business/gtm.md"
    artifact_version: "1.6.0"
    required_status: "reviewed"
supersedes: []
next_review: "2026-09-13"
next_step: "Use live product-adoption evidence to refine the public story without introducing services or premature Cockpit claims"
---

# Content Map

## Purpose

`shipglows_data/editorial/content-map.md` is the editorial navigation layer for ShipGlows. It maps where content lives, what each surface is for, and how build conversations or source ideas should be repurposed without rediscovering the content structure in every thread.

It is a structural context artifact, not a content calendar or backlog.

For public-content governance details, use `shipglows_data/editorial/` after this map. That layer owns public surface impact, page intent, claim boundaries, Astro content schema policy, editorial update gates, and blog/article stop conditions.

## Content Surfaces

| Surface | Canonical path | Purpose | Format | Source of truth | Update when |
|---|---|---|---|---|---|
| Public docs overview | `site/src/pages/docs.astro` | Explain ShipGlows docs, context layer, and decision contracts in public language | Astro page | `README.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md` | A new official artifact or documentation role is added |
| Public install guide | `site/src/pages/install.astro`, `site/src/pages/fr/install.astro` | Explain the Codex marketplace install path for the public `shipglows` plugin and the first command to run after install | Astro page | `README.md`, `plugins/shipglows/README.md`, `plugins/shipglows/assets/docs-links.json`, `shipglows_data/technical/codex-plugin-packaging.md` | Marketplace source, plugin install flow, first-run command, or public packaging posture changes |
| Public runtime and DevServer installer | `https://shipglows.com/shipglows`, `https://shipglows.com/fr/shipglows` | Provide the official server/local bootstrap path and explain the native Windows DevServer separately from the Codex workflow plugin | Canonical ShipGlows install pages | `install-shipglows.sh`, `install-shipglows.ps1`, `README.md`, `shipglows_data/technical/operator-guides/windows-devserver.md`, verified installer behavior | Bootstrap command or endpoint, install mode, supported platform, dependency set, Windows DevServer capability, launcher, or public install wording changes |
| Terminal TUI operator docs | `tui/README.md`, `shipglows_data/technical/terminal-tui.md`, `site/src/pages/docs.astro#terminal-tui` | Explain how the optional read-only terminal cockpit is installed, launched, bounded, and positioned against skills, Gum, and Flutter | Markdown + Astro section | TUI spec, verified launcher behavior, TUI source policy | TUI install, command aliases, interaction model, source policy, or read/write boundary changes |
| Public skill pages | `/home/claude/shipglows_app/site/src/content/skills/` | Present only the fourteen métier owners plus the ShipGlows router as readable public workflow pages; keep numeric engines in expert/internal documentation | Markdown content collection | `skills/references/skill-invocation-registry.json`, public owner skills, product positioning docs | A public métier is added, renamed, repositioned, or its language policy changes |
| Public benefit-first language | `shipglows_data/editorial/public-benefit-language.md` | Translate public workflow mechanisms into familiar reader outcomes while preserving technical evidence and claim limits | Markdown editorial guide | Claim register, business/product/GTM/brand contracts, active skill contracts | Public copy introduces a workflow mechanism, quality/security control, delegation practice, or sensitive product promise |
| Skill launch cheatsheet | `/home/claude/shipglows_app/site/src/pages/skill-modes.astro` | Explain the six public domains and métier modes; link expert engine details without mixing them into default discovery | Astro page | `skills/references/skill-invocation-registry.json`, `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md`, `README.md`, public skill pages | Public métier inventory, modes, ownership, or routing changes |
| Skill launch Markdown reference | `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md` | Preserve the repo Markdown version of master skills, supporting skills, and explicit mode switches | Markdown artifact | `shipglows_data/workflow/playbooks/spec-driven-workflow.md`, `skills/*/SKILL.md`, public skill pages | Skill inventory, master skill modes, argument contracts, or lifecycle routing changes |
| Focus tags cheatsheet | `shipglows_data/technical/operator-guides/focus-tags-cheatsheet.md`, `site/src/pages/docs.astro`, `site/src/pages/fr/docs.astro` | Explain the public tag families used to route people toward the right business, content, governance, execution, and recentering surfaces | Markdown artifact + Astro cards | `skills/references/shipglows-terms.md`, `skills/references/entrypoint-routing.md`, `skills/references/operator-partnership-contract.md`, `skills/references/decision-quality-contract.md`, `skills/008-sg-customer/SKILL.md`, `shipglows_data/business/gtm.md` | Tag inventory, tag families, or public routing guidance changes |
| Named profile guidance | `README.md`, `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md`, `site/src/pages/docs.astro`, `site/src/content/skills/shipglows.md` | Explain the difference between named operator profiles and focus tags, and show how `%Profile` changes arbitration without replacing skill ownership | Markdown + Astro + public skill page | `skills/references/profile-activation.md`, `skills/references/profile-project-context.md`, `shipglows_data/business/agent-profiles/`, `skills/000-shipglows/SKILL.md`, `shipglows_data/business/product.md`, `shipglows_data/business/gtm.md`, `shipglows_data/branding/branding.md` | A named profile is added, renamed, repositioned, or its public invocation guidance changes |
| Blog index and article collection | `site/src/content/articles/`, `site/src/pages/blog/index.astro`, `site/src/pages/blog/[slug].astro`, `site/src/pages/fr/blog/index.astro`, `site/src/pages/fr/blog/[slug].astro`, `site/src/content.config.ts` | Publish indexed long-form editorial content with collection-backed routing and locale-specific article pages | Markdown collection + Astro routes | `shipglows_data/editorial/page-intent-map.md`, `shipglows_data/editorial/blog-and-article-surface-policy.md`, `shipglows_data/business/product.md`, `shipglows_data/business/gtm.md`, `shipglows_data/branding/branding.md`, route-specific source docs/specs | A new article is added, collection schema changes, localized article routing changes, or public editorial strategy changes |
| Public private-data explanation | `site/src/content/articles/en/shipglows-private-data-repo.md`, `site/src/content/articles/fr/pourquoi-shipglows-separe-le-code-public-des-donnees-privees.md`, `site/src/pages/docs.astro`, `site/src/pages/fr/docs.astro` | Explain in public language why ShipGlows keeps durable private operator data in a separate Git repo from the public framework and from ephemeral runtime state | Markdown collection + Astro docs cards | `README.md`, `skills/references/private-data-repo-contract.md`, `skills/references/private-memory-store.md`, install/bootstrap docs | Private-data storage contract, bootstrap behavior, public privacy wording, or docs routing changes |
| Editorial article pages | `site/src/pages/why-not-just-prompts.astro`, `site/src/pages/remote-mcp-oauth-tunnel.astro`, localized peers under `site/src/pages/fr/` | Publish focused long-form explanations as standalone Astro pages when the topic already has a declared route and page intent | Astro page | `shipglows_data/editorial/page-intent-map.md`, `shipglows_data/business/product.md`, `shipglows_data/business/gtm.md`, `shipglows_data/branding/branding.md`, route-specific source docs/specs | A declared editorial route changes its message, claims, CTA, or supporting links |
| Site landing page | `site/src/pages/index.astro` | Present ShipGlows as a business framework shared by humans and agents; express business-aware partnership as its behavior, then connect identity and impact ambition to métier ownership, technical execution, and visible proof | Astro page | `shipglows_data/business/business.md`, `shipglows_data/business/product.md`, `shipglows_data/business/gtm.md`, `shipglows_data/branding/branding.md` | Product positioning or core workflow changes |
| Repo documentation | `README.md` | Canonical repo overview, onboarding, and artifact map | Markdown | Active project artifacts and code structure | Official docs, workflows, or tooling change |
| Workflow doctrine | `shipglows_data/workflow/playbooks/spec-driven-workflow.md` | Explain ShipGlows V3 work doctrine and artifact rules | Markdown artifact | Active skills, templates, linter behavior | Workflow or artifact doctrine changes |
| Canonical path policy | `skills/references/canonical-paths.md` | Define how skills resolve ShipGlows-owned tools, references, templates, and project-local artifacts | Markdown reference artifact | ShipGlows install root and skill execution behavior | A skill, tool, template, or reference path rule changes |
| Editorial governance | `shipglows_data/editorial/` | Govern public-content impact, claims, page intent, Astro runtime schema boundaries, and declared blog/article surfaces | Markdown governance artifacts | `shipglows_data/editorial/content-map.md`, business/product/brand/GTM contracts, site routes, content schema | A public surface, public claim, content schema policy, or editorial gate changes |
| Content quality rubric | `skills/references/content-quality-rubric.md` | Shared project-aware content quality score, blocked reason codes, and structured feedback schema for content owner skills | Markdown reference artifact | Business/product/brand/GTM contracts and editorial corpus revisions | Content scoring rules, blocked codes, evaluator allowlist, or verification gate semantics change |
| Editorial Reader role | `skills/references/subagent-roles/editorial-reader.md` | Diagnose public-content and claim impact without editing files | Markdown role contract | `skills/references/editorial-content-corpus.md`, `shipglows_data/editorial/` | Reader output format, public-content gate, or role boundaries change |
| Content lifecycle skill | `skills/sg-content/SKILL.md` | Orchestrate content strategy, repurposing, drafting, enrichment, audits, docs, validation, and ship routing | Skill contract | `shipglows_data/editorial/content-map.md`, `shipglows_data/editorial/`, specialist content skills | Content-management lifecycle, owner-skill routing, or public content validation gates change |
| Local-cloud sync skill | `skills/sg-local-cloud-sync/SKILL.md`, `site/src/content/skills/sg-local-cloud-sync.md` | Frame local-first data promotion, cloud hydration, merge/conflict policy, sync UX, sensitive-data exclusions, and proof routing | Skill contract + public skill page | `skills/sg-local-cloud-sync/SKILL.md`, skill-local references, public skill page | Local/cloud sync doctrine, public skill promise, skill launch routing, or sensitive-data claim changes |
| Product contract | `shipglows_data/business/product.md` | Define user problem, scope, workflows, non-goals, and risks | Markdown artifact | Product decisions and repo evidence | Product scope or core workflows change |
| GTM contract | `shipglows_data/business/gtm.md` | Define public promise, channels, objections, and proof | Markdown artifact | Business/product/brand docs | Public positioning or distribution assumptions change |
| Project pitch index | `shipglows_data/business/portfolio-project-pitch-links.md` | Point to the versioned pitch file associated with each project in the portfolio | Markdown artifact | Business/product/brand/GTM docs | Project identity, portfolio framing, or pitch-file URL changes |
| Brand contract | `shipglows_data/branding/branding.md` | Define tone, trust posture, vocabulary, and claim boundaries | Markdown artifact | Brand decisions | Voice, vocabulary, or claim posture changes |
| Project governance layout | `shipglows_data/technical/decisions/project-governance-layout.md` | Define where ShipGlows artifacts belong in adopted project repos | Markdown artifact | Architecture/guidelines/linter behavior | Root/corpus layout, migration command, or compliance rules change |
| Technical context | `shipglows_data/technical/context.md`, `shipglows_data/technical/context-function-tree.md` | Help agents orient in the repo and procedural hotspots | Markdown artifacts | Repo structure and major scripts | Entry points, hotspots, or routing rules change |

## Semantic Architecture

| Cluster | Pillar page | Supporting pages | Target intent | Internal link rule | Status |
|---|---|---|---|---|---|
| Shared business framework | `site/src/pages/index.astro` | `site/src/pages/docs.astro`, `site/src/content/skills/*.md`, `README.md` | Understand how humans and agents use one business framework across identity, brand, content, product, technology, growth, delivery, and proof | Landing page leads with the framework category and identity/impact ambition, retains business partnership as behavior, links to métier skills and docs, and excludes guaranteed outcomes, service, or current Cockpit claims | live |
| Plugin install and activation | `site/src/pages/install.astro`, `site/src/pages/fr/install.astro` | `site/src/pages/docs.astro`, `site/src/pages/faq.astro`, `site/src/content/skills/shipglows.md`, `plugins/shipglows/README.md` | Install ShipGlows into Codex and reach the first successful command quickly | Install page owns the marketplace command and first-run path; docs, FAQ, and public skill pages point to it | live |
| Server/local bootstrap and Windows DevServer | `https://shipglows.com/shipglows`, `https://shipglows.com/fr/shipglows` | `site/src/pages/install.astro`, `site/src/pages/fr/install.astro`, `README.md`, `shipglows_data/technical/operator-guides/windows-devserver.md` | Choose the server/local runtime install path or prepare a native Windows machine to clone and run supported development projects | ShipGlows owns bootstrap and runtime installation guidance; `/install` preserves Codex-plugin intent and exposes the runtime as a separate path | live |
| Documentation and decision contracts | `site/src/pages/docs.astro` | `README.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md`, `skills/references/canonical-paths.md`, `shipglows_data/technical/decisions/project-governance-layout.md`, `templates/*.md` | Learn how context and contracts stay coherent | Docs overview points to canonical repo docs, artifact roles, and root-vs-shipglows_data layout | live |
| Skill workflow | `site/src/pages/skills/index.astro`, `site/src/pages/skills/[slug].astro`, `site/src/pages/skill-modes.astro`, `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md` | `site/src/content/skills/*.md`, `skills/*/SKILL.md` | Choose the right skill for a task | Public skill pages should match internal skill names and promises; skill bodies stay English unless an explicit source-alignment plan says otherwise; localized hubs may explain this policy | live |
| Remote agent operations | `site/src/pages/remote-mcp-oauth-tunnel.astro` | `site/src/pages/docs.astro`, `README.md`, `local/README.md`, `shipglows_data/workflow/specs/local-mcp-oauth-tunnel-login.md` | Understand why remote agents need local callback routing for OAuth MCP login | Dedicated guide owns the SEO topic; docs overview points to it; repo docs point operators to the local guided setup | live |
| Terminal operator cockpit | `site/src/pages/docs.astro#terminal-tui` | `tui/README.md`, `shipglows_data/technical/terminal-tui.md`, `README.md`, `shipglows_data/workflow/specs/shipglows-terminal-tui-v1.md` | Understand the optional read-only TUI and how it fits with skills, Gum, and Flutter | Public docs state the boundary; repo docs and technical contract carry setup, keys, source policy, and validation | live |
| Content lifecycle and repurposing | `shipglows_data/editorial/content-map.md`, `site/src/content/skills/sg-content.md` | `skills/007-sg-content/SKILL.md`, `skills/007-sg-content/references/repurpose-playbook.md`, `skills/200-sg-redact/SKILL.md`, `skills/201-sg-enrich/SKILL.md`, `shipglows_data/editorial/`, future public docs section | Manage content strategy, source reuse, drafting, enrichment, audits, and ship validation without inventing undeclared surfaces | `007-sg-content repurpose <source>` creates the source-faithful pack, then routes to the next specialist owner | live |
| Content quality scoring | `skills/references/content-quality-rubric.md` | `skills/007-sg-content/SKILL.md`, `skills/200-sg-redact/SKILL.md`, `skills/201-sg-enrich/SKILL.md`, `skills/009-sg-marketing/SKILL.md`, `skills/406-sg-seo/SKILL.md`, `skills/103-sg-verify/SKILL.md` | Keep project-aware scoring and blocked criteria consistent across owner skills | Owner skills must consume one rubric output schema; `103-sg-verify` rejects stale/recoverable score states as proof | live |
| Editorial governance | `shipglows_data/editorial/README.md` | `shipglows_data/editorial/public-surface-map.md`, `shipglows_data/editorial/page-intent-map.md`, `shipglows_data/editorial/claim-register.md`, `shipglows_data/editorial/editorial-update-gate.md`, `shipglows_data/editorial/astro-content-schema-policy.md`, `shipglows_data/editorial/blog-and-article-surface-policy.md` | Keep public pages, README, FAQ, skill pages, indexed blog articles, standalone editorial pages, and claims aligned with product truth | Public-content work starts at `shipglows_data/editorial/content-map.md`, then uses the editorial layer for gates and evidence | live |

## Page Roles

| Page type | Job | Must include | Must not include |
|---|---|---|---|
| Landing page | Explain the shared business framework and drive a qualified visitor to the next action | Product name, human-and-agent audience, identity/impact ambition, partner behavior, technical execution, métier ownership, proof direction, CTA | AI-only, software-only, equal-pillar/server-first framing, removal of the partner doctrine, or claims unsupported by product docs and GTM |
| Docs overview | Explain artifact roles and navigation | Context layer, decision contracts, links to canonical docs | Implementation detail better suited for repo docs |
| Public skill page | Explain a workflow in human language | Use case, outcome, when to use it | Internal-only implementation prompts |
| Skill launch cheatsheet | Explain which skill to launch and which arguments switch modes | Master skills, supporting lanes, documented mode switches | Full internal prompt contracts or exhaustive implementation detail |
| Repo doc | Preserve operational and product truth for contributors | Scope, commands, artifacts, current workflow | Marketing-only claims without execution relevance |
| Decision contract | Govern future implementation and audits | Metadata, evidence, scope, dependencies | Loose brainstorming or backlog items |
| Pillar page | Own a broad semantic topic | Definition, use cases, links to supporting pages | Thin overview without links |
| Supporting article | Answer a focused question or use case | Specific angle, examples, link to pillar | Duplicate the pillar |
| FAQ entry | Resolve a precise objection or question | Direct answer, caveat, next step | Long essay answer |

## Repurposing Rules

- Use `shipglows_data/editorial/content-map.md` before choosing where repurposed content should go.
- Use `shipglows_data/editorial/` after this map when a change affects public content, page intent, public claims, Astro runtime content, or blog/article output.
- Treat `README.md`, `shipglows_data/business/product.md`, `shipglows_data/branding/branding.md`, and `shipglows_data/business/gtm.md` as claim boundaries for public content.
- Treat `shipglows_data/editorial/claim-register.md` as the register for sensitive public claims.
- Treat `shipglows_data/editorial/page-intent-map.md` as the route-level intent map for public Astro pages.
- Treat `shipglows_data/editorial/astro-content-schema-policy.md` as the rule for runtime content schema preservation.
- Use `site/src/pages/docs.astro` when the repurposed idea changes how ShipGlows documentation should be understood publicly.
- Use `site/src/content/skills/` when the repurposed idea explains a reusable skill workflow.
- Do not translate `site/src/content/skills/*.md` by default during locale work. The surrounding site UI may be localized, but skill bodies remain English unless the work explicitly includes a policy change for agent-facing contract language.
- Use `README.md` or `shipglows_data/workflow/playbooks/spec-driven-workflow.md` when the change affects the canonical internal doctrine.
- Use the declared `articles` collection and `/blog` routes for new indexed editorial articles.
- Use existing declared standalone editorial article routes under `site/src/pages/` when the topic already maps to one of them.
- Report `surface missing: blog` only when the requested output does not fit either the declared blog collection or an existing standalone editorial route.

## Cross-Surface Update Rules

| Trigger | Check these surfaces |
|---|---|
| New official artifact | `README.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md`, `tools/shipglows_metadata_lint.py`, `skills/references/canonical-paths.md`, `skills/300-sg-docs/SKILL.md`, `site/src/pages/docs.astro`, `site/src/components/RoleMap.astro` |
| Terminal TUI behavior or install change | `README.md`, `tui/README.md`, `shipglows_data/technical/terminal-tui.md`, `site/src/pages/docs.astro`, `shipglows_data/workflow/specs/shipglows-terminal-tui-v1.md` |
| Governance layout rule change | `shipglows_data/technical/decisions/project-governance-layout.md`, `shipglows_data/technical/architecture.md`, `shipglows_data/technical/guidelines.md`, `tools/shipglows_metadata_lint.py`, `skills/300-sg-docs/SKILL.md`, `skills/305-sg-init/SKILL.md`, `site/src/pages/docs.astro`, `site/src/components/RoleMap.astro` |
| New or renamed skill | `skills/`, `site/src/content/skills/`, public skills hub, README workflow references; preserve English skill-body policy unless explicitly changed |
| New focus tag or tag-family change | `shipglows_data/technical/operator-guides/focus-tags-cheatsheet.md`, `skills/references/shipglows-terms.md`, `skills/references/entrypoint-routing.md`, `site/src/pages/docs.astro`, `site/src/pages/fr/docs.astro`, `README.md` |
| New named profile or named-profile policy change | `skills/references/profile-activation.md`, `skills/references/profile-project-context.md`, `shipglows_data/business/agent-profiles/`, `README.md`, `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md`, `site/src/pages/docs.astro`, `site/src/content/skills/shipglows.md` |
| Product positioning change | `shipglows_data/business/product.md`, `shipglows_data/business/gtm.md`, `shipglows_data/branding/branding.md`, site landing page, docs overview |
| Public content, claim, FAQ, pricing, docs, README, or skill promise change | `shipglows_data/editorial/content-map.md`, `shipglows_data/editorial/public-surface-map.md`, `shipglows_data/editorial/page-intent-map.md`, `shipglows_data/editorial/claim-register.md`, `shipglows_data/editorial/editorial-update-gate.md`, target public surface |
| Astro runtime content edit | `site/src/content.config.ts`, `shipglows_data/editorial/astro-content-schema-policy.md`, target content collection, public route renderer |
| Blog or article request | `shipglows_data/editorial/blog-and-article-surface-policy.md`, `shipglows_data/editorial/content-map.md`, declared Astro route/content collection; use the `articles` collection and `/blog` routes by default, or an existing standalone editorial page when route intent is already narrower |
| Content lifecycle or repurposing output | `007-sg-content repurpose <source>`, `shipglows_data/editorial/content-map.md`, `shipglows_data/editorial/`, target content surface, evidence ledger from the repurpose pack |
| New semantic cluster | Pillar page, supporting pages, internal links, FAQ/support candidates |
| Local tunnel or remote OAuth workflow change | `README.md`, `local/README.md`, `site/src/pages/docs.astro`, `site/src/pages/remote-mcp-oauth-tunnel.astro`, `shipglows_data/editorial/content-map.md`, `shipglows_data/workflow/specs/local-mcp-oauth-tunnel-login.md` |
| Server/local bootstrap or native Windows DevServer change | ShipGlows EN/FR runtime install pages, `site/src/pages/install.astro`, `site/src/pages/fr/install.astro`, `README.md`, `shipglows_data/technical/operator-guides/windows-devserver.md`, `shipglows_data/editorial/page-intent-map.md`; keep plugin and runtime claims explicitly separate |

## Open Gaps

- [ ] No newsletter or social publishing repository surface is declared yet.
- [ ] Every project with products should maintain a governed product inventory, and every product with marketing or conversion intent should additionally declare canonical sales/product/demo/checkout surfaces inside its own corpus.
- [ ] Product claims should be validated against source truth, live surfaces, and proof assets before being marked complete.
