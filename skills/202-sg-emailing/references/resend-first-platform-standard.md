---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-18"
updated: "2026-10-27"
status: superseded
superseded_by: "skills/202-sg-emailing/references/postmark-first-platform-standard.md"
source_skill: 202-sg-emailing
scope: resend-first-email-platform-standard
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/202-sg-emailing/SKILL.md
  - skills/references/email-work-routing.md
  - skills/202-sg-emailing/references/resend-agent-integration-playbook.md
  - skills/202-sg-emailing/references/email-deliverability-and-authentication-playbook.md
depends_on: []
supersedes: []
evidence:
  - "Resend pricing and product split, checked 2026-08-18: https://resend.com/docs/knowledge-base/what-is-resend-pricing"
  - "Resend contacts, segments, and topics, checked 2026-08-18: https://resend.com/docs/dashboard/audiences/introduction"
  - "Resend event-driven automations, checked 2026-08-18: https://resend.com/docs/dashboard/automations/introduction"
  - "Resend region and US account-data residency, checked 2026-08-18: https://resend.com/docs/dashboard/domains/regions"
  - "Beehiiv plans and automation/API boundaries, checked 2026-08-18: https://www.beehiiv.com/pricing"
  - "Ghost newsletter capability and pricing, checked 2026-08-18: https://ghost.org/pricing"
  - "Loops plans and transactional/marketing scope, checked 2026-08-18: https://loops.so/pricing"
  - "Emailit pricing and beta automation status, checked 2026-08-18: https://emailit.com/pricing/"
  - "Inbound programmable send/receive/threading scope, checked 2026-08-18: https://inbound.new/"
next_review: "2026-11-18"
next_step: "/103-sg-verify Resend-first provider standard"
---

# Resend-first Email Platform Standard

> **Superseded on 2026-10-27.** The operator decided that Postmark becomes the portfolio-wide email transport and that all product email goes through the central CommandGlows email service. The current standard is `postmark-first-platform-standard.md` in this folder; use it for every provider or routing decision. Resend is now a legacy flow to migrate under that standard's rules. The text below is kept as history: it describes the superseded Resend-first position and is not active policy, and its exception matrix does not open any exception today.

## Purpose

Define the default provider and reusable architecture for ShipGlows-managed products that need transactional email, newsletters, educational sequences, or product lifecycle automation. This is a recommendation contract, not standing authority to create provider objects, change DNS, import contacts, send mail, or enable automations.

## Default Decision

Recommend **Resend-first** when a product needs any meaningful combination of:

- transactional messages from application events;
- newsletters or broadcasts;
- welcome, onboarding, educational, recovery, or retention sequences;
- contacts, properties, segments, or user-facing topic preferences;
- code-, API-, CLI-, or agent-managed templates and workflows.

Resend is the shared execution provider, not the customer or consent source of truth. Keep customer identity, consent evidence, entitlement state, and business events in the project's governed data layer. Project Resend contacts, topics, segments, broadcasts, templates, and automation runs from that authority.

## Architecture Invariants

### Local authority

- Store the current subscription projection and append-only consent evidence locally.
- Record topic, brand/project, language, source, consent wording version, action, time, and idempotency key.
- Treat provider state as a **provider projection** with explicit pending, synced, or failed status.
- Prevent delayed provider results from overwriting a newer user decision.
- Keep canonical event names, template source, sequence intent, and stop rules versioned outside the provider dashboard.

### Transactional and marketing separation

- **Transactional** email serves an account, security, purchase, payment, entitlement, refund, access, or explicitly requested product operation.
- **Marketing** email includes newsletters, optional education, launches, promotions, recommendations, and nurture.
- A purchase, account, payment, entitlement, trial, download, or product event never creates explicit marketing consent.
- Marketing begins only from explicit marketing consent for the exact topic or promise.
- Marketing unsubscribe does not suppress strictly necessary transactional email, but bounces and complaints remain operational suppression signals.

### Portfolio topology

- Use one provider organization only for products under the same legal/data controller and access authority; use a separate organization when ownership, controller, saleability, permissions, or privacy posture differs.
- Use separate credentials for every project and environment, with the smallest available scope.
- Use a distinct visible sending identity and topic for each brand promise. The same address may subscribe to several topics, but consent never spreads between them.
- Separate transactional and marketing sending subdomains when reputation, rollback, ownership, or operational risk justifies it.
- Use Broadcasts for newsletters, Automations for event-driven sequences, and the Emails API for strictly transactional delivery.

## Exception Matrix

