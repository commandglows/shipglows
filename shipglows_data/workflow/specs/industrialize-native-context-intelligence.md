---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-08-30"
created_at: "2026-08-30 20:04:13 UTC"
updated: "2026-08-30"
updated_at: "2026-08-30 21:37:23 UTC"
status: reviewed
source_skill: 100-sg-spec
source_model: gpt-5.6
scope: industrialize-native-context-intelligence
owner: Diane
confidence: high
user_story: "As a ShipGlows operator, I want agents to receive a fresh, task-scoped and dependency-aware context automatically so they can execute and resume complex work without reconstructing the repository or relying on a third-party context service."
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - tools/code_context_graph.py
  - tools/context_history.py
  - skills/301-sg-context/SKILL.md
  - skills/references/context-history-and-head.md
  - skills/references/context-quality-contract.md
  - skills/references/skill-invocation-registry.json
  - shipglows_data/technical/native-code-context-graph.md
  - shipglows_data/technical/code-docs-map.md
  - shipglows_data/workflow/history/
depends_on:
  - artifact: skills/references/context-quality-contract.md
    artifact_version: "1.4.0"
    required_status: active
  - artifact: skills/references/context-history-and-head.md
    artifact_version: "1.2.0"
    required_status: active
  - artifact: shipglows_data/technical/native-code-context-graph.md
    artifact_version: "1.1.0"
    required_status: active
supersedes: []
evidence:
  - "Commit 050e1d9 added the deterministic native code graph and bounded queries."
  - "Commit 83c6ca9 combined recent semantic history with the native graph in Context Head."
  - "The ContentGlows trash pilot indexed 983 files, 9,947 nodes and 13,100 edges, and resolved exact content-assets, video-timelines and status-API seeds without truncation."
  - "Operator decision 2026-08-30: build an evolutionary proprietary ShipGlows system inspired by Vexp rather than depend on an external service."
next_step: "Monitor measured context noise and parser misses before proposing any retrieval expansion."
---

# Title

Industrialize native context intelligence

# Status

Reviewed. The native graph and Context Head foundations are industrialized on `main` through an incremental index, explainable bounded capsule, automatic lifecycle adoption, diagnostics, aggregate evaluation and explicit native fallback.

# User Story

As a ShipGlows operator, I want agents to receive a fresh, task-scoped and dependency-aware context automatically so they can execute and resume complex work without reconstructing the repository or relying on a third-party context service.

# Minimal Behavior Contract

When a ShipGlows-owned workflow starts or resumes material work in an adopted repository, it resolves the exact project and task, refreshes only invalidated graph observations, selects a bounded context capsule from canonical sources, code relationships and significant history, and exposes its evidence state to the consuming agent. Missing tooling, incomplete relationships, stale observations, parallel worktree changes or an oversized neighborhood degrade to an explicit targeted fallback or a blocking context verdict; they never silently produce apparently complete context.

# Success Behavior

- A normal owner-skill invocation obtains one reproducible capsule without requiring the operator to invoke an internal context command.
- The capsule names target, accepted outcome, invariants, canonical evidence, relevant files/symbols/interfaces, recent decisions, uncertainty, truncation and next safe action.
- Incremental refresh invalidates changed, deleted and newly discovered supported files without rebuilding unrelated observations.
- Symbol and interface relationships can explain why a file was selected and which downstream consumers require revalidation.
- Worktree and branch identity remain explicit; parallel work does not contaminate another task's current context.
- Repeated runs measure relevance, missed dependencies, noise, latency and fallback rate without collecting source bodies, secrets or user content.
- A fresh agent can resume from the capsule, revalidate decision-changing claims and execute the ready spec without conversation history.

# Error Behavior

