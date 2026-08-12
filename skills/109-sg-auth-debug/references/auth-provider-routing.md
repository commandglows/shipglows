---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 109-sg-auth-debug
scope: auth-provider-routing
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems: [skills/109-sg-auth-debug/SKILL.md]
depends_on: []
supersedes: []
evidence: ["Extracted from the auth-debug workflow during Wave 16 compaction."]
next_review: "2026-09-12"
next_step: "/103-sg-verify auth provider routing"
---

# Auth Provider Routing

Inspect only provider configuration, login/callback routes, middleware/guards, auth-related environment variable names (never values), and the broken flow's pages/components. Look for callback URL, allowed domains, `SITE_URL`/redirect allow-list, public/protected ordering, session/cookie lifecycle, post-login redirect, and backend identity propagation.

Load only matching direct references:

- Clerk: `clerk-tooling.md`; add `clerk-testing.md` for live testing and `clerk.md` for configuration/Next.js/session behavior.
- Supabase: `supabase-tooling.md`; add `supabase-testing.md` for live/local-stack testing and shared `supabase-auth.md` for SSR cookies, callbacks, `getUser()`/`getSession()`, and RLS boundary.
- Google OAuth: `google-oauth.md`.
- Convex: `convex-tooling.md`; add `convex-clerk.md` for Clerk identity propagation and `python-convex.md` for Python jobs/clients.
- Vercel deployment/runtime/logs: `vercel-tooling.md`; deployment truth stays owned by `405-sg-prod`.
- Astro Clerk: `astro-clerk.md`.
- Flutter/Dart Clerk or Convex: `flutter-clerk-convex.md`.
- Flutter Web ClerkJS bridge: `flutter-web-clerkjs-bridge.md`; for implementation in another repo, add shared `flutter-web-clerkjs-auth-pattern.md`.
- YouTube OAuth/Google scopes/refresh token/API auth route: shared `tubeflow-youtube-oauth-nextjs-convex-pattern.md`.
- SDK stability, beta, unofficial package, or provider selection: `sdk-policy.md` plus shared `identity-provider-selection.md`.

Current provider or SDK truth that may have changed requires focused official documentation verification. Do not infer configured secrets from variable names, expose values, or change provider settings from diagnosis alone.
