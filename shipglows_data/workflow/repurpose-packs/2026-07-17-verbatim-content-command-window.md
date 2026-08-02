---
artifact: verbatim_archive
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-17"
updated: "2026-07-17"
status: draft
source_skill: 007-sg-content
scope: content-command-window
owner: Diane
confidence: high
risk_level: low
security_impact: none
docs_impact: no
source_type: conversation
source_ref: "/home/claude/.codex/sessions/2026/07/17/rollout-2026-07-17T08-03-25-019f6f1a-08df-76e3-af6b-30844945049f.jsonl; response_item message extraction indices 42..46 immediately before command index 47"
linked_systems:
  - skills/007-sg-content
depends_on: []
supersedes: []
evidence:
  - "Five immediately preceding user/assistant messages preserved verbatim at the operator's request."
next_step: "None; verbatim preservation only."
---

# Verbatim Archive

User message 1

$007-sg-content verbatim

User message 2

<skill>
<name>007-sg-content</name>
<path>/home/claude/shipglowz/skills/007-sg-content/SKILL.md</path>
---
name: 007-sg-content
description: "Orchestrate substantive content lifecycles across sources, claims, public surfaces, validation, and ship."
argument-hint: '[goal | source | file | mode: plan, repurpose, draft, enrich, audit, marketing, seo, editorial, apply, ship]'
---

Primary artifact type: `master-workflow`.

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/shipglows`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, internal scripts, and public skill content must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `obligatoire`.
Process role: `lifecycle`.

Before executing from a spec-first chantier, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md`, read the spec's `Skill Run History` and `Current Chantier Flow`, append a current `007-sg-content` row with result `implemented`, `partial`, `blocked`, or `rerouted`, update `Current Chantier Flow`, and open with the opening chantier header from `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

If no unique chantier spec is identified, do not write to any spec. Route to `/700-sg-explore <content idea>` when the content intent, surface, source, or public promise is too fuzzy to frame a ready spec. Route to `/100-sg-spec <content lifecycle title>` when the work is non-trivial, multi-surface, claim-sensitive, or requires a new content surface.

## Report Modes

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, outcome-first, and using the opening chantier header. Use `report=agent`, `handoff`, `verbose`, or `full-report` only when another agent needs file lists, validation matrices, source evidence, or unresolved gate state.

## ShipGlows-Owned Preflight

Apply `$SHIPGLOWS_ROOT/skills/references/shipglows-owned-preflight.md` before reading ShipGlows-owned references, running ShipGlows-owned tools/scripts, or checking ShipGlows-owned editorial/runtime surfaces.

## Master Delegation

Before choosing execution topology, load `$SHIPGLOWS_ROOT/skills/references/master-delegation-semantics.md`.

This skill follows that reference; local nuances below only narrow or route it. Content lifecycle work defaults to delegated sequential when reading, drafting, editing, validating, applying public-content updates, or preparing ship. Parallel content work is allowed only from ready `Execution Batches` with non-overlapping surfaces.

## Master Workflow Lifecycle

Before resolving content phases, load `$SHIPGLOWS_ROOT/skills/references/master-workflow-lifecycle.md`.

Use the shared skeleton for intake, content work item resolution, readiness, model/topology routing, owner-skill execution, validation, verification, and post-verify ship routing. Local sections below define content surfaces, owner routes, and public-claim gates only.

## Mission

`007-sg-content` is the master lifecycle for content management. It decides which content lane should run, applies governance gates, and carries content work toward validation and ship routing.

It is the content lifecycle master (`master-workflow`): it decides how source, surface, claim, specialist-owner, validation, and ship work should stay coherent from intake to publishable output.

`007-sg-content` owns content lifecycle coherence across source, surface, claims, quality, and ship, not generic writing detached from governance.

It routes content work to specialist owner skills and keeps the lifecycle coherent.

## Scope Gate

`007-sg-content` routes content lifecycle work. It does not replace specialist owner skills or invent new public surfaces on the fly.

Do not activate it for an explicit atomic string, placeholder, typo, heading-tag, or formatting replacement that needs no content strategy, claim decision, or new surface. Execute that change directly and run the focused surface check.

## Required References

Load before routing or execution:

