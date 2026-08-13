#!/usr/bin/env python3
"""Regression checks for the shared mutation-plan approval contract."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "skills" / "references" / "mutation-plan-approval.md"
STRATEGIC = ROOT / "skills" / "references" / "strategic-choice-contract.md"


class MutationPlanApprovalContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.text = CONTRACT.read_text(encoding="utf-8")

    def test_opening_identity_matches_chantier_reporting(self) -> None:
        for expected in (
            "🧭 PLAN À VALIDER (<local|spec>) : <short plan name>",
            "🎯 VALIDATION (HH:mm) : en attente",
            "Paris time",
        ):
            self.assertIn(expected, self.text)

    def test_required_sections_keep_visual_hierarchy(self) -> None:
        for expected in (
            "🎯 **Objectif**",
            "📂 **Périmètre**",
            "🔨 **Actions**",
            "✅ **Preuves**",
            "📌 **Choix**",
        ):
            self.assertIn(expected, self.text)

    def test_choices_are_contextual_and_unambiguous(self) -> None:
        for expected in (
            "two or three numbered choices",
            "adapted to the actual decision",
            "Exactly one choice may grant approval",
            "must not be a fixed menu",
            "A number-only reply",
        ):
            self.assertIn(expected, self.text)

        self.assertIn("strategic-choice-contract.md", self.text)
        strategic = STRATEGIC.read_text(encoding="utf-8")
        self.assertIn("business or product outcome", strategic)
        self.assertIn("guided follow-up", strategic)

    def test_pressure_scenarios_cover_local_spec_and_replacement(self) -> None:
        for scenario in (
            "MAP-LOCAL",
            "MAP-SPEC",
            "MAP-CONTEXTUAL-CHOICES",
            "MAP-NUMBER-ONLY",
            "MAP-REPLACEMENT",
        ):
            self.assertIn(scenario, self.text)


if __name__ == "__main__":
    unittest.main()
