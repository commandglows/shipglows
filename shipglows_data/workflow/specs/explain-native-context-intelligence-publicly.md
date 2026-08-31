---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-31"
created_at: "2026-08-31 22:52:00 UTC"
updated: "2026-08-31"
updated_at: "2026-08-31 22:52:00 UTC"
status: ready
source_skill: sg-content
source_model: gpt-5.6
scope: public-editorial
owner: Diane
user_story: "En tant que builder évaluant ShipGlows, je veux comprendre comment son intelligence de contexte sélectionne un contexte utile et vérifiable afin de juger sa valeur et ses limites sans croire à une compréhension magique du code."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - shipglows_data/workflow/specs/industrialize-native-context-intelligence.md
  - shipglows_data/editorial/claim-register.md
  - shipglows_data/editorial/content-map.md
  - site/src/content/articles/
  - site/src/pages/docs.astro
  - site/src/pages/fr/docs.astro
depends_on:
  - artifact: shipglows_data/workflow/specs/industrialize-native-context-intelligence.md
    artifact_version: "1.2.0"
    required_status: reviewed
  - artifact: shipglows_data/editorial/blog-and-article-surface-policy.md
    artifact_version: "1.2.0"
    required_status: reviewed
supersedes: []
evidence:
  - "PR #47 and merge commit 275b561801722659ef601b344d14846fb68c56da shipped the incremental graph, explainable capsule, lifecycle adoption and aggregate-only diagnostics."
  - "The ShipGlows baseline indexed 1,238 supported files, 4,288 nodes and 6,423 edges; representative owner recall was 3/3 with truncation visible."
next_step: "Draft, validate and prepare the paired EN/FR article and its declared public relays without deploying it."
---

# Explain Native Context Intelligence Publicly

## Status

Ready. The source implementation, evidence, claim boundary, audience, declared bilingual article surface and validation path are resolved.

## Minimal Behavior Contract

Publish one paired EN/FR long-form article explaining the context problem, ShipGlows's local incremental pipeline, its measurable evidence and its limits. Short homepage, README and docs relays may point to the article, but must not broaden its claims. If a claim lacks merged evidence or would expose internal source content, private paths, raw caches or telemetry, omit or qualify it visibly.

## Scope In

- One paired indexed article with shared identity and locale-native slugs.
- A governed `allowed with caveat` native-context claim.
- Short links from the homepage, public docs and README context overview.
- Build, locale, link, metadata and visual proof before publication readiness.

## Scope Out

- Deployment or publication authority.
- New graph behavior, parser coverage, embeddings, external services or performance promises.
- ContentGlows changes or current-state indexing.
- Raw graph, cache, task text, source bodies or telemetry publication.

## Invariants

- Git, code, specs and governed registers remain canonical.
- Derived context is local, bounded, replaceable and advisory.
- Every described selection has an explainability boundary; gaps and truncation remain visible.
- EN and FR peers preserve the same claim strength, evidence and caveats.

## Implementation Tasks

- [ ] Register the public claim and article surface.
- [ ] Draft the paired EN/FR article.
- [ ] Add bounded README, homepage and docs relays.
- [ ] Run metadata, content, locale, link, build and visual checks.
- [ ] Prepare exact-scope commits without deploying.

## Acceptance Criteria

- [ ] Both locale peers share one `articleKey`, map reciprocal slugs and have aligned publication state.
- [ ] The article explains task resolution, incremental freshness, ranking, capsule consumption, evidence states and continuity in audience language.
- [ ] Measurements are attributed to bounded pilots and never framed as universal performance.
- [ ] Limitations include unsupported relationships, advisory derived state and canonical-source precedence.
- [ ] No source body, secret, prompt, transcript, payload, private path, raw cache or raw telemetry is exposed.
- [ ] Declared relays link to the correct localized article.
- [ ] Site build and focused governance checks pass before publication readiness.

## Risks

- Overclaiming agent understanding: mitigated by capability wording, explicit limits and measured-scope attribution.
- Revealing internal implementation detail: mitigated by publishing architecture principles and aggregate counts only.
- Locale drift: mitigated by atomic peer edits and reciprocal metadata checks.
- Confusing prepared content with deployed content: mitigated by keeping deployment outside scope.

## Open Questions

None.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|---|---|---|---|---|---|
| 2026-08-31 22:52:00 UTC | sg-content | gpt-5.6 | Resolved the public article, claim and relay contract from the shipped context-intelligence evidence. | Ready without hidden product, surface or proof assumptions. | Draft and validate the paired article. |

## Current Chantier Flow

- `sg-spec`: done, contract created.
- `sg-ready`: done, readiness established.
- `sg-start`: active.
- `sg-verify`: not launched.
- `sg-end`: not launched.
- `sg-ship`: out of scope.

Next step: draft and validate the paired public article without deployment.