- `$SHIPGLOWS_ROOT/skills/007-sg-content/references/content-router.md` for mode selection, spec gates, governance gates, owner routing, and rubric details.
- `$SHIPGLOWS_ROOT/skills/007-sg-content/references/repurpose-playbook.md` only for the explicit `repurpose <source>` lane; it preserves source-faithful, verbatim, storage, safety, and handoff behavior without creating another public command.
- `$SHIPGLOWS_ROOT/skills/references/content-owner-handoffs.md` for the canonical content-owner matrix and minimum handoff payload.
- `$SHIPGLOWS_ROOT/skills/references/source-intake-classification.md` when the input is a pasted source, email, URL, transcript, note, article, or example whose project, angle, or owner route is not already settled.
- `$SHIPGLOWS_ROOT/skills/references/editorial-content-corpus.md` when public content, README public promises, docs, FAQ, pricing, support copy, public skill pages, blog/article intent, claims, or runtime content are in scope.
- `$SHIPGLOWS_ROOT/skills/references/content-quality-rubric.md` when mode includes audit, final draft, final repurpose, enrichment validation, or verification handoff with a required quality score.
- `$SHIPGLOWS_ROOT/skills/references/public-first-content-default.md` when Diane invokes content work and has not explicitly redirected it toward internal content or `300-sg-docs`.
- `$SHIPGLOWS_ROOT/skills/references/repurpose-pack-storage.md` when content work starts from a source and should preserve a durable source-faithful pack in the project repo.

## Inspiration Gate

For sales-page creation, offer-page copy, CTA/proof/objection sequencing, copy-pattern comparison, or explicit inspiration requests, load `$SHIPGLOWS_ROOT/skills/references/design-inspiration-library.md`. Filter only the private `index.yaml`, present at most five reference IDs with fit reasons, and require operator selection before loading detailed records or treating references as direction. Pass selected reference IDs to the owner skill and require them in the resulting spec/copy artifact; summarize copy patterns without long verbatim reuse or screenshot redistribution. Market, competitor, pricing, positioning, and differentiation work stays in `shipglows_data/business/project-competitors-and-inspirations.md`.

## Validation

Run the checks that match changed surfaces.

For ShipGlows skill or workflow changes:

```bash
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
"${SHIPGLOWS_ROOT:-$HOME/shipglows}/tools/shipglows_sync_skills.sh" --check --skill 007-sg-content
```

For ShipGlows docs/specs/content-map artifacts:

```bash
python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/specs README.md shipglows_data/workflow/playbooks/spec-driven-workflow.md shipglows_data/editorial/content-map.md shipglows_data/business/business.md shipglows_data/business/product.md shipglows_data/branding/branding.md shipglows_data/business/gtm.md shipglows_data/business/project-competitors-and-inspirations.md shipglows_data/business/affiliate-programs.md shipglows_data/technical/context.md shipglows_data/technical shipglows_data/editorial shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md
```

For public site or runtime content:

```bash
pnpm --dir shipglows-site build
```

For public-claim and leak scans:

```bash
rg -n "secret|token|credential|private key|BEGIN .*KEY" README.md shipglows_data/editorial/content-map.md shipglows_data site/src skills
rg -n "surface missing: blog|Editorial Update Plan|Claim Impact Plan|Astro content schema|claim register" shipglows_data/editorial/content-map.md shipglows_data/editorial skills site/src/content/skills
```

Use `108-sg-browser` when public visual or route behavior needs observed browser evidence. Use `405-sg-prod` only for deployed truth and `109-sg-auth-debug` only for auth/session flows.

## Fresh Docs Gate

When a content task depends on current external framework/runtime/provider behavior, run the Documentation Freshness Gate from `$SHIPGLOWS_ROOT/skills/references/documentation-freshness-gate.md`.

Record one explicit verdict:

- `fresh-docs checked`
- `fresh-docs not needed`
- `fresh-docs gap`
- `fresh-docs conflict`

For OpenAI, SDK, framework, SEO/AEO, crawler, analytics, or platform claims, use the relevant official docs or owner skill freshness rules before publishing current claims.

## Security and Abuse Constraints

- Treat public claims as product promises.
- Never publish secrets, private URLs, internal logs, tokens, credentials, private keys, or sensitive operational details.
- Never present roadmap or speculative content as shipped behavior.
- Never strengthen security, privacy, compliance, AI reliability, automation quality, speed, savings, availability, pricing, or business outcome claims without evidence.
- Never add ShipGlows governance frontmatter to runtime content unless the schema accepts it.
- Never ship with unrelated dirty files unless the user explicitly authorizes wider scope.
- Never create content paths outside the declared surfaces without a spec or explicit surface decision.

