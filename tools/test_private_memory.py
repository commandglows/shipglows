import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


TOOL = Path(__file__).with_name("private_memory.py")


class PrivateMemoryTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.store = self.root / "state" / "private-memory" / "locations.json"
        self.folder = self.root / "My Files"
        self.folder.mkdir()

    def tearDown(self):
        self.temp.cleanup()

    def run_tool(self, *args):
        environment = os.environ.copy()
        environment["SHIPGLOWS_RUNTIME_DIR"] = str(self.root / "state")
        return subprocess.run(
            [sys.executable, str(TOOL), "--store", str(self.store), "--format", "json", *args],
            text=True, capture_output=True, check=False, env=environment,
        )

    def remember(self, alias="mes fichiers", target=None, revision=0):
        return self.run_tool("remember", alias, str(target or self.folder),
                             "--expected-revision", str(revision), "--apply")

    def test_missing_store_has_empty_read_only_status(self):
        result = self.run_tool("status")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads(result.stdout)["revision"], 0)
        self.assertFalse(self.store.exists())

    def test_remember_path_defaults_to_dry_run(self):
        result = self.run_tool("remember", "mes fichiers", str(self.folder),
                               "--expected-revision", "0")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(json.loads(result.stdout)["dry_run"])
        self.assertFalse(self.store.exists())

    def test_remember_and_recall_directory_with_spaces(self):
        created = self.remember()
        self.assertEqual(created.returncode, 0, created.stderr)
        recalled = self.run_tool("recall", "MES FICHIERS")
        self.assertEqual(recalled.returncode, 0, recalled.stderr)
        item = json.loads(recalled.stdout)["item"]
        self.assertEqual(item["kind"], "directory")
        self.assertTrue(item["available"])
        self.assertEqual(Path(item["target"]), self.folder.resolve())

    def test_complete_url_is_private_and_preserved(self):
        url = "https://example.test/path?view=full#section"
        result = self.remember("reference", url)
        self.assertEqual(result.returncode, 0, result.stderr)
        recalled = self.run_tool("recall", "reference")
        self.assertEqual(json.loads(recalled.stdout)["item"]["target"], url)

    def test_url_credentials_are_rejected(self):
        result = self.remember("bad", "https://user:pass@example.test/path")
        self.assertEqual(result.returncode, 2)
        self.assertIn("credentials", result.stderr)

    def test_obvious_secret_query_parameters_are_rejected(self):
        for url in (
            "https://example.test/?token=value",
            "https://example.test/?api_key=value",
            "https://example.test/?refresh_token=value",
            "https://example.test/?client_secret=value",
            "https://example.test/?id_token=value",
            "https://example.test/?X-Amz-Credential=value&X-Amz-Signature=value",
            "https://example.test/callback#access_token=value",
        ):
            with self.subTest(url=url):
                result = self.remember("bad", url)
                self.assertEqual(result.returncode, 2)
                self.assertIn("authentication", result.stderr)

    def test_relative_path_is_rejected(self):
        result = self.remember("bad", "relative/folder")
        self.assertEqual(result.returncode, 2)
        self.assertIn("absolute", result.stderr)

    def test_store_cannot_escape_private_runtime_root(self):
        environment = os.environ.copy()
        environment["SHIPGLOWS_RUNTIME_DIR"] = str(self.root / "state")
        result = subprocess.run(
            [sys.executable, str(TOOL), "--store", str(self.root / "public.json"),
             "--format", "json", "status"],
            text=True, capture_output=True, check=False, env=environment,
        )
        self.assertEqual(result.returncode, 2)
        self.assertIn("SHIPGLOWS_RUNTIME_DIR", result.stderr)

    def test_duplicate_alias_is_case_insensitive(self):
        first = self.remember()
        revision = json.loads(first.stdout)["revision"]
        duplicate = self.remember("MES FICHIERS", self.folder, revision)
        self.assertEqual(duplicate.returncode, 2)
        self.assertIn("already exists", duplicate.stderr)

    def test_archive_and_restore_are_reversible(self):
        created = json.loads(self.remember().stdout)
        archived = self.run_tool("archive", "mes fichiers", "--expected-revision",
                                 str(created["revision"]), "--apply")
        self.assertEqual(archived.returncode, 0, archived.stderr)
        archived_data = json.loads(archived.stdout)
        missing = self.run_tool("recall", "mes fichiers")
        self.assertEqual(missing.returncode, 2)
        restored = self.run_tool("restore", "mes fichiers", "--expected-revision",
                                 str(archived_data["revision"]), "--apply")
        self.assertEqual(restored.returncode, 0, restored.stderr)
        self.assertEqual(self.run_tool("recall", "mes fichiers").returncode, 0)

    def test_stale_revision_refuses_write(self):
        self.remember()
        before = self.store.read_bytes()
        result = self.run_tool("remember", "other", str(self.folder),
                               "--expected-revision", "0", "--apply")
        self.assertEqual(result.returncode, 2)
        self.assertIn("stale", result.stderr)
        self.assertEqual(self.store.read_bytes(), before)

    def test_file_contents_are_never_ingested(self):
        source = self.root / "private.txt"
        source.write_text("DO-NOT-INGEST-CONTENT", encoding="utf-8")
        result = self.remember("private file", source)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn("DO-NOT-INGEST-CONTENT", self.store.read_text(encoding="utf-8"))
        self.assertEqual(json.loads(self.run_tool("recall", "private file").stdout)["item"]["kind"], "file")

    def test_search_is_bounded_and_private(self):
        first = json.loads(self.remember("documents", self.folder).stdout)
        second = self.run_tool("remember", "reference couleurs", "https://colors.test/tool",
                               "--tag", "design", "--expected-revision",
                               str(first["revision"]), "--apply")
        self.assertEqual(second.returncode, 0, second.stderr)
        result = self.run_tool("search", "couleurs")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads(result.stdout)["count"], 1)


if __name__ == "__main__":
    unittest.main()
