---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: "ShipGlows"
created: "2026-06-27"
updated: "2026-07-28"
status: active
source_skill: 102-sg-start
scope: task-application-loop
owner: "Diane"
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - "skills/102-sg-start/SKILL.md"
  - "skills/106-sg-fix/SKILL.md"
  - "skills/900-shipglows-core/SKILL.md"
  - "skills/103-sg-verify/SKILL.md"
depends_on:
  - artifact: "skills/references/spec-driven-development-discipline.md"
    artifact_version: "1.5.0"
    required_status: active
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "1.1.0"
    required_status: active
supersedes: []
evidence:
  - "Extracted from auditing OpenSpec's apply-change skill as a reusable execution-fidelity pattern."
next_review: "2026-07-27"
next_step: "Inject into execution and verification skills when they own task-by-task implementation."
---

# Task Application Loop

## Purpose

This reference defines the reusable ShipGlows loop for applying a bounded task list without losing the user story, context, progress state, or proof requirement.

Use it when a skill implements tasks, direct fixes, skill contract edits, or other stepwise changes where completion can drift into checkbox-only work.

## Loop Contract

Before editing:

- identify the target work item from the user request, spec, bug record, or ready artifact
- inspect current state and progress before choosing the next task
- load the context files named by the work item, plus any required ShipGlows references
- derive the proof path from `spec-driven-development-discipline.md`
- stop if the work item, context, user outcome, or proof path is ambiguous in a way that changes behavior, security, data handling, public promise, or external side effects

During implementation:

- work one task or repair slice at a time
- preserve the user story outcome over task checkbox completion
- keep each edit bounded to the active slice unless integration requires a shared edit
- update durable progress immediately after a slice is actually complete, not before
- re-read mutable trackers or records immediately before changing them
- pause when implementation reveals a contract, design, security, data, or proof gap
- for recurring lifecycle work, close only the current dated instance and preserve the reusable definition plus the next occurrence
- for cybersecurity work, keep evidence redacted and route implementation findings through the technical execution tracker

Before claiming completion:

- compare completed slices against the user story or source contract
- run or route the named proof path
- record any remaining proof gap with owner, scenario, and target/environment when applicable
- report progress as state plus evidence, not as unchecked confidence

## Progress Semantics

Use explicit state instead of vague completion language:

- `not started`: no implementation slice has been safely applied
- `in progress`: at least one slice is applied and more implementation remains
- `implemented`: all implementation slices in the current owner scope are complete
- `partial`: implementation itself is incomplete or blocked
- `blocked`: continuing would require missing context, unsafe action, unresolved ambiguity, or unavailable required proof
- `verified`: the required proof path has passed for the changed surface

Implementation completion and verification are separate. A skill may report `implemented` while routing remaining hosted, manual, provider, browser, or device proof to the proper owner.

## Stop Conditions

Stop, reroute, or report `blocked` when:

- no reliable target work item can be identified
- the next slice would satisfy a checkbox while missing the promised user outcome
- required context files or required ShipGlows references are missing
- the implementation path becomes a shortcut that weakens correctness, security, performance, maintainability, durability, excellence, or proof quality
- a progress update would rewrite stale tracker state
- the proof path cannot be named, run, or routed
- a newly discovered contract gap belongs in a spec, bug record, design decision, public promise, or owner skill before coding can continue

## Verification Hooks

Verification should check:

- target state was inspected before editing
- required context was loaded before implementation
- progress updates followed actual completed slices
- the final report names the proof run or remaining proof route
- `implemented`, `partial`, `blocked`, and `verified` are not conflated