- Unresolved project/task identity returns `context_partial`; a material unresolved target prevents dependent mutation under the context-quality stop conditions rather than introducing a second blocking verdict vocabulary.
- A stale graph, unsupported language construct, missing seed or truncated neighborhood remains visible with the exact fallback used.
- Cache corruption, path escape, symlink/junction ambiguity, schema incompatibility or secret-like persisted content fails closed with a bounded redacted diagnostic.
- An unavailable graph never makes significant history unreadable; canonical targeted retrieval remains available.
- Context generation cannot authorize mutation, upgrade hypotheses to facts or override Git, source, specs, runtime state or governed project truth.

# Problem

ShipGlows now has the correct primitives but not yet a complete operating system for context. `tools/code_context_graph.py` builds and queries a disposable graph; `tools/context_history.py` combines recent events and a small graph projection; `301-sg-context` documents how an agent may consume them. The normal lifecycle does not yet guarantee automatic task seeding, incremental graph freshness, symbol-level invalidation, explainable selection, quality telemetry, cross-project proof or consistent handoff consumption. Agents can therefore still reconstruct too much context manually, miss dynamic relationships, or use the foundation only when they already know it exists.

# Solution

Evolve the existing local-first primitives into one proprietary context-intelligence pipeline rather than introduce a second database or an external service. Add a versioned task capsule contract, incremental graph store and change invalidation, dependency-aware ranked retrieval, automatic lifecycle hooks, quality evaluation fixtures and bounded operator diagnostics. Canonical artifacts remain authoritative; the graph, rankings, telemetry and Context Head remain derived and replaceable.

# Scope In

- versioned task-scoped context capsule schema and deterministic renderer
- incremental indexing of changed, deleted and newly supported files
- symbol/interface-aware staleness and downstream revalidation hints
- ranked, bounded, explainable retrieval from task text, explicit seeds, Git diff, history refs and graph relationships
- automatic consumption by context, readiness, execution, verification, continuation and handoff paths
- repository/worktree isolation and safe cross-project pointers where an explicit relationship exists
- local quality telemetry and repeatable evaluation on ShipGlows plus at least two structurally different managed projects
- CLI/operator diagnostics for status, freshness, selected evidence, truncation and fallback, without exposing internal reasoning
- technical documentation, code/docs ownership and installation/runtime synchronization

# Scope Out

- copying Vexp internals, protocol, branding or proprietary implementation
- purchasing, embedding or depending on Vexp or another hosted context provider
- replacing specs, Git, source code, runtime registries or governed documents as canonical truth
- storing full source bodies, prompts, transcripts, credentials, production payloads or private user data in the graph or telemetry
- autonomous code mutation or permission expansion based on graph output
- semantic/vector infrastructure before deterministic retrieval metrics prove a concrete miss that bounded structural retrieval cannot solve
- a graphical knowledge-map UI

# Constraints

- Local-first and provider-independent operation is mandatory.
- Default work must remain bounded in files, nodes, depth, characters, time and persisted size; every cap reports truncation.
- The system must degrade to focused native source/Git retrieval when the context engine is absent or incomplete.
- Derived data must be reproducible or safely discardable, schema-versioned and isolated per repository/worktree.
- New machinery must replace demonstrated manual reconstruction or missed-context burden; it must not add ceremony to small deterministic tasks.
- Windows and Linux path semantics, case handling and ignored/generated directories must remain deterministic.
- Public changelog projections continue to use their existing allowlist; context telemetry and raw graph data never become public content.

# Test Contract

The primary proof surface is deterministic Python contract and integration tests. Run focused unit tests for graph/index/capsule behavior first; lifecycle invocation and fallback contracts second; repository pilots and performance budgets third; metadata, dependency graph, runtime-sync and `git diff --check` last. Browser, authentication and provider tests are not required because this chantier has no browser or external-provider behavior. Manual proof is limited to inspecting one human-readable capsule and one redacted diagnostic per pilot.

# Pilot Corpus

