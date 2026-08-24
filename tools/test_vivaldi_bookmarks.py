import hashlib
import importlib.util
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch

TOOL = Path(__file__).with_name("vivaldi_bookmarks.py")
SPEC = importlib.util.spec_from_file_location("vivaldi_bookmarks", TOOL)
BRIDGE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
SPEC.loader.exec_module(BRIDGE)


def fixture_checksum(payload):
    digest = hashlib.md5()

    def walk(node):
        digest.update(node["id"].encode())
        digest.update(node["name"].encode("utf-16-le"))
        digest.update(node["type"].encode())
        if node["type"] == "url":
            digest.update(node["url"].encode())
        else:
            for child in node.get("children", []):
                walk(child)

    for key in ("bookmark_bar", "other", "synced", "trash"):
        walk(payload["roots"][key])
    return digest.hexdigest()


class VivaldiBookmarksTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.profile = self.root / "Vivaldi" / "User Data" / "Default"
        self.profile.mkdir(parents=True)
        self.bookmarks = self.profile / "Bookmarks"
        self.backups = self.root / "private-backups"

        def folder(node_id, guid, name, children=None):
            return {"id": node_id, "guid": guid, "type": "folder", "name": name,
                    "date_added": "1", "date_last_used": "0", "date_modified": "1",
                    "children": children or []}

        palette = {"id": "11", "guid": "00000000-0000-4000-8000-000000000011",
                   "type": "url", "name": "Palette Lab",
                   "url": "https://palette.example/tool?token=kept#section",
                   "date_added": "1", "date_last_used": "0"}
        payload = {"version": 1, "roots": {
            "bookmark_bar": folder("1", "00000000-0000-4000-8000-000000000001", "Bookmarks", [
                folder("10", "00000000-0000-4000-8000-000000000010", "Design", [palette])]),
            "other": folder("2", "00000000-0000-4000-8000-000000000002", "Other"),
            "synced": folder("3", "00000000-0000-4000-8000-000000000003", "Mobile"),
            "trash": folder("4", "00000000-0000-4000-8000-000000000004", "Trash")}}
        payload["checksum"] = fixture_checksum(payload)
        self.bookmarks.write_text(json.dumps(payload), encoding="utf-8")
        self.config = self.root / "config.json"
        self.config.write_text(json.dumps({"schema_version": 2,
            "source": {"label": "all-bookmarks", "bookmarks_file": str(self.bookmarks)},
            "scope": "all", "backup_dir": str(self.backups)}), encoding="utf-8")

    def tearDown(self):
        self.temp.cleanup()

    def run_tool(self, *args):
        return subprocess.run([sys.executable, str(TOOL), "--config", str(self.config), *args],
                              text=True, capture_output=True, check=False)

    def current(self):
        return json.loads(self.bookmarks.read_text(encoding="utf-8"))

    def checksum(self):
        return self.current()["checksum"]

    def test_list_covers_all_roots_and_preserves_complete_urls(self):
        result = self.run_tool("--format", "json", "list")
        self.assertEqual(result.returncode, 0, result.stderr)
        data = json.loads(result.stdout)
        self.assertEqual(data["count"], 1)
        self.assertEqual(data["items"][0]["url"],
                         "https://palette.example/tool?token=kept#section")
        self.assertEqual(data["items"][0]["root"], "bookmark_bar")
        self.assertIn("guid", data["items"][0])

    def test_status_exposes_checksum_but_no_urls(self):
        result = self.run_tool("--format", "json", "status")
        self.assertEqual(result.returncode, 0, result.stderr)
        data = json.loads(result.stdout)
        self.assertEqual(data["bookmarks"], 1)
        self.assertEqual(data["checksum"], self.checksum())
        self.assertNotIn("https://", result.stdout)

    def test_add_update_archive_and_restore_are_reversible(self):
        added = self.run_tool("--format", "json", "add-url", "--parent", "10",
            "--title", "New", "--url", "https://new.example/?x=1",
            "--expected-checksum", self.checksum(), "--apply")
        self.assertEqual(added.returncode, 0, added.stderr)
        added_data = json.loads(added.stdout)
        guid = added_data["node"]["guid"]
        self.assertTrue(self.backups.exists())
        updated = self.run_tool("--format", "json", "update", "--node", guid,
            "--title", "Updated", "--url", "https://updated.example/?full=yes#kept",
            "--expected-checksum", added_data["checksum"], "--apply")
        self.assertEqual(updated.returncode, 0, updated.stderr)
        updated_data = json.loads(updated.stdout)
        moved = self.run_tool("--format", "json", "move", "--node", guid,
            "--parent", "2", "--expected-checksum", updated_data["checksum"], "--apply")
        self.assertEqual(moved.returncode, 0, moved.stderr)
        moved_data = json.loads(moved.stdout)
        self.assertEqual(self.current()["roots"]["other"]["children"][0]["url"],
                         "https://updated.example/?full=yes#kept")
        archived = self.run_tool("--format", "json", "archive", "--node", guid,
            "--expected-checksum", moved_data["checksum"], "--apply")
        self.assertEqual(archived.returncode, 0, archived.stderr)
        archived_data = json.loads(archived.stdout)
        self.assertEqual(self.current()["roots"]["trash"]["children"][0]["name"], "Updated")
        restored = self.run_tool("--format", "json", "restore", "--node", guid,
            "--parent", "10", "--expected-checksum", archived_data["checksum"], "--apply")
        self.assertEqual(restored.returncode, 0, restored.stderr)
        self.assertEqual(self.current()["roots"]["trash"]["children"], [])

    def test_dry_run_does_not_write_or_backup(self):
        before = self.bookmarks.read_bytes()
        result = self.run_tool("--format", "json", "add-folder", "--parent", "1",
            "--title", "Planned", "--expected-checksum", self.checksum())
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(json.loads(result.stdout)["dry_run"])
        self.assertEqual(self.bookmarks.read_bytes(), before)
        self.assertFalse(self.backups.exists())

    def test_stale_checksum_refuses_write(self):
        before = self.bookmarks.read_bytes()
        result = self.run_tool("add-folder", "--parent", "1", "--title", "Nope",
            "--expected-checksum", "0" * 32, "--apply")
        self.assertEqual(result.returncode, 2)
        self.assertIn("stale", result.stderr)
        self.assertEqual(self.bookmarks.read_bytes(), before)

    def test_running_vivaldi_refuses_live_profile_write(self):
        before = self.bookmarks.read_bytes()
        args = SimpleNamespace(command="add-folder", parent="1", title="Nope", index=None,
                               expected_checksum=self.checksum(), apply=True)
        config = BRIDGE.load_config(self.config)
        payload, original = BRIDGE.read_stable_snapshot(self.bookmarks)
        with patch.object(BRIDGE, "is_live_profile", return_value=True):
            with self.assertRaisesRegex(BRIDGE.BridgeError, "Vivaldi is running"):
                BRIDGE.execute_mutation(config, payload, original, args,
                                        running_check=lambda: True)
        self.assertEqual(self.bookmarks.read_bytes(), before)
        self.assertFalse(self.backups.exists())

    def test_move_rejects_folder_cycle(self):
        result = self.run_tool("move", "--node", "10", "--parent", "10",
            "--expected-checksum", self.checksum(), "--apply")
        self.assertEqual(result.returncode, 2)
        self.assertIn("inside itself", result.stderr)

    def test_invalid_stored_checksum_refuses_mutation(self):
        payload = self.current()
        payload["checksum"] = "f" * 32
        self.bookmarks.write_text(json.dumps(payload), encoding="utf-8")
        result = self.run_tool("add-folder", "--parent", "1", "--title", "Nope",
            "--expected-checksum", "f" * 32, "--apply")
        self.assertEqual(result.returncode, 2)
        self.assertIn("checksum", result.stderr)

    def test_malformed_json_fails_cleanly(self):
        self.bookmarks.write_text("{broken", encoding="utf-8")
        result = self.run_tool("status")
        self.assertEqual(result.returncode, 2)
        self.assertIn("valid JSON", result.stderr)
        self.assertNotIn("Traceback", result.stderr)

    def test_oversized_source_is_rejected_before_parsing(self):
        with self.bookmarks.open("wb") as handle:
            handle.seek((32 * 1024 * 1024) + 1)
            handle.write(b"0")
        result = self.run_tool("status")
        self.assertEqual(result.returncode, 2)
        self.assertIn("safe size limit", result.stderr)

    def test_unstable_source_fails_after_one_retry(self):
        class UnstableSource:
            def __init__(self): self.calls = 0
            def stat(self):
                self.calls += 1
                return SimpleNamespace(st_size=2, st_mtime_ns=self.calls)
            def read_bytes(self): return b"{}"
        with self.assertRaisesRegex(BRIDGE.BridgeError, "changed during reading"):
            BRIDGE.read_stable_snapshot(UnstableSource())


if __name__ == "__main__":
    unittest.main()
