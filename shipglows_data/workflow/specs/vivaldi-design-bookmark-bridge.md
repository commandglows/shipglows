---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: "ShipGlows"
created: "2026-08-24"
created_at: "2026-08-24 17:34:21 UTC"
updated: "2026-08-24"
updated_at: "2026-08-24 18:16:28 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "gpt-5.6"
scope: "complete Vivaldi bookmark bridge with reversible offline editing"
owner: "Diane"
user_story: "As a ShipGlows operator, I want agents to inspect and safely reorganize all my Vivaldi bookmarks through a private machine-local bridge, so bookmark work is agentic, complete, and recoverable."
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - "tools/vivaldi_bookmarks.py"
  - "tools/test_vivaldi_bookmarks.py"
  - "skills/006-sg-design/references/design-inspiration-library-operations.md"
  - "skills/references/canonical-runtime-and-private-roots.md"
  - "skills/references/design-inspiration-library.md"
  - "shipglows_data/technical/code-docs-map.md"
depends_on:
  - artifact: "skills/references/canonical-runtime-and-private-roots.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/design-inspiration-library.md"
    artifact_version: "2.0.0"
    required_status: active
supersedes: []
evidence:
  - "Operator approval 2026-08-24: cover every bookmark root in the Vivaldi Default profile and permit reversible JSON edits only while Vivaldi is closed."
  - "The live profile contains bookmark_bar, other, synced, and trash roots; its stored checksum matches Chromium-compatible traversal."
  - "Synthetic mutation coverage proves add, update, move-to-Trash, restore, dry-run, stale-checksum rejection, and running-browser refusal."
next_step: "Complete closed-browser live mutation proof, persist the updated branch remotely, then integrate it into main."
---

# Spec: Complete Vivaldi Bookmark Bridge

## Title

Complete Vivaldi Bookmark Bridge

## Status

The complete-profile read and reversible mutation implementation passes focused verification. Live checksum validation and running-browser refusal pass; the temporary live mutation lifecycle remains pending until the operator closes Vivaldi. Remote persistence and integration follow that proof.

## User Story

As a ShipGlows operator, I want agents to inspect and safely reorganize all my Vivaldi bookmarks through a private machine-local bridge, so bookmark work is agentic, complete, and recoverable.

## Problem

Vivaldi stores every bookmark folder inside one profile JSON file rather than as Windows directories. ShipGlows needs complete private access for search and organization, but direct edits must not race the running browser, invalidate Chromium's checksum, or make an irreversible change without a backup.

## Solution

Use a portable Python bridge backed by machine-local configuration under the ShipGlows mutable-state root. Read every bookmark root with complete private URLs. Mutations default to dry-run, require the current checksum and explicit `--apply`, refuse while Vivaldi runs, copy the original into a private backup directory, write atomically, and recalculate Chromium's checksum. Deletion is represented by a reversible move into Vivaldi Trash.

## Scope In

- Read every root in one configured Vivaldi `Bookmarks` file.
- Provide `status`, `list`, and `search` commands with JSON and Markdown output.
- Provide add URL/folder, update, move, archive, and restore operations.
- Preserve complete URLs in private output and keep real results outside Git.
- Store the operator-specific source and private backup directory under `${SHIPGLOWS_RUNTIME_DIR:-~/.shipglows/state}/`.
- Require a closed browser, exact checksum, dry-run/apply distinction, backup, atomic replace, and post-write verification.
- Add synthetic unit fixtures and focused documentation for agent use.

## Scope Out

- Permanent deletion and editing while Vivaldi is running.
- Reading browser history, cookies, sessions, passwords, extensions, or other profile files.
- Copying real bookmark URLs, profile paths, or private configuration into the public repository or test evidence.
- Automatically capturing pages or approving them into the design-inspiration library.
- Treating bookmarks as vetted, licensed, current, accessible, or production-ready references.

## Constraints And Invariants

- The configured source must be an absolute regular file named `Bookmarks` and must stay beneath a Vivaldi profile directory.
- Read operations open no browser page; writes fail while Vivaldi is running.
- A bounded file-size limit applies before parsing.
- The adapter retries when the source changes during a read and otherwise fails visibly.
- Node mutations use an exact ID or GUID and stale checksums fail closed.
- Configuration and real results remain outside the public ShipGlows repository.
- Search is case-insensitive, deterministic, bounded, and covers every bookmark root.
- Complete URLs remain private; public documentation and proof never include real bookmark results.

## Minimal Behavior Contract

Given a valid private configuration, `status` reports root counts, checksum validity, and write readiness; `list` and `search` expose complete private bookmark records. Mutations address exact node IDs/GUIDs, produce a dry run unless `--apply` is present, require the current checksum, and atomically persist only after a private backup when Vivaldi is closed. Invalid, stale, malformed, concurrent, or ambiguous input fails non-zero.

## Error Behavior

- Missing config/source: fail with the expected path class, without creating files.
- Invalid or oversized JSON: fail before traversal.
- Missing or ambiguous node reference: fail without mutating.
- Duplicate bookmarks remain distinct because their IDs/GUIDs are distinct.
- Empty roots or no search match: return a successful empty result.
- Running Vivaldi, stale expected checksum, or invalid stored checksum: refuse before backup or write.
- Concurrent Vivaldi write: retry once from a fresh read; fail if stability cannot be established.

## ZOMBIES Coverage

