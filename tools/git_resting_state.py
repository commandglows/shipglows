#!/usr/bin/env python3
"""Measure how far a repository is from its Git resting state.

Read-only. The resting state is the end goal of every chantier once its work is
shipped: the checkout sits on the canonical integration branch, clean and in
sync with its upstream, with no extra worktree, no temporary local or remote
branch, and no open pull request. Durable branches (``main`` and ``dev`` by
default) are part of the resting state.

Each deviation gets a suggested disposition:

- ``auto``: mechanically safe convergence under standing Git authority
  (prune a missing worktree, delete a branch already integrated, pull or push);
- ``merge``: unintegrated work with a target; reconcile it when merge-ready;
- ``ask``: dirty, unique, or unknown state; include it in one consolidated
  operator proposal instead of leaving it silent.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import shutil
import subprocess


def _git(repo: Path, *args: str, check: bool = True) -> str:
    result = subprocess.run(["git", "-C", str(repo), *args], capture_output=True)
    if check and result.returncode:
        raise subprocess.CalledProcessError(result.returncode, args, result.stderr)
    return result.stdout.decode("utf-8", "replace").strip()


def _lines(text: str) -> list[str]:
    return [line for line in text.splitlines() if line.strip()]


def _worktrees(repo: Path) -> list[dict[str, object]]:
    entries, current = [], {}
    for line in _git(repo, "worktree", "list", "--porcelain").splitlines() + [""]:
        if not line:
            if current:
                entries.append(current)
            current = {}
        elif line.startswith("worktree "):
            current["path"] = line[9:]
        elif line.startswith("HEAD "):
            current["head"] = line[5:]
        elif line.startswith("branch "):
            current["branch"] = line[7:].removeprefix("refs/heads/")
        elif line.startswith("prunable"):
            current["prunable"] = True
    return entries


def _open_pull_requests(repo: Path) -> list[dict[str, object]] | None:
    if not shutil.which("gh"):
        return None
    result = subprocess.run(
        ["gh", "pr", "list", "--state", "open", "--json", "number,headRefName,baseRefName,isDraft,title"],
        cwd=repo, capture_output=True,
    )
    if result.returncode:
        return None
    return json.loads(result.stdout.decode("utf-8") or "[]")


def resting_state(repo: Path, integration: str = "main", durable: tuple[str, ...] = ("main", "dev"),
                  remote: str = "origin", pull_requests: bool = True) -> dict[str, object]:
    repo = repo.resolve()
    durable_set = set(durable) | {integration}
    target = f"{remote}/{integration}" if _git(repo, "rev-parse", "--verify", "-q", f"{remote}/{integration}", check=False) else integration
    items: list[dict[str, str]] = []

    def add(kind: str, name: str, state: str, disposition: str) -> None:
        items.append({"kind": kind, "name": name, "state": state, "disposition": disposition})

    current = _git(repo, "branch", "--show-current", check=False) or "(detached)"
    if current != integration:
        add("checkout", current, f"not on {integration}", "ask" if current not in durable_set else "auto")
    dirty = _lines(_git(repo, "status", "--porcelain", check=False))
    if dirty:
        add("worktree-changes", ".", f"{len(dirty)} uncommitted paths", "ask")
    counts = _git(repo, "rev-list", "--left-right", "--count", f"{current}...@{{upstream}}", check=False).split()
    if len(counts) == 2:
        ahead, behind = map(int, counts)
        if ahead:
            add("upstream", current, f"{ahead} commits not pushed", "auto")
        if behind:
            add("upstream", current, f"{behind} commits not pulled", "auto")

    merged_local = {line.strip("* +").strip() for line in _lines(_git(repo, "branch", "--merged", target, check=False))}
    for branch in _lines(_git(repo, "for-each-ref", "--format=%(refname:short)", "refs/heads")):
        if branch in durable_set:
            continue
        if branch in merged_local:
            add("local-branch", branch, f"integrated into {target}", "auto")
        else:
            add("local-branch", branch, f"not integrated into {target}", "merge")

    main_path = None
    for entry in _worktrees(repo):
        if main_path is None:
            main_path = entry.get("path")
            continue
        name = f"{entry.get('path')} [{entry.get('branch', 'detached')}]"
        if entry.get("prunable"):
            add("worktree", name, "folder missing", "auto")
        else:
            branch = str(entry.get("branch", ""))
            integrated = branch in merged_local if branch else not subprocess.run(
                ["git", "-C", str(repo), "merge-base", "--is-ancestor", str(entry.get("head", "")), target],
                capture_output=True,
            ).returncode
            add("worktree", name, "work integrated" if integrated else "work not integrated",
                "auto" if integrated else "ask")

    merged_remote = {line.strip() for line in _lines(_git(repo, "branch", "-r", "--merged", target, check=False))}
    for ref in _lines(_git(repo, "for-each-ref", "--format=%(refname:short)", f"refs/remotes/{remote}")):
        branch = ref.removeprefix(f"{remote}/")
        if branch in durable_set or branch == "HEAD" or ref == remote:
            continue
        add("remote-branch", ref, "integrated" if ref in merged_remote else "not integrated",
            "auto" if ref in merged_remote else "merge")

    prs = _open_pull_requests(repo) if pull_requests else None
    if prs is None and pull_requests:
        add("pull-requests", "-", "open pull requests unknown (gh unavailable)", "ask")
    for pr in prs or []:
        add("pull-request", f"#{pr['number']} {pr['headRefName']} -> {pr['baseRefName']}",
            "draft" if pr.get("isDraft") else "open", "ask" if pr.get("isDraft") else "merge")

    return {"resting": not items, "integration": integration, "target": target, "current": current, "items": items}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("repo", nargs="?", type=Path, default=Path.cwd())
    parser.add_argument("--integration", default="main", help="Canonical integration branch (dev for live projects).")
    parser.add_argument("--durable", action="append", default=None, help="Durable branch kept at rest (repeatable).")
    parser.add_argument("--remote", default="origin")
    parser.add_argument("--no-pr", action="store_true", help="Skip the GitHub pull-request lookup.")
    parser.add_argument("--format", choices=("text", "json"), default="text")
    args = parser.parse_args()
    durable = tuple(args.durable) if args.durable else ("main", "dev")
    try:
        result = resting_state(args.repo, args.integration, durable, args.remote, not args.no_pr)
    except (OSError, subprocess.CalledProcessError) as error:
        print(f"resting-state: unavailable ({error})")
        return 2
    if args.format == "json":
        print(json.dumps(result, ensure_ascii=False, indent=2))
    elif result["resting"]:
        print(f"resting-state: clean on {result['integration']}")
    else:
        print(f"resting-state: {len(result['items'])} deviations from a clean {result['integration']}")
        for item in result["items"]:
            print(f"- [{item['disposition']}] {item['kind']} {item['name']}: {item['state']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
