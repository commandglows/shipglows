from __future__ import annotations

import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SKILL = ROOT / "skills" / "300-sg-docs" / "SKILL.md"
REFS = SKILL.parent / "references"
FAMILIES = {
    "simple-bootstrap-playbooks.md": ("INIT", "FILE", "README", "API", "COMPONENTS", "AUTO"),
    "governance-playbooks.md": ("TECHNICAL", "EDITORIAL", "DUPLICATE", "AUDIT", "UPDATE", "LAYOUT MIGRATION", "METADATA"),
    "private-project-playbooks.md": ("ADD PROJECT", "ADD PROJECT UPDATE"),
}


class DocsCompactionContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.skill = SKILL.read_text(encoding="utf-8")

    def test_activation_body_meets_budget(self) -> None:
        body = self.skill.split("---", 2)[2].lstrip("\n")
        self.assertLessEqual(len(body) / 4, 1600)

    def test_modes_route_directly_to_one_bounded_family(self) -> None:
        for reference, modes in FAMILIES.items():
            self.assertEqual(1, self.skill.count(f"references/{reference}"), reference)
            body = (REFS / reference).read_text(encoding="utf-8")
            for mode in modes:
                self.assertIn(mode, body, f"{reference}: {mode}")
        self.assertIn("Load exactly one family before the first mode action", self.skill)
        self.assertIn("compatibility index only", self.skill)

    def test_family_references_are_leaf_playbooks(self) -> None:
        local_names = tuple(FAMILIES) + ("mode-playbooks.md",)
        for reference in FAMILIES:
            body = (REFS / reference).read_text(encoding="utf-8")
            for other in local_names:
                self.assertNotIn(other, body, f"{reference} chains to {other}")
            self.assertIsNone(re.search(r"(?i)\bload\b[^\n]*\.md", body), reference)

    def test_simple_path_does_not_eagerly_load_governance(self) -> None:
        routing = self.skill.split("## Conditional Gates", 1)[0]
        simple_row = next(line for line in routing.splitlines() if "simple-bootstrap-playbooks.md" in line)
        self.assertNotIn("core-governance", simple_row)
        self.assertIn("Simple FILE/API/COMPONENTS work does not load it", self.skill)

    def test_governance_and_private_gates_remain_direct(self) -> None:
        for required in (
            "references/core-governance.md",
            "technical-docs-corpus.md",
            "editorial-content-corpus.md",
            "private-data-repo-contract.md",
            "project-import-playbook.md",
        ):
            self.assertIn(required, self.skill)

    def test_preflight_and_preservation_precede_mutation(self) -> None:
        self.assertIn("preflight **before any mutation**", self.skill)
        self.assertIn("audit_project_governance_topology.py", self.skill)
        self.assertIn("Before slimming, deleting, moving, or replacing", self.skill)
        self.assertIn("preserve non-redundant content", self.skill)
        self.assertIn("merge/preservation decision", self.skill)

    def test_public_authority_stops_and_reporting_survive(self) -> None:
        for phrase in (
            "Public label: `sg-docs`",
            "Public audience content belongs to `sg-content`",
            "## Authority And Mutation Contract",
            "## Stop Conditions",
            "## Reporting",
            "report=user",
            "report=agent",
        ):
            self.assertIn(phrase, self.skill)


if __name__ == "__main__":
    unittest.main()
