---
name: 603-sg-private
description: "Operate explicit private path, URL, and bookmark memory safely."
---

## Canonical Paths

Load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` before resolving ShipGlows tools. Load `$SHIPGLOWS_ROOT/skills/references/canonical-runtime-and-private-roots.md` before resolving private storage. Never fall back to a project repository, plugin cache, or sibling runtime.

## Mission And Mode

`603-sg-private` owns one mode only: `memory`. It remembers and retrieves explicit private pointers and uses Vivaldi as a bookmark backend when the operator names Vivaldi, bookmarks, favorites, favoris, or signets.

Load `$SHIPGLOWS_ROOT/skills/references/intent-to-outcome-autonomy.md`. Then load `$SHIPGLOWS_ROOT/skills/603-sg-private/references/memory-operations.md` and follow its source selection, persistence, mutation, and proof boundaries.

## Privacy Boundary

- Public Git may contain only this skill, schemas encoded by the tools, behavior documentation, and synthetic fixtures.
- Machine-local paths, URLs, aliases, notes, bookmark records, operation results, and backups stay below `$SHIPGLOWS_RUNTIME_DIR`, defaulting to the current user's `.shipglows/state`.
- Never store credentials, tokens, cookies, authentication material, customer data, or file contents.
- A remembered pointer grants no new authority to read, modify, move, or delete its target.
- A supplied value is transient unless the operator explicitly asks to remember, keep, store, or bookmark it.

## Mutation And Recovery

Read-only recall and search may proceed within the explicitly selected private source. Every persistence change follows `$SHIPGLOWS_ROOT/skills/references/mutation-plan-approval.md`, defaults to dry-run, requires fresh revision/checksum state, writes atomically, and creates a private backup when prior state exists. Archive instead of permanent deletion.

Vivaldi reads may run while Vivaldi is open. Vivaldi writes require every Vivaldi process closed and use `$SHIPGLOWS_ROOT/tools/vivaldi_bookmarks.py`; never edit adjacent profile files.

## Stop Conditions

When persistence is implicit, keep the supplied value transient and continue the original task without writing memory. Stop when explicit persistence targets a possible secret or relative filesystem path, the requested alias is ambiguous, the store is stale or malformed, Vivaldi is running for a write, or the destination would be public Git.

## Proof And Reporting

Validate with synthetic path/URL lifecycle tests, Vivaldi bridge tests, invocation/routing contracts, metadata, and a staged anti-leak scan. Real private values may appear only in the active operator exchange when needed; omit them from public evidence and durable reports.

Load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md` before reporting. Use `(local)` unless one unique governed spec owns the work.
