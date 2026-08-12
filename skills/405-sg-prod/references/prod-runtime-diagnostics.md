---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 405-sg-prod
scope: prod-runtime-diagnostics
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
next_step: "/103-sg-verify prod runtime diagnostics"
---

# Production Runtime Diagnostics

Collect provider build logs through pagination until stable or a bounded ceiling (normally 5,000 lines or 10 calls). Mark incomplete collection explicitly; never conclude a root cause from a truncated tail. Filter errors, file positions, warnings, deprecations, and missing-environment signals, then report the first causal error with a small redacted context and classification.

Use Sentry only from issue/event/monitor/alert pointers supplied or already visible. Match release/environment when possible. A Monitor proves detection; an Alert proves routing. Do not imply dashboard access. Without a pointer, use bounded PM2 logs or Doppler configuration/presence checks where available; report secret names only when necessary and never values.

For Blacksmith jobs, use run history and searchable logs first, metrics before recommending larger runners, and SSH only for a live/retained job and read-only diagnosis. Never dump the environment. If retention is needed, recommend a failure-only bounded keepalive and disclose runner cost; do not add it without authorization.

Runtime evidence supports deployment truth but does not replace browser, auth, manual QA, or verification owners.
