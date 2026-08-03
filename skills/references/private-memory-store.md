---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-06-29"
updated: "2026-07-11"
status: active
source_skill: 300-sg-docs
scope: private-memory-store
owner: unknown
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/source-intake-classification.md
  - shipglows_data/business/portfolio-project-pitch-links.md
  - skills/references/shipglows-terms.md
  - shipglows_data/technical/operator-guides/focus-tags-cheatsheet.md
  - skills/references/email-sequence-storage.md
depends_on:
  - artifact: "skills/references/source-intake-classification.md"
    artifact_version: "1.3.0"
    required_status: active
  - artifact: "shipglows_data/business/portfolio-project-pitch-links.md"
    artifact_version: "0.1.0"
    required_status: draft
supersedes: []
evidence:
  - "Operator approval 2026-06-29: declare an explicit private folder, hidden under the current user's home, for caching all project pitches and other reusable private material."
next_review: "2026-07-29"
next_step: "/103-sg-verify private-memory-store"
---

# Private Memory Store

## Purpose

This reference declares the approved private runtime memory root for ShipGlows agents on this server.

It exists to cache reusable private context, especially project pitches and source material, without placing that content in the public ShipGlows repository.

The repository and clone behavior for that durable private root are defined separately in `skills/references/private-data-repo-contract.md`.

## Canonical Path

```text
${SHIPGLOWS_PRIVATE_ROOT:-${SHIPGLOWS_PRIVATE_ROOT:-$HOME/.shipglows/private/data}}
```

For the current server user, this resolves to:

```text
/home/claude/.shipglows/private/data
```

This folder is outside `$SHIPGLOWS_ROOT` and is a separate private Git working tree. It is private operator memory, not a public governance artifact.

## Approved Subfolders

- `projects/`: one file per project, each file holding the project pitch, routing metadata, and the latest known project summary.
- `source-cache/`: a short-retention, pre-assignment holding area for redacted routing notes when the destination project is not yet decided.
- `reports/`: private analysis reports derived from private sources.

Create additional subfolders only when a specific owner reference documents the purpose, allowed contents, and retention rule.

## Project File Schema

Use one Markdown file per project under `projects/`.

Recommended path:

```text
projects/<project-slug>.md
```

Recommended minimal frontmatter:

```yaml
---
project: "<project name>"
slug: "<project-slug>"
pitch_url: "<github-url-or-private-source>"
status: reviewed
audience: "<primary audience>"
business_angle: "<short positioning summary>"
owner_skill: "<preferred owner skill>"
tags: ["<routing-tag>", "<optional-tag>"]
updated: "YYYY-MM-DD"
source_of_truth: "<project repo path or governed doc>"
---
```

Body content should stay short and stable:

- public-facing one-liner
- internal framing note
- relevant source-of-truth links
- decision notes when the pitch changed materially

Keep the project file as the source of truth for that project entry. Do not split the same project truth across multiple canonical files unless a separate subsystem explicitly owns the split.

## What Can Be Stored

Allowed:

- cached copies of project pitch files from the operator's project repos
- redacted summaries of project pitches for faster classification
- redacted, short-retention routing notes for an unassigned source when the operator needs to review its destination
- private analysis reports that would leak source text or project detail if committed
- local indexes that point to private cached files

Not allowed:

- credentials, tokens, cookies, OAuth secrets, SSH keys, signing keys, or private API responses containing secrets
- database dumps or customer datasets
- private source material that was provided for one-time use only
- unredacted material that the operator has not approved for durable reuse
- raw inbox material, copied third-party source text, or a durable central library of source examples
- generated cache files inside `$SHIPGLOWS_ROOT`, project repos, or public docs

## Access Rules

- Read from the private store when a skill needs reusable project truth and the public portfolio index is not enough.
- Write to the private store only after explicit operator approval or a reference that already grants the write for that source class.
- Prefer redacted summaries over full source text when full text is not needed.
- Keep public artifacts limited to source-of-truth pointers, routing notes, and redacted summaries.
- Never cite private-store paths or contents in public-facing copy.
- When a project is known, put durable derivative work in that project's governed repository. The private store may retain project-routing truth, but it is not the canonical library for email sequences, repurpose packs, or other project assets.

## Portfolio Pitch Cache

Use `shipglows_data/business/portfolio-project-pitch-links.md` as the public index of project names and pitch URLs.

Use `${SHIPGLOWS_PRIVATE_ROOT:-${SHIPGLOWS_PRIVATE_ROOT:-$HOME/.shipglows/private/data}}/projects/` as the private cache for the fetched or summarized pitch contents.

The public index decides which pitch may be relevant. The private cache may speed up classification, but it does not replace project-owned source-of-truth docs.

Recommended file naming:

```text
projects/<project-slug>.md
projects/index.md
```

## Source Cache: Pre-Assignment Only

Use `${SHIPGLOWS_PRIVATE_ROOT:-${SHIPGLOWS_PRIVATE_ROOT:-$HOME/.shipglows/private/data}}/source-cache/` only while a source has no confirmed project destination or while it awaits operator review. It is not a durable cross-project content library.

For an inspiration email or marketing example, store only the minimum redacted routing record:

- source type
- project fit
- structural pattern
- angle
- CTA pattern
- objections or proof pattern
- expiry date and next review action

Do not store raw email bodies, private recipient names, sender details, full email headers, tracking parameters, or copied proprietary phrasing.

Once a project and durable output are confirmed:

- `007-sg-content repurpose <source>` writes the pack to that project's `shipglows_data/workflow/repurpose-packs/`.
  - `202-sg-emailing` writes the sequence to that project's `shipglows_data/workflow/email/`.
- remove the source-cache item after the handoff, unless a documented short retention period is still needed for review.

The default retention is 14 days or until the handoff is complete, whichever comes first. Raw inbox content should normally remain outside Git and be deleted according to the mail workflow after processing.

## Stop Conditions

Stop and ask before persisting when:

- the source contains sensitive personal, legal, financial, medical, credential, customer, or inbox material
- the operator has not clearly approved durable reuse
- a public repo path is the only available destination
- the cache would contain private source text from a third-party repo or inbox
- retention, redaction, or owner project is unclear

## Validation

Validate references after edits with:

```bash
python3 tools/shipglows_metadata_lint.py skills/references/private-memory-store.md skills/references/source-intake-classification.md shipglows_data/business/portfolio-project-pitch-links.md shipglows_data/technical/operator-guides/focus-tags-cheatsheet.md skills/references/shipglows-terms.md
rg -n "private-memory-store|SHIPGLOWS_PRIVATE_ROOT|SHIPGLOWS_PRIVATE_ROOT|\\.shipglows/private/data|project-pitches|projects/|source-cache" skills/references shipglows_data/business shipglows_data/technical/operator-guides/focus-tags-cheatsheet.md
test -d "${SHIPGLOWS_PRIVATE_ROOT:-${SHIPGLOWS_PRIVATE_ROOT:-$HOME/.shipglows/private/data}}"
```
