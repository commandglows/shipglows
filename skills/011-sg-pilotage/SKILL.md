---
name: 011-sg-pilotage
description: "Tasks, backlog, priorities, reviews, and Codex session management."
argument-hint: "<tasks|backlog|priorities|review|sessions> [arguments]"
---

# Pilotage

## Canonical Paths

Before resolving ShipGlows-owned files, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/.shipglows/runtime`). ShipGlows tools, shared references, local playbooks, templates, and workflow docs resolve from `$SHIPGLOWS_ROOT`; project artifacts resolve from the current project root.

## Public Métier Ownership

Public label: `sg-planning`. Load `$SHIPGLOWS_ROOT/skills/references/intent-to-outcome-autonomy.md` before clarification or planning mode selection. Resolve `project -> product -> surface -> feature`, infer discoverable state, ask only for material priority decisions, and carry planning/bookkeeping outcomes through durable updates and proof.

## Instruction Layering

This `SKILL.md` is the compact activation contract. Before editing it, load `$SHIPGLOWS_ROOT/skills/references/skill-instruction-layering.md`; detailed procedures, examples, matrices, and mutation rules stay in the selected local playbook or their canonical shared reference.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `pilotage`.

Before the final report, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md`. Trace only when exactly one active spec owns the run; otherwise do not write a spec. Pilotage may route explicit non-trivial intent to `100-sg-spec`, but it does not turn every note into a chantier.

## Report Modes

Before the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise outcome, mutation truth, evidence limit, and next owner. Use `report=agent` for detailed tracker anchors, rejected writes, session-safety evidence, or a lifecycle handoff.

## Mission

`011-sg-pilotage` is the sole public entrypoint for five distinct management outcomes: execution-tracker state, deferred backlog, active-work order, evidence-based review, and repository-scoped Codex-session state. It selects exactly one explicit mode and loads exactly one substantive local playbook. It does not execute implementation, infer proof, close a chantier, or become a general helper.

## Mode Detection

Parse `$ARGUMENTS` before reading a tracker, review artifact, changelog, conversation, or Codex state:

- `tasks [focus]` -> load only `references/tasks-playbook.md`.
- `backlog [add <item>|defer [item]|review|clean]` -> load only `references/backlog-playbook.md`.
- `priorities [impact|effort|blockers|high-roi|quick-wins]` -> load only `references/priorities-playbook.md`.
- `review [daily|weekly|sprint|release]` -> load only `references/review-playbook.md`.
- `sessions [project-or-cwd|rename <status>|prune [cwd]]` -> load only `references/sessions-playbook.md`.

Bare input, an unknown mode, more than one mode, or a mixed action such as `tasks sessions rename done` loads no substantive playbook, mutates nothing, and asks one choice-oriented question with exactly these five choices: `tasks`, `backlog`, `priorities`, `review`, or `sessions`. Never infer a mode from preceding conversation, a filename, tracker proximity, or the last-used mode. `help` is not a sixth mode.

A missing selected playbook is a visible blocked result. Do not fall back to another mode, a retired identity, or a hidden compatibility path.

## Owner Boundaries

- open-ended problem framing or explore requests -> `700-sg-explore`
- model selection or model-policy questions -> `704-sg-model`
- conversation audit across transcripts -> `705-sg-conversation-audit`
- continue the current chantier or execute the resolved next action -> `706-continue` or `102-sg-start`
- read-only repository/status reporting -> `308-sg-status`
- Claude statusline label or session tag -> `707-name`
- verify conformity or proof -> `103-sg-verify`
- close a completed work item -> `104-sg-end`
- changelog generation without a pilotage review -> `304-sg-changelog`

Route before mutation when the requested outcome belongs to a neighbor. Pilotage may recommend a next owner; it never silently performs that owner's action.

## Safety And Mutation Authority

- Project trackers are local first. Use `shipglows_data/workflow/TASKS.md` for execution work and `shipglows_data/workflow/BACKLOG.md` for deferred work; root equivalents are legacy fallbacks only.
- Before any operational-record write, load `$SHIPGLOWS_ROOT/skills/references/operational-record-format.md`. Before choosing `TASKS.md` versus the editorial roadmap, load `$SHIPGLOWS_ROOT/skills/references/task-registry-routing.md`.
- Treat snapshots as informational. Authoritatively re-read the mutable target immediately before a bounded patch, recompute once when its anchor moved, then stop and ask if ambiguity remains. Never rewrite a complete tracker from stale context.
- One explicit mode authorizes only that mode's action. A combined request requires orientation first; do not chain modes automatically.
- Never infer `done` from a final message, commit, build, changelog, or review alone. Preserve `implemented`, `verified`, and `assumed` as distinct evidence states.
- Session operations must use the governed helpers and the `sessions` playbook. Never reproduce SQLite writes, native deletion, or rollout-file deletion ad hoc; never expose transcripts, raw databases, secrets, cookies, tokens, private payloads, or unnecessary private paths.

## Validation

After contract edits, run:

```bash
python3 -m unittest tools.test_011_sg_pilotage_contract tools.test_rename_codex_session tools.test_prune_codex_sessions tools.test_bug_proof_fidelity_contract tools.test_guided_business_product_discovery_contract
python3 tools/shipglows_metadata_lint.py skills/011-sg-pilotage
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
python3 tools/skill_code_index_lint.py
python3 -m json.tool plugins/shipglows/assets/pack-catalog.json
tools/shipglows_sync_skills.sh --check --all
git diff --check
```

## Rules

- Keep exactly five public modes and one local playbook per mode.
- Keep `sessions` first-class; `tasks` accepts no session operation.
- Keep neighboring owners discoverable and independent.
- Do not add aliases, wrappers, remembered-mode fallback, hidden cross-mode chains, or a sixth discovery mode.