## Stop Conditions

Stop and report `blocked` when:

- no source, goal, or surface can be inferred and the user has not answered a targeted question
- a blog/article/newsletter/social/support surface is requested but undeclared
- content strategy or public claims require a spec and readiness is not `ready`
- an owner skill should handle the work and bypassing it would duplicate specialist responsibility
- the claim register marks a claim `blocked`, `needs proof`, or `claim mismatch`
- runtime content schema would be violated
- public site build fails
- metadata lint fails on changed artifacts
- skill budget audit fails hard for skill changes
- runtime skill links are missing, stale, or blocked by non-symlink files
- verification fails
- ship scope includes unrelated dirty files without explicit approval

## Final Report

Follow the shared reporting contract. In addition to its required outcome and proof, identify the selected content lane and owner boundary, editorial status, and Fresh Docs Gate verdict. Use `report=agent` only for source classification, pack-storage decision, owner handoff, validation evidence, or unresolved claim risks that the next owner needs.

## Rules

- Orchestrate; do not duplicate specialist internals.
- Follow shared operator-partnership doctrine. In content work, apply the obvious editorial follow-through that stays inside the current surface and owner contract before asking for framing help.
- For Diane, presume public content by default and arbitrate only the correct declared public surface unless she explicitly asks for internal content or routes through `300-sg-docs`.
- Own `repurpose <source>` as one bounded local mode: load its playbook, keep verbatim requests archival, create only the governed source-faithful pack when safe, then hand downstream work to the established owner.
- Keep content source truth separate from public claims.
- Prefer declared surfaces over invented paths.
- Ask only targeted questions when the answer changes mode, surface, scope, security, claims, or ship posture.
- Use spec-first for non-trivial or public-claim-sensitive content work.
- Follow the shared master delegation reference for delegated sequential defaults and spec/batch-gated parallelism.
- Preserve runtime schemas.
- Validate before ship routing.

</skill>

User message 3

$007-sg-content verbatim 3

User message 4

<skill>
<name>007-sg-content</name>
<path>/home/claude/shipglowz/skills/007-sg-content/SKILL.md</path>
---
name: 007-sg-content
description: "Orchestrate substantive content lifecycles across sources, claims, public surfaces, validation, and ship."
argument-hint: '[goal | source | file | mode: plan, repurpose, draft, enrich, audit, marketing, seo, editorial, apply, ship]'
---

Primary artifact type: `master-workflow`.

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/shipglows`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, internal scripts, and public skill content must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `obligatoire`.
Process role: `lifecycle`.

Before executing from a spec-first chantier, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md`, read the spec's `Skill Run History` and `Current Chantier Flow`, append a current `007-sg-content` row with result `implemented`, `partial`, `blocked`, or `rerouted`, update `Current Chantier Flow`, and open with the opening chantier header from `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

If no unique chantier spec is identified, do not write to any spec. Route to `/700-sg-explore <content idea>` when the content intent, surface, source, or public promise is too fuzzy to frame a ready spec. Route to `/100-sg-spec <content lifecycle title>` when the work is non-trivial, multi-surface, claim-sensitive, or requires a new content surface.

## Report Modes

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, outcome-first, and using the opening chantier header. Use `report=agent`, `handoff`, `verbose`, or `full-report` only when another agent needs file lists, validation matrices, source evidence, or unresolved gate state.

## ShipGlows-Owned Preflight

Apply `$SHIPGLOWS_ROOT/skills/references/shipglows-owned-preflight.md` before reading ShipGlows-owned references, running ShipGlows-owned tools/scripts, or checking ShipGlows-owned editorial/runtime surfaces.

## Master Delegation

Before choosing execution topology, load `$SHIPGLOWS_ROOT/skills/references/master-delegation-semantics.md`.

This skill follows that reference; local nuances below only narrow or route it. Content lifecycle work defaults to delegated sequential when reading, drafting, editing, validating, applying public-content updates, or preparing ship. Parallel content work is allowed only from ready `Execution Batches` with non-overlapping surfaces.

## Master Workflow Lifecycle

