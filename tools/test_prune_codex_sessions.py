from __future__ import annotations

import contextlib
import io
import json
import os
import sqlite3
import subprocess
import tempfile
import unittest
from datetime import datetime, timedelta, timezone
from pathlib import Path
from unittest import mock

from tools import prune_codex_sessions as prune


UTC = timezone.utc


@contextlib.contextmanager
def closing_connection(path: Path):
    connection = sqlite3.connect(path)
    try:
        with connection:
            yield connection
    finally:
        connection.close()


class SessionPruneTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.codex_home = self.root / "codex"
        self.codex_home.mkdir()
        self.sqlite_home = self.root / "sqlite"
        self.sqlite_home.mkdir()
        self.db_path = self.sqlite_home / "state_5.sqlite"
        self.project = (self.root / "project").resolve()
        self.other_project = (self.root / "other-project").resolve()
        self.project.mkdir()
        self.other_project.mkdir()
        self.now = datetime(2026, 7, 16, 12, 0, tzinfo=UTC)
        self.sequence = 0
        with closing_connection(self.db_path) as connection:
            connection.executescript(
                """
                CREATE TABLE threads (
                    id TEXT PRIMARY KEY,
                    rollout_path TEXT NOT NULL,
                    created_at INTEGER NOT NULL,
                    updated_at INTEGER NOT NULL,
                    cwd TEXT NOT NULL,
                    title TEXT NOT NULL,
                    recency_at INTEGER NOT NULL DEFAULT 0,
                    updated_at_ms INTEGER,
                    recency_at_ms INTEGER NOT NULL DEFAULT 0
                );
                CREATE TABLE thread_spawn_edges (
                    parent_thread_id TEXT NOT NULL,
                    child_thread_id TEXT NOT NULL PRIMARY KEY,
                    status TEXT NOT NULL
                );
                CREATE TABLE agent_jobs (
                    id TEXT PRIMARY KEY,
                    status TEXT NOT NULL
                );
                CREATE TABLE agent_job_items (
                    job_id TEXT NOT NULL,
                    item_id TEXT NOT NULL,
                    status TEXT NOT NULL,
                    assigned_thread_id TEXT,
                    PRIMARY KEY (job_id, item_id)
                );
                CREATE TABLE thread_dynamic_tools (
                    thread_id TEXT NOT NULL,
                    position INTEGER NOT NULL,
                    PRIMARY KEY (thread_id, position)
                );
                CREATE TABLE unrelated (id TEXT PRIMARY KEY, value TEXT NOT NULL);
                INSERT INTO unrelated VALUES ('keep', 'unchanged');
                """
            )
        self.current_id, self.current_rollout = self.add_thread(
            title="DOING - current thread", age=timedelta()
        )

    def new_id(self) -> str:
        self.sequence += 1
        return f"00000000-0000-4000-8000-{self.sequence:012d}"

    def add_thread(
        self,
        *,
        thread_id: str | None = None,
        title: str = "DONE - completed work",
        cwd: Path | None = None,
        age: timedelta = timedelta(days=31),
    ) -> tuple[str, Path]:
        thread_id = thread_id or self.new_id()
        rollout = self.codex_home / "sessions" / f"{thread_id}.jsonl"
        rollout.parent.mkdir(parents=True, exist_ok=True)
        rollout.write_bytes(thread_id.encode())
        timestamp = int((self.now - age).timestamp())
        with closing_connection(self.db_path) as connection:
            connection.execute(
                "INSERT INTO threads VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
                (
                    thread_id,
                    str(rollout),
                    timestamp - 10,
                    timestamp,
                    str(cwd or self.project),
                    title,
                    timestamp,
                    timestamp * 1000,
                    timestamp * 1000,
                ),
            )
        return thread_id, rollout

    def add_edge(self, parent: str, child: str, status: str = "closed") -> None:
        with closing_connection(self.db_path) as connection:
            connection.execute("INSERT INTO thread_spawn_edges VALUES (?, ?, ?)", (parent, child, status))

    def assign_work(self, thread_id: str, *, job_status: str, item_status: str) -> None:
        job_id = f"job-{thread_id}"
        with closing_connection(self.db_path) as connection:
            connection.execute("INSERT INTO agent_jobs VALUES (?, ?)", (job_id, job_status))
            connection.execute(
                "INSERT INTO agent_job_items VALUES (?, 'item', ?, ?)",
                (job_id, item_status, thread_id),
            )

    def options(self, **overrides: object) -> prune.PruneOptions:
        values: dict[str, object] = {
            "cwd": self.project,
            "db_path": self.db_path,
            "codex_home": self.codex_home,
            "older_than_days": 30,
            "current_thread_id": self.current_id,
            "current_thread_source": "library",
            "apply": False,
            "confirm_cwd": None,
            "now": self.now,
            "codex_executable": "fake-codex",
        }
        values.update(overrides)
        return prune.PruneOptions(**values)

    def create_auxiliary_db(self, filename: str, table: str) -> Path:
        path = self.sqlite_home / filename
        with closing_connection(path) as connection:
            connection.execute(f"CREATE TABLE {table} (thread_id TEXT NOT NULL, value TEXT NOT NULL)")
        return path

    def add_auxiliary_row(self, path: Path, table: str, thread_id: str) -> None:
        with closing_connection(path) as connection:
            connection.execute(f"INSERT INTO {table} VALUES (?, 'payload')", (thread_id,))

    def table(self, name: str) -> list[tuple[object, ...]]:
        with closing_connection(self.db_path) as connection:
            return connection.execute(f"SELECT * FROM {name} ORDER BY 1, 2").fetchall()

    def fake_codex(self, calls: list[list[str]], *, mutate: bool = True, returncode: int = 0):
        def run(command: list[str], **kwargs: object) -> subprocess.CompletedProcess[str]:
            calls.append(command)
            self.assertEqual(kwargs["env"]["CODEX_HOME"], str(self.codex_home))  # type: ignore[index]
            self.assertEqual(kwargs["env"]["CODEX_SQLITE_HOME"], str(self.db_path.parent))  # type: ignore[index]
            if mutate and returncode == 0:
                root_id = command[-1]
                with closing_connection(self.db_path) as connection:
                    closure = {root_id}
                    while True:
                        children = {
                            row[0]
                            for row in connection.execute(
                                "SELECT child_thread_id FROM thread_spawn_edges WHERE parent_thread_id IN (%s)"
                                % ",".join("?" * len(closure)),
                                tuple(closure),
                            )
                        }
                        if children <= closure:
                            break
                        closure.update(children)
                    placeholders = ",".join("?" * len(closure))
                    paths = [
                        Path(row[0])
                        for row in connection.execute(
                            f"SELECT rollout_path FROM threads WHERE id IN ({placeholders})", tuple(closure)
                        )
                    ]
                    connection.execute(
                        "DELETE FROM thread_spawn_edges "
                        f"WHERE parent_thread_id IN ({placeholders}) "
                        f"OR child_thread_id IN ({placeholders})",
                        tuple(closure) + tuple(closure),
                    )
                    connection.execute(
                        f"DELETE FROM thread_dynamic_tools WHERE thread_id IN ({placeholders})", tuple(closure)
                    )
                    connection.execute(
                        f"DELETE FROM agent_job_items WHERE assigned_thread_id IN ({placeholders})", tuple(closure)
                    )
                    connection.execute(f"DELETE FROM threads WHERE id IN ({placeholders})", tuple(closure))
                for path in paths:
                    path.unlink(missing_ok=True)
                    Path(str(path) + ".zst").unlink(missing_ok=True)
                for filename, table in (
                    ("logs_2.sqlite", "logs"),
                    ("memories_1.sqlite", "stage1_outputs"),
                    ("goals_1.sqlite", "thread_goals"),
                ):
                    auxiliary = self.sqlite_home / filename
                    if auxiliary.exists():
                        with closing_connection(auxiliary) as connection:
                            if connection.execute(
                                "SELECT 1 FROM sqlite_master WHERE type='table' AND name=?", (table,)
                            ).fetchone():
                                connection.execute(
                                    f"DELETE FROM {table} WHERE thread_id IN ({placeholders})", tuple(closure)
                                )
            return subprocess.CompletedProcess(command, returncode, "", "native failure" if returncode else "")

        return run

    def test_dry_run_is_exact_cwd_done_strict_age_and_mutation_free(self) -> None:
        eligible, rollout = self.add_thread(age=timedelta(days=30, seconds=1))
        other, _ = self.add_thread(cwd=self.other_project)
        open_id, _ = self.add_thread(title="DOING - active")
        boundary, _ = self.add_thread(age=timedelta(days=30))
        current, current_rollout = self.add_thread()
        rows_before = self.table("threads")
        calls: list[list[str]] = []

        report = prune.prune_sessions(
            self.options(current_thread_id=current), runner=self.fake_codex(calls)
        )

        self.assertEqual(report["mode"], "dry-run")
        self.assertEqual(report["eligible_ids"], [eligible])
        self.assertEqual(report["selected_root_ids"], [eligible])
        self.assertEqual(report["excluded_current_count"], 1)
        self.assertEqual(report["threshold_days"], 30)
        self.assertGreater(report["rollout_bytes"], 0)
        self.assertEqual(calls, [])
        self.assertEqual(rows_before, self.table("threads"))
        self.assertTrue(rollout.exists())
        self.assertTrue(current_rollout.exists())
        self.assertNotIn(other, report["eligible_ids"])
        self.assertNotIn(open_id, report["eligible_ids"])
        self.assertNotIn(boundary, report["eligible_ids"])

    def test_apply_requires_exact_confirmation_and_current_id_before_execution(self) -> None:
        thread_id, rollout = self.add_thread()
        calls: list[list[str]] = []
        for confirmation in (None, self.other_project, self.project / ".." / self.project.name):
            with self.subTest(confirmation=confirmation):
                with self.assertRaises(prune.PruneError) as caught:
                    prune.prune_sessions(
                        self.options(apply=True, confirm_cwd=confirmation), runner=self.fake_codex(calls)
                    )
                self.assertEqual(caught.exception.code, "cwd_confirmation_required")
        with self.assertRaises(prune.PruneError) as caught:
            prune.prune_sessions(
                self.options(apply=True, confirm_cwd=self.project, current_thread_id=None),
                runner=self.fake_codex(calls),
            )
        self.assertEqual(caught.exception.code, "current_thread_required")
        self.assertEqual(calls, [])
        self.assertTrue(rollout.exists())
        self.assertIn(thread_id, {row[0] for row in self.table("threads")})

    def test_apply_requires_canonical_state_db_and_aligns_native_homes(self) -> None:
        candidate, _ = self.add_thread()
        noncanonical = self.root / "custom.sqlite"
        with closing_connection(self.db_path) as source, closing_connection(noncanonical) as target:
            source.backup(target)
        dry_run = prune.prune_sessions(self.options(db_path=noncanonical, apply=False))
        self.assertIn(candidate, dry_run["selected_root_ids"])

        calls: list[list[str]] = []
        with self.assertRaises(prune.PruneError) as caught:
            prune.prune_sessions(
                self.options(db_path=noncanonical, apply=True, confirm_cwd=self.project),
                runner=self.fake_codex(calls),
            )
        self.assertEqual(caught.exception.code, "noncanonical_apply_database")
        self.assertEqual(calls, [])

        with mock.patch.dict(
            os.environ,
            {"CODEX_HOME": "/ambient/wrong", "CODEX_SQLITE_HOME": "/ambient/wrong-sqlite"},
        ):
            report = prune.prune_sessions(
                self.options(apply=True, confirm_cwd=self.project), runner=self.fake_codex(calls)
            )
        self.assertEqual(report["deleted_root_ids"], [candidate])

    def test_apply_validates_current_thread_provenance_uuid_and_presence(self) -> None:
        self.add_thread()
        calls: list[list[str]] = []
        cases = (
            ({"current_thread_source": None}, "current_thread_provenance_required"),
            ({"current_thread_id": "NOT-A-UUID"}, "invalid_current_thread_id"),
            ({"current_thread_id": self.new_id()}, "current_thread_not_found"),
        )
        for overrides, code in cases:
            with self.subTest(code=code):
                with self.assertRaises(prune.PruneError) as caught:
                    prune.prune_sessions(
                        self.options(apply=True, confirm_cwd=self.project, **overrides),
                        runner=self.fake_codex(calls),
                    )
                self.assertEqual(caught.exception.code, code)
        self.assertEqual(calls, [])

    def test_environment_current_thread_wins_and_cli_conflict_is_rejected(self) -> None:
        cli_id, _ = self.add_thread(title="DOING - cli current", age=timedelta())
        stdout = io.StringIO()
        with mock.patch.dict(os.environ, {"CODEX_THREAD_ID": self.current_id}), contextlib.redirect_stdout(stdout):
            code = prune.run([
                str(self.project),
                "--apply",
                "--confirm-cwd",
                str(self.project),
                "--current-thread-id",
                cli_id,
                "--db",
                str(self.db_path),
                "--codex-home",
                str(self.codex_home),
                "--json",
            ])
        payload = json.loads(stdout.getvalue())
        self.assertEqual(code, 2)
        self.assertEqual(payload["error"], "current_thread_conflict")

    def test_rejects_root_for_unsafe_descendant_or_open_edge(self) -> None:
        roots: dict[str, str] = {}
        root, _ = self.add_thread()
        child, _ = self.add_thread(cwd=self.other_project)
        self.add_edge(root, child)
        roots[root] = "descendant_cwd_mismatch"

        root, _ = self.add_thread()
        child, _ = self.add_thread(title="DOING - child")
        self.add_edge(root, child)
        roots[root] = "descendant_not_eligible"

        current, _ = self.add_thread()
        root, _ = self.add_thread()
        self.add_edge(root, current)
        roots[root] = "current_thread_in_closure"

        root, _ = self.add_thread()
        child, _ = self.add_thread()
        self.add_edge(root, child, status="running")
        roots[root] = "open_spawn_edge"

        root, _ = self.add_thread()
        child, _ = self.add_thread()
        self.add_edge(root, child, status="future-unknown")
        roots[root] = "open_spawn_edge"

        report = prune.prune_sessions(self.options(current_thread_id=current))
        rejected = {item["id"]: item["reason"] for item in report["rejected"]}

        for root_id, reason in roots.items():
            self.assertEqual(rejected[root_id], reason)
            self.assertNotIn(root_id, report["selected_root_ids"])

    def test_rejects_root_with_active_agent_work_but_allows_terminal_work(self) -> None:
        active_root, _ = self.add_thread()
        active_child, _ = self.add_thread()
        self.add_edge(active_root, active_child)
        self.assign_work(active_child, job_status="running", item_status="pending")
        terminal_root, _ = self.add_thread()
        self.assign_work(terminal_root, job_status="completed", item_status="completed")

        report = prune.prune_sessions(self.options())
        rejected = {item["id"]: item["reason"] for item in report["rejected"]}

        self.assertEqual(rejected[active_root], "active_agent_work")
        self.assertIn(terminal_root, report["selected_root_ids"])

    def test_unknown_or_cross_domain_statuses_fail_closed(self) -> None:
        edge_root, _ = self.add_thread()
        edge_child, _ = self.add_thread()
        self.add_edge(edge_root, edge_child, status="completed")

        job_root, _ = self.add_thread()
        self.assign_work(job_root, job_status="done", item_status="completed")

        item_root, _ = self.add_thread()
        self.assign_work(item_root, job_status="completed", item_status="closed")

        report = prune.prune_sessions(self.options())
        rejected = {item["id"]: item["reason"] for item in report["rejected"]}

        self.assertEqual(rejected[edge_root], "open_spawn_edge")
        self.assertEqual(rejected[job_root], "active_agent_work")
        self.assertEqual(rejected[item_root], "active_agent_work")

    def test_collapses_selected_descendants_and_executes_native_delete_once(self) -> None:
        root_id, root_rollout = self.add_thread()
        child_id, child_rollout = self.add_thread()
        self.add_edge(root_id, child_id, status="closed")
        calls: list[list[str]] = []

        report = prune.prune_sessions(
            self.options(apply=True, confirm_cwd=self.project), runner=self.fake_codex(calls)
        )

        self.assertEqual(report["selected_root_ids"], [root_id])
        self.assertEqual(report["collapsed_ids"], [child_id])
        self.assertEqual(report["deleted_root_ids"], [root_id])
        self.assertEqual(calls, [["fake-codex", "delete", "--force", root_id]])
        self.assertFalse(root_rollout.exists())
        self.assertFalse(child_rollout.exists())
        self.assertEqual([row[0] for row in self.table("threads")], [self.current_id])
        self.assertEqual(self.table("unrelated"), [("keep", "unchanged")])

    def test_verifies_compressed_auxiliary_and_main_cleanup_with_unrelated_preservation(self) -> None:
        root_id, rollout = self.add_thread()
        compressed = Path(str(rollout) + ".zst")
        compressed.write_bytes(b"compressed")
        unrelated_id, unrelated_rollout = self.add_thread(cwd=self.other_project)
        with closing_connection(self.db_path) as connection:
            connection.execute("INSERT INTO thread_dynamic_tools VALUES (?, 0)", (root_id,))
            connection.execute("INSERT INTO thread_dynamic_tools VALUES (?, 0)", (unrelated_id,))
        self.assign_work(root_id, job_status="completed", item_status="completed")
        self.assign_work(unrelated_id, job_status="completed", item_status="completed")
        auxiliary = (
            (self.create_auxiliary_db("logs_2.sqlite", "logs"), "logs"),
            (self.create_auxiliary_db("memories_1.sqlite", "stage1_outputs"), "stage1_outputs"),
            (self.create_auxiliary_db("goals_1.sqlite", "thread_goals"), "thread_goals"),
        )
        for path, table in auxiliary:
            self.add_auxiliary_row(path, table, root_id)
            self.add_auxiliary_row(path, table, unrelated_id)
        calls: list[list[str]] = []

        report = prune.prune_sessions(
            self.options(apply=True, confirm_cwd=self.project), runner=self.fake_codex(calls)
        )

        self.assertEqual(report["affected_thread_ids"], [root_id])
        self.assertFalse(rollout.exists())
        self.assertFalse(compressed.exists())
        self.assertTrue(unrelated_rollout.exists())
        self.assertIn(unrelated_id, {row[0] for row in self.table("threads")})
        self.assertEqual(
            {row[0] for row in self.table("thread_dynamic_tools")}, {unrelated_id}
        )
        self.assertEqual(
            {row[3] for row in self.table("agent_job_items")}, {unrelated_id}
        )
        for path, table in auxiliary:
            with closing_connection(path) as connection:
                self.assertEqual(
                    connection.execute(f"SELECT thread_id FROM {table}").fetchall(),
                    [(unrelated_id,)],
                )

    def test_post_delete_verification_detects_unrelated_thread_removal(self) -> None:
        root_id, _ = self.add_thread()
        unrelated_id, _ = self.add_thread(cwd=self.other_project)
        calls: list[list[str]] = []
        native = self.fake_codex(calls)

        def overdelete(command: list[str], **kwargs: object) -> subprocess.CompletedProcess[str]:
            completed = native(command, **kwargs)
            with closing_connection(self.db_path) as connection:
                connection.execute("DELETE FROM threads WHERE id = ?", (unrelated_id,))
            return completed

        with self.assertRaises(prune.PruneError) as caught:
            prune.prune_sessions(
                self.options(apply=True, confirm_cwd=self.project), runner=overdelete
            )
        self.assertEqual(caught.exception.code, "post_delete_verification_failed")
        self.assertEqual(caught.exception.details["failed_root_id"], root_id)
        self.assertIn(unrelated_id, caught.exception.details["missing_preserved_thread_ids"])

    def test_native_failure_and_post_delete_verification_failure_are_reported(self) -> None:
        thread_id, rollout = self.add_thread()
        calls: list[list[str]] = []
        with self.assertRaises(prune.PruneError) as caught:
            prune.prune_sessions(
                self.options(apply=True, confirm_cwd=self.project),
                runner=self.fake_codex(calls, mutate=False, returncode=2),
            )
        self.assertEqual(caught.exception.code, "native_delete_failed")
        self.assertEqual(caught.exception.details["failed_root_id"], thread_id)
        self.assertEqual(caught.exception.details["deleted_root_ids"], [])
        self.assertEqual(caught.exception.details["native_success_unverified_root_ids"], [])
        self.assertEqual(caught.exception.details["unattempted_root_ids"], [])
        self.assertTrue(rollout.exists())

        calls.clear()
        with self.assertRaises(prune.PruneError) as caught:
            prune.prune_sessions(
                self.options(apply=True, confirm_cwd=self.project),
                runner=self.fake_codex(calls, mutate=False),
            )
        self.assertEqual(caught.exception.code, "post_delete_verification_failed")
        self.assertEqual(caught.exception.details["failed_root_id"], thread_id)
        self.assertEqual(caught.exception.details["deleted_root_ids"], [])
        self.assertEqual(caught.exception.details["native_success_unverified_root_ids"], [thread_id])
        self.assertEqual(caught.exception.details["unattempted_root_ids"], [])
        self.assertIn(thread_id, {row[0] for row in self.table("threads")})

    def test_multi_root_failure_reports_verified_and_unattempted_roots(self) -> None:
        first_id, _ = self.add_thread()
        failed_id, _ = self.add_thread()
        last_id, _ = self.add_thread()
        calls: list[list[str]] = []
        native = self.fake_codex(calls)

        def fail_second(command: list[str], **kwargs: object) -> subprocess.CompletedProcess[str]:
            if command[-1] == failed_id:
                calls.append(command)
                return subprocess.CompletedProcess(command, 3, "", "failed")
            return native(command, **kwargs)

        with self.assertRaises(prune.PruneError) as caught:
            prune.prune_sessions(
                self.options(apply=True, confirm_cwd=self.project), runner=fail_second
            )
        self.assertEqual(caught.exception.details["failed_root_id"], failed_id)
        self.assertEqual(caught.exception.details["deleted_root_ids"], [first_id])
        self.assertEqual(caught.exception.details["native_success_unverified_root_ids"], [])
        self.assertEqual(caught.exception.details["unattempted_root_ids"], [last_id])

    def test_second_apply_is_empty_no_op(self) -> None:
        thread_id, _ = self.add_thread()
        calls: list[list[str]] = []
        options = self.options(apply=True, confirm_cwd=self.project)

        first = prune.prune_sessions(options, runner=self.fake_codex(calls))
        second = prune.prune_sessions(options, runner=self.fake_codex(calls))

        self.assertEqual(first["deleted_root_ids"], [thread_id])
        self.assertEqual(second["selected_root_ids"], [])
        self.assertEqual(second["deleted_root_ids"], [])
        self.assertEqual(len(calls), 1)

    def test_json_cli_uses_environment_current_thread(self) -> None:
        current, _ = self.add_thread()
        candidate, _ = self.add_thread()
        stdout = io.StringIO()
        with mock.patch.dict(os.environ, {"CODEX_THREAD_ID": current}), contextlib.redirect_stdout(stdout):
            code = prune.run([
                str(self.project), "--db", str(self.db_path), "--codex-home", str(self.codex_home), "--json"
            ])

        payload = json.loads(stdout.getvalue())
        self.assertEqual(code, 0)
        self.assertEqual(payload["selected_root_ids"], [candidate])
        self.assertEqual(payload["excluded_current_count"], 1)

    def test_text_output_reports_unknown_rollouts_and_affected_ids(self) -> None:
        candidate, rollout = self.add_thread()
        rollout.unlink()
        report = prune.prune_sessions(self.options())
        stdout = io.StringIO()
        with contextlib.redirect_stdout(stdout):
            prune._print_text(report)
        rendered = stdout.getvalue()
        self.assertIn("unknown rollout count: 1", rendered)
        self.assertIn(candidate, report["unknown_rollout_ids"])
        self.assertIn(f"affected thread ids: {candidate}", rendered)


if __name__ == "__main__":
    unittest.main()
