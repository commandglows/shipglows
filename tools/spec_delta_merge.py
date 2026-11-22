#!/usr/bin/env python3
"""Merge a change spec's requirement delta into living capability specs.

A change spec (``shipglows_data/workflow/specs/<slug>.md``) declares its delta as:

    ## Capability Delta
    - Capability: `<domain>`
    ## ADDED Requirements      -> appended to the living spec
    ## MODIFIED Requirements   -> replaces the requirement of the same name
    ## REMOVED Requirements    -> deleted, with a mandatory **Reason**

The living spec is ``<specs dir>/capabilities/<domain>.md``. The merge is
deterministic and atomic: every capability is validated before any file is
written, and a MODIFIED or REMOVED requirement that does not exist in the
living spec refuses the whole merge.

Usage:
    python tools/spec_delta_merge.py <change-spec.md> [--check] [--create]
                                     [--capabilities-dir DIR] [--date YYYY-MM-DD]
    python tools/spec_delta_merge.py --validate <capability.md> [...]

Exit codes: 0 merged / valid / no delta, 1 refused, 2 usage error.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path
import re
import sys


OPERATIONS = ("ADDED", "MODIFIED", "REMOVED")
CAPABILITY_HEADING = "## Capability Delta"
REQUIREMENTS_HEADING = "## Requirements"
HISTORY_HEADING = "## Change History"
HISTORY_HEADER = (
    "| Date | Change spec | Operation | Requirement | Reason |",
    "|------|-------------|-----------|-------------|--------|",
)
REQUIREMENT = re.compile(r"^### Requirement:\s*(.*?)\s*$")
SCENARIO = re.compile(r"^#### Scenario:\s*(.*?)\s*$")
CAPABILITY_LINE = re.compile(r"^\s*(?:[-*]\s*)?\**Capability\**\s*:\s*`?([^`\s,]+)`?(.*)$", re.IGNORECASE)
CAPABILITY_SLUG = re.compile(r"^[a-z0-9][a-z0-9-]*$")
NORMATIVE = re.compile(r"\b(SHALL|MUST)\b")
WHEN = re.compile(r"^\s*[-*]\s*\*\*WHEN\*\*\s+\S")
THEN = re.compile(r"^\s*[-*]\s*\*\*THEN\*\*\s+\S")
REASON = re.compile(r"^\s*(?:[-*]\s*)?\*\*Reason\*\*\s*:\s*(\S.*?)\s*$")
FENCE = re.compile(r"^\s*(```|~~~)")
VERSION = re.compile(r'^(artifact_version:\s*)(["\']?)(\d+)\.(\d+)\.(\d+)(["\']?)\s*$')
UPDATED = re.compile(r'^(updated:\s*)(["\']?)\d{4}-\d{2}-\d{2}(["\']?)\s*$')
DATE = re.compile(r"^\d{4}-\d{2}-\d{2}$")


class DeltaError(Exception):
    """The delta or a living spec is invalid; nothing was written."""

    def __init__(self, errors: list[str]) -> None:
        super().__init__("\n".join(errors))
        self.errors = errors


@dataclass
class Requirement:
    name: str
    lines: list[str]

    @property
    def key(self) -> str:
        return " ".join(self.name.split()).casefold()

    @property
    def reason(self) -> str:
        for line in self.lines[1:]:
            match = REASON.match(line)
            if match:
                return match.group(1)
        return ""


@dataclass
class CapabilityDelta:
    capability: str
    added: list[Requirement] = field(default_factory=list)
    modified: list[Requirement] = field(default_factory=list)
    removed: list[Requirement] = field(default_factory=list)

    def operations(self) -> list[tuple[str, Requirement]]:
        return (
            [("REMOVED", item) for item in self.removed]
            + [("MODIFIED", item) for item in self.modified]
            + [("ADDED", item) for item in self.added]
        )


@dataclass
class CapabilityDocument:
    head: list[str]          # everything up to and including the "## Requirements" heading
    preamble: list[str]      # prose between the heading and the first requirement
    requirements: list[Requirement]
    tail: list[str]          # from the next "## " heading to the end of the file


@dataclass
class MergeResult:
    operations: list[tuple[str, str, str]]   # (capability, operation, requirement name)
    written: list[Path]


def _structural(lines: list[str]) -> list[bool]:
    """True for lines outside fenced code blocks, where headings are structural."""
    flags, fenced = [], False
    for line in lines:
        is_fence = bool(FENCE.match(line))
        flags.append(not fenced and not is_fence)
        if is_fence:
            fenced = not fenced
    return flags


def _strip(lines: list[str]) -> list[str]:
    start, end = 0, len(lines)
    while start < end and not lines[start].strip():
        start += 1
    while end > start and not lines[end - 1].strip():
        end -= 1
    return lines[start:end]


def _requirements(lines: list[str]) -> tuple[list[str], list[Requirement]]:
    """Split a section body into its leading prose and its requirement blocks."""
    structural = _structural(lines)
    starts = [index for index, line in enumerate(lines) if structural[index] and REQUIREMENT.match(line)]
    if not starts:
        return _strip(lines), []
    blocks = []
    for position, start in enumerate(starts):
        end = starts[position + 1] if position + 1 < len(starts) else len(lines)
        name = REQUIREMENT.match(lines[start]).group(1)
        blocks.append(Requirement(name=name, lines=_strip(lines[start:end])))
    return _strip(lines[: starts[0]]), blocks


def _sections(lines: list[str]) -> list[tuple[str, int, int]]:
    """Return (heading, body start, body end) for every structural level-2 section."""
    structural = _structural(lines)
    heads = [index for index, line in enumerate(lines) if structural[index] and line.startswith("## ")]
    return [
        (lines[start].strip(), start + 1, heads[position + 1] if position + 1 < len(heads) else len(lines))
        for position, start in enumerate(heads)
    ]


def requirement_errors(item: Requirement, operation: str = "") -> list[str]:
    """Shape errors for one requirement block."""
    label = f"{operation + ' ' if operation else ''}requirement '{item.name}'"
    if not item.name:
        return [f"{operation + ' ' if operation else ''}requirement has an empty name"]
    if operation == "REMOVED":
        return [] if item.reason else [f"{label}: a removal needs a '**Reason**: ...' line"]
    errors = []
    structural = _structural(item.lines)
    scenario_starts = [i for i, line in enumerate(item.lines) if structural[i] and SCENARIO.match(line)]
    statement = item.lines[1 : scenario_starts[0]] if scenario_starts else item.lines[1:]
    if not any(NORMATIVE.search(line) for line in statement):
        errors.append(f"{label}: the statement must use SHALL or MUST")
    if not scenario_starts:
        errors.append(f"{label}: at least one '#### Scenario:' is required")
    for position, start in enumerate(scenario_starts):
        end = scenario_starts[position + 1] if position + 1 < len(scenario_starts) else len(item.lines)
        title = SCENARIO.match(item.lines[start]).group(1) or "(unnamed)"
        body = item.lines[start + 1 : end]
        for marker, pattern in (("WHEN", WHEN), ("THEN", THEN)):
            if not any(pattern.match(line) for line in body):
                errors.append(f"{label}: scenario '{title}' needs a '- **{marker}** ...' bullet")
    return errors


def parse_change_spec(text: str) -> list[CapabilityDelta]:
    """Extract the capability deltas of a change spec. Raises DeltaError on a malformed delta."""
    lines = text.replace("\r\n", "\n").split("\n")
    deltas: list[CapabilityDelta] = []
    errors: list[str] = []
    current: CapabilityDelta | None = None
    declared_none = False
    for heading, start, end in _sections(lines):
        body = lines[start:end]
        if heading == CAPABILITY_HEADING:
            current, declared_none = None, False
            names = [match for match in (CAPABILITY_LINE.match(line) for line in body) if match]
            if not names:
                errors.append("'## Capability Delta' needs a '- Capability: `<domain>`' line")
                continue
            name = names[0].group(1).rstrip(".;")
            if name.casefold() == "none":
                declared_none = True
                continue
            if not CAPABILITY_SLUG.match(name):
                errors.append(f"Capability '{name}' must be a lowercase slug (a-z, 0-9, '-')")
                continue
            current = next((delta for delta in deltas if delta.capability == name), None)
            if current is None:
                current = CapabilityDelta(capability=name)
                deltas.append(current)
            continue
        operation = next((op for op in OPERATIONS if heading == f"## {op} Requirements"), None)
        if operation is None:
            continue
        _, blocks = _requirements(body)
        if not blocks:
            continue
        if current is None:
            reason = "declares 'Capability: none'" if declared_none else "has no '## Capability Delta' before it"
            errors.append(f"'{heading}' lists requirements but the spec {reason}; name the target Capability")
            continue
        getattr(current, operation.lower()).extend(blocks)
    for delta in deltas:
        seen: dict[str, str] = {}
        for operation, item in delta.operations():
            errors.extend(requirement_errors(item, operation))
            if item.key in seen:
                errors.append(
                    f"capability '{delta.capability}': requirement '{item.name}' appears more than one time "
                    f"in the delta ({seen[item.key]} and {operation})"
                )
            seen[item.key] = operation
    if errors:
        raise DeltaError(errors)
    return [delta for delta in deltas if delta.operations()]


def parse_capability(text: str) -> CapabilityDocument:
    """Parse a living capability spec. Raises DeltaError when '## Requirements' is missing."""
    lines = text.replace("\r\n", "\n").split("\n")
    for heading, start, end in _sections(lines):
        if heading == REQUIREMENTS_HEADING:
            preamble, requirements = _requirements(lines[start:end])
            return CapabilityDocument(
                head=lines[:start], preamble=preamble, requirements=requirements, tail=_strip(lines[end:])
            )
    raise DeltaError([f"living spec has no '{REQUIREMENTS_HEADING}' section"])


def validate_capability_text(text: str) -> list[str]:
    """Structural errors of a living capability spec (empty list when valid)."""
    try:
        document = parse_capability(text)
    except DeltaError as error:
        return error.errors
    errors: list[str] = []
    seen: set[str] = set()
    for item in document.requirements:
        errors.extend(requirement_errors(item))
        if item.key in seen:
            errors.append(f"duplicate requirement '{item.name}'")
        seen.add(item.key)
    return errors


def render_capability(document: CapabilityDocument) -> str:
    parts = ["\n".join(_strip_trailing(document.head))]
    if document.preamble:
        parts.append("\n".join(document.preamble))
    parts.extend("\n".join(item.lines) for item in document.requirements)
    if document.tail:
        parts.append("\n".join(document.tail))
    return "\n\n".join(parts) + "\n"


def _strip_trailing(lines: list[str]) -> list[str]:
    end = len(lines)
    while end and not lines[end - 1].strip():
        end -= 1
    return lines[:end]


def new_capability_text(capability: str, date: str) -> str:
    """Skeleton of a living capability spec, created by the first ADDED delta."""
    return (
        "---\n"
        "artifact: capability_spec\n"
        'metadata_schema_version: "1.0"\n'
        'artifact_version: "0.0.0"\n'
        'project: "unknown"\n'
        f'created: "{date}"\n'
        f'updated: "{date}"\n'
        "status: draft\n"
        "source_skill: 104-sg-end\n"
        f"scope: capability-{capability}\n"
        'owner: "unknown"\n'
        "confidence: medium\n"
        "risk_level: medium\n"
        "security_impact: unknown\n"
        "docs_impact: yes\n"
        "linked_systems: []\n"
        "depends_on: []\n"
        "supersedes: []\n"
        "evidence: []\n"
        'next_step: "none"\n'
        "---\n\n"
        f"# Capability: {capability}\n\n"
        "## Purpose\n\n"
        "[One paragraph: what this capability guarantees today.]\n\n"
        f"{REQUIREMENTS_HEADING}\n\n"
        f"{HISTORY_HEADING}\n\n" + "\n".join(HISTORY_HEADER) + "\n"
    )


def _cell(value: str) -> str:
    return " ".join(value.replace("|", "\\|").split())


def _history_rows(tail: list[str]) -> list[str]:
    structural = _structural(tail)
    inside, rows = False, []
    for index, line in enumerate(tail):
        if structural[index] and line.startswith("## "):
            inside = line.strip() == HISTORY_HEADING
        elif inside and line.lstrip().startswith("|"):
            rows.append(line)
    return rows


def _append_history(tail: list[str], rows: list[str]) -> list[str]:
    structural = _structural(tail)
    start = next(
        (i for i, line in enumerate(tail) if structural[i] and line.strip() == HISTORY_HEADING), None
    )
    if start is None:
        return _strip(tail + ["", HISTORY_HEADING, "", *HISTORY_HEADER, *rows])
    end = next(
        (i for i in range(start + 1, len(tail)) if structural[i] and tail[i].startswith("## ")), len(tail)
    )
    section = _strip_trailing(tail[start:end])
    if not any(line.lstrip().startswith("|") for line in section[1:]):
        section += ["", *HISTORY_HEADER]
    rest = tail[end:]
    return section + rows + ([""] + rest if rest else [])


def _bump_frontmatter(head: list[str], date: str) -> list[str]:
    if not head or head[0].strip() != "---":
        return head
    try:
        close = head.index("---", 1)
    except ValueError:
        return head
    bumped = list(head)
    for index in range(1, close):
        version = VERSION.match(bumped[index])
        if version:
            prefix, quote, major, minor, _, end_quote = version.groups()
            bumped[index] = f"{prefix}{quote}{major}.{int(minor) + 1}.0{end_quote}"
            continue
        updated = UPDATED.match(bumped[index])
        if updated:
            bumped[index] = f"{updated.group(1)}{updated.group(2)}{date}{updated.group(3)}"
    return bumped


def merge_capability(living_text: str, delta: CapabilityDelta, *, change: str, date: str) -> str:
    """Return the living spec text after applying one capability delta. Raises DeltaError."""
    document = parse_capability(living_text)
    label = f"capability '{delta.capability}'"
    errors = [f"{label}: living spec is invalid before merge: {error}" for error in validate_capability_text(living_text)]
    marker = f"| {_cell(change)} |"
    if any(marker in row for row in _history_rows(document.tail)):
        errors.append(f"{label}: change spec '{change}' is already merged (see Change History)")
    existing = {item.key: index for index, item in enumerate(document.requirements)}
    for item in delta.added:
        if item.key in existing:
            errors.append(f"{label}: ADDED requirement '{item.name}' already exists; use MODIFIED")
    for operation, items in (("MODIFIED", delta.modified), ("REMOVED", delta.removed)):
        for item in items:
            if item.key not in existing:
                errors.append(
                    f"{label}: {operation} requirement '{item.name}' not found in the living spec; "
                    "fix the name or use ADDED"
                )
    if errors:
        raise DeltaError(errors)
    requirements = list(document.requirements)
    for item in delta.modified:
        requirements[existing[item.key]] = item
    removed = {item.key for item in delta.removed}
    requirements = [item for item in requirements if item.key not in removed]
    requirements.extend(delta.added)
    rows = [
        f"| {date} | {_cell(change)} | {operation} | {_cell(item.name)} | "
        f"{_cell(item.reason) if operation == 'REMOVED' else ''} |"
        for operation, item in delta.operations()
    ]
    merged = CapabilityDocument(
        head=_bump_frontmatter(document.head, date),
        preamble=document.preamble,
        requirements=requirements,
        tail=_append_history(document.tail, rows),
    )
    return render_capability(merged)


def merge_change_spec(
    spec_path: Path,
    capabilities_dir: Path | None = None,
    *,
    date: str,
    check: bool = False,
    create: bool = False,
) -> MergeResult:
    """Merge every capability delta of ``spec_path``. All-or-nothing; raises DeltaError."""
    spec_path = Path(spec_path)
    if not DATE.match(date):
        raise DeltaError([f"date '{date}' must be YYYY-MM-DD"])
    capabilities_dir = Path(capabilities_dir) if capabilities_dir else spec_path.parent / "capabilities"
    deltas = parse_change_spec(spec_path.read_text(encoding="utf-8"))
    errors: list[str] = []
    planned: list[tuple[Path, str]] = []
    operations: list[tuple[str, str, str]] = []
    for delta in deltas:
        target = capabilities_dir / f"{delta.capability}.md"
        if target.is_file():
            living_text = target.read_text(encoding="utf-8")
        elif delta.modified or delta.removed:
            names = ", ".join(f"'{item.name}'" for item in delta.modified + delta.removed)
            errors.append(
                f"capability '{delta.capability}': living spec {target.name} does not exist, so MODIFIED/REMOVED "
                f"requirement(s) {names} cannot match; only ADDED can create a capability"
            )
            continue
        elif not create:
            errors.append(
                f"capability '{delta.capability}': living spec {target.name} does not exist; "
                "rerun with --create to create it from this ADDED delta"
            )
            continue
        else:
            living_text = new_capability_text(delta.capability, date)
        try:
            planned.append((target, merge_capability(living_text, delta, change=spec_path.stem, date=date)))
        except DeltaError as error:
            errors.extend(error.errors)
            continue
        operations.extend((delta.capability, operation, item.name) for operation, item in delta.operations())
    if errors:
        raise DeltaError(errors)
    written: list[Path] = []
    if not check:
        for target, text in planned:
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(text, encoding="utf-8", newline="\n")
            written.append(target)
    return MergeResult(operations=operations, written=written)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("paths", nargs="+", type=Path, help="change spec, or capability specs with --validate")
    parser.add_argument("--validate", action="store_true", help="validate living capability specs; merge nothing")
    parser.add_argument("--check", action="store_true", help="validate the merge without writing")
    parser.add_argument("--create", action="store_true", help="allow an ADDED delta to create a new capability spec")
    parser.add_argument("--capabilities-dir", type=Path, help="default: <change spec dir>/capabilities")
    parser.add_argument("--date", help="merge date YYYY-MM-DD (default: today, UTC)")
    args = parser.parse_args(argv)
    if args.validate:
        failed = False
        for path in args.paths:
            if not path.is_file():
                print(f"REFUSED {path}: file not found", file=sys.stderr)
                failed = True
                continue
            errors = validate_capability_text(path.read_text(encoding="utf-8"))
            failed = failed or bool(errors)
            for error in errors:
                print(f"REFUSED {path}: {error}", file=sys.stderr)
            if not errors:
                count = len(parse_capability(path.read_text(encoding="utf-8")).requirements)
                print(f"valid {path}: {count} requirement(s)")
        return 1 if failed else 0
    if len(args.paths) != 1:
        parser.error("merge takes exactly one change spec")
    spec = args.paths[0]
    if not spec.is_file():
        print(f"REFUSED: change spec not found: {spec}", file=sys.stderr)
        return 1
    date = args.date or datetime.now(timezone.utc).strftime("%Y-%m-%d")
    try:
        result = merge_change_spec(spec, args.capabilities_dir, date=date, check=args.check, create=args.create)
    except DeltaError as error:
        for line in error.errors:
            print(f"REFUSED: {line}", file=sys.stderr)
        print("Nothing was written.", file=sys.stderr)
        return 1
    if not result.operations:
        print("no capability delta: nothing to merge")
        return 0
    verb = "would apply" if args.check else "applied"
    for capability, operation, name in result.operations:
        print(f"{verb} {operation} {capability}: {name}")
    for path in result.written:
        print(f"wrote {path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
