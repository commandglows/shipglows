---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.3"
project: "ShipGlows"
created: "2026-05-01"
created_at: "2026-05-01 10:05:10 UTC"
updated: "2026-08-12"
updated_at: "2026-08-12 20:11:48 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: feature
owner: Diane
confidence: high
user_story: "En tant qu'utilisatrice ShipGlows qui publie un site Astro et délègue l'exécution à des agents, je veux une couche de gouvernance éditoriale pour le blog, les pages du site, le README et les docs publiques affichées, afin que les contenus publics, claims, FAQ, pages de vente et docs restent cohérents avec le produit réellement livré."
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - CONTENT_MAP.md
  - BUSINESS.md
  - PRODUCT.md
  - BRANDING.md
  - GTM.md
  - README.md
  - shipglows_data/workflow/playbooks/spec-driven-workflow.md
  - GUIDELINES.md
  - shipglows_data/workflow/specs/sg-build-autonomous-master-skill.md
  - docs/editorial/
  - templates/content_map.md
  - templates/editorial_content_context.md
  - skills/references/subagent-roles/editorial-reader.md
  - skills/sg-docs/SKILL.md
  - skills/sg-repurpose/SKILL.md
  - skills/sg-audit-copy/SKILL.md
  - skills/sg-redact/SKILL.md
  - skills/sg-enrich/SKILL.md
  - shipglows-site/package.json
  - shipglows-site/src/content.config.ts
  - shipglows-site/src/pages/
  - shipglows-site/src/components/
  - shipglows-site/src/content/skills/
depends_on:
  - artifact: "README.md"
    artifact_version: "0.3.0"
    required_status: draft
  - artifact: "shipglows_data/workflow/playbooks/spec-driven-workflow.md"
    artifact_version: "0.6.0"
    required_status: draft
  - artifact: "shipglows_data/workflow/specs/shipglows-technical-documentation-layer-for-ai-agents.md"
    artifact_version: "1.0.2"
    required_status: ready
  - artifact: "skills/references/documentation-freshness-gate.md"
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "Wave 20 removes the inverse sg-build spec dependency: sg-build consumes the editorial governance corpus and remains a linked downstream system, not an upstream authority."
  - "Wave 19 canonicalized exact dependency paths against the current repository resource graph."
  - "Historical migration-source provenance (legacy root documents): BRANDING.md, BUSINESS.md, CONTENT_MAP.md, GTM.md, GUIDELINES.md, PRODUCT.md."
  - "User request 2026-05-01: prepare a similar reflection for editorial documentation: blog, site pages, README, and public docs displayed on the Astro site."
  - "Local Astro site uses Astro 6.4.8 from shipglows-site/pnpm-lock.yaml and a skills content collection declared in shipglows-site/src/content.config.ts."
  - "Astro official docs checked through Context7 /withastro/docs: src/pages uses file-based routing; content collections use defineCollection with schema validation; collection entries need dynamic routes with getCollection/getStaticPaths."
  - "CONTENT_MAP.md already maps public docs overview, public skill pages, landing page, repo docs, workflow doctrine, product/GTM/brand contracts, semantic clusters, and cross-surface update rules."
  - "CONTENT_MAP.md currently says no dedicated blog directory is declared yet."
  - "README.md explicitly distinguishes ShipGlows artifact metadata from application runtime content schemas such as Astro content collections."
  - "skills/sg-repurpose/SKILL.md, skills/sg-audit-copy/SKILL.md, skills/sg-redact/SKILL.md, and skills/sg-enrich/SKILL.md already contain partial doctrine for content routing, claim safety, and runtime schema preservation."
  - "User decision 2026-05-01: create a separate read-only Editorial Reader role instead of overloading the Technical Reader; do not keep a reader.md alias."
next_step: "/sg-start ShipGlows Editorial Content Governance Layer for AI Agents"
---

# Spec: ShipGlows Editorial Content Governance Layer for AI Agents

## Title

ShipGlows Editorial Content Governance Layer for AI Agents

## Status

Ready.

This chantier is the editorial/public-content counterpart to `specs/shipglows-technical-documentation-layer-for-ai-agents.md`. It creates the durable layer that tells agents where public content lives, what each public surface is allowed to claim, which source contracts govern it, and how Astro runtime schemas constrain content edits.

## User Story

En tant qu'utilisatrice ShipGlows qui publie un site Astro et délègue l'exécution à des agents, je veux une couche de gouvernance éditoriale pour le blog, les pages du site, le README et les docs publiques affichées, afin que les contenus publics, claims, FAQ, pages de vente et docs restent cohérents avec le produit réellement livré.

The expected value is lower product/copy drift, less rediscovery of content surfaces, safer public claims, clearer routing between README/internal docs and public Astro pages, and fewer schema-breaking edits to `shipglows-site/src/content/**`.

## Minimal Behavior Contract

ShipGlows must provide a public-content governance layer: `docs/editorial/` contains an agent-readable index, a public surface map, a claim register, a page intent map, and an editorial update gate; `CONTENT_MAP.md` remains the canonical content routing artifact and links to the new layer; public Astro pages, README sections, public docs pages, skill content collection entries, and future blog surfaces each have declared source-of-truth contracts and update triggers. When a chantier changes product behavior, workflow, public docs, skill promises, pricing, support copy, or claims, the read-only Editorial Reader produces an `Editorial Update Plan` and, when claims are sensitive, a `Claim Impact Plan`; edits are applied by a write-capable executor or integrator, sequentially by default, with parallelism only for spec-defined exclusive files. The Editorial Reader is a separate role file at `skills/references/subagent-roles/editorial-reader.md`; it is not an alias of the Technical Reader and no `reader.md` compatibility file is created. If no blog path exists, agents must report the missing declared surface instead of inventing one. The easy-to-miss edge case is a code or workflow change that passes tests while the Astro site, README, FAQ, docs overview, skill pages, or future blog still promises the old behavior.

