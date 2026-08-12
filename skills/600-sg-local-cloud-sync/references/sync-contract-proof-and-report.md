---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 600-sg-local-cloud-sync
scope: sync-contract-proof-and-report
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/600-sg-local-cloud-sync/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Wave 8 extracted contract formatting, proof ladder, and documentation impact."
next_step: none
---

# Sync Contract, Proof, and Report

Record domains, local durability, remote authority, account association, promotion/hydration triggers, merge/conflict/delete policy, offline queue, sensitive-data/secrets policy, UX states, retry, tenant boundary, observability, proof, docs impact, and implementation route.

Use scenario-first for advice, test-first for pure merge/queue logic, regression-first for loss or replay bugs, evidence-first for UI/provider proof, and an explicit exception only when a proof surface is unavailable. Progress from domain/controller and adapter tests through UI/browser/auth/provider proof; require device/manual proof only for native storage, permissions, lifecycle, offline, or reinstall/relogin behavior.

Report both `Documentation Update Plan` and `Editorial Update Plan` as complete, no impact, or blocked. Check architecture, data/security/privacy/support/onboarding docs, QA, changelog/release notes, public claims, pricing, screenshots, and wording such as backup, sync, saved, cloud, import/export, and recovery.

Never turn an incomplete contract into source edits. Report the observed proof limit and the next owner.
