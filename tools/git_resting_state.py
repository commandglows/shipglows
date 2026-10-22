#!/usr/bin/env python3
"""Measure how far a repository is from its Git resting state.

Read-only. The resting state is the end goal of every chantier once its work is
shipped: the checkout sits on the canonical integration branch, clean and in
sync with its upstream, with no extra worktree, no temporary local or remote
branch, and no open pull request. Durable branches (``main`` and ``dev`` by
default) are part of the resting state.

Each deviation gets a suggested disposition:

- ``auto``: mechanically safe convergence under standing Git authority
  (prune a missing worktree, delete a branch already integrated, fast-forward);
- ``merge``: unintegrated work with a target; reconcile it when merge-ready;
- ``push``: unpushed commits; pushing follows the operator's push policy;
- ``ask``: dirty, unique, locked, or unknown state; include it in one
  consolidated operator proposal instead of leaving it silent.

Integration is proven by ancestry against the local or remote integration
branch, or by content containment (squash and rebase merges).
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
        elif line == "locked" or line.startswith("locked "):
            current["locked"] = line[7:].strip()
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


def _patch_ids(repo: Path, patch: bytes) -> set[str]:
    out = subprocess.run(["git", "-C", str(repo), "patch-id", "--stable"], input=patch, capture_output=True).stdout
    return {line.split()[0] for line in out.decode("utf-8", "replace").splitlines() if line.strip()}


_APPLIED: dict[tuple[str, str, tuple[str, ...]], set[str]] = {}
MAX_FILES_PER_COMMIT = 500


def _applied_patches(repo: Path, base: str, targets: list[str]) -> set[str]:
    """Patch ids of non-merge commits applied to the targets since ``base``, cached per base."""
    key = (str(repo), base, tuple(targets))
    if key not in _APPLIED:
        # Skip bulk commits (vendored fixtures, generated trees): no squash looks like them,
        # and their patches would dominate the run time.
        stats = _git(repo, "log", "--no-merges", "--format=@%H", "--shortstat", *targets, f"^{base}", check=False)
        keep, sha = [], None
        for line in stats.splitlines():
            if line.startswith("@"):
                sha = line[1:]
                keep.append(sha)
            elif "file" in line and sha and int(line.split()[0]) > MAX_FILES_PER_COMMIT:
                keep.remove(sha)
        log = subprocess.run(["git", "-C", str(repo), "log", "-p", "--no-walk=unsorted", *keep],
                             capture_output=True).stdout if keep else b""
        _APPLIED[key] = _patch_ids(repo, log)
    return _APPLIED[key]


def _patch_contained(repo: Path, rev: str, targets: list[str]) -> bool:
    """Squash or rebase merge: the branch's combined diff, or each of its commits,
    matches a patch already applied to an integration target since their merge base."""
    base = _git(repo, "merge-base", targets[0], rev, check=False)
    if not base:
        return False
    shortstat = _git(repo, "diff", "--shortstat", base, rev, check=False).split()
    if not shortstat or int(shortstat[0]) > MAX_FILES_PER_COMMIT:
        return False
    applied = _applied_patches(repo, base, targets)
    if not applied:
        return False
    run = lambda *args: subprocess.run(["git", "-C", str(repo), *args], capture_output=True).stdout
    combined = _patch_ids(repo, run("diff", base, rev))
    if combined and combined <= applied:
        return True
    commits = _patch_ids(repo, run("log", "-p", "--no-merges", f"{base}..{rev}"))
    return bool(commits) and commits <= applied


_INTEGRATED: dict[tuple[str, str, tuple[str, ...]], str | None] = {}


def _integrated(repo: Path, rev: str, targets: list[str]) -> str | None:
    key = (str(repo), _git(repo, "rev-parse", rev, check=False) or rev, tuple(targets))
    if key not in _INTEGRATED:
        _INTEGRATED[key] = _find_integration(repo, rev, targets)
    return _INTEGRATED[key]


def _find_integration(repo: Path, rev: str, targets: list[str]) -> str | None:
    """Return the target already containing ``rev``'s work, by ancestry or content.

    Content containment covers squash and rebase merges: merging ``rev`` into the
    target would not change the target tree.
    """
    for target in targets:
        if not subprocess.run(["git", "-C", str(repo), "merge-base", "--is-ancestor", rev, target],
                              capture_output=True).returncode:
            return target
    for target in targets:
        merged = subprocess.run(["git", "-C", str(repo), "merge-tree", "--write-tree", target, rev], capture_output=True)
        if merged.returncode == 0:
            tree = merged.stdout.decode("utf-8", "replace").splitlines()[0].strip() if merged.stdout else ""
            if tree and tree == _git(repo, "rev-parse", f"{target}^{{tree}}", check=False):
                return target
    if _patch_contained(repo, rev, targets):
        return targets[0]
    return None


def resting_state(repo: Path, integration: str = "main", durable: tuple[str, ...] = ("main", "dev"),
                  remote: str = "origin", pull_requests: bool = True) -> dict[str, object]:
    repo = repo.resolve()
    durable_set = set(durable) | {integration}
    targets = [integration]
    if _git(repo, "rev-parse", "--verify", "-q", f"{remote}/{integration}", check=False):
        targets.append(f"{remote}/{integration}")
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
            # Pushing follows the operator's push policy, which may require an explicit request.
            add("upstream", current, f"{ahead} commits not pushed", "push")
        if behind:
            add("upstream", current, f"{behind} commits not pulled", "auto")

    for branch in _lines(_git(repo, "for-each-ref", "--format=%(refname:short)", "refs/heads")):
        if branch in durable_set:
            continue
        found = _integrated(repo, branch, targets)
        add("local-branch", branch, f"integrated into {found}" if found else f"not integrated into {integration}",
            "auto" if found else "merge")

    main_path = None
    for entry in _worktrees(repo):
        if main_path is None:
            main_path = entry.get("path")
            continue
        name = f"{entry.get('path')} [{entry.get('branch', 'detached')}]"
        if entry.get("prunable"):
            add("worktree", name, "folder missing", "auto")
        elif "locked" in entry:
            reason = entry["locked"] or "no reason given"
            add("worktree", name, f"locked ({reason}); removal needs an explicit operator decision", "ask")
        else:
            found = _integrated(repo, str(entry.get("branch") or entry.get("head", "")), targets)
            add("worktree", name, "work integrated" if found else "work not integrated", "auto" if found else "ask")

    for ref in _lines(_git(repo, "for-each-ref", "--format=%(refname:short)", f"refs/remotes/{remote}")):
        branch = ref.removeprefix(f"{remote}/")
        if branch in durable_set or branch == "HEAD" or ref == remote:
            continue
        found = _integrated(repo, ref, targets)
        add("remote-branch", ref, f"integrated into {found}" if found else "not integrated",
            "auto" if found else "merge")

    prs = _open_pull_requests(repo) if pull_requests else None
    if prs is None and pull_requests:
        add("pull-requests", "-", "open pull requests unknown (gh unavailable)", "ask")
    for pr in prs or []:
        name = f"#{pr['number']} {pr['headRefName']} -> {pr['baseRefName']}"
        head = f"{remote}/{pr['headRefName']}"
        found = _integrated(repo, head, targets) if _git(repo, "rev-parse", "--verify", "-q", head, check=False) else None
        if found:
            add("pull-request", name, f"content already in {found}; closes once that branch is pushed or merged", "auto")
        else:
            add("pull-request", name, "draft" if pr.get("isDraft") else "open", "ask" if pr.get("isDraft") else "merge")

    return {"resting": not items, "integration": integration, "targets": targets, "current": current, "items": items}


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