| Provider | Use instead of, or beside, Resend when | Do not select it as the default when |
| --- | --- | --- |
| **Beehiiv** | The newsletter is itself a media product and native recommendations, referrals, advertising, paid publication, or creator growth is central. | The main need is application transactionals, entitlement/payment events, or locally owned product journeys. |
| **Ghost** | The decision also replaces the site/CMS with a publication, membership, or paid-content platform and EU storage or self-hosting matters. | Existing product sites and content architecture should remain authoritative, or complex event sequences are required. |
| **Loops** | A SaaS team prioritizes a visual lifecycle editor and non-developer operations enough to accept another platform model. | Code/agent-managed automation definitions, existing Resend integration, or maximum provider portability is the stronger constraint. |
| **Inbound** | Agents or products need programmable inbound mailboxes, replies, and thread preservation. | The primary need is newsletter publishing, audience growth, or outbound lifecycle automation. |
| **Emailit** | Extreme send-cost efficiency is decisive and current automation, deliverability, support, data, and migration proof passes a bounded evaluation. | Core lifecycle behavior still depends on beta automation or the smaller operational track record creates unacceptable risk. |
| **Substack** | A creator deliberately chooses the Substack network and hosted paid-publication model as the product. | The requirement is multi-project infrastructure, transactionals, governed application events, owned-site continuity, or provider-neutral automation. |

An exception is product-scoped. It does not silently replace the portfolio standard for other projects. A hybrid such as Resend transactionals plus Beehiiv media publishing is valid only when its growth value exceeds contact synchronization and operational maintenance.

## Events And Sequences

Prefer stable business events over provider-shaped calls. A practical starting vocabulary is:

- `user.created`
- `newsletter.subscribed`
- `newsletter.unsubscribed`
- `purchase.completed`
- `payment.failed`
- `purchase.refunded`
- `entitlement.granted`
- `entitlement.revoked`
- `course.lesson.completed`

Every sequence records trigger, audience, objective, cadence, CTA, topic, stop events, and exit behavior. Refund, revocation, unsubscribe, completion, or conversion must stop any sequence that would become misleading or unwanted.

## Privacy, Residency, And Deliverability

- Resend can dispatch from Ireland, but its account data, metadata, logs, and API records remain stored in the United States. Surface that fact whenever strict data residency or transfer posture can change the decision.
- Complete the project's controller/processor records, DPA review, retention policy, lawful-basis analysis, and consent copy before production use.
- Never put addresses, tokens, message bodies, or recipient-level activity into public governance artifacts.
- Load the deliverability playbook for SPF, DKIM, DMARC, complaint, bounce, suppression, webhook, reputation, warmup, or migration work.
- Keep provider-managed one-click unsubscribe and locally governed topic preference state aligned without relying on a dashboard alone.

## Freshness Gate

Provider features, plans, pricing, limits, automation steps, API shape, data processing, and residency can change. Before a provider decision, dependency change, provider setup, migration, or production claim:

1. inspect current official documentation and the locally installed SDK/version;
2. record the dated capability and material limitation that changes the decision;
3. prefer protocol authority for authentication/deliverability and provider authority for product behavior;
4. treat marketing pages and changelogs as current evidence, not permanent contracts;
5. stop when current evidence contradicts this standard or a project requirement.

Do not hardcode a current price into durable architecture unless cost itself is a governed acceptance constraint with a dated review.

## Implementation And Proof

The smallest reusable implementation includes:

- a provider-neutral consent ledger and event vocabulary;
- one provider adapter per project/runtime rather than scattered SDK calls;
- idempotent contact/topic projection and email sends;
- versioned templates with HTML and plain text;
- opaque, topic-scoped preference links;
- event/automation definitions kept locally and created disabled first;
- redacted webhook handling for delivery, bounce, complaint, and unsubscribe reconciliation;
- separate development, staging, and production credentials and domains.

Local tests prove source behavior only. Before production activation, obtain bounded authorization and prove DNS authentication, received headers, representative client rendering, controlled recipient delivery, topic preference behavior, suppression, webhook signature/idempotency, automation stop conditions, monitoring, and rollback.

## Stop Conditions

Stop the decision or implementation when:

- legal/data controller, audience promise, marketing consent, data residency, or ownership is unresolved;
- one provider organization would cross incompatible permission or privacy boundaries;
- a purchase or entitlement is being treated as marketing opt-in;
- a provider-only dashboard would become the sole consent authority;
- current official provider evidence no longer supports the required feature or risk posture;
- provider, DNS, recipient, send, credential, billing, or production mutation lacks explicit bounded authorization.

## Pressure Scenarios

- `RESEND-FIRST-SAAS`: transactionals, newsletters, and event sequences resolve to one Resend-first execution layer plus a local authority.
- `RESEND-FIRST-MEDIA-EXCEPTION`: a newsletter-first media business receives a Beehiiv/Ghost/Substack comparison rather than an automatic infrastructure answer.
- `RESEND-FIRST-NO-BUYER-OPTIN`: payment and entitlement events never change a marketing topic to subscribed.
- `RESEND-FIRST-CROSS-PROJECT`: subscribing to one project never opts the address into another project.
- `RESEND-FIRST-US-RESIDENCY`: Ireland sending is never reported as EU account-data residency.
- `RESEND-FIRST-PORTABILITY`: templates, events, intent, and consent evidence survive a provider migration even if automation runs do not.

