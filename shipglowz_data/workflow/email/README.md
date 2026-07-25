---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlowz
created: "2026-07-11"
updated: "2026-07-11"
status: active
source_skill: sg-emailing
scope: workflow-email-index
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - shipglowz_data/README.md
  - skills/sg-emailing/SKILL.md
  - skills/references/email-sequence-storage.md
  - skills/references/source-intake-classification.md
depends_on:
  - artifact: "skills/references/email-sequence-storage.md"
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-07-11: durable audience sequences belong in the relevant project's versioned workflow folder."
next_review: "2026-07-25"
next_step: "/sg-emailing <sequence brief>"
---

# Email Sequences

`shipglowz_data/workflow/email/` stores durable audience email sequences for this project.

This is project-owned memory: a sequence can be reviewed, refreshed, and reused with the business, product, branding, GTM, and editorial contracts that govern the same project.

## Suggested Folders

- `onboarding/`
- `launch/`
- `reactivation/`
- `seasonal/<campaign>/`

Create a folder only for a real sequence. A single sequence may live directly in this folder until a lifecycle category is useful.

## What Belongs Here

- audience sequence plans and final drafts created by `sg-emailing`
- cadence, segment, CTA, trigger, stop-rule, and compliance notes needed to send or revise the sequence
- redacted provenance notes that explain a reusable structural inspiration

## What Does Not Belong Here

- raw inbox emails, recipients, headers, tracking data, or copied third-party phrasing
- one-to-one correspondence
- unassigned source material; use an ephemeral classification or the short private-review process instead
- source-faithful analysis packs, which belong in `workflow/repurpose-packs/`

## Naming Rule

Use one Markdown file per sequence:

```text
YYYY-MM-DD-<campaign-or-lifecycle>-sequence.md
```

Examples:

```text
2026-07-11-onboarding-sequence.md
2026-12-01-christmas-offer-sequence.md
```

## Maintenance Rule

Update the existing sequence when the campaign evolves. Do not create a second global archive of email sources in the private routing store.
