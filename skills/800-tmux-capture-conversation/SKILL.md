---
name: 800-tmux-capture-conversation
description: "Capture tmux panes to cleaned Markdown transcripts."
argument-hint: [optional --tab N, title, destination]
---

# tmux Capture Conversation

## Canonical Paths

Before resolving ShipGlows-owned files, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/shipglows`) if present. Resolve this skill's script from `$SHIPGLOWS_ROOT/skills/800-tmux-capture-conversation/scripts/`.

## Chantier Tracking

Trace category: `non-applicable`.
Process role: `helper`.

This skill captures a local terminal transcript and does not write to chantier specs. If invoked inside a spec-first flow, do not modify `Skill Run History`; use a `(local)` chantier header only when useful.

## Core Rule

Default to the current tmux pane when the user does not provide a tab/window number. The bundled script captures tmux scrollback with wrapped-line joining and can prefer the alternate screen when it contains a richer conversation transcript than normal scrollback.

This skill answers one operator question: which tmux pane should be exported to a Markdown transcript, under what title, and to which destination?

It owns raw transcript export only: target pane selection, title/destination inference, confirmation, and deterministic Markdown capture through the bundled script.

Keep the boundary explicit:
- stay here when the user wants to export a tmux conversation into a Markdown transcript
- hand off to `801-clean-conversation-transcript` after capture when the user wants the transcript cleaned for readability
- hand off to `007-sg-content repurpose <source>` only when the user explicitly wants the captured transcript turned into downstream content

`800-tmux-capture-conversation` does not clean transcript content beyond capture planning, does not rewrite the exported conversation for readability, and does not become a content strategy skill.

Ask for a tab/window number only when the user wants to capture a different tab and has not identified which one.

When a tab number is provided, interpret it as a 1-based ordinal in the tmux window list. In a zero-based tmux session, tab 2 resolves to window index `:1`, matching `tmux capture-pane -t :1 -p -S -`; in a one-based tmux session, tab 2 resolves to `:2`.

## Naming And Destination Rules

Do not accept the tmux window name as the final title when it is generic (`node`, `bash`, `zsh`, `claude`, `codex`, `nvim`, etc.) and transcript content gives a better subject. Infer a human title from the captured conversation first, for example `Conversation 001-sg-build - architecture des skills`, not `Conversation tmux - panneau courant - node`.

### Presets

- `000-shipglows`: route inferred destination to `shipglows_data/workflow/conversations/` under governance root. Keep this output private to the chantier workflow (no publication).
- `docs`: deprecated preset alias that routes to the project-local canonical `shipglows_data/workflow/conversations/` directory.

Use `--preset shipglows` or pass `000-shipglows` as the first positional preset for the ShipGlows-owned root. The legacy `docs` alias remains accepted only for compatibility and never creates a root `docs/` directory.

The `000-shipglows` preset is a protected ShipGlows-owned evidence route. It must resolve to `${SHIPGLOWS_ROOT:-$HOME/shipglows}/shipglows_data/workflow/conversations/`, not to the current project's governance root. If an explicit `--destination` for the `000-shipglows` preset points outside that directory, including a relative `shipglows_data/workflow/conversations/...` path from a product repo, the script must fail before writing. Use the legacy `docs` alias for intentionally project-local conversation notes; it still writes under the project's canonical workflow corpus.

When no destination is supplied, prefer the project that the captured conversation is about, not the shell's incidental current directory. Use this priority:

1. User-supplied destination.
2. Project root inferred from absolute paths visible in the transcript, such as `/home/ubuntu/shipglows/skills/...`.
3. Git project root of the command working directory.
4. Current working directory only when no project root can be identified.

For `docs` or no preset:

- project-root destinations write under `<project-root>/shipglows_data/workflow/conversations/` by default.
- create that directory if needed.
- write directly under `$HOME` only when the transcript has no identifiable project and the command was actually run from `$HOME`.

For `000-shipglows` preset, resolve `${SHIPGLOWS_ROOT:-$HOME/shipglows}` and write under `$SHIPGLOWS_ROOT/shipglows_data/workflow/conversations/`.

`--destination` overrides preset inference only when it stays valid for that preset. For `000-shipglows`, explicit destinations outside `$SHIPGLOWS_ROOT/shipglows_data/workflow/conversations/` are blocked.

The confirmation prompt must include the inferred title and full destination. It should also surface enough capture context to catch the wrong pane early, especially capture mode plus the first/last detected prompts when available. If any of that looks generic, stale, or misplaced, fix it before asking the user to approve.

## Workflow

1. Extract the tab number from the request when present. If absent, plan to capture the current tmux pane.
2. Infer missing values:
   - title: use the user's requested title when present; otherwise infer a concise transcript title from captured conversation content, falling back to tmux window metadata only when the content has no usable subject.
   - destination: use the user's path when present; otherwise infer the project root from transcript paths or the command working directory and write to `shipglows_data/workflow/conversations/<title-slug>-YYYYMMDD-HHMMSS.md`.
3. Confirm before writing unless the user already explicitly approved the inferred destination in the current request.
   - Tell the user the chosen title and destination.
   - Surface the capture mode and the first/last detected prompts when available so the operator can sanity-check the pane.
   - Ask whether it is OK.
   - Accept a replacement destination path as the answer and use that path instead.
4. Run the bundled script after confirmation.

## Final Report

Report the final Markdown path, mention the tmux target that was captured, and relay the printed Neovim command so the user can open the file from its parent directory.

## Script

Use `scripts/capture_tmux_conversation.sh` for the deterministic export.

Preview inferred values without writing:

```bash
SHIPGLOWS_ROOT="${SHIPGLOWS_ROOT:-$HOME/shipglows}"
"$SHIPGLOWS_ROOT/skills/800-tmux-capture-conversation/scripts/capture_tmux_conversation.sh" --dry-run
```

Capture the current pane after confirmation:

```bash
SHIPGLOWS_ROOT="${SHIPGLOWS_ROOT:-$HOME/shipglows}"
"$SHIPGLOWS_ROOT/skills/800-tmux-capture-conversation/scripts/capture_tmux_conversation.sh" --title "Conversation Codex" --destination ./conversation-codex.md --yes
```

Capture another tab after confirmation:

```bash
SHIPGLOWS_ROOT="${SHIPGLOWS_ROOT:-$HOME/shipglows}"
"$SHIPGLOWS_ROOT/skills/800-tmux-capture-conversation/scripts/capture_tmux_conversation.sh" --tab 2 --title "Conversation Codex" --destination ./conversation-codex.md --yes
```

Arguments:

- `--tab N`: optional user-facing 1-based tab ordinal. Omit to capture the current pane.
- `--title TEXT`: optional Markdown title.
- `--destination PATH`: optional file path or directory. Directories receive an inferred filename. Paths without `.md` get `.md`.
- `--session NAME`: optional tmux session. Omit to use the current session, or the only available session when outside tmux.
- `--dry-run`: show the inferred capture plan without writing.
- `--yes`: skip the script's interactive confirmation. Use only after the user has approved the title and destination in chat or supplied them explicitly with clear approval.

If running interactively without `--yes`, the script asks for confirmation. Press Enter to accept, type a new destination to change it, or type `q`/`no` to abort.

After writing the file, the script prints:

```text
Open with Neovim: cd /path/to/output-dir && nvim output-file.md
```
