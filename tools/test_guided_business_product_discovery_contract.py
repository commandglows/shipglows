#!/usr/bin/env python3
"""Contract checks for guided business/product discovery."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / "skills" / "references" / "guided-business-product-discovery.md"
DECISION_CHAIN = ROOT / "skills" / "references" / "product-decision-chain.md"
DOCS_SKILL = ROOT / "skills" / "300-sg-docs" / "SKILL.md"
INIT_SKILL = ROOT / "skills" / "305-sg-init" / "SKILL.md"
BOOTSTRAP = ROOT / "skills" / "305-sg-init" / "references" / "bootstrap-workflow.md"


class GuidedDiscoveryContractTests(unittest.TestCase):
    def test_templates_cover_decision_domains(self) -> None:
        required = {
            "business_context.md": ("## Business Identity", "## Primary Customer", "## Alternatives And Differentiation"),
            "product_context.md": ("## Customer Need Model", "## Priority Value Journey", "## Journey-To-Capability Map"),
            "gtm_context.md": ("## Buying Trigger", "## Acquisition And Conversion Journey", "## Claims Boundary"),
            "brand_context.md": ("## Desired Emotional Response", "## Trust Posture", "## Touchpoint Behavior"),
        }
        for name, headings in required.items():
            text = (ROOT / "templates" / name).read_text(encoding="utf-8")
            for heading in headings:
                self.assertIn(heading, text, f"{name}: {heading}")

    def test_owner_skills_load_one_shared_contract(self) -> None:
        reference_path = "$SHIPGLOWS_ROOT/skills/references/guided-business-product-discovery.md"
        self.assertIn(reference_path, DOCS_SKILL.read_text(encoding="utf-8"))
        self.assertIn(reference_path, INIT_SKILL.read_text(encoding="utf-8"))

    def test_bootstrap_uses_all_canonical_templates(self) -> None:
        text = BOOTSTRAP.read_text(encoding="utf-8")
        for name in ("business_context.md", "product_context.md", "gtm_context.md", "brand_context.md"):
            self.assertIn(f"$SHIPGLOWS_ROOT/templates/{name}", text)
        self.assertNotIn("Décris ton projet en une phrase", text)
        self.assertIn("Confirmer`, `Corriger` or `Approfondir", text)

    def test_pressure_scenarios_and_evidence_states_are_durable(self) -> None:
        text = REFERENCE.read_text(encoding="utf-8")
        for scenario in ("ATLAS-015", "ATLAS-016", "ATLAS-017", "ATLAS-018"):
            self.assertIn(scenario, text)
        for state in ("`confirmed`", "`evidence_backed`", "`hypothesis`", "`unknown`"):
            self.assertIn(state, text)
        self.assertIn("Do not dump a questionnaire", text)

    def test_decision_chain_owns_lightweight_bmad_patterns(self) -> None:
        text = DECISION_CHAIN.read_text(encoding="utf-8")
        for scenario in ("ATLAS-019", "ATLAS-020", "ATLAS-021", "ATLAS-022", "ATLAS-023", "ATLAS-024", "ATLAS-025"):
            self.assertIn(scenario, text)
        for behavior in (
            "Cross-Contract Coherence Gate",
            "Critical Experience Moments",
            "Decision Change Protocol",
            "Focused Deepening",
            "Learning Loop",
            "before → after",
        ):
            self.assertIn(behavior, text)
        self.assertIn("does not create a second product database", text)
        self.assertIn("No simulated stakeholder theatre", text)

    def test_lifecycle_owners_load_decision_chain(self) -> None:
        reference_path = "$SHIPGLOWS_ROOT/skills/references/product-decision-chain.md"
        owners = (
            "006-sg-design",
            "100-sg-spec",
            "101-sg-ready",
            "102-sg-start",
            "103-sg-verify",
            "104-sg-end",
            "300-sg-docs",
            "703-sg-review",
        )
        for owner in owners:
            text = (ROOT / "skills" / owner / "SKILL.md").read_text(encoding="utf-8")
            self.assertIn(reference_path, text, owner)

    def test_product_template_exposes_critical_moments_and_trace(self) -> None:
        text = (ROOT / "templates" / "product_context.md").read_text(encoding="utf-8")
        self.assertIn("## Critical Experience Moments", text)
        self.assertIn("upstream journey/need IDs", text)
        self.assertIn("downstream spec/proof IDs", text)


if __name__ == "__main__":
    unittest.main()
