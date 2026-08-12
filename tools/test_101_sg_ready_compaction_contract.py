#!/usr/bin/env python3
"""Scenario-first checks for progressive 101-sg-ready activation."""

from pathlib import Path
import re
import unittest

from tools.skill_budget_audit import read_frontmatter


ROOT = Path(__file__).resolve().parents[1]
DIR = ROOT / "skills" / "101-sg-ready"
SKILL = (DIR / "SKILL.md").read_text(encoding="utf-8")
PACKS = (
    "readiness-baseline.md",
    "readiness-risk-review.md",
    "readiness-transition-and-report.md",
)
REFS = {name: (DIR / "references" / name).read_text(encoding="utf-8") for name in PACKS}
INDEX = (DIR / "references" / "readiness-review-playbook.md").read_text(encoding="utf-8")


class ReadyCompactionContractTests(unittest.TestCase):
    def test_body_budget_and_activation_signals(self) -> None:
        _, errors, _, tokens = read_frontmatter(DIR / "SKILL.md")
        self.assertEqual(errors, [])
        self.assertLessEqual(tokens, 1700)
        for marker in (
            "## Mission",
            "## Scope Gate",
            "## Progressive Readiness Packs",
            "## Readiness Verdict",
            "## Stop Conditions",
            "## Validation",
        ):
            self.assertIn(marker, SKILL)

    def test_baseline_first_and_other_packs_are_gated(self) -> None:
        progressive = SKILL.split("## Progressive Readiness Packs", 1)[1].split("## Conditional Authorities", 1)[0]
        self.assertIn("Every resolved spec loads", progressive)
        self.assertIn("only for adversarial", progressive)
        self.assertIn("After the verdict is determined", progressive)
        self.assertIn("Load at most one local pack before the first substantive decision", progressive)
        self.assertIn("compatibility index only", progressive)

    def test_verdict_and_critical_stops_remain_local(self) -> None:
        for marker in (
            "fresh agent can implement it without blocking ambiguity",
            "generous inference",
            "ZOMBIES coverage",
            "preferred stacks",
            "operator agreement",
            "OWASP Security Gate",
            "$SHIPGLOWS_ROOT/skills/references/owasp-application-security-awareness.md",
            "product-decision-chain.md",
            "not implementation, proof completion, closure, or shipping",
        ):
            self.assertIn(marker, SKILL)

    def test_leaf_packs_are_governed_and_direct(self) -> None:
        for name, text in REFS.items():
            for marker in (
                "artifact: skill_reference",
                'metadata_schema_version: "1.0"',
                "status: active",
                "source_skill: 101-sg-ready",
            ):
                self.assertIn(marker, text, name)
            self.assertIsNone(re.search(r"skills/101-sg-ready/references/[^`\s]+\.md", text), name)
        self.assertIn("Do not load this index during execution", INDEX)

    def test_security_transition_and_reports_stay_followable(self) -> None:
        self.assertIn("OWASP Security Gate", REFS["readiness-risk-review.md"])
        transition = REFS["readiness-transition-and-report.md"]
        for marker in ("Atomic transition", "lint metadata", "not implemented, verified, closed, or shipped"):
            self.assertIn(marker, transition)
        self.assertIn("In `report=user`", INDEX)
        self.assertIn("Use the detailed form", INDEX)


if __name__ == "__main__":
    unittest.main()