- **ShipGlows:** implementation repository and full before/after evaluation target.
- **ContentGlows:** reuse the accepted 2026-08-30 baseline as historical evidence. Any current-state comparison is strictly read-only, writes no cache or fixture into ContentGlows, and never changes its source, governance or Git state.
- **CommunityGlows:** second contrasting read-only pilot. Its TypeScript/Vue browser-extension structure intentionally exercises unsupported-language visibility and targeted fallback; this chantier writes no cache, fixture, source, governance or Git state into CommunityGlows.

Persist only bounded redacted expected-result fixtures inside ShipGlows. Pilot execution must direct disposable output to a ShipGlows-owned ignored or temporary location and must verify the external pilot worktrees remain unchanged. Parser expansion is not implied by pilot selection and remains evidence-gated.

# Dependencies

- Existing graph: `tools/code_context_graph.py` and `tools/test_code_context_graph.py`.
- Existing history/head: `tools/context_history.py`, its tests and `skills/references/context-history-and-head.md`.
- Context authority and verdict vocabulary: `skills/references/context-quality-contract.md`.
- Lifecycle owners: `301-sg-context`, `101-sg-ready`, `102-sg-start`, `103-sg-verify`, `303-sg-resume`, `706-continue` and agent handoff references as actually resolved during implementation.
- Invocation ownership and activation budgets: `skills/references/skill-invocation-registry.json` and its executable validation tools.

# Invariants

- Canonical truth always outranks caches, memories, graph edges, rankings and telemetry.
- Retrieval relevance never implies mutation authority or proof of ownership.
- Every selected item is explainable by a seed, edge, canonical pointer or invalidation dependency.
- Evidence certainty survives generation, compaction and handoff unchanged.
- Missing or unsupported relationships are explicit; completeness is never claimed from a partial parser.
- Parallel branches and worktrees cannot overwrite each other's derived current state.
- Small tasks can bypass durable indexing when targeted native reads are cheaper and equally safe.

# Links & Consequences

- `tools/code_context_graph.py` becomes the incremental structural discovery owner; its schema and CLI compatibility require migration tests.
- `tools/context_history.py` consumes the capsule/index API rather than owning a second retrieval algorithm.
- `skills/301-sg-context/SKILL.md` remains the context verdict owner while normal lifecycle owners consume its compact contract automatically.
- Readiness, execution, verification, resume and handoff consumers must preserve capsule evidence states and must be revalidated after contract changes.
- `skill-invocation-registry.json` and activation budgets must include only resources actually required at each lifecycle boundary.
- Installer/runtime-sync proof must ensure the linked development channel and installed ShipGlows runtime expose the same tools and references.
- Existing event history remains immutable; schema evolution applies to new derived caches and new events only when explicitly versioned.

# Documentation Coherence

Update `shipglows_data/technical/native-code-context-graph.md`, `skills/references/context-history-and-head.md`, `skills/references/context-quality-contract.md` only where behavior changes, and refresh `shipglows_data/technical/code-docs-map.md` with exact owners and validations. Update public README/help only if a user-facing command or promise is introduced; otherwise keep the mechanism internal.

# Edge Cases

- Empty repository, no history, no matching seed, one supported file and one exact relationship.
- Large monorepo with more matches than every configured bound.
- Newly added file not present in the previous index; renamed file; deleted file; case-only rename on Windows.
- Dirty worktree, staged and unstaged variants, detached HEAD, branch switch and simultaneous worktrees.
- Dynamic imports/routes/DI that structural parsing cannot resolve; generated code that must stay ignored.
- Two symbols with the same short name, cyclic dependencies and a high-degree hub that would dominate ranking.
- Corrupt or older cache schema, interrupted atomic write and concurrent refresh attempts.
- Secret-looking identifiers, local absolute paths and telemetry fields that must be redacted or rejected.
- Cross-project reference to an unavailable repository or a project whose context format is not adopted.

# ZOMBIES Coverage

