#!/usr/bin/env python3
"""Plan and execute safe, project-scoped Codex session pruning.

Selection is read-only SQLite work. Destructive work is delegated exclusively to
``codex delete --force <UUID>`` so the installed Codex CLI owns its full cleanup
contract.
"""

from __future__ import annotations

import argparse
import contextlib
import json
import os
import re
import sqlite3
import subprocess
import sys
import uuid
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Callable, Mapping, Sequence


DONE_TITLE = re.compile(r"^DONE - \S(?:.*\S)?$")
TERMINAL_EDGE_STATUSES = frozenset({"closed"})
TERMINAL_JOB_STATUSES = frozenset({"completed", "failed", "cancelled"})
TERMINAL_ITEM_STATUSES = frozenset({"completed", "failed"})
CURRENT_THREAD_SOURCES = frozenset({"environment", "argument", "library"})
THREAD_REQUIRED = frozenset({"id", "rollout_path", "created_at", "updated_at", "cwd", "title"})
EDGE_REQUIRED = frozenset({"parent_thread_id", "child_thread_id", "status"})
JOB_REQUIRED = frozenset({"id", "status"})
ITEM_REQUIRED = frozenset({"job_id", "status", "assigned_thread_id"})


class PruneError(RuntimeError):
    def __init__(self, code: str, message: str, *, details: Mapping[str, Any] | None = None) -> None:
        super().__init__(message)
        self.code = code
        self.details = dict(details or {})


@dataclass(frozen=True)
class PruneOptions:
    cwd: Path
    db_path: Path
    codex_home: Path
    older_than_days: int = 30
    current_thread_id: str | None = None
    current_thread_source: str | None = None
    apply: bool = False
    confirm_cwd: Path | None = None
    now: datetime | None = None
    codex_executable: str = "codex"


@dataclass(frozen=True)
class ThreadRecord:
    id: str
    rollout_path: str
    cwd: str
    title: str
    recency: float


@dataclass(frozen=True)
class CleanupSnapshot:
    target_ids: frozenset[str]
    thread_ids: frozenset[str]
    spawn_edges: frozenset[tuple[str, str]]
    dynamic_tool_thread_ids: frozenset[str] | None
    assignment_thread_ids: frozenset[str] | None
    auxiliary_thread_ids: Mapping[str, frozenset[str]]
    rollout_paths: Mapping[str, tuple[Path, ...]]


Runner = Callable[..., subprocess.CompletedProcess[str]]


@contextlib.contextmanager
def _connect_read_only(db_path: Path):
    resolved = db_path.expanduser().resolve()
    if not resolved.is_file():
        raise PruneError("database_missing", f"Codex state database is not a regular file: {resolved}")
    try:
        connection = sqlite3.connect(f"file:{resolved}?mode=ro", uri=True, timeout=5)
    except sqlite3.Error as error:
        raise PruneError("database_open_failed", "Could not open the Codex state database read-only") from error
    connection.row_factory = sqlite3.Row
    try:
        yield connection
    finally:
        connection.close()


def _tables(connection: sqlite3.Connection) -> set[str]:
    return {
        str(row[0])
        for row in connection.execute("SELECT name FROM sqlite_master WHERE type = 'table'")
    }


def _columns(connection: sqlite3.Connection, table: str) -> set[str]:
    # Table names passed here are fixed constants, never external input.
    return {str(row[1]) for row in connection.execute(f'PRAGMA table_info("{table}")')}


def _require_columns(connection: sqlite3.Connection, table: str, required: frozenset[str]) -> set[str]:
    columns = _columns(connection, table)
    missing = sorted(required - columns)
    if missing:
        raise PruneError(
            "unsupported_schema",
            f"Codex table {table!r} lacks required ownership fields",
            details={"table": table, "missing_columns": missing},
        )
    return columns


