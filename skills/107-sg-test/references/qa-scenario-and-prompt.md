---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 107-sg-test
scope: qa-scenario-and-prompt
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/107-sg-test/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Wave 7 extracted scenario selection and the human prompt."
next_step: none
---

# QA Scenario and Prompt

Select only scenarios material to the contract: happy path, error/recovery, primary boundary, integration/auth/data risk, and platform-specific behavior. For Flutter, use widget tests then Flutter Web smoke before native device proof unless permissions/plugins/platform channels require the device.

Production remains non-destructive. Never ask the operator to use real payment, irreversible deletion, real outbound email, or unsafe customer data when a sandbox/reversible alternative exists.

Present one focused card:

```text
## Manual Test: <flow>
Environment: <local|preview|production|device>
Preconditions: <safe setup>
Steps:
1. <action>
2. <action>
Expected success: <observable result>
Expected failure/recovery: <observable safe behavior>
Reply: pass | fail: <observed> | blocked: <reason> | not run
```

Do not interpret silence as pass. Preserve the operator's wording as evidence, compactly and safely.
