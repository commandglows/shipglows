---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.4.0"
project: ShipGlows
created: "2026-06-23"
updated: "2026-07-17"
status: draft
source_skill: 009-sg-skill-build
scope: app-blueprints
owner: Diane
confidence: high
risk_level: medium
security_impact: no
docs_impact: yes
linked_systems:
  - skills/references/preferred-stacks.md
  - skills/001-sg-build/SKILL.md
  - skills/001-sg-build/references/build-lifecycle-workflow.md
  - skills/900-shipglows-core/SKILL.md
  - skills/100-sg-spec/SKILL.md
  - skills/306-sg-scaffold/SKILL.md
  - skills/009-sg-marketing/SKILL.md
  - skills/references/master-workflow-lifecycle.md
  - skills/app-blueprints/
depends_on: []
supersedes: []
evidence:
  - "User decision 2026-06-23: blueprints serve as global spec skeletons for app archetypes."
  - "User decision 2026-06-23: each blueprint lives in its own GitHub repo, ShipGlows holds the registry."
  - "User decision 2026-06-23: the Blueprint Gate resolves via local cache first, clones from repo if missing."
  - "User decision 2026-06-25: blueprint extraction is a ShipGlows-internal operation, owned by 900-shipglows-core build."
  - "Extracted from contentglowz_app as first concrete Flutter blueprint."
  - "Operator correction 2026-07-17: blueprint matching must follow an explicit greenfield platform footprint so mobile-capable Flutter directions are not omitted by a website-only assumption."
  - "Operator correction 2026-07-17: preferred stack presets must resolve before blueprints so a domain-mismatched blueprint cannot displace the established Astro-site and Flutter-app direction."
next_review: "2026-08-15"
next_step: "Create GitHub repos for each blueprint, update registry URLs"
---

# App Blueprints

## Purpose

Blueprints are **global spec skeletons** for recurring app archetypes. They pre-fill stack decisions, data models, route structure, folder conventions, and architectural patterns so that `001-sg-build` does not navigate blindly when asked to create a new application.

A blueprint is not a full spec — it is an **app anatomy reference** that:
- Tells `001-sg-build` what kind of app this is and what patterns it follows
- Feeds `100-sg-spec` with a pre-filled architecture section
- Guides `306-sg-scaffold` with folder structure, naming conventions, and file patterns
- Gives `009-sg-marketing market` a target archetype for research scoping

## Distribution Model

Each blueprint lives in its own GitHub repository so it survives independently of ShipGlows.

`$SHIPGLOWS_ROOT/skills/app-blueprints/` holds:
- `README.md` — the **registry**: maps blueprint IDs to their GitHub repo URLs and keywords
- `<blueprint-id>/blueprint.md` — optional local cache of a cloned blueprint (for offline or ShipGlows-cloned setups)
- `<blueprint-id>/references/` — optional supplementary files

When ShipGlows is installed via the Codex plugin without a full clone, only the registry (`README.md`) ships with the plugin. The Blueprint Gate clones blueprints on demand from their GitHub repos.

## Resolution Order

The Blueprint Gate resolves a blueprint in this order:

1. **Local cache**: `$SHIPGLOWS_ROOT/skills/app-blueprints/<id>/blueprint.md` exists → use it
2. **External repo**: registry lists `source.repo` → `git clone --depth 1 <repo> <cache-dir>/<id>/` → use it
3. **No match**: proceed without blueprint (normal for novel app types)

The cache directory defaults to `$SHIPGLOWS_ROOT/skills/app-blueprints/`. If ShipGlows is not cloned (`$SHIPGLOWS_ROOT` unavailable), use `$HOME/.shipglows/blueprints/` as fallback cache.

## Registry Format

`$SHIPGLOWS_ROOT/skills/app-blueprints/README.md` is the canonical registry. It uses YAML frontmatter:

```yaml
available_blueprints:
  flutter-crud-content:
    name: Flutter CRUD Content App
    description: For apps with auth, entity list/detail/edit, offline queue
    match_keywords: [content, crud, carnet, gestion, flutter, mobile]
    source:
      repo: https://github.com/dianedefores/shipglows-blueprint-flutter-crud-content
      local: flutter-crud-content  # subdirectory name, if ShipGlows is cloned
```

Fields:
- `name`: human-readable display name
- `description`: one-line summary
- `match_keywords`: list of keywords for fuzzy matching against user requests
- `source.repo`: GitHub repo URL (the durable home of this blueprint)
- `source.local`: subdirectory name under `$SHIPGLOWS_ROOT/skills/app-blueprints/` when locally cached

## Blueprint Format

Every blueprint MUST have YAML frontmatter for machine parsing plus a Markdown body for human reading. The frontmatter includes the same `id`, `name`, `version`, `match_keywords`, `stack`, and `sources` fields.

Body sections:
1. **App Anatomy** — what this archetype does, who it serves, typical screens
2. **Stack** — framework, state, routing, HTTP, auth, storage, architecture style
3. **Models** — domain entities with fields, types, required/optional
4. **Routes** — route patterns, shell vs standalone, auth guard logic
5. **Conventions** — folder structure, naming, file patterns, code patterns
6. **Theme** — theming approach, responsive breakpoints
7. **States** — standard state handling (loading, empty, error, offline)

## Matching

Before keyword scoring, apply the Greenfield Platform Footprint Rule from
`skills/references/question-contract.md`. Product-domain keywords alone are not
enough: platform compatibility is a required matching dimension.

