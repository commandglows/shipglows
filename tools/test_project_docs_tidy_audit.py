#!/usr/bin/env python3
"""Focused tests for the sg-docs tidy inventory."""

from datetime import date
from pathlib import Path
from tempfile import TemporaryDirectory
import unittest

from tools.project_docs_tidy_audit import audit_project


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
            })
            self.assertEqual(payload["trackers"]["TASKS.md"]["open_rows"], 1)
            self.assertEqual(payload["trackers"]["TASKS.md"]["done_rows"], 1)

    def test_project_without_workflow(self) -> None:
        with TemporaryDirectory() as temporary:
            self.assertEqual(audit_project(Path(temporary))["status"], "no-workflow")


if __name__ == "__main__":
    unittest.main()
