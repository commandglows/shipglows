#!/usr/bin/env python3
"""Audit root PITCH.md presence, navigation, and freshness."""

from __future__ import annotations

import argparse
import json
import re
from dataclasses import asdict, dataclass
from datetime import date
from pathlib import Path


REVIEWED_RE = re.compile(r"^>\s*Pitch reviewed:\s*(\d{4}-\d{2}-\d{2})\b", re.MULTILINE)
UPDATED_RE = re.compile(r'^updated:\s*["\']?(\d{4}-\d{2}-\d{2})["\']?\s*$', re.MULTILINE)


@dataclass(frozen=True)
class PitchAudit:
    project: str
    root: str
    status: str
    pitch: str | None
    reviewed: str | None
    latest_source_update: str | None
    issues: tuple[str, ...]


def _source_paths(root: Path) -> list[Path]:
    candidates = [
        root / "shipglows_data" / "business" / "business.md",
        root / "shipglows_data" / "business" / "product.md",
        root / "README.md",
    ]
    return [path for path in candidates if path.is_file()]


def _latest_declared_update(paths: list[Path]) -> date | None:
    updates: list[date] = []
    for path in paths:
        if path.name == "README.md":
            continue
        match = UPDATED_RE.search(path.read_text(encoding="utf-8", errors="replace"))
        if match:
            updates.append(date.fromisoformat(match.group(1)))
    return max(updates) if updates else None


def audit_project(root: Path) -> PitchAudit:
    root = root.resolve()
    pitch_path = root / "PITCH.md"
    if not pitch_path.is_file():
        return PitchAudit(
            project=root.name,
            root=str(root),
            status="missing",
            pitch=None,
            reviewed=None,
            latest_source_update=None,
            issues=("root PITCH.md is missing",),
        )

    body = pitch_path.read_text(encoding="utf-8", errors="replace")
    issues: list[str] = []
    reviewed_match = REVIEWED_RE.search(body)
    reviewed = date.fromisoformat(reviewed_match.group(1)) if reviewed_match else None
    if reviewed is None:
        issues.append("Pitch reviewed marker is missing")
    if "## Current state" not in body:
        issues.append("Current state section is missing")
    if "## Navigate" not in body:
        issues.append("Navigate section is missing")

    sources = _source_paths(root)
    latest = _latest_declared_update(sources)
    if reviewed is not None and latest is not None and reviewed < latest:
        issues.append("pitch predates canonical business or product truth")

    if not sources:
        issues.append("no canonical business, product, or README source found")

    if any(issue.startswith("pitch predates") for issue in issues):
        status = "stale"
    elif issues:
        status = "review_required"
    else:
        status = "current"

    return PitchAudit(
        project=root.name,
        root=str(root),
        status=status,
        pitch=str(pitch_path),
        reviewed=reviewed.isoformat() if reviewed else None,
        latest_source_update=latest.isoformat() if latest else None,
        issues=tuple(issues),
    )


def discover_projects(portfolio_root: Path) -> list[Path]:
    return sorted(
        (path for path in portfolio_root.iterdir() if path.is_dir() and (path / ".git").exists()),
        key=lambda path: path.name.casefold(),
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("roots", nargs="*", type=Path, help="Project roots to audit")
    parser.add_argument("--portfolio-root", type=Path, help="Discover direct child Git projects")
    parser.add_argument("--json", action="store_true", help="Emit JSON")
    args = parser.parse_args()

    roots = list(args.roots)
    if args.portfolio_root:
        roots.extend(discover_projects(args.portfolio_root.resolve()))
    unique_roots = list(dict.fromkeys(path.resolve() for path in roots))
    if not unique_roots:
        parser.error("provide a project root or --portfolio-root")

    results = [audit_project(root) for root in unique_roots]
    if args.json:
        print(json.dumps([asdict(result) for result in results], indent=2, ensure_ascii=False))
    else:
        for result in results:
            detail = "; ".join(result.issues) if result.issues else "OK"
            print(f"{result.status}\t{result.project}\t{detail}")
    return 1 if any(result.status != "current" for result in results) else 0


if __name__ == "__main__":
    raise SystemExit(main())
