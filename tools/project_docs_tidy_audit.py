#!/usr/bin/env python3
"""Inventory accumulated project workflow documentation for the sg-docs tidy mode.

Read-only. Scans ``shipglows_data/workflow/`` of a project and classifies each
work artifact (specs, audits, reviews, research, explorations, conversations,
evidence, bugs, checklist instances, legacy archive trees) so an operator can
approve what to keep, reconnect, merge, or delete. Git history is the only
archive: tidy distills durable content into canonical docs, then deletes.
Durable assets (templates, playbooks, checklists) are out of scope. Trackers are
reported with their open and done row counts.

Classes:
- ``open``: referenced by an open tracker row (todo, in progress, blocked);
- ``delivered``: closure evidence (``delivery: closed`` frontmatter, a done
  tracker row, or a closed/shipped closure row in its run history);
- ``retired``: frontmatter status ``superseded`` or ``stale``;
- ``dormant``: none of the above and untouched for ``--dormant-days``;
- ``recent``: everything else;
- ``archived``: anything under a legacy ``archives/`` tree (git already keeps it);
- ``untracked``: not in the git index, so deleting it would be unrecoverable;
  never removable until committed or explicitly discarded by the operator.

Operational trigger (``--check``): tidy is due when the removable backlog
(delivered + retired + dormant + archived) reaches ``--max-candidates`` files, when it
outweighs live work (open + recent) in bytes, or when trackers hold
``--max-done-rows`` done rows. Deleting resets these signals by itself, so
the check needs no stored state and fires on activity rather than elapsed time.
"""

from __future__ import annotations

import argparse
from collections import defaultdict
from datetime import date, timedelta
import json
from pathlib import Path
import re
import subprocess


WORKFLOW = Path("shipglows_data/workflow")
WORK_DIRS = (
    "specs", "audits", "reviews", "research", "explorations", "conversations",
    "conversation-audits", "evidence", "bugs", "checklist-instances", "history",
    "repurpose-packs", "email", "archives",
)
REMOVABLE = ("delivered", "retired", "dormant", "archived")
LIVE = ("open", "recent")
TRACKERS = (
    "TASKS.md", "BACKLOG.md", "BUGS.md", "TEST_LOG.md", "AUDIT_LOG.md",
    "OPERATIONS_LOG.md", "DEPENDENCY_LOG.md",
)
OPEN_MARK = re.compile(r"📋|🔄|⛔|status:\s*(todo|in_progress|in progress|blocked)", re.IGNORECASE)
DONE_MARK = re.compile(r"✅|status:\s*(done|closed|shipped)", re.IGNORECASE)
CLOSURE_ROW = re.compile(
    r"^\|[^|\n]*\|\s*(?:104-sg-end|005-sg-ship|sg-release|sg-end)[^|\n]*\|(?:[^|\n]*\|){1,3}\s*(closed|shipped)\b",
    re.IGNORECASE | re.MULTILINE,
)
UPDATED = re.compile(r"^updated:\s*[\"']?(\d{4}-\d{2}-\d{2})", re.MULTILINE)
FRONT_FIELD = re.compile(r"^(status|delivery):\s*[\"']?([A-Za-z_-]+)[\"']?\s*$", re.MULTILINE)


def _frontmatter(text: str) -> str:
    text = text.replace("\r\n", "\n")
    if not text.startswith("---\n"):
        return ""
    end = text.find("\n---\n", 4)
    return "" if end < 0 else text[4:end]


def _last_touch(root: Path, scope: Path) -> dict[str, date]:
    """Map repo-relative path -> last commit date in one git pass."""
    try:
        output = subprocess.run(
            ["git", "-C", str(root), "log", "--format=@%cs", "--name-only", "--", str(scope)],
            capture_output=True, check=True,
        ).stdout.decode("utf-8", "replace")
    except (OSError, subprocess.CalledProcessError):
        return {}
    touched: dict[str, date] = {}
    current: date | None = None
    for line in output.splitlines():
        if line.startswith("@"):
            current = date.fromisoformat(line[1:])
        elif line and current and line not in touched:
            touched[line] = current
    return touched


def _tracked(root: Path, scope: Path) -> set[str] | None:
    try:
        output = subprocess.run(
            ["git", "-C", str(root), "ls-files", "-z", "--", str(scope)],
            capture_output=True, check=True,
        ).stdout.decode("utf-8", "replace")
    except (OSError, subprocess.CalledProcessError):
        return None
    return {item for item in output.split("\0") if item}


def _tracker_rows(root: Path) -> tuple[list[str], dict[str, dict[str, int]]]:
    rows: list[str] = []
    stats: dict[str, dict[str, int]] = {}
    for name in TRACKERS:
        path = root / WORKFLOW / name
        if not path.is_file():
            continue
        lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
        open_rows = sum(bool(OPEN_MARK.search(line)) for line in lines)
        done_rows = sum(bool(DONE_MARK.search(line)) and not OPEN_MARK.search(line) for line in lines)
        stats[name] = {"lines": len(lines), "bytes": path.stat().st_size, "open_rows": open_rows, "done_rows": done_rows}
        rows.extend(lines)
    return rows, stats


def classify(text: str, mentions_open: bool, mentions_done: bool, last: date | None, today: date, dormant_days: int) -> str:
    fields = dict(FRONT_FIELD.findall(_frontmatter(text)))
    if mentions_open:
        return "open"
    if fields.get("delivery") == "closed" or mentions_done or CLOSURE_ROW.search(text):
        return "delivered"
    if fields.get("status") in {"superseded", "stale"}:
        return "retired"
    if last and today - last > timedelta(days=dormant_days):
        return "dormant"
    return "recent"


