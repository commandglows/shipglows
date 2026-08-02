from __future__ import annotations

import contextlib
import io
import json
import os
import sqlite3
import tempfile
import unittest
from pathlib import Path
from unittest import mock

from tools import rename_codex_session as rename

ROOT = Path(__file__).resolve().parents[1]

class SessionRenameTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.project = (self.root / "project").resolve()
        self.other_project = (self.root / "other-project").resolve()
        self.project.mkdir()
        self.other_project.mkdir()
        self.db_path = self.root / "state_5.sqlite"
        self.current_id = "00000000-0000-4000-8000-000000000001"
        self.other_id = "00000000-0000-4000-8000-000000000002"
        with sqlite3.connect(self.db_path) as connection:
            connection.execute(
                "CREATE TABLE threads (id TEXT PRIMARY KEY, cwd TEXT NOT NULL, title TEXT NOT NULL)"
            )
            connection.executemany(
                "INSERT INTO threads VALUES (?, ?, ?)",
                [
                    (self.current_id, str(self.project), "Old current title"),
                    (self.other_id, str(self.project), "Other title"),
                ],
            )

    def titles(self) -> dict[str, str]:
        with sqlite3.connect(self.db_path) as connection:
            return dict(connection.execute("SELECT id, title FROM threads"))

    def test_renames_only_current_exact_cwd_thread(self) -> None:
        report = rename.rename_session(
            db_path=self.db_path,
            cwd=self.project,
            current_thread_id=self.current_id,
            status="done",
            work_title="Codex session rename mode",
        )
        self.assertTrue(report["changed"])
        self.assertEqual(report["title"], "DONE - Codex session rename mode")
        self.assertEqual(
            self.titles(),
            {
                self.current_id: "DONE - Codex session rename mode",
                self.other_id: "Other title",
            },
        )

    def test_repeated_rename_is_idempotent(self) -> None:
        options = dict(
            db_path=self.db_path,
            cwd=self.project,
            current_thread_id=self.current_id,
            status="DONE",
            work_title="Codex session rename mode",
        )
        rename.rename_session(**options)
        report = rename.rename_session(**options)
        self.assertFalse(report["changed"])

    def test_cwd_mismatch_fails_without_mutation(self) -> None:
        before = self.titles()
        with self.assertRaisesRegex(rename.RenameError, "exact requested cwd") as caught:
            rename.rename_session(
                db_path=self.db_path,
                cwd=self.other_project,
                current_thread_id=self.current_id,
                status="done",
                work_title="Codex session rename mode",
            )
        self.assertEqual(caught.exception.code, "cwd_mismatch")
        self.assertEqual(self.titles(), before)

    def test_equivalent_but_noncanonical_stored_cwd_is_rejected(self) -> None:
        with sqlite3.connect(self.db_path) as connection:
            connection.execute(
                "UPDATE threads SET cwd = ? WHERE id = ?",
                (str(self.project / ".." / "project"), self.current_id),
            )
        before = self.titles()
        with self.assertRaises(rename.RenameError) as caught:
            rename.rename_session(
                db_path=self.db_path,
                cwd=self.project,
                current_thread_id=self.current_id,
                status="done",
                work_title="Codex session rename mode",
            )
        self.assertEqual(caught.exception.code, "cwd_mismatch")
        self.assertEqual(self.titles(), before)

    def test_invalid_status_fails_without_mutation(self) -> None:
        before = self.titles()
        with self.assertRaises(rename.RenameError) as caught:
            rename.rename_session(
                db_path=self.db_path,
                cwd=self.project,
                current_thread_id=self.current_id,
                status="closed",
                work_title="Codex session rename mode",
            )
        self.assertEqual(caught.exception.code, "invalid_status")
        self.assertEqual(self.titles(), before)

    def test_missing_status_fails_without_mutation(self) -> None:
        before = self.titles()
        with self.assertRaises(rename.RenameError) as caught:
            rename.rename_session(
                db_path=self.db_path,
                cwd=self.project,
                current_thread_id=self.current_id,
                status="",
                work_title="Codex session rename mode",
            )
        self.assertEqual(caught.exception.code, "invalid_status")
        self.assertEqual(self.titles(), before)

    def test_cli_missing_status_does_not_open_or_mutate_database(self) -> None:
        before = self.titles()
        with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit) as caught:
            rename.run(["--cwd", str(self.project), "--db", str(self.db_path)])
        self.assertEqual(caught.exception.code, 2)
        self.assertEqual(self.titles(), before)

    def test_semantic_title_gate(self) -> None:
        for title in ("", "Review work", "DONE - Existing prefix", "bad\ntitle"):
            with self.subTest(title=title), self.assertRaises(rename.RenameError):
                rename.rename_session(
                    db_path=self.db_path,
                    cwd=self.project,
                    current_thread_id=self.current_id,
                    status="done",
                    work_title=title,
                )

    def test_work_title_whitespace_is_normalized(self) -> None:
        report = rename.rename_session(
            db_path=self.db_path,
            cwd=self.project,
            current_thread_id=self.current_id,
            status="in-progress",
            work_title="  Codex   session rename mode  ",
        )
        self.assertEqual(report["title"], "IN_PROGRESS - Codex session rename mode")

    def test_work_title_rejects_more_than_five_words_without_mutation(self) -> None:
        before = self.titles()
        with self.assertRaises(rename.RenameError) as caught:
            rename.rename_session(
                db_path=self.db_path,
                cwd=self.project,
                current_thread_id=self.current_id,
                status="done",
                work_title="Copy the opening conversation sentence fragment",
            )
        self.assertEqual(caught.exception.code, "work_title_too_long")
        self.assertEqual(caught.exception.details, {"word_count": 6, "max_words": 5})
        self.assertEqual(self.titles(), before)

    def test_missing_thread_fails_without_mutation(self) -> None:
        before = self.titles()
        with self.assertRaises(rename.RenameError) as caught:
            rename.rename_session(
                db_path=self.db_path,
                cwd=self.project,
                current_thread_id="00000000-0000-4000-8000-000000000099",
                status="done",
                work_title="Codex session rename mode",
            )
        self.assertEqual(caught.exception.code, "current_thread_not_found")
        self.assertEqual(self.titles(), before)

    def test_non_uuid_current_thread_is_rejected(self) -> None:
        before = self.titles()
        with self.assertRaises(rename.RenameError) as caught:
            rename.rename_session(
                db_path=self.db_path,
                cwd=self.project,
                current_thread_id="not-a-thread-id",
                status="done",
                work_title="Codex session rename mode",
            )
        self.assertEqual(caught.exception.code, "invalid_current_thread")
        self.assertEqual(self.titles(), before)

    def test_cli_uses_environment_thread_and_returns_json(self) -> None:
        stdout = io.StringIO()
        with mock.patch.dict(os.environ, {"CODEX_THREAD_ID": self.current_id}), contextlib.redirect_stdout(stdout):
            result = rename.run(
                [
                    "done",
                    "Codex session rename mode",
                    "--cwd",
                    str(self.project),
                    "--db",
                    str(self.db_path),
                    "--json",
                ]
            )
        payload = json.loads(stdout.getvalue())
        self.assertEqual(result, 0)
        self.assertTrue(payload["ok"])
        self.assertEqual(payload["title"], "DONE - Codex session rename mode")

    def test_environment_argument_conflict_is_rejected(self) -> None:
        stdout = io.StringIO()
        with mock.patch.dict(os.environ, {"CODEX_THREAD_ID": self.current_id}), contextlib.redirect_stdout(stdout):
            result = rename.run(
                [
                    "done",
                    "Codex session rename mode",
                    "--cwd",
                    str(self.project),
                    "--db",
                    str(self.db_path),
                    "--current-thread-id",
                    self.other_id,
                    "--json",
                ]
            )
        payload = json.loads(stdout.getvalue())
        self.assertEqual(result, 2)
        self.assertEqual(payload["error"], "current_thread_conflict")
        self.assertEqual(self.titles()[self.current_id], "Old current title")


