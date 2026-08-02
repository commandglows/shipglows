#!/usr/bin/env python3
"""Read-only audit of a project's ShipGlows governance topology."""

from __future__ import annotations

import argparse
import json
from dataclasses import asdict, dataclass
from pathlib import Path


CANONICAL_DIR = "shipglows_data"
LEGACY_DIR = "shipglows_data"
LEGACY_ROOT_FILES = {
    "AFFILIATES.md",
    "ARCHITECTURE.md",
    "AUDIT_LOG.md",
    "BRANDING.md",
    "BUSINESS.md",
    "BUGS.md",
    "CONTENT_MAP.md",
    "CONTEXT-FUNCTION-TREE.md",
    "CONTEXT.md",
    "GTM.md",
    "GUIDELINES.md",
    "INSPIRATION.md",
    "PRODUCT.md",
    "TASKS.md",
    "TEST_LOG.md",
}
LEGACY_ROOT_DIRS = {
    "archive",
    "bugs",
    "docs",
    "research",
    "specs",
}
GENERATED_ROOT_NAMES = {
    ".astro",
    ".playwright-mcp",
    ".vercel",
    "build",
    "dist",
    "dist-site",
    "node_modules",
    "test-results",
}
SKIP_DIR_NAMES = GENERATED_ROOT_NAMES | {".git", "__pycache__"}


@dataclass(frozen=True)
class TopologyReport:
    root: str
    status: str
    canonical_present: bool
    migration_sources: list[str]
    review_items: list[str]
    standalone_exceptions: list[str]
    hygiene_signals: list[str]


def relative(path: Path, root: Path) -> str:
    return path.relative_to(root).as_posix()


def is_nested_standalone(path: Path, root: Path) -> bool:
    """Return true when path belongs to a Git worktree below the target root."""
    current = path.parent
    while current != root and root in current.parents:
        if (current / ".git").exists():
            return True
        current = current.parent
    return False


def governance_dirs(root: Path) -> list[Path]:
    found: list[Path] = []
    pending = [root]
    while pending:
        current = pending.pop()
        try:
            children = sorted(current.iterdir(), reverse=True)
        except OSError:
            continue
        for child in children:
            if not child.is_dir() or child.is_symlink():
                continue
            if child.name in SKIP_DIR_NAMES:
                continue
            if child.name in {CANONICAL_DIR, LEGACY_DIR}:
                found.append(child)
                continue
            pending.append(child)
    return sorted(found)


def audit(root: Path) -> TopologyReport:
    root = root.expanduser().resolve()
    if not root.is_dir():
        raise ValueError(f"project root is not a readable directory: {root}")

    migration: list[str] = []
    review: list[str] = []
    standalone: list[str] = []
    hygiene: list[str] = []

    canonical_root = root / CANONICAL_DIR
    canonical_present = canonical_root.is_dir()

    for path in governance_dirs(root):
        rel = relative(path, root)
        if path == canonical_root:
            continue
        if path.name == CANONICAL_DIR and is_nested_standalone(path, root):
            standalone.append(rel)
        else:
            migration.append(rel)

    migration.extend(
        path.name for path in sorted(root.iterdir()) if path.is_file() and path.name in LEGACY_ROOT_FILES
    )
    migration.extend(
        path.name for path in sorted(root.iterdir()) if path.is_dir() and path.name in LEGACY_ROOT_DIRS
    )

    agents = root / "AGENTS.md"
    if agents.exists() or agents.is_symlink():
        if not agents.is_symlink():
            migration.append("AGENTS.md (must be a symlink to AGENT.md)")
        elif agents.readlink() != Path("AGENT.md"):
            migration.append(f"AGENTS.md (points to {agents.readlink()}, expected AGENT.md)")

    for name in sorted(GENERATED_ROOT_NAMES):
        if (root / name).exists():
            hygiene.append(name)

    if not canonical_present:
        review.append(f"{CANONICAL_DIR}/ missing at project root")

    migration = sorted(set(migration))
    review = sorted(set(review))
    standalone = sorted(set(standalone))
    if migration:
        status = "migration-required"
    elif review:
        status = "review-required"
    else:
        status = "compliant"

    return TopologyReport(
        root=str(root),
        status=status,
        canonical_present=canonical_present,
        migration_sources=migration,
        review_items=review,
        standalone_exceptions=standalone,
        hygiene_signals=hygiene,
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root", nargs="?", default=".", type=Path, help="Project root to audit.")
    parser.add_argument("--json", action="store_true", help="Emit a JSON report.")
    return parser.parse_args()


def print_human(report: TopologyReport) -> None:
    print(f"Governance topology: {report.status}")
    print(f"Root: {report.root}")
    print(f"Canonical corpus: {'present' if report.canonical_present else 'missing'}")
    for label, items in (
        ("Migration sources", report.migration_sources),
        ("Review items", report.review_items),
        ("Standalone exceptions", report.standalone_exceptions),
        ("Hygiene signals", report.hygiene_signals),
    ):
        if items:
            print(f"{label}:")
            for item in items:
                print(f"- {item}")


def main() -> int:
    args = parse_args()
    try:
        report = audit(args.root)
    except ValueError as exc:
        print(f"Governance topology audit failed: {exc}")
        return 2

    if args.json:
        print(json.dumps(asdict(report), indent=2, sort_keys=True))
    else:
        print_human(report)

    return {"compliant": 0, "migration-required": 1, "review-required": 2}[report.status]


if __name__ == "__main__":
    raise SystemExit(main())
