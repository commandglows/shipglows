---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.6.0"
project: ShipGlows
created: "2026-07-15"
updated: "2026-08-24"
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
  - tools/vivaldi_bookmarks.py
depends_on:
  - artifact: skills/references/design-inspiration-library.md
    artifact_version: "1.9.0"
    required_status: active
supersedes: []
evidence:
  - "Operator correction: 006-sg-design must expose add, approve, list, and status as actual operator-facing library modes."
  - "Implemented 2026-08-07: add and approval request bounded automatic synchronization to the verified private Git LFS corpus."
  - "Operator request 2026-08-07: a reusable server-migration playbook restores the private corpus without exposing its remote."
  - "Operator correction 2026-08-07: approval supplies explicit, searchable creative taxonomy rather than leaving candidate defaults in the index."
  - "Live recovery 2026-08-07: add an explicit retry route for failed artifact-free candidates after shared runtime repair."
  - "Operator approval 2026-08-24: expose a read-only, privately configured Vivaldi design-bookmark bridge as candidate intake without widening access to unrelated bookmarks."
next_review: "2026-08-15"
next_step: "/103-sg-verify sales-page-reference-library"
---

# Design Inspiration Library Operations

## Purpose

Make the private design/copy reference library usable from `006-sg-design` without exposing its source-derived contents in a public repository or making operators edit YAML indexes manually.

For server replacement or corpus recovery, use the shared migration playbook and checklist rather than reconstructing the private Git/LFS setup from this operational reference.

## Activation

Interpret the following operator forms as direct curation work:

```text
sg-design library add https://example.com/sales-page
sg-design library add https://example.com/sales-page wayback https://web.archive.org/web/.../https://example.com/sales-page
sg-design library retry example-sales-page
sg-design library approve example-sales-page
sg-design library list
sg-design library status
```

The `wayback` argument accepts an already-known archive URL only. It is optional metadata: do not query Internet Archive, create a snapshot, or block capture when no archive exists.

## Operations

Before any operation, resolve `$SHIPGLOWS_ROOT`, load `skills/references/design-inspiration-library.md`, and run the shared tool from `$SHIPGLOWS_ROOT`. Never substitute a project-relative tool path.

### Add

For one explicit public URL, invoke:

```bash
python3 "$SHIPGLOWS_ROOT/tools/capture_design_inspiration.py" --url "<public-url>" --sync
```

If the operator supplied a known archive URL, append `--wayback-url "<archive-url>"`. The result must state the generated reference ID, `capture_status`, `lifecycle_status: candidate`, and the sync result. If capture is incomplete, report its safe reason code; do not retry with credentials, stealth, or authenticated browser state. A `sync=pending` result never discards the local bundle. Do not bypass `lfs_tracking_missing` or `private_remote_unverified`; repair the private corpus setup first.

Finish with exactly one approval action:

```text
sg-design library approve <reference-id>
```

No source-derived page text, screenshots, raw HTML, browser storage, credentials, or unredacted source URL query strings may be written into the ShipGlows repository or final report.

### Retry

Use retry only after repairing a capture-runtime issue and only for a named `candidate` whose prior capture is `failed`, `blocked`, or `auth_required` with no visual/text artifacts. It is an explicit recovery action, never an automatic overwrite:

```bash
python3 "$SHIPGLOWS_ROOT/tools/capture_design_inspiration.py" --retry "<reference-id>" --sync
```

The tool retains a private summary of the prior failure in the replacement `record.yaml`. It refuses any successful, partial, approved, or artifact-bearing candidate. If the retry remains incomplete, keep the new truthful status and do not bypass access controls.

### Approve

Open only the named private candidate bundle. Review its curation fields and retain attribution, rights policy, and anti-copy constraints. Then invoke the tool rather than hand-editing `record.yaml` or `index.yaml`:

```bash
python3 "$SHIPGLOWS_ROOT/tools/capture_design_inspiration.py" \
  --approve "<reference-id>" \
  --summary "<transferable structural summary>" \
  --what-to-borrow "<pattern>" \
  --what-not-to-copy "<anti-copy constraint>" \
  --sync
```

Repeat the last two flags for more patterns. Approval also requires an explicit taxonomy: `--page-type`, at least one `--style`, `--section`, `--copy-pattern`, and `--conversion-goal`; repeat `--audience` when it is known. Tags are lower-case kebab-case. The reviewing skill may propose this classification after inspecting the private candidate, then records the agreed tags with the approval instead of silently keeping the candidate defaults.

```bash
python3 "$SHIPGLOWS_ROOT/tools/capture_design_inspiration.py" \
  --approve "<reference-id>" \
  --summary "<transferable structural summary>" \
  --what-to-borrow "<pattern>" \
  --what-not-to-copy "<anti-copy constraint>" \
  --page-type "landing-page" \
  --style "editorial" \
  --section "hero" \
  --copy-pattern "problem-agitation" \
  --conversion-goal "trial" \
  --sync
```

Approval is accepted only for a `candidate` whose capture is `captured` or `partial`; it atomically updates `record.yaml` and the bounded `index.yaml`, then reports the sync result. The skill must not invent an approval review. If the operator has not supplied enough curation intent, report the candidate and ask for its review direction rather than promoting it. A `sync=pending` result keeps the local approval intact.

### List And Status

Use the bounded index only:

```bash
python3 "$SHIPGLOWS_ROOT/tools/capture_design_inspiration.py" --list
python3 "$SHIPGLOWS_ROOT/tools/capture_design_inspiration.py" --status-only
```

`--list` returns IDs and safe summaries with source query strings redacted. `--status-only` returns aggregate capture and lifecycle counts. Neither command writes the corpus or loads page bundles.

### Private Vivaldi Bookmark Intake

When the operator has configured the machine-local Vivaldi bridge, use it only to discover candidate public references inside the selected folders:

```bash
python3 "$SHIPGLOWS_ROOT/tools/vivaldi_bookmarks.py" status
python3 "$SHIPGLOWS_ROOT/tools/vivaldi_bookmarks.py" --format markdown list
python3 "$SHIPGLOWS_ROOT/tools/vivaldi_bookmarks.py" --format json search "<design need>"
```

The adapter reads its source and exact logical folder selectors from `${SHIPGLOWS_RUNTIME_DIR:-$HOME/.shipglows/state}/sources/vivaldi-design-bookmarks.json`. That configuration, the Vivaldi profile path, and real bookmark results stay private and outside the ShipGlows repository; rendered URLs drop embedded credentials, query strings, and fragments. Never replace a missing or unresolved selector with the whole bookmark collection, and never inspect adjacent Vivaldi profile files.

A bookmark is an unverified candidate, not an approved inspiration record, rights decision, accessibility proof, current product recommendation, or authorization to copy. Open or analyze only the bounded references needed for the active design outcome. Promote a chosen public reference through `library add` and the ordinary candidate-review flow when durable capture is justified.

## Consumption Boundary

After approval, the ordinary Inspiration Gate may include the reference in a shortlist. It still requires operator selection before a design or copy task treats the reference as direction. `approved` means reviewed eligibility, not permission to copy copywriting, layout, illustrations, or branding.
