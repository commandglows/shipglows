---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-05"
updated: "2026-09-05"
status: active
source_skill: 109-sg-auth-debug
scope: auth0-integration
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems: ["Auth0","Convex"]
depends_on: []
supersedes: []
evidence:
  - "Approved Core plan: central identity, consent, access and email agent training, September 5, 2026."
next_review: "2026-10-05"
next_step: Revalidate project configuration and current official provider behavior before integration.
---

# Auth0 Integration

Use when Auth0 is selected by the project or is the actual system being diagnosed.
This playbook does not select Auth0 globally or migrate Clerk/Firebase users.
Resolve the existing project contract before the general provider-selection matrix.

## Setup and platform contract

Record tenant/issuer, application type and client ID, backend token contract,
exact callback/logout/origin allowlists and environment. Separate development,
staging and production bindings. Use supported SDKs and Authorization Code with
PKCE for public SPA/native clients; never embed a client secret in those clients.

Use the system browser and the platform's documented callback mechanism for
native apps. Verify current SDK support for each requested platform rather than
extending an Android or web success to Windows/Linux. Preserve the project's
managed launch configuration, secret-store scope and public build parameters.
Missing configuration blocks launch proof; never bypass authentication to get
an app running.

## Identity and backend verification

Store a stable verified issuer + subject mapping to the internal person ID.
Email and email_verified are attributes, not account-linking authority or paid
access. Explicit linking must prove control of both identities; never merge
accounts simply because a newsletter address matches.

Validate tokens through the supported backend integration: signature/key rotation,
issuer, intended audience, expiry and required claims. An Auth0 UI authenticated
flag does not prove that Convex or another backend accepts the identity.
For custom APIs validate their access tokens and permissions; never treat an
ID token as a generic API bearer token.

Convex's official Auth0 adapter has its own token/audience contract. Match
auth.config.ts to the actual supported adapter; do not substitute a custom-API
audience recipe blindly. Use backend getUserIdentity and server-owned authorization;
in the React adapter, useConvexAuth must confirm backend authentication before
protected queries. For other clients reproduce that backend-authenticated signal.
No raw decoded JWT or client claims can replace verification.

Authentication proves identity only. Resolve current entitlement in the canonical
ledger for each protected operation; missing/malformed identity or ledger lookup
denies. An Auth0 permission claim may constrain an API action but never replaces
the suite commercial entitlement policy. Identity changes do not subscribe marketing.

## Session, refresh and logout

Specify refresh grants/scopes, expiration, rotation and secure storage for the
selected SDK/platform. Do not invent a global browser-storage rule across SDKs.
Handle expired/reused refresh tokens through safe reauthentication; never loop
refresh retries indefinitely or log tokens. Rotating refresh-token reuse may
invalidate the token family.

Distinguish application state/session, Auth0 SSO and upstream identity-provider
session. Logout clears the app's protected state and uses the configured Auth0
logout flow when intended; upstream logout depends on provider support/policy.
Logout alone does not revoke all previously issued access tokens. In-flight
requests, local caches and another tab must not restore a signed-out user's UI.

## Email boundary and operational safety

Auth0 account verification/reset messages belong to identity flows. Postmark
newsletter confirmation belongs to marketing consent. Neither confirms the other.
If Auth0 uses a custom email provider, document that dedicated integration and
transactional purpose; never silently route identity mail through a marketing
Broadcast stream or duplicate Auth0-generated links.

Read-only diagnosis inspects configuration names and safe state, not secret values.
Tenant/application/connection changes, account linking, credential rotation and
real reset/verification mail need bounded authority. No auth bypass, permissive
callback wildcard, production tenant guess or unredacted token diagnostics.

## Required proof

- Exact target/configuration and callback round trip.
- Backend authentication accepted, then protected access granted only with
  a valid entitlement; authenticated-but-unlicensed denial is mandatory.
- Wrong issuer/audience, expired/malformed token and cross-user/product denial.
- Refresh expiry/reuse, restart, cancellation and provider/network error recovery.
- Logout clears protected state; re-login, stale callbacks and cache cannot
  resurrect the previous user.
- Hosted callback/cookie behavior on its actual origin and native callback on
  each claimed platform. Build success and browser login alone are partial.

Report configuration checked, app running, login verified and protected access
verified separately. Do not claim a device or hosted flow from source review.

## Official sources checked 2026-09-05

- [Authorization Code with PKCE](https://auth0.com/docs/get-started/authentication-and-authorization-flow/authorization-code-flow-with-pkce)
- [Access-token validation](https://auth0.com/docs/secure/tokens/access-tokens/validate-access-tokens)
- [Refresh-token rotation](https://auth0.com/docs/secure/tokens/refresh-tokens/refresh-token-rotation)
- [Logout layers](https://auth0.com/docs/authenticate/login/logout)
- [Account linking](https://auth0.com/docs/manage-users/user-accounts/user-account-linking)
- [Convex Auth0 integration](https://docs.convex.dev/auth/auth0)
- [Convex backend identity](https://docs.convex.dev/auth/functions-auth)
- [Flutter quickstart](https://auth0.com/docs/quickstart/native/flutter)

Recheck official SDK/platform/configuration details before implementation; do not
copy dated versions or plan limits into policy. This leaf does not load other leaves.