- **Z — Zero:** empty graph, empty history, no seed and no changed files return useful bounded states.
- **O — One:** one file, symbol, seed and dependency produce one explainable capsule.
- **M — Many:** monorepo scale, repeated invocations, parallel worktrees, cycles and high-degree nodes remain bounded and deterministic.
- **B — Boundaries:** node/depth/character/time/storage caps are tested below, at and above their limits with explicit truncation.
- **I — Interfaces:** graph/index, history, capsule, lifecycle skills, Git/worktree and runtime installation boundaries have versioned contracts.
- **E — Exceptional:** corrupt cache, partial write, unsupported syntax, missing tool, rename/delete, timeout and concurrent refresh fail safely or degrade explicitly.
- **S — Simple:** start with deterministic structural retrieval and measured pilots; do not add embeddings or a service until evidence requires them.

# OWASP Security Gate

- **Categories considered:** A02 Security Misconfiguration, A05 Injection, A06 Insecure Design, A08 Software or Data Integrity Failures, A09 Security Logging and Alerting Failures and A10 Mishandling of Exceptional Conditions.
- **Trust/data boundaries:** repository files, Git metadata and governed history are untrusted inputs to local parsers; derived caches and telemetry stay local, non-authoritative and non-public.
- **Required behavior:** validate and normalize paths beneath the selected root; never execute parsed content; use atomic versioned writes; reject symlink/junction escape; bound CPU, memory and output; redact secret-like data and avoid source bodies.
- **ASVS mapping:** not applicable as a formal ASVS claim because this is a local developer tool rather than an internet-facing application; equivalent path, input, integrity, logging and exceptional-condition tests remain mandatory.
- **Proof:** adversarial fixtures for path escape, malformed inputs, cache corruption, oversized graphs, redaction and fail-closed fallback.
- **Residual gap and owner:** conservative parsers will miss dynamic relationships; `301-sg-context` owns explicit uncertainty and canonical fallback rather than treating misses as security proof.

# Implementation Tasks

1. **Baseline and contracts** — Update `tools/test_code_context_graph.py`, `tools/test_context_history.py` and add focused capsule/integration fixtures before production changes. Record ShipGlows measurements, reuse the accepted ContentGlows historical baseline without rebuilding it, and record a read-only CommunityGlows fallback baseline using ShipGlows-owned disposable output. Dependency: existing main foundation. Validation: failing tests demonstrate incremental-new-file, symbol-staleness, ranking, bounds, worktree isolation and fallback requirements; Git status proves both external pilot repositories unchanged.
2. **Incremental graph engine** — Refactor `tools/code_context_graph.py` into versioned index build/update/query operations with atomic persistence, new/deleted/renamed-file detection, symbol/interface invalidation and deterministic migration/error behavior. Dependency: task 1. Validation: focused graph tests, repeatable JSON hashes, corruption/path-escape/concurrency fixtures and measured update-versus-rebuild proof.
3. **Task capsule and ranking** — Add the smallest dedicated module under `tools/` justified by the code/docs map for capsule schema, multi-seed ranking, reason codes, certainty preservation, caps and redaction; keep `tools/context_history.py` as the Context Head/history adapter. Dependency: task 2. Validation: golden capsule fixtures plus ranking, ambiguity, truncation, redaction and unsupported-parser tests.
4. **Lifecycle adoption** — Update `skills/301-sg-context/SKILL.md` and the exact readiness/execution/verification/resume/handoff owners discovered from `skill-invocation-registry.json` so material workflows consume one capsule automatically and small tasks retain a cheap targeted path. Dependency: task 3. Validation: invocation ownership, activation-profile, context-quality, handoff-fidelity and fallback contract tests.
5. **Operator diagnostics and telemetry** — Extend the existing context tool surface rather than creating a parallel product: expose bounded `status`, `explain`, freshness and evaluation outputs; persist only aggregate local quality measurements with opt-in project adoption and no source content. Dependency: tasks 3–4. Validation: schema, redaction, disabled/empty state, cap and deterministic-report tests.
6. **Cross-project pilots and tuning** — Run the accepted evaluation corpus on ShipGlows, compare against the accepted ContentGlows baseline with read-only current-state checks only where needed, and run the CommunityGlows read-only fallback pilot; classify misses by parser, seed, ranking, stale state or missing canonical truth, and add relationship types only when they improve the recorded task outcomes without exceeding budgets. Dependency: task 5. Validation: before/after metrics and ShipGlows-owned redacted fixtures, explicit unchanged external Git states, and no unmeasured parser expansion.
7. **Documentation and runtime parity** — Update the linked technical/contracts docs, `shipglows_data/technical/code-docs-map.md`, runtime synchronization and any help surface actually changed. Dependency: stable behavior from tasks 2–6. Validation: metadata lint, documentation contract tests, resource graph, activation budgets, runtime sync and `git diff --check`.
8. **Adversarial verification and closure** — Execute focused/full proportional tests, manually inspect one capsule and diagnostic per pilot, verify no source bodies/secrets are persisted, record remaining dynamic-resolution misses and create the single significant closure event. Dependency: all prior tasks. Validation: `103-sg-verify` evidence against every acceptance criterion before `104-sg-end` and ordinary ship.

