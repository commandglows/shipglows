---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-05-24"
updated: "2026-05-24"
status: draft
source_skill: sg-docs
scope: external-platform-convex
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/documentation-freshness-gate.md
  - skills/109-sg-auth-debug/references/convex-clerk.md
  - skills/109-sg-auth-debug/references/convex-tooling.md
  - templates/project_platform_usage.md
depends_on:
  - artifact: "shipglows_data/technical/external-platforms/README.md"
    artifact_version: "0.1.0"
    required_status: "draft"
supersedes: []
evidence:
  - "Fresh external docs checked on 2026-05-24 against Convex production, project configuration, deployment, auth, Clerk, indexes, scheduled functions, and local deployment docs."
next_review: "2026-06-24"
next_step: "/sg-docs technical audit"
---

# Convex Platform Note

## Purpose

This note is the global ShipGlows/Chiclou cheat sheet for Convex-related freshness checks. Use it before relying on assumptions about Convex deployments, generated APIs, auth propagation, Clerk integration, schema/index changes, scheduled functions, preview/staging environments, local deployments, or production deploy keys.

It does not replace Convex documentation. It records the source map and ShipGlows rules agents should use before changing Convex code, deployment configuration, auth logic, or project-local Convex usage docs.

## Source Map

Primary sources for Freshness Gate:

| Need | Source |
| --- | --- |
| Production deployment model | https://docs.convex.dev/production |
| Project configuration and CI deploy keys | https://docs.convex.dev/production/project-configuration |
| Multiple and preview deployments | https://docs.convex.dev/production/multiple-deployments |
| Deployment dashboard model | https://docs.convex.dev/dashboard/deployments/ |
| React client and generated API usage | https://docs.convex.dev/client/react/ |
| Authentication overview | https://docs.convex.dev/auth |
| Convex with Clerk | https://docs.convex.dev/auth/clerk |
| Database model | https://docs.convex.dev/database |
| Indexes | https://docs.convex.dev/database/reading-data/indexes/ |
| Scheduled functions | https://docs.convex.dev/scheduling/scheduled-functions |
| Local deployments | https://docs.convex.dev/cli/local-deployments |

Freshness evidence on 2026-05-24:

- Convex production docs describe one shared production deployment, personal development deployments, and preview deployments for testing before production.
- Project configuration docs describe `CONVEX_DEPLOYMENT`, client deployment URL variables, `npx convex deploy`, and `CONVEX_DEPLOY_KEY` for CI.
- Convex Clerk docs require backend auth configuration via `auth.config.ts`/`auth.config.js`, syncing with `npx convex dev` or `npx convex deploy`, and using `useConvexAuth()` when the app needs Convex-authenticated state.
- Convex scheduled functions docs state that auth is not propagated to scheduled functions; required user information must be passed explicitly.
- Local deployments are development-only unless explicitly self-hosting production via the open source backend; local deployment responses/logs can expose development detail.

## Freshness Gate Use

Use `fresh-docs checked` for Convex decisions only after checking the relevant Convex docs and local project deployment/config evidence.

Use `fresh-docs gap` when:

- Convex code or generated API is changed but local `convex/_generated/*`, schema, or deployment target was not inspected.
- Auth behavior depends on Clerk or another provider but `auth.config.*`, provider issuer, and deployment sync were not checked.
- Scheduled functions or actions have side effects but retry/idempotency behavior was not reviewed.
- A project uses Convex but lacks `shipglows_data/technical/platforms/convex.md`.

Use `fresh-docs conflict` when current Convex docs contradict local docs, deployment assumptions, or a planned implementation.

## ShipGlows Decision Rules

- Treat Convex deployment identity as part of product truth. Know whether the code targets local, personal dev, preview, staging, or production before debugging or verifying.
- Do not treat frontend auth state alone as proof of Convex backend auth. Use Convex-specific auth state and verify backend provider configuration.
- After changing `convex/auth.config.*`, require `npx convex dev` or `npx convex deploy` before trusting auth retests.
- Mutations that affect money, credits, destructive actions, quotas, or external side effects must be idempotent or explicitly protected against duplicate submission.
- Actions may perform external side effects and are not automatically retried like internal Convex retries. Use explicit retry/state patterns when reliability matters.
- Scheduled function auth is not implicitly inherited. Pass durable user/account identifiers and re-check authorization where relevant.
- Schema and index changes must consider existing production data. Do not force schema changes without migration/backfill strategy.
- Prefer indexed queries for growing tables; avoid broad scans hidden behind reactive queries.

## Common Project-Local Fields

A project using Convex should maintain `<governance-root>/shipglows_data/technical/platforms/convex.md` with:

- project and deployment names, excluding secrets
- local/dev/preview/prod deployment strategy
- client deployment URL env var names
- deploy key secret name only, never value
- auth provider and issuer-domain strategy
- schema/index invariants and migration notes
- scheduled function, cron, action, and webhook side effects
- validation commands and dashboard/MCP/CLI evidence route

Use `templates/project_platform_usage.md` as the starter structure.

## Security Notes

- Never store `CONVEX_DEPLOY_KEY`, dashboard tokens, auth issuer secrets, webhook secrets, or raw production documents in ShipGlows docs.
- Treat Convex actions and HTTP endpoints as trust-boundary code.
- Treat generated API files as build artifacts derived from Convex functions; do not hand-edit them.
- For auth failures, avoid logging JWTs or full identity payloads. Record redacted issuer, subject category, and deployment target only.

## Validation

```bash
python3 tools/shipglows_metadata_lint.py shipglows_data/technical/external-platforms/convex.md
rg -n "Freshness Gate|Source Map|ShipGlows Decision Rules|Maintenance Rule" shipglows_data/technical/external-platforms/convex.md
```

## Reader Checklist

- `convex/`, `CONVEX_DEPLOYMENT`, `ConvexReactClient`, `useQuery`, `useMutation`, or generated API usage found -> check for project-local Convex usage note.
- Clerk + Convex auth issue -> check both Convex and Clerk global notes, then project-local usage notes.
- Scheduled functions/actions changed -> verify auth, retries, idempotency, and side effects.
- Schema/index changed -> verify migration/backfill and query performance implications.

## Maintenance Rule

Update this note when Convex deployment, auth, generated API, schema/index, scheduled function, action, preview deployment, local deployment, or CI deploy-key behavior changes.
