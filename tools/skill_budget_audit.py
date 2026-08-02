#!/usr/bin/env python3
"""Audit ShipGlows skill discovery metadata.

The audit intentionally uses only Python's standard library so it can run in a
fresh ShipGlows checkout before project dependencies are installed.
"""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path


AGGREGATE_BUDGET = 8500
DESCRIPTION_TARGET_MAX = 120
DESCRIPTION_WARNING_MAX = 140
DESCRIPTION_HARD_MAX = 200
AGENT_SKILLS_DESCRIPTION_MAX = 1024
CLAUDE_LISTING_TEXT_MAX = 1536
COMPATIBILITY_MAX = 500
BODY_TOKEN_RISK = 5000
NAME_MAX = 64
DEFAULT_BATCH_SIZE = 8
VALID_NAME = re.compile(r"^[a-z0-9-]+$")
XML_TAG = re.compile(r"<[^>]+>")
GENERIC_STARTS = {
    "help",
    "manage",
    "use",
    "handle",
    "work",
    "do",
    "make",
    "create",
    "run",
}


@dataclass
class SkillAudit:
    path: Path
    display_path: str
    name: str = ""
    description: str = ""
    when_to_use: str = ""
    compatibility: str = ""
    body_lines: int = 0
    body_token_estimate: int = 0
    sentence_count: int = 0
    batch: int = 0
    errors: list[str] = field(default_factory=list)
    warnings: list[str] = field(default_factory=list)
    risks: list[str] = field(default_factory=list)

    @property
    def description_length(self) -> int:
        return len(self.description)

    @property
    def listing_text_length(self) -> int:
        return len(self.description) + len(self.when_to_use)

    @property
    def absolute_budget(self) -> int:
        return len(str(self.path.resolve())) + len(self.name) + len(self.description)

    @property
    def relative_budget(self) -> int:
        return len(self.display_path) + len(self.name) + len(self.description)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--skills-root",
        default="skills",
        help="Directory containing skill folders. Defaults to ./skills.",
    )
    parser.add_argument(
        "--format",
        choices=("text", "markdown"),
        default="text",
        help="Output format. Defaults to text.",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Exit non-zero when warnings are present, not only hard violations.",
    )
    parser.add_argument(
        "--check-names",
        action="store_true",
        help="Compatibility flag; name checks always run.",
    )
    parser.add_argument(
        "--check-paths",
        action="store_true",
        help="Compatibility flag; path checks always run.",
    )
    parser.add_argument(
        "--batch-size",
        type=int,
        default=DEFAULT_BATCH_SIZE,
        help=f"Suggested remediation batch size. Defaults to {DEFAULT_BATCH_SIZE}.",
    )
    return parser.parse_args()


def iter_skill_files(skills_root: Path) -> list[Path]:
    if not skills_root.exists():
        raise SystemExit(f"skills root not found: {skills_root}")
    if not skills_root.is_dir():
        raise SystemExit(f"skills root is not a directory: {skills_root}")
    return sorted(skills_root.rglob("SKILL.md"))


def display_path(path: Path, skills_root: Path) -> str:
    try:
        relative = path.relative_to(skills_root)
        return str(Path(skills_root.name) / relative)
    except ValueError:
        return str(path)


def estimate_tokens(text: str) -> int:
    return (len(text) + 3) // 4


def read_frontmatter(path: Path) -> tuple[dict[str, str], list[str], int, int]:
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return {}, ["missing YAML frontmatter"], len(lines), estimate_tokens(text)

    end_index = None
    for index, line in enumerate(lines[1:], start=1):
        if line.strip() == "---":
            end_index = index
            break
    if end_index is None:
        return {}, ["missing closing YAML frontmatter delimiter"], len(lines), estimate_tokens(text)

    fields: dict[str, str] = {}
    errors: list[str] = []
    multiline_keys: list[str] = []
    for line in lines[1:end_index]:
        stripped = line.strip()
        if not stripped or stripped.startswith("#") or stripped.startswith("-"):
            continue
        match = re.match(r"^([A-Za-z_][A-Za-z0-9_-]*):(?:\s*(.*))?$", line)
        if not match:
            continue
        key, value = match.groups()
        clean_value = (value or "").strip()
        if clean_value in {"|", ">"}:
            multiline_keys.append(key)
            fields[key] = clean_value
            continue
        fields[key] = clean_value.strip("\"'")

    if "description" in multiline_keys:
        errors.append("description must be a single-line YAML scalar")

    body_text = "\n".join(lines[end_index + 1 :])
    return fields, errors, len(lines), estimate_tokens(body_text)


def sentence_count(description: str) -> int:
    if not description:
        return 0
    boundaries = re.findall(r"[.!?](?=\s|$)", description)
    return max(1, len(boundaries))


