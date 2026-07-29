#!/usr/bin/env python3
"""Read-only projection for a project_lifecycle Markdown declaration."""

from __future__ import annotations

import argparse
import json
import re
from collections import Counter
from datetime import date, datetime, timedelta, timezone
from pathlib import Path
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError


TABLE_COLUMNS = (
    "Item ID", "Instance ID", "Type", "Domain", "Title", "Required", "State",
    "Due At", "Cadence", "Timezone", "Evidence", "Tracker Route", "Next Action",
)
OPEN_STATES = {"not_started", "in_progress", "waiting_for_evidence", "overdue", "blocked"}
TERMINAL_STATES = {"verified", "not_applicable", "retired", "skipped_with_reason"}
VALID_TYPES = {"one_time", "recurring", "cyclic", "event_triggered"}
VALID_ROUTES = {"technical_task", "editorial_task", "chantier", "proof", "audit", "-"}


class LifecycleError(ValueError):
    """Raised when a lifecycle declaration cannot be projected safely."""


def _cells(line: str) -> list[str]:
    return [cell.strip() for cell in line.strip().strip("|").split("|")]


def _is_separator(line: str) -> bool:
    return all(re.fullmatch(r":?-{3,}:?", cell.strip()) for cell in _cells(line))


def _table_rows(markdown: str) -> list[dict[str, str]]:
    lines = markdown.splitlines()
    heading = next((i for i, line in enumerate(lines) if line.strip() == "## Lifecycle Items"), None)
    if heading is None:
        return []
    for index in range(heading + 1, len(lines) - 2):
        if not lines[index].lstrip().startswith("|"):
            continue
        headers = _cells(lines[index])
        if tuple(headers) != TABLE_COLUMNS:
            continue
        if index + 1 >= len(lines) or not _is_separator(lines[index + 1]):
            raise LifecycleError("Lifecycle Items table is missing its separator row")
        rows = []
        for row_line in lines[index + 2:]:
            if not row_line.lstrip().startswith("|"):
                break
            values = _cells(row_line)
            if len(values) != len(TABLE_COLUMNS):
                raise LifecycleError("Lifecycle Items row has the wrong number of columns")
            rows.append(dict(zip(TABLE_COLUMNS, values)))
        return rows
    raise LifecycleError("Lifecycle Items table has the expected columns but was not parseable")


def _lifecycle_phase(markdown: str) -> str:
    match = re.search(r"^- Lifecycle phase:\s*`?([^`\n]+)`?\s*$", markdown, re.MULTILINE)
    return match.group(1).strip().lower() if match else "unknown"


def _truthy(value: str) -> bool:
    return value.lower() in {"yes", "true", "1", "required"}


def _parse_dt(value: str) -> datetime:
    try:
        parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError as exc:
        raise LifecycleError(f"invalid Due At: {value}") from exc
    if parsed.tzinfo is None:
        raise LifecycleError(f"Due At must include a timezone: {value}")
    return parsed


def _zone(name: str) -> ZoneInfo:
    try:
        return ZoneInfo(name)
    except ZoneInfoNotFoundError as exc:
        raise LifecycleError(f"unknown timezone: {name}") from exc