def _validate_schema(connection: sqlite3.Connection) -> dict[str, set[str]]:
    tables = _tables(connection)
    if "threads" not in tables or "thread_spawn_edges" not in tables:
        raise PruneError(
            "unsupported_schema",
            "Codex state must expose threads and thread_spawn_edges for safe closure planning",
        )
    schema = {
        "threads": _require_columns(connection, "threads", THREAD_REQUIRED),
        "thread_spawn_edges": _require_columns(connection, "thread_spawn_edges", EDGE_REQUIRED),
    }
    has_jobs = "agent_jobs" in tables
    has_items = "agent_job_items" in tables
    if has_jobs != has_items:
        raise PruneError(
            "unsupported_schema",
            "Codex agent job tables are only partially present; active assignments cannot be proven safe",
        )
    if has_jobs:
        schema["agent_jobs"] = _require_columns(connection, "agent_jobs", JOB_REQUIRED)
        schema["agent_job_items"] = _require_columns(connection, "agent_job_items", ITEM_REQUIRED)
    return schema


def _timestamp(row: sqlite3.Row, columns: set[str]) -> float:
    candidates = (
        ("recency_at_ms", 1000.0),
        ("recency_at", 1.0),
        ("updated_at_ms", 1000.0),
        ("updated_at", 1.0),
        ("created_at_ms", 1000.0),
        ("created_at", 1.0),
    )
    for name, divisor in candidates:
        if name in columns and row[name] is not None:
            try:
                value = float(row[name])
            except (TypeError, ValueError):
                continue
            if value > 0:
                return value / divisor
    raise PruneError(
        "unsupported_schema",
        f"Thread {row['id']} has no usable recency timestamp",
        details={"thread_id": row["id"]},
    )


def _read_threads(connection: sqlite3.Connection, columns: set[str]) -> dict[str, ThreadRecord]:
    timestamp_columns = [
        name
        for name in (
            "recency_at_ms", "recency_at", "updated_at_ms", "updated_at", "created_at_ms", "created_at"
        )
        if name in columns
    ]
    selected = ["id", "rollout_path", "cwd", "title", *timestamp_columns]
    rows = connection.execute(f"SELECT {', '.join(selected)} FROM threads").fetchall()
    return {
        str(row["id"]): ThreadRecord(
            id=str(row["id"]),
            rollout_path=str(row["rollout_path"]),
            cwd=str(row["cwd"]),
            title=str(row["title"]),
            recency=_timestamp(row, columns),
        )
        for row in rows
    }


def _read_edges(connection: sqlite3.Connection) -> list[tuple[str, str, str]]:
    return [
        (str(row[0]), str(row[1]), str(row[2]).strip().lower())
        for row in connection.execute(
            "SELECT parent_thread_id, child_thread_id, status FROM thread_spawn_edges"
        )
    ]


def _active_assignments(connection: sqlite3.Connection, schema: Mapping[str, set[str]]) -> set[str]:
    if "agent_jobs" not in schema:
        return set()
    active: set[str] = set()
    rows = connection.execute(
        """
        SELECT i.assigned_thread_id, i.status, j.status
        FROM agent_job_items AS i
        LEFT JOIN agent_jobs AS j ON j.id = i.job_id
        WHERE i.assigned_thread_id IS NOT NULL
        """
    )
    for thread_id, item_status, job_status in rows:
        item = str(item_status).strip().lower()
        job = str(job_status).strip().lower()
        if item not in TERMINAL_ITEM_STATUSES or job not in TERMINAL_JOB_STATUSES:
            active.add(str(thread_id))
    return active


def _closure(root_id: str, children: Mapping[str, set[str]]) -> set[str]:
    result = {root_id}
    pending = [root_id]
    while pending:
        parent = pending.pop()
        for child in children.get(parent, set()):
            if child not in result:
                result.add(child)
                pending.append(child)
    return result


def _is_uuid(value: str) -> bool:
    try:
        return str(uuid.UUID(value)) == value
    except (ValueError, AttributeError):
        return False