def first_word(description: str) -> str:
    match = re.match(r"^[^A-Za-z0-9]*([A-Za-z0-9-]+)", description)
    return match.group(1).lower() if match else ""


def audit_skill(path: Path, skills_root: Path, batch: int) -> SkillAudit:
    audit = SkillAudit(path=path, display_path=display_path(path, skills_root), batch=batch)
    fields, initial_errors, body_lines, body_token_estimate = read_frontmatter(path)
    audit.errors.extend(initial_errors)
    audit.body_lines = body_lines
    audit.body_token_estimate = body_token_estimate
    audit.name = fields.get("name", "")
    audit.description = fields.get("description", "")
    audit.when_to_use = fields.get("when_to_use", "")
    audit.compatibility = fields.get("compatibility", "")
    audit.sentence_count = sentence_count(audit.description)

    expected_name = path.parent.name
    expected_parent = skills_root.resolve()
    actual_parent = path.parent.parent.resolve()

    if not audit.name:
        audit.errors.append("missing name")
    elif audit.name != expected_name:
        audit.errors.append(f"name must match directory ({expected_name})")
    if audit.name and len(audit.name) > NAME_MAX:
        audit.errors.append(f"name exceeds {NAME_MAX} characters")
    if audit.name and not VALID_NAME.match(audit.name):
        audit.errors.append("name must use lowercase letters, numbers, and hyphens only")
    if audit.name and (audit.name.startswith("-") or audit.name.endswith("-")):
        audit.errors.append("name must not start or end with a hyphen")
    if audit.name and "--" in audit.name:
        audit.errors.append("name must not contain consecutive hyphens")
    if audit.name and XML_TAG.search(audit.name):
        audit.errors.append("name must not contain XML/HTML tags")

    if actual_parent != expected_parent:
        audit.errors.append("path must match skills/<name>/SKILL.md")

    if not audit.description:
        audit.errors.append("missing description")
    else:
        if "Args:" in audit.description:
            audit.errors.append("description must not contain Args:")
        if XML_TAG.search(audit.description):
            audit.errors.append("description must not contain XML/HTML tags")
        if audit.description_length > AGENT_SKILLS_DESCRIPTION_MAX:
            audit.errors.append(f"description exceeds Agent Skills maximum ({AGENT_SKILLS_DESCRIPTION_MAX})")
        if audit.description_length > DESCRIPTION_HARD_MAX:
            audit.errors.append(f"description exceeds {DESCRIPTION_HARD_MAX} characters")
        elif audit.description_length > DESCRIPTION_WARNING_MAX:
            audit.warnings.append(f"description exceeds warning threshold ({DESCRIPTION_WARNING_MAX})")
        if audit.listing_text_length > CLAUDE_LISTING_TEXT_MAX:
            audit.errors.append(
                f"description + when_to_use exceeds Claude listing cap ({CLAUDE_LISTING_TEXT_MAX})"
            )
        if audit.sentence_count > 1:
            audit.errors.append("description must be one sentence maximum")
        if first_word(audit.description) in GENERIC_STARTS:
            audit.warnings.append("description starts with a generic verb; front-load trigger keywords")

    if audit.compatibility and len(audit.compatibility) > COMPATIBILITY_MAX:
        audit.errors.append(f"compatibility exceeds {COMPATIBILITY_MAX} characters")

    if audit.body_lines > 500:
        audit.risks.append("SKILL.md exceeds 500 lines; separate body-size risk, not an initial discovery blocker")
    if audit.body_token_estimate > BODY_TOKEN_RISK:
        audit.risks.append(
            f"SKILL.md body is about {audit.body_token_estimate} tokens; consider moving detail to references/"
        )

    return audit


