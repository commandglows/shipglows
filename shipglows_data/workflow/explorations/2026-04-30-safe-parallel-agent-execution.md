---
artifact: exploration_report
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-04-30"
updated: "2026-04-30"
status: draft
source_skill: sg-explore
scope: safe-parallel-agent-execution
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/sg-spec/SKILL.md
  - skills/sg-ready/SKILL.md
  - skills/sg-start/SKILL.md
  - skills/sg-build/SKILL.md
  - specs/sg-build-autonomous-master-skill.md
  - shipglows_data/workflow/playbooks/spec-driven-workflow.md
evidence:
  - "OpenAI Codex subagents docs: subagents can run in parallel and Codex consolidates results."
  - "OpenAI Codex subagents docs: Codex only spawns subagents when explicitly asked; subagents inherit sandbox and approval controls."
  - "skills/sg-start/SKILL.md already requires explicit file ownership and forbids same writable file across subagents."
  - "skills/sg-spec/SKILL.md requires file/action/Depends on/Validate with, but does not require an execution batch graph or write-set exclusivity matrix."
depends_on: []
supersedes: []
next_step: "/sg-spec safe parallel agent execution graph"
---

# Safe Parallel Agent Execution

## Starting Question

Can ShipGlows safely optimize speed with parallel Codex subagents while keeping a zero-risk editing-conflict posture?

## Context Read

- `skills/sg-start/SKILL.md` - confirmed execution-time guardrails already require disjoint file ownership for multi-agent work.
- `skills/sg-spec/SKILL.md` - confirmed spec tasks define files, dependencies and validation, but not an auditable execution batch graph.
- `skills/sg-ready/SKILL.md` - identified the likely gate that should reject unsafe parallel plans before execution.
- `specs/sg-build-autonomous-master-skill.md` - provided a concrete example where many tasks target the same skill contract.

## Internet Research

