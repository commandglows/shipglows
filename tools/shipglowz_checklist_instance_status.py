#!/usr/bin/env python3
"""Read-only status projection for a project checklist instance."""

from __future__ import annotations

import argparse
import json
import re
from collections import Counter
from pathlib import Path


ALLOWED_STATUSES = {"not_started", "in_progress", "waiting_for_evidence", "verified", "blocked", "not_applicable", "retired"}
TERMINAL_STATUSES = {"verified", "not_applicable", "retired"}
REQUIRED_COLUMNS = ("Control ID", "Phase", "Control", "Required", "Status", "Evidence", "Notes")


class ChecklistInstanceError(ValueError):
    pass


def frontmatter(markdown: str) -> dict[str, str]:
    if not markdown.startswith("---\n"):
        raise ChecklistInstanceError("frontmatter is required")
    end = markdown.find("\n---", 4)
    if end == -1:
        raise ChecklistInstanceError("frontmatter is not closed")
    values: dict[str, str] = {}
    for line in markdown[4:end].splitlines():
        if ":" not in line or line.startswith(" "):
            continue
        key, value = line.split(":", 1)
        values[key.strip()] = value.strip().strip('"')
    return values


def cells(line: str) -> list[str]:
    return [cell.strip() for cell in line.strip().strip("|").split("|")]


def is_separator(line: str) -> bool:
    return all(re.fullmatch(r":?-{3,}:?", cell) for cell in cells(line))


def controls(markdown: str) -> list[dict[str, str]]:
    lines = markdown.splitlines()
    heading = next((index for index, line in enumerate(lines) if line.strip() == "## Controls"), None)
    if heading is None:
        raise ChecklistInstanceError("## Controls section is required")
    for index in range(heading + 1, len(lines) - 1):
        if not lines[index].lstrip().startswith("|"):
            continue
        headers = tuple(cells(lines[index]))
        if headers != REQUIRED_COLUMNS:
            continue
        if not is_separator(lines[index + 1]):
            raise ChecklistInstanceError("Controls table is missing its separator row")
        rows = []
        for line in lines[index + 2:]:
            if not line.lstrip().startswith("|"):
                break
            values = cells(line)
            if len(values) != len(REQUIRED_COLUMNS):
                raise ChecklistInstanceError("Controls row has the wrong number of columns")
            rows.append(dict(zip(REQUIRED_COLUMNS, values)))
        return rows
    raise ChecklistInstanceError("Controls table has the expected columns but was not parseable")


def clean(value: str) -> str:
    return value.strip().strip("`").strip()


def project(markdown: str) -> dict:
    metadata = frontmatter(markdown)
    rows = controls(markdown)
    diagnostics: list[str] = []
    seen: set[str] = set()
    normalized: list[dict] = []
    for row in rows:
        control_id = clean(row["Control ID"])
        if not control_id or control_id == "[master-control-id]":
            continue
        if control_id in seen:
            diagnostics.append(f"duplicate control ID: {control_id}")
        seen.add(control_id)
        status = clean(row["Status"]).lower()
        if status not in ALLOWED_STATUSES:
            diagnostics.append(f"{control_id}: invalid status {status}")
        required = clean(row["Required"]).lower() in {"yes", "true", "required"}
        evidence = clean(row["Evidence"]) not in {"", "-", "none"}
        if required and status == "verified" and not evidence:
            status = "waiting_for_evidence"
        normalized.append({
            "control_id": control_id,
            "phase": clean(row["Phase"]),
            "control": row["Control"].strip(),
            "required": required,
            "status": status,
            "evidence": evidence,
            "notes": row["Notes"].strip(),
        })
    status_counts = Counter(row["status"] for row in normalized)
    open_rows = [row for row in normalized if row["status"] not in TERMINAL_STATUSES]
    phases = [row["phase"] for row in open_rows if row["phase"]]
    progress_total = len(normalized)
    progress_done = sum(row["status"] in TERMINAL_STATUSES for row in normalized)
    progress_status = "verified" if normalized and all(row["status"] in TERMINAL_STATUSES for row in normalized) else "in_progress" if progress_done or any(row["status"] == "in_progress" for row in normalized) else "not_started"
    result = {
        "project_id": metadata.get("project_id"),
        "checklist_id": metadata.get("checklist_id"),
        "checklist_version": metadata.get("checklist_version"),
        "cycle_id": metadata.get("cycle_id"),
        "cycle_kind": metadata.get("cycle_kind"),
        "cadence_kind": metadata.get("cadence_kind"),
        "cadence_anchor": metadata.get("cadence_anchor"),
        "timezone": metadata.get("timezone", "UTC"),
        "trigger_events": metadata.get("trigger_events", "[]"),
        "next_review": metadata.get("next_review"),
        "artifact_status": metadata.get("status", "draft"),
        "status": progress_status,
        "progress": {"done": progress_done, "total": progress_total},
        "current_phase": phases[0] if phases else None,
        "next_control": open_rows[0]["control_id"] if open_rows else None,
        "blocked_controls": [row["control_id"] for row in normalized if row["status"] in {"blocked", "waiting_for_evidence"}],
        "status_counts": dict(sorted(status_counts.items())),
        "controls": normalized,
        "diagnostics": diagnostics,
    }
    result["ok"] = not diagnostics and bool(result["project_id"] and result["checklist_id"] and result["cycle_id"])
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("path", type=Path)
    args = parser.parse_args()
    try:
        result = project(args.path.read_text(encoding="utf-8"))
    except (OSError, ChecklistInstanceError) as exc:
        parser.error(str(exc))
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0 if result["ok"] else 2


if __name__ == "__main__":
    raise SystemExit(main())
