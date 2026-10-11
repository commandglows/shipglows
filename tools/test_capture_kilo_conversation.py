from __future__ import annotations

import importlib.util
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "skills" / "800-tmux-capture-conversation" / "scripts" / "capture_kilo_conversation.py"
SPEC = importlib.util.spec_from_file_location("capture_kilo_conversation", SCRIPT)
assert SPEC and SPEC.loader
capture = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = capture
SPEC.loader.exec_module(capture)


class KiloCaptureTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name) / "project"
        self.root.mkdir()
        subprocess.run(["git", "init", "-q", str(self.root)], check=True)
        self.session_id = "ses_12345678ABCDEFGH"

    def tearDown(self) -> None:
        self.temp.cleanup()

    def payload(self) -> dict:
        return {
            "info": {
                "id": self.session_id,
                "directory": str(self.root),
                "time": {"created": 1_700_000_000_000},
            },
            "messages": [
                {"info": {"role": "user"}, "parts": [
                    {"type": "text", "text": "Bonjour **Kilo**\nligne 2"},
                    {"type": "file", "text": "SECRET-FILE"},
                    {"type": "text", "text": "synthetic", "synthetic": True},
                ]},
                {"info": {"role": "assistant"}, "parts": [
                    {"type": "reasoning", "text": "SECRET-REASONING"},
                    {"type": "tool", "state": {"output": "SECRET-TOOL"}},
                    {"type": "text", "text": "Réponse exacte."},
                ]},
            ],
        }

    def write_payload(self, payload: dict | None = None) -> Path:
        path = Path(self.temp.name) / "export.json"
        path.write_text(json.dumps(payload or self.payload()), encoding="utf-8")
        return path

    def invoke(self, *extra: str) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [
                "python", str(SCRIPT), "--session-id", self.session_id,
                "--directory", str(self.root), "--worktree", str(self.root),
                "--export-file", str(self.write_payload()), *extra,
            ],
            check=False, capture_output=True, text=True, encoding="utf-8",
        )

    def test_writes_only_visible_non_synthetic_text(self) -> None:
        result = self.invoke()
        self.assertEqual(result.returncode, 0, result.stderr)
        destination = next((self.root / "shipglows_data" / "workflow" / "conversations").glob("*.md"))
        content = destination.read_text(encoding="utf-8")
        self.assertIn("Bonjour **Kilo**\nligne 2", content)
        self.assertIn("Réponse exacte.", content)
        for excluded in ("SECRET-FILE", "SECRET-REASONING", "SECRET-TOOL", "synthetic"):
            self.assertNotIn(excluded, content)

    def test_dry_run_does_not_write_or_print_content(self) -> None:
        result = self.invoke("--dry-run")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Messages: 2", result.stdout)
        self.assertNotIn("Bonjour", result.stdout)
        self.assertFalse((self.root / "shipglows_data").exists())

    def test_rejects_mismatched_session(self) -> None:
        payload = self.payload()
        payload["info"]["id"] = "ses_DIFFERENT123456"
        fixture = self.write_payload(payload)
        result = subprocess.run(
            ["python", str(SCRIPT), "--session-id", self.session_id, "--directory", str(self.root),
             "--worktree", str(self.root), "--export-file", str(fixture)],
            check=False, capture_output=True, text=True, encoding="utf-8",
        )
        self.assertEqual(result.returncode, 2)
        self.assertFalse((self.root / "shipglows_data").exists())

    def test_rejects_export_directory_outside_worktree(self) -> None:
        outside = Path(self.temp.name) / "outside"
        outside.mkdir()
        payload = self.payload()
        payload["info"]["directory"] = str(outside)
        fixture = self.write_payload(payload)
        result = subprocess.run(
            ["python", str(SCRIPT), "--session-id", self.session_id, "--directory", str(self.root),
             "--worktree", str(self.root), "--export-file", str(fixture)],
            check=False, capture_output=True, text=True, encoding="utf-8",
        )
        self.assertEqual(result.returncode, 2)
        self.assertFalse((self.root / "shipglows_data").exists())

    def test_rejects_unknown_visible_text_shape(self) -> None:
        payload = self.payload()
        payload["messages"][0]["parts"] = [{"type": "text", "text": 42}]
        with self.assertRaises(capture.CaptureError):
            capture.parse_export(payload, self.session_id)


if __name__ == "__main__":
    unittest.main()
