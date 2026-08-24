---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-08-24"
created_at: "2026-08-24 17:34:21 UTC"
updated: "2026-08-24"
updated_at: "2026-08-24 17:43:55 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "gpt-5.6"
scope: "read-only Vivaldi design-bookmark bridge"
owner: "Diane"
user_story: "As a ShipGlows operator, I want agents to search my selected Vivaldi design bookmarks through a private machine-local connector, so recurring design research reuses my curated sources without exposing unrelated bookmarks."
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
  - "Operator approval 2026-08-24: create a safe ShipGlows bridge to the Vivaldi design-bookmark folder while keeping private paths and bookmark data outside the public repository."
  - "Read-only discovery found one Vivaldi Default profile and the logical design subtree under Signets / Dev / Design, including Fonts & Colors and Outils Design."
  - "Focused verification passed 27 tests; live redacted status found 340 unique public-Web candidates and collapsed 3 duplicates without writing Vivaldi."
next_step: "Integrate the remotely persisted task branch into main, then remove the temporary worktree after integration proof."
---

# Spec: Vivaldi Design Bookmark Bridge

## Title

Vivaldi Design Bookmark Bridge

## Status

Implemented, verified locally, and persisted on the remote task branch. Integration into `main` remains before terminal cleanup of the temporary branch/worktree.

## User Story

As a ShipGlows operator, I want agents to search my selected Vivaldi design bookmarks through a private machine-local connector, so recurring design research reuses my curated sources without exposing unrelated bookmarks.

## Problem

Vivaldi stores every bookmark folder inside one profile JSON file rather than as Windows directories. A filesystem shortcut to the file would expose unrelated personal and operational bookmarks, while a copied export would become stale. ShipGlows needs a live, bounded, read-only adapter that selects only configured logical subtrees.

## Solution

Add a portable Python tool that resolves a machine-local configuration under the ShipGlows mutable-state root, reads a stable snapshot of Vivaldi's `Bookmarks` JSON, selects only configured folder paths, and emits bounded JSON or Markdown for status, listing, and search. Keep the real source path and selected folder paths in an untracked private configuration file. Document the bridge as optional intake for design research; durable approved inspiration remains governed by the separate private inspiration library.

## Scope In

- Read one configured Vivaldi `Bookmarks` file without modifying it.
- Resolve one or more configured logical folder paths beneath Vivaldi bookmark roots.
- Provide `status`, `list`, and `search` commands with JSON and Markdown output.
- Limit output to title, query/fragment/credential-redacted URL, folder path, and configured source label.
- Store the operator-specific source path and folder selectors under `${SHIPGLOWS_RUNTIME_DIR:-~/.shipglows/state}/sources/`.
- Add synthetic unit fixtures and focused documentation for agent use.

## Scope Out

- Writing, moving, deleting, tagging, or synchronizing Vivaldi bookmarks.
- Reading browser history, cookies, sessions, passwords, extensions, or other profile files.
- Copying real bookmark URLs, profile paths, or private configuration into the public repository or test evidence.
- Automatically capturing pages or approving them into the design-inspiration library.
- Treating bookmarks as vetted, licensed, current, accessible, or production-ready references.

## Constraints And Invariants

- The configured source must be an absolute regular file named `Bookmarks` and must stay beneath a Vivaldi profile directory.
- The adapter is read-only and opens no browser page.
- A bounded file-size limit applies before parsing.
- The adapter retries when the source changes during a read and otherwise fails visibly.
- Missing or ambiguous folders fail closed and never widen to the whole bookmark collection.
- Configuration and real results remain outside the public ShipGlows repository.
- Search is case-insensitive, deterministic, bounded, and restricted to configured subtrees.
- URL credentials, query strings, and fragments are removed before rendering or searching.

## Minimal Behavior Contract

Given a valid private configuration and readable Vivaldi snapshot, `status` reports only source availability and selected-folder counts, `list` returns bookmarks from configured folders, and `search <query>` returns only matching configured bookmarks. Given a missing configuration, invalid source, changed snapshot, malformed JSON, unresolved folder, or excessive result request, the command exits non-zero with a bounded diagnostic that contains no bookmark URLs or unrelated folder names.

## Error Behavior

- Missing config/source: fail with the expected path class, without creating files.
- Invalid or oversized JSON: fail before traversal.
- Unresolved selector: name only that configured selector.
- Duplicate bookmarks across selected parents: deduplicate by URL plus title plus logical folder.
- Empty selected folder or no search match: return a successful empty result.
- Concurrent Vivaldi write: retry once from a fresh read; fail if stability cannot be established.

## ZOMBIES Coverage

- Zero: empty configured folder and zero search matches return valid empty output.
- One: one selector and one bookmark retain exact title, URL, and logical folder.
- Many: multiple selectors and nested folders stay deterministic and bounded.
- Boundaries: maximum source bytes and result limit are enforced.
- Interfaces: configuration, Vivaldi JSON roots, JSON output, and Markdown output are validated.
- Exceptions: missing, malformed, unstable, or ambiguous inputs fail closed.
- Simple: no database, browser automation, Vivaldi write API, or cached mirror is introduced.

## Implementation Tasks

1. Add `tools/vivaldi_bookmarks.py` with safe config/root resolution, stable snapshot reading, exact logical-folder traversal, normalized records, filtering, deduplication, and bounded renderers.
   - Depends on: none.
   - Validate with: focused unit tests and a synthetic command smoke.
2. Add `tools/test_vivaldi_bookmarks.py` using temporary synthetic Vivaldi profiles and configurations.
   - Depends on: task 1.
   - Validate with: `uv run python -m unittest tools.test_vivaldi_bookmarks`.
3. Document optional bookmark intake in the design-inspiration operations reference and map the tool to its technical documentation/proof surface.
   - Depends on: task 1 behavior.
   - Validate with: metadata lint and targeted reference scan.
4. Create the machine-local private connector configuration for the discovered Vivaldi design subtree and run a redacted live status/search smoke.
   - Depends on: tasks 1-3.
   - Validate with: no real URLs in repository diff or command evidence.

## Acceptance Criteria

- AC1: real bookmark data and the Vivaldi path never appear in Git-tracked files.
- AC2: every command reads only selectors declared in the private configuration.
- AC3: `status`, `list`, and `search` work against synthetic fixtures and return deterministic bounded output with URL credentials, queries, and fragments removed.
- AC4: invalid paths, oversized files, malformed JSON, unresolved selectors, and unstable reads fail non-zero without broad data disclosure.
- AC5: the real private connector reports the two intended design folders without modifying Vivaldi.
- AC6: the public design workflow explains that bookmarks are candidates and that durable approved inspiration uses the private inspiration library.

## Test Strategy

Proof path: test-first for adapter behavior, followed by a redacted evidence-first smoke against the operator's live Vivaldi file. Run the focused unit module, metadata lint for changed documentation/spec artifacts, a repository scan for the private Vivaldi path and known real URLs, and a Git diff review before exact-scope delivery.

## Risks

- Privacy leakage through diagnostics or fixtures: use synthetic fixtures, bounded errors, and a final sensitive-path scan.
- Vivaldi schema evolution: tolerate unknown fields, require known root/folder/url node shapes, and fail visibly when selectors disappear.
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

## Current Chantier Flow

`100-sg-spec ready -> 102-sg-start implemented -> 103-sg-verify verified -> 005-sg-ship branch backed up -> 104-sg-end pending integration`
