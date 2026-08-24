#!/usr/bin/env python3
"""Focused scenario contract for progressive clarity and preserved agency."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
REFS = ROOT / "skills" / "references"


class ProgressiveClarityAndAgencyContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.contract = (REFS / "progressive-clarity-and-agency-contract.md").read_text(encoding="utf-8")
        cls.decision_chain = (REFS / "product-decision-chain.md").read_text(encoding="utf-8")
        cls.partnership = (REFS / "operator-partnership-contract.md").read_text(encoding="utf-8")
        cls.entitlements = (REFS / "product-entitlement-support-and-proof.md").read_text(encoding="utf-8")

    def test_core_progression_preserves_clarity_and_agency(self) -> None:
        for marker in (
            "state → consequence → value or reason → valid options → recovery",
            "Do not manufacture emotional pressure",
            "Genuine Urgency Boundary",
            "Withholding a material consequence is not progressive disclosure",
            "PCA-001",
            "PCA-008",
        ):
            self.assertIn(marker, self.contract)

    def test_targeted_entrypoints_link_without_global_activation(self) -> None:
        reference = "progressive-clarity-and-agency-contract.md"
        self.assertIn(reference, self.decision_chain)
        self.assertIn(reference, self.partnership)
        self.assertIn(reference, self.entitlements)
        self.assertIn("Do not load or cite it for ordinary low-stakes", self.contract)


if __name__ == "__main__":
    unittest.main()
