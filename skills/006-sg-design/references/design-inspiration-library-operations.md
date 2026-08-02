---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-15"
updated: "2026-07-15"
status: active
source_skill: 006-sg-design
scope: design-inspiration-library-operations
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/006-sg-design/SKILL.md
  - skills/references/design-inspiration-library.md
  - tools/capture_design_inspiration.py
depends_on:
  - artifact: skills/references/design-inspiration-library.md
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "Operator correction: 006-sg-design must expose add, approve, list, and status as actual operator-facing library modes."
next_review: "2026-08-15"
next_step: "/103-sg-verify sales-page-reference-library"
---

# Design Inspiration Library Operations

## Purpose

Make the private design/copy reference library usable from `006-sg-design` without exposing its source-derived contents in a public repository or making operators edit YAML indexes manually.

## Activation

Interpret the following operator forms as direct curation work:

```text
/006-sg-design library add https://example.com/sales-page
/006-sg-design library add https://example.com/sales-page wayback https://web.archive.org/web/.../https://example.com/sales-page
/006-sg-design library approve example-sales-page
/006-sg-design library list
/006-sg-design library status
```

The `wayback` argument accepts an already-known archive URL only. It is optional metadata: do not query Internet Archive, create a snapshot, or block capture when no archive exists.

## Operations

Before any operation, resolve `$SHIPGLOWS_ROOT`, load `skills/references/design-inspiration-library.md`, and run the shared tool from `$SHIPGLOWS_ROOT`. Never substitute a project-relative tool path.

### Add

For one explicit public URL, invoke:

```bash
python3 "$SHIPGLOWS_ROOT/tools/capture_design_inspiration.py" --url "<public-url>"
```

If the operator supplied a known archive URL, append `--wayback-url "<archive-url>"`. The result must state the generated reference ID, `capture_status`, and `lifecycle_status: candidate`. If capture is incomplete, report its safe reason code; do not retry with credentials, stealth, or authenticated browser state.

Finish with exactly one approval action:

```text
/006-sg-design library approve <reference-id>
```

No source-derived page text, screenshots, raw HTML, browser storage, credentials, or unredacted source URL query strings may be written into the ShipGlows repository or final report.

### Approve

Open only the named private candidate bundle. Review its curation fields and retain attribution, rights policy, and anti-copy constraints. Then invoke the tool rather than hand-editing `record.yaml` or `index.yaml`:

```bash
python3 "$SHIPGLOWS_ROOT/tools/capture_design_inspiration.py" \
  --approve "<reference-id>" \
  --summary "<transferable structural summary>" \
  --what-to-borrow "<pattern>" \
  --what-not-to-copy "<anti-copy constraint>"
```

Repeat the last two flags for more patterns. Approval is accepted only for a `candidate` whose capture is `captured` or `partial`; it atomically updates `record.yaml` and the bounded `index.yaml`. The skill must not invent an approval review. If the operator has not supplied enough curation intent, report the candidate and ask for its review direction rather than promoting it.

### List And Status

Use the bounded index only:

```bash
python3 "$SHIPGLOWS_ROOT/tools/capture_design_inspiration.py" --list
python3 "$SHIPGLOWS_ROOT/tools/capture_design_inspiration.py" --status-only
```

`--list` returns IDs and safe summaries with source query strings redacted. `--status-only` returns aggregate capture and lifecycle counts. Neither command writes the corpus or loads page bundles.

## Consumption Boundary

After approval, the ordinary Inspiration Gate may include the reference in a shortlist. It still requires operator selection before a design or copy task treats the reference as direction. `approved` means reviewed eligibility, not permission to copy copywriting, layout, illustrations, or branding.
