from __future__ import annotations

import importlib.util
import json
import os
import subprocess
import sys
import tempfile
import unittest
from datetime import datetime, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "skills" / "800-tmux-capture-conversation" / "scripts" / "capture_codex_conversation.py"
SPEC = importlib.util.spec_from_file_location("capture_codex_conversation", SCRIPT)
assert SPEC and SPEC.loader
capture = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = capture
SPEC.loader.exec_module(capture)


class CaptureCodexConversationTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.project = self.root / "project"
        self.project.mkdir()
        subprocess.run(["git", "init", "--quiet", str(self.project)], check=True)
        self.codex_home = self.root / "codex"
        self.thread_id = "01a00d26-ec92-72d2-b9be-caf19030b0a1"
        self.journal = self.codex_home / "sessions" / "2026" / "08" / "18" / f"rollout-{self.thread_id}.jsonl"
        self.journal.parent.mkdir(parents=True)

    def records(self) -> list[dict]:
        return [
            {
                "type": "session_meta",
                "payload": {
                    "session_id": self.thread_id,
                    "timestamp": "2026-08-18T20:10:11Z",
                    "cwd": str(self.project / "nested"),
                },
            },
            {
                "type": "response_item",
                "payload": {
                    "type": "message",
                    "id": "dev-1",
                    "role": "developer",
                    "content": [{"type": "input_text", "text": "PRIVATE INTERNAL"}],
                },
            },
            {
                "type": "response_item",
                "payload": {
                    "type": "message",
                    "id": "user-1",
                    "role": "user",
                    "content": [{"type": "input_text", "text": "Héllo **Markdown**\nligne 2\n"}],
                },
            },
            {"type": "event_msg", "payload": {"type": "tool", "text": "SECRET TOOL"}},
            {
                "type": "response_item",
                "payload": {
                    "type": "message",
                    "id": "assistant-1",
                    "role": "assistant",
                    "content": [{"type": "output_text", "text": "Réponse `code`\n\nfin"}],
                },
            },
        ]

    def write_records(self, records: list[dict], tail: bytes = b"") -> None:
        (self.project / "nested").mkdir(exist_ok=True)
        with self.journal.open("wb") as stream:
            for record in records:
                stream.write(json.dumps(record, ensure_ascii=False).encode("utf-8") + b"\n")
            stream.write(tail)

    def invoke(self, *extra: str) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [
                os.fspath(Path(os.sys.executable)),
                os.fspath(SCRIPT),
                "--thread-id",
                self.thread_id,
                "--codex-home",
                os.fspath(self.codex_home),
                *extra,
            ],
            capture_output=True,
            text=True,
            encoding="utf-8",
        )

    def test_verbatim_visible_messages_and_internal_exclusion(self) -> None:
        records = self.records()
        records.append(records[2])  # duplicate journal record id must not duplicate output
        self.write_records(records, b'{"partial":')

        result = self.invoke()

        self.assertEqual(result.returncode, 0, result.stderr)
        output_dir = self.project / "shipglows_data" / "workflow" / "conversations"
        files = list(output_dir.glob("*.md"))
        self.assertEqual(len(files), 1)
        written = files[0].read_text(encoding="utf-8")
        self.assertIn("Héllo **Markdown**\nligne 2\n", written)
        self.assertIn("Réponse `code`\n\nfin", written)
        self.assertEqual(written.count("Héllo **Markdown**"), 1)
        self.assertLess(written.index("Héllo"), written.index("Réponse"))
        self.assertNotIn("PRIVATE INTERNAL", written)
        self.assertNotIn("SECRET TOOL", written)

    def test_dry_run_is_content_free_and_does_not_write(self) -> None:
        self.write_records(self.records())

        result = self.invoke("--dry-run")

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn(f"Project root: {self.project}", result.stdout)
        self.assertIn("Messages: 2", result.stdout)
        self.assertNotIn("Héllo", result.stdout)
        self.assertNotIn("Réponse", result.stdout)
        self.assertFalse((self.project / "shipglows_data").exists())

    def test_complete_malformed_line_fails_without_write(self) -> None:
        self.write_records(self.records(), b"not-json\n")

        result = self.invoke()

        self.assertEqual(result.returncode, 2)
        self.assertIn("complete line", result.stderr)
        self.assertFalse((self.project / "shipglows_data").exists())

    def test_collision_uses_numeric_suffix(self) -> None:
        self.write_records(self.records())

        first = self.invoke()
        second = self.invoke()

        self.assertEqual(first.returncode, 0, first.stderr)
        self.assertEqual(second.returncode, 0, second.stderr)
        names = sorted(path.name for path in (self.project / "shipglows_data" / "workflow" / "conversations").glob("*.md"))
        self.assertEqual(
            names,
            [
                "conversation-codex-20260818-201011-01a00d26-2.md",
                "conversation-codex-20260818-201011-01a00d26.md",
            ],
        )

    def test_missing_git_project_fails_closed(self) -> None:
        outside = self.root / "outside"
        outside.mkdir()
        records = self.records()
        records[0]["payload"]["cwd"] = str(outside)
        self.write_records(records)

        result = self.invoke()

        self.assertEqual(result.returncode, 2)
        self.assertIn("not inside a Git repository", result.stderr)

    def test_multiple_exact_journals_are_rejected(self) -> None:
        self.write_records(self.records())
        duplicate = self.codex_home / "sessions" / "duplicate" / f"other-{self.thread_id}.jsonl"
        duplicate.parent.mkdir()
        duplicate.write_text("{}\n", encoding="utf-8")

        result = self.invoke("--dry-run")

        self.assertEqual(result.returncode, 2)
        self.assertIn("found 2", result.stderr)

    def test_unknown_visible_content_fails_closed(self) -> None:
        records = self.records()
        records[2]["payload"]["content"].append({"type": "image", "url": "private"})
        self.write_records(records)

        result = self.invoke()

        self.assertEqual(result.returncode, 2)
        self.assertIn("unsupported visible message content", result.stderr)
        self.assertFalse((self.project / "shipglows_data").exists())

    def test_render_keeps_message_strings_unchanged(self) -> None:
        meta = capture.SessionMeta(
            self.thread_id,
            self.project,
            datetime(2026, 8, 18, tzinfo=timezone.utc),
        )
        values = ["", "a\r\nb", "```\nraw\n```", "final-no-newline"]
        rendered = capture.render_transcript(meta, [capture.Message("user", value) for value in values])
        cursor = 0
        for value in values:
            position = rendered.find(value, cursor)
            self.assertGreaterEqual(position, cursor)
            cursor = position + len(value)


if __name__ == "__main__":
    unittest.main()
