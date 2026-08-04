---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.3"
project: ShipGlows
created: "2026-08-03"
created_at: "2026-08-03 19:55:00 UTC"
updated: "2026-08-03"
updated_at: "2026-08-04 00:00:00 UTC"
status: reviewed
source_skill: 100-sg-spec
source_model: GPT-5 Codex
scope: shipglows-resource-discovery
owner: Diane
user_story: "As a ShipGlows agent, I want a small deterministic starter pack of relevant references and playbooks for the active skill, mode, and intent so that I can progressively discover useful files without hard-coding every physical path in each skill."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/
  - skills/*/references/
  - shipglows_data/workflow/playbooks/
  - tools/
  - skills/references/skill-instruction-layering.md
depends_on:
  - artifact: "skills/references/canonical-paths.md"
    artifact_version: "1.8.0"
    required_status: active
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "1.2.0"
    required_status: active
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-03: ShipGlows will increasingly use smaller searchable reference files and needs governed progressive discovery."
  - "Current corpus contains more than 170 shared and skill-local Markdown references, while activation contracts embed many physical paths."
  - "The landing-page framework was discoverable from only one hard-coded loader despite being relevant to several owner lanes."
next_step: "none"
---

# Spec: ShipGlows Resource Resolver

## Status

Closed. The resolver is an internal, read-only discovery utility, not a new public skill or a replacement for owner-skill routing. Its technical documentation map and runtime lifecycle references are now aligned.

## User Story

As a ShipGlows agent, I want a small deterministic starter pack of relevant references and playbooks for the active skill, mode, and intent so that I can progressively discover useful files without hard-coding every physical path in each skill.

## Minimal Behavior Contract

Given a registered ShipGlows skill plus optional mode and natural-language intent, scan only canonical ShipGlows resource roots, rank eligible Markdown references deterministically, and return a bounded starter pack with stable resource IDs, resolved paths, metadata, scores, and human-readable reasons. Given one resource ID, expand to directly related resources through declared dependencies, linked systems, owner proximity, and explicit references. The utility never activates a skill, edits files, searches arbitrary roots, or treats relevance as authority.

## Success Behavior

- Discover shared references, skill-local references, and reusable workflow playbooks without a hand-maintained physical-path catalog.
- Use stable logical resource IDs derived from canonical ownership and filenames.
- Rank by skill ownership, selected mode, intent terms, metadata, headings, filename, and declared links.
- Return at most the requested bounded limit and explain each match.
- Expand one known resource into a bounded related-resource list.
- Prefer active resources while visibly labelling draft or non-active material.
- Keep required activation and safety gates authoritative; discovery supplements them until semantic resource profiles replace physical loaders through a later migration.
- Emit deterministic JSON by default and concise text on request.

## Error Behavior

- Unknown skill, resource ID, invalid limit, missing canonical root, malformed metadata, or path escape returns a non-zero diagnostic without mutation.
- Empty intent is allowed only when skill or expansion context can rank resources responsibly.
- Duplicate logical IDs are rejected rather than silently choosing one file.
- Inactive or superseded resources are excluded by default and may only be included explicitly.
- Search results never imply that a resource is mandatory, current, or safe unless its metadata and owner contract establish that status.

## Scope In

- Internal Python resolver and CLI.
- Deterministic scanning and ranking of canonical Markdown resources.
- Progressive expansion through resource relationships.
- Scenario tests using the landing-page copywriting framework and owner-local playbooks.
- Shared discovery doctrine and focused validation.

## Scope Out

- Embeddings, vector databases, external APIs, network search, or background indexing services.
- Automatically rewriting every existing skill loader.
- Replacing explicit mandatory gates, the skill router, the invocation preflight, or project-governance discovery.
- Searching arbitrary user directories or project source trees.
- Creating a public resolver skill or exposing internal-only resources in public plugin bundles.

## Architecture

The resolver scans three canonical roots relative to `$SHIPGLOWS_ROOT`: shared skill references, skill-local references, and reusable workflow playbooks. It parses bounded frontmatter fields and Markdown text with the Python standard library, produces stable IDs (`shared:<stem>`, `<skill>:<stem>`, `workflow:<stem>`), and calculates deterministic weighted matches. Physical paths remain resolver output, not activation-contract identity.

Progressive discovery has two stages:

1. `resolve`: return the most relevant starter pack for skill + mode + intent.
2. `expand`: return directly related resources for one stable resource ID.

## Safety And Invariants

- Read-only standard-library implementation; no subprocess, network, mutation, dynamic import, or arbitrary root argument.
- Resolve and verify every candidate remains inside a canonical root.
- Cap file size, result count, and expansion depth.
- Treat metadata status and declared dependencies as evidence, not truth replacement.
- Preserve explicit activation-critical loaders until a separate migration proves semantic profiles can replace them safely.
- Do not index private inspiration bundles, secrets, generated output, caches, or project customer data.

## Implementation Tasks

- [x] Define resource identity, eligible roots, metadata parsing, and ranking contract.
- [x] Add scenario-first tests for landing-page discovery, local-owner boost, expansion, bounded output, invalid skill/resource, inactive filtering, duplicate IDs, and no side effects.
- [x] Implement the read-only resolver and CLI.
- [x] Add shared progressive-discovery doctrine and a compact integration point for ShipGlows skill maintenance/help.
- [x] Run focused tests, metadata lint, skill audit, budget audit, runtime sync, and diff hygiene.

## Acceptance Criteria

- [x] `009-sg-marketing` + `copywriting` + landing-page section-flow intent ranks the landing-page framework and copywriting playbook in the starter pack.
- [x] An unrelated technical intent does not rank the landing-page framework in its bounded top results.
- [x] Expanding the landing-page framework exposes its directly linked copywriting and decision-quality resources.
- [x] Every result includes stable ID, canonical resolved path, status, type, score, and at least one reason.
- [x] Unknown skills and resources fail without suggestions that invent ownership.
- [x] Results are deterministic across repeated runs on unchanged files.
- [x] The resolver performs no write, network, subprocess, skill activation, or arbitrary filesystem traversal.
- [x] Existing explicit loaders remain valid during the progressive migration period.

## Proof Path

Scenario-first tests plus focused unit tests, metadata lint, skill-contract audit, context-budget audit, runtime sync, and `git diff --check`. Fresh docs are not needed because the implementation uses only the local Python standard library and ShipGlows-owned contracts.

## Verification Limits

The bounded proof passes. The repository-wide migration debt observed during this chantier was repaired afterward under `BUG-2026-08-03-001`: full Python contract discovery now passes, while three public-site assertions are explicitly skipped when the optional `shipglows-site` checkout is unavailable.

## Risks

- Lexical ranking can miss synonyms; mitigate with metadata, owner/mode boosts, deterministic token normalization, and explainable results rather than opaque confidence.
- Parsing all files could waste context or time; mitigate with bounded file sizes, local execution, and result limits.
- Generated IDs can collide; reject collisions and require a future explicit metadata ID only where needed.
- Agents could mistake recommendations for mandatory gates; keep requirement authority in activation contracts and label resolver output as discovery evidence.
- A broad automatic migration could remove safety loaders prematurely; keep migration explicitly out of scope.

## Documentation Update Plan

Completed: the shared progressive-discovery reference already documents the authority boundary and invocation; the internal technical README, code-docs map, and skill runtime/lifecycle guide now map the resolver, tests, semantic IDs, validation, and migration limits. No public product claim is affected.

## Editorial Update Plan

No public editorial impact. The resolver remains internal to ShipGlows maintenance and agent execution.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
| --- | --- | --- | --- | --- | --- |
| 2026-08-03 19:40:00 UTC | 900-shipglows-core | GPT-5 Codex | Diagnosed a missing invocation preflight, traced it to an untracked stash object, and recovered the bounded implementation without applying unrelated stash contents. | implemented | Validate recovery and continue resolver spec. |
| 2026-08-03 19:55:00 UTC | 100-sg-spec | GPT-5 Codex | Defined the deterministic progressive resource resolver, authority boundaries, risks, tasks, and scenario-first proof. | ready | Implement and verify. |
| 2026-08-03 19:55:00 UTC | 101-sg-ready | GPT-5 Codex | Reviewed owner boundary, canonical roots, safety, deterministic proof, and migration scope; no unresolved decision remains. | ready | Implement tests and resolver. |
| 2026-08-03 20:06:52 UTC | 102-sg-start | GPT-5 Codex | Implemented the standard-library resolver, stable ID lookup, relationship expansion, progressive-discovery doctrine, help/core semantic integration, and orphan-loader audit. | implemented | Verify focused and global contracts. |
| 2026-08-03 20:06:52 UTC | 900-shipglows-core | GPT-5 Codex | Applied conservative refresh across touched master/help contracts; preserved mandatory loaders and limited semantic IDs to proven discovery paths. | refreshed | Run final verification and ship. |
| 2026-08-03 20:06:52 UTC | 103-sg-verify | GPT-5 Codex | Verified 36 focused scenarios, metadata, audit, budget, runtime sync, code hygiene, and live resolver examples; recorded unrelated pre-existing global-suite gaps. | verified | Close and ship bounded scope. |
| 2026-08-03 20:06:52 UTC | 104-sg-end | GPT-5 Codex | Closed the bounded implementation record, aligned refresh history and changelog, and preserved unrelated migration debt outside ship scope. | closed | Commit and push bounded scope. |
| 2026-08-03 20:09:53 UTC | 005-sg-ship | GPT-5 Codex | Created bounded implementation commit `784109a`; closure metadata is committed separately before pushing both commits to `origin/main`. | shipped | None. |
| 2026-08-03 20:33:16 UTC | 005-sg-ship | GPT-5 Codex | Completed the explicit full-close pass, synchronized the project tracker, confirmed changelog and documentation reflection, and prepared the final documentation ship. | shipped | None. |
| 2026-08-04 00:00:00 UTC | 300-sg-docs | GPT-5 Codex | Audited the internal technical corpus and aligned the README, code-docs map, and skill runtime/lifecycle guide with the shipped resolver, its tests, semantic IDs, bounded discovery, and authority boundary. | documented | None. |

## Current Chantier Flow

| Stage | Status | Note |
| --- | --- | --- |
| 100-sg-spec | completed | Contract is autonomous and bounded. |
| 101-sg-ready | completed | Ready with scenario-first proof and no external dependency. |
| 102-sg-start | completed | Preflight recovery and resolver implementation complete. |
| 103-sg-verify | completed | Focused proof passes; unrelated global-suite migration debt is recorded separately. |
| 104-sg-end | completed | Refresh history and changelog aligned. |
| 005-sg-ship | completed | Implementation, closure record, project tracker, and changelog are synchronized and shipped. |
