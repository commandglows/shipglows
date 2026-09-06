---
name: 011-sg-pilotage
description: "Tasks, backlog, priorities, reviews, and Codex session management."
argument-hint: "<tasks|backlog|priorities|review|sessions> [arguments]"
---

# Pilotage

## Canonical Paths

Before resolving ShipGlows-owned files, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/.shipglows/runtime`). ShipGlows tools, shared references, local playbooks, templates, and workflow docs resolve from `$SHIPGLOWS_ROOT`; project artifacts resolve from the current project root.

## Public Métier Ownership

Public label: `sg-planning`. Resolve `project -> business/brand/product -> outcome -> surface -> work item`. A supplied task uses bounded capture or the missing-project question below. Load `$SHIPGLOWS_ROOT/skills/references/intent-to-outcome-autonomy.md` for other outcome/direction interpretation; a missing project name alone does not trigger it. Carry bookkeeping through durable updates and proof.

## Instruction Layering

This `SKILL.md` is the compact activation contract. Before editing it, load `$SHIPGLOWS_ROOT/skills/references/skill-instruction-layering.md`; detailed procedures, examples, matrices, and mutation rules stay in the selected local playbook or their canonical shared reference.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `pilotage`.

Before writing or updating a spec trace, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md`. Bounded capture only updates the tracker; it does not create, select or update a spec. A missing-project question selects no spec or tracker. Other modes load chantier tracking before a work report.

## Report Modes

Before the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

Use its simple question for a missing project, record confirmation after a verified save/duplicate, and work report for execution, failure or chantier closure. Do not load work-report leaves solely because a supplied task was recorded or a factual input is missing.

Default to `report=user`: concise outcome, mutation truth, evidence limit, and next owner. Use `report=agent` only on explicit operator/orchestrator request; tracker detail, rejected writes, session-safety evidence, or internal lifecycle handoffs do not select it. Preserve required blocker, proof, and continuity disclosures through the shared reporting gates.

## Mission

`011-sg-pilotage` owns five management outcomes: execution-tracker state, deferred backlog, active-work order, evidence-based review, and repository-scoped Codex-session state. It selects one mode and one substantive local playbook. It does not execute implementation, infer proof, or close a chantier.

## Mode Detection

Parse `$ARGUMENTS` before reading a tracker, review artifact, changelog, conversation, or Codex state:

### Bounded task capture

A natural-language request to add a supplied implementation task in one known project selects `tasks`; no mode question is needed. A dependency such as "after commit and push" is recorded, not executed. Load `references/tasks-playbook.md`, then its bounded capture branch. This is an existing tasks operation, not a sixth mode. An explicitly attached spec or requested spec trace uses the full tasks workflow and chantier tracking. Missing project, conflicting scope, mixed actions, editorial work, deferred ideas, status changes or requests to execute work use the normal owner/mode rules below. Do not infer a completed status or invent an owner.

### Other planning requests

When task capture is clear but the project is ambiguous, load `question-contract.md` and ask only which project before any tracker read/write, then reevaluate bounded capture. Clear editorial work uses `task-registry-routing.md` and its content owner. Neither case asks the user to choose a technical mode.

Normalize the first token `prio` to the canonical `priorities` mode before selection, preserving every remaining argument. This alias loads the same priorities playbook and never creates a sixth mode.

- `tasks [focus]` -> load only `references/tasks-playbook.md`.
- `backlog [add <item>|defer [item]|review|clean]` -> load only `references/backlog-playbook.md`.
- `priorities [impact|effort|blockers|high-roi|quick-wins]` -> load only `references/priorities-playbook.md`.
- `review [daily|weekly|sprint|release]` -> load only `references/review-playbook.md`.
- `sessions [project-or-cwd|rename <status>|prune [cwd]]` -> load only `references/sessions-playbook.md`.

Outside the routes above, bare input, an unknown mode, more than one mode, or a mixed action such as `tasks sessions rename done` loads no substantive playbook, mutates nothing, and asks one choice-oriented question with exactly these five choices: `tasks`, `backlog`, `priorities`, `review`, or `sessions`. Never infer a mode solely from a filename, tracker proximity, or the last-used mode. `help` is not a sixth mode.

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
- Before any operational-record write, load `$SHIPGLOWS_ROOT/skills/references/operational-record-format.md` and apply `$SHIPGLOWS_ROOT/skills/references/mutation-plan-approval.md`. For bounded implementation-task capture the destination is `TASKS.md`; load `$SHIPGLOWS_ROOT/skills/references/task-registry-routing.md` when choosing another destination or resolving mixed/unclear ownership.
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
- Keep exactly one bounded compatibility alias, `prio` -> `priorities`; do not add other aliases, wrappers, remembered-mode fallback, hidden cross-mode chains, or a sixth discovery mode.
