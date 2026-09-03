#!/usr/bin/env python3
"""Read effective per-repository branch and worktree creation policy."""

from __future__ import annotations

import argparse
import json
import re
from dataclasses import asdict, dataclass
from pathlib import Path


CANONICAL_RELATIVE = Path("shipglows_data/technical/guidelines.md")
VALID_POLICIES = {"allowed", "forbidden"}
POLICY_FIELDS = ("task_branch_policy", "worktree_policy")


@dataclass(frozen=True)
class GitPolicy:
    state: str
    canonical_source: str
    task_branch_policy: str
    worktree_policy: str
    reason: str


def _frontmatter(text: str) -> str:
    if not text.startswith("---"):
        return ""
    parts = text.split("---", 2)
    return parts[1] if len(parts) == 3 else ""


def _field(frontmatter: str, name: str) -> str | None:
    match = re.search(
        rf"(?mi)^{re.escape(name)}:\s*[\"']?([^\s\"']+)[\"']?\s*$",
        frontmatter,
    )
    return match.group(1).lower() if match else None


def inspect_project(project: Path) -> GitPolicy:
    source = project.resolve() / CANONICAL_RELATIVE
    relative = CANONICAL_RELATIVE.as_posix()
    if not source.is_file():
        return GitPolicy(
            "defaulted", relative, "forbidden", "forbidden",
            "canonical technical guidelines are missing; fail-closed defaults applied",
        )

    frontmatter = _frontmatter(source.read_text(encoding="utf-8"))
    values = {name: _field(frontmatter, name) for name in POLICY_FIELDS}
    invalid = {
        name: value for name, value in values.items()
        if value is not None and value not in VALID_POLICIES
    }
    if invalid:
        details = ", ".join(f"{name}={value}" for name, value in invalid.items())
        return GitPolicy(
            "invalid", relative, "forbidden", "forbidden",
            f"unsupported Git policy value(s): {details}; fail-closed defaults applied",
        )

    missing = [name for name, value in values.items() if value is None]
    task_branch = values["task_branch_policy"] or "forbidden"
    worktree = values["worktree_policy"] or "forbidden"
    if missing:
        return GitPolicy(
            "defaulted", relative, task_branch, worktree,
            f"missing {', '.join(missing)}; forbidden default applied",
        )
    return GitPolicy(
        "resolved", relative, task_branch, worktree,
        "canonical repository Git policy resolved",
    )


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Inspect repository branch/worktree creation policy without mutation."
    )
    parser.add_argument("--project", type=Path, default=Path.cwd())
    parser.add_argument("--format", choices=("json", "text"), default="text")
    args = parser.parse_args(argv)
    policy = inspect_project(args.project)
    if args.format == "json":
        print(json.dumps(asdict(policy), sort_keys=True))
    else:
        print(f"state={policy.state}")
        print(f"canonical_source={policy.canonical_source}")
        print(f"task_branch_policy={policy.task_branch_policy}")
        print(f"worktree_policy={policy.worktree_policy}")
        print(f"reason={policy.reason}")
    return 2 if policy.state == "invalid" else 0


if __name__ == "__main__":
    raise SystemExit(main())
