---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-03"
updated: "2026-08-03"
status: active
source_skill: 600-sg-local-cloud-sync
scope: post-auth-sync-orchestration
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems: [skills/600-sg-local-cloud-sync/SKILL.md]
depends_on: []
supersedes: []
evidence: ["Post-auth orchestrator extraction."]
next_step: "/103-sg-verify compact monolithic skill references"
---

# Post-Auth Sync Orchestration

Follow `local-cloud-sync-doctrine.md` for every decision. Begin guidance, identify authenticated and remembered account, block unsafe reuse, fetch one logical cloud snapshot, then hydrate/merge/seed according to the domain contract. Anonymous or remembered same-account local data may seed an empty cloud only under explicit policy; a different remembered account clears unsafe queue and cloud-backed local state before applying cloud authority.

Apply snapshots through domain-owned APIs (`replaceFromCloud`, `seedCloud`, `clearLocal`), not scattered storage keys. One post-auth finalizer owns guidance, hydration/seed decision, reload and failure reset; UI callers never duplicate it.
