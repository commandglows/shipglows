---
name: 707-name
description: "Name or rename the current session."
argument-hint: <session name>
allowed-tools: Bash(mkdir:*), Bash(ls:*), Bash(echo:*), Bash(cat:*), Bash(tee:*)
---

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/shipglows`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `non-applicable`.
Process role: `helper`.

This skill does not write to chantier specs. If invoked inside a spec-first flow, do not modify `Skill Run History`; use a `(local)` chantier header with a short work name.

## Report Modes

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md` and use the shared chantier-then-verdict opening.

## Your task

Name the current session so it appears in the statusline and is saved for future reference.

This skill answers one operator question: what short name should the current session carry so the operator can recognize it later?

It owns local session tagging only: getting or confirming the session name, resolving the current session id, and storing the statusline label.

Keep the boundary explicit:
- stay here when the user wants to name or rename the current session label
- hand off to `303-sg-resume` when the user wants a summary of what the session is about
- hand off to `309-sg-tasks` when the user wants project tracker bookkeeping rather than a local session tag

`707-name` does not summarize the work, does not mutate project artifacts, and does not act like a conversation cleanup or continuation owner.

The argument provided is: `{{ args }}`

### Steps

1. **Get the session name** — use the argument if provided, otherwise ask the user with the runtime's structured question tool when available, or a concise plain-text question: "What name do you want to give this session?"

2. **Find the current session ID** — run:
   ```bash
   ls -t ~/.claude/projects/*/*.jsonl 2>/dev/null | head -1 | xargs basename | sed 's/\.jsonl$//'
   ```

3. **Save the session name**:
   ```bash
   mkdir -p ~/.claude/session_notes
   echo "<name>" | tee ~/.claude/session_notes/<session_id>
   ```

4. **Confirm** — tell the user the session is named and will appear in the statusline (📌 <name>) after the next response.

### Note

This is separate from Claude Code's built-in `/rename` command which renames the session in the UI sidebar.
Use `/name` to tag the session so the statusline always reminds you what you're working on.
You can use both: `/rename` for the sidebar, `/name` for the statusline.
