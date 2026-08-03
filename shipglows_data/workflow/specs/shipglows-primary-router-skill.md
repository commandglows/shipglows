---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-05-04"
created_at: "2026-05-04 19:35:56 UTC"
updated: "2026-05-04"
updated_at: "2026-05-04 21:14:01 UTC"
status: ready
source_skill: sg-skill-build
source_model: "GPT-5 Codex"
scope: skill
owner: Diane
user_story: "As a non-technical ShipGlows operator, I want one natural-language ShipGlows entrypoint that routes to the right skill or answers directly, so I do not need to memorize the skill taxonomy before asking for work."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/shipglows/SKILL.md
  - skills/references/entrypoint-routing.md
  - skills/references/master-delegation-semantics.md
  - skills/REFRESH_LOG.md
  - skills/sg-help/SKILL.md
  - README.md
  - shipglows_data/workflow/playbooks/spec-driven-workflow.md
  - shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md
  - docs/technical/skill-runtime-and-lifecycle.md
  - site/src/content/skills/shipglows.md
depends_on:
  - artifact: "skills/references/master-delegation-semantics.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "skills/references/master-workflow-lifecycle.md"
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "User decision 2026-05-04: the primary operator entrypoint should be named shipglows and public-facing as ShipGlows."
  - "User decision 2026-05-04: the router should choose the right skill for non-technical users instead of requiring them to know the taxonomy."
  - "User decision 2026-05-04: the router should use direct main-thread handoff to selected master skills, not master-skill-in-subagent nesting."
next_step: "none"
---

# Spec: ShipGlows Primary Router Skill

## Title

ShipGlows Primary Router Skill

## Status

ready

## User Story

As a non-technical ShipGlows operator, I want one natural-language ShipGlows entrypoint that routes to the right skill or answers directly, so I do not need to memorize the skill taxonomy before asking for work.

## Minimal Behavior Contract

`shipglows <instruction>` is the primary natural-language entrypoint. It classifies the operator's intent, answers directly when no file work or lifecycle routing is needed, asks one short question when routing is materially ambiguous, or hands off control in the main conversation to the selected existing skill. It must not launch a master skill inside a subagent; selected master skills own their own delegated sequential execution.

## Success Behavior

- Preconditions: the ShipGlows skill set is installed and the operator provides a natural-language instruction.
- Trigger: the operator invokes `shipglows <instruction>` or `$shipglows <instruction>`.
- User/operator result: ShipGlows either answers directly, asks one routing question, or continues through the correct existing skill contract.
- System effect: no new durable work item is created by `shipglows` itself; durable specs, bug files, release scopes, content surfaces, and ship scopes remain owned by the selected skill.
- Success proof: skill contract, shared routing reference, help/workflow docs, public page, runtime sync, budget audit, metadata lint, and site build all pass.
- Silent success: not allowed; the route or direct-answer reason must be visible in the final report when useful.

## Error Behavior

- Expected failures: unknown skill taxonomy match, multiple plausible owner skills, missing runtime skill link, or selected skill stop condition.
- User/operator response: ask one short question, report the blocked reason, or name the selected recovery skill.
- System effect: no file mutation, ship, deployment, or durable artifact write occurs inside `shipglows` itself.
- Must never happen: nested master-skill orchestration through a subagent, duplicate skill internals, unbounded parallelism, hidden spec creation, or routing that bypasses owner-skill gates.
- Silent failure: not allowed.

## Problem

ShipGlows now has enough skills that non-technical operators should not need to know which master or owner skill to invoke before asking for help.

## Solution

Create `shipglows` as a thin primary router backed by a shared `entrypoint-routing.md` reference. It performs intent classification, then uses direct handoff to the selected skill instead of becoming another mega-master.

## Scope In

- New `shipglows` skill contract and runtime metadata.
- Shared entrypoint routing reference.
- Help, workflow, technical docs, launch cheatsheet, and public skill page discoverability.
- Runtime symlink validation for current-user Claude/Codex skill directories.

## Scope Out

- Renaming existing `sg-*` skills.
- Replacing `sg-build`, `sg-maintain`, `sg-bug`, `sg-deploy`, `sg-content`, `sg-skill-build`, or audit owner skills.
- Launching selected master skills inside subagents.
- Adding a separate CLI binary or shell command outside the skill system.

