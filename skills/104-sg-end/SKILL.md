---
name: 104-sg-end
description: "Close tasks with summaries, trackers, and changelog prep."
argument-hint: [optional summary or notes]
---

Primary artifact type: `specialist-workflow`.

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/.shipglows/runtime`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Instruction Layering

This `SKILL.md` is the activation contract. Keep closure semantics here; task-row mechanics and changelog detail should stay as concise as possible.

## Chantier Tracking

Trace category: `obligatoire`.
Process role: `lifecycle`.

Before closing a spec-first chantier, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md`, then read the spec's `Skill Run History` and `Current Chantier Flow` when a unique spec exists. Append a current `104-sg-end` row with result `closed`, `deferred`, `blocked`, or `not applicable`, update `Current Chantier Flow`, and open the report with the opening chantier header from `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`. If no unique spec is available, do not write to a spec; use a `(local)` chantier header with a short work name.

## Report Modes

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, outcome-first, and using the opening chantier header. Use `report=agent`, blocked runs, or explicit handoff when detailed closure evidence is required.

## Required References

Before tracker closure, changelog framing, or done/closed wording, load `$SHIPGLOWS_ROOT/skills/references/closure-archive-guard.md`.

Before closure, load and run `$SHIPGLOWS_ROOT/skills/references/documentation-reflection-gate.md`. Classify documentation alignment as `updated`, `not impacted` with a reason, or `needs review`; route `updated` and `needs review` to `300-sg-docs` automatically and keep closure partial when a material docs gap remains.

Load `$SHIPGLOWS_ROOT/skills/references/product-decision-chain.md` when closure includes a material product decision, rework, failed proof or reusable lesson. Record only evidence-backed lessons with applicability and a future verification hook; never promote a local opinion directly into shared doctrine.

## Mission

`104-sg-end` closes the current work session: summary, tracker updates, changelog prep, and explicit next work. It owns closure bookkeeping, not implementation proof or git shipping.

`104-sg-end` answers one question:

```text
What can be closed in trackers and changelog framing now without overstating proof or ship status?
```

If the next unresolved owner is still proof, stay with `103-sg-verify`. If the next unresolved owner is git shipping, route to `005-sg-ship` after closure bookkeeping instead of absorbing ship behavior here.

## ShipGlows-Owned Preflight

Apply `$SHIPGLOWS_ROOT/skills/references/shipglows-owned-preflight.md` before reading ShipGlows-owned references, mutating ShipGlows-owned tracker/spec surfaces, or running ShipGlows-owned tools/scripts.
For `104-sg-end`, this preflight also applies before closure writes that affect ShipGlows-owned workflow state.

## Context

- Current directory: !`pwd`
- Current date: !`date '+%Y-%m-%d'`
- Project name: !`basename $(pwd)`
- Git branch: !`git branch --show-current 2>/dev/null || echo "unknown"`
- Git status: !`git status --short 2>/dev/null || echo "Not a git repo"`
- Git diff stat: !`git diff HEAD --stat 2>/dev/null || echo "no changes"`
- Recent commits (this session): !`git log --oneline -10 2>/dev/null || echo "no commits"`
- ShipGlows development mode: !`rg -n "ShipGlows Development Mode|development_mode|validation_surface|ship_before_preview_test|post_ship_verification|deployment_provider" CLAUDE.md SHIPGLOWS.md 2>/dev/null || echo "No project development mode documented"`
- Project-local TASKS.md: !`cat shipglows_data/workflow/TASKS.md 2>/dev/null || cat TASKS.md 2>/dev/null || echo "No project-local TASKS.md"`
- Local TASKS.md (if exists): !`cat TASKS.md 2>/dev/null || echo "No local TASKS.md"`
- Existing CHANGELOG: !`head -30 CHANGELOG.md 2>/dev/null || echo "no CHANGELOG.md"`

## Your task

Wrap up the current task. Summarize, update tracking files, but do NOT commit or push.
This skill closes a work session, not product truth. `TASKS.md` and `CHANGELOG.md` are bookkeeping, not proof that the outcome is fully correct, complete, secure, or shipped.

### Step 1 — Summarize what was done (internal)

From the conversation, identify:
- What was completed
- What was started but not finished
- Key files modified (from git diff)
- Any decisions worth noting
- Any evidence-backed lesson worth rechecking in the next related chantier, including its applicability boundary
- The user story or user-facing outcome this work was intended to support, if inferable
- Any gap between "work performed" and "outcome proven"
- Documentation surfaces updated or possibly stale after the change
- Documentation Reflection Gate result: `updated`, `not impacted` with reason, or `needs review`
- Project development mode from `${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/skills/references/project-development-mode.md` and `CLAUDE.md` / `SHIPGLOWS.md`
- Whether required preview deployment evidence exists (`005-sg-ship` pushed, `405-sg-prod` confirmed, and preview test/auth proof collected when needed)
- Whether any source-of-truth delta remains unsynced before closure: tracker, changelog, docs, bug file, spec, public copy, skill runtime links, or archive target

### Step 1.5 — Closure mode decision

If completion status is ambiguous, use the runtime's structured question tool when available, or a concise plain-text question:
- Question: "Quel mode de clôture veux-tu ?"
- `multiSelect: false`
- Options:
  - **Clôture complète** — "Marquer la tâche en done"
  - **Clôture partielle (recommandé si doute)** — "Garder un reliquat en in progress"
  - **Résumé seulement** — "Ne pas toucher TASKS/CHANGELOG, juste rapporter"

