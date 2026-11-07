---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-06-01"
updated: "2026-11-07"
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
  - "2026-11-07: last synced base added after CommandGlows brought deleted snippets back; rule and shared cases in shipglows-app-engine, audit in its shipglows_data/technical/sync-deletions-audit.md."
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

## Tombstones and deletions

Delete-capable domains need one of:

- last synced base (below)
- durable tombstones with retention longer than the longest absence of a device
- server-authoritative deletes with audit trail
- local-only deletes with clear non-sync behavior
- explicit unsupported-delete decision

Never rely on "missing from latest snapshot" as the only delete signal when multiple devices or offline writes are possible.

### Last synced base

A three-way comparison: the device, the account, and what both held after the last completed sync. It needs no server change, no timestamp and no retention window, so it fits any backend exposing a list of current records. A record missing on one side was deleted there if the base holds it unchanged; a value changed on one side only wins without a conflict. Shared code: `reconcileSnapshots(device, account, base:)` in the Dart `shipglows_sync_core`, `reconcileRecords` in `@shipglows/sync/reconcile`, both checked by the same cases.

Conditions, each one a real way to lose data:

- Read the account only from a successful, authenticated, complete query. An error returned as an empty list, or a list capped at N rows, reads as a deletion of everything else. Give the sync its own uncapped query.
- Scope the base per account and deployment, and keep it in the same durable storage as the device copy, so both are lost together.
- A device holding nothing while its base does has lost its copy: restore it, never propagate. The price: deleting everything while offline comes back. If the copy can only be lost whole, count an existing empty list as held (one section with a marker), so deleting the last record travels.
- If a record can leave the device without being deleted (a local cap, a filter), a missing record proves nothing: read local deletions from explicit tombstones, and never store deleted text in them.
- Save the base last, and remove applied deletions from it as soon as they are applied, so a later failed step cannot make a record created again read as deleted.
- Without a base (first sync), keep the union: nothing is read as deleted, at worst a deleted record returns once.
- After a sync changes the device copy, in-memory state must be read again: writing old state back reads as a deletion.

Use stamps and tombstones instead when the backend stores metadata with the records and more than two copies merge directly.

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
