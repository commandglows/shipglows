#!/usr/bin/env python3
"""Compare a project audit log with a declared audit-cadence matrix."""

from __future__ import annotations

import argparse
from datetime import date, timedelta
import json
from pathlib import Path
import re
import unicodedata


DATE_RE = re.compile(r"\|\s*date:\s*(\d{4}-\d{2}-\d{2})", re.IGNORECASE)
DOMAIN_RE = re.compile(r"\|\s*domain:\s*([a-z0-9-]+)", re.IGNORECASE)


def _normalize(value: str) -> str:
    value = unicodedata.normalize("NFKD", value).encode("ascii", "ignore").decode()
    return re.sub(r"[^a-z0-9]+", " ", value.lower()).strip()


def _load_matrix(path: Path) -> list[dict[str, object]]:
    payload = json.loads(path.read_text(encoding="utf-8"))
    if payload.get("schema_version") != "1.0" or not isinstance(payload.get("domains"), list):
        raise ValueError("audit cadence matrix must use schema_version 1.0 and domains[]")
    return payload["domains"]


def _domain_lookup(domains: list[dict[str, object]]) -> dict[str, str]:
    lookup: dict[str, str] = {}
    for domain in domains:
        domain_id = str(domain["id"])
        for alias in [domain_id, str(domain.get("label", "")), *domain.get("aliases", [])]:
            normalized = _normalize(str(alias))
            if normalized:
                lookup[normalized] = domain_id
    return lookup


def _match_domain(text: str, lookup: dict[str, str]) -> str | None:
    normalized = f" {_normalize(text)} "
    matches = [
        (len(alias), domain_id)
        for alias, domain_id in lookup.items()
        if f" {alias} " in normalized
    ]
    return max(matches, default=(0, None))[1]


def _read_last_audits(
    audit_log: Path, domains: list[dict[str, object]], as_of: date
) -> dict[str, date]:
    if not audit_log.is_file():
        return {}
    lines = audit_log.read_text(encoding="utf-8").splitlines()
    lookup = _domain_lookup(domains)
    latest: dict[str, date] = {}

    for line in lines:
        date_match = DATE_RE.search(line)
        if not date_match or "audit:" not in line.lower():
            continue
        audit_date = date.fromisoformat(date_match.group(1))
        if audit_date > as_of:
            continue
        explicit = DOMAIN_RE.search(line)
        title_match = re.search(r"audit:\s*(.*?)(?:\||$)", line, re.IGNORECASE)
        domain_id = (
            explicit.group(1).lower()
            if explicit
            else _match_domain(title_match.group(1) if title_match else "", lookup)
        )
        if domain_id in {str(domain["id"]) for domain in domains}:
            latest[domain_id] = max(latest.get(domain_id, audit_date), audit_date)

    header: list[str] | None = None
    for line in lines:
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if len(cells) < 2:
            continue
        if cells[0].lower() == "date":
            header = cells
            continue
        if header is None or cells[0].startswith("-") or len(cells) != len(header):
            continue
        try:
            audit_date = date.fromisoformat(cells[0])
        except ValueError:
            continue
        if audit_date > as_of:
            continue
        for column, value in zip(header[1:], cells[1:]):
            if not value or value in {"-", "—", "–"}:
                continue
            domain_id = _match_domain(column, lookup)
            if domain_id:
                latest[domain_id] = max(latest.get(domain_id, audit_date), audit_date)
    return latest


def calculate_audit_status(
    matrix_path: Path,
    audit_log_path: Path,
    as_of: date | None = None,
    triggered_domains: set[str] | None = None,
) -> list[dict[str, object]]:
    """Return all domains sorted with the most actionable audit first."""

    reference_date = as_of or date.today()
    domains = _load_matrix(matrix_path)
    latest = _read_last_audits(audit_log_path, domains, reference_date)
    triggered = triggered_domains or set()
    result: list[dict[str, object]] = []

    for domain in domains:
        domain_id = str(domain["id"])
        max_age = int(domain["max_age_days"])
        last = latest.get(domain_id)
        next_due = last + timedelta(days=max_age) if last else None
        if domain_id in triggered:
            state = "event-triggered"
            overdue_days = 0
        elif last is None:
            state = "never-run"
            overdue_days = None
        elif next_due and reference_date > next_due:
            state = "overdue"
            overdue_days = (reference_date - next_due).days
        else:
            state = "current"
            overdue_days = 0
        result.append(
            {
                "id": domain_id,
                "label": domain["label"],
                "priority": int(domain["priority"]),
                "max_age_days": max_age,
                "last_audit": last.isoformat() if last else None,
                "next_due": next_due.isoformat() if next_due else None,
                "state": state,
                "overdue_days": overdue_days,
            }
        )

    state_order = {"event-triggered": 0, "never-run": 1, "overdue": 2, "current": 3}
    result.sort(
        key=lambda item: (
            state_order[str(item["state"])],
            -int(item["overdue_days"] or 0) if item["state"] == "overdue" else 0,
            int(item["priority"]),
        )
    )
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--matrix", type=Path, required=True)
    parser.add_argument("--audit-log", type=Path, required=True)
    parser.add_argument("--as-of", type=date.fromisoformat)
    parser.add_argument("--trigger", action="append", default=[])
    parser.add_argument("--actionable-only", action="store_true")
    parser.add_argument("--format", choices=("text", "json"), default="text")
    args = parser.parse_args()
    status = calculate_audit_status(
        args.matrix, args.audit_log, args.as_of, set(args.trigger)
    )
    if args.actionable_only:
        status = [item for item in status if item["state"] != "current"]
    if args.format == "json":
        print(json.dumps(status, ensure_ascii=False, indent=2))
    else:
        for item in status:
            print(
                f"{item['state']:15} {item['id']:24} "
                f"last={item['last_audit'] or 'never'} next={item['next_due'] or 'due-now'}"
            )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
