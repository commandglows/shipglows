---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-03"
updated: "2026-08-03"
status: active
source_skill: 600-sg-local-cloud-sync
scope: sync-queue-and-payload-safety
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems: [skills/600-sg-local-cloud-sync/SKILL.md]
depends_on: []
supersedes: []
evidence: ["Queue and validation extraction."]
next_step: "/103-sg-verify compact monolithic skill references"
---

# Sync Queue And Payload Safety

Validate remote data before stores: bounded ids/URLs/enums/numbers, deduplicated capped arrays and dropped malformed records. The queue has stable keys, revision/attempt metadata, idempotent mutation or idempotency key, safe log redaction and account/auth/entitlement recheck. Coalesce settings changes. Flush only with configured provider, valid auth and network; failed operations remain with bounded retry, while account mismatch clears unsafe replay. The queue is not cross-account import.
