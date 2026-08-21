---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-21"
updated: "2026-08-21"
status: ready
source_skill: sg-content
scope: public-git-persistence-positioning-and-article
owner: Diane
user_story: "As a solo founder evaluating ShipGlows, I want to understand how its Git and GitHub workflow protects, traces, and recovers agent work, so I can trust the delivery process without mistaking backup for deployment."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
content_surfaces: [repo_docs, public_site, faq_support, indexed_articles]
claim_register: shipglows_data/editorial/claim-register.md
page_intent: shipglows_data/editorial/page-intent-map.md
linked_systems:
  - README.md
  - shipglows_data/business/product.md
  - shipglows_data/business/gtm.md
  - shipglows_data/editorial/claim-register.md
  - /home/claude/shipglows_app/site/src/
depends_on:
  - artifact: skills/references/git-persistence-preflight.md
    artifact_version: "1.0.0"
    required_status: active
  - artifact: skills/references/git-milestone-delivery-contract.md
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-21: Git and GitHub integration is a high-impact public trust and positioning pillar."
  - "Operator-approved message: Each milestone backed up. Every delivery traceable."
next_step: /103-sg-verify public-git-persistence-positioning-and-article
---

# Public Git Persistence Positioning And Article

## Status

ready

## Audience And Reader Job

- Primary audience: solo founders and autonomous technical builders using agents on real product work.
- Reader job: determine whether ShipGlows merely edits files or protects work through interruption, recovery, and delivery.
- Desired belief: ShipGlows makes remote persistence and delivery state explicit without adding workflow ceremony when Git is healthy.

## Core Promise

**Each milestone backed up. Every delivery traceable.**

French: **Chaque jalon sauvegardé. Chaque livraison traçable.**

## Claim Impact Plan

- Claim: ShipGlows requires exact-scope commit and remote push at validated milestones and clean chantier completion, detects locally vulnerable work at lifecycle boundaries, and distinguishes local, remotely backed-up, and deployed states.
- Claim family: automation, AI reliability, availability.
- Affected surfaces: README, EN/FR landing, docs, FAQ, and indexed article pair.
- Evidence: Git milestone delivery, persistence preflight, project delivery policy, reporting contract, and focused contract tests.
- Status: allowed with caveat.
- Allowed wording: describe workflow requirements, agent checks, recovery signals, and evidence states.
- Required action: state that a push proves remote persistence rather than deployment; avoid guarantees of GitHub availability, zero loss, provider configuration, or unattended production shipping.
- Stop condition: do not merge public site claims before the underlying ShipGlows implementation is canonical on `main` and site preview evidence passes.

## Scope In

- Canonical product/GTM/claim truth and public repository README.
- One prominent EN/FR homepage proof point.
- One EN/FR docs explanation and FAQ answer.
- One indexed article in each locale with paired metadata and internal links.
- Draft PRs for ShipGlows and the isolated site branch.
- CI/preview observation after push; no local build or generated artifact.

## Scope Out

- No production merge, release, provider configuration, branch-protection mutation, or deployment claim.
- No quantified loss reduction, reliability, speed, savings, or uptime promise.
- No changes to unrelated ShipGlows dirty files or the site's existing `runner/` work.

## Article Direction

- EN: `Your agent changed the code. But is your work actually backed up?`
- FR: `Votre agent a modifié le code. Mais votre travail est-il vraiment sauvegardé ?`
- Structure: hidden local-only risk; coherent milestones; local/backed-up/deployed; interruption recovery; sensitive recovery points; honest limits; evaluation checklist.

## Acceptance Criteria

- The same evidence-safe promise appears consistently across EN/FR surfaces.
- Public copy leads with founder value and keeps Git mechanics as supporting proof.
- Article metadata follows the existing content schema and locale pairing conventions.
- Every claim maps to implemented contracts; caveats remain visible where trust could otherwise be overstated.
- Source and site changes are isolated, committed, pushed, and opened as linked draft PRs.
- Production publication remains gated on canonical implementation merge plus CI/preview proof.

## Implementation Tasks

- [ ] Align canonical product, GTM, claim register, README, and content record.
- [ ] Create isolated site branch/worktree and author EN/FR landing, docs, FAQ, and articles.
- [ ] Run focused schema, parity, link, claim, and secret checks without a local build.
- [ ] Push both milestones, open linked draft PRs, and record CI/preview state.

## Execution Batches

| Batch | Ownership | Write set | Dependency |
| --- | --- | --- | --- |
| A | Canonical public truth | ShipGlows business/editorial docs, README, spec | approved plan |
| B | Public site content | isolated shipglows_app worktree: EN/FR homepage, docs, FAQ, articles | batch A pushed |
| C | Publication readiness | spec evidence, linked draft PRs, CI/preview observation | batches A and B pushed |

## Current Chantier Flow

`sg-content ✅ -> spec/ready ✅ -> canonical truth -> site content -> content proof -> draft PRs -> publication pending`

## Skill Run History

| Date | Skill | Result | Evidence | Next step |
| --- | --- | --- | --- | --- |
| 2026-08-21 | sg-content | approved | Operator approved a publication-ready EN/FR positioning chantier with linked PRs and no automatic production merge. | canonical truth |
| 2026-08-21 | content planning | ready | Audience, promise, surfaces, evidence, caveats, article direction, batches, and publication stop are explicit. | batch A |
