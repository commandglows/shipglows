---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-06-01"
updated: "2026-06-01"
status: draft
source_skill: 600-sg-local-cloud-sync
scope: sync-ux-security-checklist
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/600-sg-local-cloud-sync/SKILL.md
depends_on:
  - artifact: "skills/references/spec-driven-development-discipline.md"
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "Extracted from WinFlowz sync/save status and secrets-policy decisions."
next_step: "/103-sg-verify shipglows_data/workflow/specs/600-sg-local-cloud-sync-skill.md"
---

# Sync UX And Security Checklist

## UX States

Expose user-facing state when it changes user trust or next action:

- local-only
- saving locally
- saved locally
- sync pending
- syncing
- synced
- retrying
- conflict
- blocked by sign-in, entitlement, provider config, or account mismatch
- error with retry/recheck action

Settings save and data sync may share visual language, but their semantics must stay distinct: "saved locally" is not "synced to cloud."

## Refresh And Retry

The shared sync/status component should support:

- manual refresh/recheck
- retry after transient error
- visible loading state
- visible success state
- visible error state with next action
- accessible labels/tooltips
- no infinite spinner without timeout or fallback state

Clicking the component may re-run refresh/sync only if the operation is idempotent or guarded against duplicate writes.

## Sensitive Data Policy

Default exclusions:

- secrets
- tokens
- credentials
- private keys
- recovery phrases
- raw payment data
- OS permission grants
- private logs
- full clipboard contents likely to be passwords, API keys, or one-time codes

Syncing any excluded class requires a separate explicit spec with encryption, key management, recovery, threat model, and user consent.

## Tenant And Account Boundary

Check:

- auth identity source
- entitlement source
- local metadata account ID
- remote tenant/user/org path
- provider-side security rules or server authorization
- import/export boundaries
- support/admin access assumptions

Never treat a visible account email or UI route as sufficient authorization.

## Logging And Observability

Log enough to debug state transitions without leaking payloads:

- domain name
- operation type
- redacted record count
- checksum or operation ID
- error class
- retry count
- account/tenant ID only if redacted or safe under project policy

Never log raw secrets, clipboard payloads, tokens, credentials, private keys, private user text, or full sync snapshots.

## Abuse And Availability

Consider:

- max payload size
- max records per promotion
- max queued operations
- retry backoff
- idempotency
- duplicate submission
- rate limits
- provider quota failure
- clock skew
- partial outage
- rollback or pending state after partial success
