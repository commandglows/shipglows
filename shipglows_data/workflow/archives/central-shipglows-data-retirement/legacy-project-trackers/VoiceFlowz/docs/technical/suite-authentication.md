---
artifact: technical_decision_pointer
metadata_schema_version: "1.0"
artifact_version: "1.0.1"
project: "WinFlowz App"
created: "2026-05-17"
updated: "2026-05-17"
status: reviewed
source_skill: sg-docs
scope: "suite-authentication-pointer"
owner: "Diane"
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "WinFlowz suite auth"
  - "WinFlowz Android app"
  - "VoiceFlowz legacy naming"
  - "Clerk"
  - "Firebase Auth"
  - "legacy Supabase/Convex references"
depends_on:
  - artifact: "/home/claude/shipglows_data/projects/winflowz/docs/technical/suite-authentication.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
supersedes: []
evidence:
  - "Canonical suite auth decision documented in the main WinFlowz project on 2026-05-17."
  - "User clarification 2026-05-17: VoiceFlowz / VoiceFlows is the old name of the WinFlowz app, not a separate product."
next_review: "2026-06-17"
next_step: "/sg-spec unified-suite-authentication provider decision"
---

# Legacy VoiceFlowz Authentication Pointer

VoiceFlowz, sometimes written VoiceFlows, is the old name of the current WinFlowz app. This folder is a historical pointer, not a separate current product authority.

The canonical suite authentication decision lives in:

`/home/claude/shipglows_data/projects/winflowz/docs/technical/suite-authentication.md`

For historical VoiceFlowz material:

- Do not create a separate durable auth domain.
- Do not create a separate `voiceflowz` product entitlement by default.
- Map useful historical requirements to the WinFlowz Android app.
- Clerk is the long-term suite identity provider.
- Firebase remains the WinFlowz app mobile adapter only behind a suite identity bridge.
- Product access must be controlled by server-owned entitlements.
