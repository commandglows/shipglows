---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.4.1"
project: ShipGlows
created: "2026-08-02"
updated: "2026-09-05"
status: active
source_skill: 109-sg-auth-debug
scope: flutter-identity-provider-selection
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/109-sg-auth-debug/references/sdk-policy.md
  - skills/app-blueprints/flutter-crud-content/blueprint.md
  - skills/references/documentation-freshness-gate.md
  - skills/references/backend-data-provider-selection.md
  - skills/references/cross-platform-runtime-selection.md
depends_on: []
supersedes: []
evidence:
  - "Official Clerk Android documentation reviewed 2026-08-02."
  - "Official Firebase Flutter platform support reviewed 2026-08-02."
  - "Official Clerk, Firebase, and Supabase pricing reviewed 2026-08-02."
  - "Official Supabase pausing documentation reviewed 2026-08-02: a paused Free project cannot process requests; each project includes Auth alongside its other services."
  - "ContentGlowz release APK completed the Clerk Android browser OAuth path on a physical device."
  - "Official Clerk Flutter beta announcement, Clerk pricing, and Firebase Auth Flutter package platform support reviewed 2026-08-11."
  - "Operator decision 2026-08-11: identity and backend/data providers are selected independently, with portfolio project limits treated as a first-class criterion."
  - "Operator decision 2026-08-11: Firebase Auth is the prevailing identity owner for universal Flutter; Linux uses REST/OIDC because firebase_auth does not list Linux."
  - "Official Auth0 Flutter SDK, pricing, tenant, and Convex integration documentation reviewed 2026-08-11."
  - "Operator decision 2026-08-11: Auth0 is a strong OIDC alternative but not the free-portfolio default; Clerk is inherited proof to migrate progressively."
next_review: "2026-09-11"
next_step: "Refresh provider maturity and package versions before the next Flutter identity-provider decision."
---

# Flutter Identity Provider Selection

Existing project decisions take precedence over this general selection matrix.
Diagnosing or extending a declared Auth0 integration does not reopen provider
selection. The active development, engineering or auth owner loads
`auth0-integration-playbook.md` directly for that implementation; this matrix
does not change a project's provider or claim that Auth0 is deployed globally.

Use this matrix before implementing or changing identity. Firebase Auth is the
portfolio default. Clerk remains an inherited existing-product exception with
proved flows and a progressive migration expectation. Auth0 is a strong OIDC
alternative, not the free-portfolio default.
Identity selection never selects Firestore implicitly.

## Evidence vocabulary

- **Proved locally**: signed release artifact completed the named user flow on a
  real target device.
- **Official stable/support listed**: the provider documents the platform; this
  is not local end-to-end proof.
- **Official beta**: provider support is listed as beta; it needs an early
  signed-target spike before it becomes a launch dependency.
- **Unproven**: no ShipGlows release-device proof exists yet.

## Current matrix — reviewed 2026-08-11

| Criterion | Clerk | Firebase Auth |
| --- | --- | --- |
| Flutter web | ClerkJS bridge: proved locally; official Flutter SDK remains beta | Official Flutter package support listed; unproven in ShipGlows as the web identity owner |
| Flutter Android | Official Kotlin SDK behind Flutter bridge: proved locally; official Flutter SDK remains beta | Official Flutter package support listed; used by ReplayGlowz, but creates a second identity owner when web uses Clerk |
| Flutter iOS / macOS | iOS native SDK exists; Flutter bridge unproven | macOS Auth support is official beta; Google Sign-In package supports macOS; unproven in ShipGlows |
| Flutter Windows | No proven ShipGlows native Windows flow; use ClerkJS web/PWA or an explicitly designed desktop OAuth flow | Official `firebase_auth` package lists Windows; native Google flow must still be spike-tested for the exact release target |
| Flutter Linux | No proven native Linux flow; requires an explicitly designed browser/OIDC adapter | `firebase_auth` does not list Linux; use a reviewed REST/OIDC adapter with secure callback and token storage |
| Public desktop roadmap | No Clerk Windows/macOS native SDK commitment located in public docs/changelog at this review date | Beta status, not a promised GA date |
| One identity across web and Android | Strong: Clerk owns both | Strong only if Firebase owns both; weak if web remains Clerk |
| OS-native desktop priority | PWA has less OS integration | Better candidate, but beta support is a launch risk to validate early |

