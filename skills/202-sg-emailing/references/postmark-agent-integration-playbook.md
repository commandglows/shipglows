---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-05"
updated: "2026-09-05"
status: active
source_skill: 202-sg-emailing
scope: postmark-agent-integration
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems: ["Postmark","Convex"]
depends_on: []
supersedes: []
evidence:
  - "Approved Core plan: central identity, consent, access and email agent training, September 5, 2026."
next_review: "2026-10-05"
next_step: Revalidate project configuration and current official provider behavior before integration.
---

# Postmark Agent Integration

Use for Postmark setup, API adapters, delivery diagnosis or provider operations.
Inspect the current callable tools and project binding first. A documented
integration does not prove a connected account, an approved sender or live mail.
Preserve declared credentials and environments; never ask for a token in chat.

## Configuration contract

Record actual server ID and Sandbox/Live mode, server-token variable name,
verified sender/domain, explicit transactional and broadcast stream IDs,
HTTPS webhook/preference origin and scoped operator authority. Query actual
server/stream state before dispatch; reject mismatched environment, archived
streams, wrong types or unauthorized business bindings. Do not guess a server
from a URL or rely on the default outbound stream.

Use the server token for sending; account-management authority is distinct.
Keep tokens server-only, per environment, and out of browser bundles, logs and
shared configuration examples. Bounded approval is required for real sends,
recipients, DNS, webhooks and credential changes; code work alone does not authorize them.

## Send adapter and outbox

Persist the canonical job/attempt before HTTP. Submit From, To, Subject, HtmlBody,
TextBody, explicit MessageStream and non-sensitive correlation metadata to
POST /email with X-Postmark-Server-Token. In this central pattern disable opens
and link tracking unless separately approved. Parse ErrorCode and MessageID;
an HTTP 200 alone is not a successful submission.

Postmark does not support send idempotency keys. A timeout, lost receipt or
ambiguous server failure is unknown, not permission to resend. Reconcile provider
evidence and authenticated callbacks first. Retry only failures proved not
accepted, with bounded backoff. A duplicate API request must reuse the internal
command key; that key cannot deduplicate an already accepted external send.

Recheck marketing consent for marketing jobs and applicable delivery suppression
for all jobs before dispatch. Legitimate service-triggered transactional mail
does not require newsletter opt-in. Send one isolated
recipient per canonical job unless an approved batching contract preserves that
isolation and partial-result recovery. Never expose recipients through shared To/CC.

## Streams, unsubscribe and events

Separate transactional service mail from marketing Broadcast streams. Keep an
explicit business/purpose-to-server/stream mapping: provider suppression is
stream-scoped, so independent unsubscribe promises need isolated streams or an
explicitly approved shared suppression scope. Test the same address across two
independently scoped brands; never silently reuse one Broadcast stream for both.
Use
Postmark-managed unsubscribe for the central default, with its template placeholder
and native headers, and reconcile SubscriptionChange into canonical consent.
Custom management requires current provider requirements and explicit approval;
a hand-written footer link is not proof of complete unsubscribe handling.

Authenticate webhooks before processing (HTTPS plus configured Basic auth or
secret headers); do not invent a native signature verification scheme. Bind
the route/credential to server, stream, business and environment. Store normalized
events only. Deduplicate by event type and provider event identity; MessageID
alone is insufficient, and SubscriptionChange may have no MessageID. Preserve
out-of-order suppression precedence; delivery never restores marketing consent.

Verify enabled webhook event types using the current Webhooks API and an authorized
endpoint. Saving a URL alone is not activation proof. Check per-event verified/paused
state and reverify after repair. Redact API responses containing HttpAuth/HttpHeaders.
Use X-PM-Webhook-Trace-Id for retry correlation when supplied, scoped to the
authenticated binding, with a typed semantic fallback for missing IDs.
Current retry/drop behavior must be checked before designing response codes;
an invalid callback must never be acknowledged as durably ingested.

## Proof ladder and migration

1. Local fake transport: schema, auth failures, duplicates, wrong streams,
   unknown submission, withdrawals and late events.
2. Actual Sandbox Server: accepted submission plus provider events. Sandbox
   Delivered is simulated; it does not prove an inbox receipt or client rendering.
   POSTMARK_API_TEST is weaker request validation, not hosted lifecycle proof.
3. Authorized Live recipient: receipt, HTML/text/client rendering, headers,
   unsubscribe propagation and blocked subsequent marketing.
4. Production activation: exact environment, sender/domain, recipient scope,
   monitoring, rollback and approval evidence.

Keep legacy Resend flows until consent/suppression/import parity and migration
authority are explicit. Avoid dual sending and double subscription side effects.
Provider acceptance, delivery and inbox rendering are separate report fields.

## Official sources checked 2026-09-05

- [Email API](https://postmarkapp.com/developer/api/email-api)
- [Server API](https://postmarkapp.com/developer/api/server-api)
- [Message streams](https://postmarkapp.com/developer/api/message-streams-api)
- [Send idempotency](https://postmarkapp.com/support/article/what-is-an-idempotency-key)
- [Webhooks overview](https://postmarkapp.com/developer/webhooks/webhooks-overview)
- [Webhooks API](https://postmarkapp.com/developer/api/webhooks-api)
- [Subscription changes](https://postmarkapp.com/developer/webhooks/subscription-change-webhook)
- [Sandbox Server](https://postmarkapp.com/developer/user-guide/sandbox-mode/server-sandbox-mode)
- [Unsubscribe headers](https://postmarkapp.com/support/article/1299-how-to-include-a-list-unsubscribe-header)
- [Custom unsubscribe](https://postmarkapp.com/support/article/managing-your-own-unsubscribe-process)

Refresh provider-sensitive details before actual setup or changed API behavior.
These sources support provider facts; central ownership and approval rules are
ShipGlows policy. This leaf does not load other leaves.
