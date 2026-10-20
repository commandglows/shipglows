#!/usr/bin/env python3
"""Decide whether a repository needs local Git storage upkeep.

Read-only. Reads ``git count-objects -v`` and ``git worktree list --porcelain``
and reports whether upkeep is operationally due, with the bounded commands that
fix each signal:

- ``git worktree prune`` when registered worktrees point at missing folders;
- ``git gc`` (default expiry, so recent unreachable objects and the reflog
  recovery window survive) when loose objects, pack count, or garbage pile up.

Destructive variants (``git prune --expire=now``, ``git gc --prune=now``,
``git reflog expire --expire=now``) are never suggested here; they need an
explicit operator decision because they erase the recent recovery window.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import subprocess


def _git(repo: Path, *args: str) -> str:
    return subprocess.run(
        ["git", "-C", str(repo), *args], capture_output=True, check=True,
    ).stdout.decode("utf-8", "replace")


def parse_count_objects(output: str) -> dict[str, int]:
    stats: dict[str, int] = {}
    for line in output.splitlines():
        key, _, value = line.partition(":")
        if value.strip().isdigit():
            stats[key.strip()] = int(value.strip())
    return stats


def count_prunable_worktrees(porcelain: str) -> int:
    return sum(line.startswith("prunable") for line in porcelain.splitlines())


def assess(
    stats: dict[str, int],
    prunable_worktrees: int,
    max_loose: int = 1000,
    max_loose_mib: int = 50,
    max_packs: int = 20,
) -> dict[str, object]:
    reasons: list[str] = []
    actions: list[str] = []
    if prunable_worktrees:
        reasons.append(f"{prunable_worktrees} worktree entries point at missing folders")
        actions.append("git worktree prune")
    loose, loose_kib = stats.get("count", 0), stats.get("size", 0)
    storage = []
    if loose >= max_loose:
        storage.append(f"{loose} loose objects >= {max_loose}")
    if loose_kib >= max_loose_mib * 1024:
        storage.append(f"loose objects use {loose_kib // 1024} MiB >= {max_loose_mib}")
    if stats.get("packs", 0) >= max_packs:
        storage.append(f"{stats['packs']} packs >= {max_packs}")
    if stats.get("garbage", 0):
        storage.append(f"{stats['garbage']} garbage files")
    if storage:
        reasons.extend(storage)
        actions.append("git gc")
    return {"due": bool(reasons), "reasons": reasons, "actions": actions, "stats": stats, "prunable_worktrees": prunable_worktrees}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("repo", nargs="?", type=Path, default=Path.cwd())
    parser.add_argument("--max-loose", type=int, default=1000)
    parser.add_argument("--max-loose-mib", type=int, default=50)
    parser.add_argument("--max-packs", type=int, default=20)
    parser.add_argument("--format", choices=("text", "json"), default="text")
    args = parser.parse_args()
    try:
        stats = parse_count_objects(_git(args.repo, "count-objects", "-v"))
        prunable = count_prunable_worktrees(_git(args.repo, "worktree", "list", "--porcelain"))
    except (OSError, subprocess.CalledProcessError) as error:
        print(f"git-storage: unavailable ({error})")
        return 2
    result = assess(stats, prunable, args.max_loose, args.max_loose_mib, args.max_packs)
    if args.format == "json":
        print(json.dumps(result, ensure_ascii=False, indent=2, sort_keys=True))
    elif result["due"]:
        print("git-storage: due (" + "; ".join(result["reasons"]) + ") -> " + " && ".join(result["actions"]))
    else:
        print("git-storage: not due")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