## Auth0 alternative assessment - reviewed 2026-08-11

| Criterion | Auth0 |
| --- | --- |
| Flutter platforms | Official `auth0_flutter` covers Android, iOS, macOS, Web, and Windows; Linux is not listed |
| Linux | Requires a separately designed OIDC adapter and proof |
| Windows credential storage | Windows is supported, but Credentials Manager is unavailable; secure token persistence needs explicit proof |
| Convex | Convex documents an official Auth0 integration |
| Free portfolio economics | Free includes 25,000 MAU but only one tenant; isolated development and production tenants are unavailable |
| Paid cliff | Separate development/production tenancy requires a paid plan; Essentials starts at $35/month at this review date |
| Verdict | Strong OIDC alternative for justified enterprise needs; rejected as the default for many independent free products |

## Default decisions

1. **Greenfield universal Flutter:** choose Firebase Auth for Web, Android, iOS,
   Windows, macOS, and Linux; use official SDKs where listed and REST/OIDC on Linux.
2. **Windows or macOS launch:** require a signed spike proving Google sign-in,
   restore, sign-out, backend-token propagation, and installer behavior.
3. **Linux launch:** prove PKCE, callback ownership, secure token storage,
   restore, revocation, sign-out, and Firebase-token propagation to Convex.
4. **Existing proved Clerk product:** preserve Clerk unless migration has an
   explicit identity-linking, rollback, and release-proof contract. Migrate
   progressively rather than copying Clerk into new products.
5. **Auth0 exception:** select Auth0 only when OIDC/enterprise fit outweighs its
   Linux adapter, Windows credential-store, tenant-isolation, and paid-plan
   consequences. Official Convex integration does not override portfolio cost.

## Launch availability gate

Before comparing SDK ergonomics, reject any candidate whose chosen plan can
pause, hibernate, or otherwise make sign-in unavailable while the product has
few or no active users, unless the product budget explicitly includes the plan
needed to keep it continuously available. A free tier that sleeps is not a
viable launch identity service for an app expected to accept a first user at
any time.

Concrete current example: Supabase Free may pause a project after low database
activity over seven days. A Supabase project contains Auth as one of its
sub-services, and a paused project cannot process requests (HTTP 540). Its
authentication endpoints and session refresh therefore do not remain available
until an owner resumes the project in Supabase Studio. This makes the Free-plan
configuration unsuitable as a continuously available identity owner before a
product has regular activity.

Pressure scenario: a Flutter product has no users yet and a candidate provider
pauses inactive projects. The agent excludes that free-plan configuration from
the shortlist before recommending it for native Windows/macOS coverage; it does
not treat a manual wake-up as an acceptable sign-in recovery path.

## Commercial launch snapshot — reviewed 2026-08-11

Prices are provider-published USD starting prices, not a budget guarantee.
Recheck them before committing a provider or a paid plan.

| Provider/configuration | Early-stage auth cost and availability |
| --- | --- |
| Clerk Hobby | $0 without a credit card; unlimited applications and up to 50,000 monthly retained users per app. |
| Firebase Authentication | Most methods, including social sign-in, are no-cost; phone/SMS and other Firebase/Google Cloud products can create charges. |
| Supabase Free | $0, but the whole project (including Auth) can pause after low activity. Not suitable for continuously available launch auth. |
| Supabase Pro | Starts at $25/month per organization, with the first standard project included; additional standard projects start around $10/month. No inactivity pausing. |

Cost rule: compare the plan that keeps sign-in continuously available, not only
the $0 tier. Keep identity-provider cost separate from database, storage,
functions, messaging, and analytics costs; they can change the total product
budget even when authentication itself is free.

Provider-count rule: identity application limits, backend project/deployment
limits, and data usage quotas are different constraints. Record each one and
use `backend-data-provider-selection.md` for the independent data decision.

## Scale economics — reviewed 2026-08-02

Do not compare a Clerk MRU total directly to a Firebase or Supabase MAU total.
An MRU is a user who returns after the first day; an MAU is a user active during
the billing month. A product with significant one-time sign-ups can therefore
show materially fewer billable Clerk users than MAUs.