# Acceptance Criteria

- [x] A material normal-path ShipGlows workflow automatically receives one bounded task capsule without an operator invoking an internal context engine.
- [x] The same Git/task state produces byte-stable derived output; changed state invalidates only affected observations and dependents.
- [x] New, changed, renamed and deleted supported files are represented correctly without mandatory full rebuild.
- [x] Every selected context item exposes an explainable reason and retains authority, freshness and certainty state.
- [x] Missing tools, unsupported relationships, cache corruption, truncation and ambiguous targets produce explicit fallback or blocking verdicts.
- [x] Worktree/branch isolation and concurrent refresh behavior are covered by deterministic tests.
- [x] No graph, capsule or telemetry artifact stores source bodies, secrets, prompts, transcripts, production payloads or private user content.
- [x] ShipGlows plus two contrasting project pilots show improved or equal relevant-file recall with measured noise, latency, size and fallback rate; regressions are documented rather than hidden.
- [x] Lifecycle, invocation, handoff, metadata, dependency graph, activation budget and runtime-sync validations pass.
- [x] Technical documentation identifies canonical truth, derived-data limits, operator diagnostics, known parser gaps and the safe fallback.

# Test Strategy

Use fixture-first deterministic tests for parser/index/capsule contracts, then lifecycle integration tests, then real-repository read-only pilots. Keep performance assertions relative and bounded enough for CI stability while recording local absolute measurements separately. Compare expected relevant files for representative tasks rather than optimizing node count. Include negative assertions proving that ignored files, source bodies, secret-like values and cross-worktree state never enter persisted artifacts.

# Risks

- **False confidence:** a structural graph can miss dynamic behavior. Mitigation: visible uncertainty, canonical revalidation and measured fixtures.
- **Context noise:** more edges can reduce agent quality. Mitigation: reasoned ranking, strict caps and relevance/noise metrics.
- **Stale derived state:** incremental indexing can appear fresh while missing new inputs. Mitigation: Git fingerprint plus untracked/new-file detection and schema-version checks.
- **Privacy leakage:** paths, identifiers or telemetry could reveal sensitive information. Mitigation: local-only storage, allowlisted fields, redaction and no source bodies.
- **Lifecycle overhead:** automatic context could slow small tasks. Mitigation: activation gate, incremental updates, latency budgets and targeted bypass.
- **Parallel corruption:** worktrees or concurrent agents could race on caches. Mitigation: worktree-scoped paths, atomic writes, bounded locks and corruption recovery.
- **Speculative architecture:** embeddings or a service could expand scope without proof. Mitigation: deterministic local pipeline first; new retrieval technology requires a separate evidence-backed decision.