def _rollout_bytes(records: Sequence[ThreadRecord], codex_home: Path) -> tuple[int, list[str]]:
    home = codex_home.expanduser().resolve()
    total = 0
    unknown: list[str] = []
    for record in records:
        rollout = Path(record.rollout_path).expanduser()
        candidates = {rollout}
        if str(rollout).endswith(".jsonl"):
            candidates.add(Path(str(rollout) + ".zst"))
        elif str(rollout).endswith(".jsonl.zst"):
            candidates.add(Path(str(rollout)[:-4]))
        known = False
        for path in candidates:
            try:
                resolved = path.resolve(strict=True)
                resolved.relative_to(home)
                if not resolved.is_file():
                    continue
                total += resolved.stat().st_size
                known = True
            except (OSError, RuntimeError, ValueError):
                continue
        if not known:
            unknown.append(record.id)
    return total, unknown


def _plan(options: PruneOptions) -> tuple[dict[str, Any], dict[str, set[str]], dict[str, ThreadRecord]]:
    target = options.cwd.expanduser().resolve()
    if not target.is_absolute():  # resolve() is absolute; retain an explicit invariant guard.
        raise PruneError("invalid_cwd", "Target cwd must resolve to an absolute path")
    if options.older_than_days < 0:
        raise PruneError("invalid_age", "--older-than-days must be zero or greater")
    now = options.now or datetime.now(timezone.utc)
    if now.tzinfo is None:
        now = now.replace(tzinfo=timezone.utc)
    cutoff = now.timestamp() - options.older_than_days * 86400

    with _connect_read_only(options.db_path) as connection:
        schema = _validate_schema(connection)
        threads = _read_threads(connection, schema["threads"])
        edges = _read_edges(connection)
        active_assignments = _active_assignments(connection, schema)

    eligible_all = {
        thread_id
        for thread_id, thread in threads.items()
        if thread.cwd == str(target) and DONE_TITLE.fullmatch(thread.title) and thread.recency < cutoff
    }
    excluded_current = int(bool(options.current_thread_id and options.current_thread_id in eligible_all))
    eligible = eligible_all - ({options.current_thread_id} if options.current_thread_id else set())

    children: dict[str, set[str]] = {}
    parents: dict[str, set[str]] = {}
    for parent, child, _status in edges:
        children.setdefault(parent, set()).add(child)
        parents.setdefault(child, set()).add(parent)

    closures = {thread_id: _closure(thread_id, children) for thread_id in eligible}
    rejected: list[dict[str, Any]] = []
    safe: set[str] = set()
    for root_id in sorted(eligible):
        closure = closures[root_id]
        descendants = closure - {root_id}
        reason: str | None = None
        details: dict[str, Any] = {}
        missing = sorted(descendants - threads.keys())
        wrong_cwd = sorted(
            thread_id
            for thread_id in descendants
            if thread_id in threads and threads[thread_id].cwd != str(target)
        )
        noneligible = sorted(
            thread_id
            for thread_id in descendants
            if thread_id in threads and thread_id not in eligible_all
        )
        incident_open_edges = sorted(
            (parent, child, status)
            for parent, child, status in edges
            if (parent in closure or child in closure) and status not in TERMINAL_EDGE_STATUSES
        )
        active = sorted(closure & active_assignments)
        if missing:
            reason, details = "descendant_metadata_missing", {"thread_ids": missing}
        elif wrong_cwd:
            reason, details = "descendant_cwd_mismatch", {"thread_ids": wrong_cwd}
        elif noneligible:
            reason, details = "descendant_not_eligible", {"thread_ids": noneligible}
        elif options.current_thread_id and options.current_thread_id in closure:
            reason, details = "current_thread_in_closure", {"thread_ids": [options.current_thread_id]}
        elif incident_open_edges:
            reason, details = "open_spawn_edge", {"edges": incident_open_edges}
        elif active:
            reason, details = "active_agent_work", {"thread_ids": active}
        elif not _is_uuid(root_id):
            reason, details = "invalid_thread_id", {"thread_ids": [root_id]}
        if reason:
            rejected.append({"id": root_id, "reason": reason, **details})
        else:
            safe.add(root_id)

    selected = {
        thread_id
        for thread_id in safe
        if not any(parent in safe for parent in _ancestor_ids(thread_id, parents))
    }
    collapsed = sorted(safe - selected)
    selected_closures = {thread_id: closures[thread_id] for thread_id in sorted(selected)}
    selected_thread_ids = set().union(*selected_closures.values()) if selected_closures else set()
    byte_records = [threads[thread_id] for thread_id in sorted(selected_thread_ids) if thread_id in threads]
    rollout_bytes, unknown_rollout_ids = _rollout_bytes(byte_records, options.codex_home)
    report: dict[str, Any] = {
        "mode": "apply" if options.apply else "dry-run",
        "cwd": str(target),
        "threshold_days": options.older_than_days,
        "eligible_ids": sorted(eligible),
        "eligible_count": len(eligible),
        "excluded_current_count": excluded_current,
        "selected_root_ids": sorted(selected),
        "selected_root_count": len(selected),
        "collapsed_ids": collapsed,
        "affected_thread_ids": sorted(selected_thread_ids),
        "affected_thread_count": len(selected_thread_ids),
        "rejected": rejected,
        "rollout_bytes": rollout_bytes,
        "unknown_rollout_count": len(unknown_rollout_ids),
        "unknown_rollout_ids": unknown_rollout_ids,
        "deleted_root_ids": [],
        "native_success_unverified_root_ids": [],
    }
    return report, selected_closures, threads