- Zero: empty configured folder and zero search matches return valid empty output.
- One: one bookmark retains its ID, GUID, complete URL, root, and logical folder.
- Many: all roots and nested folders stay deterministic and bounded.
- Boundaries: maximum source bytes and result limit are enforced.
- Interfaces: configuration, Vivaldi JSON roots, JSON output, and Markdown output are validated.
- Exceptions: missing, malformed, unstable, or ambiguous inputs fail closed.
- Simple: no database, browser automation, Vivaldi write API, or cached mirror is introduced.

## Implementation Tasks

1. Extend `tools/vivaldi_bookmarks.py` with complete-root traversal, stable IDs/GUIDs, Chromium checksum calculation, dry-run mutations, closed-browser enforcement, private backups, atomic replacement, and bounded renderers.
   - Depends on: none.
   - Validate with: focused unit tests and a synthetic command smoke.
2. Add `tools/test_vivaldi_bookmarks.py` using temporary synthetic Vivaldi profiles and configurations.
   - Depends on: task 1.
   - Validate with: `uv run python -m unittest tools.test_vivaldi_bookmarks`.
3. Document complete-profile bookmark operations in the design-inspiration operations reference and map the tool to its technical documentation/proof surface.
   - Depends on: task 1 behavior.
   - Validate with: metadata lint and targeted reference scan.
4. Create the machine-local all-bookmark configuration and run live status plus closed-browser write-readiness proof without printing real URLs.
   - Depends on: tasks 1-3.
   - Validate with: no real URLs in repository diff or command evidence.

## Acceptance Criteria

- AC1: real bookmark data and the Vivaldi path never appear in Git-tracked files.
- AC2: read commands cover bookmark_bar, other, synced, trash, and their descendants.
- AC3: complete URLs are preserved in private list/search output; status emits no URLs.
- AC4: invalid paths, oversized files, malformed JSON, stale checksums, invalid checksums, unstable reads, folder cycles, and a running browser fail safely.
- AC5: add/update/move/archive/restore work against synthetic fixtures with a backup per applied operation and no backup for dry runs.
- AC6: the public design workflow explains that bookmarks are candidates and that durable approved inspiration uses the private inspiration library.

## Test Strategy

Proof path: test-first for the complete mutation lifecycle, followed by a no-URL live checksum/status smoke and a temporary closed-browser create/update/archive/restore proof. Run focused tests, metadata lint, a repository scan for the private Vivaldi path/real results, and Git diff review before delivery.

## Risks

- Privacy leakage through diagnostics or fixtures: use synthetic fixtures, bounded errors, and a final sensitive-path scan.
- Vivaldi schema evolution: preserve unknown fields, validate root/folder/url node shapes, and fail visibly on checksum or shape drift.
- Stale reads during browser sync: detect source metadata changes and retry once.
- Confusing discovery with endorsement: document bookmark records as unverified candidates.
- Windows-only path assumptions: use `pathlib` and environment-based state resolution; keep fixtures platform-neutral.

## Documentation Update Plan

Update the design-inspiration operations reference and technical code map. Public marketing/editorial content is not impacted because this is an optional private operator connector with no new public promise.

## Execution Notes

- Worktree: `C:\Users\Diane\ShipGlows\worktrees\shipglows-vivaldi-bookmarks`.
- Branch: `codex/vivaldi-bookmark-bridge` from `origin/main`.
- Temporary Git artifact: branch and worktree owned by this spec; intended target `main`; cleanup disposition `pending` until integration is proven.
- Preserve the unrelated dirty DevServer worktree completely.
- Stage and deliver only this spec, tool, focused tests, and mapped documentation.
- The private local config is never staged or committed.

## Open Questions

None.

## Skill Run History

| Timestamp (UTC) | Skill | Result | Evidence | Next action |
| --- | --- | --- | --- | --- |
| 2026-08-24 17:34:21 UTC | 100-sg-spec | ready | Operator-approved scope, storage boundary, selectors, proof, and delivery route recorded | Implement and verify |
| 2026-08-24 17:42:34 UTC | 102-sg-start | implemented | Read-only adapter, synthetic tests, private configuration, and mapped documentation created | Verify |
| 2026-08-24 17:42:34 UTC | 103-sg-verify standard | verified | 27 focused tests passed; metadata lint passed for 4 artifacts; live status/search smoke passed; private Vivaldi path absent from repository | Persist branch remotely |
| 2026-08-24 17:43:55 UTC | 005-sg-ship checkpoint | backed up | Commit `e1d235e` pushed to `origin/codex/vivaldi-bookmark-bridge` without force | Integrate into main, then prove cleanup eligibility |
| 2026-08-24 18:17:26 UTC | 100-sg-spec revision | ready | Operator expanded scope to every Default-profile bookmark and approved reversible offline JSON edits | Implement complete-profile mutation bridge |
| 2026-08-24 18:17:26 UTC | 102-sg-start | implemented | Full-root reads, complete private URLs, ID/GUID mutations, Chromium checksum, dry-run, private backup, atomic write, Trash archive/restore, and running-browser guard implemented | Complete live proof |
| 2026-08-24 18:17:26 UTC | 103-sg-verify standard | partial | 29 focused tests, syntax, metadata lint, real checksum validation, no-write dry run, and live running-browser refusal pass; Vivaldi remains open | Close Vivaldi and run temporary mutation/restore proof |

## Current Chantier Flow

`100-sg-spec revised -> 102-sg-start implemented -> 103-sg-verify partial (closed-browser live proof pending) -> 005-sg-ship pending update -> 104-sg-end pending integration`
