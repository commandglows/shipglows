---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-06-10"
updated: "2026-06-10"
status: active
source_skill: 602-sg-platform-parity
scope: platform-parity-matrix
owner: Diane
confidence: medium
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/602-sg-platform-parity/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "User request 2026-06-10: create a ShipGlows skill to manage product and technical parity across platforms."
next_review: "2026-07-10"
next_step: "Use with /602-sg-platform-parity on a real project scope."
---

# Platform Parity Matrix

Use this reference when `602-sg-platform-parity` needs durable evidence or handoff detail.

## Matrix Columns

| Capability | User expectation | Platform | Verdict | Evidence | Gap | Owner route | QA route | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |

Verdicts:

- `same`
- `adapted-better`
- `adapted-required`
- `degraded-accepted`
- `not-supported`
- `unknown`

Gap values:

- `none`
- `implementation`
- `native-host`
- `shared-ui`
- `permission`
- `test-proof`
- `manual-qa`
- `docs-claim`
- `release-risk`

Owner routes:

- `100-sg-spec`: new parity chantier needed
- `001-sg-build`: implementation can start from a clear contract
- `107-sg-test`: native or device QA is the primary missing proof
- `103-sg-verify`: readiness and coherence need verification
- `300-sg-docs`: claim or operator guidance correction
- `005-sg-ship`: only after verification with bounded ship scope

## Decision Log

Record adaptations explicitly:

| Date | Capability | Platform | Decision | Why better or required | Accepted by | Follow-up |
| --- | --- | --- | --- | --- | --- | --- |

An adaptation is acceptable when it is either materially better for that platform or required by OS, browser, store, hardware, permission, or distribution constraints. Equivalent alternatives should keep the same user experience.

## Report Shape

In `report=user`, summarize:

1. parity verdict
2. top gaps by platform
3. implementation or QA route
4. claim drift, if any

In `report=agent`, include the full matrix, evidence pointers, and decision log.
