#!/usr/bin/env python3
"""Find ShipGlows skill Markdown that no live surface references.

Read-only discovery for the dead-code and obsolescence audit. A candidate is any
Markdown file under ``skills/`` except skill entrypoints (``SKILL.md`` and a
skill-root ``README.md``). Mentions are matched conservatively by basename, by
hyphenated/underscored stem, so a collision keeps every same-named candidate
alive. Findings are removal candidates, never deletion proof.

Classes:
- ``orphan``: no inbound mention from any other file;
- ``weak``: mentioned only by tests or history (logs, changelogs, archives);
- ``unreachable``: mentioned only by other unreachable or orphan candidates.

A candidate whose frontmatter declares ``orphan_policy: retain`` (with an
``orphan_reason``) passed value triage as intentionally unloaded evidence; it
is counted as ``retained`` and kept out of findings.
"""

from __future__ import annotations

import argparse
from collections import defaultdict
from dataclasses import dataclass, field
import json
import os
from pathlib import Path
import re
import subprocess
from typing import Iterable


ROOT = Path(__file__).resolve().parents[1]
TEXT_SUFFIXES = {
    ".md", ".json", ".py", ".sh", ".ps1", ".psm1", ".psd1", ".yml", ".yaml",
    ".toml", ".txt", ".js", ".mjs", ".cjs", ".ts", ".tsx", ".dart", ".cfg",
}
SKIPPED_DIRS = {".git", "node_modules", "__pycache__", ".venv", "venv", "build", "dist", ".dart_tool"}
HISTORY_NAMES = {"REFRESH_LOG.md", "CHANGELOG.md"}
MAX_BYTES = 2_000_000
TOKEN = re.compile(r"[A-Za-z0-9_][A-Za-z0-9_.-]*")
RETAIN = re.compile(r"^orphan_policy:\s*[\"']?retain[\"']?\s*$", re.MULTILINE)


@dataclass
class Finding:
    path: str
    classification: str
    inbound: list[str] = field(default_factory=list)


def _tracked_files(root: Path) -> list[str] | None:
    try:
        result = subprocess.run(
            ["git", "-C", str(root), "ls-files", "-z"],
            capture_output=True, check=True,
        )
    except (OSError, subprocess.CalledProcessError):
        return None
    return [item for item in result.stdout.decode("utf-8").split("\0") if item]


def _iter_text_files(root: Path) -> Iterable[Path]:
    """Yield tracked text files (git index), falling back to a pruned walk."""
    tracked = _tracked_files(root)
    if tracked is None:
        tracked = []
        for directory, dirnames, filenames in os.walk(root):
            dirnames[:] = [name for name in dirnames if name not in SKIPPED_DIRS]
            base = Path(directory).relative_to(root)
            tracked.extend((base / name).as_posix() for name in filenames)
    for relative in tracked:
        path = root / relative
        if path.suffix.lower() not in TEXT_SUFFIXES or not path.is_file():
            continue
        if any(part in SKIPPED_DIRS for part in Path(relative).parts):
            continue
        if path.stat().st_size > MAX_BYTES:
            continue
        yield path


def source_kind(relative: str) -> str:
    """Classify a referencing file as live, test, or history evidence."""
    parts = relative.split("/")
    name = parts[-1]
    if name in HISTORY_NAMES or "archives" in parts:
        return "history"
    if parts[0] == "tests" or (parts[0] == "tools" and (name.startswith("test_") or "fixtures" in parts)):
        return "test"
    return "live"


def is_candidate(relative: str) -> bool:
    parts = relative.split("/")
    if parts[0] != "skills" or not relative.endswith(".md") or "archives" in parts:
        return False
    if parts[-1] == "SKILL.md":
        return False
    # skills/<skill>/README.md and skills/README.md are entrypoints.
    if parts[-1] == "README.md" and len(parts) <= 3:
        return False
    return parts[-1] not in HISTORY_NAMES


