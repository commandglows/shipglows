#!/usr/bin/env python3
"""Validate the ShipGlows numeric skill-code index."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


ROW_RE = re.compile(
    r"^\|\s*`(?P<code>\d{3})`\s*\|\s*`(?P<old>[^`]+)`\s*\|\s*`(?P<skill>[^`]+)`\s*\|\s*(?P<family>[^|]+?)\s*\|"
)
RUNTIME_NAME_RE = re.compile(r"^\d{3}-[a-z0-9](?:[a-z0-9-]{0,59}[a-z0-9])?$")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--index",
        default="skills/references/skill-code-index.md",
        help="Path to the Markdown skill-code index.",
    )
    parser.add_argument(
        "--skills-root",
        default="skills",
        help="Path to the ShipGlows skills root.",
    )
    return parser.parse_args()


def skill_dirs(skills_root: Path) -> set[str]:
    return {
        path.parent.name
        for path in skills_root.glob("*/SKILL.md")
        if path.parent.is_dir()
        and "Compatibility alias." not in path.read_text(encoding="utf-8")
    }


def parse_index(index_path: Path) -> list[tuple[str, str, str, str, int]]:
    rows: list[tuple[str, str, str, str, int]] = []
    for lineno, line in enumerate(index_path.read_text(encoding="utf-8").splitlines(), start=1):
        match = ROW_RE.match(line)
        if not match:
            continue
        rows.append(
            (
                match.group("code"),
                match.group("old"),
                match.group("skill"),
                match.group("family").strip(),
                lineno,
            )
        )
    return rows


def main() -> int:
    args = parse_args()
    index_path = Path(args.index)
    skills_root = Path(args.skills_root)
    errors: list[str] = []

    if not index_path.exists():
        errors.append(f"missing index: {index_path}")
        print_errors(errors)
        return 1
    if not skills_root.exists():
        errors.append(f"missing skills root: {skills_root}")
        print_errors(errors)
        return 1

    rows = parse_index(index_path)
    if not rows:
        errors.append(f"no active code rows found in {index_path}")

    codes: dict[str, int] = {}
    skills: dict[str, int] = {}
    indexed_skills: set[str] = set()
    existing_skills = skill_dirs(skills_root)

    for code, old_name, skill, family, lineno in rows:
        if code in codes:
            errors.append(f"duplicate code {code}: lines {codes[code]} and {lineno}")
        codes[code] = lineno

        if skill in skills:
            errors.append(f"duplicate skill {skill}: lines {skills[skill]} and {lineno}")
        skills[skill] = lineno
        indexed_skills.add(skill)

        if not family:
            errors.append(f"empty family for {code}-{skill}: line {lineno}")

        if not RUNTIME_NAME_RE.match(skill):
            errors.append(f"bad runtime skill name: {skill} on line {lineno}")

        expected_skill = f"{code}-{old_name}"
        if skill != expected_skill:
            errors.append(f"bad runtime name for {old_name}: expected {expected_skill}, got {skill} on line {lineno}")

        if skill not in existing_skills:
            errors.append(f"indexed skill does not exist: {skill} on line {lineno}")

    missing = sorted(existing_skills - indexed_skills)
    extra = sorted(indexed_skills - existing_skills)
    if missing:
        errors.append("skills missing from index: " + ", ".join(missing))
    if extra:
        errors.append("index points to absent skills: " + ", ".join(extra))

    if errors:
        print_errors(errors)
        return 1

    print(f"OK: {len(rows)} three-digit runtime skill codes cover {len(existing_skills)} skills")
    return 0


def print_errors(errors: list[str]) -> None:
    for error in errors:
        print(f"ERROR: {error}", file=sys.stderr)


if __name__ == "__main__":
    raise SystemExit(main())
