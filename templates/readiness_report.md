---
artifact: readiness_report
metadata_schema_version: "1.0"
artifact_version: "0.2.0"
project: "[project name]"
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
status: draft
source_skill: sg-ready
scope: "[scope]"
owner: "[owner]"
user_story: "[user story]"
confidence: medium
risk_level: medium
security_impact: unknown
docs_impact: unknown
verified_outcomes: []
assumptions: []
evidence: []
depends_on: []
supersedes: []
next_step: "/sg-start [scope]"
---

# Readiness: [spec title]

## User-Mode Summary

Use this compact shape when a human directly launched `sg-ready` and did not ask for detail:

```text
Readiness: [ready|not ready|blocked]
Spec: [path]
[Blockers: only blockers that require action]
[Checks: short metadata/proof summary]
Next step: [real user action only]
```

Do not include the full checklist in a successful user-mode report. Use the detailed sections below for `report=agent`, handoff, blocked runs, or explicit verbose/full-report requests.

## Spec

[Path to the spec reviewed.]

## Current Status

[draft|reviewed]

## Checklist

- Structure: [ok|fail]
- Metadata: [ok|fail]
- User story alignment: [ok|fail]
- Ambiguity: [ok|fail]
- Task ordering: [ok|fail]
- Links & consequences: [ok|fail]
- Acceptance criteria: [ok|fail]
- Documentation coherence: [ok|fail]
- Execution notes: [ok|fail]
- Adversarial review: [ok|fail]
- Security review: [ok|fail]
- Open questions: [ok|fail]

## Evidence

- [Spec section, code scan, document dependency, or command used as proof.]

## Evidence Limits

- [What was not inspected or cannot be proven from the spec.]

## Metadata Gaps

- [Missing artifact versions, unknown dependency status, stale contract, or `None`.]

## Not Ready Because

- [Concrete blocking issue, or `None`.]

## Adversarial Gaps

- [Bypass, bad state, missing edge case, cross-system consequence, or `None`.]

## Security Gaps

- [Auth, authz, input validation, data exposure, logging, abuse control, tenant boundary, or `None`.]

## Risks

- [Residual product, security, data, perf, or documentation risk.]

## Verdict

- [ready|not ready]

## Next Step

- [/sg-start [title] if ready, or /sg-spec [title] if not ready]

## Fresh Context

- [subagent launched / ask user to open a new thread / not necessary]
