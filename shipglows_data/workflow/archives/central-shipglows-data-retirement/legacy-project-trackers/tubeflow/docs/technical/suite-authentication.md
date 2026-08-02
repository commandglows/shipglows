---
artifact: technical_decision_pointer
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "TubeFlow"
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
  - "Clerk"
  - "Convex"
  - "YouTube OAuth"
depends_on:
  - artifact: "/home/claude/shipglows_data/projects/winflowz/docs/technical/suite-authentication.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
supersedes: []
evidence:
  - "Canonical suite auth decision documented in the main WinFlowz project on 2026-05-17."
next_review: "2026-06-17"
next_step: "/sg-spec unified-suite-authentication provider decision"
---

# Suite Authentication Pointer

TubeFlow follows the canonical suite authentication decision:

`/home/claude/shipglows_data/projects/winflowz/docs/technical/suite-authentication.md`

For TubeFlow:

- Clerk is the long-term suite identity provider.
- TubeFlow product access must be checked through server-owned entitlements.
- YouTube OAuth is a product permission grant, not the WinFlowz suite identity.
- YouTube tokens must remain separate from the suite account and revocable without deleting the user's WinFlowz identity.