## Success Behavior

- Given a fresh agent receives a task touching product behavior, a public skill promise, README, FAQ, docs overview, pricing, landing copy, support copy, or future article/blog content, when it opens `CONTENT_MAP.md` and `docs/editorial/`, then it can identify impacted surfaces, source contracts, update triggers, allowed claim boundaries, and validation checks.
- Given a ShipGlows workstream changes user-visible behavior or public documentation truth, when the Editorial Reader runs the editorial gate, then it produces an `Editorial Update Plan` with impacted files, reason, required action, owner role, parallel-safety, and validation.
- Given a public claim touches security, privacy, compliance, AI reliability, automation quality, speed, savings, availability, pricing, or business outcomes, when the claim is added or changed, then it is checked against `docs/editorial/claim-register.md` and either backed by evidence, downgraded, marked pending proof, or blocked.
- Given a content file lives in `shipglows-site/src/content/**`, when an agent edits it, then it preserves the Astro content collection schema and never adds incompatible ShipGlows frontmatter.
- Given a blog/article output is requested, when no blog route or collection is declared, then the agent reports `surface missing: blog` and proposes a separate spec or explicit surface decision instead of creating an ad hoc path.

## Error Behavior

- If `CONTENT_MAP.md` or `docs/editorial/page-intent-map.md` does not list a public surface that is affected by a change, the plan reports `surface missing` and routes shared-map updates before page/content edits are considered complete.
- If an Astro content collection schema rejects additional fields, the implementation preserves the runtime schema and records ShipGlows context versions in the plan/report, not in incompatible frontmatter.
- If a public claim lacks evidence or conflicts with product/brand/GTM contracts, the claim is marked `claim mismatch`, `needs proof`, or `blocked`; it is not published as fact.
- If shared editorial files such as `CONTENT_MAP.md`, `docs/editorial/claim-register.md`, `shipglows-site/src/pages/index.astro`, shared components, nav/footer, FAQ, pricing, or docs overview are assigned to parallel write agents, the work is blocked or rerouted to sequential integration.
- If a feature ships with stale public docs, README guidance, FAQ, skill pages, or site copy that describe the old behavior, verification fails unless the stale item is explicitly marked `pending final copy` with owner, reason, and a block-before-ship condition.
- If public content would expose internal-only technical details, private URLs, credentials, tokens, sensitive logs, or unsupported security/compliance language, verification fails and the content must be removed or rewritten.

## Problem

ShipGlows already has strong pieces for editorial work:

- `CONTENT_MAP.md` maps major public and internal content surfaces.
- `BUSINESS.md`, `PRODUCT.md`, `BRANDING.md`, and `GTM.md` define audience, promise, tone, and claim boundaries.
- `README.md` is both a public overview and contributor/operator entrypoint.
- `shipglows-site/src/pages/*.astro` contains the public Astro pages.
- `shipglows-site/src/content/skills/*.md` contains public skill pages rendered through Astro's `skills` content collection.
- `sg-repurpose`, `sg-audit-copy`, `sg-redact`, and `sg-enrich` already contain partial rules for content routing and claim safety.

The gap is that these rules are spread across many documents and skills. A fresh agent can see that content matters, but it does not have one durable layer that answers: which public surface owns which message, which source contract governs it, which claims are sensitive, what to update after a behavior change, how README and public Astro docs relate, how future blog work should be declared, and how to avoid breaking Astro content schemas.

## Solution

Create a canonical editorial governance layer:

```text
docs/editorial/
  README.md
  public-surface-map.md
  page-intent-map.md
  claim-register.md
  editorial-update-gate.md
  astro-content-schema-policy.md
  blog-and-article-surface-policy.md
```

Add two supporting artifacts:

```text
templates/editorial_content_context.md
skills/references/editorial-content-corpus.md
skills/references/subagent-roles/editorial-reader.md
```

Then connect the layer to the existing content and documentation workflows by updating `CONTENT_MAP.md`, `templates/content_map.md`, `skills/sg-docs/SKILL.md`, `skills/sg-repurpose/SKILL.md`, `skills/sg-audit-copy/SKILL.md`, `skills/sg-redact/SKILL.md`, `skills/sg-enrich/SKILL.md`, `README.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md`, and `site/src/pages/docs.astro`.

This chantier does not create a blog implementation. It defines how a future blog/article surface must be declared before agents write blog content, because the current repo has no dedicated blog directory or blog route.

## Scope In

- Create `docs/editorial/README.md` as the entrypoint for public-content governance.
- Create `docs/editorial/public-surface-map.md` for public pages, README sections, public docs, skill pages, future blog/article surfaces, FAQ/support, and shared components.
- Create `docs/editorial/page-intent-map.md` for each current Astro page: audience, job, CTA, source of truth, update trigger, and shared-file risk.
- Create `docs/editorial/claim-register.md` for sensitive public claims and allowed wording boundaries.
- Create `docs/editorial/editorial-update-gate.md` with `Editorial Update Plan`, `Claim Impact Plan`, statuses, pending-final-copy rules, and parallelism constraints.
- Create `docs/editorial/astro-content-schema-policy.md` for Astro 5 content collections, frontmatter schema constraints, and build validation.
- Create `docs/editorial/blog-and-article-surface-policy.md` to handle the currently missing blog surface and prevent agents from inventing paths.
- Create `templates/editorial_content_context.md` for durable editorial governance artifacts outside app-rendered runtime content.
- Create `skills/references/editorial-content-corpus.md` for skills and agents that need to load the editorial layer.
- Create `skills/references/subagent-roles/editorial-reader.md` as the read-only role contract for public-content and claim impact analysis.
- Update `CONTENT_MAP.md` and `templates/content_map.md` to point to `docs/editorial/`, declared surfaces, claim register, page intents, and update gates.
- Update content/documentation skills so they use the editorial layer before changing public content or claims.
- Update README, workflow docs, and the public docs Astro page with a concise mention of editorial coherence.
- Define safe execution waves and explicit no-overlap rules for editorial content edits.

