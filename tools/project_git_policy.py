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
    configuration_guidance: str


CONFIGURATION_GUIDANCE = (
    "forbidden prevents silent creation; discuss a justified need with the user "
    "before changing the repository policy"
)


def _frontmatter(text: str) -> str:
    if not text.startswith("---"):
        return ""
    parts = text.split("---", 2)
    return parts[1] if len(parts) == 3 else ""


def _canonical_scalar(frontmatter: str, name: str) -> tuple[str | None, str | None]:
    """Read one top-level scalar without interpreting general YAML."""
    if any(
        re.match(rf"^[ \t]+{re.escape(name)}[ \t]*:", line)
        for line in frontmatter.splitlines()
    ):
        return None, f"canonical field must be top-level: {name}"
    values = [
        match.group(1)
        for line in frontmatter.splitlines()
        if (match := re.match(rf"^{re.escape(name)}[ \t]*:(.*)$", line))
    ]
    if len(values) > 1:
        return None, f"duplicate canonical field: {name}"
    if not values:
        return None, None

    raw = values[0]
    if raw and raw[0] not in " \t":
        return None, f"ambiguous YAML scalar for {name}: whitespace required after ':'"
    raw = raw.strip()
    if not raw or raw.startswith("#"):
        return None, None

    if raw[0] in "\"'":
        quote = raw[0]
        end = raw.find(quote, 1)
        if end < 0:
            return None, f"unterminated quoted scalar for {name}"
        value = raw[1:end]
        suffix = raw[end + 1 :]
        if suffix and not suffix[0].isspace():
            return None, f"ambiguous trailing content for {name}"
        suffix = suffix.strip()
        if suffix and not suffix.startswith("#"):
            return None, f"ambiguous trailing content for {name}"
    else:
        value = re.split(r"[ \t]+#", raw, maxsplit=1)[0].strip()

    if value.lower() in {"", "none", "null", "~"}:
        return None, None
    return value.lower(), None


def inspect_project(project: Path) -> GitPolicy:
    source = project.resolve() / CANONICAL_RELATIVE
    relative = CANONICAL_RELATIVE.as_posix()
    if not source.is_file():
        return GitPolicy(
            "defaulted", relative, "forbidden", "forbidden",
            "canonical technical guidelines are missing; fail-closed defaults applied",
            CONFIGURATION_GUIDANCE,
        )

    frontmatter = _frontmatter(source.read_text(encoding="utf-8"))
    parsed = {name: _canonical_scalar(frontmatter, name) for name in POLICY_FIELDS}
    values = {name: item[0] for name, item in parsed.items()}
    parse_issues = {name: item[1] for name, item in parsed.items() if item[1]}
    invalid = {
        name: value for name, value in values.items()
        if value is not None and value not in VALID_POLICIES
    }
    invalid.update(parse_issues)
    missing = [name for name, value in values.items() if value is None]
    task_branch = (
        values["task_branch_policy"]
        if values["task_branch_policy"] in VALID_POLICIES
        else "forbidden"
    )
    worktree = (
        values["worktree_policy"]
        if values["worktree_policy"] in VALID_POLICIES
        else "forbidden"
    )
    if invalid:
        details = ", ".join(f"{name}={value}" for name, value in invalid.items())
        return GitPolicy(
            "invalid", relative, task_branch, worktree,
            f"unsupported Git policy value(s): {details}; forbidden default applied to invalid fields",
            CONFIGURATION_GUIDANCE,
        )
    if missing:
        return GitPolicy(
            "defaulted", relative, task_branch, worktree,
            f"missing {', '.join(missing)}; forbidden default applied",
            CONFIGURATION_GUIDANCE,
        )
    return GitPolicy(
        "resolved", relative, task_branch, worktree,
        "canonical repository Git policy resolved",
        CONFIGURATION_GUIDANCE,
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
        print(f"configuration_guidance={policy.configuration_guidance}")
    return 2 if policy.state == "invalid" else 0


if __name__ == "__main__":
    raise SystemExit(main())
