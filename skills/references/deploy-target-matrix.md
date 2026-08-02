---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-07-05"
updated: "2026-07-16"
status: active
source_skill: 102-sg-start
scope: deploy-target-matrix
owner: unknown
confidence: medium
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/004-sg-deploy/SKILL.md
  - skills/000-shipglows/SKILL.md
  - skills/references/entrypoint-routing.md
  - README.md
  - shipglows_data/workflow/playbooks/spec-driven-workflow.md
  - shipglows_data/workflow/research/codesphere-fit-for-shipglows-workflows.md
  - shipglows_data/workflow/research/codesphere-vs-railway-vs-render-vs-flyio-for-shipglows.md
depends_on:
  - artifact: "shipglows_data/business/business.md"
    artifact_version: "1.2.0"
    required_status: reviewed
  - artifact: "shipglows_data/business/product.md"
    artifact_version: "1.2.0"
    required_status: reviewed
  - artifact: "shipglows_data/business/gtm.md"
    artifact_version: "1.2.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Research verdict 2026-07-04: Codesphere is a specialized deploy/runtime target, not a replacement for ShipGlows governance."
  - "Market study verdict 2026-07-04: Railway should be the default recommendation, Render the strongest preview-heavy alternative, Fly.io the advanced-control target, and Codesphere the sovereignty/private-cloud target."
  - "Operator clarification 2026-07-05: the matrix belongs in ShipGlows references; ShipGlows can advise only, and final target choice remains project-contextual."
  - "Operator correction 2026-07-16: Vercel is the ShipGlows default for websites and compatible web applications; the server-hosting matrix applies only when a dedicated server runtime is actually required."
next_review: "2026-08-05"
next_step: "/104-sg-end deploy target matrix reference correction"
---

# Deploy Target Matrix

## Purpose

This reference defines ShipGlows's canonical deploy-target recommendation rule for web surfaces and dedicated application servers.

It answers one bounded question:

```text
Given the current project shape, should ShipGlows use its Vercel web default or enter the dedicated-server matrix, and what exception rule can override that choice?
```

This reference is advisory only. It does not auto-select a provider, does not replace project-specific architecture judgment, and does not imply that ShipGlows implements deep automation for every target it recommends.

## Core Rule

ShipGlows advises on deploy targets; it does not decide them in a vacuum.

Classify the deployable surface before consulting a provider ranking:

- `website or Vercel-compatible web application` -> recommend `Vercel` by default
- `dedicated server runtime` -> use the server-hosting matrix below

Do not send an ordinary website or compatible full-stack web application into the server-hosting matrix merely because it uses a database, authentication, webhooks, server functions, or third-party APIs. Enter the server lane only when the architecture genuinely requires a separately hosted long-running server or backend, such as FastAPI, a persistent worker, a custom multi-service runtime, or infrastructure constraints incompatible with the Vercel web lane.

Use this matrix when:

- the operator asks where to deploy an app
- `004-sg-deploy` needs a target recommendation lane
- `000-shipglows` or a docs surface needs a canonical answer
- public or operator-facing guidance would otherwise drift into ad hoc platform opinion

If a large project-context delta exists, the final answer must say so explicitly rather than pretending the matrix alone decides.

## Web Default

For websites and Vercel-compatible web applications, the ShipGlows default is:

1. `Vercel`

This includes ordinary marketing sites, content sites, storefronts, dashboards, and compatible serverless/full-stack web applications. A project-specific incompatibility, explicit operator choice, sovereignty requirement, or dedicated-server need can override the default.

When a project has both a web frontend and a dedicated backend, evaluate them separately: keep the compatible web surface on Vercel by default and apply the server matrix only to the dedicated backend.

## Dedicated-Server Ranking

When a project genuinely requires a dedicated application server:

1. `Railway`
2. `Render`
3. `Fly.io`
4. `Codesphere`

This server ranking assumes ShipGlows's primary audience:

- solo founders first
- small technical teams second
- need for fast deployment, low ambiguity, reasonable observability, and multi-service support

## Exception Lanes

Within the dedicated-server lane, override the server default when one of these needs dominates:

- `preview-heavy review workflow` -> prefer `Render`
- `advanced infra / topology / networking control` -> prefer `Fly.io`
- `sovereignty / private cloud / institutional hosting posture` -> prefer `Codesphere`
- `simple dedicated-server deployment with low ceremony` -> keep `Railway`

If two lanes conflict materially, the owner skill should either:

- recommend the lane that best preserves the project outcome, or
- ask one concise routing question when the answer changes platform choice materially

## Platform Summaries

### Railway

Recommend first within the dedicated-server lane when the project needs:

- fastest path from repo to running app
- low-ceremony multi-service deployment
- strong founder/operator DX
- a good default for ShipGlows's primary audience

Do not use Railway as the default for an ordinary website or Vercel-compatible web application. Within the server lane, avoid treating Railway as universal when sovereignty, unusual infra topology, or heavy review-environment requirements dominate.

### Render

Recommend first when the project needs:

- strong preview/review environments
- conventional managed full-stack hosting
- clearer review workflows than a lighter founder-default path

Avoid presenting Render as the cheapest or most flexible answer by default; the main reason to prefer it is review/deploy workflow fit.

### Fly.io

Recommend first when the project needs:

- deeper control over runtime shape
- networking or topology sensitivity
- more infra-explicit operation

Avoid recommending Fly.io as the default for casual founder projects; it usually asks for more operator fluency.

### Codesphere

Recommend first when the project needs:

- sovereignty or private-cloud posture
- self-hostable or institutionally constrained infrastructure
- a heavier standardized platform model across dev/deploy/ops

Avoid recommending Codesphere only because its platform story sounds stronger. For many smaller projects it is more platform than they need.

## Advice Boundary

Every owner surface that uses this matrix must preserve these statements:

- Vercel is the default for websites and compatible web applications.
- Railway, Render, Fly.io, and Codesphere form a dedicated-server matrix, not a replacement web-hosting default.
- ShipGlows is recommending a substrate, not choosing the project's final architecture.
- The final target still depends on project-specific context.
- Recommendation coverage is wider than automation coverage.
- Public claims must stay narrower than actual provider-specific support in ShipGlows.

## Routing Guidance

- Generic deploy-target advice -> `004-sg-deploy`
- Generic "where should I deploy this?" in `000-shipglows` -> route to `004-sg-deploy` with this reference loaded
- Pure explanation with no file work -> direct answer may cite this matrix, but should still keep the advice boundary explicit

## Documentation Rule

When docs, skills, or public surfaces mention deploy-target recommendations:

- reference this file as the canonical source
- do not duplicate the full ranking logic unless the downstream contract truly requires a local summary
- keep local summaries short and consistent

## Freshness Rule

This matrix depends on external platform behavior that can change.

Before writing or updating provider-specific promises, workflows, pricing claims, feature claims, or support claims outside research artifacts, apply the Documentation Freshness Gate and re-check current official docs.

## Manual Scenarios

Use these scenarios during verification:

- `DTM-001` ordinary website or compatible web app -> `Vercel`
- `DTM-002` dedicated FastAPI or equivalent server -> `Railway`
- `DTM-003` dedicated preview-heavy server workflow -> `Render`
- `DTM-004` dedicated server with advanced topology -> `Fly.io`
- `DTM-005` dedicated server with sovereignty/private-cloud needs -> `Codesphere`
- `DTM-006` Vercel frontend plus dedicated backend -> `Vercel` for the web surface and the server matrix for the backend
