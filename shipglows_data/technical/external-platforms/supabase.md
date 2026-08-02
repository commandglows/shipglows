---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-05-24"
updated: "2026-05-24"
status: draft
source_skill: sg-docs
scope: external-platform-supabase
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/documentation-freshness-gate.md
  - skills/references/supabase-auth.md
  - skills/references/supabase-db.md
  - skills/references/supabase-storage.md
  - templates/project_platform_usage.md
depends_on:
  - artifact: "shipglows_data/technical/external-platforms/README.md"
    artifact_version: "0.1.0"
    required_status: "draft"
supersedes: []
evidence:
  - "Fresh external docs checked on 2026-05-24 against Supabase docs, secure data, RLS, SSR auth, Storage access control, CLI, and database advisors docs."
next_review: "2026-06-24"
next_step: "/sg-docs technical audit"
---

# Supabase Platform Note

## Purpose

This note is the global ShipGlows/Chiclou cheat sheet for Supabase-related freshness checks. Use it before relying on assumptions about Supabase Auth, Postgres/RLS, Storage policies, Edge Functions, SSR sessions, API keys, CLI behavior, migrations, generated types, or database advisors.

It does not replace Supabase documentation. It records the source map and ShipGlows rules agents should use before changing Supabase code, policies, migrations, storage, auth, or project-local Supabase usage docs.

## Source Map

Primary sources for Freshness Gate:

| Need | Source |
| --- | --- |
| Supabase docs entrypoint | https://supabase.com/docs |
| Securing your data | https://supabase.com/docs/guides/database/secure-data/ |
| Row Level Security | https://supabase.com/docs/guides/database/postgres/row-level-security |
| SSR auth overview | https://supabase.com/docs/guides/auth/server-side |
| Next.js SSR client setup | https://supabase.com/docs/guides/auth/server-side/nextjs |
| Advanced SSR guide | https://supabase.com/docs/guides/auth/server-side-rendering |
| Storage overview | https://supabase.com/docs/guides/storage |
| Storage access control | https://supabase.com/docs/guides/storage/security/access-control |
| Supabase CLI | https://supabase.com/docs/guides/cli/getting-started |
| CLI reference | https://supabase.com/docs/reference/cli/supabase-encryption |
| Database advisors | https://supabase.com/docs/guides/database/database-advisors |

Freshness evidence on 2026-05-24:

- Supabase secure-data docs distinguish frontend Data API access, Edge Functions, and direct database connections, with different security models.
- Supabase docs state publishable/anon keys are safe to expose only when paired with RLS and least-privilege grants; secret/service-role keys are never safe on the frontend.
- RLS docs state RLS should always be enabled on tables in exposed schemas and that service keys can bypass RLS.
- SSR auth docs recommend cookie-based sessions for SSR and note that `@supabase/ssr` is beta and may have breaking changes.
- Next.js SSR docs warn about cached responses with `Set-Cookie` causing session leakage if not handled correctly.
- Storage access control docs state Supabase Storage works with Postgres RLS policies on `storage.objects`.
- CLI docs state global CLI usage should use Homebrew, Scoop, or the standalone binary, while npx/npm usage requires Node.js 20+.

## Freshness Gate Use

Use `fresh-docs checked` for Supabase decisions only after checking the relevant Supabase docs and local project schema/policies/auth/storage evidence.

Use `fresh-docs gap` when:

- A table in an exposed schema is accessed from frontend/client code and RLS/policies were not checked.
- Secret/service-role keys, direct DB URLs, or Edge Function secrets are used without documenting backend-only boundaries.
- SSR auth is changed without reviewing cookie handling, token refresh, and caching behavior.
- Storage upload/download behavior changes without checking `storage.objects` policies and bucket visibility.
- A project uses Supabase but lacks `shipglows_data/technical/platforms/supabase.md`.

Use `fresh-docs conflict` when current Supabase docs contradict local docs, key assumptions, RLS assumptions, or a planned implementation.

## ShipGlows Decision Rules

- Treat RLS as mandatory for client-accessible tables in exposed schemas. Do not ship frontend database access without explicit RLS evidence.
- Secret/service-role keys are backend-only and must never appear in browser bundles, public env vars, frontend code, committed docs, logs, or screenshots.
- Publishable/anon keys identify a project and are only safe with RLS and least-privilege grants.
- SSR auth requires cookie-aware clients and cache discipline. Never cache personalized `Set-Cookie` responses across users.
- Storage authorization lives in policies too. Public buckets and listing permissions require explicit product reason.
- Prefer migrations and generated types over dashboard-only drift when code depends on schema shape.
- Run or review database advisors when security/performance posture matters.

## Common Project-Local Fields

A project using Supabase should maintain `<governance-root>/shipglows_data/technical/platforms/supabase.md` with:

- project URL/key env var names, never secret values
- services used: Auth, Database, Storage, Realtime, Edge Functions, Cron, Queues
- RLS policy ownership and test scenarios
- client/server boundary and key usage
- SSR/session/cookie strategy
- storage buckets and visibility policy
- migration/generation commands
- MCP/CLI/dashboard evidence route

Use `templates/project_platform_usage.md` as the starter structure.

## Security Notes

- Never store service-role keys, secret keys, DB passwords, connection strings, JWT signing secrets, refresh tokens, raw table data, or raw storage objects in ShipGlows docs.
- Treat policy changes as security-sensitive code changes.
- Redact user IDs/emails unless required and safe.
- For migrations, distinguish schema diff, data migration, and production deploy risk.

## Validation

```bash
python3 tools/shipglows_metadata_lint.py shipglows_data/technical/external-platforms/supabase.md
rg -n "Freshness Gate|Source Map|ShipGlows Decision Rules|Maintenance Rule" shipglows_data/technical/external-platforms/supabase.md
```

## Reader Checklist

- `supabase`, `RLS`, `service_role`, `anon`, `sb_publishable`, `storage.objects`, or Supabase env vars found -> check for project-local Supabase usage note.
- Auth/SSR changed -> verify cookies, token refresh, cache behavior, and route protection.
- DB/storage policies changed -> verify positive and negative access cases.
- Edge Function or backend secret path changed -> verify backend-only containment.

## Maintenance Rule

Update this note when Supabase Auth, RLS, API keys, SSR, Storage policies, CLI, migrations, generated types, Edge Functions, or database advisor behavior changes.