## Scope Out

- Rewriting all public pages, README sections, or skill pages.
- Creating or launching a blog, newsletter, CMS, RSS feed, or article collection.
- Adding blog/article routes to Astro.
- Running a full SEO/content strategy project.
- Creating a content calendar or backlog.
- Replacing `CONTENT_MAP.md` as the canonical surface map.
- Making public pages the source of truth for product behavior.
- Adding ShipGlows frontmatter to Astro runtime content when the content collection schema does not allow it.
- Publishing unsupported claims about security, privacy, compliance, AI reliability, automation quality, speed, savings, availability, pricing, or business outcomes.
- Exposing internal-only technical docs or private operational details on the public site.

## Constraints

- `CONTENT_MAP.md` remains the canonical content surface map.
- `docs/editorial/` is a governance layer, not a content calendar.
- The Editorial Reader is read-only: it diagnoses public-content impact, public claim impact, route/schema risk, and surface ownership, but never edits, stages, formats, or validates destructively.
- The Editorial Reader works alongside the Technical Reader. They may both run as read-only analysis roles without edit-conflict risk, but any write-capable executor remains sequential by default unless a ready spec defines exclusive file ownership.
- Public content must stay inside `BUSINESS.md`, `PRODUCT.md`, `BRANDING.md`, `GTM.md`, specs, verified behavior, and claim evidence.
- ShipGlows language doctrine applies: internal governance docs, role contracts, workflow rules, stable headings, validation notes, acceptance criteria, and stop conditions use English; user-facing public copy uses the active user/project language and natural accented French when the active language is French.
- Astro runtime content keeps the schema declared in `site/src/content.config.ts`; ShipGlows artifact metadata belongs outside runtime content unless the schema explicitly accepts it.
- The current Astro site uses Astro 5.18.1 and a `skills` content collection with a strict Zod schema.
- `src/pages` file-based routes and dynamic routes are governed by Astro routing behavior.
- Markdown content collections do not automatically become pages; routes such as `site/src/pages/skills/[slug].astro` own rendering through `getCollection()` and `getStaticPaths()`.
- Shared editorial files and shared Astro components are sequential integration surfaces.
- Parallel editorial edits are allowed only when a ready spec assigns exclusive target files and no shared map, register, component, layout, collection schema, nav/footer, index, FAQ, docs, or pricing file is touched in the same wave.
- A missing blog surface is a governance finding, not permission to invent `blog/`, `posts/`, or `site/src/content/blog/`.
- Public success and error states must be observable through changed files, build output, plan items, or verification findings.
- Preserve unrelated dirty worktree changes.

## Dependencies

Local docs and contracts to inspect before implementation:

- `CONTENT_MAP.md`
- `BUSINESS.md`
- `PRODUCT.md`
- `BRANDING.md`
- `GTM.md`
- `README.md`
- `shipglows_data/workflow/playbooks/spec-driven-workflow.md`
- `GUIDELINES.md`
- `shipglows_data/workflow/specs/sg-build-autonomous-master-skill.md`
- `specs/shipglows-technical-documentation-layer-for-ai-agents.md`
- `skills/sg-docs/SKILL.md`
- `skills/sg-repurpose/SKILL.md`
- `skills/sg-audit-copy/SKILL.md`
- `skills/sg-redact/SKILL.md`
- `skills/sg-enrich/SKILL.md`
- `templates/content_map.md`

Astro site files to inspect before writing public-surface docs:

- `site/package.json`
- `shipglows-site/pnpm-lock.yaml`
- `site/src/content.config.ts`
- `site/src/pages/*.astro`
- `site/src/pages/skills/[slug].astro`
- `site/src/pages/skills/index.astro`
- `site/src/components/NavBar.astro`
- `site/src/components/Footer.astro`
- `site/src/components/FaqSection.astro`
- `site/src/components/PricingHypothesis.astro`
- `site/src/content/skills/*.md`

Fresh external docs checked:

- Context7 `/withastro/docs`, Astro docs for file-based routing: files in `src/pages/` become routes, and dynamic routes use `getStaticPaths()`.
- Context7 `/withastro/docs`, Astro docs for content collections: `src/content.config.ts` defines content collection schemas with `defineCollection` and Zod; content collection entries are queried with `getCollection()` and rendered by route files.

Verdict: fresh-docs checked.

## Invariants

- `CONTENT_MAP.md` maps surfaces; `docs/editorial/` explains governance, claims, page intent, gates, and schema constraints.
- `skills/references/subagent-roles/editorial-reader.md` owns the read-only role contract for producing `Editorial Update Plan` and `Claim Impact Plan`.
- `BUSINESS.md`, `PRODUCT.md`, `BRANDING.md`, and `GTM.md` bound public claims.
- `README.md` remains a repo/project overview, not a marketing-only landing page.
- Public Astro pages remain the rendered public surfaces.
- `site/src/content/skills/*.md` remains a runtime content collection governed by `site/src/content.config.ts`.
- The future blog/article surface must be declared before agents write blog content.
- Claim evidence is required before sensitive public claims are strengthened.
- Unsupported sensitive claims are downgraded, marked pending proof, or blocked.
- Shared editorial surfaces are sequential.
- Public docs cannot expose internal-only technical detail unless explicitly approved and filtered.
- A chantier is not cleanly closed if known impacted public content remains false.

