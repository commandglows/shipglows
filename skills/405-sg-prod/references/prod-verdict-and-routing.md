---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 405-sg-prod
scope: prod-verdict-routing
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems: [skills/405-sg-prod/SKILL.md]
depends_on: []
supersedes: []
evidence: ["Extracted from production-verification-workflow.md during Wave 16 compaction."]
next_review: "2026-09-12"
next_step: "/103-sg-verify prod verdict"
---

# Production Verdict And Routing

Report project, intended and observed commit/branch, development mode, provider and evidence source, deployment state and time, deployment/final URL, health result, log completeness, causal errors/warnings, runtime evidence, confidence, and `Hypotheses / remaining risks`.

Use precise verdicts: `ready` only for the bounded production surfaces actually proved; `failed` for terminal deploy or runtime failure; `pending` while provider work remains active; `partial` for missing matching, logs, health, or downstream flow proof; `blocked` when required access/target/evidence cannot safely be obtained.

On failure, offer routes to `106-sg-fix`, `105-sg-check`, or an explicit rollback decision. Never repair, push, rollback, ignore a failure, or mutate production automatically. A successful deploy routes remaining non-auth, auth, manual, or lifecycle proof to its owner with scenario and target. Always retain a dashboard/log pointer when safely available and redact sensitive identifiers.