# Execution Notes

- Start from `main` at or after merge `3b54e4c`; do not recreate the graph or Context Head foundations.
- First-read files: `tools/code_context_graph.py`, `tools/context_history.py`, `skills/301-sg-context/SKILL.md`, `skills/references/context-history-and-head.md`, and `shipglows_data/technical/native-code-context-graph.md`.
- Preserve the public/private boundary and immutable history schema. Generated graph/capsule caches remain ignored and disposable.
- The ContentGlows trash pilot is evidence, not an implementation target; ContentGlows product changes are explicitly outside this ShipGlows chantier.
- CommunityGlows is a read-only structural-contrast target, not an implementation target; unsupported TypeScript/Vue relationships must remain explicit and use the targeted fallback unless measured evidence supports a separately reviewed parser addition.
- Prefer extending existing commands/modules when ownership remains coherent. A new module is justified only when it prevents graph, history and capsule responsibilities from collapsing into one file.
- If evaluation shows deterministic structural retrieval cannot satisfy an accepted representative task, stop and record the exact miss before proposing embeddings, a database or an external provider.
- The next agent must run `101-sg-ready` before implementation and may repair this draft only within the accepted proprietary/local-first direction.

# Open Questions

None blocking. Technology expansion beyond deterministic local structural retrieval is intentionally deferred until measured evidence justifies a separate operator decision.

# Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-08-30 20:04:13 | 100-sg-spec | gpt-5.6 | Created the autonomous industrialization contract from the merged native graph, Context Head and ContentGlows pilot evidence. | Draft records lifecycle adoption, incremental indexing, explainable retrieval, metrics, safety, pilots and proof without external-service dependency. | Run `101-sg-ready` in ShipGlows `main`. |
| 2026-08-30 20:54:51 | 101-sg-ready | gpt-5.6 | Reviewed scope, behavior, security, proof, lifecycle consequences and pilot isolation; repaired the verdict vocabulary and resolved the pilot corpus. | Ready: a fresh agent can execute without rebuilding ContentGlows, mutating external pilots or inventing a second context verdict. | Start implementation from fixtures and baseline contracts. |
| 2026-08-30 21:10:00 | 102-sg-start | gpt-5.6 | Implemented the incremental v2 graph, explainable capsule, aggregate evaluation, lifecycle adoption, diagnostics, fallback pointers and mapped documentation. | Implemented: focused contracts pass and both external pilot repositories remain unchanged. | Verify every acceptance criterion and adversarial boundary. |
| 2026-08-30 21:15:57 | 103-sg-verify | gpt-5.6 | Verified incremental invalidation, migration, locking, path isolation, byte stability, privacy, lifecycle budgets, runtime visibility and cross-project recall. | Verified: 52 focused context tests pass; ShipGlows and CommunityGlows reach 1.0 representative recall with noise, truncation and unsupported-language gaps visible. | Close the internal-only chantier and ship its exact scope. |
| 2026-08-30 21:17:02 | 104-sg-end | gpt-5.6 | Synchronized the spec, technical documentation, runtime visibility and one immutable internal closure event. | Closed for implementation and proof; editorial surfaces are not impacted and the significant change remains internal-only. | Commit and push the exact chantier scope. |
| 2026-08-30 21:37:23 | 005-sg-ship | gpt-5.6 | Delivered the exact chantier scope through PR #47 after both required ShipGlows gates passed. | Shipped to `main` through the protected merge path; no deployment or public changelog claim applies. | Monitor aggregate quality evidence before expanding parser or retrieval technology. |

# Current Chantier Flow

`100-sg-spec (complete) -> 101-sg-ready (ready) -> 102-sg-start (implemented) -> 103-sg-verify (verified) -> 104-sg-end (closed) -> 005-sg-ship (shipped)`
