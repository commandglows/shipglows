#!/usr/bin/env python3
"""Contract checks for compact 203-sg-research activation."""

from __future__ import annotations

from pathlib import Path
import unittest

from tools.skill_budget_audit import read_frontmatter


ROOT = Path(__file__).resolve().parents[1]
SKILL = ROOT / "skills" / "203-sg-research" / "SKILL.md"
PLAYBOOK = ROOT / "skills" / "203-sg-research" / "references" / "research-execution-playbook.md"
TEMPLATE = ROOT / "skills" / "203-sg-research" / "references" / "research-report-template.md"


class ResearchCompactionContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.skill = SKILL.read_text(encoding="utf-8")
        cls.playbook = PLAYBOOK.read_text(encoding="utf-8")
        cls.template = TEMPLATE.read_text(encoding="utf-8")

    def test_activation_contract_and_budget(self) -> None:
        for heading in (
            "## Mission",
            "## Scope Gate",
            "## Required References",
            "## Stop Conditions",
            "## Validation",
            "## Report Modes",
            "## Canonical Paths",
            "## Chantier Tracking",
        ):
            self.assertIn(heading, self.skill)
        _, errors, _, tokens = read_frontmatter(SKILL)
        self.assertEqual(errors, [])
        self.assertLessEqual(tokens, 1300)

    def test_research_reference_chain(self) -> None:
        for path in (PLAYBOOK, TEMPLATE):
            self.assertTrue(path.is_file())
        self.assertIn("research-execution-playbook.md", self.skill)
        self.assertIn("research-report-template.md", self.skill)

    def test_no_unsourced_claims_without_method(self) -> None:
        self.assertIn("Do not claim verified truth from uncited assertions", self.skill)
        self.assertIn("Phase 1", self.playbook)
        self.assertIn("source list", self.skill)
        self.assertIn("confidence", self.template)

    def test_every_valid_run_persists_to_canonical_path(self) -> None:
        self.assertIn("Every valid research run saves a durable report", self.skill)
        self.assertIn("printing a synthesis without saving it is incomplete", self.skill)
        self.assertIn("shipglows_data/workflow/research/<topic-slug>.md", self.playbook)
        self.assertIn("$SHIPGLOWS_ROOT/shipglows_data/workflow/research/<topic-slug>.md", self.playbook)
        self.assertIn("If persistence fails, report `blocked`", self.playbook)

    def test_references_are_governed_and_cleanly_encoded(self) -> None:
        for text in (self.playbook, self.template):
            self.assertIn("artifact: skill_reference", text)
            self.assertIn('metadata_schema_version: "1.0"', text)
            self.assertIn("status: active", text)
            self.assertIn("source_skill: 203-sg-research", text)
            for broken in ("Ã", "Â", "â€”"):
                self.assertNotIn(broken, text)
        self.assertIn("status: <draft|reviewed>", self.template)
        self.assertIn("never stamp new research `reviewed` by default", self.template)
        for marker in ("owner:", "linked_systems:", "depends_on:", "supersedes:"):
            self.assertIn(marker, self.template)


if __name__ == "__main__":
    unittest.main()
