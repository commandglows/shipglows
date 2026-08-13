---
artifact: competitive_intelligence
metadata_schema_version: "1.0"
artifact_version: "1.0.2"
project: "ShipGlows"
created: "2026-05-11"
updated: "2026-08-13"
status: reviewed
source_skill: 205-sg-veille
scope: "project-competitors-and-inspirations"
owner: "unknown"
confidence: high
risk_level: medium
target_projects: "ShipGlows and project-local ShipGlows governance corpora"
reference_categories: "direct competitor, indirect competitor, alternative, inspiration, anti-pattern"
source_policy: "Record public URLs, capture dates, and explicit use; do not copy proprietary material or treat inspiration as permission to clone."
security_impact: none
docs_impact: yes
evidence:
  - "User requested a formal file for competitors and inspirations by project."
  - "Web triage on 2026-07-26 identified prior art for approved visual baselines, agent-readable visual history, visual regression, and product roadmaps."
  - "Operator supplied Warp agent notifications as a ShipGlows inspiration on 2026-08-07."
  - "Operator flagged https://grabltd.com/products/agentica as a probable competitor and requested tracking on 2026-08-09."
  - "Checked Agentica official landing site https://astarlabshub.com/ and verified core product claims on 2026-08-09."
  - "ShipGlows positioning decision SG-BIZ-2026-08-13-01 changes the comparison axis from infrastructure lifecycle control to business-aware outcome ownership."
depends_on:
  - artifact: "shipglows_data/business/business.md"
    artifact_version: "1.3.0"
    required_status: reviewed
  - artifact: "shipglows_data/business/product.md"
    artifact_version: "1.3.0"
    required_status: reviewed
  - artifact: "shipglows_data/business/gtm.md"
    artifact_version: "1.3.0"
    required_status: reviewed
supersedes: []
next_review: "2026-09-13"
next_step: "/009-sg-marketing market update project competitors"
---

# Project Competitors And Inspirations

## Purpose

Ce registre conserve, par projet, les concurrents, alternatives et inspirations qui influencent le positionnement, le produit, le design, le contenu ou la distribution.

Il sert a eviter que ces references restent seulement dans une conversation. Une entree doit expliquer pourquoi la reference compte et comment elle peut etre utilisee sans creer de confusion, de copie non maitrisee ou de claim non prouve.

## When To Use

- Etude de marche, positionnement, pricing, landing page, FAQ ou copywriting.
- Inspiration produit, UX, design system, onboarding, documentation ou workflow.
- Analyse de differenciation avant une nouvelle feature ou un pivot de promesse.
- Verification qu'une idee vient d'une reference publique, d'une hypothese ou d'une decision interne.

## Source Rules

- Garder une URL publique et une date de consultation quand c'est possible.
- Classer la reference explicitement : `direct competitor`, `indirect competitor`, `alternative`, `inspiration`, `anti-pattern`.
- Distinguer ce qui est observe de ce qui est infere.
- Ne pas recopier de contenu proprietaire. Resumer l'insight utile et pointer vers la source.
- Ne pas transformer une inspiration en promesse publique sans preuve produit ou GTM.
- Archiver les references obsoletes au lieu de les supprimer si elles expliquent une ancienne decision.

## Status Values

- `candidate`: reference reperee mais non analysee.
- `watch`: reference a surveiller pour marche, pricing, messaging ou produit.
- `reference`: reference validee comme utile pour decisions ou audits.
- `rejected`: reference jugee hors-scope ou trompeuse.
- `archived`: reference conservee pour historique, mais non active.

## Project Registry

