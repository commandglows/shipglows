---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlowz
created: "2026-07-26"
updated: "2026-07-26"
status: draft
source_skill: 900-shipglowz-core
scope: documentation-reflection-before-milestone-closure
owner: ShipGlowz
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems: [master-workflow-lifecycle, 103-sg-verify, 104-sg-end, 005-sg-ship, 300-sg-docs]
depends_on: ["skills/references/documentation-governance-rules.md", "skills/references/technical-docs-corpus.md"]
supersedes: []
evidence: ["Operator request 2026-07-26: milestones and SGEND should automatically trigger technical-documentation reflection."]
next_review: "2026-08-26"
next_step: "Apply the gate in closure and milestone owner skills."
---

# Documentation Reflection Gate

## Purpose

Ensure that a milestone cannot imply completion while documentation has silently drifted from the changed behavior. This gate complements the technical documentation map, the `Documentation Update Plan`, and the external documentation freshness gate; it does not replace them.

## Trigger

Run before any milestone, closure, changelog, ship, or report wording that could imply a work item is complete. It is mandatory for code, behavior, UI, API, data, security, deployment, workflow, public-content, and skill-contract changes.

## Reflection Questions

1. What behavior, contract, source of truth, or operator/user expectation changed?
2. Which mapped technical, product, editorial, support, operational, spec, tracker, or changelog surfaces describe it?
3. Is the documentation already aligned, missing, stale, or ambiguous?
4. Does the change require current external documentation, or is `fresh-docs not needed` justified?

## Required Classification

Record exactly one result:

- `updated`: impacted documentation was aligned in the canonical location;
- `not impacted`: no documented contract or user/operator expectation changed, with a concise reason;
- `needs review`: an owner review or documentation update remains before full closure.

`updated` and `needs review` route automatically to `300-sg-docs`. A material `needs review` result keeps closure partial and must not be hidden by a successful build or test.

## Owner Routing

- technical code/module or architecture docs -> `300-sg-docs technical`;
- public claims, support, onboarding, pricing, or editorial surfaces -> `300-sg-docs editorial` or the applicable content owner;
- external SDK/provider/runtime contract -> `documentation-freshness-gate` plus the relevant technical/provider owner;
- spec, tracker, changelog, or closure source-of-truth sync -> the active lifecycle closure owner, with `300-sg-docs` when the durable documentation itself changes.

## Evidence

The reflection should leave one compact evidence line in the owner handoff or closure record:

```text
Documentation reflection: updated | not impacted — <reason> | needs review — <owner/surface>
```

Do not claim `updated` from a generic build alone. A mapped code change requires either the impacted documentation update or an explicit no-impact reason.

## Maintenance Rule

Update this reference when milestone ownership, documentation routing, canonical documentation families, or closure proof semantics change.
