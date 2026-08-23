#!/usr/bin/env python3
"""Regression checks for ShipGlows business, identity, human, and Git doctrine."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
SKILLS = ROOT / "skills"

POSITIONING_DOCUMENTS = {
    "README.md": ROOT / "README.md",
    "business.md": ROOT / "shipglows_data" / "business" / "business.md",
    "product.md": ROOT / "shipglows_data" / "business" / "product.md",
    "gtm.md": ROOT / "shipglows_data" / "business" / "gtm.md",
    "branding.md": ROOT / "shipglows_data" / "branding" / "branding.md",
    "claim-register.md": ROOT / "shipglows_data" / "editorial" / "claim-register.md",
    "public-benefit-language.md": (
        ROOT / "shipglows_data" / "editorial" / "public-benefit-language.md"
    ),
}

POSITIONING_REQUIREMENTS = {
    "README.md": (
        "ShipGlows is a business framework for humans and AI agents",
        "Business framework, partner behavior",
        "not guaranteed outcomes",
    ),
    "business.md": (
        "a business framework shared by humans and agents",
        "distinctive identities, businesses that make an impact, and solid technical execution",
        "business-aware partnership that challenges, recommends, owns, and proves",
        "governed truth, métier ownership, bounded chantiers, execution capabilities, and visible proof",
    ),
    "product.md": (
        "framework directly usable by humans and actionable by agents",
        "partnership describes its behavior, not a human service",
    ),
    "gtm.md": (
        "Category: a business framework for humans and AI agents",
        "Behavior: a business-aware delivery partner",
    ),
    "branding.md": (
        "Prefer “business framework” when naming the product category",
        "Use “business-aware delivery partner” to explain behavior",
        "Give every ambition a solid technical execution",
    ),
    "claim-register.md": (
        "business framework shared by humans and agents",
        "not guarantees of distinctiveness, impact, technical success",
    ),
    "public-benefit-language.md": (
        "shared business framework",
        "business-aware partnership as the product's behavior",
    ),
}

STALE_CENTRAL_DEFINITIONS = {
    "README.md": ("ShipGlows is a business-aware delivery partner that",),
    "business.md": ('business_model: "ShipGlows is an autonomous software product',),
    "gtm.md": ('offer: "an autonomous business-aware delivery product',),
    "branding.md": (
        "business-aware delivery partner first; métier agents, governed execution",
    ),
}


def text(path: Path) -> str:
    return " ".join(path.read_text(encoding="utf-8").split())


def positioning_contract_failures(documents: dict[str, str]) -> list[str]:
    failures = []
    for name, required_phrases in POSITIONING_REQUIREMENTS.items():
        for phrase in required_phrases:
            if phrase not in documents[name]:
                failures.append(f"{name} missing required positioning: {phrase}")

    for name, stale_phrases in STALE_CENTRAL_DEFINITIONS.items():
        for phrase in stale_phrases:
            if phrase in documents[name]:
                failures.append(f"{name} contains stale central positioning: {phrase}")

    return failures


class ShipGlowsVisionAlignmentContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.autonomy = text(SKILLS / "references" / "intent-to-outcome-autonomy.md")
        cls.execution = text(SKILLS / "references" / "intent-to-outcome-execution.md")
        cls.partnership = text(SKILLS / "references" / "operator-partnership-contract.md")
        cls.lifecycle = text(SKILLS / "references" / "master-workflow-lifecycle-core.md")
        cls.router = text(SKILLS / "references" / "entrypoint-routing.md")
        cls.scenarios = text(SKILLS / "references" / "intent-to-outcome-pressure-scenarios.md")
        cls.positioning_documents = {
            name: text(path) for name, path in POSITIONING_DOCUMENTS.items()
        }

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

    def test_governance_keeps_the_business_framework_hierarchy(self) -> None:
        self.assertEqual([], positioning_contract_failures(self.positioning_documents))

    def test_previous_delivery_partner_definition_is_rejected(self) -> None:
        stale_documents = dict(self.positioning_documents)
        stale_documents["README.md"] = stale_documents["README.md"].replace(
            "ShipGlows is a business framework for humans and AI agents",
            "ShipGlows is a business-aware delivery partner that ships software with AI agents",
        )

        failures = positioning_contract_failures(stale_documents)

        self.assertTrue(
            any("README.md missing required positioning" in failure for failure in failures)
        )
        self.assertTrue(
            any("README.md contains stale central positioning" in failure for failure in failures)
        )


if __name__ == "__main__":
    unittest.main()
