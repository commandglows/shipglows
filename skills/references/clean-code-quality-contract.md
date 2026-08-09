---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-07"
updated: "2026-08-08"
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
  - skills/references/zombies-edge-case-heuristic.md
  - skills/references/owasp-application-security-awareness.md
  - tools/test_clean_code_quality_contract.py
depends_on:
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "1.2.0"
    required_status: active
  - artifact: "skills/references/zombies-edge-case-heuristic.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/owasp-application-security-awareness.md"
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "User decision 2026-08-07: make Clean Code principles explicit, pragmatic, and mechanically protected across implementation, fixes, technical audit, and verification."
  - "Operator decision 2026-08-08: generated code uses immutable short domain identifiers for stable vocabularies while technical instances retain UUID/ULID or equivalent identities."
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

## Domain Identifier Gate

Apply this gate when authored or materially modified code introduces or changes a stable machine-readable vocabulary: formats, placements, categories, platforms or channels, statuses, error types, capabilities, workflow actions, or another durable set of shared concepts.

Keep three identity layers distinct:

- A **technical instance ID**, such as a UUID or ULID, identifies one record, event, job, session, file, or other instance.
- A short **canonical domain code** identifies a shared concept. Default to readable ASCII uppercase segments separated by `_` and prefixed by the owning domain, such as `FMT_REEL` or `PLC_REEL_COVER`. Do not impose one universal length limit.
- A mutable **localized label**, description, slug, or other presentation value is resolved from the canonical code and is never used as machine identity.

A canonical code becomes immutable once it is persisted, published in an API, exported, logged as a contract, or consumed by another surface. It is nontranslated, is never renamed after that boundary, and is never recycled after deprecation or retirement. An unpublished draft code may change before durable use.

Each domain owns a small versioned registry and its migrations; shared code owns validation conventions only. A domain-owned registry declares `domain`, `namespace`, `owner`, and `version`. Every entry declares `code`, lifecycle `status`, and `introduced_in`; localized labels and aliases are optional presentation or compatibility metadata. A deprecated or retired entry declares `deprecated_in`, may name a valid `replaced_by`, and remains as a reserved tombstone when no successor exists. Do not create a universal EAV registry or a generic mega-registry that erases domain ownership.

Aliases are bounded, input-only migration mechanisms. Each alias has a compatibility owner and a proof-based removal criterion. New writes, APIs, storage, exports, and machine comparisons use only canonical codes. Validate empty or malformed codes, duplicate codes, alias-to-code collision, and ambiguous aliases deterministically. A `replaced_by` value, when present, resolves to a suitable canonical code in the same registry; missing targets, self-replacements, and alias or replacement cycles fail deterministically. At a trust boundary, an unknown value is either rejected with an actionable error or represented explicitly as `unknown` under a declared forward-compatibility contract; never guess identity from a localized label.

Adopt the rule prospectively. When an existing stable vocabulary is materially changed, migrate additively and reversibly: inventory legacy values, add canonical fields or mappings, retain bounded dual-read compatibility, backfill, prove compatibility, switch all new writes and outputs to canonical codes, then retire the legacy path. Never delete the first legacy representation before migration proof is complete.

Readable role, permission, or capability codes do not grant access by their shape. Alias normalization must not widen privileges; authoritative server-side authorization and tenant policy remain decisive.

Exceptions must preserve the strongest safe alternative and be explicit: do not rewrite external or vendor identifiers, generated identifiers, protocol-defined identifiers, or an identifier shape required by a project-documented constraint. When the product also owns stable domain meaning around such a value, isolate the external form and map it to the domain-owned canonical code instead of conflating the two identities.

Pressure scenarios:

- `ID-LABEL-LOCALE`: copy or locale changes while the canonical code remains stable.
- `ID-ALIAS-MIGRATION`: legacy input resolves through an alias while every output uses the canonical code.
- `ID-DEPRECATE-REPLACE`: a deprecated code keeps lifecycle metadata, an optional replacement, and a non-recycled tombstone.
- `ID-TECHNICAL-INSTANCE`: distinct UUID/ULID instances may share one domain code.
- `ID-COLLISION`: duplicate codes, alias collisions, and cycles fail before generation or migration proceeds.
- `ID-UNKNOWN`: unknown input is rejected or explicitly represented according to the consumer contract, never inferred from a label.
- `ID-REGISTRY-OWNERSHIP`: domains keep separate owners and registries while sharing validation rules.
- `ID-ADDITIVE-MIGRATION`: legacy values remain readable through bounded compatibility until backfill and proof permit retirement, while all new writes and outputs use canonical codes.
- `ID-AUTHORIZATION-BOUNDARY`: readable codes and alias normalization never grant or widen access; authoritative server-side policy remains decisive.
- `ID-EXTERNAL-MAPPING`: vendor, generated, protocol-defined, or project-constrained identifiers retain their required shape and map separately to product-owned domain meaning when needed.

## Proportional Application

Apply every relevant gate to the changed surface, not to the whole repository by default. Generated code, vendored code, framework-required boilerplate, migrations, performance-critical sections, and compatibility adapters may justify exceptions; record the constraint and preserve the strongest safe alternative.

Do not enforce arbitrary function-length, file-length, parameter-count, or complexity numbers unless the project already declares them. Do not perform unrelated refactors merely to improve a cleanliness score.

## Proof Record

For non-trivial implementation, fix, audit, or verification, retain a compact `Clean Code Gate` verdict covering:

`naming · cohesion · complexity · abstraction/duplication · errors/side effects · comments/dead code · behavior-focused proof`

Use `pass`, `partial`, `fail`, or `not applicable`, with evidence for partial/fail and a reason for non-obvious exceptions. A clean lint result is supporting evidence, not proof of readability or cohesion.

When the Domain Identifier Gate applies, also retain a compact `Domain Identifier Gate` verdict covering:

`applicability · identity separation · code stability/format · registry ownership/versioning · lifecycle/aliases · unknowns/collisions · migration · authorization boundary · proof`

Fail or report partial when the change works but leaves misleading structure, swallowed failures, unjustified dead code, a premature abstraction, or complexity that materially weakens safe maintenance.
