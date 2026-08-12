import unittest
from pathlib import Path

from tools.skill_budget_audit import read_frontmatter


ROOT = Path(__file__).resolve().parents[1]
SKILL_PATH = ROOT / "skills" / "105-sg-check" / "SKILL.md"
REFS = SKILL_PATH.parent / "references"


class CheckSkillContractTests(unittest.TestCase):
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
        self.assertLessEqual(tokens, 1500)
        self.assertLessEqual(len(list(REFS.glob("*.md"))), 2)

    def test_check_nofix_and_repair_pressure(self) -> None:
        self.assertIn("`nofix` is strictly read-only", self.skill)
        self.assertIn("at most 3 fix cycles", self.skill)
        self.assertIn("Never install dependencies", self.skill)
        self.assertIn("weaken lint/type/test/build rules", self.skill)
        self.assertIn("Stop mutation immediately in `nofix`", self.skill)

    def test_green_check_has_bounded_meaning(self) -> None:
        self.assertIn("not product, browser, manual-flow, security, auth, or production proof", self.skill)
        self.assertIn("Never describe a passing `105-sg-check` run as production-ready", self.skill)
        self.assertIn("Quick dependency checks", self.skill)
        self.assertIn("never become security sign-off", self.skill)

    def test_conditional_playbooks_and_owner_routes(self) -> None:
        for name in ("check-execution-playbook.md", "check-repair-and-report-playbook.md"):
            self.assertTrue((REFS / name).is_file())
            self.assertIn(name, self.skill)
        self.assertIn("only when a check fails", self.skill)
        for owner in (
            "/010-sg-technical deps <project>",
            "/108-sg-browser",
            "/109-sg-auth-debug",
            "/405-sg-prod",
            "/103-sg-verify",
        ):
            self.assertIn(owner, self.skill)
        self.assertIn("005-sg-ship -> 405-sg-prod", self.skill)


if __name__ == "__main__":
    unittest.main()
