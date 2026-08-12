#!/usr/bin/env python3
"""Scenario-first checks for the compact audit master workflow."""

from pathlib import Path
import re
import unittest

from tools.skill_budget_audit import read_frontmatter

ROOT = Path(__file__).resolve().parents[1]
DIR = ROOT / "skills" / "400-sg-audit" / "references"
CORE = (DIR / "audit-master-workflow.md").read_text(encoding="utf-8")
LEAVES = (
    "audit-scope-and-routing.md",
    "audit-consolidation-and-proof.md",
    "audit-records-and-remediation.md",
)


class AuditCompactionContractTests(unittest.TestCase):
    def test_core_is_compact_and_routes_directly(self) -> None:
        _, errors, _, tokens = read_frontmatter(DIR / "audit-master-workflow.md")
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
            for marker in ("artifact: skill_reference", "status: active", "source_skill: 400-sg-audit"):
                self.assertIn(marker, text, leaf)

    def test_decision_security_and_proof_gates_survive(self) -> None:
        corpus = CORE + "\n" + "\n".join((DIR / leaf).read_text(encoding="utf-8") for leaf in LEAVES)
        for marker in (
            "read-only", "Never expose secrets", "missing proof", "confidence",
            "operational-record", "Never auto-fix", "OWASP", "project × domain",
        ):
            self.assertIn(marker, corpus)


if __name__ == "__main__":
    unittest.main()
