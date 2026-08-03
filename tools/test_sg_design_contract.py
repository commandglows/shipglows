#!/usr/bin/env python3
"""Regression checks for shared-token and component migration doctrine."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
TOKEN_CONTRACT = ROOT / "skills" / "references" / "design-system-token-contract.md"
DESIGN_SKILL = ROOT / "skills" / "006-sg-design" / "SKILL.md"
TOKEN_AUDIT = ROOT / "skills" / "006-sg-design" / "references" / "design-token-audit-playbook.md"
COMPONENT_AUDIT = ROOT / "skills" / "006-sg-design" / "references" / "component-system-audit-playbook.md"
A11Y_AUDIT = ROOT / "skills" / "006-sg-design" / "references" / "accessibility-audit-playbook.md"


class DesignContractTests(unittest.TestCase):
    def test_parallel_token_files_do_not_prove_shared_authority(self) -> None:
        contract = TOKEN_CONTRACT.read_text(encoding="utf-8")
        audit = TOKEN_AUDIT.read_text(encoding="utf-8")
        self.assertIn("Multiple applications do not share a design system merely because", contract)
        self.assertIn("Parallel hand-maintained token files", contract)
        self.assertIn("compare resolved values and rendered roles", audit)
        self.assertIn("split-brain authority", audit)

    def test_component_migration_separates_behavior_and_visual_ownership(self) -> None:
        contract = TOKEN_CONTRACT.read_text(encoding="utf-8")
        audit = COMPONENT_AUDIT.read_text(encoding="utf-8")
        self.assertIn("## Behavior And Visual Ownership Gate", contract)
        self.assertIn("headless primitives own semantics, focus, keyboard interaction", contract)
        self.assertIn("project wrappers own visual composition", contract)
        self.assertIn("Never recommend copying vendor component internals", audit)
        self.assertIn("Prefer incremental replacement behind project-owned wrappers", audit)

    def test_keyboard_parity_is_explicit_regression_proof(self) -> None:
        contract = TOKEN_CONTRACT.read_text(encoding="utf-8")
        a11y = A11Y_AUDIT.read_text(encoding="utf-8")
        skill = DESIGN_SKILL.read_text(encoding="utf-8")
        for behavior in (
            "Tab and Shift+Tab order",
            "pattern-specific arrows and Home/End",
            "Escape",
            "focus restoration",
            "application shortcuts",
        ):
            self.assertIn(behavior, contract)
        self.assertIn("build this matrix per affected primitive", a11y)
        self.assertIn("matching screenshots do not prove interaction parity", a11y)
        self.assertIn("copies vendor internals without equivalent regression proof", skill)


if __name__ == "__main__":
    unittest.main()
