---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-21"
updated: "2026-08-21"
status: reviewed
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
next_step: Review and merge ShipGlows PR 24 before the dependent site PR 13; production publication remains a separate approval.
---

# Public Git Persistence Positioning And Article

## Status

reviewed

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

- [x] Align canonical product, GTM, claim register, README, and content record.
- [x] Create isolated site branch/worktree and author EN/FR landing, docs, FAQ, and articles.
- [x] Run focused schema, parity, link, claim, and secret checks without a local build.
- [x] Push both milestones, open linked draft PRs, and record CI/preview state.

## Execution Batches

| Batch | Ownership | Write set | Dependency |
| --- | --- | --- | --- |
| A | Canonical public truth | ShipGlows business/editorial docs, README, spec | approved plan |
| B | Public site content | isolated shipglows_app worktree: EN/FR homepage, docs, FAQ, articles | batch A pushed |
| C | Publication readiness | spec evidence, linked draft PRs, CI/preview observation | batches A and B pushed |

## Current Chantier Flow

`sg-content ✅ -> spec/reviewed ✅ -> canonical truth ✅ -> site content ✅ -> static content proof ✅ -> draft PRs ✅ -> source merge pending -> visual preview review pending -> publication pending`

## Delivery Evidence

- Canonical milestone: commit `d83d4f2` pushed to `codex/public-install-guidance`; draft ShipGlows PR [#24](https://github.com/commandglows/shipglows/pull/24).
- Public-site milestone: commit `3b0978b` pushed to `codex/git-persistence-positioning`; draft site PR [#13](https://github.com/commandglows/shipglows_app/pull/13).
- Vercel deployment and preview-comment checks: successful on site PR #13.
- Preview URL: `https://shipglows-site-git-codex-git-persisten-899813-diane-ds-projects.vercel.app`.
- Rendered-content proof: pending reviewer access because Vercel Deployment Protection serves its login surface to anonymous requests and the installed Vercel CLI is logged out. This does not invalidate the successful deployment check, but it prevents claiming visual preview verification.
- Local build and generated artifacts: intentionally not run, per operator constraint.

## Content Quality Evaluation

```json
{
  "schema_version": "1.0",
  "run_id": "public-git-persistence-positioning-2026-08-21",
  "project_id": "ShipGlows",
  "surface": "article",
  "evaluator": {
    "skill": "007-sg-content",
    "role": "producer",
    "initiated_by": "operator"
  },
  "scores": {
    "overall": 94,
    "clarity": 92,
    "structure": 94,
    "source_faithfulness": 96,
    "compliance": 97,
    "brand_voice": 91,
    "call_to_action": 88
  },
  "weights": {
    "clarity": 0.2,
    "structure": 0.15,
    "source_faithfulness": 0.2,
    "compliance": 0.2,
    "brand_voice": 0.15,
    "call_to_action": 0.1
  },
  "status": "publishable with caveats",
  "blocked_reasons": [],
  "evidence": [
    {
      "criterion": "claim honesty and source faithfulness",
      "source": "claim register, Git delivery contracts, and EN/FR public copy",
      "state": "pass"
    },
    {
      "criterion": "locale and metadata parity",
      "source": "paired EN/FR article frontmatter and internal-link checks",
      "state": "pass"
    },
    {
      "criterion": "rendered preview",
      "source": "Vercel-protected PR preview",
      "state": "warning"
    }
  ],
  "recommendations": [
    "Merge the canonical ShipGlows implementation before the dependent public-site change.",
    "Perform the final visual review through an authenticated Vercel preview before publication."
  ],
  "confidence": 0.95,
  "expires_at_utc": null
}
```

Fresh external documentation was not required: the copy describes internal implemented contracts and deliberately avoids current third-party capability promises.

## Skill Run History

| Date | Skill | Result | Evidence | Next step |
| --- | --- | --- | --- | --- |
| 2026-08-21 | sg-content | approved | Operator approved a publication-ready EN/FR positioning chantier with linked PRs and no automatic production merge. | canonical truth |
| 2026-08-21 | content planning | ready | Audience, promise, surfaces, evidence, caveats, article direction, batches, and publication stop are explicit. | batch A |
| 2026-08-21 | sg-content | reviewed | Canonical truth and bilingual public surfaces were committed and pushed; static checks passed; draft PRs #24 and #13 are linked by dependency. | merge source PR first |
| 2026-08-21 | CI/preview observation | publishable with caveats | Vercel checks passed; anonymous rendered verification is unavailable because Deployment Protection requires authentication. | authenticated visual review before publication |
