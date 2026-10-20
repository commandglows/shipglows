---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-07-05"
updated: "2026-10-20"
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
  - skills/sg-release/SKILL.md
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
  - "Operator decision 2026-10-20: add store, desktop-package, long-running worker, and extension/plugin lanes; managed backend services stay outside the server matrix."
  - "Official docs re-checked 2026-10-20: Cloud Run service request timeout max 60 minutes, job task timeout max 168 hours (1 hour with GPUs), worker pools listed in Cloud Run quotas; Google Play requires new personal developer accounts to run a closed test with at least 12 opted-in testers for 14 continuous days before production; Tauri v2 ships MSI/NSIS installers and its Microsoft Store path links an offline, code-signed, self-updating installer."
  - "Managed project evidence 2026-10-20: ContentGlows runs its Remotion worker as a private Cloud Run service with GCS artifacts; managed Flutter surfaces (ContentGlows, ReplayGlows, CommandGlows, ShipGlows app, DreamGlows) target Android, Windows, and web; CommunityGlows ships a Tauri desktop app; DreamGlows ships Chrome and Obsidian extensions; most backends are Convex or a remote HTTP API."
next_review: "2027-02-20"
next_step: none
---

# Deploy Target Matrix

## Purpose

This reference defines ShipGlows's canonical deploy-target recommendation rule for every deployable surface a managed project ships: web surfaces, dedicated application servers, long-running workers, mobile apps, packaged desktop apps, and browser or editor extensions.

It answers one bounded question:

```text
Given the current project shape, which lane does each deployable surface belong to, what is that lane's default target, and what exception rule can override that choice?
```

This reference is advisory only. It does not auto-select a provider, does not replace project-specific architecture judgment, and does not imply that ShipGlows implements deep automation for every target it recommends.

## Core Rule

ShipGlows advises on deploy targets; it does not decide them in a vacuum.

Classify the deployable surface before consulting a provider ranking:

- `website or Vercel-compatible web application` -> recommend `Vercel` by default
- `dedicated server runtime` -> use the server-hosting matrix below
- `long-running or compute-heavy worker` -> use the worker lane
- `mobile app` (Flutter Android/iOS) -> use the store lane
- `packaged desktop app` (Tauri, Flutter Windows/macOS) -> use the desktop-package lane
- `browser extension or editor plugin` -> use the extension lane
- `managed backend service` (Convex, Supabase, Clerk, Auth0) -> the provider hosts it; it is not a dedicated server and never enters the server matrix

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

When a project has several surfaces, evaluate each one separately: keep the compatible web surface on Vercel by default, apply the server matrix only to a dedicated backend, and send workers, mobile, desktop, and extension surfaces to their own lanes. A Flutter web build of a mobile app is a web surface.

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

## Worker Lane

For a worker that renders, transcodes, or batches heavy work (for example the ContentGlows Remotion worker), the ShipGlows default is:

1. `Google Cloud Run`

Pick the Cloud Run shape from the work pattern:

- request-triggered work that finishes within 60 minutes -> private Cloud Run service invoked by the backend
- bounded batch work -> Cloud Run job (task timeout up to 7 days; 1 hour with GPUs)
- continuous pull-based consumer -> Cloud Run worker pool

Override the default when the worker must stay colocated with a dedicated backend (use the same server-matrix host as that backend), when a run exceeds Cloud Run limits, or when the operator already owns a server for it. Keep worker outputs in durable storage, never on the instance disk.

## Store Lane

Mobile apps ship through the platform stores, never through a web host:

- Android -> `Google Play` (internal testing, then closed testing, then production). A new personal developer account must run a closed test with at least 12 opted-in testers for 14 continuous days before applying for production; plan that delay before announcing a launch date.
- iOS -> `TestFlight` then `App Store`.

An APK sideload or local artifact is test distribution only, never a release target. Store submission, review, and read-back belong to `sg-release`.

## Desktop-Package Lane

Packaged desktop apps ship as code-signed installers with an update path:

1. `GitHub Releases` hosting the signed installer plus an auto-update feed (Tauri updater for MSI/NSIS)
2. `Microsoft Store` when store discovery or managed installs matter; for Tauri, the Store entry links an offline, code-signed, self-updating installer

An unsigned installer, a local build folder, or the ShipGlows local artifact cache is never a distribution channel. Release mechanics belong to `sg-release`.

## Extension Lane

Extensions ship through their ecosystem's catalog:

- Chrome extension -> `Chrome Web Store`
- Obsidian plugin -> a GitHub release plus the Obsidian community-plugin listing

Any backend the extension calls is a separate surface classified by the rules above.

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
- Workers, mobile apps, desktop packages, and extensions follow their own lanes and never default to Vercel or the server matrix.
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

Before writing or updating provider-specific promises, workflows, pricing claims, feature claims, or support claims outside research artifacts, apply the Documentation Freshness Gate and re-check current official docs. Store policies (Google Play testing rules, Apple review) and Cloud Run limits change most often; re-check them at every review.

## Manual Scenarios

Use these scenarios during verification:

- `DTM-001` ordinary website or compatible web app -> `Vercel`
- `DTM-002` dedicated FastAPI or equivalent server -> `Railway`
- `DTM-003` dedicated preview-heavy server workflow -> `Render`
- `DTM-004` dedicated server with advanced topology -> `Fly.io`
- `DTM-005` dedicated server with sovereignty/private-cloud needs -> `Codesphere`
- `DTM-006` Vercel frontend plus dedicated backend -> `Vercel` for the web surface and the server matrix for the backend
- `DTM-007` heavy rendering worker (Remotion) -> `Cloud Run` service or job, not the web lane
- `DTM-008` Flutter Android and iOS app -> `Google Play` and `App Store`; its Flutter web build -> `Vercel`
- `DTM-009` Tauri or Flutter Windows app -> signed installer on `GitHub Releases` with updates; `Microsoft Store` optional
- `DTM-010` Chrome extension with a Convex backend -> `Chrome Web Store`; Convex stays a managed backend outside the server matrix