def _ancestor_ids(thread_id: str, parents: Mapping[str, set[str]]) -> set[str]:
    result: set[str] = set()
    pending = list(parents.get(thread_id, set()))
    while pending:
        parent = pending.pop()
        if parent not in result:
            result.add(parent)
            pending.extend(parents.get(parent, set()))
    return result


def _optional_thread_ids(db_path: Path, table: str) -> frozenset[str] | None:
    if not db_path.exists():
        return None
    with _connect_read_only(db_path) as connection:
        if table not in _tables(connection):
            return None
        columns = _columns(connection, table)
        if "thread_id" not in columns:
            raise PruneError(
                "unsupported_schema",
                f"Cleanup table {table!r} lacks thread_id",
                details={"database": str(db_path), "table": table},
            )
        return frozenset(str(row[0]) for row in connection.execute(f'SELECT DISTINCT thread_id FROM "{table}"'))


def _main_cleanup_ids(
    db_path: Path,
) -> tuple[frozenset[str], frozenset[tuple[str, str]], frozenset[str] | None, frozenset[str] | None]:
    with _connect_read_only(db_path) as connection:
        schema = _validate_schema(connection)
        thread_ids = frozenset(str(row[0]) for row in connection.execute("SELECT id FROM threads"))
        spawn_edges = frozenset(
            (str(row[0]), str(row[1]))
            for row in connection.execute(
                "SELECT parent_thread_id, child_thread_id FROM thread_spawn_edges"
            )
        )
        tables = _tables(connection)
        dynamic_ids = None
        if "thread_dynamic_tools" in tables:
            columns = _columns(connection, "thread_dynamic_tools")
            if "thread_id" not in columns:
                raise PruneError("unsupported_schema", "thread_dynamic_tools lacks thread_id")
            dynamic_ids = frozenset(
                str(row[0])
                for row in connection.execute("SELECT DISTINCT thread_id FROM thread_dynamic_tools")
            )
        assignment_ids = None
        if "agent_job_items" in schema:
            assignment_ids = frozenset(
                str(row[0])
                for row in connection.execute(
                    "SELECT DISTINCT assigned_thread_id FROM agent_job_items WHERE assigned_thread_id IS NOT NULL"
                )
            )
    return thread_ids, spawn_edges, dynamic_ids, assignment_ids


