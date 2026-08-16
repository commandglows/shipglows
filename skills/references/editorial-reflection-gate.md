---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-16"
updated: "2026-08-16"
status: active
source_skill: 900-shipglows-core
scope: editorial-reflection-before-closure
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/references/reporting-contract.md
  - skills/references/documentation-reflection-gate.md
  - skills/104-sg-end/SKILL.md
  - skills/005-sg-ship/SKILL.md
  - skills/007-sg-content/SKILL.md
depends_on:
  - artifact: skills/references/editorial-content-corpus.md
    artifact_version: "1.4.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-16: every closure receives an explicit editorial reflection in addition to documentation reflection."
next_review: "2026-09-16"
next_step: none
---

# Editorial Reflection Gate

## Purpose

Prevent a closure from leaving public promises, onboarding, support copy, or
declared audience surfaces silently behind the delivered behavior. Editorial
Editorial impact is classified independently from documentation impact; one cannot stand
in for the other.

## Trigger

Run before every report that claims a work item is closed, complete, done,
resolved, delivered, or shipped. The reflection is mandatory; creating or
editing public content is not.

## Reflection

1. Did behavior, positioning, availability, onboarding, support expectations,
   public skill behavior, pricing, or another user-visible promise change?
2. Does the project declare a public surface in its editorial content map or
   equivalent canonical routing map?
3. Which existing public pages, README promises, FAQ, support, pricing, public
   skill pages, install surfaces, or claims describe the changed outcome?
4. Are those surfaces aligned, honestly unaffected, or still awaiting review?

## Required Classification

Record exactly one result:

- `updated`: every directly impacted declared public surface was aligned;
- `not impacted`: no public promise or declared surface changed, with a concrete
  reason. `No declared public surface` is valid when project evidence proves it;
- `needs review`: a named public surface or claim remains stale, ambiguous, or
  requires owner truth before safe publication.

A material editorial `needs review` result forbids closure or shipping language.
Route it to the public content owner; do not disguise it as a documentation gap.
When directly mapped public copy is already inside the approved workstream,
align it before closure. Otherwise keep the result partial and request the
required authority or business truth.

## No-Filler Boundary

Do not create a blog post, page, FAQ, roadmap item, or public claim merely to
satisfy this gate. A project with no declared public surface, or a change with no
audience consequence, records `not impacted` with its evidence-backed reason.
Installation, configuration, discovery, and callability remain distinct in any
public claim.

## Visible Evidence

Every closure report includes exactly one compact line:

```text
✏️ ÉDITORIAL
✅ updated · <aligned public surface>
```

Use `➖ not impacted · <concrete reason>` or
`⚠️ needs review · <named public surface>` when applicable. Keep the stable
status value in English while translating the scope or reason.

## Pressure Scenarios

- `EDITORIAL-CLOSE-VISIBLE`: every completion claim includes the editorial block and one classification.
- `EDITORIAL-CLOSE-BLOCKED`: a material stale public promise returns `needs review` and blocks closure language.
- `EDITORIAL-CLOSE-UPDATE`: directly mapped public surfaces inside approved scope are aligned before closure.
- `EDITORIAL-CLOSE-NO-SURFACE`: a proven absence of declared public surfaces returns `not impacted · No declared public surface`.
- `EDITORIAL-CLOSE-NO-FILLER`: an unaffected change does not generate ceremonial public content.
