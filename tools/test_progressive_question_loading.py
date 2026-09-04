"""Safety-critical first-read gates and isolated question detail after compaction."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
REFS = ROOT / "skills/references"


class ProgressiveQuestionLoadingTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.core = (REFS / "question-contract.md").read_text(encoding="utf-8")
        cls.greenfield = (REFS / "question-greenfield-decisions.md").read_text(encoding="utf-8")
        cls.cold = (REFS / "question-pressure-scenarios.md").read_text(encoding="utf-8")

    def test_existing_project_question_has_no_eager_greenfield_or_history(self):
        self.assertIn("Before greenfield platform, blueprint or technology selection, load", self.core)
        self.assertIn("Existing-stack work alone does not trigger this branch", self.core)
        self.assertIn("examples and history never load for ordinary questions", self.core)
        for leaf in ("question-greenfield-decisions.md", "question-pressure-scenarios.md"):
            self.assertTrue((REFS / leaf).is_file())
        self.assertNotIn("## Greenfield Platform Footprint Rule", self.core)
        self.assertNotIn("## Pressure Scenarios", self.core)
        self.assertIn("never chain siblings", self.core)
        # Full specialized policy is available without traversing a cold test file.
        self.assertNotIn("question-pressure-scenarios.md", self.greenfield)
        self.assertNotIn("question-greenfield-decisions.md", self.cold)

    def test_greenfield_preserves_platform_before_stack_and_existing_consent(self):
        for rule in (
            "Before blueprint matching or technology recommendations",
            "Never put a major platform",
            "one Flutter codebase for",
            "After the platform footprint is known, load",
            "Do not repeatedly ask",
            "A matched",
            "blueprint is a recommendation, not consent",
        ):
            self.assertIn(rule, self.greenfield)
        self.assertLess(self.greenfield.index("## Greenfield Platform Footprint Rule"),
                        self.greenfield.index("## Greenfield Technology Decision Rule"))

    def test_missing_target_does_not_waive_authority_or_source_recovery(self):
        for rule in (
            "missing required", "stops the dependent decision",
            "Never invent a target/default", "silence is no answer",
            "its answer never authorizes a mutation",
            "Material expansion requires its own authority",
            "Research discoverable facts", "guided-business-product-discovery.md",
            "A question never permits a governing-source write",
        ):
            self.assertIn(rule, self.core)

    def test_material_decisions_and_proof_remain_in_first_read(self):
        for rule in (
            "blocking materiality is not required", "professional evidence-backed decision",
            "strategic-choice-contract.md", "Before validation or mutation",
            "security/privacy", "auth/tenant/permissions", "money", "public claims",
            "Do not trade missing proof for premature shipping",
        ):
            self.assertIn(rule, self.core)

    def test_replay_omissions_have_visible_entry_and_recovery_gates(self):
        router = (ROOT / "skills/000-shipglows/SKILL.md").read_text(encoding="utf-8")
        self.assertIn("Explicit invocations, including `$shipglows`", router)
        self.assertIn("run its checker", router)
        self.assertIn("invalid/ambiguous activates no substitute", router)
        self.assertIn("`skill-execution-fidelity.md` is advisory here", router)
        continuation = (ROOT / "skills/706-continue/references/continuation-playbook.md").read_text(encoding="utf-8")
        self.assertIn("or the outcome is unknown, load `question-contract.md`", continuation)
        self.assertIn("With a known non-trivial outcome but no work item", continuation)
        self.assertIn("Never invent a hidden continuation target", continuation)


if __name__ == "__main__":
    unittest.main()
