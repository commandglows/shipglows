---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-07"
updated: "2026-08-07"
status: active
source_skill: 010-sg-technical
scope: clean-code-quality-contract
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/010-sg-technical/SKILL.md
  - skills/102-sg-start/SKILL.md
  - skills/103-sg-verify/SKILL.md
  - skills/106-sg-fix/SKILL.md
  - skills/references/decision-quality-contract.md
depends_on:
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "1.1.0"
    required_status: active
supersedes: []
evidence:
  - "User decision 2026-08-07: make Clean Code principles explicit, pragmatic, and mechanically protected across implementation, fixes, technical audit, and verification."
next_review: "2027-02-07"
next_step: "/103-sg-verify clean-code-quality-contract"
---

# Clean Code Quality Contract

## Purpose

Use this contract for authored or materially modified code. Treat Clean Code as a maintainability heuristic, not a style religion. Correctness, security, privacy, observable behavior, performance requirements, platform constraints, and established project conventions take precedence.

## Observable Gates

- **Intent-revealing names:** use domain language and established conventions; avoid vague names, misleading abbreviations, type noise, and comments needed only to decode a name.
- **Cohesive responsibility:** keep a function, class, component, or module focused on one coherent responsibility and one level of abstraction. “Single responsibility” does not require artificially tiny units.
- **Controlled complexity:** make control flow and state transitions understandable; reduce avoidable nesting, flag arguments, hidden temporal coupling, and oversized branches. Extract only when the result is clearer.
- **Evidence-based abstraction:** remove duplicated knowledge, not every repeated line. Prefer a small amount of honest duplication over a premature or leaky abstraction; use Rule of Three/AHA when project evidence does not already establish the shared concept.
- **Explicit errors and side effects:** validate at trust boundaries, preserve actionable context, make failure/recovery behavior visible, and never silently swallow errors. Keep I/O, mutation, time, randomness, and external calls identifiable and isolate them from pure decisions when that improves reasoning or testing.
- **Useful comments and documentation:** explain why, constraints, invariants, non-obvious trade-offs, or external contracts. Do not narrate obvious code or keep commented-out implementations; follow the project’s public API documentation convention.
- **No unjustified dead code:** do not add unused branches, helpers, dependencies, flags, exports, or compatibility paths. Remove dead code in the owned change surface when proof is sufficient; do not expand scope into speculative cleanup.
- **Behavior-focused tests:** prove public behavior, boundaries, errors, and regressions without coupling tests unnecessarily to private implementation structure. Apply the shared ZOMBIES heuristic when the behavior is non-trivial.

## Proportional Application

Apply every relevant gate to the changed surface, not to the whole repository by default. Generated code, vendored code, framework-required boilerplate, migrations, performance-critical sections, and compatibility adapters may justify exceptions; record the constraint and preserve the strongest safe alternative.

Do not enforce arbitrary function-length, file-length, parameter-count, or complexity numbers unless the project already declares them. Do not perform unrelated refactors merely to improve a cleanliness score.

## Proof Record

For non-trivial implementation, fix, audit, or verification, retain a compact `Clean Code Gate` verdict covering:

`naming · cohesion · complexity · abstraction/duplication · errors/side effects · comments/dead code · behavior-focused proof`

Use `pass`, `partial`, `fail`, or `not applicable`, with evidence for partial/fail and a reason for non-obvious exceptions. A clean lint result is supporting evidence, not proof of readability or cohesion.

Fail or report partial when the change works but leaves misleading structure, swallowed failures, unjustified dead code, a premature abstraction, or complexity that materially weakens safe maintenance.
