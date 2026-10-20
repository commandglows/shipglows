#!/usr/bin/env python3
"""Focused tests for the sg-docs tidy inventory."""

from datetime import date
from pathlib import Path
import subprocess
from tempfile import TemporaryDirectory
import unittest

from tools.project_docs_tidy_audit import audit_project, tidy_pressure


def _write(root: Path, relative: str, text: str = "") -> None:
    path = root / relative
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def _spec(updated: str, extra: str = "", body: str = "") -> str:
    return f'---\nstatus: ready\nupdated: "{updated}"\n{extra}---\n\n{body}'


class ProjectDocsTidyAuditTests(unittest.TestCase):
    def test_classifies_workflow_artifacts(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            wf = "shipglows_data/workflow"
            _write(root, f"{wf}/TASKS.md",
                   "📋 task: build | spec: specs/open-feature-spec.md\n"
                   "✅ task: old | status: done | spec: specs/tracked-done-spec.md\n")
            _write(root, f"{wf}/specs/open-feature-spec.md", _spec("2026-01-01"))
            _write(root, f"{wf}/specs/tracked-done-spec.md", _spec("2026-10-01"))
            _write(root, f"{wf}/specs/marked-closed-spec.md", _spec("2026-10-01", 'delivery: closed\n'))
            _write(root, f"{wf}/specs/history-shipped-spec.md", _spec(
                "2026-10-01", body="| 2026-10-01 | 005-sg-ship | m | ship | shipped | none |\n"))
            _write(root, f"{wf}/specs/replaced-old-spec.md", '---\nstatus: superseded\nupdated: "2026-10-01"\n---\n')
            _write(root, f"{wf}/specs/forgotten-idea-spec.md", _spec("2026-01-01"))
            _write(root, f"{wf}/specs/fresh-idea-spec.md", _spec("2026-10-15"))
            _write(root, f"{wf}/templates/spec-template.md", _spec("2020-01-01"))
            _write(root, f"{wf}/archives/2025/specs/archived-spec.md", _spec("2020-01-01"))
            payload = audit_project(root, dormant_days=90, today=date(2026, 10, 20))
            classes = {Path(item["path"]).stem: item["class"] for item in payload["items"]}
            self.assertEqual(classes, {
                "open-feature-spec": "open",
                "tracked-done-spec": "delivered",
                "marked-closed-spec": "delivered",
                "history-shipped-spec": "delivered",
                "replaced-old-spec": "retired",
                "forgotten-idea-spec": "dormant",
                "fresh-idea-spec": "recent",
                "archived-spec": "archived",
            })
            self.assertEqual(payload["trackers"]["TASKS.md"]["open_rows"], 1)
            self.assertEqual(payload["trackers"]["TASKS.md"]["done_rows"], 1)

    def test_active_bugs_are_open_and_test_read_items_are_pinned(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            subprocess.run(["git", "init", "-q", str(root)], check=True)
            wf = "shipglows_data/workflow"
            _write(root, f"{wf}/bugs/live-login-bug.md", '---\nbug_status: "fix-attempted"\nupdated: "2026-01-01"\n---\n')
            _write(root, f"{wf}/bugs/closed-login-bug.md", '---\nbug_status: "closed"\nupdated: "2026-01-01"\n---\n')
            _write(root, f"{wf}/specs/frozen-by-test-spec.md", _spec("2026-01-01"))
            _write(root, "tools/test_example.py", "SPEC = 'frozen-by-test-spec.md'\n")
            subprocess.run(["git", "-C", str(root), "add", "-A"], check=True)
            payload = audit_project(root, dormant_days=90, today=date(2026, 10, 20))
            classes = {Path(item["path"]).stem: item["class"] for item in payload["items"]}
            self.assertEqual(classes["live-login-bug"], "open")
            self.assertEqual(classes["closed-login-bug"], "dormant")
            self.assertEqual(classes["frozen-by-test-spec"], "pinned")

    def test_tidy_pressure_fires_on_activity_not_time(self) -> None:
        light = {"totals": {"recent": {"files": 30, "bytes": 9000}, "delivered": {"files": 3, "bytes": 900}},
                 "trackers": {"TASKS.md": {"done_rows": 10}}}
        self.assertFalse(tidy_pressure(light)["due"])
        heavy = {"totals": {"recent": {"files": 10, "bytes": 1000}, "delivered": {"files": 8, "bytes": 5000}},
                 "trackers": {"TASKS.md": {"done_rows": 60}}}
        pressure = tidy_pressure(heavy)
        self.assertTrue(pressure["due"])
        self.assertEqual(len(pressure["reasons"]), 2)

    def test_project_without_workflow(self) -> None:
        with TemporaryDirectory() as temporary:
            self.assertEqual(audit_project(Path(temporary))["status"], "no-workflow")


if __name__ == "__main__":
    unittest.main()
