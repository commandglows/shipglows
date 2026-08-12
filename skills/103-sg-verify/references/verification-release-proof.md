---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 103-sg-verify
scope: 103-sg-verify-release-proof
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems: [skills/103-sg-verify/SKILL.md]
depends_on: []
supersedes: []
evidence: ["Wave 17 moved conditional bug and manual proof from the mandatory baseline."]
next_step: "/103-sg-verify progressive lifecycle activation compaction wave 17"
---

# Verification Release Proof

Load directly when bugs or manual checklist rows are in scope. This leaf loads no sibling.

Bug truth is `shipglows_data/workflow/bugs/*.md`; an aggregate index is secondary. Any open high/critical in-scope bug blocks ship. Required manual rows must pass, have an accepted exception, or transition to stronger recorded proof. Otherwise `NOT_RUN`, `FAIL`, or `BLOCKED` yields `partial` or `not verified`.
