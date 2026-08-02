---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-05-16"
updated: "2026-05-16"
status: draft
source_skill: 102-sg-start
scope: 305-sg-init-bootstrap-workflow
owner: unknown
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/305-sg-init/SKILL.md
  - skills/305-sg-init/references/bootstrap-workflow.md
depends_on:
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "0.1.0"
    required_status: "draft"
supersedes: []
evidence:
  - "Extracted from skills/305-sg-init/SKILL.md during Compact ShipGlows Skill Instructions Phase 2."
next_review: "2026-06-16"
next_step: "/103-sg-verify Compact ShipGlows Skill Instructions Phase 2"
---

# Bootstrap Workflow

## Purpose

Detailed bootstrap workflow, generated artifact templates, MCP setup, governance corpus bootstrap, and final reporting details.

This reference preserves the detailed pre-compaction instructions for `305-sg-init`. The top-level `SKILL.md` is now the activation contract; load this file only when the selected mode needs the detailed workflow, checklist, templates, or examples below.

## Detailed Instructions

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/shipglows`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `support-de-chantier`.

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active `specs/*.md` chantier is identified, append the current run to `Skill Run History`, update `Current Chantier Flow` when the run changes the chantier state, and open the report with the shared chantier header. If no unique chantier is identified, do not write to any spec; use a `(local)` chantier header with a short work name.


## Context

- Current directory: !`pwd`
- Package.json: !`cat package.json 2>/dev/null | head -60 || echo "no package.json"`
- Requirements.txt: !`cat requirements.txt 2>/dev/null | head -20 || echo "no requirements.txt"`
- Shell scripts: !`ls -1 *.sh 2>/dev/null | head -10 || echo "no .sh files"`
- Existing CLAUDE.md: !`head -30 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`
- Existing TASKS.md: !`head -20 TASKS.md 2>/dev/null || echo "no TASKS.md"`
- Directory listing: !`ls -la 2>/dev/null | head -30`
- Git remote: !`git remote -v 2>/dev/null | head -2 || echo "no git"`
- Project structure: !`find . -maxdepth 2 -type d 2>/dev/null | grep -v node_modules | grep -v .git | grep -v dist | sort | head -30`

## Mode detection

- **`$ARGUMENTS` is a path** → Init the project at that path.
- **`$ARGUMENTS` is empty** → Init the current directory.

---

## Flow

### Step 1: Detect project type

Analyze the project to determine:
- **Stack**: framework (Astro, Next.js, React, React Native, Vue, Python, Bash), runtime (Node, Python, Bun)
- **Package manager**: npm, yarn, pnpm, pip, none (detect from lockfiles)
- **UI framework**: React, Vue, Svelte, none
- **CSS solution**: Tailwind, UnoCSS, CSS Modules, styled-components, none
- **Content type**: blog, docs, app, CLI, API, library
- **i18n**: locale dirs, i18n config, bilingual content
- **Auth**: Clerk, Auth.js, Supabase Auth, none
- **Backend / DB**: Convex, Supabase Postgres, Firebase, custom API, none
- **Storage**: Supabase Storage, S3/R2, Firebase Storage, local, none
- **Hosting / platform signals**: Vercel, Netlify, Cloudflare, none
- **Payments**: Stripe, LemonSqueezy, none

### Step 2: Generate CLAUDE.md template

Create a `CLAUDE.md` with:

```markdown
# CLAUDE.md

This file provides guidance to Claude Code when working in this project.

## Project Overview
[Auto-detected: name, description, stack]

## Commands
[Auto-detected from package.json scripts, Makefile, or shell scripts]

## ShipGlows Development Mode

- development_mode: local | vercel-preview-push | hybrid
- validation_surface: local | vercel-preview | production | mixed
- ship_before_preview_test: yes | no | conditional
- post_ship_verification: 405-sg-prod | other | none
- deployment_provider: vercel | netlify | cloudflare | other | none
- preview_source: Vercel MCP deployment target_url | static URL | not applicable
- production_url: [URL or unknown]
- observability: sentry-required | sentry-static-exception | other
- diagnostic_surface: route/component/copy-action | missing | not applicable
- logs_copy_action: available | missing | not applicable
- diagnostic_log_header: commit/build + Paris/UTC build time | missing | not applicable
- notes: [short project-specific rule]
- last_reviewed: [YYYY-MM-DD]

## Architecture
[Auto-detected: directory structure, key patterns]

## Key Conventions
[Framework-specific conventions based on detected stack]
```

Use **AskUserQuestion** to let the user review and confirm:
- Question: "I've detected [stack summary]. Here's the generated CLAUDE.md — should I create it?"
- Options:
  - **Create as-is** — "Save the generated CLAUDE.md" (Recommended)
  - **Edit first** — "Let me review and adjust before saving"
  - **Skip** — "Don't create CLAUDE.md"

### Step 2.5: Record ShipGlows development mode

Read `${SHIPGLOWS_ROOT:-$HOME/shipglows}/skills/references/project-development-mode.md`, `${SHIPGLOWS_ROOT:-$HOME/shipglows}/skills/references/sentry-observability.md`, and `${SHIPGLOWS_ROOT:-$HOME/shipglows}/skills/references/runtime-diagnostics-surface.md`.

Every initialized project should have a project-local `## ShipGlows Development Mode` section in `CLAUDE.md`. If `CLAUDE.md` is skipped or absent, create or update `SHIPGLOWS.md` with the same section.

For runtime projects, record Sentry, the safe diagnostics/log-copy surface, the concrete component/helper/route that owns it, and whether copied logs start with commit/build identity plus Paris/UTC build time. Static sites may use the Sentry static-site exception only when they have no auth, account state, protected routes, checkout/payment, server-handled forms, webhooks, jobs, or user-specific runtime workflow.

If Vercel is detected, ask which mode this project uses:
- **Local dev** — "Tests run on local dev server; Vercel is checked after shipping"
- **Vercel preview push** — "Every browser/manual preview test requires 005-sg-ship, then 405-sg-prod waits for Vercel"
- **Hybrid** — "Local for unit/static checks, Vercel preview for auth, env, webhooks, serverless, routing"

If Vercel is not detected, default to local unless another hosted preview workflow is explicitly configured:
```markdown
- development_mode: local
- validation_surface: local
- ship_before_preview_test: no
- post_ship_verification: none
- deployment_provider: none
- preview_source: not applicable
- production_url: unknown
- observability: sentry-static-exception
- diagnostic_surface: not applicable
- logs_copy_action: not applicable
- diagnostic_log_header: not applicable
- notes: Local validation is the default until a hosting provider or preview workflow is configured.
- last_reviewed: [YYYY-MM-DD]
```

When the selected mode is `vercel-preview-push`, write:
```markdown
- development_mode: vercel-preview-push
- validation_surface: vercel-preview
- ship_before_preview_test: yes
- post_ship_verification: 405-sg-prod
- deployment_provider: vercel
- preview_source: Vercel MCP deployment target_url
- production_url: [custom domain or unknown]
- observability: sentry-required
- diagnostic_surface: [route/component/copy-action or missing]
- logs_copy_action: [available or missing]
- diagnostic_log_header: [commit/build + Paris/UTC build time or missing]
- notes: After each code change that needs browser/manual validation, run 005-sg-ship first, then 405-sg-prod must wait for the matching Vercel deployment before testing.
- last_reviewed: [YYYY-MM-DD]
```

When the selected mode is `hybrid`, write:
```markdown
- development_mode: hybrid
- validation_surface: mixed
- ship_before_preview_test: conditional
- post_ship_verification: 405-sg-prod
- deployment_provider: vercel
- preview_source: Vercel MCP deployment target_url
- production_url: [custom domain or unknown]
- observability: sentry-required
- diagnostic_surface: [route/component/copy-action or missing]
- logs_copy_action: [available or missing]
- diagnostic_log_header: [commit/build + Paris/UTC build time or missing]
- notes: Local checks are valid for unit/static work; hosted flows require 005-sg-ship -> 405-sg-prod before manual/browser testing.
- last_reviewed: [YYYY-MM-DD]
```

Never leave the section with pipe-delimited placeholders after init. Pick the confirmed/default values and keep unknowns explicit.

### Step 3: Create local project tracker

**Architecture**: In this phase, the active project backlog is local under the project umbrella.
- primary source of truth: `shipglows_data/workflow/TASKS.md`
- no central master aggregate is created; cross-project views are derived from local project trackers.
- do not point project operators to master files as a task source of truth.

`TASKS.md` is an operational tracker, not a metadata-bearing decision artifact. Do not add ShipGlows YAML frontmatter to generated `TASKS.md` files. Durable business, brand, guideline, spec, research, audit, review, or decision content belongs in separate artifacts with metadata.

**Check first**:
- prefer updating `shipglows_data/workflow/TASKS.md` when present
- if root `TASKS.md` exists as a real file, treat it as legacy local content: do not overwrite it, report layout migration debt, and route to `/300-sg-docs migrate-layout` unless an external project tool explicitly requires the root file
- if a legacy ShipGlows-created `TASKS.md` symlink points into `shipglows_data`, remove the symlink only; do not move or overwrite real project files.

If it does not exist:
1. Create directory `shipglows_data/workflow/`
2. Create `shipglows_data/workflow/TASKS.md` with the canonical format below
3. Do not create a symlink for this tracker

Never create a bare placeholder — populate with real tasks detected in Step 1:

```markdown
# Tasks — [project name]

> **Priority:** 🔴 P0 blocker · 🟠 P1 high · 🟡 P2 normal · 🟢 P3 low · ⚪ deferred
> **Status:** 📋 todo · 🔄 in progress · ✅ done · ⛔ blocked · 💤 deferred

---

## Setup

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | [First critical task based on detected stack — e.g. "Configure env vars", "Set up auth", "Deploy first build"] | 📋 todo |
| 🟠 | [Second high-priority task] | 📋 todo |

---

## [Core Feature Area — detected from project]

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | [Feature task] | 📋 todo |
| 🟡 | [Normal task] | 📋 todo |

---

## Backlog

| Pri | Task | Status |
|-----|------|--------|
| 🟢 | [Future improvement] | 💤 deferred |

---

## Audit Findings
<!-- Populated by /400-sg-audit — dated sections added automatically:

### Audit: [Domain] (YYYY-MM-DD)

**Fixed:**
- [x] Issue resolved

**Remaining:**
- [ ] 🔴 Blocker still open
- [ ] 🟠 High-priority finding
-->
```

Populate the initial tasks intelligently from what was detected in Step 1 (stack, framework, existing files, package.json scripts). Do not leave placeholder text like `[First critical task]` — replace with real tasks for this project.

### Step 4: Derive project discovery metadata

Do not register the project in a central `PROJECTS.md`. Project discovery is derived from the project path, local `shipglows_data/`, and root markers such as `AGENT.md`, `CLAUDE.md`, `package.json`, `pyproject.toml`, or equivalent stack files.

**Domain Applicability defaults** — auto-detect and report:
- Code: ✓ (always)
- Design: ✓ if has UI
- Copy: ✓ if has user-facing content
- SEO: ✓ if web project with public pages
- GTM: ✓ if commercial intent
- Translate: ✓ if i18n detected
- Deps: ✓ if has package manager
- Perf: ✓ (always)

### Step 5: Generate business, product, GTM & brand context files

This step is governed by `$SHIPGLOWS_ROOT/skills/references/guided-business-product-discovery.md`. The canonical starting structures are:

- `$SHIPGLOWS_ROOT/templates/business_context.md` → `shipglows_data/business/business.md`;
- `$SHIPGLOWS_ROOT/templates/product_context.md` → `shipglows_data/business/product.md`;
- `$SHIPGLOWS_ROOT/templates/gtm_context.md` → `shipglows_data/business/gtm.md`;
- `$SHIPGLOWS_ROOT/templates/brand_context.md` → `shipglows_data/branding/branding.md`.

Create them in that order because customer need and business promise constrain product scope, then GTM and brand. Existing confirmed content is preserved. A bootstrap draft may contain `hypothesis` and `unknown`, but it must not convert stack detection into operator-confirmed business truth. Ask one thematic question at a time, propose the exact section, and require `Confirmer`, `Corriger` or `Approfondir` before advancing. Use `artifact_version: "0.1.0"` while decisive placeholders or unknowns remain; use `1.0.0` only after explicit operator review.

The detailed examples below are formatting aids only. When they conflict with the canonical templates or guided-discovery reference, those canonical sources win.

Créer les fichiers de contexte business/marque dans le dossier `shipglows_data/` du repo du projet. Ces documents sont des contrats de décision du projet et leur source canonique doit rester dans le corpus gouverné par ShipGlows, au plus près du code, des specs et de la documentation qu'ils gouvernent.

`shipglows_data/workflow` porte le tracking local (`TASKS.md`, `AUDIT_LOG.md`, specs, bugs, reviews, audits). Les artefacts de gouvernance projet vivent dans `shipglows_data/business/*`, `shipglows_data/editorial/*` et `shipglows_data/technical/*` quand disponibles.

**Pour chaque fichier** : vérifier d'abord s'il existe déjà dans le projet. Si oui, sauter.

`shipglows_data/business/business.md`, `shipglows_data/branding/branding.md`, `shipglows_data/editorial/content-map.md` et `shipglows_data/technical/guidelines.md` sont des artefacts ShipGlows, pas de simples notes. Les anciens fichiers racine (`BUSINESS.md`, `BRANDING.md`, `CONTENT_MAP.md`, `GUIDELINES.md`, `CONTEXT.md`, `CONTEXT-FUNCTION-TREE.md`, `PRODUCT.md`, `GTM.md`, `ARCHITECTURE.md`) ne servent que de sources de migration quand ils existent encore. Ils ne sont pas des emplacements finaux conformes. Les artefacts doivent commencer par un frontmatter YAML ShipGlows avec `metadata_schema_version`, `artifact_version`, `status`, `confidence`, `risk_level`, `evidence`, `next_review`, `depends_on` et `supersedes`. À l'initialisation, utiliser `metadata_schema_version: "1.0"` et `artifact_version: "0.1.0"` tant que le contenu n'a pas été revu explicitement par l'utilisateur; passer à `artifact_version: "1.0.0"` seulement si les réponses utilisateur couvrent les décisions essentielles sans placeholder.

Les registres `shipglows_data/business/project-competitors-and-inspirations.md` et `shipglows_data/business/affiliate-programs.md` sont optionnels. `305-sg-init` ne les crée pas par défaut pour tous les projets. Si l'un d'eux existe déjà, reporter son statut et le faire valider par `/300-sg-docs update` ou le linter ShipGlows. Si l'utilisateur demande explicitement une initialisation marché/affiliation, utiliser les templates `templates/competitive_intelligence.md` et `templates/affiliate_program_registry.md`; sinon reporter `absent optionnel`.

#### 5a. shipglows_data/business/business.md

Commencer par une synthèse sourcée du contexte existant, puis poser uniquement la première question business à fort impact encore sans réponse. Ne jamais demander à l'opérateur de remplir le template seul.

Puis générer `[project_dir]/shipglows_data/business/business.md` :

```markdown
---
artifact: business_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "[project name]"
created: "[YYYY-MM-DD]"
updated: "[YYYY-MM-DD]"
status: "draft"
source_skill: 305-sg-init
scope: "business"
owner: "[user or team if known]"
confidence: "low"
risk_level: "medium"
business_model: "[detected or unknown]"
target_audience: "[short ICP/persona or unknown]"
value_proposition: "[one-line promise or unknown]"
market: "[country/language/niche or unknown]"
docs_impact: "yes"
security_impact: "unknown"
evidence:
  - "[user answer or detected source]"
depends_on: []
supersedes: []
next_review: "[YYYY-MM-DD]"
next_step: "/300-sg-docs update"
---

# Business — [project name]

## Mission
[Déduit de la réponse utilisateur — en 1-2 phrases]

## Proposition de valeur
[Quel problème résout-on ? Pourquoi nous plutôt qu'un concurrent ?]

## Audience cible
[Qui sont les utilisateurs ? Quel est leur niveau ? Quels sont leurs pain points ?]

## Business model
[Freemium, SaaS, e-commerce, contenu monétisé, service... — déduit du stack détecté : Stripe = payant, pas de payment = gratuit/early stage]

## Distribution
[Comment les utilisateurs trouvent le produit ? SEO, réseaux sociaux, bouche-à-oreille, paid ads...]

## Concurrents connus
[À compléter plus tard — laisser vide avec un placeholder "À renseigner via /009-sg-marketing market"]
```

Si l'utilisateur donne une réponse courte, proposer une interprétation à partir du contenu existant, la marquer `hypothesis` et demander confirmation. Le stack peut documenter ce qui existe techniquement, jamais confirmer l'audience, la promesse ou le modèle économique.

#### 5b. shipglows_data/branding/ bundle

Après confirmation du business et du produit, proposer une hypothèse de posture de marque reliée au client prioritaire, puis poser une seule question de différenciation émotionnelle ou de confiance. Les options suivantes ne sont que des contrastes possibles :
- Options :
  - **Pro & accessible** — "Expert mais pas condescendant, tutoiement OK" (Recommandé)
  - **Corporate & formel** — "Vouvoiement, ton institutionnel"
  - **Décontracté & fun** — "Familier, emojis OK, humour"
  - **Technique & précis** — "Documentation style, pas de fluff"

Puis générer au minimum :

- `[project_dir]/shipglows_data/branding/branding.md`
- `[project_dir]/shipglows_data/branding/voice-and-tone.md`
- `[project_dir]/shipglows_data/branding/messaging-pillars.md`
- `[project_dir]/shipglows_data/branding/brand-rules.md`

Générer aussi si le projet a une vraie surface publique ou UI :

- `[project_dir]/shipglows_data/branding/visual-identity.md`
- `[project_dir]/shipglows_data/branding/assets/README.md`

`branding.md` reste l'index canonique du bundle :

```markdown
---
artifact: brand_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "[project name]"
created: "[YYYY-MM-DD]"
updated: "[YYYY-MM-DD]"
status: "draft"
source_skill: 305-sg-init
scope: "branding"
owner: "[user or team if known]"
confidence: "low"
risk_level: "medium"
target_audience: "[from shipglows_data/business/business.md if known]"
value_proposition: "[from shipglows_data/business/business.md if known]"
market: "[country/language/niche or unknown]"
docs_impact: "yes"
security_impact: "none"
evidence:
  - "[tone selected by user]"
depends_on:
  - artifact: shipglows_data/business/business.md
    artifact_version: "0.1.0"
    required_status: "draft|reviewed"
supersedes: []
next_review: "[YYYY-MM-DD]"
next_step: "/300-sg-docs update"
---

# Branding — [project name]

## Bundle

- `voice-and-tone.md`
- `messaging-pillars.md`
- `brand-rules.md`
- `visual-identity.md` [si surface UI/publique]
- `assets/README.md` [si assets ou surface UI/publique]

## Rôle
[Décrire ce que le branding gouverne et ce qui reste côté business/technical]
```

Puis générer `voice-and-tone.md` :

```markdown
# Voice And Tone — [project name]

## Voix de marque
[Ton choisi — description en 2-3 phrases]

## Style d'adresse
[tu/vous — déduit du ton + langue du projet]

## Personnalité
[3-5 adjectifs qui décrivent la marque]
```

Puis `messaging-pillars.md` :

```markdown
# Messaging Pillars — [project name]

## Promesse
[Promesse centrale]

## Messages clés
- [...]
- [...]

## Claims boundaries
[Ce qui peut ou ne peut pas être promis]
```

Puis `brand-rules.md` :

```markdown
# Brand Rules — [project name]

## Copy rules
- do
- don't

## Claim rules
- allowed
- forbidden
```

Puis `visual-identity.md` si nécessaire :

```markdown
# Visual Identity — [project name]

## Direction visuelle
[Palette, typographie, imagerie, principes]
```

Puis `assets/README.md` si nécessaire :

```markdown
# Brand Assets — [project name]

## Inventory
- [asset path]
```
## Valeurs
[Déduites de la mission et du ton — 3-5 valeurs]

## Ce qu'on n'est PAS
[Anti-patterns de communication — ex: "jamais condescendant, jamais corporate bullshit"]
```

#### 5c. shipglows_data/technical/guidelines.md

Générer automatiquement depuis ce qui a été détecté en Step 1 + CLAUDE.md. Pas de question à l'utilisateur — c'est technique.

`[project_dir]/shipglows_data/technical/guidelines.md` :

```markdown
---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "[project name]"
created: "[YYYY-MM-DD]"
updated: "[YYYY-MM-DD]"
status: "draft"
source_skill: 305-sg-init
scope: "guidelines"
owner: "[user or team if known]"
confidence: "medium"
risk_level: "medium"
docs_impact: "yes"
security_impact: "unknown"
linked_systems: ["[detected auth/payments/backend/hosting if any]"]
evidence:
  - "Detected stack and project files during 305-sg-init"
depends_on:
  - artifact: CLAUDE.md
    artifact_version: "unknown"
    required_status: "draft|reviewed"
supersedes: []
next_review: "[YYYY-MM-DD]"
next_step: "/300-sg-docs audit"
---

# Guidelines — [project name]

## Stack technique
[Résumé du stack détecté]

## Conventions de code
[Extraites de CLAUDE.md, eslint config, prettier config, etc.]

## Structure du projet
[Arborescence des dossiers clés avec leur rôle]

## Conventions de contenu
[Langue du contenu, format des dates, format des URLs/slugs — détecté depuis le code]

## Outils et services
[Auth, payments, analytics, CMS, hosting — détectés en Step 1]
```

### Step 6: Create CHANGELOG.md + update trackers

**CHANGELOG.md** lives directly in the project directory (committed to git, visible to other devs).

If `CHANGELOG.md` doesn't exist in the project dir, create it:

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased] — [today's date]

### Added
- Initial project setup
```

**Local tracker** — create or update `[project_dir]/shipglows_data/workflow/TASKS.md` if present.

**Local audit log** — create or update `[project_dir]/shipglows_data/workflow/AUDIT_LOG.md` when an audit index is needed. Do not create root `AUDIT_LOG.md`; if it exists, treat it as layout migration debt unless an external project tool requires it.

### Step 7: Configure MCP servers

Always configure the Shipglows codebase MCP server, Context7 MCP, and OpenAI Docs MCP for this project by writing (or updating) `.claude/settings.json`.

If Clerk is detected in the project, propose adding the Clerk MCP and configure it when the user accepts.
Detection signals:
- `@clerk/*` in `package.json`
- source-level Clerk integration such as `clerkMiddleware`, `ClerkProvider`, or `@clerk/*` imports

If Convex is detected in the project, propose adding the Convex MCP and configure it when the user accepts.
Detection signals:
- `convex/` directory
- `convex.json`
- `convex.config.ts` or `convex.config.js`
- `convex` or `@convex-dev/*` in `package.json`

If Vercel is detected in the project, propose adding the Vercel MCP and configure it when the user accepts.
Detection signals:
- `vercel.json`
- `.vercel/project.json`
- `vercel` or `@vercel/*` in `package.json`

If Supabase is detected in the project, propose adding the Supabase MCP and configure it when the user accepts.
Detection signals:
- `supabase/` directory
- `supabase/config.toml`
- `@supabase/*` or `supabase` in `package.json`
- source-level Supabase integration such as `@supabase/*` imports, `supabase.auth`, or `createClient(...)`

Base config:

```json
{
  "mcpServers": {
    "codebase": {
      "command": "python3",
      "args": ["[ABSOLUTE_SHIPGLOWS_ROOT]/tools/codebase-mcp/server.py", "[ABSOLUTE_PROJECT_PATH]"]
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    },
    "openaiDeveloperDocs": {
      "url": "https://developers.openai.com/mcp"
    }
  },
  "disabledMcpServers": ["codebase"]
}
```

Resolve `[ABSOLUTE_SHIPGLOWS_ROOT]` from `$SHIPGLOWS_ROOT` first, or from `$HOME/shipglows` only when that fallback exists. Do not write shell variables in JSON MCP `args`; they are not shell-expanded.

If Clerk is accepted, add:

```json
"clerk": {
  "url": "https://mcp.clerk.com/mcp"
}
```

If Convex is accepted, add:

```json
"convex": {
  "command": "npx",
  "args": ["-y", "convex@latest", "mcp", "start"]
}
```

If Vercel is accepted, add:

```json
"vercel": {
  "url": "https://mcp.vercel.com"
}
```

If Supabase is accepted, add:

```json
"supabase": {
  "url": "https://mcp.supabase.com/mcp"
}
```

- Replace `[ABSOLUTE_PROJECT_PATH]` with the actual absolute path of the project.
- If `.claude/settings.json` already exists and has `mcpServers`, merge the base keys plus accepted detected integrations without overwriting other entries.
- Always add `codebase` to `disabledMcpServers` so the MCP is installed but inactive by default.
- Do not add `clerk` to `disabledMcpServers` by default when it is enabled for the project.
- Do not add `context7` to `disabledMcpServers` by default. Context7 should be available for current official docs, but only consumes model context when a tool call retrieves documentation.
- Do not add `openaiDeveloperDocs` to `disabledMcpServers` by default. OpenAI Docs MCP should be available for current OpenAI product/API/model docs, but only consumes model context when a tool call retrieves documentation.
- Do not add `convex`, `vercel`, or `supabase` to `disabledMcpServers` by default when they are enabled for the project.
- Create `.claude/` directory if needed.
- Skip silently if `${SHIPGLOWS_ROOT:-$HOME/shipglows}/tools/codebase-mcp/server.py` doesn't exist.

Operational guidance:
- OpenAI Docs MCP is the first source for current OpenAI API, Codex, model-selection, migration, and prompting guidance.
- Clerk MCP is for current SDK snippets and implementation patterns, not live auth-state inspection.
- Clerk CLI is for diagnostics and config operations such as `clerk doctor`, `clerk env pull`, `clerk config pull`, `clerk config patch`, and `clerk api`.
- Supabase MCP is for project state, SQL/logs/docs access, and schema-aware assistance. Prefer development or staging projects, not production.
- Supabase CLI is for local stack control, project linking, migrations, and type generation such as `supabase start`, `supabase link`, `supabase db pull`, `supabase db push`, and `supabase gen types`.
- For real auth-flow proof, use browser automation such as Playwright.

Also append the codebase-mcp usage protocol to the generated `CLAUDE.md` (after the Commands section):

```markdown
## Context MCP — Token-Saving Protocol

This project uses a local codebase MCP server for efficient context management.

### Every turn:
1. **Call `context_continue` FIRST** — returns files already in memory, avoids re-reads.
2. **Call `context_retrieve`** with your query to find relevant files.
3. **Use `context_read`** instead of Read for code exploration (tracks token budget).
4. **After editing**, call `context_register_edit` with a one-sentence summary.

See `${SHIPGLOWS_ROOT:-$HOME/shipglows}/tools/codebase-mcp/README.md` for full tool reference.
```

#### 5d. shipglows_data/editorial/content-map.md

Générer automatiquement depuis les dossiers détectés (`src/content`, `content`, `docs`, `app`, `pages`, routes marketing, collections Astro/MDX, changelog, FAQ/support si présents). Utiliser `templates/content_map.md` comme structure.

`[project_dir]/shipglows_data/editorial/content-map.md` doit cartographier :
- blog et articles
- documentation produit/API/support
- landing pages et pages marketing
- FAQ, changelog, newsletter/social si présents
- cocons sémantiques, pages piliers et pages de support
- règles de mise à jour entre surfaces

Ne pas le transformer en calendrier éditorial ou backlog. Si aucun blog/newsletter/FAQ n'existe, noter la surface comme absente ou `planned`, pas comme chemin inventé.

### Step 7.5: Governance Corpus Bootstrap

After `shipglows_data/editorial/content-map.md` generation or skip decision, detect and report the project-local governance corpus state. This step is a bootstrap and status gate; long-term maintenance stays owned by `300-sg-docs`.

Load these ShipGlows-owned references from `$SHIPGLOWS_ROOT` before creating or auditing governance files:
- `skills/references/technical-docs-corpus.md`
- `skills/references/editorial-content-corpus.md`
- `templates/technical_module_context.md`
- `templates/editorial_content_context.md`

Detect:
- code areas: `package.json`, lockfiles, `src/`, `app/`, `pages/`, `components/`, `lib/`, `convex/`, `supabase/`, `server/`, `api/`, `*.sh`, `*.py`, `*.ts`, `*.tsx`, `*.js`, `*.jsx`, `*.astro`, `*.vue`, or framework config files
- public surfaces: public routes, `site/`, `src/pages/`, `app/`, `pages/`, `docs/`, README public promises, FAQ, pricing, support copy, public skill pages, blog/article intent, `src/content`, `content/`, Astro/MDX runtime content, newsletter/social surfaces
- existing governance files: `shipglows_data/technical/README.md` (legacy source: `docs/technical/README.md`), `shipglows_data/technical/code-docs-map.md` (legacy source: `docs/technical/code-docs-map.md`), `shipglows_data/editorial/README.md` (legacy source: `docs/editorial/README.md`), `shipglows_data/editorial/content-map.md` (legacy source: `CONTENT_MAP.md`)
- agent entrypoint state: `AGENT.md` and `AGENTS.md`

#### Technical governance bootstrap

Technical governance is applicable to code projects by default.

If code areas are detected and `shipglows_data/technical/` can be written:
- create `shipglows_data/technical/README.md` when missing, using the `technical_module_context` schema as the metadata model but keeping the body as a concise index
- create `shipglows_data/technical/code-docs-map.md` when missing, with path patterns, primary technical doc targets, required validation commands, and documentation update triggers based on detected code areas
- when no major code area can be mapped precisely, still create `shipglows_data/technical/code-docs-map.md` with an explicit `non-coverage` reason and next step `/300-sg-docs technical`
- do not create a mega-doc during init; route subsystem detail to `/300-sg-docs technical`

If `shipglows_data/technical/` already exists (or legacy migration source `docs/technical/` exists):
- do not overwrite it
- report `shipglows_data/technical: already existed` or `shipglows_data/technical: needs audit`
- name `/300-sg-docs technical` as the recovery command when the map is missing, stale, or incomplete

If no code areas are detected:
- report `technical governance: skipped - no code areas detected`
- do not invent code paths

#### Editorial governance bootstrap

Editorial governance is applicable when public pages, README public promises, docs, FAQ, pricing, support copy, public skill pages, blog/article intent, or runtime content surfaces exist.

If public surfaces are detected and `shipglows_data/editorial/` can be written:
- create `shipglows_data/editorial/README.md` when missing
- create `shipglows_data/editorial/ROADMAP.md` when missing, using the minimal operational template from the bootstrap starter templates
- create baseline project-specific editorial governance files when evidence exists: `public-surface-map.md`, `page-intent-map.md`, `claim-register.md`, `editorial-update-gate.md`, `astro-content-schema-policy.md`, and `blog-and-article-surface-policy.md`
- keep entries evidence-based; do not copy ShipGlows's own repository-specific conclusions into the target project
- preserve runtime content schema boundaries. Do not add ShipGlows metadata to `src/content/**`, Astro collections, MDX consumed by the app, CMS entries, or other runtime content unless the local schema explicitly accepts it
- if a blog or article output is requested but no blog route is declared, record `surface missing: blog` instead of inventing a route

If public surfaces are detected and `shipglows_data/editorial/` already exists:
- preserve existing governance files
- create `shipglows_data/editorial/ROADMAP.md` when it is missing and the folder is writable
- otherwise report whether the roadmap `already existed`, `created`, `blocked`, or `needs audit`

If no public/content surfaces are detected:
- report `editorial governance: skipped - no editorial surfaces detected`
- report `shipglows_data/editorial/ROADMAP.md: skipped - no editorial surfaces detected`
- name `/300-sg-docs editorial` as the adoption command if public surfaces appear later

If public surfaces are detected but `shipglows_data/editorial/` cannot be created safely:
- report `editorial governance: blocked`
- report `shipglows_data/editorial/ROADMAP.md: blocked`
- name the blocked files and the next safe command `/300-sg-docs editorial`
- do not strengthen README, docs, public claims, FAQ, pricing, or support copy until the editorial governance state is created, audited, skipped with reason, or explicitly marked pending

#### Agent entrypoint compatibility

`AGENT.md` is the canonical agent routing entrypoint.

- If `AGENT.md` is missing, create a baseline project-specific entrypoint that points to `CLAUDE.md`, `shipglows_data/technical/context.md`, `shipglows_data/technical/code-docs-map.md`, `shipglows_data/editorial/content-map.md`, and `README.md`. If only legacy sources such as root `CONTEXT.md`, root `CONTENT_MAP.md`, or `docs/technical/code-docs-map.md` exist, mention them as layout migration debt and route to `/300-sg-docs migrate-layout`.
- If `AGENTS.md` is missing and symlinks are supported, create `AGENTS.md -> AGENT.md` as compatibility only.
- If `AGENTS.md` exists as a symlink to `AGENT.md`, report it as OK.
- If `AGENTS.md` exists as a real file or points elsewhere, report `AGENTS.md: compatibility conflict` and ask before converting or preserving it as external-tool-specific guidance.

The final report must make silent success impossible by showing `created`, `already existed`, `skipped`, `blocked`, or `needs audit` for each governance layer.

### Step 8: Confirm domain applicability

Use **AskUserQuestion**:
- Question: "Which audit domains apply to [project name]?"
- `multiSelect: true`
- Options: Code, Design, Copy, SEO, GTM, Translate, Deps, Perf
- Pre-select based on auto-detection from Step 4
- Description for each: what was detected (or "not detected — opt in manually")

Record the user's confirmed domain selection in the local init report or project-local governance notes when needed; do not write central `PROJECTS.md`.

### Step 9: Report

```
PROJECT INITIALIZED: [name]
═══════════════════════════════════
Stack:       [detected stack]
Path:        [project path]
CLAUDE.md:   [created / skipped / already existed]
shipglows_data/workflow/TASKS.md:    [created / skipped / already existed / legacy root migration debt]
shipglows_data/workflow/AUDIT_LOG.md: [created / skipped / already existed / legacy root migration debt]
shipglows_data/business/business.md: [created / skipped / already existed]
shipglows_data/branding/branding.md: [created / skipped / already existed]
shipglows_data/business/project-competitors-and-inspirations.md: [absent optional / created on request / already existed / needs audit]
shipglows_data/business/affiliate-programs.md: [absent optional / created on request / already existed / needs audit]
shipglows_data/editorial/content-map.md: [created / skipped / already existed]
shipglows_data/editorial/ROADMAP.md: [created / skipped - no editorial surfaces detected / already existed / blocked / needs audit]
shipglows_data/technical/guidelines.md: [created / skipped / already existed]
AGENT.md:    [created / already existed / blocked]
AGENTS.md:   [symlink created / symlink ok / absent / compatibility conflict]
shipglows_data/technical: [created / already existed / skipped - no code areas detected / needs audit / blocked]
shipglows_data/editorial: [created / already existed / skipped - no editorial surfaces detected / needs audit / blocked]
MCP:         [configured / skipped]
Project discovery: [local markers present / needs AGENT.md or shipglows_data marker / blocked]
Domains:     [list of applicable domains]
═══════════════════════════════════
Next steps:
  /400-sg-audit        — Run initial audit
  /105-sg-check        — Verify build passes
  /309-sg-tasks        — Start tracking work
  /300-sg-docs technical — Bootstrap or audit technical governance
  /300-sg-docs editorial — Bootstrap or audit editorial governance when public surfaces exist
```

---

## Important

- Never overwrite an existing CLAUDE.md without asking.
- Never overwrite an existing root `TASKS.md` or root `AUDIT_LOG.md`; migrate with `/300-sg-docs migrate-layout` after collision checks.
- Do not create or update a central `PROJECTS.md`.
- Detect the stack from actual files, not just project name.
- The generated CLAUDE.md should match the style of existing project CLAUDE.md files in the workspace.