def audit_all(skills_root: Path, batch_size: int) -> list[SkillAudit]:
    files = iter_skill_files(skills_root)
    audits: list[SkillAudit] = []
    for index, path in enumerate(files):
        batch = (index // max(1, batch_size)) + 1
        audits.append(audit_skill(path, skills_root, batch))
    return audits


def summary(audits: list[SkillAudit]) -> dict[str, float | int]:
    count = len(audits)
    absolute = sum(audit.absolute_budget for audit in audits)
    relative = sum(audit.relative_budget for audit in audits)
    description = sum(audit.description_length for audit in audits)
    return {
        "skills": count,
        "errors": sum(len(audit.errors) for audit in audits),
        "warnings": sum(len(audit.warnings) for audit in audits),
        "risks": sum(len(audit.risks) for audit in audits),
        "absolute_budget": absolute,
        "relative_budget": relative,
        "description_chars": description,
        "average_description": round(description / count, 1) if count else 0,
        "over_200": sum(1 for audit in audits if audit.description_length > DESCRIPTION_HARD_MAX),
        "over_140": sum(1 for audit in audits if audit.description_length > DESCRIPTION_WARNING_MAX),
        "over_120": sum(1 for audit in audits if audit.description_length > DESCRIPTION_TARGET_MAX),
        "long_bodies": sum(1 for audit in audits if audit.body_lines > 500),
        "body_token_risks": sum(1 for audit in audits if audit.body_token_estimate > BODY_TOKEN_RISK),
    }


def print_text(audits: list[SkillAudit], aggregate_errors: list[str]) -> None:
    totals = summary(audits)
    print("Skill Budget Audit")
    print(f"Skills: {totals['skills']}")
    print(f"Hard violations: {totals['errors']}")
    print(f"Warnings: {totals['warnings']}")
    print(f"Separate risks: {totals['risks']}")
    print(f"Absolute estimate: {totals['absolute_budget']} / {AGGREGATE_BUDGET}")
    print(f"Repo-relative estimate: {totals['relative_budget']} / {AGGREGATE_BUDGET}")
    print(f"Average description length: {totals['average_description']}")
    print(f"Descriptions >200: {totals['over_200']}")
    print(f"Descriptions >140: {totals['over_140']}")
    print(f"Descriptions >120: {totals['over_120']}")
    print(f"Skill bodies >500 lines: {totals['long_bodies']}")
    print(f"Skill bodies >~5000 tokens: {totals['body_token_risks']}")
    for message in aggregate_errors:
        print(f"ERROR: {message}")
    print()

    for audit in audits:
        if not audit.errors and not audit.warnings and not audit.risks:
            continue
        print(f"{audit.display_path}")
        print(
            f"  name={audit.name or '-'} desc_len={audit.description_length} "
            f"listing_len={audit.listing_text_length} sentences={audit.sentence_count} "
            f"lines={audit.body_lines} body_tokens~{audit.body_token_estimate} batch={audit.batch}"
        )
        for error in audit.errors:
            print(f"  ERROR: {error}")
        for warning in audit.warnings:
            print(f"  WARN: {warning}")
        for risk in audit.risks:
            print(f"  RISK: {risk}")


def markdown_escape(value: str) -> str:
    return value.replace("|", "\\|")


def print_markdown(audits: list[SkillAudit], aggregate_errors: list[str]) -> None:
    totals = summary(audits)
    print("## Skill Budget Audit")
    print()
    print(f"- Skills: {totals['skills']}")
    print(f"- Hard violations: {totals['errors']}")
    print(f"- Warnings: {totals['warnings']}")
    print(f"- Separate risks: {totals['risks']}")
    print(f"- Absolute estimate: {totals['absolute_budget']} / {AGGREGATE_BUDGET}")
    print(f"- Repo-relative estimate: {totals['relative_budget']} / {AGGREGATE_BUDGET}")
    print(f"- Average description length: {totals['average_description']}")
    print(f"- Descriptions >200: {totals['over_200']}")
    print(f"- Descriptions >140: {totals['over_140']}")
    print(f"- Descriptions >120: {totals['over_120']}")
    print(f"- Skill bodies >500 lines: {totals['long_bodies']}")
    print(f"- Skill bodies >~5000 tokens: {totals['body_token_risks']}")
    for message in aggregate_errors:
        print(f"- ERROR: {message}")
    print()
    print("| Batch | Skill | Description chars | Listing chars | Sentences | Lines | Body tokens est. | Status | Issues |")
    print("|-------|-------|-------------------|---------------|-----------|-------|------------------|--------|--------|")
    for audit in audits:
        issues = audit.errors + audit.warnings + audit.risks
        status = "fail" if audit.errors else "warn" if audit.warnings else "risk" if audit.risks else "ok"
        issue_text = "<br>".join(markdown_escape(issue) for issue in issues) or "-"
        print(
            f"| {audit.batch} | `{audit.display_path}` | {audit.description_length} | "
            f"{audit.listing_text_length} | {audit.sentence_count} | {audit.body_lines} | "
            f"{audit.body_token_estimate} | {status} | {issue_text} |"
        )


def main() -> int:
    args = parse_args()
    skills_root = Path(args.skills_root).resolve()
    audits = audit_all(skills_root, args.batch_size)

    aggregate_errors: list[str] = []
    totals = summary(audits)
    if totals["absolute_budget"] > AGGREGATE_BUDGET:
        aggregate_errors.append(
            f"absolute aggregate estimate exceeds {AGGREGATE_BUDGET}: {totals['absolute_budget']}"
        )

    if args.format == "markdown":
        print_markdown(audits, aggregate_errors)
    else:
        print_text(audits, aggregate_errors)

    has_errors = any(audit.errors for audit in audits)
    has_warnings = any(audit.warnings for audit in audits)
    if has_errors or aggregate_errors or (args.strict and has_warnings):
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
