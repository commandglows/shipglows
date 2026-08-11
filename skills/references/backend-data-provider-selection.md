---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-08-11"
updated: "2026-08-11"
status: active
source_skill: 900-shipglows-core
scope: backend-data-provider-selection
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/preferred-stacks.md
  - skills/references/identity-provider-selection.md
  - skills/app-blueprints/
  - skills/references/cross-platform-runtime-selection.md
depends_on: []
supersedes: []
evidence:
  - "Official Convex pricing, limits, project, HTTP API, and authentication documentation reviewed 2026-08-11."
  - "Official Firebase project, Firestore quota, pricing, and FlutterFire package documentation reviewed 2026-08-11."
  - "Official Supabase pricing and organization billing documentation reviewed 2026-08-11."
  - "Operator decision 2026-08-11: Convex HTTP is the prevailing backend/data owner for universal Flutter."
  - "Official Convex Auth0 integration documentation reviewed 2026-08-11."
next_review: "2026-09-11"
next_step: "Refresh dynamic quotas and SDK maturity before the next provider commitment."
---

# Backend And Data Provider Selection

Use this matrix after the product surfaces and identity owner are known. Auth
and data are separate decisions: Firebase Auth does not require Firestore, and
Clerk does not require Convex.

## Current matrix - reviewed 2026-08-11

| Criterion | Convex | Firestore | Supabase |
| --- | --- | --- | --- |
| Portfolio of free projects | Strongest current default: Free/Starter allows 40 deployments per team; usage is pooled across the team | Spark project creation is usually limited to about 5-10 projects per Google account | Free organizations are constrained by active-project limits across organizations where a member is owner/admin |
| Free data allowance | 0.5 GB database, 1 GB monthly database I/O, and other resource caps pooled per team | One free database per project: 1 GiB, 50,000 reads/day, 20,000 writes/day, 10 GiB monthly egress | Project-level database, storage, egress, and MAU quotas; inactive Free projects may pause |
| Flutter integration | No official Flutter SDK documented; use the official HTTP API by default, or approve a community SDK explicitly | Official FlutterFire SDK supports Android, iOS, macOS, Web, and Windows | Official `supabase_flutter` SDK; broad Flutter support |
| Realtime and offline | Realtime is native through official JS/mobile clients; HTTP integration is request/response unless a reviewed realtime bridge is adopted | Excellent realtime listeners and built-in offline persistence | Realtime available; offline-first behavior requires an application strategy |
| Server-side authority | Queries, mutations, actions, crons, and HTTP actions are included | Firestore rules protect data, but authoritative application logic normally needs Cloud Functions or another backend; Cloud Functions requires Blaze | Postgres functions, Edge Functions, RLS, and SQL transactions are available |
| Cost behavior | Free uses hard caps; prolonged excess can return errors. Starter adds metered overages | Spark stops at free limits; Blaze enables paid usage. Reads and index-entry reads can amplify cost | Free can pause; Pro starts with organization/project compute economics and additional projects add cost |
| Best fit | Many small pre-revenue products needing a managed backend and server functions | A small number of Flutter-first products where official SDK, offline, and realtime outweigh portfolio limits | Products that specifically benefit from PostgreSQL, SQL, RLS, or existing Supabase investment and can fund continuous availability |

Project and deployment limits are not usage quotas. Record both. Convex's 40
deployment limit is team-wide and each project normally consumes production
plus development deployments. Firebase project quota is account-specific and
may be increased by Google; never promise an exact permanent project count.

## Default decisions

1. **Canonical portfolio default:** use Convex for backend/data and server functions. Keep each
   product isolated and monitor pooled team usage. Use its official HTTP API
   from every Flutter target until an official or approved realtime client exists.
   Verify Firebase ID tokens server-side; a client user ID is not authentication.
2. **Flutter with native Windows:** prefer Firebase Auth as identity candidate,
   but keep Convex as backend/data unless the product independently satisfies
   the Firestore decision below.
3. **Firestore exception:** choose Firestore when the portfolio contains only a
   bounded number of projects and official Flutter offline/realtime behavior is
   a material product requirement. Define a server-authority path separately.
4. **Supabase exception:** choose Supabase when PostgreSQL and SQL capabilities
   materially replace complexity and the budget covers an always-available
   plan. Do not create organizations merely to evade free-plan limits.
5. **Existing product:** migration requires parity, export/import, identity
   mapping, rollback, cost, and hosted proof. A matrix preference alone never
   authorizes migration.

Auth0 does not change the backend/data default. Convex officially documents an
Auth0 integration, so Auth0 is technically compatible as an identity exception.
Evaluate tenant and plan economics in `identity-provider-selection.md`; official
integration alone does not make Auth0 the portfolio default.

## Server-authority gate

Scores, XP, leaderboards, entitlements, payments, moderation decisions, and
other abuse-sensitive mutations must be recomputed or validated by trusted
server code. Firestore Security Rules are authorization policy, not a general
replacement for domain logic. A Flutter client must never be the authority for
these values.

## Decision record

```text
backend_data_owner: convex | firestore | supabase | other
identity_owner: firebase | clerk | other
products_on_account_or_team: <count and forecast>
project_or_deployment_limit_checked_at: YYYY-MM-DD
usage_quota_checked_at: YYYY-MM-DD
billing_activation_required: yes | no
flutter_client_path: official_sdk | official_http_api | approved_community_sdk
windows_required: yes | no
offline_required: yes | no
server_authority: <functions/actions/backend owner>
cost_cliff: <hard stop, pause, or metered overage>
migration_required: yes | no
```

## Official sources to refresh

- [Convex pricing](https://www.convex.dev/pricing), [limits](https://docs.convex.dev/production/state/limits), [projects](https://docs.convex.dev/production/overview), and [HTTP API](https://docs.convex.dev/http-api/).
- [Firebase project limits](https://firebase.google.com/docs/projects/learn-more), [Firestore quotas](https://firebase.google.com/docs/firestore/quotas), [Firestore pricing](https://firebase.google.com/docs/firestore/pricing), and [`firebase_auth`](https://pub.dev/packages/firebase_auth).
- [Supabase pricing](https://supabase.com/pricing) and [organization billing](https://supabase.com/docs/guides/platform/org-based-billing).
- [Convex Auth0 integration](https://docs.convex.dev/auth/auth0).
