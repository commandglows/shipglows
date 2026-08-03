---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "0.1.2"
project: ShipGlows
created: "2026-05-17"
updated: "2026-05-23"
status: draft
source_skill: sg-build
scope: terminal-tui
owner: "Diane"
confidence: medium
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "/home/claude/shipglows/tui"
  - "Bun"
  - "OpenTUI"
depends_on:
  - "shipglows_data/workflow/specs/shipglows-terminal-tui-v1.md@1.0.0"
supersedes: []
evidence:
  - "tui/src/sources/readers.ts"
  - "tui/src/viewModels/dashboard.ts"
  - "tui/src/views/dashboardView.ts"
  - "tui/test/dashboardViewModel.test.ts"
  - "tui/test/readers.test.ts"
next_review: "2026-06-21"
next_step: "/sg-verify ShipGlows Terminal TUI V1"
---

# Terminal TUI V1

## Purpose

`/home/claude/shipglows/tui` provides an optional local terminal cockpit for ShipGlows operations next to the skills used from the terminal.

It is an operator visibility layer, not a second workflow engine. The TUI helps
an operator choose the next skill or chantier to inspect, while the durable
source of truth stays in ShipGlows Markdown artifacts and skill-run ledgers.

## Documentation surfaces

- Internal operator guide: `/home/claude/shipglows/tui/README.md`.
- Internal technical contract: `/home/claude/shipglows/shipglows_data/technical/terminal-tui.md`.
- Public overview surface: `/home/claude/shipglows_app/site/src/pages/docs.astro`.
- Repo onboarding pointer: `/home/claude/shipglows/README.md`.

Public copy must keep the same boundary as V1: read-only, local, optional, and
not a replacement for skills or the Flutter app.

## Runtime and dependency boundary

- Subproject: `/home/claude/shipglows/tui` (Bun + TypeScript).
- OpenTUI dependency is isolated in `tui/package.json`.
- If Bun/OpenTUI is missing, startup fails with clear guidance to `tui/README.md`.
- `install.sh` calls `tui/scripts/install-shipglows-tui.sh` during per-user setup so the main ShipGlows install also provisions the TUI.
- `tui/scripts/install-shipglows-tui.sh` bootstraps Bun when missing, installs TUI dependencies, and creates `tui`, `shipglows-tui`, `sg-tui`, plus legacy aliases `sftui`, `sg-tui`, and `shipglows-tui` in `~/.local/bin`.

## V1 read-only contract

- Read-only navigation across projects, specs/chantiers, tasks/audits/logs, skills/help, diagnostics.
- No write-back to markdown/ledgers.
- No shell execution surface.
- No auth/cloud/db/secrets handling.

## Source policy

All file reads must use `tui/src/sources/sourcePolicy.ts`:

- Allowlisted roots only.
- `realpath` + path-relative check blocks symlink escapes.
- File size limit enforced.
- Diagnostics redact sensitive path segments.

## Data flow

- `sources/readers.ts`: orchestration publique `readDashboardData`, discovery de projets, parsing specs, lecture TASKS/AUDIT.
- `sources/canonicalRecords.ts`: parsing des enregistrements canoniques `🔴/🟠/🟡/🟢` et dédup.
- `sources/summarizers.ts`: résumés tasks/audits, helpers de lignes et tri.
- `viewModels/dashboard.ts`: maps parsed data and ephemeral navigation state to render-safe lines.
- `views/dashboardView.ts`: text layout, keyboard navigation, filtering, OpenTUI mount/quit lifecycle.
- `statusMaps.ts`: mappings de statut/couleur partagés (shell/TUI).
- `main.ts`: Bun runtime guard + reader/view wiring.

## Interaction model

- `Tab`: cycle projects, specs, tasks, and audits.
- `!!!`: open diagnostics.
- Default view renders only projects and specs to stay readable on phone-sized terminals.
- Tasks and audits render on separate panels.
- Projects show names only in a compact three-column grid.
- Projects remain visible on recent task and audit panels.
- When the project filter is active, specs, tasks, and audits are scoped to the matching selected project.
- Typing while projects/specs/tasks/audits is active filters that list or the project scope.
- `Backspace`: edits the active filter.
- `Up`/`Down`: changes the selected project, spec, task, or audit line in the active panel; when the selection reaches the bottom, the visible window scrolls to the next results.
- Details are intentionally compact in the main view; full write/action surfaces remain out of V1.

## Operator commands

- `tui`: shortest daily launcher installed in `~/.local/bin`.
- `shipglows-tui`: explicit ShipGlows launcher.
- `sg-tui`: short hyphenated alias.
- `sftui`: legacy short alias.
- `sg-tui`: legacy hyphenated alias.
- `shipglows-tui`: legacy full launcher name.

The root `install.sh` provisions these commands for configured users by calling
`tui/scripts/install-shipglows-tui.sh` during per-user setup.

Set `SHIPGLOWS_SKIP_TUI_INSTALL=1` to skip TUI provisioning during a full
ShipGlows install. Set `SHIPGLOWS_INSTALL_TUI_FOR_ROOT=1` only when the root
account itself should receive the TUI install.

## Summary line format

Task, spec, and audit summaries must use traffic-first rendering so priority stays visible at the start of wrapped terminal lines:

```text
🔴 [project] summary...
🟠 [project] summary...
🟡 [project] summary...
🟢 [project] summary...
```

Specs keep the selection marker after the traffic light, for example `🟢 > [shipglows_app] [ready] ...`. The source Markdown tables may keep their existing columns; `sources/readers.ts` and `viewModels/dashboard.ts` own normalization into this display contract.

Canonical records are parsed using
`/home/claude/shipglows/skills/references/operational-record-format.md` before any legacy table parsing.
This preserves migration compatibility while making canonical one-line entries the default read path:

- task/audit/spec operational records are parsed directly from traffic-first lines with `[project]` prefixes;
- legacy task/audit tables remain enabled when canonical entries are absent;
- canonical and legacy entries sharing a dedupe key are deduplicated in favor of canonical.

## Validation

```bash
cd /home/claude/shipglows/tui
bun run typecheck
bun test
```

If Bun is unavailable in the environment, report `bun validation skipped: bun missing`.

## Future write/action gate

Any write/action capability needs a separate ready spec with:

- explicit permission model,
- confirmation UX,
- audit logging and rollback,
- security review,
- dedicated tests.
