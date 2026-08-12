#!/usr/bin/env python3
"""Scenario-first checks for compact production verification."""

from pathlib import Path
import re
import unittest

from tools.skill_budget_audit import read_frontmatter

ROOT = Path(__file__).resolve().parents[1]
DIR = ROOT / "skills" / "405-sg-prod" / "references"
CORE = (DIR / "production-verification-workflow.md").read_text(encoding="utf-8")
LEAVES = (
    "prod-deployment-evidence.md",
    "prod-health-and-proof.md",
    "prod-runtime-diagnostics.md",
    "prod-verdict-and-routing.md",
)


class ProdCompactionContractTests(unittest.TestCase):
    def test_core_is_compact_and_routes_directly(self) -> None:
        _, errors, _, tokens = read_frontmatter(DIR / "production-verification-workflow.md")
        self.assertEqual(errors, [])
        self.assertLessEqual(tokens, 900)
        for leaf in LEAVES:
            self.assertIn(f"references/{leaf}", CORE)
        self.assertIn("references are siblings", CORE)

    def test_leaves_do_not_chain_to_siblings(self) -> None:
        pattern = re.compile(r"(?:references/)?(?:" + "|".join(map(re.escape, LEAVES)) + r")")
        for leaf in LEAVES:
            text = (DIR / leaf).read_text(encoding="utf-8")
            self.assertIsNone(pattern.search(text), leaf)
            for marker in ("artifact: skill_reference", "status: active", "source_skill: 405-sg-prod"):
                self.assertIn(marker, text, leaf)

    def test_decision_security_and_proof_gates_survive(self) -> None:
        corpus = CORE + "\n" + "\n".join((DIR / leaf).read_text(encoding="utf-8") for leaf in LEAVES)
        for marker in (
            "terminal state", "Never infer auth", "Never rollback", "truncated",
            "Never expose", "production PII", "proof_type", "owner_skill",
            "target_or_environment", "first causal error", "partial",
        ):
            self.assertIn(marker, corpus)


if __name__ == "__main__":
    unittest.main()