## Links & Consequences

Upstream systems:

- Product, business, brand, GTM, specs, README, content map, implementation changes, technical documentation layer, and Astro site structure.

Downstream systems:

- `sg-docs`, `sg-repurpose`, `sg-audit-copy`, `sg-redact`, `sg-enrich`, README, public Astro pages, public skill pages, FAQ, pricing, docs overview, remote MCP guide, and future blog/article surfaces.

Consequences:

- Agents gain a single layer for public-content impact instead of rediscovering pages and claim boundaries in each thread.
- README, public docs, and Astro pages become explicitly linked surfaces instead of separate editing targets.
- Public claims become auditable and bounded by evidence.
- Future blog/article work is safer because missing surfaces are reported before content is written.
- Astro build/schema failures become part of editorial validation, not late incidental breakage.
- The editorial layer adds maintenance cost and must be audited by `sg-docs`.

## Documentation Coherence

Durable split:

- `CONTENT_MAP.md`: canonical map of content surfaces and cross-surface routing.
- `docs/editorial/README.md`: entrypoint to editorial governance.
- `docs/editorial/public-surface-map.md`: public content surface inventory, including README/public docs/site pages/future blog.
- `docs/editorial/page-intent-map.md`: page-level audience, job, CTA, source of truth, and update triggers.
- `docs/editorial/claim-register.md`: sensitive public claims, proof state, allowed wording, surfaces, and stop conditions.
- `docs/editorial/editorial-update-gate.md`: lifecycle gate and plan formats.
- `docs/editorial/astro-content-schema-policy.md`: Astro schema/routing constraints for public content.
- `docs/editorial/blog-and-article-surface-policy.md`: rules for the currently missing blog/article surface.
- `templates/editorial_content_context.md`: template for governance artifacts, not runtime content.
- `skills/references/editorial-content-corpus.md`: compact loading list for content skills and agents.
- `skills/references/subagent-roles/editorial-reader.md`: read-only agent role contract for public-content surface and claim impact analysis.
- `README.md`: repo and public overview; short pointer only.
- `site/src/pages/docs.astro`: public docs overview; short public explanation only.

Anti-duplication rules:

- Do not copy full business/product/brand/GTM docs into editorial docs.
- Do not copy full page content into page intent maps.
- Do not make the claim register a marketing draft file.
- Do not make runtime Astro content carry ShipGlows governance metadata unless the schema allows it.
- Do not duplicate `CONTENT_MAP.md`; link and extend its governance context.

## Edge Cases

- A code change is purely internal: the editorial gate returns `no editorial impact` with reason.
- A bug fix changes visible behavior: the plan checks README, docs overview, FAQ, public skill pages, support copy, and future changelog/article candidates.
- A public page mentions a capability that is no longer true: the plan marks `update required` or `claim mismatch`.
- A new public page is added under `site/src/pages/`: the page intent map and content map must be updated.
- A new skill content file is added: it must satisfy `site/src/content.config.ts`, and the public skill hub/dynamic route must still build.
- A blog article is requested but no blog path exists: the agent reports `surface missing: blog` and routes to a separate blog-surface spec or explicit user decision.
- Two agents edit separate skill content files: allowed only if no shared collection schema, hub copy, nav, map, or claim register changes are in the same parallel wave.
- The Technical Reader and Editorial Reader both analyze the same chantier: allowed because both roles are read-only; the master/integrator merges their plans before assigning any write-capable executor.
- A claim is true internally but risky publicly: the claim register defines allowed wording before the public page is edited.
- A source contract is draft but high-confidence enough to guide the work: the spec records that status and `/sg-ready` decides whether it is acceptable.
- A public docs page would reveal internal operational detail: create filtered public language or leave the detail internal.
- Astro docs behavior conflicts with local implementation assumptions: stop and reroute to `/sg-spec` or a focused Astro migration check.

## Implementation Tasks

- [x] Task 1: Create the editorial governance index.
  - File : `docs/editorial/README.md`
  - Action : Explain purpose, relationship to `CONTENT_MAP.md`, relation to public Astro pages, README, docs, future blog/article surfaces, claims, and schema constraints.
  - User story link : Gives fresh agents a stable editorial entrypoint.
  - Depends on : Read `CONTENT_MAP.md`, `BUSINESS.md`, `PRODUCT.md`, `BRANDING.md`, `GTM.md`.
  - Validate with : `test -f docs/editorial/README.md && rg -n "CONTENT_MAP|Astro|README|public docs|claim|blog|schema|Editorial Update Plan" docs/editorial/README.md`
  - Notes : Keep it an index, not a long strategy memo.

- [x] Task 2: Create the public surface map.
  - File : `docs/editorial/public-surface-map.md`
  - Action : Map README, public Astro pages, public skill pages, docs overview, FAQ, pricing, remote MCP guide, shared components, and future blog/article surfaces.
  - User story link : Helps agents know which public surfaces can drift after product changes.
  - Depends on : Task 1 plus reading `site/src/pages/`, `site/src/components/`, `site/src/content/skills/`.
  - Validate with : `rg -n "README.md|site/src/pages/index.astro|site/src/pages/docs.astro|site/src/pages/faq.astro|site/src/content/skills|blog|shared component|update trigger" docs/editorial/public-surface-map.md`
  - Notes : Mark blog/article as undeclared, not live.

