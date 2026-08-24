import importlib.util
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace


TOOL = Path(__file__).with_name("vivaldi_bookmarks.py")
SPEC = importlib.util.spec_from_file_location("vivaldi_bookmarks", TOOL)
BRIDGE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
SPEC.loader.exec_module(BRIDGE)


class VivaldiBookmarksTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.profile = self.root / "Vivaldi" / "User Data" / "Default"
        self.profile.mkdir(parents=True)
        self.bookmarks = self.profile / "Bookmarks"
        payload = {
            "roots": {
                "bookmark_bar": {
                    "type": "folder",
                    "name": "Bookmarks",
                    "children": [
                        {
                            "type": "folder",
                            "name": "🎨 Design",
                            "children": [
                                {
                                    "type": "folder",
                                    "name": "Colors",
                                    "children": [
                                        {
                                            "type": "url",
                                            "name": "Palette Lab",
                                            "url": "https://user:pass@palette.example/tool?token=secret#section",
                                        },
                                        {
                                            "type": "url",
                                            "name": "Local note",
                                            "url": "file:///private/note.html",
                                        },
                                        {
                                            "type": "url",
                                            "name": "Palette Lab",
                                            "url": "https://palette.example/tool?another=tracking",
                                        },
                                    ],
                                },
                                {
                                    "type": "url",
                                    "name": "Typography",
                                    "url": "https://type.example/guide",
                                },
                            ],
                        },
                        {
                            "type": "folder",
                            "name": "Private",
                            "children": [
                                {
                                    "type": "url",
                                    "name": "Must not leak",
                                    "url": "https://private.example/secret",
                                }
                            ],
                        },
                    ],
                }
            }
        }
        self.bookmarks.write_text(json.dumps(payload), encoding="utf-8")
        self.config = self.root / "config.json"
        self.config.write_text(
            json.dumps(
                {
                    "schema_version": 1,
                    "source": {
                        "label": "design-bookmarks",
                        "bookmarks_file": str(self.bookmarks),
                    },
                    "folders": [["bookmark_bar", "🎨 Design"]],
                }
            ),
            encoding="utf-8",
        )

    def tearDown(self):
        self.temp.cleanup()

    def run_tool(self, *args):
        return subprocess.run(
            [sys.executable, str(TOOL), "--config", str(self.config), *args],
            text=True,
            capture_output=True,
            check=False,
        )

    def test_list_is_scoped_and_skips_non_web_urls(self):
        result = self.run_tool("--format", "json", "list")
        self.assertEqual(result.returncode, 0, result.stderr)
        data = json.loads(result.stdout)
        self.assertEqual(data["count"], 2)
        self.assertEqual(data["skipped_unsupported_urls"], 1)
        self.assertEqual(data["duplicates_collapsed"], 1)
        self.assertEqual(
            [item["title"] for item in data["items"]],
            ["Typography", "Palette Lab"],
        )
        self.assertNotIn("private.example", result.stdout)
        self.assertNotIn("token=secret", result.stdout)
        self.assertNotIn("user:pass", result.stdout)

    def test_search_is_case_insensitive_and_bounded(self):
        result = self.run_tool("--format", "json", "--limit", "1", "search", "PALETTE")
        self.assertEqual(result.returncode, 0, result.stderr)
        data = json.loads(result.stdout)
        self.assertEqual(data["count"], 1)
        self.assertEqual(data["items"][0]["url"], "https://palette.example/tool")

    def test_status_contains_counts_but_no_urls(self):
        result = self.run_tool("--format", "json", "status")
        self.assertEqual(result.returncode, 0, result.stderr)
        data = json.loads(result.stdout)
        self.assertEqual(data["selected_bookmarks"], 2)
        self.assertNotIn("https://", result.stdout)

    def test_missing_selector_fails_without_unrelated_bookmark_data(self):
        config = json.loads(self.config.read_text(encoding="utf-8"))
        config["folders"] = [["bookmark_bar", "Missing"]]
        self.config.write_text(json.dumps(config), encoding="utf-8")
        result = self.run_tool("list")
        self.assertEqual(result.returncode, 2)
        self.assertIn("Missing", result.stderr)
        self.assertNotIn("private.example", result.stderr)

    def test_source_must_be_vivaldi_bookmarks_file(self):
        other = self.root / "Bookmarks"
        other.write_text("{}", encoding="utf-8")
        config = json.loads(self.config.read_text(encoding="utf-8"))
        config["source"]["bookmarks_file"] = str(other)
        self.config.write_text(json.dumps(config), encoding="utf-8")
        result = self.run_tool("status")
        self.assertEqual(result.returncode, 2)
        self.assertIn("Vivaldi profile", result.stderr)

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
        self.assertNotIn("Traceback", result.stderr)

    def test_unstable_source_fails_after_one_retry(self):
        class UnstableSource:
            def __init__(self):
                self.calls = 0

            def stat(self):
                self.calls += 1
                return SimpleNamespace(st_size=2, st_mtime_ns=self.calls)

            def read_bytes(self):
                return b"{}"

        with self.assertRaisesRegex(BRIDGE.BridgeError, "changed during reading"):
            BRIDGE.read_stable_bookmarks(UnstableSource())

    def test_duplicate_selectors_are_rejected(self):
        config = json.loads(self.config.read_text(encoding="utf-8"))
        config["folders"].append(config["folders"][0])
        self.config.write_text(json.dumps(config), encoding="utf-8")
        result = self.run_tool("status")
        self.assertEqual(result.returncode, 2)
        self.assertIn("must be unique", result.stderr)


if __name__ == "__main__":
    unittest.main()
