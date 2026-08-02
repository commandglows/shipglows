# ShipGlows Terminal TUI (V1)

Optional terminal dashboard for ShipGlows, isolated under `/home/claude/shipglowz/tui`.

## Status

- V1 scope: read-only.
- No write-back, no shell runner, no auth/cloud/db.
- ShipGlows skills remain the main command surface; this TUI is an optional operator cockpit.

## What It Is For

Use the TUI when you want a fast terminal overview before deciding which
ShipGlows skill to run next. It is optimized for small screens and remote
terminal sessions:

- check the current projects without opening the Flutter app,
- scan specs/chantiers by status,
- switch to task and audit panels when you need recent operational context,
- open diagnostics only when the reader or source policy needs inspection.

Do not use it as a write surface. Edits still happen through skills, Markdown
files, and validated workflows.

## Requirements

- Bun runtime (OpenTUI V1 is Bun-only).
- `@opentui/core` installed in this subproject.

## Setup

The main ShipGlows installer also installs this TUI for configured users:

```bash
cd /home/claude/shipglows
sudo ./install.sh
```

Recommended one-time install:

```bash
/home/claude/shipglowz/tui/scripts/install-shipglows-tui.sh
```

Then launch from anywhere:

```bash
tui
shipglows-tui
sg-tui
```

Available command names:

- `tui`: shortest daily command.
- `shipglows-tui`: explicit ShipGlows launcher.
- `sg-tui`: short hyphenated ShipGlows alias.
- `sftui`: legacy short alias.
- `sf-tui`: legacy hyphenated alias.
- `shipglows-tui`: legacy full launcher name.

Manual setup:

```bash
cd /home/claude/shipglowz/tui
bun install
```

## Run

```bash
bun run dev
```

## Cheat Sheet

- `Tab`: move focus between projects, specs, tasks, and audits.
- `!!!`: open diagnostics.
- Type while projects/specs/tasks/audits is active: filter that list or the project scope.
- `Backspace`: edit the active filter.
- `Up`/`Down`: move selection in the active list; when the selection reaches the bottom, the visible window scrolls to the next results.
- `q`, `Esc`, `Ctrl+C`: quit and restore the terminal.

Display behavior:

- Default view renders only projects and specs to stay readable on phone-sized terminals.
- Tasks and audits render on separate panels.
- Projects are shown as names only, in a compact three-column grid.
- Projects remain visible on task and audit panels.
- When the project filter is active, specs, tasks, and audits are scoped to the matching selected project.
- Diagnostics are outside the normal `Tab` cycle and require `!!!`.

## New Server Flow

On a freshly cloned server:

```bash
cd ~/shipglows
sudo ./install.sh
```

Then open a new shell and run:

```bash
tui
```

If the command is missing in the current shell, check that `~/.local/bin` is in
`PATH` or source the shell profile created by the installer.

## Summary Line Format

Task, spec, and audit summaries use a traffic-first format so severity stays visible when terminal lines wrap:

```text
🔴 [project] summary...
🟠 [project] summary...
🟡 [project] summary...
🟢 [project] summary...
```

Selectable summaries keep the selection marker after the traffic light, for example `🟢 > [shipglows_app] [ready] ...`.

The TUI reader now follows the shared operational record contract at
`/home/claude/shipglowz/skills/references/operational-record-format.md`:

- canonical `task`, `audit`, and `spec` records are parsed directly from one-line traffic-first entries,
- canonical parsing runs before legacy table summarization,
- canonical rows take precedence when a dedupe key matches a legacy row,
- duplicate canonical/legacy rows are deduplicated per kind and surfaced as diagnostics.

## Validation

```bash
bun run typecheck
bun test
```

If the current shell cannot find Bun after install, run `export BUN_INSTALL="$HOME/.bun"; export PATH="$BUN_INSTALL/bin:$PATH"` or call `~/.bun/bin/bun` directly.

## Data Sources (read-only)

- Local project corpsora discovered from configured workspace roots (project-local `shipglows_data/` folders):
  - `./shipglows_data/workflow/TASKS.md`
  - `./shipglows_data/workflow/AUDIT_LOG.md`
  - `./shipglows_data/workflow/OPERATIONS_LOG.md`
  - `./shipglows_data/workflow/DEPENDENCY_LOG.md`
  - `./shipglows_data/workflow/specs/*.md`
- Legacy `./shipglows_data/TASKS.md` and `./shipglows_data/AUDIT_LOG.md` are still supported as fallback reads.
- `/home/claude/shipglowz/skills/*`

Workspace discovery roots can be customized with `SHIPGLOWS_TUI_WORKSPACE_ROOTS` (comma-separated paths). The legacy `SHIPGLOWS_TUI_WORKSPACE_ROOTS` name is still accepted as a fallback. If unset, the TUI uses its current working directory as the active root and falls back to the installed ShipGlows repo for auxiliary reads.

All reads go through `src/sources/sourcePolicy.ts` with allowlisted roots, symlink escape protection, file size limit, and redacted diagnostics.

## Gum / Flutter relation

- Gum is for one-shot shell prompts in scripts, not this persistent dashboard.
- Flutter app remains separate and unaffected by TUI dependencies.
