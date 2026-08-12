---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 107-sg-test
scope: qa-records-and-routing
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
  - "Wave 7 extracted durable evidence, bug transitions, and routing."
next_step: none
---

# QA Records and Routing

## Evidence interpretation

Accept `pass`, `fail`, `blocked`, or `not run` only from observed user/tool evidence. Record environment, scenario, expected/observed behavior, evidence type, result, limits, and pointers. Never rewrite prior history.

## Records

Append one compact dated entry to `shipglows_data/workflow/TEST_LOG.md`. On failure, allocate/reuse a stable `BUG-ID`, write the durable bug record with severity, reproduction, expected/actual, environment, redacted evidence, history, and next owner. On retest, append history and apply only transitions authorized in `SKILL.md`.

## Routing

- pass/retest pass: verification owns final acceptance;
- fail with actionable cause: `106-sg-fix`;
- missing hosted target: `405-sg-prod`;
- auth/session/provider: `109-sg-auth-debug`;
- non-auth browser detail: `108-sg-browser`;
- material contract ambiguity: `100-sg-spec`;
- repeated/cross-system risk: emit `Chantier potentiel`.

Report the evidence actually recorded, redaction/limits, and route. Never claim fixed, verified, closed, released, or shipped from a manual log alone.
