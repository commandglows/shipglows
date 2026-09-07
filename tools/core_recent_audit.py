"""Read-only integrated Git inventory for Core's semantic loading audit.

No automatic quality verdict: changed-file estimates are not scenario costs.
"""
from __future__ import annotations

import argparse
import json
import subprocess
from pathlib import Path


class AuditError(ValueError):
    pass


def git(root: Path, *args: str) -> str:
    result = subprocess.run(
        ["git", "--no-optional-locks", "-C", str(root), *args],
        capture_output=True, encoding="utf-8", errors="replace",
    )
    if result.returncode:
        raise AuditError(result.stderr.strip() or "Git command failed")
    return result.stdout


def resolve(root: Path, ref: str) -> str:
    return git(root, "rev-parse", "--verify", "--end-of-options", ref + "^{commit}").strip()


def content(root: Path, revision: str, path: str) -> str | None:
    # Revision is a resolved SHA; absence at either endpoint is an add/delete.
    result = subprocess.run(
        ["git", "--no-optional-locks", "-C", str(root), "show", f"{revision}:{path}"],
        capture_output=True, encoding="utf-8", errors="replace",
    )
    if result.returncode:
        return None
    return result.stdout


def relevant(path: str) -> bool:
    return path.startswith(("skills/", "tools/", "templates/", "shipglows_data/", ".codex-plugin/")) or path in {
        "AGENTS.md", "CLAUDE.md", "SHIPGLOWS.md", "README.md",
    }


def inventory(root: Path, integration: str, count: int = 10, since: str | None = None) -> dict:
    if not integration.startswith(("refs/heads/", "refs/remotes/")) or integration.endswith("/HEAD"):
        raise AuditError("Use an evidence-backed full integration branch ref, not HEAD or a guessed default")
    if count < 1:
        raise AuditError("count must be positive")
    tip = resolve(root, integration)
    warnings = ["remote freshness not verified; local ref snapshot only"]
    if git(root, "rev-parse", "--is-shallow-repository").strip() == "true":
        warnings.append("shallow history: completeness not established")
    if since:
        base = resolve(root, since)
        # First-parent membership prevents a merge's side branch from becoming
        # a misleading integration baseline. A missing base never broadens scope.
        chain = git(root, "rev-list", "--first-parent", tip).splitlines()
        if base not in chain:
            raise AuditError("since must be on the integration first-parent chain; history may be incomplete")
        commits = list(reversed(chain[:chain.index(base)]))
    else:
        chain = git(root, "rev-list", "--first-parent", f"--max-count={count + 1}", tip).splitlines()
        if len(chain) < 2:
            raise AuditError("No parent baseline available; supply complete integration history")
        base = chain[-1]
        commits = list(reversed(chain[:-1]))
        if len(commits) < count:
            warnings.append(f"short window: requested {count}, available {len(commits)} with a parent baseline")
    records = []
    touched: set[str] = set()
    parent = base
    for commit in commits:
        paths = [p for p in git(root, "diff", "--name-only", "-z", "--no-renames", parent, commit, "--").split("\0") if p]
        selected = [p for p in paths if relevant(p)]
        records.append({"commit": commit, "first_parent": parent,
                        "subject": git(root, "show", "-s", "--format=%s", commit).strip(),
                        "changed_paths": paths, "review_paths": selected})
        touched.update(selected)
        parent = commit
    changes = []
    for path in sorted(touched):
        old, new = content(root, base, path), content(root, tip, path)
        changes.append({"path": path, "before_present": old is not None,
                        "after_present": new is not None,
                        "before_estimated_tokens": (len(old) + 3) // 4 if old is not None else 0,
                        "after_estimated_tokens": (len(new) + 3) // 4 if new is not None else 0})
    return {"status": "inventory-ready", "semantic_verdict": "not-assessed",
            "integration_ref": integration, "base": base, "tip": tip,
            "mode": "since" if since else "recent", "commit_count": len(commits),
            "warnings": warnings, "commits": records, "changes": changes,
            "measurement": "ceil(decoded UTF-8 characters/4); file estimates only, not full scenario cost or observed reads",
            "local_work": "excluded: index and worktree content were not read"}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--integration", required=True, help="Verified full branch ref")
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--count", type=int, default=10)
    group.add_argument("--since")
    args = parser.parse_args()
    try:
        result = inventory(args.repo, args.integration, args.count, args.since)
    except AuditError as exc:
        print(json.dumps({"status": "blocked", "reason": str(exc)}, ensure_ascii=False))
        return 1
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
