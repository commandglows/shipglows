---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: shipglows
created: "2026-08-12"
updated: "2026-08-13"
status: active
source_skill: 102-sg-start
scope: 102-sg-start-execution-contract
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/102-sg-start/SKILL.md
  - skills/references/context-quality-contract.md
depends_on:
  - artifact: skills/references/context-quality-contract.md
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "START-DIRECT and START-SPEC-FIRST derive contracts before topology or mutation."
next_step: none
---

# Execution Contract

Material execution consumes a current bounded capsule from `301-sg-context`, refreshes it on Git/task invalidation, and preserves reasons, gaps and truncation. Direct micro-work may stay targeted.

Derive this contract before model selection, delegation, or writes.

For `direct`, record a silent mini-contract: trigger/input, observable success, expected failures, easiest missed edge case, target files, constraints, linked systems, documentation impact, proof path, validation, and stop conditions.

For `spec-first`, read the ready spec fully and preserve its metadata/version, user story, minimal/success/error behavior, tasks, acceptance criteria, dependencies, invariants, non-goals, linked systems, documentation obligations, execution batches, proof path, and unresolved risks. Reroute to readiness when required fields are absent, stale, incompatible, or contradict current canonical contracts.

Select `test-first`, `regression-first`, `scenario-first`, `evidence-first`, or `exception-with-proof`; map meaningful ZOMBIES cases for non-trivial behavior. Select bounded or full validation proportionally.

Determine applicable context before writing: project development mode and validation surface, external-doc freshness, Atlas registrations, product-decision impacts, security/abuse constraints, UI token source, runtime diagnostics/Sentry, Supabase client and policy boundaries, tracker write target, and required browser/auth/manual/hosted proof owner.

When those decisions depend on authority, freshness, memory, conflict, compaction, or handoff, load `skills/references/context-quality-contract.md`. Preserve its `Context Capsule`, revalidate invalidated claims before writes, and stop dependent mutation on unresolved target, material `context_partial`, `context_conflict`, or `context_stale` truth.

Record auto-verify eligibility and the exact expected report value. External or user-dependent proof must be `auto-verify: skipped` with owner, scenario, and target/environment.

Read only target entry points, tests, and linked consumers capable of changing correctness. If implementation tasks could pass while the user promise fails, stop and repair the contract rather than coding the proxy.
