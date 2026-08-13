#!/usr/bin/env python3
"""Contracts for the Wave 15 progressive decision-quality split."""

import json
from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
CORE_PATH = ROOT / "skills" / "references" / "decision-quality-contract.md"
LEAF_PATH = ROOT / "skills" / "references" / "decision-quality-implementation-discipline.md"
REGISTRY_PATH = ROOT / "skills" / "references" / "skill-invocation-registry.json"


def estimate_tokens(path: Path) -> int:
    return (len(path.read_text(encoding="utf-8")) + 3) // 4


class DecisionQualityProgressiveContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.core = CORE_PATH.read_text(encoding="utf-8")
        cls.leaf = LEAF_PATH.read_text(encoding="utf-8")
        cls.registry = json.loads(REGISTRY_PATH.read_text(encoding="utf-8"))

    def test_canonical_core_stays_within_progressive_budget(self) -> None:
        self.assertLessEqual(estimate_tokens(CORE_PATH), 1800)

    def test_core_preserves_mechanical_decision_gates(self) -> None:
        for marker in (
            "Decision Quality Baseline",
            "Structure Replacement Fit",
            "Fast Fix Shortcut Gate",
            "Safety Gate",
            "Product Gate",
            "Operator Autonomy Gate",
            "Followability Gate",
            "Smallest safe path",
            "matching proof",
            "Industrial Excellence Gate",
        ):
            self.assertIn(marker, self.core)

    def test_core_routes_conditional_authorities_directly(self) -> None:
        for path in (
            "skills/references/decision-quality-implementation-discipline.md",
            "skills/references/design-system-token-contract.md",
            "operator-partnership-contract.md",
            "question-contract.md",
            "product-decision-chain.md",
            "skill-instruction-layering.md",
        ):
            self.assertIn(path, self.core)
        self.assertIn("never chain through sibling leaves", self.core)

    def test_implementation_leaf_is_direct_and_non_chaining(self) -> None:
        self.assertIn('artifact: "skills/references/decision-quality-contract.md"', self.leaf)
        self.assertIn("This leaf does not load or select other conditional leaves", self.leaf)
        for sibling in (
            "design-system-token-contract.md",
            "operator-partnership-contract.md",
            "question-contract.md",
            "product-decision-chain.md",
            "skill-instruction-layering.md",
        ):
            self.assertNotIn(sibling, self.leaf)

    def test_leaf_preserves_durable_repair_and_mitigation_pressure(self) -> None:
        for marker in (
            "Diagnose the root cause",
            "canonical owner boundary",
            "smallest complete professional change",
            "Targeted edits protect the worktree",
            "Mitigation Contract",
            "fail or report partial",
        ):
            self.assertIn(marker, self.leaf)

    def test_measured_profiles_keep_the_canonical_core_path(self) -> None:
        profiles = self.registry["activation_profiles"]["skills"]
        decision_path = "skills/references/decision-quality-contract.md"
        self.assertIn(decision_path, profiles["010-sg-technical"]["baseline"])
        self.assertIn(decision_path, profiles["103-sg-verify"]["baseline"])
        self.assertIn(decision_path, profiles["601-sg-product-entitlements"]["gates"]["ownership-decision"])


if __name__ == "__main__":
    unittest.main()
