#!/usr/bin/env python3
"""Execution-fidelity audit for local ShipGlows skills."""

from __future__ import annotations

import os
import re
from dataclasses import dataclass, field
from pathlib import Path


HEADING_RE = re.compile(r"^#{1,3}\s+(.+?)\s*$", re.MULTILINE)
REFERENCE_PATH_RE = re.compile(
    r"(?P<path>skills/[A-Za-z0-9_.-]+(?:/[A-Za-z0-9_.-]+)*\.md"
    r"|references/[A-Za-z0-9_.-]+(?:/[A-Za-z0-9_.-]+)*\.md)"
)

MISSION_ALIASES = (
    "mission",
    "your task",
    "purpose",
    "scope gate",
    "core rule",
    "mode detection",
    "what this skill does",
)
STOP_SIGNALS = (
    "stop condition",
    "stop and report",
    "stop, ask",
    "blocked when",
    "must never",
    "do not ",
    "ask before",
)
VALIDATION_SIGNALS = (
    "validation",
    "validate with",
    "test strategy",
    "proof path",
    "run ",
    "checks",
    "verify",
)
REPORT_SIGNALS = (
    "report modes",
    "final report",
    "reporting",
    "report=user",
    "report=agent",
    "reporting-contract",
)
ACTIVATION_ROUTE_SIGNALS = (
    "next best action",
    "owner skill",
    "recommended path",
    "guided route",
    "first success",
)
FOCUS_TAG_EXECUTION_SIGNALS = (
    "focus tag",
    "focus tags",
    "route-bias",
    "route bias",
    "artifact preference",
    "public-docs",
    "single-source",
    "shipglows-core",
)
REFERENCE_SIGNALS = (
    "required references",
    "before ",
    "load ",
    "$shipglows_root/skills/references",
    "skills/references/",
)
PREFLIGHT_SIGNALS = (
    "resolve `$shipglows_root`",
    "confirm the owned path",
    "confirm the target tool",
)
CANONICAL_PATHS_LOADER_SIGNAL = "load `$shipglows_root/skills/references/canonical-paths.md`"
CANONICAL_PATHS_SHARED_PREFLIGHT_SIGNAL = "## shipglows-owned tool preflight"


@dataclass
class FindingSet:
    hard: list[str] = field(default_factory=list)
    review: list[str] = field(default_factory=list)
    style: list[str] = field(default_factory=list)

    def any(self) -> bool:
        return bool(self.hard or self.review or self.style)


def frontmatter_status(path: Path, text: str) -> list[str]:
    if not text.startswith("---\n"):
        return ["frontmatter missing"]
    try:
        end = text.index("\n---\n", 4)
    except ValueError:
        return ["frontmatter unterminated"]

    block = text[4:end]
    issues: list[str] = []
    for key in ("name:", "description:"):
        if key not in block:
            issues.append(f"frontmatter missing {key[:-1]}")

    name_match = re.search(r"^name:\s*['\"]?([^'\"\n]+)", block, re.MULTILINE)
    if name_match:
        name = name_match.group(1).strip()
        if name != path.parent.name:
            issues.append(f"frontmatter name '{name}' does not match directory '{path.parent.name}'")

    return issues


def headings(text: str) -> set[str]:
    return {match.group(1).strip().lower() for match in HEADING_RE.finditer(text)}


def has_any(text: str, signals: tuple[str, ...]) -> bool:
    lowered = text.lower()
    return any(signal in lowered for signal in signals)


def has_heading_alias(found_headings: set[str], aliases: tuple[str, ...]) -> bool:
    return any(any(alias in heading for alias in aliases) for heading in found_headings)


def has_shared_canonical_paths_preflight(path: Path, text: str) -> bool:
    lowered = text.lower()
    if CANONICAL_PATHS_LOADER_SIGNAL not in lowered:
        return False

    canonical_paths = path.parents[1] / "references" / "canonical-paths.md"
    if not canonical_paths.exists():
        return False

    canonical_text = canonical_paths.read_text(encoding="utf-8").lower()
    return CANONICAL_PATHS_SHARED_PREFLIGHT_SIGNAL in canonical_text