- [x] Task 3: Create the page intent map.
  - File : `docs/editorial/page-intent-map.md`
  - Action : For each public Astro route, document page job, audience, CTA, source of truth, related surfaces, update triggers, and shared-file risk.
  - User story link : Prevents agents from editing a page without understanding its role.
  - Depends on : Task 2.
  - Validate with : `rg -n "page job|audience|CTA|source of truth|update trigger|index.astro|docs.astro|skills/index.astro|skills/\\[slug\\].astro" docs/editorial/page-intent-map.md`
  - Notes : Do not duplicate page copy.

- [x] Task 4: Create the claim register.
  - File : `docs/editorial/claim-register.md`
  - Action : Register sensitive public claim families, allowed wording boundaries, evidence source, status, surfaces, owner, review cadence, and stop conditions.
  - User story link : Prevents unsupported public promises from reaching the site or README.
  - Depends on : Task 1 plus reading `BUSINESS.md`, `PRODUCT.md`, `BRANDING.md`, `GTM.md`.
  - Validate with : `rg -n "security|privacy|compliance|AI reliability|automation|speed|savings|availability|pricing|allowed wording|evidence|stop condition" docs/editorial/claim-register.md`
  - Notes : Initial entries can be claim families rather than every sentence.

- [x] Task 5: Create the editorial update gate.
  - File : `docs/editorial/editorial-update-gate.md`
  - Action : Define triggers, `Editorial Update Plan`, `Claim Impact Plan`, statuses, pending final copy, no-impact justification, shared-surface rules, and closure blockers.
  - User story link : Makes public-content coherence a repeatable gate.
  - Depends on : Tasks 2, 3, and 4.
  - Validate with : `rg -n "Editorial Update Plan|Claim Impact Plan|pending final copy|no editorial impact|claim mismatch|surface missing|shared surface|closure|ship" docs/editorial/editorial-update-gate.md`
  - Notes : Align with the technical documentation layer but keep public-content language separate.

- [x] Task 6: Create the Astro content schema policy.
  - File : `docs/editorial/astro-content-schema-policy.md`
  - Action : Document Astro 5.18.1 local setup, `site/src/content.config.ts`, `skills` collection schema, dynamic skill routes, and the rule against incompatible ShipGlows metadata in runtime content.
  - User story link : Keeps public content updates from breaking the Astro site.
  - Depends on : Task 2 and fresh Astro docs evidence.
  - Validate with : `rg -n "Astro 5.18.1|content.config.ts|defineCollection|z.object|getCollection|getStaticPaths|runtime content|frontmatter|schema" docs/editorial/astro-content-schema-policy.md`
  - Notes : Cite Context7 `/withastro/docs` in the doc evidence section.

- [x] Task 7: Create the blog and article surface policy.
  - File : `docs/editorial/blog-and-article-surface-policy.md`
  - Action : State that no blog path is declared yet, define how future blog/article surfaces must be declared, and list stop conditions before agents write article content.
  - User story link : Handles the user's blog interest without inventing paths or routes.
  - Depends on : Task 2 and `CONTENT_MAP.md`.
  - Validate with : `rg -n "No dedicated blog|surface missing|blog path|article surface|separate spec|CONTENT_MAP|Astro route|content collection" docs/editorial/blog-and-article-surface-policy.md`
  - Notes : This chantier may prepare blog governance, not implement the blog.

- [x] Task 8: Create the editorial content context template.
  - File : `templates/editorial_content_context.md`
  - Action : Add a ShipGlows metadata-bearing template for editorial governance artifacts outside runtime content.
  - User story link : Standardizes future editorial docs without polluting Astro collection schemas.
  - Depends on : Tasks 1 through 7.
  - Validate with : `rg -n "artifact: editorial_content_context|metadata_schema_version|artifact_version|depends_on|content_surfaces|claim_register|page_intent|runtime content" templates/editorial_content_context.md`
  - Notes : Do not require this frontmatter inside `site/src/content/**`.

- [x] Task 9: Create the editorial content corpus reference.
  - File : `skills/references/editorial-content-corpus.md`
  - Action : List the docs, contracts, Astro paths, public surfaces, and skills that editorial/content agents should read first.
  - User story link : Reduces context loading cost for future content agents.
  - Depends on : Task 8.
  - Validate with : `rg -n "CONTENT_MAP|BUSINESS|PRODUCT|BRANDING|GTM|docs/editorial|site/src/pages|site/src/content|sg-repurpose|sg-audit-copy|Astro" skills/references/editorial-content-corpus.md`
  - Notes : Keep it a routing reference, not a duplicate of the docs.

- [x] Task 9b: Create the Editorial Reader role contract.
  - File : `skills/references/subagent-roles/editorial-reader.md`
  - Action : Define a strict read-only role contract for the Editorial Reader: load `editorial-content-corpus.md`, `CONTENT_MAP.md`, business/product/brand/GTM contracts, public Astro pages, public docs, claim register, page intent map, and Astro schema policy; produce `Editorial Update Plan` and `Claim Impact Plan`; never edit, stage, format, or run destructive validation.
  - User story link : Gives `sg-build` a dedicated Editorial Reader without overloading the Technical Reader.
  - Depends on : Task 9 and the `sg-build` role-file contract.
  - Validate with : `test -f skills/references/subagent-roles/editorial-reader.md && rg -n "Editorial Reader Agent Contract|read-only|editorial corpus|CONTENT_MAP|public surfaces|Astro|Editorial Update Plan|Claim Impact Plan|no edits|no staging" skills/references/subagent-roles/editorial-reader.md`
  - Notes : Do not create `skills/references/subagent-roles/reader.md` as an alias.

