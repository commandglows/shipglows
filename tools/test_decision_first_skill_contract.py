#!/usr/bin/env python3
"""Decision-first pressure checks for ShipGlows skill contracts."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]


def read(relative: str) -> str:
    return (ROOT / relative).read_text(encoding="utf-8")


class DecisionFirstSkillContractTests(unittest.TestCase):
    def test_report_templates_render_resolved_values(self) -> None:
        reporting = read("skills/references/reporting-contract.md")
        self.assertIn("<resolved documentation plan>", reporting)
        self.assertIn("<resolved documentation status", reporting)
        self.assertIn("<resolved editorial status", reporting)
        self.assertIn("<resolved changelog status", reporting)
        self.assertIn("<resolved delivery status", reporting)
        self.assertNotIn("📖 DOCUMENTATION ✅ updated · <aligned documentation scope>", reporting)
        self.assertNotIn("✏️ ÉDITORIAL ➖ not impacted · <concrete reason>", reporting)
        self.assertNotIn("📰 CHANGELOG 🔒 internal-only · <concrete reason>", reporting)

    def test_unfinished_choices_require_a_real_operator_decision(self) -> None:
        blocked = read("skills/references/reporting-blocked-and-audit.md")
        self.assertIn("operator owns a real unresolved decision", blocked)
        self.assertIn("one required recovery action or fact", blocked)
        self.assertNotIn("Poursuivre le résultat convenu", blocked)

    def test_question_shape_follows_decision_shape(self) -> None:
        question = read("skills/references/question-contract.md")
        autonomy = read("skills/references/intent-to-outcome-autonomy.md")
        partnership = read("skills/references/operator-partnership-contract.md")
        corpus = question + autonomy + partnership
        self.assertIn("genuinely enumerable", corpus)
        self.assertIn("natural-language answer", corpus)
        self.assertNotIn("Every user-facing question must be answerable by number", question)
        self.assertNotIn("should be asked readily", question)

    def test_empty_check_and_status_invocations_choose_safe_defaults(self) -> None:
        check = read("skills/105-sg-check/SKILL.md")
        status = read("skills/308-sg-status/SKILL.md")
        self.assertIn("With empty arguments, derive", check)
        self.assertNotIn("ask which checks to run", check)
        self.assertIn("With empty arguments, use `issues`", status)
        self.assertNotIn("Quelle vue du dashboard veux-tu", status)
        self.assertIn("current shell", status)
        self.assertNotIn("/005-sg-ship to commit and push", status)

    def test_platform_horizon_does_not_precommit_launch_scope(self) -> None:
        stacks = read("skills/references/preferred-stacks.md")
        self.assertIn("capability horizon", stacks)
        self.assertIn("not a launch commitment", stacks)
        self.assertNotIn("Recommend the shared six-platform footprint first", stacks)

    def test_conversation_follow_through_keeps_semantic_proof_open(self) -> None:
        audit = read("skills/705-sg-conversation-audit/SKILL.md")
        self.assertIn("structure-only", audit)
        self.assertIn("targeted semantic pressure scenario", audit)
        self.assertIn("affected owner layer", audit)
        self.assertIn("python3 -m unittest tools.test_decision_first_skill_contract", audit)


if __name__ == "__main__":
    unittest.main()
