#!/usr/bin/env python3
"""Scenario-first checks for compact entitlement activation."""

from pathlib import Path
import unittest

from tools.skill_budget_audit import read_frontmatter

ROOT = Path(__file__).resolve().parents[1]
SKILL = ROOT / "skills" / "601-sg-product-entitlements" / "SKILL.md"
TEXT = SKILL.read_text(encoding="utf-8")


class ProductEntitlementsCompactionContractTests(unittest.TestCase):
    def test_budget_and_progressive_authorities(self) -> None:
        _, errors, _, tokens = read_frontmatter(SKILL)
        self.assertEqual([], errors)
        self.assertLessEqual(tokens, 1400)
        self.assertIn("Load at most one entitlement doctrine before the first substantive action", TEXT)

    def test_access_security_gates_remain_local(self) -> None:
        for marker in (
            "Authentication proves identity only", "event sources, not runtime authorization sources",
            "Fail closed", "replay rejection", "bearer credentials", "revocation/refund/expiry",
            "UI and client claims are non-authoritative",
        ):
            self.assertIn(marker, TEXT)

    def test_owner_and_freshness_routes_are_followable(self) -> None:
        for marker in (
            "600", "109", "product-entitlements-playbook.md", "winflowz-suite-product-registry.md",
            "spec-driven-development-discipline.md", "documentation-freshness-gate.md", "SPE-001",
        ):
            self.assertIn(marker, TEXT)


if __name__ == "__main__":
    unittest.main()
