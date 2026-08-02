#!/usr/bin/env python3
"""Inventory central ~/shipglows_data repository for retirement-only workflows."""

from __future__ import annotations

import argparse
import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any
import os
import subprocess


ROOT = Path("/home/claude/shipglows_data")
SHARE_ROOT = Path("/home/claude/shipglows/shipglows_data")
ARCHIVE_ROOT = Path("/home/claude/shipglows/shipglows_data/workflow/archives/central-shipglows-data-retirement")
MAX_HASH_BYTES = 10 * 1024 * 1024




ROOT_TO_SHIPGLOWS = {
    "AGENT.md": "AGENT.md",
    "ARCHITECTURE.md": "technical/architecture.md",
    "AUDIT_LOG.md": "workflow/AUDIT_LOG.md",
    "BRANDING.md": "business/branding.md",
    "BUSINESS.md": "business/business.md",
    "CLAUDE.md": "CLAUDE.md",
    "CONTENT_MAP.md": "editorial/content-map.md",
    "CONTEXT-FUNCTION-TREE.md": "technical/context-function-tree.md",
    "CONTEXT.md": "technical/context.md",
    "DEPENDENCY_LOG.md": "workflow/DEPENDENCY_LOG.md",
    "GTM.md": "business/gtm.md",
    "GUIDELINES.md": "technical/guidelines.md",
    "OPERATIONS_LOG.md": "workflow/OPERATIONS_LOG.md",
    "PRODUCT.md": "business/product.md",
    "PROJECTS.md": "workflow/PROJECTS.md",
    "README.md": "README.md",
    "TASKS.md": "workflow/TASKS.md",
    "concurrent.md": "workflow/research/concurrent.md",
    "migrations/shipglows_data_metadata_inventory.md": "workflow/archives/central-shipglows-data-retirement/shipglows_data_metadata_inventory.md",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--json-output",
        type=Path,
        default=Path("/home/claude/shipglows/shipglows_data/workflow/archives/central-shipglows-data-retirement/inventory.json"),
        help="Output JSON file.",
    )
    parser.add_argument(
        "--md-output",
        type=Path,
        default=Path("/home/claude/shipglows/shipglows_data/workflow/archives/central-shipglows-data-retirement/inventory.md"),
        help="Output markdown file.",
    )
    parser.add_argument(
        "--root",
        type=Path,
        default=ROOT,
        help="Central repository root to scan.",
    )
    parser.add_argument(
        "--max-hash-bytes",
        type=int,
        default=MAX_HASH_BYTES,
        help="Maximum file size to hash, in bytes.",
    )
    parser.add_argument(
        "--skip-git",
        action="store_true",
        help="Skip git status lookup for speed.",
    )
    return parser.parse_args()


def load_git_status(root: Path) -> dict[str, str]:
    try:
        output = subprocess.run(
            ["git", "-C", str(root), "status", "--short"],
            check=True,
            capture_output=True,
            text=True,
        ).stdout
    except Exception:
        return {}

    status_by_path: dict[str, str] = {}
    for line in output.splitlines():
        if len(line) < 4:
            continue
        status = line[:2]
        path = line[3:]
        status_by_path[path] = status.strip() or "??"
    return status_by_path


def canonical_owners_in_home() -> list[Path]:
    home = Path.home()
    paths = []
    for p in sorted(home.iterdir()):
        if p.is_dir() and p.name != "shipglows_data":
            paths.append(p)
    return paths


def resolve_project_root(project_name: str, candidates: list[Path]) -> Path | None:
    direct = Path("/home/claude") / project_name
    if direct.exists() and direct.is_dir():
        return direct

    lower = project_name.lower()
    for candidate in candidates:
        if candidate.name.lower() == lower:
        # Prefer closest match to avoid unrelated nested names.
            return candidate
    return None


