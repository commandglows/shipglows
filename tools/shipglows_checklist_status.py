#!/usr/bin/env python3
"""Parse and validate ShipGlows manual checklist files."""

from __future__ import annotations

import argparse
import json
import re
from dataclasses import dataclass
from pathlib import Path


STATUS_ALIASES = {
    "pass": "PASS",
    "p": "PASS",
    "done": "PASS",
    "réussi": "PASS",
    "reussi": "PASS",
    "ok": "PASS",
    "passé": "PASS",
    "passed": "PASS",
    "succeed": "PASS",
    "succès": "PASS",
    "success": "PASS",
    "fail": "FAIL",
    "failed": "FAIL",
    "failure": "FAIL",
    "erreur": "FAIL",
    "error": "FAIL",
    "ko": "FAIL",
    "blocked": "BLOCKED",
    "bloqué": "BLOCKED",
    "not run": "NOT_RUN",
    "not_run": "NOT_RUN",
    "notrun": "NOT_RUN",
    "na": "N/A",
    "n/a": "N/A",
    "not applicable": "N/A",
    "notapplicable": "N/A",
    "skip": "N/A",
}


ALLOWED_STATUSES = {"NOT_RUN", "PASS", "FAIL", "BLOCKED", "N/A"}
REQUIRED_COLUMNS = [
    "Scenario ID",
    "Surface",
    "Scenario",
    "Required",
    "Expected",
    "Status",
    "Observed",
    "Evidence pointer",
    "Notes",
    "Bug Link",
]

BUG_LINK_RE = re.compile(r"^BUG-\d{4}-\d{2}-\d{2}-\d{3}$")
UNSAFE_POINTER_RE = re.compile(
    r"(^/)|(\.\.)|([A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,})|(\b(token|secret|api[_-]?key|cookie|password|session)\b)",
    re.IGNORECASE,
)


@dataclass
class ChecklistRow:
    scenario_id: str
    required: bool
    status: str
    observed: str
    evidence_pointer: str
    bug_link: str


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("path", help="Path to a manual_test_checklist.md file")
    parser.add_argument("--json", action="store_true", help="Output JSON payload")
    parser.add_argument("--require-passed", action="store_true", help="Treat not-run as error")
    return parser.parse_args()


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def normalize_status(value: str, row_no: int, errors: list[str]) -> str:
    status = (value or "").strip()
    if not status:
        return "NOT_RUN"

    normalized = status.lower().strip()
    if normalized in STATUS_ALIASES:
        return STATUS_ALIASES[normalized]

    candidate = status.upper().replace(" ", "_")
    if candidate in ALLOWED_STATUSES:
        return candidate

    errors.append(f"row {row_no}: unsupported status '{status}'")
    return "UNKNOWN"


