#!/usr/bin/env python3
"""Regression proof for question/validation separation and autonomous Git policy."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
REFS = ROOT / "skills" / "references"


class QuestionValidationGitAutonomyContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.question = (REFS / "question-contract.md").read_text(encoding="utf-8")
        cls.approval = (REFS / "mutation-plan-approval.md").read_text(encoding="utf-8")
        cls.policy = (REFS / "project-delivery-policy.md").read_text(encoding="utf-8")
        cls.lifecycle = (REFS / "git-temporary-artifact-lifecycle.md").read_text(
            encoding="utf-8"
        )

    def test_product_questions_are_proactive_and_may_be_non_blocking(self) -> None:
        for marker in (
            "Product and experience questions are proactive partnership",
            "blocking materiality is not required",
            "Continue safe in-scope work while the answer is pending when possible",
        ):
            self.assertIn(marker, self.question)

    def test_technical_questions_and_validations_are_exceptional(self) -> None:
        for marker in (
            "For a purely technical question, first attempt a professional evidence-backed decision",
            "Never ask the operator to supervise implementation mechanics",
            "Validation requests are different: they interrupt execution and must be rare",
        ):
            self.assertIn(marker, self.question)

    def test_question_answers_do_not_expand_authority(self) -> None:
        self.assertIn(
            "A question is not a validation request, and its answer never authorizes a mutation",
            self.question,
        )
        self.assertIn("one named canonical field", self.question)
        self.assertIn("SSRP-019 bounded-product-fact-capture", self.question)

    def test_git_has_standing_authority_and_status_driven_targets(self) -> None:
        for marker in (
            "Git/GitHub stewardship authority",
            "without a separate Git validation",
            "`development` (non-live)",
            "`integration_branch: main`",
            "`published` and `sensitive-production`",
            "exact canonical branch `dev` for integration and staging",
        ):
            self.assertIn(marker, self.approval + self.policy)

    def test_cleanup_is_always_classified_and_proportional_after_proof(self) -> None:
        for marker in (
            "After integration and required hosted or production proof",
            "clean tracked and untracked state",
            "do not request validation for that ordinary cleanup",
            "For a large chantier, multiple repositories or artifacts",
            "present one exact evidence-backed cleanup proposal",
            "The operator may refuse a proposed cleanup",
            "never force",
            "preserve the artifact as `blocked`",
        ):
            self.assertIn(marker, self.lifecycle)


if __name__ == "__main__":
    unittest.main()
