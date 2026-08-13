#!/usr/bin/env python3
"""Pressure contracts for ShipGlows industrial and visual excellence doctrine."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
DECISION = ROOT / "skills/references/decision-quality-contract.md"
IMPLEMENTATION = ROOT / "skills/references/decision-quality-implementation-discipline.md"
CLEAN_CODE = ROOT / "skills/references/clean-code-quality-contract.md"
DESIGN = ROOT / "skills/references/design-system-token-contract.md"
EXCELLENCE = ROOT / "skills/103-sg-verify/references/verification-excellence.md"
SPEC = ROOT / "shipglows_data/workflow/specs/industrial-excellence-quality-doctrine.md"


def normalized(path: Path) -> str:
    return " ".join(path.read_text(encoding="utf-8").split()).casefold()


class IndustrialExcellenceContractTests(unittest.TestCase):
    def test_shared_baseline_blocks_merely_functional_delivery(self) -> None:
        text = normalized(DECISION)
        for marker in (
            "industrial excellence gate",
            "merely functional",
            "unintentionally generic for the accepted product",
            "unresolved provisional elements presented as final",
            "partial",
            "industrial-grade",
            "scales with consequence",
        ):
            self.assertIn(marker, text)

    def test_implementation_requires_operational_resilience(self) -> None:
        text = normalized(IMPLEMENTATION)
        for marker in (
            "critical-system rigor",
            "failure modes",
            "observability",
            "recovery",
            "degraded behavior",
            "compatibility and migration",
            "performance budgets",
        ):
            self.assertIn(marker, text)

    def test_future_proofing_is_not_speculative_architecture(self) -> None:
        text = normalized(IMPLEMENTATION)
        self.assertIn("future-proofing gate", text)
        self.assertIn("demonstrated evolution pressure", text)
        self.assertIn("speculative abstraction", text)
        self.assertIn("replaceable boundaries", text)

    def test_clean_code_rejects_draft_and_generated_clutter(self) -> None:
        text = normalized(CLEAN_CODE)
        for marker in (
            "production-ready finish",
            "unresolved implementation/content placeholders",
            "debug scaffolding",
            "generated clutter",
            "duplicated knowledge",
            "deliberately accepted follow-up",
        ):
            self.assertIn(marker, text)

    def test_design_separates_brand_craft_from_operational_clarity(self) -> None:
        text = normalized(DESIGN)
        for marker in (
            "award-caliber craft gate",
            "brand and marketing surfaces",
            "sotd/awwwards-level benchmark",
            "operational and government-service interfaces",
            "clarity-first",
            "template-like",
        ):
            self.assertIn(marker, text)

    def test_excellence_does_not_license_overengineering_or_false_claims(self) -> None:
        decision = normalized(DECISION)
        implementation = normalized(IMPLEMENTATION)
        design = normalized(DESIGN)
        self.assertIn("complexity is not excellence", decision)
        self.assertIn("reject speculative abstraction", implementation)
        self.assertIn("not a promise of an award", design)
        self.assertIn("never permission to imitate", design)
        self.assertIn("speed outrank spectacle", design)

    def test_visual_ambition_never_weakens_product_quality(self) -> None:
        text = normalized(DESIGN)
        for marker in (
            "accessibility",
            "readability",
            "conversion",
            "performance",
            "maintainability",
            "reduced motion",
        ):
            self.assertIn(marker, text)

    def test_institutional_names_never_imply_unproven_compliance(self) -> None:
        text = normalized(DECISION)
        for marker in (
            "nasa",
            "government",
            "anssi",
            "rgaa",
            "secnumcloud",
            "framework-specific scoped audit and direct evidence",
        ):
            self.assertIn(marker, text)

    def test_excellence_verification_challenges_industrial_and_visual_gaps(self) -> None:
        text = normalized(EXCELLENCE)
        for marker in (
            "industrial excellence",
            "merely functional",
            "award-caliber",
            "critical-system rigor",
            "unsupported compliance",
        ):
            self.assertIn(marker, text)

    def test_durable_spec_preserves_the_qualified_completion_boundary(self) -> None:
        text = normalized(SPEC)
        for marker in (
            "unintentionally generic for the accepted product",
            "unresolved provisional work presented as final",
            "framework-specific scoped audit against named requirements and direct evidence",
        ):
            self.assertIn(marker, text)


if __name__ == "__main__":
    unittest.main()
