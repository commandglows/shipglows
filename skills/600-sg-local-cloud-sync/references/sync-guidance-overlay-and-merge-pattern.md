---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-06-12"
updated: "2026-08-03"
status: active
source_skill: 600-sg-local-cloud-sync
scope: sync-guidance-overlay-index
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems: [skills/600-sg-local-cloud-sync/SKILL.md]
depends_on: []
supersedes: []
evidence: ["Former sync pattern split by UI, orchestration, queue and proof decisions."]
next_step: "/103-sg-verify compact monolithic skill references"
---

# Sync Guidance Overlay Index

| Need | Load direct reference |
| --- | --- |
| Visual feedback, stages, copy, accessibility | `sync-guidance-overlay-ui.md` |
| Post-auth snapshot, association, hydrate/seed/apply/finalize | `post-auth-sync-orchestration.md` |
| Remote validation and durable queue | `sync-queue-and-payload-safety.md` |
| Recovery, proof, provider and documentation gates | `sync-guidance-proof-and-docs.md` |

`local-cloud-sync-doctrine.md` remains the authority for data/merge decisions; `ux-security-checklist.md` remains the authority for UX/security. Never reconstruct either from this index.