def is_retained(text: str) -> bool:
    """Return whether frontmatter records a triaged ``retain`` decision."""
    text = text.replace("\r\n", "\n")
    if not text.startswith("---\n"):
        return False
    end = text.find("\n---\n", 4)
    return end > 0 and bool(RETAIN.search(text[4:end]))


def _stem_key(name: str) -> str | None:
    stem = name[:-3]
    return stem if ("-" in stem or "_" in stem) and len(stem) >= 8 else None


def audit_orphans(root: Path = ROOT) -> dict[str, object]:
    root = root.resolve()
    files = {path.relative_to(root).as_posix(): path for path in _iter_text_files(root)}
    candidates = sorted(rel for rel in files if is_candidate(rel))
    by_key: dict[str, set[str]] = defaultdict(set)
    for rel in candidates:
        name = rel.rsplit("/", 1)[-1]
        by_key[name].add(rel)
        if stem := _stem_key(name):
            by_key[stem].add(rel)

    retained: set[str] = set()
    inbound: dict[str, set[str]] = defaultdict(set)
    outbound: dict[str, set[str]] = defaultdict(set)
    for rel, path in files.items():
        try:
            text = path.read_text(encoding="utf-8")
        except (UnicodeDecodeError, OSError):
            continue
        if rel in by_key.get(rel.rsplit("/", 1)[-1], ()) and is_retained(text):
            retained.add(rel)
        for token in set(TOKEN.findall(text)) & by_key.keys():
            for target in by_key[token]:
                if target != rel:
                    inbound[target].add(rel)
                    outbound[rel].add(target)

    candidate_set = set(candidates)
    reachable: set[str] = set()
    pending = [
        target
        for rel in files
        if rel not in candidate_set and source_kind(rel) == "live"
        for target in outbound.get(rel, ())
    ]
    while pending:
        node = pending.pop()
        if node in reachable:
            continue
        reachable.add(node)
        pending.extend(outbound.get(node, ()))

    findings: list[Finding] = []
    for rel in candidates:
        if rel in reachable or rel in retained:
            continue
        sources = sorted(inbound.get(rel, ()))
        if not sources:
            classification = "orphan"
        elif all(source_kind(src) != "live" for src in sources):
            classification = "weak"
        else:
            classification = "unreachable"
        findings.append(Finding(rel, classification, sources))

    counts = {name: sum(f.classification == name for f in findings) for name in ("orphan", "weak", "unreachable")}
    return {
        "status": "clean" if not findings else "candidates",
        "candidates_scanned": len(candidates),
        "retained": sorted(retained - reachable),
        "counts": counts,
        "findings": [f.__dict__ for f in findings],
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--root", type=Path, default=ROOT)
    parser.add_argument("--format", choices=("text", "json", "paths"), default="text")
    parser.add_argument(
        "--class", dest="classes", action="append", choices=("orphan", "weak", "unreachable"),
        help="Restrict output to one or more classes (repeatable).",
    )
    parser.add_argument("--strict", action="store_true", help="Exit 2 when any candidate is reported.")
    args = parser.parse_args()
    payload = audit_orphans(args.root)
    if args.classes:
        payload["findings"] = [f for f in payload["findings"] if f["classification"] in args.classes]
    if args.format == "json":
        print(json.dumps(payload, ensure_ascii=False, sort_keys=True, indent=2))
    elif args.format == "paths":
        for finding in payload["findings"]:
            print(finding["path"])
    else:
        counts = payload["counts"]
        print(
            f"Orphan reference audit: {payload['status']} · scanned={payload['candidates_scanned']} "
            f"orphan={counts['orphan']} weak={counts['weak']} unreachable={counts['unreachable']} "
            f"retained={len(payload['retained'])}"
        )
        for finding in payload["findings"]:
            via = f" <- {', '.join(finding['inbound'][:3])}" if finding["inbound"] else ""
            print(f"- [{finding['classification']}] {finding['path']}{via}")
    return 2 if args.strict and payload["findings"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