Before resolving content phases, load `$SHIPGLOWS_ROOT/skills/references/master-workflow-lifecycle.md`.

Use the shared skeleton for intake, content work item resolution, readiness, model/topology routing, owner-skill execution, validation, verification, and post-verify ship routing. Local sections below define content surfaces, owner routes, and public-claim gates only.

## Mission

`007-sg-content` is the master lifecycle for content management. It decides which content lane should run, applies governance gates, and carries content work toward validation and ship routing.

It is the content lifecycle master (`master-workflow`): it decides how source, surface, claim, specialist-owner, validation, and ship work should stay coherent from intake to publishable output.

`007-sg-content` owns content lifecycle coherence across source, surface, claims, quality, and ship, not generic writing detached from governance.

It routes content work to specialist owner skills and keeps the lifecycle coherent.

## Scope Gate

`007-sg-content` routes content lifecycle work. It does not replace specialist owner skills or invent new public surfaces on the fly.

Do not activate it for an explicit atomic string, placeholder, typo, heading-tag, or formatting replacement that needs no content strategy, claim decision, or new surface. Execute that change directly and run the focused surface check.

## Required References

Load before routing or execution:

- `$SHIPGLOWS_ROOT/skills/007-sg-content/references/content-router.md` for mode selection, spec gates, governance gates, owner routing, and rubric details.
- `$SHIPGLOWS_ROOT/skills/007-sg-content/references/repurpose-playbook.md` only for the explicit `repurpose <source>` lane; it preserves source-faithful, verbatim, storage, safety, and handoff behavior without creating another public command.
- `$SHIPGLOWS_ROOT/skills/references/content-owner-handoffs.md` for the canonical content-owner matrix and minimum handoff payload.
- `$SHIPGLOWS_ROOT/skills/references/source-intake-classification.md` when the input is a pasted source, email, URL, transcript, note, article, or example whose project, angle, or owner route is not already settled.
- `$SHIPGLOWS_ROOT/skills/references/editorial-content-corpus.md` when public content, README public promises, docs, FAQ, pricing, support copy, public skill pages, blog/article intent, claims, or runtime content are in scope.
- `$SHIPGLOWS_ROOT/skills/references/content-quality-rubric.md` when mode includes audit, final draft, final repurpose, enrichment validation, or verification handoff with a required quality score.
- `$SHIPGLOWS_ROOT/skills/references/public-first-content-default.md` when Diane invokes content work and has not explicitly redirected it toward internal content or `300-sg-docs`.
- `$SHIPGLOWS_ROOT/skills/references/repurpose-pack-storage.md` when content work starts from a source and should preserve a durable source-faithful pack in the project repo.

## Inspiration Gate

For sales-page creation, offer-page copy, CTA/proof/objection sequencing, copy-pattern comparison, or explicit inspiration requests, load `$SHIPGLOWS_ROOT/skills/references/design-inspiration-library.md`. Filter only the private `index.yaml`, present at most five reference IDs with fit reasons, and require operator selection before loading detailed records or treating references as direction. Pass selected reference IDs to the owner skill and require them in the resulting spec/copy artifact; summarize copy patterns without long verbatim reuse or screenshot redistribution. Market, competitor, pricing, positioning, and differentiation work stays in `shipglows_data/business/project-competitors-and-inspirations.md`.

## Validation

Run the checks that match changed surfaces.

For ShipGlows skill or workflow changes:

```bash
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
"${SHIPGLOWS_ROOT:-$HOME/shipglows}/tools/shipglows_sync_skills.sh" --check --skill 007-sg-content
```

For ShipGlows docs/specs/content-map artifacts:

```bash
python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/specs README.md shipglows_data/workflow/playbooks/spec-driven-workflow.md shipglows_data/editorial/content-map.md shipglows_data/business/business.md shipglows_data/business/product.md shipglows_data/branding/branding.md shipglows_data/business/gtm.md shipglows_data/business/project-competitors-and-inspirations.md shipglows_data/business/affiliate-programs.md shipglows_data/technical/context.md shipglows_data/technical shipglows_data/editorial shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md
```

For public site or runtime content:

```bash
pnpm --dir shipglows-site build
```

For public-claim and leak scans:

