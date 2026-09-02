---
artifact: portfolio_project_pitch_links_index
metadata_schema_version: "1.0"
artifact_version: "0.5.0"
project: "ShipGlows"
created: "2026-06-27"
updated: "2026-09-02"
status: draft
source_skill: sg-docs
scope: "project-pitches"
owner: "unknown"
confidence: medium
risk_level: medium
security_impact: none
docs_impact: yes
target_projects: "ShipGlows and project-local ShipGlows governance corpora"
source_policy: "Keep each pitch short, stable, and tied to a single source of truth. Distinguish public pitch text from internal framing notes."
linked_systems:
  - skills/references/private-memory-store.md
evidence:
  - "User asked for an internal governance doc that gives a quick pitch for each project."
  - "Operator confirmed ShipGlows positioning decision SG-BIZ-2026-08-13-01."
  - "Operator confirmed the shared business-framework category on 2026-08-22."
  - "ShipGlows App's project-local business corpus defines it as a managed multi-project SaaS on 2026-09-02, superseding the historical read-only desktop-dashboard framing."
  - "Disk-backed portfolio audit on 2026-09-02 found thirteen canonical Git projects and established one reviewed root PITCH.md navigation card for each."
depends_on:
  - artifact: "shipglows_data/business/business.md"
    artifact_version: "1.5.0"
    required_status: reviewed
  - artifact: "shipglows_data/business/product.md"
    artifact_version: "1.6.0"
    required_status: reviewed
  - artifact: "shipglows_data/business/gtm.md"
    artifact_version: "1.6.0"
    required_status: reviewed
supersedes: []
next_review: "2026-09-13"
next_step: "Keep root project pitches current through the shared pitch audit"
---

# Portfolio Project Pitch Links Index

## Purpose

This is the portfolio index for project pitch URLs, not the pitch file for any single project.

It exists so the agent can recover project identity quickly during portfolio-level reasoning, especially when the operator is speaking from a `#shipglows-owner` posture and the conversation needs to branch across multiple projects. Each row should point to that project’s own pitch URL when one exists; the ShipGlows row is the index itself.

## When To Use

- Portfolio-level business reasoning across ShipGlows, Winflowz, Socialglowz, and other operator-owned projects.
- Quick recentering when the operator mentions another project and wants the agent to carry the right framing forward.
- Internal governance updates to business, product, GTM, or brand documents.
- Cross-project comparison where a short pitch is enough to recall the role of each asset.

## Source Rules

- Keep each pitch to one or two sentences.
- Treat the pitch as a durable summary, not as a sales page.
- Link each entry to the project's source-of-truth docs and its own pitch URL.
- Prefer a GitHub URL to the versioned pitch file for each project.
- Keep the portfolio index URL separate from the per-project pitch URL.
- Separate observable facts from inferred positioning.
- Update the pitch when the business model, audience, or promise materially changes.
- Do not let the pitch replace product, GTM, or brand contracts.

## Private Cache Rule

This public file is only the portfolio index. It may contain project names, pitch URLs, short routing notes, statuses, and source-of-truth pointers.

Fetched pitch contents, private pitch summaries, and reusable source material belong in the approved private memory root:

```text
${SHIPGLOWS_PRIVATE_DATA_DIR:-${SHIPGLOWS_PRIVATE_DIR:-$HOME/.shipglows}/data}
```

Use `skills/references/private-memory-store.md` for the storage rules. The default pitch cache location is:

```text
${SHIPGLOWS_PRIVATE_DATA_DIR:-${SHIPGLOWS_PRIVATE_DIR:-$HOME/.shipglows}/data}/projects/
```

Do not copy cached pitch bodies, private repo contents, or source excerpts into this public index.

## Status Values

- `candidate`: project exists but the pitch is not yet reviewed.
- `reviewed`: pitch is current enough to use in routing and governance.
- `stale`: pitch exists but no longer matches current project truth.
- `archived`: pitch kept only for historical context.

## Project Index