## Constraints

- Internal skill contracts stay in English.
- Public/operator language should be non-technical.
- `shipglows` must not duplicate owner-skill internals.
- Delegation semantics must preserve the distinction between sequential delegation and parallelism.

## Implementation Tasks

- [x] Task 1: Create the primary router skill contract.
  - File: `skills/shipglows/SKILL.md`
  - Action: Define direct-answer, direct-handoff, ambiguity-question, topology, stop conditions, and final report behavior.
  - Validate with: `rg -n "Direct Handoff|master-skill-in-subagent|entrypoint-routing|sg-build|sg-maintain|sg-bug|sg-deploy|sg-content|sg-skill-build|sg-audit" skills/shipglows/SKILL.md`

- [x] Task 2: Extract shared routing rules.
  - File: `skills/references/entrypoint-routing.md`
  - Action: Define the canonical routing matrix and direct handoff semantics.
  - Validate with: `python3 tools/shipglows_metadata_lint.py skills/references/entrypoint-routing.md`

- [x] Task 3: Publish runtime metadata.
  - File: `skills/shipglows/agents/openai.yaml`
  - Action: Expose `display_name: "shipglows"` for the skill picker.
  - Validate with: `tools/shipglows_sync_skills.sh --check --skill shipglows`

- [x] Task 4: Update help and chantier doctrine.
  - File: `skills/sg-help/SKILL.md`, `skills/references/chantier-tracking.md`, `skills/references/master-delegation-semantics.md`
  - Action: Make `shipglows` discoverable and mark it as non-applicable/helper for chantier tracing.
  - Validate with: `rg -n "shipglows|entrypoint-routing|master-skill-in-subagent|direct handoff" skills/sg-help/SKILL.md skills/references/chantier-tracking.md skills/references/master-delegation-semantics.md`

- [x] Task 5: Update docs and public surfaces.
  - File: `README.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md`, `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md`, `docs/technical/skill-runtime-and-lifecycle.md`, `site/src/content/skills/shipglows.md`
  - Action: Present `shipglows` as the recommended non-technical first command.
  - Validate with: `rg -n "shipglows|ShipGlows primary|direct handoff|sg-build|sg-maintain|sg-bug|sg-deploy|sg-content|sg-skill-build" README.md shipglows_data/workflow/playbooks/spec-driven-workflow.md shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md docs/technical/skill-runtime-and-lifecycle.md site/src/content/skills/shipglows.md`

- [x] Task 6: Validate the skill lifecycle.
  - File: changed skill, reference, spec, docs, and public surfaces
  - Action: Run budget audit, metadata lint, runtime sync check, focused route checks, and site build.
  - Validate with: `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`; `python3 tools/shipglows_metadata_lint.py specs/shipglows-primary-router-skill.md skills/references/entrypoint-routing.md skills/references/master-delegation-semantics.md skills/references/master-workflow-lifecycle.md skills/references/chantier-tracking.md README.md shipglows_data/workflow/playbooks/spec-driven-workflow.md shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md docs/technical/skill-runtime-and-lifecycle.md`; `tools/shipglows_sync_skills.sh --check --skill shipglows`; `pnpm --dir shipglows-site build`

## Acceptance Criteria

- [x] AC 1: Given a non-technical operator invokes `shipglows <instruction>`, when the request is a pure question that needs no file work, then `shipglows` answers directly.
- [x] AC 2: Given the request is a feature, code, docs, or site workstream, when `shipglows` routes, then it hands off to `sg-build`.
- [x] AC 3: Given the request is maintenance, bug-loop, release/deploy, content, skill-maintenance, or obvious audit work, when `shipglows` routes, then it chooses `sg-maintain`, `sg-bug`, `sg-deploy`, `sg-content`, `sg-skill-build`, or the relevant audit skill.
- [x] AC 4: Given multiple routes are plausible, when the answer changes behavior or risk, then `shipglows` asks one short question instead of guessing.
- [x] AC 5: Given a master skill is selected, when execution continues, then the handoff stays in the main conversation and does not launch that master inside a subagent.
- [x] AC 6: Given file work happens after handoff, when subagents are available, then the selected master skill owns delegated sequential execution through the shared delegation reference.
- [x] AC 7: Given current-user runtime sync is checked, then `~/.claude/skills/shipglows` and `~/.codex/skills/shipglows` resolve to the ShipGlows skill directory or the run blocks.
- [x] AC 8: Given public docs build, then `site/src/content/skills/shipglows.md` renders through the skill content collection.
- [x] AC 9: Given validation completes, then budget audit, metadata lint, focused route checks, and site build pass.