| Provider | Included volume and scale signal |
| --- | --- |
| Clerk Pro | 50,000 MRU per app included; above that, published tiered MRU pricing applies. Favors a product with many one-off sign-ups or paid retained users, but can become expensive with a high-retention free audience. |
| Firebase Auth with Identity Platform / Blaze | 50,000 MAU included for email, social, anonymous, and custom auth; then $0.0025–$0.0055 per MAU, depending on volume. Phone/SMS is separate. Favors a native-first product where authentication is not expected to carry a large standalone bill. |
| Supabase Pro | 100,000 MAU included; then $0.00325 per MAU. The total still depends materially on Postgres compute, database size, egress, storage, and functions. Favors a product that also wants Supabase as its backend. |

Financial decision rule:

1. Forecast returning users and monthly active users separately.
2. Price the same 12-month growth curve with the provider's own metric.
3. Add mandatory platform costs: continuous availability, database/compute,
   storage/egress, SMS/email, support/SLA, MFA, organizations/SSO, and custom
   domains.
4. Choose the provider that fits the product-wide identity owner and native
   platform proof; never select a cheaper auth line item that creates a second
   identity system or blocks the target desktop platform.

## Non-negotiable rule: one owner

Do not adopt `Clerk on web + Firebase Auth on native` as a default architecture.
It creates two independent session/user stores and requires a bridge to match
accounts, entitlements, tokens, sign-out, deletion, recovery, and support
diagnostics. An existing hybrid system is migration debt, not a template.

An exception requires an explicit migration/identity-linking contract covering:
canonical user ID, account matching, token exchange, entitlement authority,
sign-out and deletion propagation, recovery, observability, rollback, and
release-device proof on every targeted platform.

## Decision record and validation gate

Before implementation, record:

```text
identity_owner: clerk | firebase
backend_data_owner: convex | firestore | supabase | other
targets_at_launch: web | android | windows | macos | ios
desktop_expectation: pwa | native
continuous_auth_availability: <plan that remains active before first user>
auth_cost_checked_at: YYYY-MM-DD
auth_cost_assumption: <provider plan, user metric, and excluded service costs>
scale_forecast: <MRU, MAU, retention, and 12-month assumptions>
provider_maturity_checked_at: YYYY-MM-DD
provider_versions_checked: <exact relevant package/SDK versions>
release_spike_required: yes | no
release_spike_scope: <platform flows or not required>
auth0_exception: <enterprise/OIDC justification or not applicable>
linux_adapter: rest_oidc | not_applicable
backend_token_audience_and_issuer: <Firebase/Convex verification contract>
```

Use the official provider documentation and package pages at the time of the
decision. Do not reuse this matrix's versions or maturity labels blindly after
its review date. When any required platform is beta or unproven, the decision
is `conditional` until the release-target spike passes.

## Question routing and freshness

Always load this matrix first for a Clerk/Firebase/platform question.

1. If it answers the question at its review date, state that evidence and date;
   do not browse merely to repeat it.
2. Check official sources only when the operator asks for the latest/current
   status, roadmap or release estimate; when the matrix review date has passed;
   or before a provider decision or release spike.
3. State the result as a dated fact, never as a vendor delivery promise. An
   absent public roadmap is not evidence that a platform will arrive soon.
4. Refresh this matrix's review date, maturity status, source list, and
   decision record after an actionable change is found.

Pressure scenario: asked whether Clerk will soon support native Windows, the
agent first reports the matrix's dated absence of a public commitment. It then
checks the official Clerk changelog only because roadmap timing is dynamic; it
does not present that research as a substitute for the decision matrix.

## Sources to refresh

- Clerk native mobile reference and Android/iOS platform pages.
- Clerk changelog and official public roadmap/announcement surfaces.
- Clerk Flutter package pages, when considering Flutter/Dart-native support.
- Firebase Flutter supported-platform table.
- `firebase_auth` and `google_sign_in` official Flutter package pages.
- Firebase Auth REST API and OpenID Connect documentation for the Linux adapter.
- [Auth0 Flutter SDK](https://auth0.com/docs/quickstart/native/flutter),
  [Auth0 pricing](https://auth0.com/pricing), and
  [Auth0 tenants](https://auth0.com/docs/get-started/auth0-overview/create-tenants).
- [Convex Auth0 integration](https://docs.convex.dev/auth/auth0).
- Clerk, Firebase, and Supabase official pricing pages before a commercial
  provider decision.
- Supabase Free project-pausing and billing documentation when Supabase enters
  a shortlist.
- `backend-data-provider-selection.md` whenever authentication is discussed
  alongside Firestore, Convex, Supabase, project counts, or data costs.
