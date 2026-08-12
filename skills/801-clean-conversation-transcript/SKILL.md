---
name: 801-clean-conversation-transcript
description: "Clean tmux/Codex transcripts into readable Markdown."
argument-hint: <markdown transcript path>
---

# Clean Conversation Transcript

## Canonical Paths

Before resolving ShipGlows-owned files, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/.shipglows/runtime`) if present. Project transcript files still resolve from the current project root unless the user gives an absolute path.

## Chantier Tracking

Trace category: `non-applicable`.
Process role: `helper`.

This skill edits a submitted transcript for readability and does not write to chantier specs. If invoked inside a spec-first flow, do not modify `Skill Run History`; use a `(local)` chantier header only when useful.

## Mission

Clean one exported tmux/Codex transcript into a readable Markdown source while preserving user intent, decisions, commands, errors, and outcomes.

This skill answers one operator question: how do we turn this one transcript file into a readable source without losing the important conversation substance?

It owns transcript cleanup only: reading one submitted transcript, removing obvious chrome/noise, relabeling turns, preserving key commands/outcomes, and saving the cleaned result in place.

Keep the boundary explicit:
- stay here when the user already has a transcript file and wants it cleaned for readability
- hand off to `800-tmux-capture-conversation` when the transcript has not been exported yet
- hand off to `007-sg-content repurpose <source>` only when the user explicitly wants the cleaned source turned into another content artifact

`801-clean-conversation-transcript` does not capture new transcripts, does not produce a separate strategy report by default, and does not invent content beyond the submitted transcript.

## Goal

Transform one exported Markdown transcript into a readable working source for documentation or content repurposing. Edit the submitted file directly. Do not create a separate report, pack, summary file, or sidecar unless the user explicitly asks for one.

## Required Input

Require a target file path. If no file is supplied and no obvious single exported transcript is in scope, ask for the path.

The expected source is usually a Markdown file produced by `$800-tmux-capture-conversation`, but apply the same rules to any tmux/Codex terminal transcript.

## Editing Rules

- Preserve the useful conversation substance.
- Do not delete user intent, decisions, commands, file paths, errors, or outcomes.
- Remove only obvious terminal/product chrome, especially OpenAI/Codex splash blocks, model/mode banners, status bars, empty screen filler, repeated prompts, and non-conversational UI noise.
- Label each conversational turn with exactly:
  - `Diane:` for the human/user.
  - `agent IA:` for the assistant/agent.
- Infer speakers pragmatically. If uncertain, choose the most plausible label; the user may correct it later.
- Keep command outputs and important commands when they matter to the story, but compress long raw logs into readable summaries.
- If the agent spoke too much, replace the excess with a concise `agent IA:` summary that keeps the action and outcome.
- Keep language natural and readable. The cleaned file should be pleasant to read, not a forensic transcript.

## Speaker Heuristics

Use `Diane:` when a block:

- asks for something, corrects direction, approves, rejects, or clarifies intent.
- is informal first-person French from the operator.
- mentions what "je" wants the agent to do.
- gives a file/path/tab/title/destination requirement.

Use `agent IA:` when a block:

- explains what it will do or did.
- reports command execution, file edits, validations, errors, or next steps.
- contains terminal commands selected by the assistant.
- summarizes analysis or proposes an implementation path.

For mixed blocks, split them into separate `Diane:` and `agent IA:` turns only when the split is obvious. Otherwise keep one label and preserve the text.

## Content Angle Block

Add one visible developer-style comment block near the top, after the existing title/metadata if present. Use this exact visual style:

```text
/* CONTENT ANGLES
 * Suggested title: ...
 * Strongest angle: ...
 * Possible formats: tutorial, internal doc, product note, article, FAQ, changelog
 * Notes: ...
 */
```

The content angle block must:

- propose a better title when the filename or current title is weak.
- identify the strongest reusable angle in the conversation.
- mention likely content formats.
- stay short enough to be useful while editing.
- remain inside the file as comments, not as a separate report.

Use `007-sg-content repurpose <source>` as the source-faithful route when the user explicitly requests a content artifact. Borrow its doctrine: stay faithful to the source, separate confirmed facts from speculation, and prefer concrete reusable angles over generic marketing.

## Cleaning Workflow

1. Read the whole file or enough chunks to understand the conversation.
2. Identify the actual conversation boundaries and remove only non-conversational chrome.
3. Choose or rewrite the top title for the cleaned transcript when useful.
4. Insert the `/* CONTENT ANGLES */` block.
5. Rewrite the transcript into labeled turns:
   - `Diane:` followed by her message.
   - `agent IA:` followed by the assistant response or a concise assistant-action summary.
6. Preserve significant commands and outcomes as short quoted or fenced blocks only when they are needed.
7. Remove duplicated progress chatter, repeated terminal noise, and excessive assistant narration.
8. Save the changes in place.

## Final Report

Only state the file edited and the main transformation. Do not paste a long report.

## Output Shape Inside The File

Prefer this structure:

~~~markdown
# Clean, content-oriented title

/* CONTENT ANGLES
 * Suggested title: ...
 * Strongest angle: ...
 * Possible formats: ...
 * Notes: ...
 */

Diane: ...

agent IA: ...

Diane: ...

agent IA: ...
~~~

When preserving command detail:

~~~markdown
agent IA: The agent checked the tmux windows and captured the second tab with:

```bash
tmux capture-pane -t :1 -p -S - > conversation-onglet-2.txt
```
~~~

When compressing noisy output:

~~~markdown
agent IA: The agent ran validation. Two issues appeared: the script targeted the wrong tmux window index on one-based sessions, and a Markdown printf edge case needed correction. It patched both and reran the checks successfully.
~~~

## Hard Boundaries

- Do not invent facts that are not in the transcript.
- Do not erase uncertainty created by guessed speaker labels.
- Do not turn the file into a polished article unless the user asks for that; this skill prepares the source for later repurposing.
- Do not produce a separate content strategy report.
- Do not modify unrelated files.
