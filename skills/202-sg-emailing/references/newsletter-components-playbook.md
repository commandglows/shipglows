---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-05"
updated: "2026-09-05"
status: active
source_skill: 202-sg-emailing
scope: newsletter-components
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems: ["Newsletter","Convex","Postmark"]
depends_on: []
supersedes: []
evidence:
  - "Approved Core plan: central identity, consent, access and email agent training, September 5, 2026."
next_review: "2026-10-05"
next_step: Revalidate project configuration and current official provider behavior before integration.
---

# Reusable Newsletter Components and Journeys

Use for a newsletter signup, confirmation, preferences or operator preview/send
surface. Reuse this behavior contract across frameworks; it is not a published
component package. Adapt markup to the existing design system and runtime, not
a copied project domain, API key or hardcoded business identity.

## Component responsibilities

| Component | Required inputs | Observable behavior |
| --- | --- | --- |
| Signup form | Locale, controller/contact, notice URL/version, enabled state | Labelled email, unchecked explicit consent, pending/success/error states |
| Server proxy | Fixed business/audience/purpose/source, scoped service credential | Validate, enforce scope, call canonical API; never expose provider tokens |
| Confirmation | Signed opaque expiring token, action generation | GET displays; POST confirms once; expired/withdrawn links cannot restore consent |
| Preferences | Verified token/session, declared scopes | Clear per-purpose choices, withdrawal receipt, accessible recovery |
| Email template | Locale, brand tokens, approved content/footer/action | Escaped semantic HTML and equivalent plain text; usable unsubscribe |
| Operator preview | Purpose, audience snapshot, immutable content version | Preview without send; approval binds content and recipient scope |

In the central pattern, identity, consent and entitlements remain separate.
An anonymous visitor can subscribe. Never require a purchase or grant product
access through this form. Unsubscribe must not delete an account or license.

## Signup and errors

Show the real purpose, sender/controller and versioned notice next to consent.
Do not precheck, bundle account acceptance with marketing, invent social proof
or hide material conditions. Keep disabled/unconfigured forms honestly disabled
with an appropriate explanation; no simulated success handler.

Use semantic labels, autocomplete=email, keyboard operation, visible focus and
a status region; announce async errors/success without trapping focus. Preserve
entered email on recoverable errors without persisting it unnecessarily. Support
native form POST or an equivalently usable declared fallback; JS enhancement
must not be the only way to understand failure. Do not announce subscribed when
the server has only accepted a pending confirmation request.

Server-side controls validate current notice version, affirmative consent and
allowlisted business/purpose/source; hidden browser fields are untrusted. Limit
request size and rate, use honeypot as supplementary protection, and do not
trust spoofable forwarded-IP headers. Check Origin/CSRF for browser endpoints.
Authentication and rate limits still apply to non-browser callers.

Use stable idempotency for a retry of the same logical submission. A new intent
gets a new key. Bound upstream timeouts, inspect structured status (HTTP 200 alone
is insufficient) and return privacy-preserving responses without exposing whether
an address has an account. Missing/stale notice or malformed upstream success
must produce an honest recoverable error.

## Confirmation and withdrawal

Separate requested, confirmation sent, confirmed, expired and withdrawn states.
Do not mutate through scanner GET requests. Confirmation consumes a scoped token
once; withdrawal supersedes pending confirmations. Expired links offer a safe
fresh-request route, not an automatic extension or subscription.

Newsletter marketing uses provider-managed unsubscribe when required by the
selected adapter, with canonical event reconciliation. Preference links preserve
scope, locale and no-referrer/no-cache protection. Prove repeated withdrawal is
idempotent and a delayed provider event cannot restore consent. Cross-brand
preferences require explicit authenticated scope, not the same email alone.

## Preview, approval and transport

Preview renders both HTML and text without sending. Approval binds immutable
content, purpose and recipient scope; edits invalidate it. Recheck each recipient's
eligibility immediately before send. Suppressed or withdrawn recipients stay
excluded even when they were in an earlier preview.

Do not present a one-recipient pilot as a full campaign engine. Campaign scheduling,
pagination, cancellation, retries, audience snapshots and aggregate reporting
need an explicit implementation contract before promising bulk delivery.

## Adoption and proof

Resolve static versus server output: a static Astro build needs an actual
server/serverless endpoint for POST; a source route or build success alone
does not prove deployment. Keep provider code on the server behind the central
service. Project records own brand, legal footer, domains, IDs, notices, retention
and activation flags; examples must not carry real personal data or secrets.

Prove keyboard and narrow-screen flows; pending confirmation; unchecked consent;
stale notice; duplicate click/retry; timeout and malformed upstream response;
scanner GET; expired token; withdrawal before send; cross-business isolation;
HTML/text and actual authorized receipt where delivery is claimed. Use the
selected accessibility playbooks' manual/client proof before calling mail accessible.

The owner loads writing, technical accessibility, central boundary and selected
provider references directly as needed. This leaf does not load other leaves.
