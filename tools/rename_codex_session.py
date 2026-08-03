#!/usr/bin/env python3
"""Rename the current Codex session with a canonical tracker-status title."""

from __future__ import annotations

import argparse
import json
import os
import re
import sqlite3
import sys
import uuid
from pathlib import Path
from typing import Any, Mapping, Sequence


STATUSES = frozenset({"todo", "doing", "in_progress", "blocked", "done"})
CANONICAL_PREFIX = re.compile(r"^(TODO|DOING|IN_PROGRESS|BLOCKED|DONE)\s+-\s+", re.IGNORECASE)
GENERIC_TITLES = frozenset(
    {
        "general task",
        "011-sg-pilotage",
        "review work",
        "review project work",
        "sessions",
        "session rename",
        "sg-pilotage",
        "task",
        "work",
    }
)
REQUIRED_COLUMNS = frozenset({"id", "cwd", "title"})
MAX_WORK_TITLE_WORDS = 5


class RenameError(RuntimeError):
    def __init__(self, code: str, message: str, *, details: Mapping[str, Any] | None = None) -> None:
        super().__init__(message)
        self.code = code
        self.details = dict(details or {})


def normalize_status(value: str) -> str:
    status = value.strip().lower().replace("-", "_")
    if status not in STATUSES:
        raise RenameError(
            "invalid_status",
            "Status must be one of: todo, doing, in_progress, blocked, done",
        )
    return status


def normalize_work_title(value: str) -> str:
    if any(ord(character) < 32 or ord(character) == 127 for character in value):
        raise RenameError("invalid_work_title", "Work title must not contain control characters")
    title = " ".join(value.strip().split())
    if not title:
        raise RenameError("invalid_work_title", "Work title must not be empty")
    if CANONICAL_PREFIX.match(title):
        raise RenameError("invalid_work_title", "Pass the semantic work title without a status prefix")
    if title.casefold() in GENERIC_TITLES:
        raise RenameError("generic_work_title", "Work title must identify the concrete work")
    word_count = len(title.split())
    if word_count > MAX_WORK_TITLE_WORDS:
        raise RenameError(
            "work_title_too_long",
            f"Work title must contain at most {MAX_WORK_TITLE_WORDS} words",
            details={"word_count": word_count, "max_words": MAX_WORK_TITLE_WORDS},
        )
    return title


def rename_session(
    *,
    db_path: Path,
    cwd: Path,
    current_thread_id: str,
    status: str,
    work_title: str,
) -> dict[str, Any]:
    resolved_db = db_path.expanduser().resolve()
    resolved_cwd = cwd.expanduser().resolve()
    if not resolved_db.is_file():
        raise RenameError("database_missing", f"Codex state database is not a regular file: {resolved_db}")
    if not current_thread_id.strip():
        raise RenameError("current_thread_missing", "Current Codex thread id is required")
    try:
        canonical_thread_id = str(uuid.UUID(current_thread_id))
    except (ValueError, AttributeError) as error:
        raise RenameError("invalid_current_thread", "Current Codex thread id must be a UUID") from error
    if canonical_thread_id != current_thread_id:
        raise RenameError("invalid_current_thread", "Current Codex thread id must be a canonical UUID")

    canonical_status = normalize_status(status)
    semantic_title = normalize_work_title(work_title)
    target_title = f"{canonical_status.upper()} - {semantic_title}"

    try:
        connection = sqlite3.connect(resolved_db, timeout=5)
        connection.row_factory = sqlite3.Row
    except sqlite3.Error as error:
        raise RenameError("database_open_failed", "Could not open the Codex state database") from error

    try:
        columns = {
            str(row[1]) for row in connection.execute('PRAGMA table_info("threads")')
        }
        missing = sorted(REQUIRED_COLUMNS - columns)
        if missing:
            raise RenameError(
                "unsupported_schema",
                "Codex threads table lacks required fields",
                details={"missing_columns": missing},
            )
        row = connection.execute(
            "SELECT id, cwd, title FROM threads WHERE id = ?",
            (canonical_thread_id,),
        ).fetchone()
        if row is None:
            raise RenameError("current_thread_not_found", "Current Codex thread was not found")
        if str(row["cwd"]) != str(resolved_cwd):
            raise RenameError(
                "cwd_mismatch",
                "Current Codex thread does not belong to the exact requested cwd",
                details={"thread_cwd": str(row["cwd"]), "requested_cwd": str(resolved_cwd)},
            )

        previous_title = str(row["title"])
        changed = previous_title != target_title
        if changed:
            connection.execute("BEGIN IMMEDIATE")
            cursor = connection.execute(
                "UPDATE threads SET title = ? WHERE id = ? AND cwd = ?",
                (target_title, canonical_thread_id, str(resolved_cwd)),
            )
            if cursor.rowcount != 1:
                connection.rollback()
                raise RenameError("concurrent_change", "Current thread changed before rename could be applied")
            persisted = connection.execute(
                "SELECT title FROM threads WHERE id = ?",
                (canonical_thread_id,),
            ).fetchone()
            if persisted is None or str(persisted["title"]) != target_title:
                connection.rollback()
                raise RenameError("verification_failed", "Renamed title could not be verified")
            connection.commit()

        return {
            "thread_id": canonical_thread_id,
            "cwd": str(resolved_cwd),
            "status": canonical_status,
            "previous_title": previous_title,
            "title": target_title,
            "changed": changed,
        }
    except sqlite3.Error as error:
        connection.rollback()
        raise RenameError("database_write_failed", "Could not rename the current Codex thread") from error
    finally:
        connection.close()


def _default_db() -> Path:
    sqlite_home = os.environ.get("CODEX_SQLITE_HOME")
    if sqlite_home:
        return Path(sqlite_home).expanduser() / "state_5.sqlite"
    return Path(os.environ.get("CODEX_HOME", str(Path.home() / ".codex"))).expanduser() / "state_5.sqlite"


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("status")
    parser.add_argument("work_title")
    parser.add_argument("--cwd", default=os.getcwd())
    parser.add_argument("--db")
    parser.add_argument("--current-thread-id")
    parser.add_argument("--json", action="store_true", dest="json_output")
    return parser


def run(argv: Sequence[str] | None = None) -> int:
    parser = _parser()
    args = parser.parse_args(argv)
    try:
        environment_thread_id = os.environ.get("CODEX_THREAD_ID")
        if environment_thread_id and args.current_thread_id and environment_thread_id != args.current_thread_id:
            raise RenameError(
                "current_thread_conflict",
                "CODEX_THREAD_ID conflicts with --current-thread-id",
            )
        current_thread_id = environment_thread_id or args.current_thread_id
        if not current_thread_id:
            raise RenameError(
                "current_thread_missing",
                "CODEX_THREAD_ID is required to rename the current conversation",
            )
        report = rename_session(
            db_path=Path(args.db) if args.db else _default_db(),
            cwd=Path(args.cwd),
            current_thread_id=current_thread_id,
            status=args.status,
            work_title=args.work_title,
        )
    except RenameError as error:
        payload = {"ok": False, "error": error.code, "message": str(error), **error.details}
        if args.json_output:
            print(json.dumps(payload, sort_keys=True))
        else:
            print(f"error [{error.code}]: {error}", file=sys.stderr)
        return 2

    if args.json_output:
        print(json.dumps({"ok": True, **report}, sort_keys=True))
    else:
        action = "renamed" if report["changed"] else "unchanged"
        print(f"{action}: {report['title']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(run())