- [x] Task 10: Update CONTENT_MAP and content map template.
  - File : `CONTENT_MAP.md`, `templates/content_map.md`
  - Action : Add `docs/editorial/`, public surface map, page intent map, claim register, editorial update gate, Astro schema policy, and blog/article surface policy.
  - User story link : Connects the governance layer to the canonical content map.
  - Depends on : Tasks 1 through 9b.
  - Validate with : `rg -n "docs/editorial|public-surface-map|page-intent|claim-register|editorial-update-gate|Astro content schema|blog-and-article" CONTENT_MAP.md templates/content_map.md`
  - Notes : Shared files; sequential edit only.

- [x] Task 11: Update sg-docs for editorial governance.
  - File : `skills/sg-docs/SKILL.md`
  - Action : Add audit/update instructions for `docs/editorial/`, public content drift, claim register, page intent map, and Astro runtime schema preservation.
  - User story link : Makes editorial governance maintainable by the docs workflow.
  - Depends on : Task 10.
  - Validate with : `rg -n "editorial governance|docs/editorial|claim register|page intent|public content drift|Astro content schema|runtime content" skills/sg-docs/SKILL.md`
  - Notes : Preserve existing metadata vs runtime-content distinction.

- [x] Task 12: Update sg-repurpose for public content routing.
  - File : `skills/sg-repurpose/SKILL.md`
  - Action : Require the editorial corpus, claim register, page intent map, and blog-surface policy before recommending or applying public content outputs.
  - User story link : Keeps repurposed content faithful to product truth and declared surfaces.
  - Depends on : Task 11.
  - Validate with : `rg -n "Editorial Update Plan|Claim Impact Plan|claim register|page intent|blog surface|docs/editorial|surface missing" skills/sg-repurpose/SKILL.md`
  - Notes : Preserve source-faithful doctrine.

- [x] Task 13: Update copy and content-generation skills.
  - File : `skills/sg-audit-copy/SKILL.md`, `skills/sg-redact/SKILL.md`, `skills/sg-enrich/SKILL.md`
  - Action : Add instructions to use the editorial corpus, claim register, page intent map, and Astro schema policy before auditing, drafting, or enriching public content.
  - User story link : Prevents copy audits and content generation from drifting beyond product evidence.
  - Depends on : Task 12.
  - Validate with : `rg -n "claim register|page intent|docs/editorial|Astro content schema|unsupported public claims|surface missing|proof gap" skills/sg-audit-copy/SKILL.md skills/sg-redact/SKILL.md skills/sg-enrich/SKILL.md`
  - Notes : Runtime content may be edited only within schema-compatible fields.

- [x] Task 14: Update README, workflow docs, and public docs page.
  - File : `README.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md`, `site/src/pages/docs.astro`
  - Action : Add concise references to editorial coherence, content governance, public claim safety, and Astro runtime-content schema boundaries.
  - User story link : Makes the editorial layer discoverable to operators and public readers without exposing internal machinery.
  - Depends on : Tasks 10 through 13.
  - Validate with : `rg -n "editorial coherence|content governance|public content|claims|CONTENT_MAP|docs/editorial|Astro content" README.md shipglows_data/workflow/playbooks/spec-driven-workflow.md site/src/pages/docs.astro`
  - Notes : Keep public wording short; do not copy the internal gate.

- [x] Task 15: Final validation and integration.
  - File : `specs/shipglows-editorial-content-governance-layer-for-ai-agents.md`, `docs/editorial/`, `templates/editorial_content_context.md`, `skills/references/editorial-content-corpus.md`, `skills/references/subagent-roles/editorial-reader.md`, modified skills/docs/site files
  - Action : Run metadata lint, static `rg` validations, and the Astro build when dependencies are available.
  - User story link : Proves the layer does not break ShipGlows artifacts or the public Astro site.
  - Depends on : All previous tasks.
  - Validate with : `$SHIPGLOWS_ROOT/tools/shipglows_metadata_lint.py specs/shipglows-editorial-content-governance-layer-for-ai-agents.md docs/editorial templates/editorial_content_context.md && test -f skills/references/subagent-roles/editorial-reader.md && test ! -e skills/references/subagent-roles/reader.md && cd shipglows-site && pnpm build`
  - Notes : If build cannot run, report the exact dependency blocker and run static schema checks.

## Acceptance Criteria

- [ ] AC 1: Given a fresh agent needs to evaluate public content impact, when it opens `CONTENT_MAP.md` and `docs/editorial/README.md`, then it can find public surfaces, claim register, page intent map, Astro schema policy, and update gate.
- [ ] AC 2: Given a chantier changes user-visible behavior, when the editorial gate runs, then it produces an `Editorial Update Plan` or explicit `no editorial impact` justification.
- [ ] AC 2b: Given `sg-build` needs public-content impact analysis, when it launches an editorial analysis role, then it uses `skills/references/subagent-roles/editorial-reader.md` and does not rely on or create a generic `reader.md` alias.
- [ ] AC 3: Given a sensitive public claim changes, when the claim lacks proof, then the `Claim Impact Plan` marks it `needs proof`, `claim mismatch`, or `blocked`.
- [ ] AC 4: Given a page exists under `site/src/pages/`, when it is public-facing, then it appears in `public-surface-map.md` or is explicitly documented as excluded.
- [ ] AC 5: Given public skill content is edited under `site/src/content/skills/`, when validation runs, then it still satisfies `site/src/content.config.ts`.
- [ ] AC 6: Given blog/article content is requested, when no blog surface is declared, then the agent reports `surface missing: blog` and does not invent a path.
- [ ] AC 7: Given `README.md` or public docs copy changes, when the change affects positioning or claims, then `BUSINESS.md`, `PRODUCT.md`, `BRANDING.md`, `GTM.md`, and `claim-register.md` are checked.
- [ ] AC 8: Given shared editorial files need changes, when execution is planned, then those files are edited sequentially.
- [ ] AC 9: Given two exclusive public skill pages need copy-only updates, when a ready spec assigns one file per executor and no shared files are touched, then parallel edits may be allowed and integrated before closure.
- [ ] AC 10: Given `sg-docs`, `sg-repurpose`, `sg-audit-copy`, `sg-redact`, or `sg-enrich` touches public content, then the relevant skill instructions point to the editorial corpus and claim boundaries.
- [ ] AC 11: Given public docs are rendered by Astro, when the site builds, then no incompatible frontmatter or broken route/schema is introduced.
- [ ] AC 12: Given implementation finishes, when verification runs, then metadata lint passes for ShipGlows editorial artifacts and `cd shipglows-site && pnpm build` passes or the blocker is documented.