def _rollout_siblings(record: ThreadRecord) -> tuple[Path, ...]:
    rollout = Path(record.rollout_path).expanduser()
    candidates = {rollout}
    if str(rollout).endswith(".jsonl"):
        candidates.add(Path(str(rollout) + ".zst"))
    elif str(rollout).endswith(".jsonl.zst"):
        candidates.add(Path(str(rollout)[:-4]))
    return tuple(sorted((path for path in candidates if path.exists()), key=str))


def _snapshot_cleanup(
    options: PruneOptions,
    closures: Mapping[str, set[str]],
    threads: Mapping[str, ThreadRecord],
) -> CleanupSnapshot:
    target_ids = frozenset().union(*closures.values()) if closures else frozenset()
    thread_ids, edges, dynamic_ids, assignment_ids = _main_cleanup_ids(options.db_path)
    sqlite_home = options.db_path.expanduser().resolve().parent
    auxiliary_specs = (
        ("logs", sqlite_home / "logs_2.sqlite", "logs"),
        ("memories", sqlite_home / "memories_1.sqlite", "stage1_outputs"),
        ("goals", sqlite_home / "goals_1.sqlite", "thread_goals"),
    )
    auxiliary = {
        name: ids
        for name, path, table in auxiliary_specs
        if (ids := _optional_thread_ids(path, table)) is not None
    }
    rollouts = {
        thread_id: _rollout_siblings(threads[thread_id])
        for thread_id in target_ids
        if thread_id in threads
    }
    return CleanupSnapshot(
        target_ids=target_ids,
        thread_ids=thread_ids,
        spawn_edges=edges,
        dynamic_tool_thread_ids=dynamic_ids,
        assignment_thread_ids=assignment_ids,
        auxiliary_thread_ids=auxiliary,
        rollout_paths=rollouts,
    )


def _verify_cleanup(options: PruneOptions, snapshot: CleanupSnapshot, deleted_ids: set[str]) -> None:
    thread_ids, edges, dynamic_ids, assignment_ids = _main_cleanup_ids(options.db_path)
    details: dict[str, Any] = {}
    remaining_threads = sorted(snapshot.target_ids & deleted_ids & thread_ids)
    missing_preserved_threads = sorted((snapshot.thread_ids - deleted_ids) - thread_ids)
    if remaining_threads:
        details["remaining_thread_ids"] = remaining_threads
    if missing_preserved_threads:
        details["missing_preserved_thread_ids"] = missing_preserved_threads

    remaining_edges = sorted(
        edge for edge in edges if edge[0] in deleted_ids or edge[1] in deleted_ids
    )
    expected_edges = {
        edge for edge in snapshot.spawn_edges if edge[0] not in deleted_ids and edge[1] not in deleted_ids
    }
    missing_edges = sorted(expected_edges - edges)
    if remaining_edges:
        details["remaining_spawn_edges"] = remaining_edges
    if missing_edges:
        details["missing_preserved_spawn_edges"] = missing_edges

    for label, before, after in (
        ("dynamic_tool", snapshot.dynamic_tool_thread_ids, dynamic_ids),
        ("agent_assignment", snapshot.assignment_thread_ids, assignment_ids),
    ):
        if before is None:
            continue
        if after is None:
            details[f"missing_{label}_surface"] = True
            continue
        remaining = sorted(deleted_ids & after)
        missing = sorted((before - deleted_ids) - after)
        if remaining:
            details[f"remaining_{label}_thread_ids"] = remaining
        if missing:
            details[f"missing_preserved_{label}_thread_ids"] = missing

    sqlite_home = options.db_path.expanduser().resolve().parent
    auxiliary_specs = {
        "logs": (sqlite_home / "logs_2.sqlite", "logs"),
        "memories": (sqlite_home / "memories_1.sqlite", "stage1_outputs"),
        "goals": (sqlite_home / "goals_1.sqlite", "thread_goals"),
    }
    for name, before in snapshot.auxiliary_thread_ids.items():
        path, table = auxiliary_specs[name]
        after = _optional_thread_ids(path, table)
        if after is None:
            details[f"missing_{name}_surface"] = True
            continue
        remaining = sorted(deleted_ids & after)
        missing = sorted((before - deleted_ids) - after)
        if remaining:
            details[f"remaining_{name}_thread_ids"] = remaining
        if missing:
            details[f"missing_preserved_{name}_thread_ids"] = missing

    remaining_rollouts = sorted(
        str(path)
        for thread_id in deleted_ids
        for path in snapshot.rollout_paths.get(thread_id, ())
        if path.exists()
    )
    if remaining_rollouts:
        details["remaining_rollout_paths"] = remaining_rollouts
    if details:
        raise PruneError(
            "post_delete_verification_failed",
            "Native Codex deletion returned success but cleanup verification failed",
            details=details,
        )


