---
name: 306-sg-scaffold
description: "Scaffold pages, components, routes, hooks, and utilities."
disable-model-invocation: true
argument-hint: <type> <name> (e.g., "page about", "component UserCard")
---

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/shipglows`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `support-de-chantier`.

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active `specs/*.md` chantier is identified, append the current run to `Skill Run History`, update `Current Chantier Flow` when the run changes the chantier state, and open the report with the opening chantier header. If no unique chantier is identified, do not write to any spec; use a `(local)` chantier header with a short work name.


## Context

- Current directory: !`pwd`
- Project CLAUDE.md: !`head -80 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`
- Package.json: !`cat package.json 2>/dev/null | head -40 || echo "no package.json"`
- Project structure: !`find . -maxdepth 3 -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.astro" -o -name "*.vue" -o -name "*.py" -o -name "*.sh" \) 2>/dev/null | grep -v node_modules | grep -v .git | grep -v dist | sort | head -40`
- Blueprint path: !`echo "${BLUEPRINT_PATH:-}" 2>/dev/null || echo "no blueprint"`

## Required References

Load `$SHIPGLOWS_ROOT/skills/references/design-system-token-contract.md` before scaffolding any `page`, `component`, or `layout`, or any artifact that introduces UI styling, design tokens, visual states, theming, typography, color, spacing, shadows, motion, or branding implementation.

When `$BLUEPRINT_PATH` is set or a `blueprint:` handoff is present, load `$SHIPGLOWS_ROOT/skills/references/app-blueprints.md` for the blueprint system contract, then read the blueprint file at the given path. Use its conventions, models, and route structure as scaffolding guidance (see Blueprint-Aware Scaffolding below).

## Mode detection

Parse `$ARGUMENTS` for type and name:
- `page about` → type: page, name: about
- `component UserCard` → type: component, name: UserCard
- `api users` → type: api, name: users
- Empty → use the runtime's structured question tool when available, or a concise plain-text question

---

## Supported types

| Type | Description | Typical location |
|------|-------------|-----------------|
| `page` | Route/page file | `src/pages/`, `app/`, `pages/` |
| `component` | UI component | `src/components/`, `components/` |
| `layout` | Layout wrapper | `src/layouts/`, `app/layout` |
| `api` | API route/endpoint | `src/pages/api/`, `app/api/`, `convex/` |
| `content` | Content/blog post | `src/content/`, `content/` |
| `hook` | Custom hook | `src/hooks/`, `hooks/` |
| `util` | Utility function | `src/utils/`, `src/lib/`, `utils/` |

## Blueprint-Aware Scaffolding

When a blueprint is loaded (via `$BLUEPRINT_PATH` or `blueprint:` handoff), apply these additional rules before and during the normal flow:

### Convention Resolution Order

Blueprint conventions supplement, not replace, project examples. Resolution order:
1. Project examples (what the project actually does) — highest priority.
2. Blueprint conventions (what the blueprint recommends) — used when the project has no convention or when scaffolding a new entity not yet present in the project.
3. LLM inference — lowest priority, used only when neither project nor blueprint provides guidance.

### Folder and Naming

- Use `blueprint.conventions.folder_structure` to decide where to place files when no project examples exist for that entity type.
- Use `blueprint.conventions.naming` for file/class/provider naming when the project has no established pattern for the scaffolded type.
- If the project already has a different convention, the project wins.

### Models

- Use `blueprint.models` as a starting point for data class scaffolding.
- Each blueprint model entry provides field names, types, and patterns (e.g., `copyWith`, `fromJson`/`toJson`, `const` constructors).
- Adapt to the project's actual style (codegen vs hand-written, equality pattern) — the blueprint is a reference, not a template copy.

### Routes

- Use `blueprint.router` to determine the route pattern when scaffolding a new screen (shell vs standalone, GoRouter vs file-based, guard structure).
- Use `router.screens` to know which screens exist and scaffold new ones alongside them.

### Report

Add to the scaffold report:
```
Blueprint: [id] (v[version]) — conventions used for [folder/naming/models/routes]
```

### Clean Slate Projects

When no project files exist yet (truly clean slate), the blueprint becomes the primary source of truth:
- Scaffold the full folder structure from `blueprint.conventions.folder_structure`.
- Use `blueprint.stack` to guide package/dependency scaffolding.
- Use `blueprint.models` to scaffold model files.
- Use `blueprint.router` to scaffold the route file.
- Use `blueprint.name` as project name hint.

## Flow

### Step 1: Parse arguments

If `$ARGUMENTS` is empty, use the runtime's structured question tool when available, or a concise plain-text question:
- Q1: "What type of file should I scaffold?"
  - Options: page, component, layout, api, content, hook, util
- Q2: "What name?" (free text — user types via "Other")

Then capture the required product intent before generating anything:
- what user-facing outcome this file serves
- who the actor is
- whether the artifact is public-facing, internal, admin-only, or system-only
- whether it reads/writes sensitive data, performs privileged actions, calls external services, or changes an existing user flow
- whether it requires docs, README, examples, FAQ, onboarding, pricing, changelog or support copy to stay coherent

If any of those points is unclear and could materially change behavior, scope, product coherence, or security, stop and ask targeted questions instead of scaffolding immediately.

Use targeted prompts, not generic ones. Prefer questions that force an implementable decision, for example:
- "Is this page public, authenticated, or admin-only?"
- "Should this API route only read data, or can it also create/update/delete?"
- "Can users from another org/project ever access this resource?"
- "Is this meant to fit an existing flow, or is it the first step of a new flow?"
- "If the backend check fails, should the UI hide the action, disable it, or show an explicit error state?"

Do not invent answers when ambiguity affects:
- auth or authorization
- tenant/org/project boundaries
- data visibility, retention, export, or logging
- destructive or billable actions
- public navigation, SEO, analytics, or conversion flows
- success/error states that shape the product experience
- docs or support surfaces that would mislead users if left unchanged

### Step 2: Find existing examples

Find 2-3 existing files of the same type in the project:

```bash
# For pages:
find src/pages -maxdepth 2 -type f | head -3
# For components:
find src/components -maxdepth 2 -type f | head -3
# etc.
```

Read each example file completely.

Also read the nearest files that define the surrounding flow, not only files of the same type. Examples:
- for a `page`: nearby layout, route group, navigation entry, metadata, loading/error states
- for a `component`: parent screen/section, design primitives, tests, stories if present
- for an `api`: auth middleware, validators, service layer, neighboring endpoints, contract tests
- for `content`: sibling entries, schema/config, listing page, SEO fields

If the request appears to create a new public-facing surface, read enough nearby files to answer:
- how this product currently names and groups similar flows
- what level of polish/structure is expected
- where the canonical design-system authority lives: brand contract, token source, theme carrier, component bridge, layout/motion authority, and forbidden bypasses
- where auth, validation, analytics, SEO, and error handling are usually enforced

If Supabase is detected and the scaffold touches auth, uploads, storage, or DB-backed CRUD, load only the relevant references among `${SHIPGLOWS_ROOT:-$HOME/shipglows}/skills/references/supabase-auth.md`, `${SHIPGLOWS_ROOT:-$HOME/shipglows}/skills/references/supabase-storage.md`, `${SHIPGLOWS_ROOT:-$HOME/shipglows}/skills/references/supabase-db.md` before generating code.

### Step 3: Analyze patterns

From the examples, extract:
- **File extension**: `.astro`, `.tsx`, `.vue`, `.py`, etc.
- **Naming convention**: PascalCase, kebab-case, camelCase
- **Import style**: relative vs alias (`@/`), named vs default
- **Component structure**: function vs arrow, export style
- **Styling approach**: Tailwind classes, CSS modules, scoped styles
- **Design-system authority**: canonical tokens, theme/config files, component primitives, spacing/typography/color/shadow/motion rules, and validation command
- **TypeScript patterns**: interface vs type, Props naming, generics
- **Frontmatter**: Astro frontmatter patterns, metadata
- **Framework patterns**: `getStaticPaths`, `loader`, `useQuery`, etc.

Also analyze product and risk coherence:
- **User story fit**: what user/job this file appears to serve
- **Flow placement**: entrypoint, next step, cancellation path, empty/loading/error states
- **Terminology**: product naming already used in UI/content/routes/docs
- **Quality bar**: baseline for copy clarity, accessibility, validation, feedback states, loading states, responsiveness
- **Security model**: where auth/authz, input validation, server enforcement, tenant scoping, and audit-sensitive behavior are handled
- **Documentation model**: where similar features are documented, linked, exampled, onboarded, or explained to support users

If Supabase is part of the flow, also extract:
- which client boundary the project uses for the operation (`browser`, `server`, `service-role`)
- how RLS and tenant ownership are enforced
- how storage paths and DB rows stay consistent

If the requested scaffold would conflict with existing terminology, route structure, component API shape, trust boundary patterns, or active documentation, stop and surface the conflict before generating.

### Step 4: Generate new file

Create the new file matching EXACTLY the patterns found:
- Same file extension
- Same naming convention
- Same import style and structure
- Same export pattern
- Same styling approach
- Placeholder content that matches the pattern

Additional generation rules:
- Preserve product coherence before speed. The scaffold must fit the surrounding user flow, naming, and quality bar.
- Preserve design-system authority before local convenience. Do not introduce raw visual literals, one-off spacing, colors, shadows, font sizes, radii, animation values, or ad-hoc component variants unless they already resolve through the declared token/component system.
- Preserve documentation coherence. If the scaffold introduces or changes feature behavior, create/update the matching doc surface only when the existing pattern is clear; otherwise report the doc gap.
- Default to the safest existing pattern, not the loosest one.
- For public-facing pages/components/content, include the states needed to avoid a broken or misleading experience: loading, empty, error, success, and permission-denied states when relevant.
- For API routes or server-facing code, do not scaffold privileged mutations, cross-tenant access, secret handling, webhook trust, or file processing unless the required security behavior is explicit from the project patterns or clarified by the user.
- Never rely on UI visibility alone as a control. If an action needs authorization, scaffold the server-side enforcement pattern used by the project, or stop and ask.
- Never scaffold raw acceptance of untrusted input when the project uses validation/sanitization/allowlists elsewhere.
- Never scaffold public artifacts with placeholder claims that could misrepresent pricing, security, compliance, availability, or product capabilities.
- If no safe and coherent version can be inferred, refuse to generate and list the blocking questions.
- If the project has UI but no discoverable design-system authority, refuse visual scaffolding and route to `300-sg-docs` or `006-sg-design system` before generating styled UI. A behavior-only shell may be created only when it adds no new visual decisions.

For ambiguous requests, produce a professional safe shell only when it is still useful and honest; never fake completeness:
- `page`: route shell with explicit pending-decision markers for approved copy and behavior, plus safe empty/error structure
- `component`: production-shaped presentational shell with typed props and no invented business logic
- `api`: read-only or stubbed handler returning `501 Not Implemented` until auth/authz/validation decisions are confirmed
- `content`: draft entry clearly marked as draft, following schema without invented promises

### Step 5: Report

When a blueprint was used:
```
SCAFFOLDED: [type] — [name]
─────────────────────────────
File:     [created file path]
Based on: [example files used]
Blueprint: [id] (v[version]) — conventions used for [aspects]
Patterns: [key patterns matched]
─────────────────────────────
```

When no blueprint was used (existing behavior):
```
SCAFFOLDED: [type] — [name]
─────────────────────────────
File:     [created file path]
Based on: [example files used]
Patterns: [key patterns matched]
─────────────────────────────
```

If scaffolding is blocked, report instead:

```text
NOT SCAFFOLDED: [type] — [name]
Reason: [behavior/scope/security/product coherence ambiguity]
Blueprint: [id] if applicable
Questions:
- [targeted decision needed]
- [targeted decision needed]
Safe path:
- [professional next step or safe shell that would be acceptable]
```

---

## Important

- **Never invent patterns.** Always derive from existing files in the project.
- **Consistency > creativity.** The generated file should look like it was written by the same developer.
- **Tokens > local styling.** Visual scaffolds must consume existing tokens, primitives, theme variables, or component APIs; they must not create a parallel style system.
- **User story > local convenience.** If a scaffold fits the code style but weakens the product flow or obscures the user outcome, it is not acceptable.
- **Ask when behavior matters.** Use targeted user prompts whenever uncertainty changes the actor, trigger, permissions, scope, or expected outcome.
- **Security by default.** Refuse to scaffold insecure defaults for public-facing, privileged, data-bearing, or externally exposed surfaces.
- **Coherence by default.** Refuse to introduce route names, copy, component APIs, or flow states that conflict with the surrounding product language and quality level.
- **Docs by default.** For feature scaffolds, identify whether docs/examples/onboarding/support should be updated or explicitly report `Documentation impact: none, because ...`.
- If no examples of the requested type exist, tell the user and ask how to proceed.
- For Astro projects: detect whether to use `.astro`, `.tsx`, or `.vue` based on existing patterns.
- For content files: use the project's content schema (Content Collections, MDX frontmatter).
- Name the file following the project's existing naming convention (don't impose a different one).
- Place the file in the correct directory based on where existing files of that type live.
- For requests touching auth, permissions, tenant boundaries, billing, uploads, admin, webhooks, external integrations, or public marketing surfaces, explicitly state the inferred risk level in the report:
  - `Security impact: none, because ...`
  - `Security impact: yes, scaffold limited by ...`
- When a blueprint is available, prefer its conventions over LLM inference for folder structure, naming, model patterns, and route structure. The blueprint represents patterns validated by shipped apps.
