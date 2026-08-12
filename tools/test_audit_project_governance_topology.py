from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from tools.audit_project_governance_topology import audit


class GovernanceTopologyAuditTests(unittest.TestCase):
    def project(self) -> tuple[tempfile.TemporaryDirectory[str], Path]:
        temp = tempfile.TemporaryDirectory()
        root = Path(temp.name)
        (root / "shipglows_data").mkdir()
        return temp, root

    def test_compliant_single_corpus(self) -> None:
        temp, root = self.project()
        self.addCleanup(temp.cleanup)
        report = audit(root)
        self.assertEqual(report.status, "compliant")
        self.assertEqual(report.migration_sources, [])

    def test_detects_root_and_nested_legacy_corpora_together(self) -> None:
        temp, root = self.project()
        self.addCleanup(temp.cleanup)
        (root / "shipflow_data").mkdir()
        (root / "site" / "shipflow_data").mkdir(parents=True)
        report = audit(root)
        self.assertEqual(report.status, "migration-required")
        self.assertEqual(report.migration_sources, ["shipflow_data", "site/shipflow_data"])

    def test_detects_all_legacy_root_files_without_explicit_arguments(self) -> None:
        temp, root = self.project()
        self.addCleanup(temp.cleanup)
        (root / "BUSINESS.md").write_text("legacy", encoding="utf-8")
        (root / "TASKS.md").write_text("legacy", encoding="utf-8")
        report = audit(root)
        self.assertEqual(report.migration_sources, ["BUSINESS.md", "TASKS.md"])

    def test_detects_legacy_root_governance_directories(self) -> None:
        temp, root = self.project()
        self.addCleanup(temp.cleanup)
        (root / "research").mkdir()
        (root / "specs").mkdir()
        report = audit(root)
        self.assertEqual(report.status, "migration-required")
        self.assertEqual(report.migration_sources, ["research", "specs"])

    def test_root_workflow_directories_require_canonical_migration(self) -> None:
        temp, root = self.project()
        self.addCleanup(temp.cleanup)
        for name in ("bugs", "docs"):
            (root / name).mkdir()
        report = audit(root)
        self.assertEqual(report.status, "migration-required")
        self.assertEqual(report.migration_sources, ["bugs", "docs"])

    def test_root_bug_trackers_require_canonical_migration(self) -> None:
        temp, root = self.project()
        self.addCleanup(temp.cleanup)
        (root / "BUGS.md").write_text("legacy", encoding="utf-8")
        (root / "TEST_LOG.md").write_text("legacy", encoding="utf-8")
        report = audit(root)
        self.assertEqual(report.status, "migration-required")
        self.assertEqual(report.migration_sources, ["BUGS.md", "TEST_LOG.md"])

    def test_root_archive_requires_canonical_migration(self) -> None:
        temp, root = self.project()
        self.addCleanup(temp.cleanup)
        (root / "archive").mkdir()
        report = audit(root)
        self.assertEqual(report.status, "migration-required")
        self.assertEqual(report.migration_sources, ["archive"])

    def test_accepts_exact_agents_symlink_and_rejects_regular_file(self) -> None:
        temp, root = self.project()
        self.addCleanup(temp.cleanup)
        (root / "AGENT.md").write_text("entry", encoding="utf-8")
        try:
            (root / "AGENTS.md").symlink_to("AGENT.md")
        except OSError as error:
            if getattr(error, "winerror", None) == 1314:
                self.skipTest("Windows symlink privilege is unavailable")
            raise
        self.assertEqual(audit(root).status, "compliant")
        (root / "AGENTS.md").unlink()
        (root / "AGENTS.md").write_text("duplicate", encoding="utf-8")
        self.assertIn("AGENTS.md (must be a symlink to AGENT.md)", audit(root).migration_sources)

    def test_nested_canonical_corpus_in_standalone_git_repo_is_exception(self) -> None:
        temp, root = self.project()
        self.addCleanup(temp.cleanup)
        nested = root / "site"
        (nested / ".git").mkdir(parents=True)
        (nested / "shipglows_data").mkdir()
        report = audit(root)
        self.assertEqual(report.status, "compliant")
        self.assertEqual(report.standalone_exceptions, ["site/shipglows_data"])

    def test_nested_canonical_corpus_without_git_boundary_requires_migration(self) -> None:
        temp, root = self.project()
        self.addCleanup(temp.cleanup)
        (root / "site" / "shipglows_data").mkdir(parents=True)
        report = audit(root)
        self.assertEqual(report.status, "migration-required")
        self.assertEqual(report.migration_sources, ["site/shipglows_data"])

    def test_generated_output_is_hygiene_signal_not_migration(self) -> None:
        temp, root = self.project()
        self.addCleanup(temp.cleanup)
        (root / "dist-site").mkdir()
        report = audit(root)
        self.assertEqual(report.status, "compliant")
        self.assertEqual(report.hygiene_signals, ["dist-site"])

    def test_missing_canonical_corpus_requires_review(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            report = audit(Path(temp))
        self.assertEqual(report.status, "review-required")


if __name__ == "__main__":
    unittest.main()
