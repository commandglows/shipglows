"""Synthetic contract tests for the explicit private-data capability."""

from __future__ import annotations

import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
TOOL = ROOT / "cli" / "private_data.py"


class PrivateDataCapabilityTests(unittest.TestCase):
    def run_tool(self, root: Path, *args: str) -> subprocess.CompletedProcess[str]:
        environment = os.environ.copy()
        environment.update({
            "SHIPGLOWS_PRIVATE_DIR": str(root / ".shipglows"),
            "SHIPGLOWS_PRIVATE_DATA_CONFIG_FILE": str(root / "config" / "private-data.env"),
        })
        return subprocess.run([sys.executable, str(TOOL), "--format", "json", *args], text=True, capture_output=True, env=environment, check=False)

    def init_repo(self, root: Path, manifest: dict) -> Path:
        data = root / ".shipglows" / "data"
        data.mkdir(parents=True)
        subprocess.run(["git", "init", "-q", str(data)], check=True)
        (data / ".shipglows-private-data.json").write_text(json.dumps(manifest), encoding="utf-8")
        for namespace in manifest.get("namespaces", {}).values():
            namespace_path = namespace.get("path")
            if isinstance(namespace_path, str) and ".." not in Path(namespace_path).parts:
                (data / namespace_path).mkdir(parents=True, exist_ok=True)
        return data

    def test_status_is_redacted_and_manifest_namespaces_are_visible(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            self.init_repo(root, {"schema_version": 1, "namespaces": {"projects": {"path": "projects", "retention": "durable", "operations": ["read", "write"]}}})
            result = self.run_tool(root, "status")
            self.assertEqual(result.returncode, 0, result.stderr)
            payload = json.loads(result.stdout)
            self.assertEqual(payload["manifest"], "valid")
            self.assertEqual(payload["namespaces"], ["projects"])
            self.assertNotIn(str(root), result.stdout)
            self.assertNotIn("origin", result.stdout)

    def test_capability_requires_declared_namespace_and_operation(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            self.init_repo(root, {"schema_version": 1, "namespaces": {"projects": {"path": "projects", "retention": "durable", "operations": ["read"]}}})
            granted = self.run_tool(root, "capability", "projects", "read")
            self.assertEqual(granted.returncode, 0, granted.stderr)
            refused = self.run_tool(root, "capability", "projects", "write")
            self.assertEqual(refused.returncode, 2)
            self.assertNotIn("projects/", refused.stderr)

    def test_manifest_rejects_traversal_and_unknown_fields(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            self.init_repo(root, {"schema_version": 1, "namespaces": {"bad": {"path": "../outside", "retention": "durable", "operations": ["read"], "extra": True}}})
            result = self.run_tool(root, "doctor")
            self.assertEqual(result.returncode, 2)
            payload = json.loads(result.stdout)
            self.assertEqual(payload["manifest"], "invalid")
            self.assertEqual(payload["compatibility"], "invalid")

    def test_doctor_refuses_dirty_repository(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            data = self.init_repo(root, {"schema_version": 1, "namespaces": {"reports": {"path": "reports", "retention": "90 days", "operations": ["read"]}}})
            (data / "untracked.txt").write_text("synthetic", encoding="utf-8")
            result = self.run_tool(root, "doctor")
            self.assertEqual(result.returncode, 2)
            payload = json.loads(result.stdout)
            self.assertEqual(payload["git_state"], "dirty")

    def test_sync_refuses_dirty_repository_before_network_activity(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            data = self.init_repo(root, {"schema_version": 1, "namespaces": {"reports": {"path": "reports", "retention": "90 days", "operations": ["read"]}}})
            (data / "untracked.txt").write_text("synthetic", encoding="utf-8")
            result = self.run_tool(root, "sync", "pull", "--apply")
            self.assertEqual(result.returncode, 2)
            self.assertIn("clean repository", result.stderr)

    def test_connect_is_dry_run_until_explicitly_applied(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            result = self.run_tool(root, "connect", "--repo", "git@github.com:shipglows/private-data.git")
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(json.loads(result.stdout)["connect"], "planned")
            self.assertFalse((root / ".shipglows" / "data").exists())
            self.assertFalse((root / "config" / "private-data.env").exists())

    def test_connect_refuses_embedded_credentials(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            result = self.run_tool(Path(temporary), "connect", "--repo", "https://token@example.com/private-data.git")
            self.assertEqual(result.returncode, 2)
            self.assertIn("must not contain credentials", result.stderr)

    def test_open_is_dry_run_until_explicitly_applied(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            self.init_repo(root, {"schema_version": 1, "namespaces": {"projects": {"path": "projects", "retention": "durable", "operations": ["read"]}}})
            result = self.run_tool(root, "open")
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(json.loads(result.stdout), {"open": "planned"})

    def test_legacy_and_future_generations_fail_closed_differently(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            data = root / ".shipglows" / "data"
            data.mkdir(parents=True)
            subprocess.run(["git", "init", "-q", str(data)], check=True)
            legacy = self.run_tool(root, "status")
            self.assertEqual(json.loads(legacy.stdout)["compatibility"], "migration_required")
            (data / ".shipglows-private-data.json").write_text(json.dumps({"schema_version": 99, "namespaces": {}}), encoding="utf-8")
            future = self.run_tool(root, "status")
            payload = json.loads(future.stdout)
            self.assertEqual(payload["repository_generation"], "unsupported")
            self.assertEqual(payload["compatibility"], "unsupported")

    def test_migration_is_planned_then_applied_atomically(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            data = root / ".shipglows" / "data"
            (data / "projects").mkdir(parents=True)
            subprocess.run(["git", "init", "-q", str(data)], check=True)
            proposal = root / "manifest.json"
            proposal.write_text(json.dumps({"schema_version": 1, "namespaces": {"projects": {"path": "projects", "retention": "durable", "operations": ["read", "write"]}}}), encoding="utf-8")
            planned = self.run_tool(root, "migrate", "--manifest", str(proposal))
            self.assertEqual(json.loads(planned.stdout)["migration"], "planned")
            self.assertFalse((data / ".shipglows-private-data.json").exists())
            applied = self.run_tool(root, "migrate", "--manifest", str(proposal), "--apply")
            self.assertEqual(applied.returncode, 0, applied.stderr)
            self.assertEqual(json.loads(applied.stdout)["migration"], "applied")
            self.assertTrue((data / ".shipglows-private-data.json").is_file())

    def test_existing_clean_clone_can_be_adopted_explicitly(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            data = root / "existing"
            data.mkdir()
            subprocess.run(["git", "init", "-q", str(data)], check=True)
            repository_url = "https://github.com/shipglows/private-data.git"
            subprocess.run(["git", "-C", str(data), "remote", "add", "origin", repository_url], check=True)
            planned = self.run_tool(root, "connect", "--repo", repository_url, "--existing", "--dir", str(data))
            self.assertEqual(json.loads(planned.stdout)["mode"], "adopt")
            applied = self.run_tool(root, "connect", "--repo", repository_url, "--existing", "--dir", str(data), "--apply")
            self.assertEqual(applied.returncode, 0, applied.stderr)
            self.assertEqual(json.loads(applied.stdout)["compatibility"], "migration_required")
            self.assertTrue((root / "config" / "private-data.env").is_file())

    def test_windows_portability_rules_are_platform_independent(self) -> None:
        sys.path.insert(0, str(ROOT / "cli"))
        try:
            from private_data import is_windows_compatible_git_path

            self.assertTrue(is_windows_compatible_git_path("mail-source/new/message,U=1_2,S"))
            self.assertFalse(is_windows_compatible_git_path("mail-source/new/message,U=1:2,S"))
            self.assertFalse(is_windows_compatible_git_path("reports/CON.txt"))
        finally:
            sys.path.pop(0)


if __name__ == "__main__":
    unittest.main()
