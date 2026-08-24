---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-24"
updated: "2026-08-24"
status: active
source_skill: 603-sg-private
scope: private-memory-operations
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - tools/private_memory.py
  - tools/vivaldi_bookmarks.py
  - skills/references/canonical-runtime-and-private-roots.md
depends_on:
  - artifact: "skills/references/canonical-runtime-and-private-roots.md"
    artifact_version: "1.1.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-24: one memory mode selects local pointer memory or Vivaldi without persisting supplied values implicitly."
next_step: "/103-sg-verify private memory public/private boundary"
---

# Private Memory Operations

## Intent Gate

Persist only from explicit language such as remember, retain, keep, store, memorize, bookmark, retiens, garde, mémorise, enregistre, or ajoute à mes signets. A pasted path, URL, file, or page used for another task remains transient.

## Source Selection

- A named local alias, file, directory, or ordinary URL uses `tools/private_memory.py`.
- An explicit Vivaldi, bookmark, favorite, favoris, or signets request uses `tools/vivaldi_bookmarks.py`.
- A generic recall checks the local alias registry first. Search Vivaldi only when bookmark intent is explicit or the local registry has no match and the request clearly seeks a saved web reference.
- Do not copy records between backends unless the operator explicitly names the destination.

## Local Pointer Memory

The canonical store is `${SHIPGLOWS_RUNTIME_DIR:-$HOME/.shipglows/state}/private-memory/locations.json`. It stores only alias, target type, complete target pointer, optional bounded note/tags, timestamps, and lifecycle state. It never reads or embeds target file contents.

Read operations:

```text
python3 "$SHIPGLOWS_ROOT/tools/private_memory.py" status
python3 "$SHIPGLOWS_ROOT/tools/private_memory.py" recall "<alias>"
python3 "$SHIPGLOWS_ROOT/tools/private_memory.py" search "<query>"
python3 "$SHIPGLOWS_ROOT/tools/private_memory.py" list
```

For a mutation, obtain the current revision with `status`, run the intended command without `--apply`, present the exact target and effect under the ordinary approval gate, then repeat with `--apply` only after approval:

```text
python3 "$SHIPGLOWS_ROOT/tools/private_memory.py" remember "<alias>" "<absolute-path-or-url>" --expected-revision <n>
python3 "$SHIPGLOWS_ROOT/tools/private_memory.py" archive "<alias>" --expected-revision <n>
python3 "$SHIPGLOWS_ROOT/tools/private_memory.py" restore "<alias>" --expected-revision <n>
```

On Windows use the environment's recorded Python runner, normally `uv run python`, while preserving the same arguments.

## Vivaldi Memory

Use `tools/vivaldi_bookmarks.py` for status, list, search, add URL/folder, update, move, archive, and restore. Preserve complete URLs privately. Reads are allowed while Vivaldi runs; writes require Vivaldi fully closed, the current checksum, dry-run review, explicit approval, `--apply`, and a private backup.

For a new bookmark, use a title explicitly supplied by the operator or unambiguously available from the supplied page/bookmark metadata. The destination folder must be explicit or uniquely resolvable from the requested context. If either remains ambiguous, ask one concise question for the missing title or placement; never silently default to the bookmark bar or another root.

## Reporting Boundary

For status, report counts and availability without targets. For recall, return only the requested bounded result. For search, limit results to what is useful. Never include real private values in Git diffs, specs, fixtures, test output committed to Git, or public-facing content.