- [OpenAI Codex subagents](https://developers.openai.com/codex/subagents) - Accessed 2026-04-30 - Confirmed Codex can run specialized subagents in parallel and consolidate results.
- [OpenAI Codex CLI](https://developers.openai.com/codex/cli) - Accessed 2026-04-30 - Confirmed the relevant local execution context and current Codex CLI behavior.

## Problem Framing

Parallel subagents can reduce elapsed time, but ShipGlows needs the spec layer to make write-set boundaries explicit before execution. Without that contract, `sg-start` may infer parallelism from an ordered task list that is not actually conflict-safe.

## Short Answer

Yes, Codex can run parallel subagents. The current ShipGlows execution layer already has good guardrails in `sg-start`, but the spec layer is not strict enough yet. `sg-spec` asks for ordered tasks with a target file and `Depends on`, but it does not force a formal execution graph that proves:

- which tasks may run in parallel,
- which tasks must run sequentially,
- exact write ownership per batch,
- shared files that must remain with the main agent,
- read-only context files,
- integration ownership,
- and stop conditions when overlap is detected.

The gap is not "Codex cannot do it"; the gap is "ShipGlows specs do not yet make parallel safety mechanically auditable before execution."

## Current State

### Codex Capability

Official OpenAI Codex docs say Codex can spawn specialized agents in parallel and collect their results into one response. Current Codex releases enable this by default. The docs also state that Codex only spawns subagents when explicitly asked, and that subagents inherit the current sandbox policy and approval controls.

Relevant docs:

- https://developers.openai.com/codex/subagents
- https://developers.openai.com/codex/cli

Important local version observed:

- `codex-cli 0.125.0`

### ShipGlows Strengths

`skills/sg-start/SKILL.md` already contains the right execution-time posture:

- choose `single-agent` vs `multi-agent`,
- prefer single-agent for coupled changes,
- prefer multi-agent only when write sets are mostly disjoint,
- create at most 2-4 groups,
- require explicit file ownership,
- never assign the same writable file to multiple subagents,
- keep shared files, final wiring, and conflict resolution with the main agent,
- fall back to single-agent when boundaries are fuzzy.

This is the strongest part of the current system.

### ShipGlows Gap

`skills/sg-spec/SKILL.md` requires every implementation task to include:

- file,
- action,
- user story link,
- dependency,
- validation.

That is necessary, but not sufficient for zero-conflict parallelism.

The current spec format can produce a list like:

```text
Task 1 -> skills/sg-build/SKILL.md
Task 2 -> skills/sg-build/SKILL.md
Task 3 -> skills/sg-build/SKILL.md
Task 4 -> skills/sg-build/SKILL.md
Task 9 -> skills/sg-help/SKILL.md, shipglows_data/workflow/playbooks/spec-driven-workflow.md, README.md
```

This is ordered, but not parallel-safe. Many tasks target the same file, and one task can name several files. A fresh executor can infer sequencing, but the spec does not force an explicit graph.

## Risk Model

The dangerous failure mode is:

```text
Spec tasks look ordered
        |
        v
sg-start sees "multi-agent" opportunity
        |
        v
two agents touch same file or hidden shared contract
        |
        v
merge conflict, subtle overwrite, duplicated logic, stale context, or wrong integration
```

Even without a Git conflict, the real risk is semantic conflict:

- one agent edits a skill contract,
- another edits docs that describe the older contract,
- a third edits tests/checks against a different assumption,
- everything merges cleanly but the workflow is incoherent.

## Option Space

### Option A: Keep Parallel Safety In `sg-start` Only

- Summary: Let execution-time instructions infer whether subagents are safe.
- Pros: No extra spec burden.
- Cons: Safety remains partly implicit and hard to review before execution.

### Option B: Add Explicit Execution Batches To Specs

- Summary: Require specs to define sequential and parallel batches with write files, read-only context, dependencies and shared-file reservations.
- Pros: Makes parallel safety auditable before execution.
- Cons: Adds structure to non-trivial specs.

### Option C: Ban Parallel Agents For ShipGlows Chantiers

- Summary: Keep all implementation in one main agent.
- Pros: Lowest merge-conflict risk.
- Cons: Gives up useful speed when write sets are genuinely disjoint.

## Comparison

Option B is the best balance: it preserves speed for genuinely independent work while giving `sg-ready` and `sg-start` a concrete graph to inspect. Option A is too implicit for zero-conflict guarantees, and Option C is unnecessarily slow for broad but separable work.

## Emerging Recommendation

Add an `Execution Batches` contract to non-trivial specs, then make `sg-ready` reject unsafe batch graphs before `sg-start` can delegate work.

## Recommended Rule

Parallel execution should be allowed only when the spec contains an explicit `Execution Batches` section.

Proposed contract:

```markdown
## Execution Batches

- Batch A: Foundation, sequential
  - Agent: main
  - Write files:
    - `skills/sg-build/SKILL.md`
  - Read-only context:
    - `skills/sg-start/SKILL.md`
    - `skills/sg-ready/SKILL.md`
  - Depends on: None
  - Parallel safe with: None
  - Reason: shared contract file, integration-critical

- Batch B: Docs, parallel-safe after Batch A
  - Agent: worker
  - Write files:
    - `README.md`
    - `shipglows_data/workflow/playbooks/spec-driven-workflow.md`
  - Read-only context:
    - `skills/sg-build/SKILL.md`
  - Depends on: Batch A
  - Parallel safe with: Batch C
  - Reason: docs-only after contract is stable

- Shared files reserved for main agent:
  - `TASKS.md`
  - `CHANGELOG.md`
  - any file already dirty outside the chantier scope
```

## Hard Gate

`sg-ready` should reject a non-trivial multi-agent spec if:

- no `Execution Batches` section exists,
- any batch has overlapping write files with another batch,
- a batch writes a file that is also listed as read-only elsewhere without dependency ordering,
- a batch has multiple write files without explaining why they are one atomic group,
- shared files are not explicitly reserved for the main agent,
- the dependency graph has a cycle,
- a task marked parallel-safe depends on an unfinished task,
- validation is only global and cannot identify which batch caused a failure.

## Recommended Execution Policy

Use this decision tree:

```text
Is the task small or same 1-3 files?
        |
        +-- yes --> single-agent
        |
        +-- no
             |
             v
Does the spec define execution batches?
        |
        +-- no --> not ready / route back to sg-spec
        |
        +-- yes
             |
             v
Do write sets overlap?
        |
        +-- yes --> sequential or main-agent only
        |
        +-- no
             |
             v
Do batches share hidden contracts or ordering?
        |
        +-- yes --> DAG order, no parallel until dependency done
        |
        +-- no --> parallel allowed
```

## Concrete Recommendation

Create a follow-up spec to upgrade ShipGlows's spec/readiness contract:

```text
/sg-spec safe parallel agent execution graph
```

Scope should include:

- update `sg-spec` to require `Execution Batches` for non-trivial multi-agent work,
- update `sg-ready` to reject unsafe or missing batch graphs,
- update `sg-start` to consume the batch graph instead of deriving everything ad hoc,
- update `shipglows_data/workflow/playbooks/spec-driven-workflow.md`,
- optionally add a tiny lint/check script later, but only after the markdown contract is stable.

## Exploration Status

This is not an implementation. No specs or skills were modified by this exploration.

## Non-Decisions

- No final schema for `Execution Batches` was implemented.
- No skill files were modified during the exploration.
- No lint script was designed beyond the possible future idea.

## Rejected Paths

- Relying only on ordered task lists - rejected because ordered lists do not prove parallel safety.
- Banning parallel agents globally - rejected because disjoint work can still be useful and safe.

## Risks And Unknowns

- The right strictness level for small specs is still open.
- A batch graph could become busywork if required for trivial single-file changes.
- Hidden shared contracts can still exist even when file write sets are disjoint.

## Redaction Review

- Reviewed: yes
- Sensitive inputs seen: none
- Redactions applied: none
- Notes: The report cites public documentation URLs and local ShipGlows file paths only.

## Decision Inputs For Spec

- User story seed: As a ShipGlows maintainer, I want specs to describe safe execution batches so parallel agents can be used without write conflicts or semantic drift.
- Scope in seed: `sg-spec`, `sg-ready`, `sg-start`, workflow docs, and examples for batch graphs.
- Scope out seed: building an automated linter before the markdown contract is stable.
- Invariants/constraints seed: never assign overlapping write files to parallel agents; reserve shared files for the main agent; reject unsafe or cyclic dependency graphs.
- Validation seed: inspect a spec with overlapping write sets and confirm readiness rejects it; inspect a spec with disjoint batches and confirm execution can delegate safely.

## Handoff

- Recommended next command: `/sg-spec safe parallel agent execution graph`
- Why this next step: The exploration produced a clear policy direction that affects several lifecycle skills and needs a proper implementation contract.

## Exploration Run History

| Date UTC | Prompt/Focus | Action | Result | Next step |
|----------|--------------|--------|--------|-----------|
| 2026-04-30 | Safe parallel agent execution | Compared Codex subagent capability with ShipGlows spec/start guardrails | Recommended explicit execution batches before parallel delegation | `/sg-spec safe parallel agent execution graph` |
