---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlowz
created: "2026-08-02"
updated: "2026-08-02"
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
depends_on: []
supersedes: []
evidence:
  - "Official Clerk Android documentation reviewed 2026-08-02."
  - "Official Firebase Flutter platform support reviewed 2026-08-02."
  - "ContentGlowz release APK completed the Clerk Android browser OAuth path on a physical device."
next_review: "2026-09-02"
next_step: "Refresh provider maturity and package versions before the next Flutter identity-provider decision."
---

# Flutter Identity Provider Selection

Use this matrix before choosing, changing, or combining Clerk and Firebase Auth
for a Flutter product. It is a product-architecture decision, not a per-screen
or per-platform convenience choice.

## Evidence vocabulary

- **Proved locally**: signed release artifact completed the named user flow on a
  real target device.
- **Official stable/support listed**: the provider documents the platform; this
  is not local end-to-end proof.
- **Official beta**: provider support is listed as beta; it needs an early
  signed-target spike before it becomes a launch dependency.
- **Unproven**: no ShipGlowz release-device proof exists yet.

## Current matrix — reviewed 2026-08-02

| Criterion | Clerk | Firebase Auth |
| --- | --- | --- |
| Flutter web | ClerkJS bridge: proved locally | Official support listed; unproven in ShipGlowz as the web identity owner |
| Flutter Android | Official Kotlin SDK behind Flutter bridge: proved locally | Official Flutter packages; used by ReplayGlowz, but creates a second identity owner when web uses Clerk |
| Flutter iOS / macOS | iOS native SDK exists; Flutter bridge unproven | macOS Auth support is official beta; Google Sign-In package supports macOS; unproven in ShipGlowz |
| Flutter Windows | No Clerk native Flutter/Windows SDK; use ClerkJS web/PWA or an explicitly designed desktop OAuth flow | Firebase Auth Windows support is official beta; native Google flow must be spike-tested for the exact release target |
| Public desktop roadmap | No Clerk Windows/macOS native SDK commitment located in public docs/changelog at this review date | Beta status, not a promised GA date |
| One identity across web and Android | Strong: Clerk owns both | Strong only if Firebase owns both; weak if web remains Clerk |
| OS-native desktop priority | PWA has less OS integration | Better candidate, but beta support is a launch risk to validate early |

## Default decisions

1. **Web + Android, with Clerk web already in use:** choose Clerk everywhere.
   Use ClerkJS on web and the validated Kotlin Android bridge. Do not add
   Firebase merely for Android.
2. **Windows native application is a launch requirement, with material OS
   integration:** choose Firebase Auth as the candidate identity owner for the
   entire product only after a signed Windows spike proves Google sign-in,
   restore, sign-out, backend-token propagation, and installer behavior.
3. **Windows can begin as a PWA:** keep Clerk as the sole owner. Reassess a
   Firebase-wide migration only if native desktop requirements become material.
4. **macOS is a later target:** it does not by itself justify a provider split.
   Re-evaluate from the selected product-wide identity owner when macOS enters
   the committed roadmap.

## Launch availability gate

Before comparing SDK ergonomics, reject any candidate whose chosen plan can
pause, hibernate, or otherwise make sign-in unavailable while the product has
few or no active users, unless the product budget explicitly includes the plan
needed to keep it continuously available. A free tier that sleeps is not a
viable launch identity service for an app expected to accept a first user at
any time.

Pressure scenario: a Flutter product has no users yet and a candidate provider
pauses inactive projects. The agent excludes that free-plan configuration from
the shortlist before recommending it for native Windows/macOS coverage; it does
not treat a manual wake-up as an acceptable sign-in recovery path.

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
targets_at_launch: web | android | windows | macos | ios
desktop_expectation: pwa | native
continuous_auth_availability: <plan that remains active before first user>
provider_maturity_checked_at: YYYY-MM-DD
provider_versions_checked: <exact relevant package/SDK versions>
release_spike_required: yes | no
release_spike_scope: <platform flows or not required>
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