class SessionNamingContractTests(unittest.TestCase):
    def test_contract_requires_latest_objective_and_forbids_truncation(self) -> None:
        skill = (ROOT / "skills" / "309-sg-tasks" / "SKILL.md").read_text(encoding="utf-8")
        playbook = (
            ROOT
            / "shipglows_data"
            / "workflow"
            / "playbooks"
            / "conversation-tracker-sync-playbook.md"
        ).read_text(encoding="utf-8")
        for text in (skill, playbook):
            self.assertIn("latest objective", text)
            self.assertIn("at most five words", text)
            self.assertIn("first-N-word extraction", text)

    def test_contract_rejects_missing_status_before_all_rename_work(self) -> None:
        skill = (ROOT / "skills" / "309-sg-tasks" / "SKILL.md").read_text(encoding="utf-8")
        playbook = (
            ROOT
            / "shipglows_data"
            / "workflow"
            / "playbooks"
            / "conversation-tracker-sync-playbook.md"
        ).read_text(encoding="utf-8")
        for text in (skill, playbook):
            normalized = " ".join(text.split())
            self.assertIn("CONVERSATION-RENAME-MISSING-STATUS", normalized)
            self.assertIn("ask for exactly one supported status", normalized)
            self.assertIn("do not derive a title, inspect sessions, call the helper, or mutate", normalized)


if __name__ == "__main__":
    unittest.main()
