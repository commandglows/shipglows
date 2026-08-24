---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-24"
created_at: "2026-08-24 20:24:11 UTC"
updated: "2026-08-24"
updated_at: "2026-08-24 20:38:25 UTC"
status: ready
source_skill: 900-shipglows-core
source_model: "gpt-5.6"
scope: "public sg-private memory skill with strictly private operator data"
owner: Diane
user_story: "As a ShipGlows operator, I want one private-memory command that can remember or retrieve named paths, URLs, and Vivaldi bookmarks without placing my values in public Git."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/sg-private/SKILL.md
  - skills/603-sg-private/SKILL.md
  - skills/603-sg-private/references/memory-operations.md
  - tools/private_memory.py
  - tools/vivaldi_bookmarks.py
  - skills/references/skill-invocation-registry.json
depends_on:
  - artifact: "skills/references/canonical-runtime-and-private-roots.md"
    artifact_version: "1.1.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-24: expose one sg-private memory mode; public code and synthetic tests stay in Git while every real value remains in private machine state."
  - "Combined private-memory, Vivaldi, routing, help, and runtime-documentation contracts pass; both skills pass the official structural validator."
  - "An independent adversarial forward-test approved the final boundary with no remaining high- or medium-severity finding."
  - "Machine-local smoke proof confirms an empty valid pointer registry, runtime-confined Vivaldi backups, and a valid Windows shortcut without exposing private values."
next_step: "Verify the public/private boundary, persist the branch remotely, and integrate it into main after approval."
---

# Spec: Public Private-Memory Skill

## Outcome

ShipGlows exposes `sg-private memory <instruction>` as the single public interface for explicitly remembered private pointers. The public skill selects a machine-local alias registry or Vivaldi based on the request without copying operator data into Git.

## Scope

- Remember and retrieve named absolute paths and complete HTTP(S) URLs.
- Search active local aliases with bounded results.
- Archive and restore aliases instead of deleting them permanently.
- Select the Vivaldi bridge for explicit bookmark intent.
- Keep the registry, real values, operation results, and backups under the private runtime-state root.
- Route explicit and natural-language private-memory requests through one public owner and one internal engine.

## Non-Goals

- Implicitly persisting a pasted value.
- Reading or copying file contents when remembering a path.
- Storing credentials, tokens, cookies, authentication material, customer data, or inbox content.
- Granting authority over the target merely because its pointer is remembered.
- Creating empty future modes or bootstrapping the durable private-data Git repository.

## Invariants

- Public files contain only schemas, behavior, synthetic fixtures, and generic path notation.
- Persistence requires explicit intent, normal mutation approval, fresh revision/checksum state, dry-run, and atomic write.
- Prior local state is backed up before replacement.
- Relative paths, URL credentials, stale state, duplicates, ambiguity, malformed stores, and unsafe Vivaldi writes fail closed.
- Vivaldi remains the source of truth for bookmarks; the local alias registry stores only pointers outside Vivaldi.

## Acceptance Criteria

- `sg-private memory` is discoverable explicitly and through natural routing.
- A directory containing spaces and a complete URL can be remembered and recalled from synthetic stores.
- File contents never appear in the registry.
- Archive and restore preserve the entry.
- Vivaldi reads and closed-browser mutation guards remain verified.
- Public staged content contains no operator-specific path or real private value.
- A local Windows shortcut opens the private state root without adding a link or junction to the public repository.

## Verification

Run the private-memory and Vivaldi unit suites, public/expert partition contracts, invocation checker, skill-code lint, metadata lint, skill validator, syntax checks, staged anti-leak scan, and private empty-store/shortcut smoke.

## Delivery

Implementation belongs to `codex/vivaldi-bookmark-bridge` because the new public interface consumes the bridge delivered by that branch. Do not modify the unrelated dirty canonical worktree. Commit and push exact scope without force; integration into `main` remains a separate approval boundary.

The implementation is verified for branch delivery. URL writes reject embedded credentials and recognizable authentication parameters in query strings or fragments; backup and registry paths are mechanically confined to the private runtime root. The staged public payload must pass an operator-path, live-bookmark, and credential-pattern scan before remote persistence.
