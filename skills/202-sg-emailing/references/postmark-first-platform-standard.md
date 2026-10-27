---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-10-27"
updated: "2026-10-27"
status: active
source_skill: 202-sg-emailing
scope: postmark-first-email-platform-standard
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/202-sg-emailing/SKILL.md
  - skills/references/email-work-routing.md
  - skills/references/identity-consent-access-contract.md
  - skills/202-sg-emailing/references/postmark-agent-integration-playbook.md
  - skills/202-sg-emailing/references/resend-agent-integration-playbook.md
  - CommandGlows central email service (commandglows repo)
depends_on: []
supersedes:
  - skills/202-sg-emailing/references/resend-first-platform-standard.md
evidence:
  - "Operator decision 2026-10-27 (Diane): Postmark becomes the portfolio-wide email provider; all product email goes through the central CommandGlows email service."
  - "commandglows/shipglows_data/technical/central-email-operations.md: routes, streams, dispatch and Postmark webhook binding."
  - "commandglows/shipglows_data/technical/central-email-api-contract.md and commandglows_site/public/contracts/central-email-v1.openapi.json: v1 contract authority."
next_review: "2026-11-27"
next_step: "/103-sg-verify Postmark-first provider standard"
---

# Postmark-first Email Platform Standard

## Purpose

Defines the default email provider and the routing of every product email for ShipGlows-managed products. It replaces `resend-first-platform-standard.md` (superseded 2026-10-27, kept as history). It is a decision contract: it does not authorize creating provider objects, changing DNS, importing contacts, sending mail, or enabling automations.

## Operator Decision (2026-10-27)

- Postmark is the portfolio-wide email transport. The Resend-first default is retired.
- All product email goes through one central service: the CommandGlows central email service (commandglows repo: `commandglows_site/src/lib/email/central/`, `commandglows_site/convex/email*.ts`, API `/api/v1/email/*`).
- Resend is legacy. Flows move one at a time under the migration rules below.

## Central Service Rule

- Convex in the central service owns contacts, the consent ledger, suppressions, campaigns and the send queue.
- Postmark is transport only: one Postmark server per business, with distinct transactional and broadcast message streams.
- Apps never hold a Postmark or Resend token. They call the central API server-side with an operation-scoped machine credential. Human operators use the Clerk-protected admin relay.
- Product code never calls a provider SDK or API directly. Provider adapters live only in the central service.
- Email HTML is rendered only by the central service from content blocks. Apps send blocks, never raw HTML.
- Provider dashboards are projections. They are never the consent authority.

## Routing By Email Type

| Email type | Emitter | Path |
| --- | --- | --- |
| Authentication (OTP, magic link, verification, password reset) | Clerk | Clerk native emails. No reimplementation in ShipGlows or the central service. |
| Transactional and operational (receipts, access, alerts, service notices) | Each app's backend | `POST /api/v1/email/messages/transactional` on the business's transactional stream. Fixed service template; trusted service only. |
| Product updates | ShipGlows App | Central campaigns, one audience per product, broadcast stream, explicit marketing consent only. |
| Content newsletters | ContentGlows | ContentGlows writes the content; central campaigns deliver it on the broadcast stream. |
| Website signups (newsletter, waitlist) | Astro sites | `POST /api/v1/email/subscriptions` with double opt-in, through a shared Astro package (planned). |

Route names come from `central-email-operations.md`. The v1 OpenAPI currently publishes the campaigns, operations and templates resources. Verify each route against the contract before integration.

## Stream Separation

- The transactional stream carries service and operational mail only. It never carries newsletters, promotions or recommendations.
- The broadcast stream carries product updates and content newsletters. It is used only for recipients with explicit marketing consent for that business and purpose.
- A purchase, account creation, payment, entitlement, trial or download never creates marketing consent.
- Marketing unsubscribe never suppresses strictly necessary transactional mail. Bounces and complaints stay operational suppression signals.
- Postmark suppression is stream-scoped. Independent brand promises get isolated servers or streams. Consent never spreads across brands, even for the same address.
- Never label marketing as transactional to avoid a withdrawal.

## Consent And Double Opt-in

- Website signups create a pending subscription and send a confirmation. Only confirmation makes the subscription eligible for marketing.
- Confirmation tokens are single-use, expire, and are bound to a generation. A scanner GET never confirms or unsubscribes.
- Consent evidence (business, purpose, notice version, locale, source, recorded time) lives in the central Convex ledger.
- Postmark-managed unsubscribe and Postmark subscription events reconcile into the ledger. They do not replace it.
- Withdrawal invalidates pending confirmations and queued marketing work.
- Every marketing job rechecks consent immediately before dispatch. Every job rechecks applicable suppression.

## Auth Emails

Clerk sends its own authentication emails natively. Do not rebuild OTP, magic-link, verification or reset mail in ShipGlows, the central service or any app. Routing Clerk email delivery through the central service is an optional later step that needs its own decision record.

## Legacy Resend Migration

- A Resend flow stays live until parity is proven: eligibility, consent and suppression, template rendering, delivery and webhook reconciliation.
- Import contacts into the central service only with provenance: source, consent evidence or its absence, and date. Contacts without provenance are not marketing-eligible.
- One producer per flow. Disable the Resend producer before enabling the central producer. Never double-send.
- Keep templates, event names and sequence intent versioned outside any provider dashboard, so they survive migration.
- Load `resend-agent-integration-playbook.md` only for legacy inventory or migration work.

## Planned Shared Packages

These are planned, not implemented by this standard:

- `@shipglows/email-client`: TypeScript client, target `shipglows-email-engine/packages/email-client`.
- Astro signup component and route helper: target `shipglows-astro-engine`.
- `newsletter_studio_flutter`: composition UI, existing in `shipglows-email-engine/packages`.
- Python client: inside the ContentGlows lab.

## Exceptions

An exception to the central service or Postmark is allowed only with an explicit operator decision recorded in the project's governance: date, scope, owner and rationale. It is product-scoped and never extends to other projects. Without that record the default applies. The provider exceptions listed in the superseded Resend-first standard are history and do not open an exception.

## Freshness And Proof

- Check current Postmark behavior in official documentation before setup or a changed claim. The Postmark playbook lists the sources.
- Local tests prove source behavior only. Production activation needs the proof ladder in `postmark-agent-integration-playbook.md`: sandbox, authorized live recipient, then production with bounded approval.
- Record the Postmark server ID, mode, stream IDs and sender authority for each business before any real send.

## Stop Conditions

Stop and ask when:

- consent or marketing eligibility would be inferred outside the central ledger;
- a product needs a Postmark or Resend token, or would send raw HTML;
- a migration would send the same message through two producers;
- an exception is requested without a recorded operator decision;
- a DNS, recipient, credential, webhook or send change lacks bounded authorization.
