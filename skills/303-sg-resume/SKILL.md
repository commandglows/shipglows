---
name: 303-sg-resume
description: "Summarize session state, task status, and next actions."
disable-model-invocation: false
argument-hint: [optional: court | ultra-court]
---

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/.shipglows/runtime`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `non-applicable`.
Process role: `helper`.

This skill does not write to chantier specs. If invoked inside a spec-first flow, do not modify `Skill Run History`; use a `(local)` chantier header with a short work name.

## Report Modes

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md` and use the shared chantier-then-verdict opening.

# SG Résume

## Mission

When the visible conversation already carries a bounded `Context Capsule` or exact governed pointer, preserve its target, evidence states, gaps, truncation and next action in the recap. Do not regenerate or enrich it from hidden state; route actionable continuation to `706-continue`, which owns freshness checks.

Give the user a fast retention snapshot of the current conversation only.

## Goal

Identify the useful information that still exists only in the visible conversation and would be lost if that transcript were discarded.

`303-sg-resume` answers one summary question:

```text
What non-disposable information still exists only in this visible conversation and would be lost if the thread were discarded?
```

This skill is for users who feel lost across many chats and need to know:
- what was done in this thread
- what is still planned or in progress
- whether some tasks mentioned earlier were quietly dropped, forgotten, or left implicit
- which important decision, evidence, idea, risk, next step, or product angle still lacks a durable home
- whether nothing meaningful remains to preserve from the visible thread

Keep the boundary explicit: `303-sg-resume` summarizes the visible conversation only. It does not inspect repo state, infer hidden durable truth, continue a chantier, or decide the next implementation owner from local files. It does not assess whether context is reliable for a future task; conversation continuity is a separate next-task decision.

Route instead of staying here when the user needs more than a thread recap:

- explain a workflow, skill, or doctrine -> `302-sg-help`
- actually continue paused work -> `706-continue`
- verify real repo state or run lifecycle work -> route to the owning lifecycle or specialist skill

## Speed Rules

- Do not browse.
- Do not run commands.
- Do not inspect files.
- Do not spawn agents.
- Do not reconstruct every detail.
- Use only the visible conversation context.
- Prefer an approximate but useful answer over a slow exhaustive answer.

Target response time: immediate.

## Output Format

Always answer in French unless the user asks otherwise.

Keep the whole answer concise:
- 3 to 5 bullet points maximum for tasks
- one short commits section
- one short information-retention status line
- one short "À ne pas oublier" line

Use this structure:

```markdown
**Résumé du thread**
- [Terminé|En cours|Planifié] Tâche courte accomplie ou prévue.
- [Terminé|En cours|Planifié] Tâche courte accomplie ou prévue.
- [Terminé|En cours|Planifié] Tâche courte accomplie ou prévue.

**Commits effectués**
- Aucun commit effectué dans cette conversation.

**Conservation**: À préserver / Rien à préserver / À vérifier.

**À ne pas oublier**: précise s'il reste un écart entre les tâches évoquées et les tâches réellement menées à terme, s'il y a un oubli concret probable, ou s'il existe une piste produit intéressante à creuser ensuite.
```

## Status Labels

Use only these labels in task bullets:
- `Terminé`: the task was actually completed in the conversation.
- `En cours`: work started but was not completed or not verified.
- `Planifié`: discussed or decided, but not started.

## Information-Retention Verdict

Classify only whether the visible thread contains information with continuing value that is not shown as durably captured. This is independent from context reliability for a proposed next task and never recommends opening or closing a conversation.

Use:
- `Information to preserve` -> `À préserver` when an important decision, proof, constraint, unresolved commitment, or high-value idea still appears to exist only in the thread.
- `No information to preserve` -> `Rien à préserver` when the visible thread shows that meaningful outcomes and open state are already durable or no longer useful.
- `Uncertain retention` -> `À vérifier` when the visible conversation cannot establish whether a material item was persisted.

## Commits

Always include the `Commits effectués` section in the final summary.

Use only commits that are explicitly visible in the current conversation context. Do not run Git commands, inspect files, or infer commits from completed work.

If no commit is visible, write exactly:

```markdown
**Commits effectués**
- Aucun commit effectué dans cette conversation.
```

If one or more commits were made in the conversation, list only the short commit hash and 2 to 3 descriptive words:

```markdown
**Commits effectués**
- `a1b2c3d` Résumé bref
- `e4f5g6h` Fix tests
```

Do not include commit messages in full, branch names, authors, dates, or long explanations.

## What Counts as "À ne pas oublier"

Use this line as a compact coverage check of the thread, not just as a generic reminder.

It must answer, as directly as possible:
- did we actually finish the tasks we said we would do in this conversation
- is there a concrete discussed item that seems easy to forget
- is there a promising product or strategy angle mentioned in passing that deserves later follow-up

Prioritize in this order:
- a mismatch between discussed tasks and completed tasks
- a concrete forgotten follow-up, verification, decision, or deliverable
- a high-value idea or product angle worth capturing for later
- if none of the above exists, explicitly say that nothing important seems missing

When relevant, name the gap plainly:
- `On a parlé de X mais ce n'est pas fait.`
- `Y a été commencé mais pas confirmé.`
- `Aucun oubli concret repéré dans ce thread.`
- `Piste à creuser plus tard: Z.`

Do not invent hidden work. If the thread only shows discussion, mark it as not completed.
Do not claim "rien à signaler" unless the thread actually looks closed and coherent.

If there is nothing meaningful, say:

```markdown
**À ne pas oublier**: Rien de critique identifié dans ce thread.
```

## Style

- Be direct.
- No long explanations.
- No generic recap.
- No more than 5 task bullets.
- If the thread has more than 5 tasks, merge related items and keep only the most important.
- The "À ne pas oublier" line should be concrete, slightly adversarial, and optimized to catch omission rather than to sound polite.
- If persistence evidence is unclear, use `À vérifier` in the conservation line rather than claiming that nothing remains to preserve.