```bash
rg -n "secret|token|credential|private key|BEGIN .*KEY" README.md shipglows_data/editorial/content-map.md shipglows_data site/src skills
rg -n "surface missing: blog|Editorial Update Plan|Claim Impact Plan|Astro content schema|claim register" shipglows_data/editorial/content-map.md shipglows_data/editorial skills site/src/content/skills
```

Use `108-sg-browser` when public visual or route behavior needs observed browser evidence. Use `405-sg-prod` only for deployed truth and `109-sg-auth-debug` only for auth/session flows.

## Fresh Docs Gate

When a content task depends on current external framework/runtime/provider behavior, run the Documentation Freshness Gate from `$SHIPGLOWS_ROOT/skills/references/documentation-freshness-gate.md`.

Record one explicit verdict:

- `fresh-docs checked`
- `fresh-docs not needed`
- `fresh-docs gap`
- `fresh-docs conflict`

For OpenAI, SDK, framework, SEO/AEO, crawler, analytics, or platform claims, use the relevant official docs or owner skill freshness rules before publishing current claims.

## Security and Abuse Constraints

- Treat public claims as product promises.
- Never publish secrets, private URLs, internal logs, tokens, credentials, private keys, or sensitive operational details.
- Never present roadmap or speculative content as shipped behavior.
- Never strengthen security, privacy, compliance, AI reliability, automation quality, speed, savings, availability, pricing, or business outcome claims without evidence.
- Never add ShipGlows governance frontmatter to runtime content unless the schema accepts it.
- Never ship with unrelated dirty files unless the user explicitly authorizes wider scope.
- Never create content paths outside the declared surfaces without a spec or explicit surface decision.

## Stop Conditions

Stop and report `blocked` when:

- no source, goal, or surface can be inferred and the user has not answered a targeted question
- a blog/article/newsletter/social/support surface is requested but undeclared
- content strategy or public claims require a spec and readiness is not `ready`
- an owner skill should handle the work and bypassing it would duplicate specialist responsibility
- the claim register marks a claim `blocked`, `needs proof`, or `claim mismatch`
- runtime content schema would be violated
- public site build fails
- metadata lint fails on changed artifacts
- skill budget audit fails hard for skill changes
- runtime skill links are missing, stale, or blocked by non-symlink files
- verification fails
- ship scope includes unrelated dirty files without explicit approval

## Final Report

Follow the shared reporting contract. In addition to its required outcome and proof, identify the selected content lane and owner boundary, editorial status, and Fresh Docs Gate verdict. Use `report=agent` only for source classification, pack-storage decision, owner handoff, validation evidence, or unresolved claim risks that the next owner needs.

## Rules

- Orchestrate; do not duplicate specialist internals.
- Follow shared operator-partnership doctrine. In content work, apply the obvious editorial follow-through that stays inside the current surface and owner contract before asking for framing help.
- For Diane, presume public content by default and arbitrate only the correct declared public surface unless she explicitly asks for internal content or routes through `300-sg-docs`.
- Own `repurpose <source>` as one bounded local mode: load its playbook, keep verbatim requests archival, create only the governed source-faithful pack when safe, then hand downstream work to the established owner.
- Keep content source truth separate from public claims.
- Prefer declared surfaces over invented paths.
- Ask only targeted questions when the answer changes mode, surface, scope, security, claims, or ship posture.
- Use spec-first for non-trivial or public-claim-sensitive content work.
- Follow the shared master delegation reference for delegated sequential defaults and spec/batch-gated parallelism.
- Preserve runtime schemas.
- Validate before ship routing.

</skill>

User message 5

# AGENTS.md instructions for /home/claude/shipglows

<INSTRUCTIONS>
---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "0.6.0"
project: "ShipGlows"
created: "2026-04-25"
updated: "2026-06-23"
status: draft
source_skill: manual
scope: "agent-entrypoint"
owner: "unknown"
confidence: "high"
risk_level: "low"
security_impact: "none"
docs_impact: "yes"
linked_systems: ["CLAUDE.md", "shipglows_data/technical/context.md", "shipglows_data/technical/context-function-tree.md", "shipglows_data/editorial/content-map.md", "README.md", "shipglows_data/technical/", "shipglows_data/technical/code-docs-map.md", "shipglows_data/technical/blacksmith.md", "skills/references/canonical-paths.md", "shipglows_data/business/project-competitors-and-inspirations.md", "shipglows_data/business/affiliate-programs.md", "skills/references/app-blueprints.md", "skills/app-blueprints/README.md"]
depends_on: []
supersedes: []
evidence: ["Repository structure and active context docs", "shipglows_data/editorial/content-map.md added as the content routing artifact", "Canonical path resolution added for ShipGlows-owned tools and references", "Technical documentation layer added for code-proximate agent routing", "Blacksmith CI/SSH Access routing added for APK build and log debugging.", "Business registries added for project competitors/inspirations and affiliate programs.", "App blueprints system added: app-blueprints.md contract, flutter-crud-content blueprint from ContentGlowz, Blueprint Gate in 001-sg-build."]
next_step: "/sg-docs update AGENT.md"
---

