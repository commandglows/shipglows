---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-07-26"
updated: "2026-08-15"
status: active
source_skill: 900-shipglows-core
scope: documentation-reflection-before-closure
owner: ShipGlows
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems: [master-workflow-lifecycle, 103-sg-verify, 104-sg-end, 005-sg-ship, 300-sg-docs]
depends_on: ["skills/references/documentation-governance-rules.md", "skills/references/technical-docs-corpus.md"]
supersedes: []
evidence:
  - "Operator request 2026-07-26: milestones and SGEND should automatically trigger technical-documentation reflection."
  - "Operator clarification 2026-08-15: closure is the primary enforcement point and its documentation verdict must be visible to the operator."
  - "Operator decision 2026-08-15: the visible documentation verdict sits beneath the main documentation icon on one line separated by middle dots."
next_review: "2026-08-26"
next_step: "Apply the gate in closure and milestone owner skills."
---

# Documentation Reflection Gate

## Purpose

Ensure that a closure cannot imply completion while documentation has silently drifted from the changed behavior. This gate complements the technical documentation map, the `Documentation Update Plan`, and the external documentation freshness gate; it does not replace them.

## Trigger

Run before every closure transition and every report using completion language such as `closed`, `complete`, `done`, `resolved`, or `shipped`. This applies whether closure runs through `104-sg-end`, full-close `005-sg-ship`, another lifecycle owner, or direct execution. It is mandatory for code, behavior, UI, API, data, security, deployment, workflow, public-content, and skill-contract changes.

Ordinary progress and micro-task reports that do not claim closure are outside this mandatory visible-report gate.

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

When the impacted canonical documentation is directly mapped to the already approved work, update it in the same workstream before closure. Do not create filler documentation: `not impacted` is correct when no documented behavior, contract, source of truth, or user/operator expectation changed, but its reason must be concrete.

## Owner Routing

- technical code/module or architecture docs -> `300-sg-docs technical`;
- public claims, support, onboarding, pricing, or editorial surfaces -> `300-sg-docs editorial` or the applicable content owner;
- external SDK/provider/runtime contract -> `documentation-freshness-gate` plus the relevant technical/provider owner;
- spec, tracker, changelog, or closure source-of-truth sync -> the active lifecycle closure owner, with `300-sg-docs` when the durable documentation itself changes.

## Evidence

Every user-facing closure report must include the main documentation section icon and one compact evidence line in the user's active language, preserving one of the three stable status values:

```text
📚 DOCUMENTATION
✅ updated · <scope> | ➖ not impacted · <concrete reason> | ⚠️ needs review · <surface>
```

Choose exactly one status form; the alternatives above are not printed together. Keep its scope or reason on the same line and use ` · ` for additional compact items. The line is mandatory even for `not impacted`. A non-closure progress report may omit it. `needs review` forbids `closed`, `complete`, `done`, `resolved`, or `shipped` wording until the material gap is cleared.

Do not claim `updated` from a generic build alone. A mapped code change requires either the impacted documentation update or an explicit no-impact reason.

## Maintenance Rule

Update this reference when closure ownership, documentation routing, canonical documentation families, or closure proof semantics change.

## Pressure Scenarios

- `DOC-CLOSE-VISIBLE`: a closure report without `📚 DOCUMENTATION` followed by `updated`, `not impacted · <concrete reason>`, or `needs review · <surface>` on one compact line fails even when tests and builds pass.
- `DOC-CLOSE-BLOCKED`: a material `needs review` classification forces partial status and forbids completion or shipping language.
- `DOC-CLOSE-UPDATE`: directly mapped documentation impacted by approved work is updated before closure in the same workstream.
- `DOC-CLOSE-NO-FILLER`: an honestly unimpacted task records a concrete reason without creating ceremonial documentation.