def parse_table_rows(markdown: str, errors: list[str]) -> list[ChecklistRow]:
    lines = markdown.splitlines()
    table_header = None
    table_sep = None
    start = 0
    for i, line in enumerate(lines):
        if not line.startswith("|"):
            continue
        if table_header is None and "Scenario ID" in line and "Scenario" in line and "Status" in line:
            table_header = [c.strip() for c in line.strip().strip("|").split("|")]
            if len(table_header) < len(REQUIRED_COLUMNS):
                errors.append(
                    f"table header has {len(table_header)} columns, expected at least {len(REQUIRED_COLUMNS)}"
                )
                return []

        if table_header is not None and i + 1 < len(lines) and re.match(r"^\s*\|?\s*:?-{3,}", lines[i + 1]):
            table_sep = i + 1
            start = i + 2
            break

    if table_header is None or start == 0:
        errors.append("no markdown table detected")
        return []

    missing_cols = [col for col in REQUIRED_COLUMNS if col not in table_header]
    if missing_cols:
        errors.append(f"missing checklist columns: {', '.join(missing_cols)}")
        return []

    idx = {name: table_header.index(name) for name in REQUIRED_COLUMNS}
    rows: list[ChecklistRow] = []
    ids: set[str] = set()

    for line_no, line in enumerate(lines[start:], start=start + 1):
        raw = line.strip()
        if not raw.startswith("|"):
            break
        cols = [c.strip() for c in raw.strip("|").split("|")]
        if len(cols) < len(table_header):
            continue
        get = lambda name: cols[idx[name]]
        scenario_id = get("Scenario ID")
        if not scenario_id:
            errors.append(f"row {line_no}: missing Scenario ID")
            continue
        if scenario_id in ids:
            errors.append(f"row {line_no}: duplicate Scenario ID '{scenario_id}'")
            continue
        ids.add(scenario_id)

        required_raw = get("Required").lower().strip()
        required = required_raw in {"yes", "true", "y", "1"}
        status = normalize_status(get("Status"), line_no, errors)
        observed = get("Observed").strip()
        evidence_pointer = get("Evidence pointer").strip()
        bug_link = get("Bug Link").strip()

        if status in {"FAIL", "BLOCKED"}:
            if not observed:
                errors.append(f"row {line_no}: observed is required for status {status}")
            if not bug_link and not evidence_pointer:
                errors.append(f"row {line_no}: evidence pointer required when status is {status} without Bug Link")

        if status in {"PASS", "FAIL", "BLOCKED", "NOT_RUN", "N/A"} and status != "N/A":
            if status != "PASS" and status != "N/A" and required and not observed:
                # error above for fail/blocked; explicit for completeness
                pass

        if evidence_pointer and is_unsafe_evidence_pointer(evidence_pointer, line_no, errors):
            errors.append(f"row {line_no}: unsafe evidence pointer '{evidence_pointer}'")

        rows.append(
            ChecklistRow(
                scenario_id=scenario_id,
                required=required,
                status=status,
                observed=observed,
                evidence_pointer=evidence_pointer,
                bug_link=bug_link,
            )
        )
    return rows


def is_unsafe_evidence_pointer(path: str, line_no: int, errors: list[str]) -> bool:
    if UNSAFE_POINTER_RE.search(path):
        return True
    return False


def evaluate_gate(rows: list[ChecklistRow], require_passed: bool, errors: list[str]) -> dict:
    required_blockers = []
    status_counts: dict[str, int] = {status: 0 for status in sorted(ALLOWED_STATUSES)}
    invalid_rows = []

    for row in rows:
        status_counts[row.status] = status_counts.get(row.status, 0) + 1
        if row.required and row.status == "NOT_RUN":
            required_blockers.append(row.scenario_id)
            if require_passed:
                invalid_rows.append(f"required row {row.scenario_id} is NOT_RUN")
        if row.required and row.status in {"FAIL", "BLOCKED"}:
            required_blockers.append(row.scenario_id)
            invalid_rows.append(
                f"required row {row.scenario_id} has status {row.status}"
            )

    if require_passed and invalid_rows:
        errors.extend(invalid_rows)

    return {
        "rows": len(rows),
        "status_counts": status_counts,
        "required_blockers": required_blockers,
    }


def main() -> int:
    args = parse_args()
    path = Path(args.path)
    if not path.exists():
        print(f"file-not-found: {args.path}")
        return 2

    text = read_text(path)
    errors: list[str] = []
    rows = parse_table_rows(text, errors)
    gate = evaluate_gate(rows, args.require_passed, errors)

    if args.json:
        payload = {
            "path": str(path),
            "ok": not errors,
            "rows": gate["rows"],
            "status_counts": gate["status_counts"],
            "required_blockers": gate["required_blockers"],
            "errors": errors,
        }
        print(json.dumps(payload, indent=2, sort_keys=True))
    else:
        if errors:
            print(f"{path}: invalid")
            for error in errors:
                print(f"  - {error}")
        else:
            print(f"{path}: ok ({gate['rows']} rows)")
            for status, count in gate["status_counts"].items():
                print(f"  - {status}: {count}")
            if gate["required_blockers"]:
                print("  - required blockers:", ", ".join(gate["required_blockers"]))

    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