| Project | Pitch file URL | Audience | Business angle | Source of truth | Status | Owner | Evidence date | Next action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ShipGlows | `https://github.com/commandglows/shipglows/blob/dev/PITCH.md` | Solo founders, small teams, and AI agents working from shared business truth | Open and inspectable business framework carrying intent through identity, product, content, engineering, delivery, and proof | `shipglows_data/business/business.md`, `shipglows_data/business/product.md`, `shipglows_data/business/gtm.md` | reviewed | Diane | 2026-09-02 | Keep framework and managed-SaaS identities distinct |
| Best Fried Chicken Namur | `https://github.com/dianedef/bestfriedchicken/blob/main/PITCH.md` | Local pickup and delivery customers; restaurant operators | Direct mobile-first ordering that reduces marketplace dependency while preserving restaurant control | `shipglows_data/business/business.md`, `shipglows_data/workflow/specs/direct-ordering-platform.md` | reviewed | Best Fried Chicken Namur | 2026-09-02 | Refresh after menu, fulfilment, payment, and publication evidence changes |
| Chrome BRAT | `https://github.com/commandglows/chrome-brat/blob/main/PITCH.md` | People tracking public GitHub browser-extension repositories | Local-first revision tracking and extraction while browser loading remains explicit | `README.md` | reviewed | Diane | 2026-09-02 | Add governed business/product truth if the utility becomes a broader product |
| CommandGlows | `https://github.com/commandglows/commandglows/blob/main/PITCH.md` | Windows-first professionals, independents, and productivity learners | Windows Mastery-led productivity and learning system across bilingual web, gated learning, and companion app surfaces | `shipglows_data/business/business.md`, `shipglows_data/business/product.md` | reviewed | Diane | 2026-09-02 | Refresh after the next positioning or offer review |
| CommunityGlows | `https://github.com/commandglows/communityglows/blob/main/PITCH.md` | Creators, operators, marketers, and small teams managing several social channels | Unified social workspace across browser, desktop, web, and mobile while preserving platform-specific behavior | `shipglows_data/business/business.md`, `shipglows_data/business/product.md` | reviewed | Diane | 2026-09-02 | Keep shipped and planned platform claims distinct |
| ContentGlows | `https://github.com/commandglows/contentglows/blob/main/PITCH.md` | Creators, founders, and lean content teams | One multi-surface product turning ideas and source assets into reviewable, publishable outputs | `shipglows_data/business/business.md`, `shipglows_data/product/` | reviewed | Diane | 2026-09-02 | Refresh when source intelligence or publishing authority changes |
| Dotfiles | `https://github.com/commandglows/dotfiles/blob/main/PITCH.md` | Diane and technical operators maintaining repeatable environments | Cross-platform terminal configuration and auditable machine bootstrap | `shipglows_data/business/business.md`, `shipglows_data/business/product.md` | reviewed | Diane | 2026-09-02 | Keep Dotfiles and ShipGlows provisioning boundaries explicit |
| DreamGlows | `https://github.com/dianedef/dreamglows/blob/main/PITCH.md` | People turning a dream or ambition into concrete progress | Dream-to-milestone-to-task guidance with Obsidian as the first active surface | `shipglows_data/business/business.md`, `shipglows_data/business/dreamglows-product.md` | reviewed | Diane | 2026-09-02 | Refresh as non-Obsidian surfaces gain verified behavior |
| Sources and Newsletter Studio for Flutter | `https://github.com/commandglows/email-sidebar-app/blob/main/PITCH.md` | Flutter products needing native source-reading and newsletter-composition UI | Provider-neutral presentation packages with typed host integration boundaries | `README.md`, `shipglows_data/business/business.md` | reviewed | Diane | 2026-09-02 | Keep real provider and delivery claims with consuming products |
| Winflowz | `https://github.com/diane-defores/winflowz/blob/main/PITCH.md` | Operators shipping a site plus an app from one repo | Monorepo for a governed Astro site and Flutter Android-first app with explicit deployment boundaries | `README.md`, `shipglows_data/business/business.md` | reviewed | unknown | 2026-06-27 | Replace with a richer pitch if positioning changes |
| Socialglowz | `https://github.com/diane-defores/socialglowz/blob/master/PITCH.md` | Users who need one social dashboard across browser, desktop, and mobile | Unified social control surface with platform-specific behavior kept explicit across targets | `README.md`, `shipglows_data/business/business.md` | reviewed | unknown | 2026-06-27 | Replace with a richer pitch if positioning changes |
| Temuglowz | `https://github.com/diane-defores/temuglowz/blob/main/PITCH.md` | Users saving Temu links into durable shopping lists | Local-first Android MVP for link capture, list management, and manual observation without fake automation claims | `README.md`, `BUSINESS.md` | reviewed | unknown | 2026-06-27 | Replace with a richer pitch if the product expands beyond MVP |
| ShipGlows App | `https://github.com/commandglows/shipglows_app/blob/main/PITCH.md` | Ambitious founders and small product teams directing governed work across projects | Managed SaaS making the open ShipGlows framework usable through a Cockpit, conversations, Studio, and managed runner | `shipglows_data/business/business.md`, `shipglows_data/business/product.md` | reviewed | Diane | 2026-09-02 | Refresh when hosted availability or Studio implementation truth changes |
| ShipGlows Audio Engine | `https://github.com/commandglows/shipglows-audio-engine/blob/main/PITCH.md` | ShipGlows products needing bounded native recording infrastructure | Private real-time C++ audio core exposed through a Flutter plugin contract | `README.md`, `shipglows_data/technical/code-docs-map.md` | reviewed | Diane | 2026-09-02 | Add business/product truth if it gains an independent offer |
| ShipGlows Private Data | `https://github.com/dianedef/shipglows-private/blob/main/PITCH.md` | The ShipGlows operator and authorized private workflows | Versioned recovery-worthy private operational state with explicit exclusions for secrets and customer data | `README.md` | reviewed | Diane | 2026-09-02 | Keep every new data family behind an explicit storage contract |
| ToolGlows | `https://github.com/dianedef/ToolGlows/blob/main/PITCH.md` | Browser-heavy professionals, independents, researchers, writers, and learners | Configurable in-page toolbar for recurring reading, capture, search, navigation, and focus actions | `shipglows_data/business/business.md`, `shipglows_data/business/product.md` | reviewed | Diane | 2026-09-02 | Keep stable utilities separate from experimental social modules |
| Notefinderz | `https://github.com/dianedef/notefinderz/blob/main/PITCH.md` | People comparing note-taking and knowledge-base tools | Astro SSR directory for note-native app comparison with authenticated filtering and editorial structure | `README.md`, `shipglows_data/business/business.md` | reviewed | unknown | 2026-06-27 | Replace with a richer pitch if the directory scope expands |
| Gocharbon | `https://github.com/dianedef/gocharbon/blob/main/PITCH.md` | Beginners who want accessible technical depth in a coaching-oriented editorial frame | Neobrutalist Astro theme plus business-education content with a friendly, clear tone | `README.md`, `PITCH.md` | reviewed | unknown | 2026-06-27 | Keep the pitch short and aligned with the parcours strategy |

## Entry Template

### [Project] - [Pitch Name]

- Pitch file URL:
- Audience:
- Business angle:
- Public-facing one-liner:
- Internal framing note:
- Source of truth:
- Status: `candidate | reviewed | stale | archived`
- Owner:
- Evidence date:
- Related artifacts:
- Next action:

## Maintenance Rule

Update this file when a project gets a new pitch file URL, a new public story, a new internal framing, or a material change in audience, offer, or positioning. For repos without a pitch file yet, add the first versioned `PITCH.md` or `pitch.md` in the project root or governed business folder, then replace the placeholder entry with that project’s GitHub URL. Keep the top-level ShipGlows row reserved for the index itself.