def missing_reference_paths(path: Path, text: str) -> list[str]:
    """Return exact Markdown loaders that do not resolve canonically."""
    root = path.parents[2]
    missing: list[str] = []
    for reference in sorted({match.group("path") for match in REFERENCE_PATH_RE.finditer(text)}):
        if reference.startswith("references/"):
            resolved = path.parent / reference
        else:
            resolved = root / reference
        if not resolved.is_file():
            missing.append(f"referenced Markdown file missing: {reference}")
    return missing


def audit_skill(path: Path) -> FindingSet:
    text = path.read_text(encoding="utf-8")
    findings = FindingSet()

    findings.hard.extend(frontmatter_status(path, text))
    findings.hard.extend(missing_reference_paths(path, text))

    line_count = text.count("\n") + 1
    token_estimate = max(1, len(text) // 4)
    if line_count > 500 or token_estimate > 5000:
        findings.review.append(f"body-size risk: {line_count} lines, about {token_estimate} tokens")

    found_headings = headings(text)
    lowered = text.lower()

    if not has_heading_alias(found_headings, MISSION_ALIASES):
        if "description:" in lowered:
            findings.style.append("no explicit mission/owner heading; frontmatter description is the only obvious trigger")
        else:
            findings.review.append("no visible mission/owner heading or accepted alias")

    if not has_any(text, STOP_SIGNALS):
        findings.review.append("no visible stop-condition signal")

    if not has_any(text, VALIDATION_SIGNALS):
        findings.review.append("no visible validation/proof signal")

    if not has_any(text, REPORT_SIGNALS):
        findings.review.append("no visible report-contract signal")

    if "$SHIPGLOWS_ROOT" in text and not has_any(text, REFERENCE_SIGNALS):
        findings.style.append("$SHIPGLOWS_ROOT appears but reference-loading intent is not obvious")

    if path.parent.name == "008-sg-customer" and not has_any(text, ACTIVATION_ROUTE_SIGNALS):
        findings.review.append(
            "onboarding contract lacks visible next-best-action guidance for recurring friction or setup forks"
        )

    if path.parent.name == "000-shipglows" and not has_any(text, FOCUS_TAG_EXECUTION_SIGNALS):
        findings.review.append(
            "primary router lacks visible focus-tag execution guidance beyond generic reference loading"
        )

    if "${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/tools/" in text and not (
        has_any(text, PREFLIGHT_SIGNALS) or has_shared_canonical_paths_preflight(path, text)
    ):
        findings.review.append(
            "ShipGlows-owned tool invocation lacks visible preflight doctrine: "
            "local explicit order or shared canonical-paths preflight"
        )

    if "/home/claude/" in text:
        findings.review.append("hard-coded /home/claude path")

    return findings


def print_group(title: str, items: list[str]) -> None:
    if not items:
        return
    print(f"  {title}:")
    for item in items:
        print(f"    - {item}")


def main() -> int:
    root = Path(os.environ.get("SHIPGLOWS_ROOT", str(Path.home() / "shipglows")))
    skills_dir = root / "skills"
    if not skills_dir.exists():
        print(f"ShipGlows skills directory not found: {skills_dir}")
        return 2

    skill_files = sorted(path for path in skills_dir.glob("*/SKILL.md") if not path.parent.is_symlink())
    if not skill_files:
        print(f"No SKILL.md files found under {skills_dir}")
        return 2

    hard_total = 0
    review_total = 0
    style_total = 0
    files_with_findings = 0

    print(f"Auditing {len(skill_files)} skills under {skills_dir}")
    for skill_file in skill_files:
        findings = audit_skill(skill_file)
        if not findings.any():
            continue
        files_with_findings += 1
        hard_total += len(findings.hard)
        review_total += len(findings.review)
        style_total += len(findings.style)

        rel = skill_file.relative_to(root)
        print(f"\n{rel}")
        print_group("Hard", findings.hard)
        print_group("Review", findings.review)
        print_group("Style", findings.style)

    print("\nSummary")
    print(f"- Files with findings: {files_with_findings}")
    print(f"- Hard findings: {hard_total}")
    print(f"- Review findings: {review_total}")
    print(f"- Style findings: {style_total}")

    if hard_total:
        print("\nHard findings should block a completion claim.")
    elif review_total:
        print("\nReview findings need human or scenario-first triage before broad edits.")
    else:
        print("\nNo hard or review-level execution-fidelity findings found.")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