Then apply `skills/references/preferred-stacks.md`. A blueprint may refine an
accepted preset with validated architecture and conventions, but it must not
silently replace that preset. If they conflict, keep the preset and treat the
blueprint as evidence for a clearly disclosed exception only.

- Exclude a blueprint that cannot cover a required platform.
- Surface a Flutter-capable candidate when iOS/Android are required, even when
  the product-domain keywords do not make it the final archetype match.
- Treat a platform-compatible but domain-mismatched blueprint as a stack and
  conventions reference, not as consent to inherit its domain models/routes.
- For products combining an SEO-sensitive public website with mobile apps,
  allow a split recommendation instead of forcing one blueprint across every
  surface.

When `001-sg-build` receives a request like "crée une app de carnet de santé pour voiture":

1. Resolve the product's required launch and roadmap platforms.
2. Normalize the request to keywords: `[carnet, santé, voiture, health, log, vehicle]`
3. Scan the registry (`$SHIPGLOWS_ROOT/skills/app-blueprints/README.md`) for matching blueprints — match against required platforms plus `match_keywords`, `name`, and `description` (fuzzy, case-insensitive)
4. For each match found in the registry, resolve it (local cache → clone from repo)
5. If no match in registry, scan local `$SHIPGLOWS_ROOT/skills/app-blueprints/*/blueprint.md` as fallback
6. Return the best match or a shortlist; if no exact archetype matches, keep any platform-compatible candidate as a reference and proceed without falsely declaring an exact blueprint
7. If multiple blueprints could match, ask the user to choose

## Blueprint Repo Structure

Each GitHub repo for a blueprint follows this layout:

```
shipglows-blueprint-<id>/
  README.md                 # Blueprint overview + link to source app
  blueprint.md              # The blueprint (primary file, follows format above)
  references/               # Optional: patterns, examples, templates
  source/                   # Optional: link to the source app that validated this
```

The repo's `README.md` serves as the public face. ShipGlows reads only `blueprint.md`.

## Creating a New Blueprint

1. Ship an app of the new archetype.
2. Extract its repeatable patterns into a `blueprint.md`.
3. Create a GitHub repo: `shipglows-blueprint-<id>`.
4. Push `blueprint.md` + optional `references/` to the repo.
5. Add the entry to `$SHIPGLOWS_ROOT/skills/app-blueprints/README.md` registry.
6. Optionally clone it locally for offline use.

## How Skills Consume Blueprints

### 001-sg-build

The Blueprint Gate fires after `existing chantier check` and before `spec/readiness loop`:

```
intake -> chantier check -> BLUEPRINT GATE -> spec/readiness -> governance -> model routing -> start -> verify -> end -> ship
```

At the Blueprint Gate:
1. Match keywords against the registry.
2. Resolve each candidate (local → clone from repo).
3. Load the best-matching blueprint into the active context.
4. Add `Blueprint: [id] (v[version])` to the final report.
5. Pass `BLUEPRINT_PATH` to downstream skills via handoff context.

### 100-sg-spec

When a blueprint is loaded:
- Pre-fill the `Architecture`, `Stack`, and `Data Model` sections of the spec.
- Use the blueprint's model list as the starting point for domain entities.
- Use the blueprint's route structure as the navigation skeleton.
- The author still owns refinement and project-specific decisions.

### 306-sg-scaffold

When a blueprint is loaded:
- Use `conventions.folder_structure` and `conventions.naming` to decide where and how to place files.
- Use the model list to scaffold data classes and services.
- Use the route list to scaffold screens and their shell/guard wrappers.
- Do not invent patterns not present in the blueprint or the project.

### 009-sg-marketing market

When a blueprint is loaded:
- Use `app_type` to scope research to the relevant platform.
- Use `stack` to identify ecosystem competitors.
- Use the blueprint description as the "product category" for demand/keyword research.

## Blueprint Extraction Workflow

Use this workflow when the request is to create a new blueprint from an existing app (e.g. "extract a blueprint from ContentGlowz", "create a blueprint from ce projet").

### Trigger

`900-shipglows-core build` (ShipGlows internal artifact maintenance) owns this workflow. Route here from `000-shipglows` when the intake contains keywords like `extract`, `blueprint from`, `create blueprint`, `nouveau blueprint`, or equivalent. This is **not** an end-user flow — it maintains ShipGlows's own blueprint registry.

### Steps

1. **Identify source** — determine the app path or GitHub repo that validates the blueprint. This must be a shipped, working app.
2. **Explore app anatomy** — read the project structure, main entry points, router, state management, models, services, theme, and conventions. Use `306-sg-scaffold` exploration patterns.
3. **Extract stack** — document framework, SDK version, state management, routing, HTTP, auth, storage, architecture style, codegen status.
4. **Extract conventions** — document folder structure, naming, file patterns, model pattern, screen pattern, provider organization, theme system, responsive breakpoints.
5. **Write `blueprint.md`** — follow the Format section above (frontmatter + body sections). Include `source_repo` pointing to the app's repo.
6. **Register** — add the new blueprint to `$SHIPGLOWS_ROOT/skills/app-blueprints/README.md` registry with `source.repo` URL.
7. **Create GitHub repo** — recommend creating `shipglows-blueprint-<id>` repo and pushing the blueprint there. Point `source.repo` to it.
8. **Validate** — the blueprint must be self-consistent: every convention documented must match the source app. If in doubt, re-read the source.

### Output

```
Blueprint extracted: <id> (v<version>)
Source: <app path or repo>
Repo: <source.repo URL>
Registry: $SHIPGLOWS_ROOT/skills/app-blueprints/README.md
Next: push to GitHub repo, or use locally.
```