# AGENT

## Role

Ce fichier est le point d'entree rapide pour un agent qui arrive dans le repo. Il ne doit pas dupliquer toute la doc. Il doit diriger vers le bon contexte le plus vite possible.

## Read Order

1. Lire `CLAUDE.md` pour les contraintes du repo.
2. Lire `shipglows_data/technical/context.md` pour la carte operative du projet.
3. Lire `shipglows_data/technical/context-function-tree.md` si la tache touche les scripts Bash principaux ou `lib.sh`.
4. Lire `shipglows_data/technical/code-docs-map.md` si la tache touche du code, un outil, une skill, un template, le site public ou la documentation technique.
5. Lire `shipglows_data/editorial/content-map.md` si la tache touche contenu, repurposing, blog, docs publiques, landing pages, FAQ ou cocons semantiques.
6. Lire `README.md` pour la vue d'ensemble publique et les workflows officiels.

## Route By Task

  - Pour tout fichier interne ShipGlows, resoudre depuis `${SHIPGLOWS_ROOT:-$HOME/shipglows}`. Cela inclut `skills/`, `skills/references/`, `templates/`, `tools/`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md` et `shipglows_data/technical/metadata-migration-guide.md`. Le repo courant ne sert de racine que pour les artefacts et le code du projet audite ou modifie.
- Si la tache touche la creation d'une app ou l'utilisation du Blueprint Gate (consommation), lire `$SHIPGLOWS_ROOT/skills/references/app-blueprints.md` puis `$SHIPGLOWS_ROOT/skills/app-blueprints/README.md`; le Blueprint Gate appartient à `001-sg-build`.
- Si la tache touche l'extraction d'un blueprint depuis une app existante (creation/maintenance interne ShipGlows), lire `$SHIPGLOWS_ROOT/skills/references/app-blueprints.md` puis `$SHIPGLOWS_ROOT/skills/app-blueprints/README.md`; la creation d'un blueprint appartient à `900-shipglows-core build`.
- Si la tache touche le CLI principal, commencer par `shipglows.sh`, `lib.sh`, puis `shipglows_data/technical/context.md`.
- Si la tache touche le setup serveur ou Codex, lire `install.sh`, `config.sh`, puis `shipglows_data/technical/context.md`.
- Si la tache touche les tunnels SSH locaux, lire `local/local.sh`, `local/dev-tunnel.sh`, puis `shipglows_data/technical/context-function-tree.md`.
- Si la tache touche Blacksmith, runners CI, Testboxes, logs CI, APK/AAB Android, SSH Access runner ou debugging de build GitHub Actions, lire `shipglows_data/technical/blacksmith.md`; pour une verification deploy/logs, router via `skills/405-sg-prod/SKILL.md`, et pour une release complete via `skills/004-sg-deploy/SKILL.md`.
- Si la tache touche les skills, lire `README.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md`, puis les `skills/*/SKILL.md` concernes.
  - Si la tache touche la metadata des docs, lire `$SHIPGLOWS_ROOT/shipglows_data/technical/metadata-migration-guide.md`, `$SHIPGLOWS_ROOT/tools/shipglows_metadata_lint.py`, puis `$SHIPGLOWS_ROOT/skills/300-sg-docs/SKILL.md`.
- Si la tache touche un code area mappe, lire `shipglows_data/technical/code-docs-map.md`, puis le doc primaire dans `shipglows_data/technical/`. `AGENT.md` reste canonique; `AGENTS.md` ne doit etre qu'un symlink de compatibilite vers `AGENT.md`.
- Si la tache touche contenu, repurposing, blog, docs publiques, landing pages ou cocons semantiques, lire `shipglows_data/editorial/content-map.md`, puis `skills/202-sg-repurpose/SKILL.md` si la demande transforme une source en contenu.
- Si la tache touche produit, audience, priorites ou scope, lire `shipglows_data/business/business.md`, `shipglows_data/business/product.md`, puis `shipglows_data/business/gtm.md` si la demande touche la promesse publique.
- Si la tache touche concurrents, alternatives, inspirations, references marche, differenciation ou anti-patterns par projet, lire `shipglows_data/business/project-competitors-and-inspirations.md`, puis `shipglows_data/business/gtm.md`.
- Si la tache touche affiliation, referral, sponsorship, partner programs, liens remuneres ou disclosure commerciale, lire `shipglows_data/business/affiliate-programs.md`, puis `shipglows_data/business/gtm.md`.
- Si la tache touche architecture ou conventions techniques, lire `shipglows_data/technical/architecture.md`, `shipglows_data/technical/guidelines.md`, puis `shipglows_data/technical/context.md`.

## Context Docs

- `CLAUDE.md`: contraintes techniques et patterns critiques.
- `shipglows_data/technical/context.md`: architecture, entry points, flux, hotspots, invariants, ou modifier quoi.
- `shipglows_data/technical/context-function-tree.md`: arbre de fonctions des scripts principaux.
- `shipglows_data/editorial/content-map.md`: surfaces de contenu, pages piliers, cocons semantiques, destinations de repurposing.
- `shipglows_data/workflow/playbooks/spec-driven-workflow.md`: doctrine de travail spec-first et artefacts.
- `shipglows_data/technical/metadata-migration-guide.md`: doctrine de migration frontmatter.
- `shipglows_data/technical/README.md`: index interne des docs techniques proches du code.
- `shipglows_data/technical/code-docs-map.md`: map code -> docs, validations et triggers de mise a jour.
- `shipglows_data/technical/blacksmith.md`: Blacksmith CI, APK builds, logs, Run History, Metrics, SSH Access, Testboxes.
- `shipglows_data/business/business.md`: contrat business.
- `shipglows_data/business/product.md`: contrat produit.
- `shipglows_data/branding/branding.md`: contrat de marque.
- `shipglows_data/business/gtm.md`: contrat de promesse publique et de distribution.
- `shipglows_data/business/project-competitors-and-inspirations.md`: registre des concurrents, alternatives, inspirations et anti-patterns par projet.
- `shipglows_data/business/affiliate-programs.md`: registre des programmes d'affiliation, referral, partner et disclosure par projet.
- `shipglows_data/technical/architecture.md`: contrat de structure technique.
- `shipglows_data/technical/guidelines.md`: conventions techniques et de contribution.
- `skills/references/app-blueprints.md`: systeme de blueprints (squelettes de specs globales pour archetypes d'applications). Lire avant `001-sg-build` pour toute creation d'app.
- `skills/app-blueprints/`: catalogue des blueprints disponibles, indexes dans `README.md`.

## Rules

- Ne pas lire tout le repo avant d'identifier la zone utile.
- Sur hote Linux ARM64 (`aarch64`/`arm64`), ne pas lancer de build Android release local: pas de `flutter build apk --release`, `flutter build appbundle --release`, `./gradlew assembleRelease` ou `./gradlew bundleRelease`; router les APK/AAB vers Blacksmith ou une CI Linux x64. Localement, limiter Flutter a `flutter analyze`, `flutter test` et `flutter build web --release`.
- Utiliser `shipglows_data/technical/context.md` comme index, pas comme verite absolue.
- Si `shipglows_data/technical/context.md` et le code divergent, le code gagne et la doc doit etre corrigee.
- Pour une tache locale, lire seulement la doc specialisee necessaire.
- Pour une tache ambigue ou transverse, lire `shipglows_data/technical/context.md` avant de parcourir le code.

</INSTRUCTIONS><environment_context>
  <cwd>/home/claude/shipglows</cwd>
  <shell>bash</shell>
  <current_date>2026-07-17</current_date>
  <timezone>Etc/UTC</timezone>
  <filesystem><workspace_roots><root>/home/claude/shipglows</root></workspace_roots><permission_profile type="disabled"><file_system type="unrestricted" /></permission_profile></filesystem>
  <subagents>
    - close: Nash
    - fix_lock: Turing
    - ship: McClintock
  </subagents>
</environment_context>