def prune_sessions(options: PruneOptions, *, runner: Runner = subprocess.run) -> dict[str, Any]:
    target = options.cwd.expanduser().resolve()
    if options.apply:
        if options.confirm_cwd is None or str(options.confirm_cwd) != str(target):
            raise PruneError(
                "cwd_confirmation_required",
                f"Apply requires --confirm-cwd exactly equal to {target}",
            )
        if not options.current_thread_id:
            raise PruneError(
                "current_thread_required",
                "Apply requires --current-thread-id or CODEX_THREAD_ID",
            )
        if options.current_thread_source not in CURRENT_THREAD_SOURCES:
            raise PruneError(
                "current_thread_provenance_required",
                "Apply requires explicit current-thread provenance",
            )
        if not _is_uuid(options.current_thread_id):
            raise PruneError(
                "invalid_current_thread_id",
                "The current thread id must be a canonical UUID",
            )
        resolved_db = options.db_path.expanduser().resolve()
        if resolved_db.name != "state_5.sqlite":
            raise PruneError(
                "noncanonical_apply_database",
                "Apply requires a canonical state_5.sqlite database",
                details={"db_path": str(resolved_db)},
            )

    report, closures, threads = _plan(options)
    if options.apply and options.current_thread_id not in threads:
        raise PruneError(
            "current_thread_not_found",
            "The current thread id is not present in the planned Codex database",
            details={"current_thread_id": options.current_thread_id},
        )
    if not options.apply or not closures:
        return report

    snapshot = _snapshot_cleanup(options, closures, threads)
    environment = os.environ.copy()
    environment["CODEX_HOME"] = str(options.codex_home.expanduser().resolve())
    environment["CODEX_SQLITE_HOME"] = str(options.db_path.expanduser().resolve().parent)
    deleted: list[str] = []
    verified_thread_ids: set[str] = set()
    selected_roots = report["selected_root_ids"]
    for index, root_id in enumerate(selected_roots):
        command = [options.codex_executable, "delete", "--force", root_id]
        try:
            completed = runner(command, env=environment, capture_output=True, text=True, check=False)
        except OSError as error:
            raise PruneError(
                "native_delete_unavailable",
                "Could not execute the Codex CLI",
                details={
                    "failed_root_id": root_id,
                    "deleted_root_ids": deleted,
                    "native_success_unverified_root_ids": [],
                    "unattempted_root_ids": selected_roots[index + 1 :],
                },
            ) from error
        if completed.returncode != 0:
            raise PruneError(
                "native_delete_failed",
                f"Native Codex deletion failed for {root_id}",
                details={
                    "failed_root_id": root_id,
                    "returncode": completed.returncode,
                    "deleted_root_ids": deleted,
                    "native_success_unverified_root_ids": [],
                    "unattempted_root_ids": selected_roots[index + 1 :],
                },
            )
        try:
            _verify_cleanup(options, snapshot, verified_thread_ids | closures[root_id])
        except PruneError as error:
            error.details.update(
                {
                    "failed_root_id": root_id,
                    "deleted_root_ids": deleted,
                    "native_success_unverified_root_ids": [root_id],
                    "unattempted_root_ids": selected_roots[index + 1 :],
                }
            )
            raise
        verified_thread_ids.update(closures[root_id])
        deleted.append(root_id)
    report["deleted_root_ids"] = deleted
    return report


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("cwd", nargs="?", default=os.getcwd(), help="Exact project cwd (default: current directory)")
    parser.add_argument("--older-than-days", type=int, default=30)
    parser.add_argument("--current-thread-id", default=None)
    parser.add_argument("--apply", action="store_true")
    parser.add_argument("--confirm-cwd")
    parser.add_argument("--codex-home", default=str(Path.home() / ".codex"))
    parser.add_argument("--db")
    parser.add_argument("--codex-executable", default="codex")
    parser.add_argument("--json", action="store_true", dest="json_output")
    return parser


