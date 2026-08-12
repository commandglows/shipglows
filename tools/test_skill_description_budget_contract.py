#!/usr/bin/env python3
"""Contracts for concise expert discovery descriptions."""

from pathlib import Path
import re
import unittest


ROOT = Path(__file__).resolve().parents[1]


def description(skill: str) -> str:
    text = (ROOT / "skills" / skill / "SKILL.md").read_text(encoding="utf-8")
    return re.search(r'^description:\s*"([^"]+)"$', text, re.MULTILINE).group(1)


class SkillDescriptionBudgetContractTests(unittest.TestCase):
    def test_compacted_experts_preserve_trigger_vocabulary(self) -> None:
        expected = {
            "006-sg-design": ("Design systems", "accessibility", "audits"),
            "007-sg-content": ("public content", "source", "publication"),
            "009-sg-marketing": ("markets", "GTM", "copy"),
            "010-sg-technical": ("Architecture", "dependencies", "performance", "sync", "access"),
            "011-sg-pilotage": ("Tasks", "backlog", "priorities", "Codex session"),
            "202-sg-emailing": ("email", "delivery", "authentication"),
            "407-sg-translate": ("translations", "localized"),
            "601-sg-product-entitlements": ("entitlement", "provider-event", "mirror"),
        }
        for skill, markers in expected.items():
            value = description(skill)
            self.assertLessEqual(len(value), 80, skill)
            for marker in markers:
                self.assertIn(marker, value, skill)

    def test_compatibility_email_alias_matches_canonical_description(self) -> None:
        self.assertEqual(description("202-sg-emailing"), description("emailing"))


if __name__ == "__main__":
    unittest.main()
