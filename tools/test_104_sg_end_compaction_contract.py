#!/usr/bin/env python3
"""Contract checks for compact 104-sg-end activation."""

from __future__ import annotations

from pathlib import Path
import unittest

from tools.skill_budget_audit import read_frontmatter


ROOT = Path(__file__).resolve().parents[1]
SKILL = ROOT / "skills" / "104-sg-end" / "SKILL.md"
PLAYBOOK = ROOT / "skills" / "104-sg-end" / "references" / "closure-bookkeeping-playbook.md"


class EndCompactionContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.skill = SKILL.read_text(encoding="utf-8")
        cls.playbook = PLAYBOOK.read_text(encoding="utf-8")

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
        self.assertLessEqual(tokens, 1600)

    def test_closure_reference_is_required(self) -> None:
        self.assertIn("closure-bookkeeping-playbook.md", self.skill)
        self.assertIn("closed", self.skill)
        self.assertIn("partial", self.skill)
        self.assertTrue(PLAYBOOK.is_file())
        self.assertIn("Closure mode", self.playbook)

    def test_user_report_markers_are_present(self) -> None:
        self.assertIn("### Step 5 \u2014 Report", self.skill)
        self.assertIn("### Rules", self.skill)
        report_section = self.skill.split("### Step 5 \u2014 Report", 1)[1].split("### Rules", 1)[0]
        forbidden = (
            "Flux: 100-sg-spec",
            "Route: [",
            "Prochaine etape",
            "run /005-sg-ship",
        )
        for legacy in forbidden:
            self.assertNotIn(legacy, report_section)


if __name__ == "__main__":
    unittest.main()