def sha256_file(path: Path, max_size: int) -> str | None:
    try:
        size = path.stat().st_size
    except OSError:
        return None
    if size > max_size:
        return None
    h = hashlib.sha256()
    try:
        with path.open("rb") as handle:
            while True:
                block = handle.read(1024 * 1024)
                if not block:
                    break
                h.update(block)
    except OSError:
        return None
    return h.hexdigest()


def file_info(path: Path, root: Path, git_status: dict[str, str], max_hash_bytes: int) -> dict[str, Any]:
    try:
        stat = path.lstat()
    except OSError:
        return {
            "path": str(path.relative_to(root)),
            "type": "missing",
            "size": None,
            "mtime_utc": None,
            "sha256": None,
            "git_status": "missing",
            "likely_owner": "unknown",
            "candidate_destination": None,
            "classification": "conflict",
            "classification_reason": "Path could not be stat()'ed.",
        }

    rel = path.relative_to(root)
    rel_str = str(rel)
    relative_path = rel.parts

    is_symlink = path.is_symlink()
    if path.is_dir() and not is_symlink:
        item_type = "dir"
    elif is_symlink:
        item_type = "symlink"
    else:
        item_type = "file"

    git_state = git_status.get(rel_str, "clean")
    mtime = datetime.fromtimestamp(stat.st_mtime, tz=timezone.utc).isoformat(timespec="seconds")

    sha256 = None
    if item_type == "file" and not is_symlink and stat.st_size <= max_hash_bytes:
        sha256 = sha256_file(path, max_hash_bytes)

    owner, destination, classification, reason = classify_entry(path, rel, git_state, stat.st_size)
    if git_state and git_state != "clean":
        classification = "conflict" if classification == "delete-safe" else classification
        if "dirty" not in reason.lower():
            reason = "dirty git path -> conflict"

    return {
        "path": rel_str,
        "type": item_type,
        "size": stat.st_size,
        "mtime_utc": mtime,
        "sha256": sha256,
        "git_status": git_state,
        "likely_owner": owner,
        "candidate_destination": destination,
        "classification": classification,
        "classification_reason": reason,
    }

def classify_entry(path: Path, rel: Path, git_state: str, size: int) -> tuple[str, str | None, str, str]:
    name = rel.name
    if rel.parts[:1] == (".git",):
        return "shipglows-system", "preserve via git bundle", "archive-history", "central VCS metadata should remain in bundle"

    if len(rel.parts) >= 2 and rel.parts[0] == "projects":
        project = rel.parts[1]
        candidates = canonical_owners_in_home()
        project_root = resolve_project_root(project, candidates)
        if project_root is None:
            destination = f"/home/claude/{project}/(unresolved)"
            return "project-unknown", destination, "conflict", "project has no local shipglows workspace match"

        if not project_root.joinpath("shipglows_data").exists():
            destination = str(project_root / "shipglows_data" / "workflow" / "/".join(rel.parts[2:]))
            return (
                "project-local",
                destination,
                "migrate-project",
                "project folder exists but has no shipglows_data corpus yet",
            )

        destination = str(project_root / "shipglows_data" / "workflow" / "/".join(rel.parts[2:]))
        return (
            "project-local",
            destination,
            "migrate-project",
            "owned by matching project workspace under /home/claude",
        )

    if git_state != "clean":
        return (
            "shipglows",
            str(ARCHIVE_ROOT / rel.as_posix()),
            "conflict",
            f"dirty git state ({git_state})",
        )

    target = ROOT_TO_SHIPGLOWS.get(str(rel))
    if target:
        dest = str(SHARE_ROOT / target)
        return (
            "shipglows",
            dest,
            "migrate-shipglows",
            "root central artifact likely belongs to ShipGlows governance corpus",
        )

    if name.lower() in {"readme.md", "concurrent.md", "suite-authentication-support-runbook.md"}:
        return (
            "shipglows",
            str(ARCHIVE_ROOT),
            "archive-history",
            "legacy supporting material or helper doc",
        )

    if size > 200 * 1024 * 1024:
        return (
            "shipglows",
            str(ARCHIVE_ROOT),
            "archive-history",
            "large/utility artifact; preserve in history",
        )

    return (
        "shipglows",
        str(ARCHIVE_ROOT),
        "archive-history",
        "not mapped by migration heuristics",
    )


