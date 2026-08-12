---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-06-01"
updated: "2026-08-12"
status: active
source_skill: 600-sg-local-cloud-sync
scope: local-cloud-sync-doctrine
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/600-sg-local-cloud-sync/SKILL.md
depends_on:
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Extracted from WinFlowz local-to-cloud promotion and merge chantier."
  - "Wave 8 preserved the account, merge, conflict, tombstone, and queue doctrine behind a conditional loader."
next_step: none
---

# Local-Cloud Sync Doctrine

## Purpose

Use this reference when a project lets users create local data before account-backed cloud sync exists. The goal is to protect user work, tenant boundaries, privacy, and product trust.

## Required Domain Inventory

For every data domain, record:

- domain name and user value
- local source and durability level
- cloud source and authority level
- business key and stable record identity
- `updatedAt`, device/source metadata, and checksum availability
- create/update/delete semantics
- sensitive-data classification
- conflict tolerance
- offline behavior
- retention and export/import expectations

## Account Association Matrix

| State | Default decision | Reason |
| --- | --- | --- |
| Anonymous local data plus sign-up flow, cloud empty | Promote or seed cloud after auth and entitlement are valid | Same user flow created both local data and account. |
| Anonymous local data plus existing-account sign-in, cloud empty | Ask for explicit import/seed confirmation | Empty cloud does not prove ownership of local data. |
| Local metadata remembers same account, cloud empty | Promote local data | Prior association reduces replay risk. |
| Local metadata remembers different account | Block automatic promotion | Prevent cross-account replay. |
| Local empty, cloud non-empty | Hydrate local from cloud | Supports reinstall/relogin recovery. |
| Local non-empty and cloud non-empty | Merge or conflict based on per-domain policy | Preserves both sides unless deterministic resolution exists. |
| Provider/auth unavailable | Stay local-only or pending | Do not fake sync state. |

## Merge Decision Matrix

| Local | Cloud | Decision |
| --- | --- | --- |
| Same key, same checksum | Mark synced |
| Disjoint keys | Merge both ways if domain allows |
| Same key, different payload, reliable metadata | Apply domain conflict policy; latest-wins only if allowed |
| Same key, different payload, unreliable metadata | Conflict |
| Local tombstone, cloud record | Delete or conflict according to tombstone policy |
| Cloud tombstone, local record | Delete or conflict according to tombstone policy |
| Local-only/non-promotable domain | Keep local and show local-only state |

## Conflict Policy Requirements

A conflict policy must name:

- conflict key
- winning rule or manual resolution route
- required metadata
- stale clock behavior
- duplicate write behavior
- retry behavior
- user-facing state
- audit/logging needs without sensitive payload leakage

Latest-wins is not a default. It is acceptable only when `updatedAt` is durable, monotonic enough for the domain, tied to a device/source identity, and tested against stale or missing metadata.

## Tombstones

Delete-capable domains need one of:

- durable tombstones with retention
- server-authoritative deletes with audit trail
- local-only deletes with clear non-sync behavior
- explicit unsupported-delete decision

Never rely on "missing from latest snapshot" as the only delete signal when multiple devices or offline writes are possible.

## Offline Queue

Queued changes should include:

- operation ID
- account/user ID or explicit unassociated marker
- domain and business key
- operation type
- payload checksum or redacted summary
- created/updated timestamps
- retry count and last error
- idempotency key when a remote write may be retried

Queue replay must re-check auth, entitlement, account association, and domain policy before writing remote data.
