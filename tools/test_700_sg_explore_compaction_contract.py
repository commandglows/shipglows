#!/usr/bin/env python3
"""Contract checks for compact 700-sg-explore activation."""

from __future__ import annotations

from pathlib import Path
import unittest

from tools.skill_budget_audit import read_frontmatter


ROOT = Path(__file__).resolve().parents[1]
SKILL = ROOT / "skills" / "700-sg-explore" / "SKILL.md"
POSTURE = ROOT / "skills" / "700-sg-explore" / "references" / "exploration-posture-and-techniques.md"
REPORT = ROOT / "skills" / "700-sg-explore" / "references" / "durable-exploration-report.md"


class ExploreCompactionContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.skill = SKILL.read_text(encoding="utf-8")
        cls.posture = POSTURE.read_text(encoding="utf-8")
        cls.report = REPORT.read_text(encoding="utf-8")

    def test_activation_contract_and_budget(self) -> None:
        for heading in (
            "## Mission",
            "## Scope Gate",
            "## Required References",
            "## Stop Conditions",
            "## Validation",
            "## Report Modes",
            "## Canonical Paths",
        ):
            self.assertIn(heading, self.skill)
        _, errors, _, tokens = read_frontmatter(SKILL)
        self.assertEqual(errors, [])
        self.assertLessEqual(tokens, 1400)

    def test_reference_routing_is_conditional(self) -> None:
        for name in ("exploration-posture-and-techniques.md", "durable-exploration-report.md"):
            self.assertTrue((ROOT / "skills" / "700-sg-explore" / "references" / name).is_file())
            self.assertIn(name, self.skill)
        self.assertIn("Do not write code", self.skill)
        self.assertIn("No implementation", self.posture)
        self.assertIn("exploration_report", self.report)

    def test_threshold_and_persistence_rules(self) -> None:
        self.assertIn("Persistent report trigger", self.posture)
        self.assertIn("at least 2", self.posture)
        self.assertIn("no durable report", self.skill.lower())


if __name__ == "__main__":
    unittest.main()
