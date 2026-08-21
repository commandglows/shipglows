#!/usr/bin/env python3
"""Pressure scenarios for the lightweight Git persistence preflight."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
PREFLIGHT = ROOT / "skills/references/git-persistence-preflight.md"


class GitPersistencePreflightContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.preflight = PREFLIGHT.read_text(encoding="utf-8")
        cls.start = (ROOT / "skills/102-sg-start/SKILL.md").read_text(encoding="utf-8")
        cls.resume = (ROOT / "skills/706-continue/SKILL.md").read_text(encoding="utf-8")
        cls.end = (ROOT / "skills/104-sg-end/SKILL.md").read_text(encoding="utf-8")
        cls.lifecycle = (
            ROOT / "skills/references/master-workflow-lifecycle.md"
        ).read_text(encoding="utf-8")
        cls.reporting = (
            ROOT / "skills/references/reporting-contract.md"
        ).read_text(encoding="utf-8")

    def test_healthy_path_is_silent_and_not_repeated_per_edit(self) -> None:
        for marker in (
            "without a question, confirmation, visible preflight card",
            "Do not rerun before every file edit",
            "GPP-HEALTHY-SILENT",
        ):
            with self.subTest(marker=marker):
                self.assertIn(marker, self.preflight)

    def test_states_have_distinct_evidence(self) -> None:
        for marker in (
            "`local`",
            "`backed up`",
            "`deployed`",
            "A commit is not automatically backed up",
            "A push proves remote persistence, not deployment",
            "GPP-STATE-SEPARATION",
        ):
            with self.subTest(marker=marker):
                self.assertIn(marker, self.preflight)

    def test_findings_are_actionable_without_generic_questions(self) -> None:
        for marker in (
            "preserve them unstaged",
            "ownership is unknown",
            "do not guess or push",
            "Do not convert every finding into a question",
            "GPP-WRONG-REMOTE",
            "GPP-UNRELATED-DIRTY",
        ):
            with self.subTest(marker=marker):
                self.assertIn(marker, self.preflight)

    def test_sensitive_work_requires_remote_recovery_point(self) -> None:
        for marker in (
            "Sensitive Recovery Point",
            "require the relevant pre-change baseline to be `backed up`",
            "stop rather than manufacturing a recovery commit",
            "GPP-SENSITIVE-RECOVERY-POINT",
        ):
            with self.subTest(marker=marker):
                self.assertIn(marker, self.preflight)
        self.assertIn("git-persistence-preflight.md", self.lifecycle)

    def test_existing_lifecycle_boundaries_load_the_preflight(self) -> None:
        for name, corpus in (
            ("start", self.start),
            ("resume", self.resume),
            ("end", self.end),
        ):
            with self.subTest(owner=name):
                self.assertIn("git-persistence-preflight.md", corpus)

    def test_reporting_supports_compact_persistence_evidence(self) -> None:
        self.assertIn("📦 PERSISTANCE", self.reporting)
        self.assertIn("Local", self.reporting)
        self.assertIn("Git distant", self.reporting)
        self.assertIn("Déployé", self.reporting)


if __name__ == "__main__":
    unittest.main()
