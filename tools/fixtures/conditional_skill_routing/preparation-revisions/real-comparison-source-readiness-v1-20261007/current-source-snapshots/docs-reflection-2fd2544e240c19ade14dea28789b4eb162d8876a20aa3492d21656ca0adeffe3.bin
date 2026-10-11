---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.4.0"
project: ShipGlows
created: "2026-07-26"
updated: "2026-09-01"
status: active
source_skill: 900-shipglows-core
scope: documentation-reflection-before-closure
owner: ShipGlows
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems: [master-workflow-lifecycle, 103-sg-verify, 104-sg-end, 005-sg-ship, 300-sg-docs]
depends_on:
  - artifact: skills/references/documentation-governance-rules.md
    artifact_version: "1.3.0"
    required_status: active
  - artifact: skills/references/technical-docs-corpus.md
    artifact_version: "1.5.0"
    required_status: active
  - artifact: skills/references/context-quality-contract.md
    artifact_version: "1.4.0"
    required_status: active
supersedes: []
evidence:
  - "Operator request 2026-07-26: milestones and SGEND should automatically trigger technical-documentation reflection."
  - "Operator clarification 2026-08-15: closure is the primary enforcement point and its documentation verdict must be visible to the operator."
  - "Operator decision 2026-08-15: the visible documentation verdict sits beneath the main documentation icon on one line separated by middle dots."
  - "Operator decision 2026-08-15: the documentation section uses the open-book icon in both start and closure cards."
  - "Operator decision 2026-08-16: editorial impact receives an independent closure gate and visible classification."
  - "Operator correction 2026-09-01: a Windows code change with mapped technical docs was incorrectly reported as documentation not impacted because editorial impact was used as a proxy."
next_review: "2026-08-26"
next_step: "Apply the gate in closure and milestone owner skills."
---

# Documentation Reflection Gate

## Purpose

Ensure that a closure cannot imply completion while documentation has silently drifted from the changed behavior. This gate complements the technical documentation map, the `Documentation Update Plan`, and the external documentation freshness gate; it does not replace them.

Public/editorial impact is classified separately by `editorial-reflection-gate.md`.
An `updated` documentation result never proves that public promises are aligned.

## Trigger

Run before every closure transition and every report using completion language such as `closed`, `complete`, `done`, `resolved`, or `shipped`. This applies whether closure runs through `104-sg-end`, full-close `005-sg-ship`, another lifecycle owner, or direct execution. It is mandatory for code, behavior, UI, API, data, security, deployment, workflow, public-content, and skill-contract changes.

Ordinary progress and micro-task reports that do not claim closure are outside this mandatory visible-report gate.

## Required Evidence Resolution

Before documentation classification:

1. Resolve the exact task-owned changed paths from the current Git diff/staged scope or the exact delivered scope. Never use all dirty files when unrelated work exists.
2. Revalidate the bounded capsule after relevant branch, `HEAD`, dirty, staged, spec, dependency/lockfile, runtime, or proof-target changes. Prefer a fresh Context Head; when it is stale, absent, truncated, noisy, or unsupported, use its no-write view or the targeted canonical fallback.
3. Compare every changed code path with the governance-root `shipglows_data/technical/code-docs-map.md` and its trigger. The graph, Context Head, capsule, memory, and report prose accelerate discovery but never replace Git or the canonical documentation map.
4. Inspect the mapped canonical technical, operational, product, support, spec, tracker, and changelog owners. Missing map coverage for changed code is `needs review`, not evidence of no impact.
5. Decide whether current external documentation is required or `fresh-docs not needed` is justified, then update directly mapped docs inside the approved workstream.

This chain is required for code-changing work even when no public promise changed. Editorial `not impacted` does not imply documentation `not impacted`.

## Required Classification

Record exactly one result:

- `updated`: impacted documentation was aligned in the canonical location;
- `not impacted`: the required changed-path mapping completed and found no applicable documented contract or expectation change, with a concise mapped reason;
- `needs review`: an owner review or documentation update remains before full closure.

`updated` and `needs review` route automatically to `300-sg-docs`. A material `needs review` result keeps closure partial and must not be hidden by a successful build or test.

When impacted canonical documentation is directly mapped to approved work, update it in the same workstream before closure. Do not create filler documentation. A generic assertion, unchanged public copy, passing tests, a graph result, or a concrete-sounding sentence cannot establish `not impacted` without the evidence resolution above.

## Owner Routing

- technical code/module or architecture docs -> `300-sg-docs technical`;
- public claims, support, onboarding, pricing, or editorial surfaces -> `300-sg-docs editorial` or the applicable content owner;
- external SDK/provider/runtime contract -> `documentation-freshness-gate` plus the relevant technical/provider owner;
- spec, tracker, changelog, or closure source-of-truth sync -> the active lifecycle closure owner, with `300-sg-docs` when the durable documentation itself changes.

## Evidence

Every user-facing closure report must include the main documentation section icon and one compact evidence line in the user's active language, preserving one of the three stable status values:

```text
📖 DOCUMENTATION ✅ updated · <scope> | ➖ not impacted · <concrete reason> | ⚠️ needs review · <surface>
```

Choose exactly one status form; the alternatives above are not printed together. Keep its scope or reason on the same line and use ` · ` for additional compact items. The line is mandatory even for `not impacted`. A non-closure progress report may omit it. `needs review` forbids `closed`, `complete`, `done`, `resolved`, or `shipped` wording until the material gap is cleared.

Do not claim `updated` from a generic build alone. A mapped code change requires either the impacted documentation update or an explicit no-impact reason.

## Maintenance Rule

Update this reference when closure ownership, documentation routing, canonical documentation families, or closure proof semantics change.

## Pressure Scenarios

- `DOC-CLOSE-VISIBLE`: a closure report without `📖 DOCUMENTATION` followed by `updated`, `not impacted · <concrete reason>`, or `needs review · <surface>` on one compact line fails even when tests and builds pass.
- `DOC-CLOSE-BLOCKED`: a material `needs review` classification forces partial status and forbids completion or shipping language.
- `DOC-CLOSE-UPDATE`: directly mapped documentation impacted by approved work is updated before closure in the same workstream.
- `DOC-CLOSE-NO-FILLER`: an honestly unimpacted task records a concrete reason without creating ceremonial documentation.
- `DOC-CLOSE-MAPPED-CODE`: changed Windows code with an applicable code-docs trigger forbids documentation `not impacted` until its canonical technical docs are aligned, even when editorial impact is `not impacted`.
- `DOC-CLOSE-UNMAPPED-CODE`: changed code absent from the canonical map yields `needs review` and a technical-navigation gap.
- `DOC-CLOSE-STALE-CONTEXT`: invalidated Context Head or capsule evidence is refreshed or replaced by targeted canonical fallback before documentation classification.
- `DOC-CLOSE-EDITORIAL-SEPARATION`: editorial `not impacted` never substitutes for the independent technical documentation verdict.
