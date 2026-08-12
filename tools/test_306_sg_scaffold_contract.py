import unittest
from pathlib import Path

from tools.skill_budget_audit import read_frontmatter


ROOT = Path(__file__).resolve().parents[1]
SKILL_PATH = ROOT / "skills" / "306-sg-scaffold" / "SKILL.md"
REFS = SKILL_PATH.parent / "references"


class ScaffoldSkillContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.skill = SKILL_PATH.read_text(encoding="utf-8")

    def test_activation_contract_and_budget(self) -> None:
        for heading in (
            "## Mission",
            "## Scope Gate",
            "## Required References",
            "## Stop Conditions",
            "## Report Modes",
            "## Validation",
        ):
            self.assertIn(heading, self.skill)
        _, errors, _, tokens = read_frontmatter(SKILL_PATH)
        self.assertEqual(errors, [])
        self.assertLessEqual(tokens, 1400)
        self.assertLessEqual(len(list(REFS.glob("*.md"))), 2)

    def test_project_evidence_precedes_blueprint_and_inference(self) -> None:
        self.assertIn("project examples > loaded blueprint > inference", self.skill)
        self.assertIn("$BLUEPRINT_PATH", self.skill)
        self.assertIn("`blueprint:` handoff", self.skill)
        self.assertIn("the project wins", self.skill)

    def test_conditional_loaders(self) -> None:
        for name in ("scaffold-discovery-playbook.md", "scaffold-generation-playbook.md"):
            self.assertTrue((REFS / name).is_file())
            self.assertIn(name, self.skill)
        self.assertIn("only when discovery has produced", self.skill)
        self.assertIn("app-blueprints.md` only for", self.skill)
        self.assertIn("design-system-token-contract.md` before any page", self.skill)

    def test_security_design_and_claim_stops_remain_local(self) -> None:
        for phrase in (
            "auth or authorization",
            "tenant/org/project boundaries",
            "pricing/security/compliance/capability claims",
            "UI visibility is never authorization",
            "no canonical design-system authority",
            "Do not scaffold when reliable examples",
        ):
            self.assertIn(phrase, self.skill)

    def test_safe_shell_remains_bounded(self) -> None:
        generation = (REFS / "scaffold-generation-playbook.md").read_text(encoding="utf-8")
        self.assertIn("`501 Not Implemented`", generation)
        self.assertIn("without invented business logic", generation)
        self.assertIn("Do not use a safe shell to bypass", generation)
        self.assertIn("NOT SCAFFOLDED", generation)


if __name__ == "__main__":
    unittest.main()