Ask a targeted clarification instead of assuming `done` when:
- the work is implemented but not meaningfully validated
- the project is `vercel-preview-push` and the work still needs deployed proof governed by `$SHIPGLOWS_ROOT/skills/references/preview-proof-routing.md`
- the project is `hybrid` and the changed surface depends on hosted auth/OAuth, webhooks, env vars, serverless/edge, Vercel routing, or preview/prod data without confirmed preview evidence
- the user story or expected outcome is still unclear
- the work touches auth, permissions, billing, secrets, tenant boundaries, destructive actions, migrations, public flows, or other security-sensitive surfaces
- there are remaining risks, TODOs, or blockers that materially affect product coherence or safety
- docs, README, FAQ, onboarding, changelog, examples, pricing or support copy may still describe old behavior

Examples:
- "Est-ce que tu veux clôturer la tâche comme livrée fonctionnellement, ou la laisser partielle tant que le flow utilisateur n’est pas validé ?"
- "Cette passe touche la sécurité / visibilité des données. Veux-tu une clôture partielle avec risques restants explicites ?"

### Step 2 — Update TASKS.md (silent)

Using the master TASKS.md from context:
- Before creating or mutating task operational records, load `$SHIPGLOWS_ROOT/skills/references/operational-record-format.md` and follow it for new `TASKS.md` writes.
- Mark completed items: `🔄 in progress` → `✅ done` and `📋 todo` → `✅ done`
- Mark partially done items: `📋 todo` → `🔄 in progress` with a note
- Add new tasks discovered during the work
- Update project-local `shipglows_data/workflow/TASKS.md` when task closure changes local workflow state.
- If a local `TASKS.md` also exists, update both
- Treat the TASKS content loaded in Context as informational only.
- Immediately before editing either TASKS file, re-read it from disk and use that version as authoritative.
- Apply a minimal targeted edit to the relevant rows only; never rewrite the whole file from stale context.
- If the expected row or section moved, re-read once and recompute; if it is still ambiguous, stop and ask the user.
- If the evidence supports only partial completion, keep or move the task to `🔄 in progress` with a short note rather than forcing `✅ done`.
- If preview-push validation is required but missing, do not mark the task `✅ done`; keep it `🔄 in progress` with a note such as `awaiting preview-proof route`.
- Reflect product coherence and safety gaps when they materially affect closure.
- Reflect documentation coherence gaps when a user-facing feature behavior changed.
- No output at this step.

If mode is **Résumé seulement**, skip this step.

### Step 3 — Update CHANGELOG.md (silent)

- Group changes into Keep a Changelog categories: Added / Changed / Fixed / Security / Removed
- Consolidate related changes into single human-readable entries
- Prepend a new `## [date]` entry to CHANGELOG.md (or update today's entry if it exists)
- Skip trivial changes (formatting, comments)
- Keep entries evidence-based and user-facing; do not claim a feature is "done", "safe", or "production ready" unless the work actually demonstrated that.
- In `vercel-preview-push` or relevant `hybrid` mode, apply `$SHIPGLOWS_ROOT/skills/references/preview-proof-routing.md` before framing a changelog entry as functionally released/validated.
- Include documentation alignment when it materially affects user-facing behavior.
- No output at this step.

If mode is **Résumé seulement**, skip this step.

### Step 4 — Save decisions to memory (silent)

For each significant decision or discovery from Step 1, save to memory if it will be useful in future conversations. Skip if nothing meaningful.

### Step 5 — Report

Output ONE concise report:

```
🧱 CHANTIER (local|spec) : [nom]
🎯 VERDICT (HH:mm) : [clos localement | partiel | différé | bloqué]

[Résultat métier ou opérateur en une ou deux lignes]
✅ [Preuve compacte réellement exécutée]
[Limite de preuve, documentation ou risque seulement si elle compte]

[Si le chantier reste ouvert, terminer par deux ou trois choix numérotés en
langage simple sur la poursuite, la priorité, le périmètre ou la pause. Ne
jamais exposer un skill, une commande, un propriétaire interne, une étape de
cycle de vie, un chemin de spec ou un flux.]
```

In `report=agent`, add tracker/changelog state, development mode, detailed
evidence limits, spec trace, lifecycle state, internal owners, and exact next
commands when the receiving agent needs them.

### Rules

- Do NOT commit or push — that's 005-sg-ship's job
- Do NOT output anything before Step 5 — one report only
- Keep the report under 25 lines
- Keep user mode free of internal skill names, commands, spec paths, lifecycle stages, and agent topology
- If nothing was done this session, say so honestly
- Update BOTH master and local TASKS.md when both exist
- Do not let TASKS/CHANGELOG imply stronger proof than the actual validation supports
- Apply the closure archive guard before any `done`, `closed`, or archived framing.
- Do not mark feature work fully closed if known docs remain stale and materially affect users/operators
- Prefer partial closure when user-story completion or security posture remains uncertain
- Prefer partial closure when required Vercel preview validation is missing.

## Validation

- `rg -n "Trace category|Process role|Mission|ShipGlows-Owned Preflight|canonical ShipGlows path|closure-archive-guard|operational-record-format|TASKS.md|CHANGELOG.md|vercel-preview-push|Prefer partial closure" skills/104-sg-end/SKILL.md`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `tools/shipglows_sync_skills.sh --check --skill 104-sg-end`