def _print_text(report: Mapping[str, Any]) -> None:
    print(f"mode: {report['mode']}")
    print(f"cwd: {report['cwd']}")
    print(f"threshold: strictly older than {report['threshold_days']} days")
    print(f"eligible: {report['eligible_count']}; selected roots: {report['selected_root_count']}")
    print(f"excluded current: {report['excluded_current_count']}; rejected: {len(report['rejected'])}")
    print(f"rollout bytes (known): {report['rollout_bytes']}")
    print(f"unknown rollout count: {report['unknown_rollout_count']}")
    if report["unknown_rollout_ids"]:
        print("unknown rollout ids: " + ", ".join(report["unknown_rollout_ids"]))
    if report["affected_thread_ids"]:
        print("affected thread ids: " + ", ".join(report["affected_thread_ids"]))
    if report["selected_root_ids"]:
        print("selected root ids: " + ", ".join(report["selected_root_ids"]))
    if report["deleted_root_ids"]:
        print("deleted root ids: " + ", ".join(report["deleted_root_ids"]))
    for item in report["rejected"]:
        print(f"rejected {item['id']}: {item['reason']}")


def run(argv: Sequence[str] | None = None) -> int:
    parser = _parser()
    args = parser.parse_args(argv)
    codex_home = Path(args.codex_home).expanduser()
    try:
        environment_thread_id = os.environ.get("CODEX_THREAD_ID")
        if environment_thread_id and args.current_thread_id and environment_thread_id != args.current_thread_id:
            raise PruneError(
                "current_thread_conflict",
                "CODEX_THREAD_ID conflicts with --current-thread-id",
                details={"environment_wins": True},
            )
        if environment_thread_id:
            current_thread_id = environment_thread_id
            current_thread_source = "environment"
        elif args.current_thread_id:
            current_thread_id = args.current_thread_id
            current_thread_source = "argument"
        else:
            current_thread_id = None
            current_thread_source = None
        options = PruneOptions(
            cwd=Path(args.cwd),
            db_path=Path(args.db).expanduser() if args.db else codex_home / "state_5.sqlite",
            codex_home=codex_home,
            older_than_days=args.older_than_days,
            current_thread_id=current_thread_id,
            current_thread_source=current_thread_source,
            apply=args.apply,
            confirm_cwd=Path(args.confirm_cwd) if args.confirm_cwd is not None else None,
            codex_executable=args.codex_executable,
        )
        report = prune_sessions(options)
    except PruneError as error:
        payload = {"ok": False, "error": error.code, "message": str(error), **error.details}
        if args.json_output:
            print(json.dumps(payload, sort_keys=True))
        else:
            print(f"error [{error.code}]: {error}", file=sys.stderr)
        return 2
    if args.json_output:
        print(json.dumps({"ok": True, **report}, sort_keys=True))
    else:
        _print_text(report)
    return 0


if __name__ == "__main__":
    raise SystemExit(run())
