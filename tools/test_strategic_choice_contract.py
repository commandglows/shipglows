#!/usr/bin/env python3
"""Regression checks for operator-facing strategic choice surfaces."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
STRATEGIC = ROOT / "skills" / "references" / "strategic-choice-contract.md"
PLAN = ROOT / "skills" / "references" / "mutation-plan-approval.md"
QUESTION = ROOT / "skills" / "references" / "question-contract.md"
REPORT = ROOT / "skills" / "references" / "reporting-blocked-and-audit.md"
SCENARIOS = ROOT / "skills" / "references" / "reporting-pressure-scenarios.md"


class StrategicChoiceContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.strategic = STRATEGIC.read_text(encoding="utf-8")

    def test_material_choices_express_business_visions(self) -> None:
        for expected in (
            "business or product outcome",
            "customer, market, revenue, trust, cost, risk, or organizational effect",
            "time horizon",
            "material trade-off",
            "recommended direction",
        ):
            self.assertIn(expected, self.strategic)

    def test_short_interaction_labels_trigger_guided_follow_up(self) -> None:
        for expected in (
            "`Questionner`",
            "`Réorienter`",
            "guided follow-up",
            "must not ask the operator to invent the next direction from a blank page",
            "never grants approval",
        ):
            self.assertIn(expected, self.strategic)

    def test_all_choice_surfaces_load_shared_contract(self) -> None:
        for path in (PLAN, QUESTION, REPORT):
            text = path.read_text(encoding="utf-8")
            self.assertIn("strategic-choice-contract.md", text, str(path))

    def test_pressure_scenarios_reject_short_sighted_choices(self) -> None:
        text = SCENARIOS.read_text(encoding="utf-8")
        for scenario in (
            "SSRP-014 strategic business choice",
            "SSRP-015 guided questioning",
            "SSRP-016 guided reorientation",
            "SSRP-017 no blank-page handoff",
        ):
            self.assertIn(scenario, text)


if __name__ == "__main__":
    unittest.main()