| Project | Category | Name | URL | Why it matters | Used for | Differentiation note | Evidence date | Owner | Status | Next action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ShipGlows | inspiration | Vizzly | https://vizzly.dev/ | Approved visual baselines, review decisions, and agent context around UI changes. | Design protection, visual history, agent workflow | Keep our own multidimensional approval model; do not outsource product truth to a visual-testing vendor. | 2026-07-26 | Diane | reference | Formalize protected-surface contract |
| ShipGlows | indirect competitor | Chromatic | https://www.chromatic.com/ | Story-level visual baselines with accept/deny review and branch/commit lineage. | Visual QA and baseline review | Their unit is the Storybook story; ours must be a product section with copy/design/structure/behavior permissions. | 2026-07-26 | Diane | reference | Compare baseline evidence formats |
| ShipGlows | alternative | Playwright visual comparisons | https://playwright.dev/docs/test-snapshots | Git-versioned screenshots and snapshot updates for deterministic visual regression tests. | Technical regression safety net | Screenshots alone cannot express “this copy may change but this layout may not.” | 2026-07-26 | Diane | reference | Use as optional proof layer |
| ShipGlows | indirect competitor | Applitools Eyes | https://applitools.com/platform/eyes/ | Visual AI comparison, baseline acceptance/rejection, and dynamic-region handling. | Tolerant visual comparison | Avoid opaque visual scoring; keep human approval and explicit protected dimensions. | 2026-07-26 | Diane | watch | Revisit if screenshot noise becomes costly |
| ShipGlows | alternative | vregt | https://docs.vregt.com/getting-started/overview/ | Framework-agnostic screenshot baselines with dashboard/API approval. | Cross-framework visual evidence | Do not let a dashboard become a second source of truth beside our cartography. | 2026-07-26 | Diane | watch | Monitor workflow ergonomics |
| ShipGlows | alternative | Lost Pixel | https://github.com/lost-pixel/lost-pixel | Open-source visual regression for Storybook, pages, and custom screenshots with approvals. | Self-hosted visual regression inspiration | Reuse the idea of approvals, not their scope or naming model. | 2026-07-26 | Diane | watch | Assess reusable open-source patterns |
| ShipGlows | inspiration | Atlassian User Story Maps / Roadmaps | https://www.atlassian.com/blog/2016/05/guide-to-agile-user-story-maps | A map organizes user activities, capabilities, and roadmap slices. | Product cartography and roadmap | Our map must link each surface to approval dimensions and a known-good commit. | 2026-07-26 | Diane | reference | Model the two-view cartography |
| ShipGlows | inspiration | Productboard hierarchy | https://support.productboard.com/hc/en-us/articles/360058212253-Build-your-product-hierarchy | Hierarchical product structure linking products, features, and roadmap context. | Capability inventory and roadmap | Keep the map repository-local and agent-readable instead of adopting a SaaS hierarchy as authority. | 2026-07-26 | Diane | reference | Define stable section IDs |
| ShipGlows | inspiration | Warp agent notifications | https://docs.warp.dev/agents/capabilities/agent-notifications/ | Alerts when an agent completes work or needs operator attention, so long-running work can stay in the background. | Operator attention and asynchronous agent supervision | Candidate pattern only: preserve ShipGlows' explicit outcome, urgency, and actionable-next-step semantics instead of copying notification behavior. | 2026-08-07 | Diane | candidate | Verify current notification states and assess fit with ShipGlows' existing attention model |
| ShipGlows | direct competitor | Agentica | https://astarlabshub.com/ | Official landing: AI platform for founder workflows (6 specialized AI agents, startup operating system, full-stack app + landing-page generation, React/FastAPI output, live terminal-style logs, GitHub deploy, Railway/Vercel) with free-to-try onboarding. Listed as a lifetime deal on https://grabltd.com/products/agentica. | Positioning, product workflow scope, onboarding, pricing model validation | Differentiate through governed business truth, useful operator choices, public métier ownership, canonical context refresh, and verified outcomes rather than autonomous startup orchestration alone. | 2026-08-09 | Operator | candidate | Compare business-aware outcome ownership against autonomous startup orchestration; validate pricing tiers after plan-page details update. |

## Entry Template

### [Project] - [Reference Name]

- Category: `direct competitor | indirect competitor | alternative | inspiration | anti-pattern`
- URL:
- Evidence date:
- Owner:
- Status: `candidate | watch | reference | rejected | archived`
- Summary:
- What to learn:
- What not to copy:
- Differentiation note:
- Related artifacts:
- Next action:

## Maintenance Rule

Update this file when a competitor, alternative, inspiration source, or anti-pattern materially influences product scope, positioning, copy, pricing, onboarding, documentation, or visual direction.

## Prior-Art Synthesis: Approved Surfaces

La veille du 2026-07-26 conclut qu’aucune des références consultées ne réunit dans un même contrat : cartographie produit, roadmap, validation humaine, ancrage sur commit et permissions indépendantes pour copywriting, design, structure et fonctionnalité.

### Ce que ShipGlows peut reprendre

- Une baseline visuelle approuvée par surface, avec diff lisible et historique par commit.
- Une décision humaine explicite (`approved`, `rejected`, commentaire) avant de considérer une évolution comme acceptable.
- Un contexte consultable par l’agent avant modification, afin qu’il découvre les surfaces protégées et leurs limites.
- Une cartographie hiérarchique des sections et capacités qui sert aussi de roadmap.

### Ce que ShipGlows doit faire différemment

- La vérité produit reste notre cartographie versionnée, pas un outil de tests ou une plateforme SaaS.
- Chaque section possède des dimensions indépendantes : `copywriting`, `design`, `structure`, `fonctionnalité`.
- Chaque dimension peut être `fluide`, `stable` ou `protégée`, avec un commit de référence quand elle est protégée.
- Une modification autorisée sur une dimension ne vaut pas permission de toucher aux autres.
- Le retour à un commit de référence est un mécanisme de récupération ; la prévention principale reste le contrôle de portée avant édition.

### Sources de veille détaillées

Voir le rapport cité et vérifié : [`approved-surface-protection-prior-art-2026-07-26.md`](../workflow/research/approved-surface-protection-prior-art-2026-07-26.md).


Synexis Core is an AI business health platform that helps companies monitor website performance, SEO, security, accessibility, revenue signals, inventory, leads, ads, and operational risks in one dashboard. It runs continuous scans, detects issues and anomalies, scores business impact, and helps teams prioritize fixes. Synexis Core also includes AI modules for financial intelligence, fraud monitoring, workforce insights, compliance readiness, vendor intelligence, opportunity detection, reputation tracking, sales forecasting, and more.
https://synexiscore.com/?ref=betalist
