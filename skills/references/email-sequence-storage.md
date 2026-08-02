---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-11"
updated: "2026-07-11"
status: active
source_skill: sg-emailing
scope: email-sequence-storage
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/sg-emailing/SKILL.md
  - skills/references/source-intake-classification.md
  - skills/references/private-memory-store.md
  - skills/references/repurpose-pack-storage.md
  - shipglows_data/README.md
depends_on:
  - artifact: "skills/references/source-intake-classification.md"
    artifact_version: "1.4.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-07-11: durable email sequences should be versioned in the relevant project repository, alongside other project-owned content assets."
next_review: "2026-07-25"
next_step: "/103-sg-verify email sequence storage"
---

# Email Sequence Storage

## Purpose

Define where durable audience email sequences live after source classification and sequence drafting.

The routing index decides the likely project. The selected project owns the reusable sequence. This avoids turning private intake storage into a second global content system.

## Canonical Path

Store durable sequences in the governed project repository under:

```text
shipglows_data/workflow/email/
```

Use lifecycle or campaign folders when useful:

```text
shipglows_data/workflow/email/onboarding/
shipglows_data/workflow/email/launch/
shipglows_data/workflow/email/reactivation/
shipglows_data/workflow/email/seasonal/christmas/
```

Do not create every folder in advance. Create the smallest path that reflects a real sequence.

## When To Write

Write a sequence there when all of these are true:

- a destination project is confirmed
- the sequence is intended for reuse, review, iteration, or sending
- its claims have been checked against that project's business, product, branding, and GTM context
- the source is safe to represent through a derivative rather than copied raw text

Use an ephemeral response when the sequence is only exploratory, the project is unknown, or the source cannot safely enter project history.

## File Naming And Shape

Use one Markdown file per sequence.

Preferred filename:

```text
YYYY-MM-DD-<campaign-or-lifecycle>-sequence.md
```

Example:

```text
2026-07-11-onboarding-sequence.md
2026-12-01-christmas-offer-sequence.md
```

Minimum frontmatter:

```yaml
---
artifact: email_sequence
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "<project>"
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
status: draft
source_skill: sg-emailing
scope: "<onboarding | launch | reactivation | seasonal>"
audience: "<segment>"
objective: "<desired change>"
trigger: "<entry condition>"
cadence: "<timing>"
cta: "<primary action>"
stop_rule: "<exit or suppression rule>"
source_ref: "<redacted source reference or none>"
---
```

Keep the body sequence-first: campaign intent, segment and exclusions, step-by-step emails, CTA, stop or branch logic, and claim/compliance notes.

## Privacy And Source Boundary

- Do not copy raw inbox emails, recipient data, headers, tracking parameters, or proprietary phrasing into a sequence file.
- Record the structural lesson or a redacted source reference when provenance matters.
- Keep source-derived packs in `workflow/repurpose-packs/` when the reusable asset is source analysis rather than a finished sequence.
- Keep `~/.shipglows/private/data/projects/` for routing context and `source-cache/` only for short private review before a project is known.

## Ownership

- `sg-emailing` owns durable audience sequence files.
- `007-sg-content repurpose <source>` owns durable source-faithful packs and may hand a pack to `sg-emailing`.
- The project's business, product, branding, GTM, and editorial contracts govern the sequence's claims, positioning, and declared public surfaces.

## Validation

```bash
python3 tools/shipglows_metadata_lint.py skills/references/email-sequence-storage.md
rg -n "email-sequence-storage|workflow/email|source-cache" skills/emailing/SKILL.md skills/references/source-intake-classification.md skills/references/private-memory-store.md shipglows_data/README.md
```
