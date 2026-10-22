#!/usr/bin/env python3
"""Regression checks for the sourced interaction-heuristics doctrine."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "skills" / "references" / "human-centered-interaction-heuristics.md"
SPEC = ROOT / "shipglows_data" / "workflow" / "specs" / "human-centered-interaction-heuristics.md"
DESIGN = ROOT / "skills" / "006-sg-design" / "SKILL.md"
CUSTOMER = ROOT / "skills" / "008-sg-customer" / "SKILL.md"


def normalized_text(path: Path) -> str:
    return " ".join(path.read_text(encoding="utf-8").split())


class HumanCenteredInteractionHeuristicsTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.contract = normalized_text(CONTRACT)

    def test_design_and_customer_load_the_shared_contract_conditionally(self) -> None:
        # Owners may name a shared contract by file name inside a shared-contract loader list.
        reference = "human-centered-interaction-heuristics.md"
        self.assertEqual(normalized_text(DESIGN).count(reference), 1)
        self.assertEqual(normalized_text(CUSTOMER).count(reference), 1)

    def test_contract_and_spec_follow_the_current_quality_baseline(self) -> None:
        dependency = 'artifact: skills/references/decision-quality-contract.md artifact_version: "2.2.0" required_status: active'
        self.assertIn(dependency, self.contract)
        if SPEC.is_file():  # the spec lives in the private data corpus
            self.assertIn(dependency, normalized_text(SPEC))
        self.assertNotIn("a heuristic proves usability", self.contract.lower())
        self.assertNotIn("a checklist proves accessibility", self.contract.lower())

    def test_sources_are_named_with_roles_and_limits(self) -> None:
        for expected in (
            "https://lawsofux.com/",
            "https://www.checklist.design/",
            "https://mobbin.com/",
            "https://principles.design/",
            "https://www.nngroup.com/articles/ten-usability-heuristics/",
            "https://www.w3.org/TR/WCAG22/",
            "What it does not prove",
            "Consulted 2026-08-15",
        ):
            self.assertIn(expected, self.contract)

    def test_pattern_examples_are_not_user_research_or_best_practice_proof(self) -> None:
        for expected in (
            "User research, conversion impact, accessibility, legal permission to copy",
            "similarity to a successful product is not causal evidence",
            "Do not claim `user-tested`, `validated`, `proven`, `best practice`, `accessible`, `intuitive`, or `conversion-improving`",
        ):
            self.assertIn(expected, self.contract)

    def test_checklist_completion_is_not_completeness_proof(self) -> None:
        self.assertIn("A checklist supports coverage but never proves completeness or quality", self.contract)
        self.assertIn("Never call a review exhaustive because a third-party checklist was completed", self.contract)

    def test_heuristics_do_not_replace_context_or_accessibility_evidence(self) -> None:
        for expected in (
            "Heuristics generate hypotheses and findings; they do not automatically establish defects",
            "never decide by counting rules",
            "Accessibility conclusions require applicable WCAG/platform criteria",
            "manual, rendered, keyboard, zoom/reflow, and assistive-technology evidence",
        ):
            self.assertIn(expected, self.contract)

    def test_public_mode_grammar_remains_unchanged(self) -> None:
        customer = normalized_text(CUSTOMER)
        self.assertIn("<audit|flow|onboarding|recovery> <scope>", customer)
        self.assertNotIn("heuristics [scope]", customer)


if __name__ == "__main__":
    unittest.main()