def _next_due(due: datetime, cadence: str) -> datetime:
    """Compute the next occurrence for the v1 table shorthand."""
    kind = cadence.split(";", 1)[0].strip().lower()
    if kind == "daily":
        return due + timedelta(days=1)
    if kind == "weekly":
        return due + timedelta(days=7)
    if kind == "monthly":
        month = due.month + 1
        year = due.year + (month - 1) // 12
        month = (month - 1) % 12 + 1
        days = [31, 29 if year % 4 == 0 and (year % 100 != 0 or year % 400 == 0) else 28,
                31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        return due.replace(year=year, month=month, day=min(due.day, days[month - 1]))
    if kind == "quarterly":
        return _next_due(_next_due(_next_due(due, "monthly"), "monthly"), "monthly")
    if kind in {"cycle", "event", "-", ""}:
        raise LifecycleError(f"cadence {cadence!r} needs an explicit future instance")
    raise LifecycleError(f"unsupported cadence: {cadence}")


def project(markdown: str, *, now: datetime | None = None, operator_timezone: str = "UTC") -> dict:
    """Return a deterministic, read-only lifecycle projection."""
    operator_zone = _zone(operator_timezone)
    current = now or datetime.now(timezone.utc)
    if current.tzinfo is None:
        raise LifecycleError("now must include a timezone")
    current_local = current.astimezone(operator_zone)
    lifecycle_phase = _lifecycle_phase(markdown)
    paused = lifecycle_phase == "paused"
    rows = _table_rows(markdown)
    ids = [row["Item ID"] for row in rows if row["Item ID"] != "-" and row["Item ID"]]
    duplicate_ids = sorted(item_id for item_id, count in Counter(ids).items() if count > 1)
    items: list[dict] = []
    diagnostics: list[str] = []
    for row in rows:
        item_id = row["Item ID"]
        if item_id in {"", "-", "[stable-item-id]"}:
            continue
        item_type = row["Type"]
        if item_type not in VALID_TYPES:
            diagnostics.append(f"{item_id}: invalid type {item_type}")
            continue
        due = None if row["Due At"] in {"", "-", "YYYY-MM-DDTHH:MM:SS+00:00"} else _parse_dt(row["Due At"])
        state = row["State"]
        evidence = row["Evidence"] not in {"", "-", "none", "None"}
        evidence_gap = _truthy(row["Required"]) and state == "verified" and not evidence
        if evidence_gap:
            state = "waiting_for_evidence"
        if due and state in OPEN_STATES and due < current and not evidence_gap:
            state = "overdue"
        item = {
            "item_id": item_id,
            "instance_id": row["Instance ID"],
            "type": item_type,
            "domain": row["Domain"],
            "title": row["Title"],
            "required": _truthy(row["Required"]),
            "state": state,
            "due_at": due.isoformat() if due else None,
            "cadence": row["Cadence"],
            "timezone": row["Timezone"],
            "evidence": evidence,
            "tracker_route": row["Tracker Route"],
            "next_action": row["Next Action"],
            "history_closed": False,
            "suspended": paused and item_type in {"recurring", "cyclic", "event_triggered"},
        }
        if row["Tracker Route"] not in VALID_ROUTES:
            diagnostics.append(f"{item_id}: invalid tracker route {row['Tracker Route']}")
        if item_type == "recurring" and state == "verified" and due:
            next_due = _next_due(due, row["Cadence"])
            item["history_closed"] = True
            item["next_instance"] = {
                "instance_id": f"{row['Item ID']}:{next_due.date().isoformat()}",
                "due_at": next_due.isoformat(),
                "state": "not_started",
            }
        items.append(item)
    today = current_local.date()
    week_start = today - timedelta(days=today.weekday())
    next_week_start = week_start + timedelta(days=7)
    def local_due(item: dict) -> date | None:
        return _parse_dt(item["due_at"]).astimezone(operator_zone).date() if item["due_at"] else None
    actionable = [item for item in items if item["state"] in OPEN_STATES and not item["suspended"]]
    overdue = [item for item in actionable if item["due_at"] and _parse_dt(item["due_at"]) < current]
    today_items = [item for item in actionable if local_due(item) == today or item in overdue]
    this_week = [item for item in actionable if item in overdue or (local_due(item) and week_start <= local_due(item) < next_week_start)]
    next_week = [item for item in actionable if local_due(item) and next_week_start <= local_due(item) < next_week_start + timedelta(days=7)]
    next_review = sorted((item for item in items if item["due_at"] and item["state"] not in TERMINAL_STATES and not item["suspended"] and _parse_dt(item["due_at"]) >= current), key=lambda item: item["due_at"])
    return {
        "lifecycle_phase": lifecycle_phase,
        "paused": paused,
        "operator_timezone": operator_timezone,
        "as_of": current.isoformat(),
        "items": items,
        "today": [item["instance_id"] for item in today_items],
        "this_week": [item["instance_id"] for item in this_week],
        "next_week": [item["instance_id"] for item in next_week],
        "overdue": [item["instance_id"] for item in overdue],
        "next_review": next_review[0]["instance_id"] if next_review else None,
        "duplicate_item_ids": duplicate_ids,
        "diagnostics": diagnostics,
        "ok": not duplicate_ids and not diagnostics,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("path", type=Path)
    parser.add_argument("--timezone", default="UTC", dest="operator_timezone")
    parser.add_argument("--now", help="ISO-8601 timestamp for deterministic projections")
    args = parser.parse_args()
    try:
        now = _parse_dt(args.now) if args.now else None
        result = project(args.path.read_text(encoding="utf-8"), now=now, operator_timezone=args.operator_timezone)
    except (OSError, LifecycleError) as exc:
        parser.error(str(exc))
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0 if result["ok"] else 2


if __name__ == "__main__":
    raise SystemExit(main())