## Test Strategy

- Static: run focused `rg` checks for each routing target and the no-nested-master rule.
- Metadata: lint the new spec and reference plus changed docs.
- Skill budget: run the skill discovery budget audit.
- Runtime: run `tools/shipglows_sync_skills.sh --repair --skill shipglows`, then `--check --skill shipglows`.
- Public site: run `pnpm --dir shipglows-site build`.
- Manual scenarios: classify pure question, feature, maintenance, bug, deploy, content, skill-maintenance, audit, and ambiguous requests against the routing matrix.

## Risks

- Security impact: high, because this skill changes how future agents interpret top-level user intent. Mitigation: route only, preserve owner gates, never nest masters in subagents, and ask when routing changes risk.
- Product risk: medium, because the primary entrypoint could overpromise autonomy. Mitigation: public wording says it routes to existing gates and asks when intent is ambiguous.
- Operational risk: medium, because runtime skill visibility depends on symlink sync and session reload. Mitigation: run current-user runtime sync checks and report reload caveat if needed.

## Execution Notes

- Read first: `skills/sg-skill-build/SKILL.md`, `skills/references/master-delegation-semantics.md`, `skills/references/master-workflow-lifecycle.md`, `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md`, `skills/sg-help/SKILL.md`, and representative public skill pages.
- Stop conditions: invalid skill name, runtime sync blocked by non-symlink path, budget audit hard failure, metadata lint failure, site build failure, or docs that imply nested master execution.

## Open Questions

None.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-04 19:35:56 UTC | sg-skill-build | GPT-5 Codex | Created ready spec for the `shipglows` primary router skill from the user-approved plan. | ready | /sg-skill-build shipglows primary router |
| 2026-05-04 19:45:58 UTC | sg-skill-build | GPT-5 Codex | Implemented the `shipglows` primary router, shared entrypoint routing reference, runtime metadata, help/workflow/docs/public surfaces, refresh log entry, and runtime symlink repair. | implemented | /sg-verify specs/shipglows-primary-router-skill.md |
| 2026-05-04 20:02:02 UTC | sg-verify | GPT-5 Codex | Re-verified after cleaning delayed out-of-scope question-format overreach: budget audit, metadata lint, runtime skill sync, focused route checks, stale wording scan, diff whitespace, and Astro site build including `/skills/shipglows/`. | verified | /sg-ship "Add shipglows primary router" |
| 2026-05-04 21:14:01 UTC | sg-ship | GPT-5 Codex | Quick ship requested with commit message `add shipglows primary router`; staged the shipglows primary router scope after checks, then committed and pushed it. | shipped | none |

## Current Chantier Flow

- `sg-spec`: done, ready spec created directly from the user-approved decision-complete plan.
- `sg-ready`: ready by explicit user decisions: invocation key `shipglows`, direct handoff execution, no master-skill-in-subagent nesting.
- `sg-start`: not applicable; implementation is owned by `sg-skill-build`.
- `sg-skill-build`: implemented; created `skills/shipglows/SKILL.md`, `skills/references/entrypoint-routing.md`, runtime metadata, public page, help/workflow/docs updates, and refresh log entry.
- `sg-skills-refresh`: done; local routing/delegation doctrine refresh logged in `skills/REFRESH_LOG.md` with no external URLs needed.
- `runtime skill links`: done; current-user Claude and Codex `shipglows` links resolve to `$SHIPGLOWS_ROOT/skills/shipglows`.
- `skill budget audit`: passed; absolute estimate 7994 / 8000, no hard violations or warnings.
- `sg-verify`: verified; metadata lint, focused route checks, stale wording scan, diff whitespace, and site build passed.
- `sg-end`: not launched.
- `sg-ship`: shipped; quick mode commit + push.