def audit_project(root: Path, dormant_days: int = 90, today: date | None = None) -> dict[str, object]:
    root = root.resolve()
    today = today or date.today()
    workflow = root / WORKFLOW
    if not workflow.is_dir():
        return {"status": "no-workflow", "root": str(root), "items": [], "totals": {}, "trackers": {}}
    touched = _last_touch(root, WORKFLOW)
    tracked = _tracked(root, WORKFLOW)
    rows, tracker_stats = _tracker_rows(root)
    items = []
    for directory in WORK_DIRS:
        base = workflow / directory
        if not base.is_dir():
            continue
        for path in sorted(base.rglob("*")):
            if not path.is_file():
                continue
            rel = path.relative_to(root).as_posix()
            text = path.read_text(encoding="utf-8", errors="replace") if path.suffix == ".md" else ""
            needles = {path.name, path.stem} if len(path.stem) >= 8 else {rel}
            # Frontmatter ``updated`` tracks content changes; bulk metadata
            # commits would otherwise make every artifact look recent.
            declared = UPDATED.search(_frontmatter(text))
            last = date.fromisoformat(declared.group(1)) if declared else touched.get(rel)
            mentioning = [row for row in rows if any(needle in row for needle in needles)]
            item_class = "untracked" if tracked is not None and rel not in tracked else (
                "archived" if "archives" in path.relative_to(workflow).parts else None
            ) or classify(
                text,
                mentions_open=any(OPEN_MARK.search(row) for row in mentioning),
                mentions_done=any(DONE_MARK.search(row) for row in mentioning),
                last=last,
                today=today,
                dormant_days=dormant_days,
            )
            items.append({
                "path": rel,
                "kind": directory,
                "class": item_class,
                "bytes": path.stat().st_size,
                "last_commit": last.isoformat() if last else None,
            })
    totals: dict[str, dict[str, int]] = defaultdict(lambda: {"files": 0, "bytes": 0})
    for item in items:
        totals[item["class"]]["files"] += 1
        totals[item["class"]]["bytes"] += item["bytes"]
    return {
        "status": "inventoried",
        "root": str(root),
        "dormant_days": dormant_days,
        "items": items,
        "totals": dict(totals),
        "trackers": tracker_stats,
    }


def tidy_pressure(payload: dict[str, object], max_candidates: int = 20, max_done_rows: int = 50) -> dict[str, object]:
    """Return whether accumulated workflow material makes a tidy due, and why."""
    totals = payload.get("totals", {})
    def total(names: tuple[str, ...], key: str) -> int:
        return sum(totals.get(name, {}).get(key, 0) for name in names)
    files, size = total(REMOVABLE, "files"), total(REMOVABLE, "bytes")
    done_rows = sum(stats["done_rows"] for stats in payload.get("trackers", {}).values())
    reasons = []
    if files >= max_candidates:
        reasons.append(f"removable backlog {files} files >= {max_candidates}")
    if files >= 5 and size >= total(LIVE, "bytes"):
        reasons.append("removable material outweighs live work")
    if done_rows >= max_done_rows:
        reasons.append(f"trackers hold {done_rows} done rows >= {max_done_rows}")
    return {"due": bool(reasons), "reasons": reasons, "removable_files": files, "removable_bytes": size, "done_rows": done_rows}


def _size(value: int) -> str:
    return f"{value / 1024:.0f} KB" if value < 1024 * 1024 else f"{value / 1024 / 1024:.1f} MB"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("project", nargs="?", type=Path, default=Path.cwd())
    parser.add_argument("--dormant-days", type=int, default=90)
    parser.add_argument("--max-candidates", type=int, default=20)
    parser.add_argument("--max-done-rows", type=int, default=50)
    parser.add_argument("--check", action="store_true", help="Print only whether a tidy is operationally due.")
    parser.add_argument("--format", choices=("text", "json", "paths"), default="text")
    parser.add_argument(
        "--class", dest="classes", action="append",
        choices=("open", "recent", *REMOVABLE, "untracked"),
        help="Restrict listed items to one or more classes (repeatable).",
    )
    args = parser.parse_args()
    payload = audit_project(args.project, args.dormant_days)
    payload["tidy"] = tidy_pressure(payload, args.max_candidates, args.max_done_rows)
    if args.check:
        tidy = payload["tidy"]
        print("tidy: due (" + "; ".join(tidy["reasons"]) + ")" if tidy["due"] else "tidy: not due")
        return 0
    listed = [item for item in payload["items"] if not args.classes or item["class"] in args.classes]
    if args.format == "json":
        print(json.dumps({**payload, "items": listed}, ensure_ascii=False, indent=2, sort_keys=True))
        return 0
    if args.format == "paths":
        print("\n".join(item["path"] for item in listed))
        return 0
    if payload["status"] == "no-workflow":
        print(f"No shipglows_data/workflow in {payload['root']}")
        return 0
    print(f"Project docs tidy inventory: {payload['root']} (dormant > {payload['dormant_days']} days)")
    for name in (*LIVE, *REMOVABLE, "untracked"):
        total = payload["totals"].get(name)
        if total:
            print(f"  {name:<10} {total['files']:>4} files  {_size(total['bytes'])}")
    tidy = payload["tidy"]
    print("  tidy: due (" + "; ".join(tidy["reasons"]) + ")" if tidy["due"] else "  tidy: not due")
    for name, stats in payload["trackers"].items():
        print(f"  tracker {name}: {stats['lines']} lines, open={stats['open_rows']} done={stats['done_rows']}")
    if args.classes:
        for item in listed:
            print(f"- [{item['class']}] {item['path']} ({_size(item['bytes'])}, last {item['last_commit'] or 'unknown'})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