## Test Strategy

Structural checks:

- `test -f docs/editorial/README.md`
- `test -f docs/editorial/public-surface-map.md`
- `test -f docs/editorial/page-intent-map.md`
- `test -f docs/editorial/claim-register.md`
- `test -f docs/editorial/editorial-update-gate.md`
- `test -f docs/editorial/astro-content-schema-policy.md`
- `test -f docs/editorial/blog-and-article-surface-policy.md`
- `test -f templates/editorial_content_context.md`
- `test -f skills/references/editorial-content-corpus.md`
- `test -f skills/references/subagent-roles/editorial-reader.md`
- `test ! -e skills/references/subagent-roles/reader.md`
- `rg -n "Editorial Reader Agent Contract|read-only|editorial corpus|Editorial Update Plan|Claim Impact Plan|no edits|no staging" skills/references/subagent-roles/editorial-reader.md`

Coherence checks:

- `rg -n "TODO|TBD|PLACEHOLDER" docs/editorial templates/editorial_content_context.md skills/references/editorial-content-corpus.md`
- Compare `docs/editorial/public-surface-map.md` against `find site/src/pages -maxdepth 2 -type f` and `site/src/content/skills/`.
- Check that blog/article policy states no blog path is currently declared.
- Check that README and `site/src/pages/docs.astro` mention the editorial layer without reproducing internal role details.

Astro checks:

- Confirm local Astro version from `shipglows-site/pnpm-lock.yaml`.
- Confirm `shipglows-site/src/content.config.ts` still validates the `skills` collection fields.
- Run `cd shipglows-site && pnpm build` after implementation.

Claim and safety checks:

- `rg -n "security|privacy|compliance|AI|automation|speed|savings|availability|pricing" docs/editorial/claim-register.md`
- Manually review any strong public claims in README, public pages, docs overview, FAQ, pricing, and skill pages against the claim register.
- Verify `docs/editorial/` does not expose internal-only secrets, private URLs, credentials, tokens, or sensitive logs.

## Risks

- Security and trust risk: public claims can misrepresent security, privacy, compliance, permissions, data handling, or AI behavior.
- Product risk: public content can promise more than the code, specs, or reviewed business/product contracts support.
- Schema risk: adding ShipGlows metadata to runtime Astro content can break the site build.
- Editorial drift risk: README, public pages, FAQ, docs, and skill pages can diverge after behavior changes.
- Blog scope risk: agents may invent a blog path because the content skills know about blog formats, even though this repo has no declared blog surface.
- Parallel editing risk: public pages and shared maps/components can conflict when multiple agents edit content.
- Overprocess risk: internal-only changes should be allowed to produce `no editorial impact` with reason rather than forcing content updates.
- Maintenance risk: `docs/editorial/` can become stale if not audited by `sg-docs`.

## Execution Notes

Read first:

- `CONTENT_MAP.md`, `BUSINESS.md`, `PRODUCT.md`, `BRANDING.md`, `GTM.md`.
- `README.md`, `shipglows-site/src/pages/docs.astro`, `shipglows-site/src/pages/index.astro`, `shipglows-site/src/pages/faq.astro`, `shipglows-site/src/pages/pricing.astro`, `shipglows-site/src/pages/skills/index.astro`, `shipglows-site/src/pages/skills/[slug].astro`.
- `shipglows-site/src/content.config.ts`, `shipglows-site/package.json`, `shipglows-site/pnpm-lock.yaml`.
- `skills/sg-docs/SKILL.md`, `skills/sg-repurpose/SKILL.md`, `skills/sg-audit-copy/SKILL.md`, `skills/sg-redact/SKILL.md`, `skills/sg-enrich/SKILL.md`.
- `specs/shipglows-technical-documentation-layer-for-ai-agents.md`.

Implementation order:

```text
Foundation sequential:
  Task 1 -> Task 2 -> Task 3 -> Task 4 -> Task 5 -> Task 6 -> Task 7

Supporting artifacts:
  Task 8 -> Task 9 -> Task 9b

Integration:
  Task 10 -> Task 11 -> Task 12 -> Task 13 -> Task 14

Validation:
  Task 15
```

Safe waves after `/sg-ready`:

- Wave 0, sequential foundation: `docs/editorial/README.md`, public surface map, page intent map, claim register, gate, Astro schema policy, blog policy, `skills/references/editorial-content-corpus.md`, and `skills/references/subagent-roles/editorial-reader.md`.
- Wave 1, parallel only if assigned as exclusive files: page intent map and claim register may be drafted by separate agents after the index exists.
- Wave 2, sequential shared integration: `CONTENT_MAP.md`, `templates/content_map.md`, all skill files, README, workflow docs, and public docs page.
- Wave 3, final validation: metadata lint, static checks, Astro build.

