#!/usr/bin/env python3
"""Regression checks for ShipGlows business, identity, human, and Git doctrine."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
SKILLS = ROOT / "skills"


def text(path: Path) -> str:
    return " ".join(path.read_text(encoding="utf-8").split())


class ShipGlowsVisionAlignmentContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.autonomy = text(SKILLS / "references" / "intent-to-outcome-autonomy.md")
        cls.execution = text(SKILLS / "references" / "intent-to-outcome-execution.md")
        cls.partnership = text(SKILLS / "references" / "operator-partnership-contract.md")
        cls.lifecycle = text(SKILLS / "references" / "master-workflow-lifecycle-core.md")
        cls.router = text(SKILLS / "references" / "entrypoint-routing.md")
        cls.scenarios = text(SKILLS / "references" / "intent-to-outcome-pressure-scenarios.md")

    def test_target_model_does_not_assume_software(self) -> None:
        target = "project -> business/brand/product -> outcome -> surface -> work item"
        self.assertIn(target, self.autonomy)
        self.assertNotIn("project -> product -> surface -> feature", " ".join(
            path.read_text(encoding="utf-8")
            for path in SKILLS.rglob("*.md")
        ))
        self.assertIn("software is one possible form, not the default", self.autonomy)

    def test_git_is_common_memory_but_not_activation_proof(self) -> None:
        for phrase in (
            "every repository-representable ShipGlows artifact",
            "Commit records a coherent local version",
            "push provides remote backup and collaboration",
            "Publication, adoption, application, rollout, and deployment are separate activation states",
        ):
            self.assertIn(phrase, self.partnership)
        self.assertIn("Commit/push proves persistence", self.lifecycle)

    def test_external_native_sources_keep_truthful_git_receipts(self) -> None:
        self.assertIn("provider-native sources", self.partnership)
        self.assertIn("canonical link plus proportionate exports", self.partnership)
        self.assertIn("without pretending an export is the editable native source", self.execution)

    def test_humans_and_agents_share_one_usable_framework(self) -> None:
        self.assertIn("so humans can use them directly", self.autonomy)
        self.assertIn("without requiring agent mediation", self.partnership)
        self.assertIn("neither receives a hidden parallel framework", self.partnership)

    def test_routing_separates_business_identity_content_and_software(self) -> None:
        for phrase in (
            "Business model, offer, market, positioning, message strategy",
            "Brand identity, visual identity system, art direction",
            "Audience content, editorial expression, content site strategy",
            "Software feature, application behavior, code implementation",
        ):
            self.assertIn(phrase, self.router)

    def test_pressure_scenarios_preserve_non_software_and_technical_rigor(self) -> None:
        for scenario in ("MH-19", "MH-20", "MH-21", "MH-22", "MH-23"):
            self.assertIn(scenario, self.scenarios)


if __name__ == "__main__":
    unittest.main()
