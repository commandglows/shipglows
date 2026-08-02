---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-05-24"
updated: "2026-05-24"
status: draft
source_skill: sg-docs
scope: external-platform-clerk
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/documentation-freshness-gate.md
  - skills/109-sg-auth-debug/SKILL.md
  - skills/109-sg-auth-debug/references/clerk.md
  - skills/109-sg-auth-debug/references/convex-clerk.md
  - templates/project_platform_usage.md
depends_on:
  - artifact: "shipglows_data/technical/external-platforms/README.md"
    artifact_version: "0.1.0"
    required_status: "draft"
supersedes: []
evidence:
  - "Fresh external docs checked on 2026-05-24 against Clerk React hooks, Next.js middleware, webhooks, JWT templates, and Convex integration docs."
next_review: "2026-06-24"
next_step: "/sg-docs technical audit"
---

# Clerk Platform Note

## Purpose

This note is the global ShipGlows/Chiclou cheat sheet for Clerk-related freshness checks. Use it before relying on assumptions about Clerk SDKs, hooks, middleware, JWT templates, webhooks, Convex integration, session state, organizations, reverification, or hosted auth callbacks.

It does not replace Clerk documentation. It records the source map and ShipGlows rules agents should use before changing auth code, protected routes, webhook handlers, project-local auth docs, or Convex/Clerk integration.

## Source Map

Primary sources for Freshness Gate:

| Need | Source |
| --- | --- |
| React SDK overview | https://clerk.com/docs/references/react/overview |
| React hooks reference | https://clerk.com/docs/react/reference/hooks/overview |
| `useUser()` reference | https://clerk.com/docs/reference/clerk-react/useuser |
| Next.js middleware | https://clerk.com/docs/reference/nextjs/clerk-middleware |
| Webhooks overview | https://clerk.com/docs/guides/development/webhooks/overview |
| Sync Clerk data with backend | https://clerk.com/docs/users/sync-data-to-your-backend |
| JWT templates | https://clerk.com/docs/backend-requests/making/jwt-templates |
| Convex integration | https://clerk.com/docs/integrations/databases/convex |
| Reverification for sensitive actions | https://clerk.com/docs/react/hooks/use-reverification |

Freshness evidence on 2026-05-24:

- Clerk React docs list hooks such as `useUser`, `useAuth`, `useClerk`, session hooks, organization hooks, reverification, and billing-related hooks.
- Next.js `clerkMiddleware()` docs describe route protection, matcher configuration, debug mode, authorized parties, dynamic keys, and `CLERK_ENCRYPTION_KEY` requirements for dynamic secret keys.
- Clerk webhooks use Svix and require a webhook signing secret from the Clerk Dashboard.
- Clerk JWT template docs describe template name, token lifetime, allowed clock skew, claims, and token generation via `getToken()`.
- Clerk Convex integration docs describe creating a Convex JWT template and configuring the Convex backend with Clerk's issuer domain.

## Freshness Gate Use

Use `fresh-docs checked` for Clerk decisions only after checking the relevant Clerk SDK/framework docs and local project auth configuration.

Use `fresh-docs gap` when:

- Auth behavior affects protected routes, callbacks, cookies, sessions, organizations, webhooks, or Convex auth but current Clerk docs and local env/config were not checked.
- Code depends on a Clerk SDK version but the local package version and matching docs were not identified.
- Webhook handlers are changed without verifying Svix signature validation and event coverage.
- A project uses Clerk but lacks `shipglows_data/technical/platforms/clerk.md`.

Use `fresh-docs conflict` when current Clerk docs contradict local docs, route assumptions, or a planned implementation.

## ShipGlows Decision Rules

- Auth is a security boundary, not UI state. Protected data and privileged actions need server/backend authorization, not only signed-in UI components.
- For Next.js, verify `clerkMiddleware()` matcher coverage before claiming protected routes are protected.
- For hosted auth, OAuth, cookies, callbacks, or deployed env behavior, local proof is not enough when the project's validation surface is preview/prod.
- Webhooks must verify Clerk/Svix signatures before mutating local data.
- Do not treat Clerk user profile data as application authorization by default. Map roles, org membership, subscriptions, or app permissions explicitly.
- For Convex integration, check both Clerk JWT template/issuer configuration and Convex `auth.config.*` sync.
- Use reverification or equivalent extra confirmation for sensitive actions such as billing, account deletion, credential changes, admin operations, or destructive flows.

## Common Project-Local Fields

A project using Clerk should maintain `<governance-root>/shipglows_data/technical/platforms/clerk.md` with:

- Clerk SDK/framework and package versions
- publishable-key env var names and secret-key env var names, never values
- sign-in, sign-up, callback, OAuth, and allowed redirect/domain policy
- protected route/middleware strategy
- webhook endpoint list and event types
- JWT templates and downstream consumers
- Convex/Supabase/Firebase/backend integration notes
- validation surface and browser/auth proof route

Use `templates/project_platform_usage.md` as the starter structure.

## Security Notes

- Never store Clerk secret keys, webhook signing secrets, session tokens, JWTs, cookies, auth codes, raw webhook bodies with PII, or dashboard tokens in ShipGlows docs.
- Treat publishable keys as non-secret but still project-identifying; document only when useful.
- Redact user IDs and emails unless the exact value is necessary and safe.
- Do not enable middleware debug logs in production without a narrow reason.

## Validation

```bash
python3 tools/shipglows_metadata_lint.py shipglows_data/technical/external-platforms/clerk.md
rg -n "Freshness Gate|Source Map|ShipGlows Decision Rules|Maintenance Rule" shipglows_data/technical/external-platforms/clerk.md
```

## Reader Checklist

- `@clerk/`, `ClerkProvider`, `useUser`, `useAuth`, `clerkMiddleware`, Clerk env vars, or Clerk webhook code found -> check for project-local Clerk usage note.
- Clerk + Convex found -> read both provider notes and project usage notes.
- Protected route or webhook changed -> verify server-side protection/signature validation.
- OAuth/callback failure -> require hosted proof when the project depends on deployed domains or provider dashboard settings.

## Maintenance Rule

Update this note when Clerk SDK, middleware, webhook, JWT template, organization, reverification, billing, or Convex integration behavior changes.
