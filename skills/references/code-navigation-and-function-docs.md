---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-04"
updated: "2026-07-04"
status: active
source_skill: 102-sg-start
scope: code-navigation-and-function-documentation
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/technical-docs-corpus.md
  - skills/references/documentation-governance-rules.md
  - skills/references/project-governance-rules.md
  - skills/300-sg-docs/SKILL.md
  - templates/technical_behavior_index.md
  - shipglows_data/technical/code-docs-map.md
depends_on:
  - artifact: "skills/references/technical-docs-corpus.md"
    artifact_version: "1.7.0"
    required_status: active
  - artifact: "skills/references/documentation-governance-rules.md"
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Ready spec shipglows-code-navigation-and-function-documentation-system.md."
  - "WinFlowz IME swipe investigation showed repeated rediscovery cost across code, docs, specs, and bugs."
  - "Operator clarification 2026-07-01: existing context maps must stay and be integrated."
next_review: "2026-08-04"
next_step: "/300-sg-docs technical audit"
---

# Code Navigation And Function Documentation

## Purpose

This reference defines the ShipGlows standard for recovering code from operator language or product behavior without broad rediscovery.

Use it when the task starts from terms such as `swipe`, `sync`, `checkout`, `auth`, `export`, or `theme` rather than from a known file path.

## Layer Model

The navigation stack has distinct layers. Do not collapse them into one mega-doc.

1. `context.md`
   - owns the operational/system overview
   - answers "what are the major technical surfaces here?"
2. `context-function-tree.md`
   - owns the structural and function-tree overview
   - answers "where do the main entrypoints and feature trees live?"
3. `code-docs-map.md`
   - owns path-to-doc routing
   - answers "if I know the code path, which technical doc and validation surface apply?"
4. behavior index or domain-model doc
   - owns term-to-behavior recovery
   - answers "if the operator says a behavior word, what concrete meanings, files, symbols, tests, and decisions does it map to?"
5. source comments
   - own local symbol contracts and invariants for high-cognitive-load code
   - answer "now that I am in the file, what must stay true here?"
6. decision records
   - own durable rationale that should not live in comments or specs
   - answer "why does this behavior exist this way?"

## Resolution Flow

When the operator gives a behavior term:

```text
operator term
  -> context.md for surface orientation when needed
  -> context-function-tree.md for structural orientation when needed
  -> behavior index / domain model for term disambiguation
  -> code-docs-map.md for path/doc routing
  -> source code entrypoints and key symbols
  -> tests / specs / bugs / decisions
```

Do not start with broad `rg` if the technical navigation layer already covers the term.

When the message includes an explicit `#feature:<term>` token, treat it as a high-priority navigation hint: load the behavior index or domain-model layer before broad repository search, keep the free-text request active, and ignore malformed variants that do not match the explicit form.

## Behavior Index Contract

Create a behavior index when:

- one operator term can mean multiple behaviors
- the behavior crosses docs, code, tests, specs, and bugs
- the recovery cost is high enough that agents are likely to repeat the same search
- the subsystem is product-critical, platform-critical, security-sensitive, or cognitively dense

Do not create one-doc-per-function indexes.

Each behavior index should include:

- aliases and operator terms
- ambiguity handling
- named behaviors
- primary entrypoints
- key files and symbols
- linked tests
- linked specs/bugs
- linked decisions or an explicit `no durable decision record needed`
- maintenance rule

There must be one canonical owner artifact per behavior family.

## Source Comment Contract

Comments are required only for high-cognitive-load symbols such as:

- arbitration or dispatch logic
- gesture/state/lifecycle invariants
- security or permission boundaries
- concurrency or persistence guarantees
- non-obvious product behavior
- error recovery behavior

Comments should state:

- contract
- invariants
- related symbol or doc when that speeds recovery

Comments should not:

- narrate line-by-line implementation
- duplicate the whole behavior doc
- restate obvious code
- contain secrets, raw logs, private payloads, or stale walkthroughs

## ADR Boundary

Use a decision record when the behavior exists because of a durable product, technical, privacy, or platform decision that future agents would otherwise reconstruct from old specs or bug threads.

Use comments instead when the knowledge is local to one symbol contract.

Use the behavior index instead when the need is navigation across files and artifacts.

## Drift And Bootstrap Classification

Use these classifications precisely:

- `technical navigation bootstrap gap`
  - no behavior index exists for a term family that clearly needs one
- `technical navigation drift`
  - mapped files, symbols, tests, specs, or docs are stale or missing
- `term ambiguity handled`
  - the term maps to multiple valid behaviors and the index names them
- `no durable decision record needed`
  - the behavior is implementation-local and does not justify an ADR

## Security Rules

- Never persist secrets, tokens, cookies, private URLs, raw logs, private screenshots, or user data in behavior docs or comments.
- Redact or stop when the only useful example would expose sensitive data.
- Behavior docs may reference proof or incidents, but they should link to the owning artifact instead of copying sensitive payloads.

## Audit Expectations

`300-sg-docs technical audit` should verify:

- context layer roles remain clear
- behavior indexes exist for mapped high-recovery-cost behaviors
- ambiguous terms are called out instead of silently merged
- key symbols linked from a behavior index have comment coverage when their logic is cognitively dense
- linked tests/specs/shipglows_data/workflow/bugs/decisions still resolve
- stale navigation is reported as drift, not silently ignored

## Maintenance Rule

Update this reference when ShipGlows changes the layer model, behavior-index contract, comment boundary, drift taxonomy, or audit expectations.
