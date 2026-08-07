---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-07"
updated: "2026-08-07"
status: active
source_skill: 202-sg-emailing
scope: email-deliverability-and-authentication
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/202-sg-emailing/SKILL.md
  - skills/202-sg-emailing/references/accessible-email-technical-playbook.md
  - skills/202-sg-emailing/references/resend-agent-integration-playbook.md
  - skills/references/documentation-freshness-gate.md
depends_on: []
supersedes: []
evidence:
  - "RFC 9989, Domain-based Message Authentication, Reporting, and Conformance (DMARC): https://www.rfc-editor.org/rfc/rfc9989.html"
  - "RFC 9990, DMARC Aggregate Reporting: https://www.rfc-editor.org/rfc/rfc9990.html"
  - "RFC 9991, DMARC Failure Reporting: https://www.rfc-editor.org/rfc/rfc9991.html"
  - "Resend, The New DMARC is Here, 2026-07-17: https://resend.com/blog/the-new-dmarc-is-here"
next_review: "2027-02-07"
next_step: "/103-sg-verify email deliverability and authentication"
---

# Email Deliverability And Authentication Playbook

## Purpose

Define a provider-neutral setup and rollout contract for sending identity,
authentication, reputation, compliance, and deliverability. This playbook does
not own message copy or accessible markup; load the writing and technical email
playbooks for those concerns.

DNS, domain policy, contact suppression, and production sends are external
state changes. Inspect and propose safely, but require explicit operator
authorization before mutating them.

## Freshness And Authority

Apply `skills/references/documentation-freshness-gate.md` before changing a
provider integration, DNS record, authentication policy, webhook, or sending
configuration.

Use this source order:

1. current IETF/RFC specification for protocol semantics
2. current official sender/provider documentation for implementation details
3. local DNS, sending-domain, application, and provider configuration
4. observed provider verification, headers, reports, and delivery events

The 2026 DMARC standards are split across [RFC 9989](https://www.rfc-editor.org/rfc/rfc9989.html),
[RFC 9990](https://www.rfc-editor.org/rfc/rfc9990.html), and
[RFC 9991](https://www.rfc-editor.org/rfc/rfc9991.html). Keep the
[Resend explanation](https://resend.com/blog/the-new-dmarc-is-here) as a
practical secondary reference, not protocol authority.

## Sending Identity Inventory

Before editing DNS or sending:

- identify every visible `From`, envelope sender/return path, DKIM signing
  domain, sending subdomain, provider, application, automation, and third-party
  sender
- classify transactional, lifecycle, broadcast, support, and machine-generated
  mail separately
- record the owner and purpose of each legitimate source
- confirm consent basis, suppression/unsubscribe behavior, retention, and
  complaint handling for each mail class
- preserve an emergency rollback path and access owner for DNS/provider changes

Do not tighten policy while an unexplained legitimate source remains.

## Authentication Baseline

- Publish SPF narrowly for actual envelope-sending infrastructure. Avoid
  duplicate SPF records and uncontrolled include chains.
- Enable DKIM with provider-supported strong keys, document selector ownership,
  and plan rotation without invalidating active mail unexpectedly.
- Align the visible `From` domain with authenticated SPF or DKIM identifiers as
  required by DMARC. Prefer DKIM alignment for durable multi-provider setups.
- Separate product streams with subdomains when ownership, reputation, risk, or
  rollback needs differ; do not fragment domains without an operational reason.
- Verify records through authoritative DNS and the provider, then inspect a
  received message's authentication results. Dashboard green states alone are
  not end-to-end proof.

## DMARC 2026 Contract

RFC 9989 replaces Public Suffix List dependency with bounded DNS Tree Walk
discovery and moves DMARC to the Internet Standards Track. For new or reviewed
records:

- treat `pct` as historic; do not use fractional enforcement as rollout control
- use monitoring and the current policy/testing semantics supported by the
  receivers and provider rather than assuming every receiver adopts new RFC
  behavior immediately
- consider `np=reject` only after confirming which non-existent subdomains must
  stay non-existent and that no legitimate dynamic sender depends on them
- reserve `psd` decisions for public-suffix or organizational-boundary cases;
  most ordinary senders should not add it casually
- keep `rua` aggregate reporting; treat `ruf` failure reports as sensitive and
  assess privacy, availability, and recipient authorization before enabling
- do not depend on removed `rf` or `ri` controls

Existing records are not automatically wrong because a new standard exists.
Evaluate receiver adoption, current provider guidance, and observed reports
before migration.

## Safe Enforcement Rollout

1. Inventory all legitimate sources and owners.
2. Establish SPF and DKIM, then prove alignment on received messages.
3. Publish monitoring policy and collect enough representative aggregate data.
4. Resolve unknown, misaligned, forwarded, and intermittent sources.
5. Advance deliberately to quarantine, then reject, with an operator-approved
   observation window, rollback condition, and incident owner.
6. Continue report review after enforcement; policy completion is not the end
   of deliverability operations.

Never promise an exact observation duration without traffic volume, sending
cadence, risk, and receiver coverage. Never rush to `reject` from a provider
dashboard alone.

## Deliverability Operations

- require explicit consent and truthful sender identity
- provide functional unsubscribe/preference handling where applicable and
  suppress opt-outs, complaints, and hard bounces promptly
- avoid purchased, scraped, or unverified lists and deceptive engagement tactics
- monitor delivery, bounce, complaint, deferral, block, and unsubscribe events
  by stream and provider
- verify webhook signatures, retries, idempotency, event ordering assumptions,
  redaction, and retention before relying on event automation
- warm or migrate traffic gradually when domain, provider, IP, or volume changes
- investigate content, authentication, reputation, and receiver-specific causes
  before attributing a delivery failure to one dimension

## Release Evidence

Record without secrets or recipient data:

- sending domain/subdomain and mail class
- redacted SPF, DKIM selector, and DMARC policy summary
- provider verification state and timestamp
- sampled authentication-result verdicts
- aggregate-report coverage window and unexplained-source status
- suppression, complaint, bounce, and unsubscribe test results
- rollout stage, accepted limitations, rollback trigger, and owner

## Validation

```bash
python3 tools/shipglows_metadata_lint.py skills/202-sg-emailing/references/email-deliverability-and-authentication-playbook.md
rg -n "RFC 9989|RFC 9990|RFC 9991|SPF|DKIM|DMARC|pct|np=reject|rua|authorization|Release Evidence" skills/202-sg-emailing/references/email-deliverability-and-authentication-playbook.md
```