def walk_tree(root: Path, git_status: dict[str, str], max_hash_bytes: int) -> list[dict[str, Any]]:
    entries: list[dict[str, Any]] = []
    git_dir = root / ".git"
    if git_dir.exists():
        entries.append(file_info(git_dir, root, git_status, max_hash_bytes))
    # Exclude .git contents from expansion; keep the directory itself for inventory signal.
    for current_dir, dirnames, filenames in os.walk(root, followlinks=False, topdown=True):
        cur = Path(current_dir)
        dirnames[:] = [d for d in dirnames if d != ".git"]

        for dirname in sorted(dirnames):
            p = cur / dirname
            entries.append(file_info(p, root, git_status, max_hash_bytes))
        for filename in sorted(filenames):
            p = cur / filename
            entries.append(file_info(p, root, git_status, max_hash_bytes))

    root_entry = file_info(root, root, git_status, max_hash_bytes)
    entries.append(root_entry)
    return entries


def write_json(output: Path, payload: dict[str, Any]) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open("w", encoding="utf-8") as handle:
        json.dump(payload, handle, indent=2, sort_keys=True)


def write_md(output: Path, entries: list[dict[str, Any]]) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    total = len(entries)
    conflict = sum(1 for item in entries if item["classification"] == "conflict")
    classify_counts: dict[str, int] = {}
    for item in entries:
        classify_counts[item["classification"]] = classify_counts.get(item["classification"], 0) + 1

    lines = [
        "# central shipglows_data retirement inventory",
        "",
        f"- Generated at: {datetime.now(timezone.utc).isoformat(timespec='seconds')} UTC",
        f"- Scan root: {ROOT}",
        f"- Total entries: {total}",
        f"- Conflicts: {conflict}",
        "",
        "## Classification summary",
        "",
    ]
    for key in sorted(classify_counts):
        lines.append(f"- {key}: {classify_counts[key]}")

    lines.extend(["", "## Inventory", "", "| path | type | size | mtime_utc | sha256 | git_status | likely_owner | classification | candidate_destination | reason |", "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |"])

    for item in sorted(entries, key=lambda x: x["path"]):
        path = item["path"]
        sha = item["sha256"] or ""
        lines.append(
            "| "
            + " | ".join(
                [
                    path,
                    str(item["type"]),
                    str(item["size"]),
                    str(item["mtime_utc"]),
                    str(sha),
                    str(item["git_status"]),
                    str(item["likely_owner"]),
                    str(item["classification"]),
                    str(item["candidate_destination"]),
                    str(item["classification_reason"]).replace("|", "/"),
                ]
            )
            + " |"
        )
    output.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    args = parse_args()
    root = args.root.expanduser().resolve()
    if not root.exists() or not root.is_dir():
        raise SystemExit(f"invalid scan root: {root}")
    git_status = {} if args.skip_git else load_git_status(root)
    entries = walk_tree(root, git_status, args.max_hash_bytes)
    entries.sort(key=lambda item: item["path"])

    payload = {
        "scan_root": str(root),
        "generated_at_utc": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "root_is_git_repo": bool(git_status),
        "entries": entries,
        "validation": {
            "entries_total": len(entries),
            "entries_classified": sum(1 for item in entries if item["classification"] in {"duplicate", "migrate-project", "migrate-shipglows", "archive-history", "conflict", "delete-safe"}),
        },
    }

    write_json(args.json_output, payload)
    write_md(args.md_output, entries)
    print(f"Wrote {args.json_output}")
    print(f"Wrote {args.md_output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
