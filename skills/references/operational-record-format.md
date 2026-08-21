---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-05-22"
updated: "2026-08-21"
status: active
source_skill: 102-sg-start
scope: operational-record-format
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "shipglows_data/workflow/TASKS.md"
  - "shipglows_data/editorial/ROADMAP.md"
  - "shipglows_data/workflow/AUDIT_LOG.md"
  - "shipglows_data/workflow/specs/"
  - "lib/data/shipglows_sources/parsers/"
  - "tui/src/sources/"
  - "skills/*/SKILL.md"
depends_on: []
supersedes: []
evidence:
  - "Traffic-first Markdown operational record spec approved on 2026-05-22."
  - "Wave 14 removed a dependency on a non-existent historical spec; the durable contract and its current consumers are authoritative."
  - "Audit cadence hardening on 2026-08-21 added stable domain identifiers and optional due/trigger context for deterministic freshness checks."
next_review: "2026-06-22"
next_step: "/102-sg-start Traffic-first Markdown operational record format Batch 2"
---

# Operational Record Format

This is the shared ShipGlows contract for task, audit, and spec operational summary records. Writer skills must load or cite this reference before creating or mutating records in `TASKS.md`, `ROADMAP.md`, `AUDIT_LOG.md`, or spec summary/index sections.

## Grammar V1

Canonical records are one physical Markdown line:

```text
<traffic> [<project>] <kind>: <title> | <field>: <value> | <field>: <value>
```

Canonical writer output must use this exact structure:

- `traffic` is one of `🔴`, `🟠`, `🟡`, or `🟢`.
- Legacy `✅` may be read as `🟢` during migration only. Writers must not emit `✅`.
- `[project]` is required immediately after the traffic marker.
- Structural spacing is a single ASCII space after `<traffic>`, after `]`, and around each ` | ` separator.
- `project` is matched case-insensitively but preserved as written for display.
- `project` must not contain raw `[` or `]`.
- `kind` is one of `task`, `audit`, or `spec`.
- `title` is the first value after `<kind>: ` and may contain colons after that first colon-space split.
- Additional fields use `key: value`, split only on the first `: ` in the field.
- Unknown fields are preserved as data and ignored unless a consumer explicitly supports them.
- Parsers may trim line ends, but must preserve internal spaces in titles and values.
- Markdown links, inline code, and command-like text are parsed as plain text only. Readers must never execute field values.

Newlines are forbidden inside the physical record line. Writers must escape source text that contains newline content.

## Escaping

Supported escapes inside titles and field values:

- `\|` means literal pipe.
- `\\` means literal backslash.
- `\n` means logical newline content.
- `\[` and `\]` mean literal brackets in text values.

Only those characters are escaped. A backslash before any other character remains literal. The `[project]` token is not escaped and cannot contain bracket characters.

## Required Fields

| Kind | Required fields | Optional fields | Value rules |
| --- | --- | --- | --- |
| `task` | `status` | `area`, `id` | `status` is a non-empty workflow state token. Canonical output uses lower-case labels such as `todo`, `in_progress`, `blocked`, `done`, or `ready` when meaningful in the source. |
| `audit` | `date`, `overall`, `issues` | `id`, `scope`, `domain`, `next_due`, `trigger` | `date` and `next_due` are ISO `YYYY-MM-DD`; `overall` is a short grade or documented equivalent; `issues` is a stable concise count or summary token; `domain` is a stable identifier from the applicable audit-cadence matrix. |
| `spec` | `status`, `path`, `next` | `id` | `status` matches the spec lifecycle vocabulary; `path` is repository-relative Markdown; `next` is a short command or label, not executable parser input. |

Specs keep YAML frontmatter and full contract sections. A `spec:` operational line is only a raw-scan summary. Canonical spec summary lines belong immediately after the `# Spec: ...` title block and before `## Title`.

## Dedupe

Dedupe keys are per kind:

- `task`: normalized project + `id` when present; otherwise normalized project + normalized title + normalized `area` when present.
- `audit`: normalized project + `id` when present; otherwise normalized project + normalized `date` + normalized `overall` + normalized `scope` or title.
- `spec`: normalized project + `id` when present; otherwise normalized project + normalized `path`; if legacy input has no path, use normalized project + normalized title.

Canonical traffic-first records take priority over legacy table rows with the same key. If multiple canonical records share a key, the first source-order record survives and later duplicates emit diagnostics.

## Diagnostics

Readers must isolate malformed records and continue parsing valid neighboring records. Diagnostics should include file, line, short excerpt, problem, and the suggested ShipGlows repair command when available.

Emit diagnostics for at least:

- missing `[project]`
- unsupported traffic marker
- unknown `kind`
- invalid date
- malformed ` | ` separator or `key: value`
- missing required field
- duplicate dedupe key
- spec summary conflict with frontmatter
- legacy table row with mismatched cells

Diagnostics must truncate large excerpts and must not expose secrets, credentials, cookies, or large logs.

## Writer Obligations

Writer skills must:

- create new task, audit, and spec summary records in the canonical grammar
- keep project identity explicit in `[project]`
- escape `|`, `\`, newline, `[`, and `]` in titles and field values
- preserve unknown fields when updating an existing canonical record
- avoid introducing duplicate canonical and legacy representations for the same operational item
- treat compact display lines that do not match this grammar as display-only output, never source format
- include `domain` on new audit records when an audit-cadence matrix applies; readers may infer legacy records conservatively, but writers must not rely on title inference
- include `next_due` when a project override differs from the shared cadence, and `trigger` when an event made the audit due independently of age

## Migration Compatibility

During migration, readers must parse canonical records first, then tolerate legacy task and audit tables or legacy spec summaries as fallback. Legacy input compatibility is temporary and does not permit new writer output in legacy table-only form.

When canonical and legacy records map to the same dedupe key, keep the canonical record and suppress the legacy row with a duplicate diagnostic. Migration tooling must produce a recoverable diff and record counts before deleting or replacing legacy information.

When `--write` migration is required for a live source, zero unmapped/legacy-active rows remain for migrated files; unmapped or malformed rows block the write and must be resolved first.

## Examples

```text
🔴 [shipglows_app] task: Run /103-sg-verify for shipglows-github-managed-clone-indexer.md | status: todo | area: github-clone-indexer
🟠 [ShipGlows] audit: dependencies | date: 2026-04-27 | overall: C | issues: 0/1/2 | domain: dependencies | next_due: 2026-05-11
🟢 [ShipGlows] spec: ShipGlows Terminal TUI V1 | status: ready | path: shipglows_data/workflow/specs/shipglows-terminal-tui-v1.md | next: /102-sg-start ShipGlows Terminal TUI V1
```
