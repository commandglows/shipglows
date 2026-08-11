---
artifact: specification
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-11"
updated: "2026-08-11"
status: ready
source_skill: 900-shipglows-core
scope: portfolio-backend-auth-decision-matrices
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/preferred-stacks.md
  - skills/references/identity-provider-selection.md
  - skills/references/backend-data-provider-selection.md
  - skills/references/cross-platform-runtime-selection.md
  - skills/app-blueprints/flutter-crud-content/blueprint.md
  - skills/109-sg-auth-debug/references/flutter-clerk-convex.md
depends_on: []
supersedes: []
evidence:
  - "Operator decision 2026-08-11: Astro public site; universal Flutter app; Firebase Auth identity; Convex HTTP backend/data; Rust only for a justified native engine."
  - "Official Flutter, FlutterFire, Tauri, Expo, and .NET MAUI platform documentation reviewed 2026-08-11."
  - "Official Auth0 pricing, Flutter SDK, tenant, and Convex integration documentation reviewed 2026-08-11."
  - "Operator decision 2026-08-11: Auth0 is a strong OIDC alternative but rejected as the default for a free multi-product portfolio."
next_review: "2026-09-11"
next_step: "Prove the first Linux Firebase Auth adapter and signed desktop release paths."
---

# Portfolio Backend And Auth Decision Matrices

## Outcome

ShipGlows must choose authentication and backend/data providers from the full
product footprint, including a portfolio with many pre-revenue applications,
rather than treating a provider's headline free tier as sufficient evidence.

The prevailing portfolio decision is Astro for the public site; one Flutter
application for Web, Android, iOS, Windows, macOS, and Linux; Firebase Auth as
the single identity owner, with a REST/OIDC adapter on Linux; Convex through its
official HTTP API for data and functions; and Rust only for a justified native engine.

Auth0 remains an approved OIDC alternative with official Convex integration,
but not the default: its Flutter SDK does not list Linux, Windows lacks
Credentials Manager, Free has 25,000 MAU but one tenant, isolated
development/production tenancy is paid, and Essentials starts at $35/month at
the 2026-08-11 review. Clerk remains inherited proved context to migrate
progressively, including the GoCharbon decision context; no application project
is changed by this ShipGlows Core chantier.

## Scope

- Keep identity-provider selection separate from backend/data selection.
- Add project/deployment limits, pooled usage, billing activation, Flutter and
  Windows support, server-side authority, offline/realtime behavior, and cost
  cliffs to provider decisions.
- Refresh the preferred Flutter portfolio defaults from current official
  evidence for Convex, Firebase, Clerk, Firestore, and Supabase.
- Do not migrate an application, create provider projects, or change billing.

## Invariants

- One product has one canonical identity owner.
- Client code never owns authoritative scores, entitlements, or sensitive
  business mutations.
- Authentication choice does not implicitly select the data provider.
- A free-plan recommendation states both project-count limits and usage limits.
- Dynamic quotas and pricing are rechecked before implementation.
- Universal Flutter is the application shell; Rust is an exceptional native
  engine, not a second general-purpose UI stack.

## Pressure scenarios

- `TECH-PORTFOLIO-FREE`: many independent pre-revenue products need continuously
  available backends without one paid database subscription per product.
- `TECH-FLUTTER-WINDOWS`: Android, Web, and native Windows must authenticate
  without depending on an unsupported community bridge.
- `TECH-AUTH-NOT-DATA`: choosing Firebase Auth must not silently choose Firestore.
- `TECH-SERVER-AUTHORITY`: a quiz leaderboard must not trust scores calculated
  by a modified Flutter client.
- `TECH-FREE-CLIFF`: a plan with pooled quotas, pausing, hard failures, or billing
  activation must expose that consequence before recommendation.
- `TECH-AUTH0-PORTFOLIO`: official OIDC and Convex compatibility do not override
  missing Linux SDK coverage, Windows token storage, one-Free-tenant isolation,
  or the paid development/production cliff.

## Execution batches

One sequential documentation batch owns:

- `skills/references/backend-data-provider-selection.md`
- `skills/references/preferred-stacks.md`
- `skills/references/identity-provider-selection.md`
- `skills/references/cross-platform-runtime-selection.md`
- `skills/app-blueprints/flutter-crud-content/blueprint.md`
- `skills/109-sg-auth-debug/references/flutter-clerk-convex.md`

## Proof path

Scenario-first documentation proof: focused searches must show the new backend
matrix, the `identity != data` rule, the portfolio-free criterion, Flutter
Windows routing, and current review dates. Metadata lint must pass for changed
governance references.

## Rollback

Revert these bounded documentation files. No provider or application state is
mutated by this chantier.
