---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-03"
updated: "2026-08-03"
status: active
source_skill: 600-sg-local-cloud-sync
scope: sync-guidance-overlay-ui
owner: Diane
confidence: high
risk_level: medium
security_impact: no
docs_impact: yes
linked_systems: [skills/600-sg-local-cloud-sync/SKILL.md, skills/006-sg-design/SKILL.md]
depends_on: []
supersedes: []
evidence: ["UI/stage extraction from SocialGlowz pattern."]
next_step: "/103-sg-verify compact monolithic skill references"
---

# Sync Guidance Overlay UI

Use a visible post-auth modal for real operations: `waitingServer`, `dataReceived`, `dataApplied`, `restarting`, then short `ready` confirmation. A stage completes only after its operation. The state machine is re-entrant safe, has readable dwell, reset/recovery behavior and a reload-surviving ready notice; it never contains raw sync payloads.

Render blocking/success mode, visible stage labels, labelled step list, token-based visual treatment, dark/mobile support, modal semantics and polite updates. It is operational guidance, not marketing. Copy identifies what data class moves, what remains local, restart expectation and next action; it never says synced/backup before durable proof.
