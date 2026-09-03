---
artifact: launch_protection
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "[project name]"
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
status: active
source_skill: sg-development
scope: prelaunch-public-surface
owner: "[owner]"
confidence: medium
risk_level: high
security_impact: yes
docs_impact: yes
public_surface: none
public_url: none
protection_status: not_applicable
email_capture_status: inactive
email_provider: none
last_verified_at: none
release_condition: "Explicit launch decision followed by protection removal and public-route verification."
handoff_reference: none
evidence: []
depends_on: []
supersedes: []
next_review: "YYYY-MM-DD"
next_step: "Review public exposure before launch."
---

# Launch Protection

Allowed protection states: `not_applicable`, `protected`, `unprotected`,
`unverified`. Allowed email states: `inactive`, `configured`, `verified`.
Only hosted evidence permits `verified`.
