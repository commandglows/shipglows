---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-09"
updated: "2026-07-09"
status: active
source_skill: 009-sg-skill-build
scope: source-faithful-pack-contract
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/007-sg-content/references/repurpose-playbook.md
  - skills/references/repurpose-pack-storage.md
depends_on:
  - artifact: "skills/references/repurpose-pack-storage.md"
    artifact_version: "1.0.0"
    required_status: "active"
supersedes: []
evidence:
  - "The retired repurpose owner repeated the same source-faithful pack structure in its output template and workflow reference."
  - "007-sg-content now treats source-faithful extraction as a reusable lane, which benefits from a shared contract."
next_review: "2026-08-09"
next_step: "/103-sg-verify source-faithful-pack-contract"
---

# Source-Faithful Pack Contract

## Purpose

Define the canonical structure and minimum rules for a reusable source-faithful pack.

This contract is shared doctrine. Owner skills may narrow it locally, but they should not silently weaken source-faithfulness, evidence separation, or handoff clarity.

## Mandatory Output Backbone

Use this section order unless a stricter owner skill says otherwise:

1. `Best Next Actions`
2. `Source-Faithful Pack`
3. `Existing Content Opportunities`
4. `Owner Skill Handoffs`
5. `Evidence Ledger`

Optional appendices may follow when justified:

- `Optional Surface Draft Seeds`
- `Titles For This Conversation`
- `Article Name Ideas`
- `Supporting Source Notes`

## Default Template

```md
## Best Next Actions

- Action:
  Deliverable:
  Target surface or owner:
  Source proof:
  Next step:

## Source-Faithful Pack

### Source Classification

- Source type:
- Probable project:
- Audience:
- Best angle:
- Confidence:

### Core Truth

- Core idea:
- Problem or tension:
- Promised outcome actually supported:
- Strongest proof:
- Constraints and caveats:
- Unsafe or unproven claims:

### Reusable Material

- Best reusable wording:
- Objections or questions surfaced:
- Diagrams or lists worth preserving:
- What should not be echoed too closely:

### Surface Opportunities

- Public surfaces justified:
- Internal surfaces justified:
- Surfaces to avoid:
- Canonical surface if one exists:

## Existing Content Opportunities

### Internal Docs / Notes

- Surface:
  Placement idea:
  Audience learning moment:
  Source proof:
  Content move:
  Priority:
  Next step:

### Public Content

- Surface:
  Placement idea:
  Audience learning moment:
  Source proof:
  Content move:
  Priority:
  Next step:

## Owner Skill Handoffs

- Owner skill:
  Recommended command:
  Target surface:
  Source truth:
  Source proof:
  Intended content move:
  Claim constraints:
  Priority:
  Context to pass forward:

## Evidence Ledger
```

## Optional Sections

Add only when the request or source justifies them.

```md
## Optional Surface Draft Seeds

### FAQ / Docs / Notes

- Surface:
  Seed:
  Why justified:

### Article / Blog / Newsletter

- Surface:
  Seed:
  Why justified:

### Email / Campaign

- Surface:
  Seed:
  Why justified:
```

```md
## Titles For This Conversation

- Title:
  Promise:
  Why this source supports it:
  Best destination:

## Article Name Ideas

- Working name:
  Angle:
  Source proof:
  Target surface:
  Recommended next step:
```

```md
## Supporting Source Notes

## Build Summary

- Problem:
- Audience:
- What changed:
- Why it matters:
- Current status:

## Source Analysis

- Source type:
- Core idea:
- Strongest insight:
- Best reusable wording:
- Diagrams or lists worth preserving:
- Audience fit:
- What is worth repurposing:
- What to avoid echoing too closely:

## Product Documentation Notes

- User-visible behavior:
- Setup or workflow impact:
- Constraints / caveats:
- Docs to update:

## Internal Change Narrative

- Before:
- After:
- Tradeoff chosen:
- Follow-up worth tracking:

## Marketing Claims

- Safe claims:
- Claims to soften:
- Claims to avoid:

## Content Angles

- Release note:
- FAQ entry:
- Landing/page hook:
- Blog or post angle:
- Newsletter angle:
- Social/thread angle:

## Diffusion Map

- Canonical surface:
- Supporting surfaces:
- Repeated concept:
- Per-surface job:
- Surfaces intentionally skipped:

## Handoff Checklist

- Must route:
- Should route:
- Optional:
- Deferred / blocked:
```

## Operating Rules

- `Best Next Actions` comes first and must stay actionable without reading the full pack.
- `Source-Faithful Pack` is mandatory. It must remain useful even when the downstream surface is unresolved.
- Keep source facts, reusable wording, justified surfaces, and unsafe claims clearly separated.
- `Evidence Ledger` is mandatory whenever the output includes public-facing claims or owner handoffs.
- `Existing Content Opportunities` should identify where the source improves existing surfaces, not only propose new ones.
- `Supporting Source Notes` is an appendix, not the default top section.

## Compression Rules

- If the work is internal only, keep `Marketing Claims` to one short line or `None justified`.
- If the work is tiny, collapse `Internal Change Narrative` into 2-3 bullets.
- If the user asked for one surface only, keep the other sections brief but keep the evidence ledger.
- If the source is third-party text, favor `Source Analysis`, `Marketing Claims`, and `Content Angles` over build-specific notes.
- If the user asked for ideas or titles, expand `Best Next Actions` first, then add the title appendix only if useful.
- If the user asked where to improve existing content, expand `Existing Content Opportunities` and compress article-title exploration.

## Storage Relationship

When the pack is durable and safe to persist in the governed project repo, follow `skills/references/repurpose-pack-storage.md` for path, naming, metadata, and ownership.