Packages:

- No new package is expected.
- Do not add CMS, blog, RSS, search, analytics, or newsletter tooling in this chantier.

Abstractions to avoid:

- No second content registry that replaces `CONTENT_MAP.md`.
- No content calendar.
- No automatic claim publishing.
- No global ShipGlows metadata forced into Astro runtime content.
- No public exposure of internal-only technical docs.

Stop conditions:

- Stop and return to `/sg-spec` if the implementation would create a blog route or collection without an explicit blog-surface decision.
- Stop if Astro content schema changes are required beyond documenting current constraints.
- Stop if a sensitive public claim cannot be supported by product behavior, reviewed contracts, or explicit evidence.
- Stop if parallel edits would touch shared maps, shared pages, shared components, collection schema, nav/footer, README, docs overview, FAQ, or pricing.
- Stop if a plan attempts to use `skills/references/subagent-roles/reader.md`; the accepted role names are `technical-reader.md` and `editorial-reader.md`.
- Stop if the site build fails because of content schema or route changes.

## Open Questions

None.

The current decision is explicit: prepare editorial governance for blog/article content, but do not create a blog surface in this chantier because the repo does not declare one yet.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-01 10:05:10 UTC | sg-spec | GPT-5 Codex | Created initial draft spec for ShipGlows editorial content governance layer. | Draft existed but was not aligned with the current repo state after the interrupted turn. | `/sg-spec ShipGlows Editorial Content Governance Layer for AI Agents` |
| 2026-05-01 14:18:28 UTC | sg-spec | GPT-5 Codex | Reworked the spec around the actual Astro public-content surfaces, README, public docs, missing blog surface, claim governance, runtime schema constraints, and content skills. | Draft saved at `specs/shipglows-editorial-content-governance-layer-for-ai-agents.md`. | `/sg-ready ShipGlows Editorial Content Governance Layer for AI Agents` |
| 2026-05-01 14:37:51 UTC | sg-spec | GPT-5 Codex | Added the dedicated read-only Editorial Reader role contract, aligned it with the sg-build Technical Reader / Editorial Reader split, and explicitly rejected a reader.md alias. | Draft updated. | `/sg-ready ShipGlows Editorial Content Governance Layer for AI Agents` |
| 2026-05-01 14:50:34 UTC | sg-ready | GPT-5 Codex | Evaluated readiness gate for structure, metadata, user-story alignment, freshness, task order, docs coherence, language doctrine, adversarial risks, security posture, and open questions. | Ready: local dependency versions were aligned, Astro freshness evidence was rechecked, hidden dependencies were made explicit, metadata lint passed, and no blocking ambiguity remained. | `/sg-start ShipGlows Editorial Content Governance Layer for AI Agents` |
| 2026-05-01 19:08:22 UTC | sg-start | GPT-5 Codex | Implemented the editorial governance layer, editorial content template, editorial corpus reference, Editorial Reader role, metadata-linter support, content-map wiring, content skill gates, README/workflow/public-docs pointers, and related technical docs. | implemented | `/sg-verify ShipGlows Editorial Content Governance Layer for AI Agents` |
| 2026-05-01 19:58:45 UTC | sg-verify | GPT-5 Codex | Verified the editorial governance layer against the ready spec, corrected stale dependency metadata references, ran metadata lint, structural checks, skill budget audit, linter syntax/help checks, page-surface coverage checks, and risk scans. | partial: static and contract checks pass, but Astro build evidence remains pending because sg-verify does not run builds. | `/sg-check ShipGlows Editorial Content Governance Layer for AI Agents` |
| 2026-05-01 20:46:41 UTC | sg-check | GPT-5 Codex | Ran the missing Astro production build proof for the public site after sg-verify identified it as the only blocking evidence gap. | passed: `pnpm --dir shipglows-site build` generated 58 static pages, including `/docs` and dynamic `/skills/[slug]` pages. | `/sg-end ShipGlows Editorial Content Governance Layer for AI Agents` |
| 2026-05-01 20:48:10 UTC | sg-check | GPT-5 Codex | Re-ran scoped technical checks for the editorial governance chantier: Astro build, metadata lint, metadata linter compile check, whitespace diff check, npm audit high threshold, and npm outdated summary. | passed with known dependency note: build generated 58 pages, lint/compile/diff checks passed, no high/critical npm audit findings, Astro has a moderate advisory with latest major 6.2.1. | `/sg-end ShipGlows Editorial Content Governance Layer for AI Agents` |
| 2026-05-02 03:39:28 UTC | sg-end | GPT-5 Codex | Closed the editorial governance chantier, updated local and master task trackers, and prepared the changelog entry without committing or pushing. | closed | `/sg-ship ShipGlows Editorial Content Governance Layer for AI Agents` |
| 2026-05-02 04:46:54 UTC | sg-ship | GPT-5 Codex | Quick-shipped the editorial governance chantier after metadata lint, Python compile, whitespace diff, high-threshold npm audit, and Astro build checks passed. | shipped | None |

## Current Chantier Flow

```text
sg-spec: done, ready spec updated with dedicated Editorial Reader role and no reader.md alias
sg-ready: ready
sg-start: implemented
sg-verify: verified after sg-check supplied the missing Astro build evidence
sg-end: closed
sg-ship: shipped
```

Current state:

- Chantier identified: yes.
- Implementation started: yes.
- Spec path: `specs/shipglows-editorial-content-governance-layer-for-ai-agents.md`.
- Required next step: None.
- Execution rule: spec-first; implementation completed, verified, closed, and shipped.
