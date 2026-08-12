#!/usr/bin/env python3
"""Scenario-first checks for compact release activation."""

from pathlib import Path
import unittest

from tools.skill_budget_audit import read_frontmatter

ROOT = Path(__file__).resolve().parents[1]
SKILL = ROOT / "skills" / "004-sg-deploy" / "SKILL.md"
TEXT = SKILL.read_text(encoding="utf-8")


class DeployCompactionContractTests(unittest.TestCase):
    def test_budget_and_progressive_route(self) -> None:
        _, errors, _, tokens = read_frontmatter(SKILL)
        self.assertEqual([], errors)
        self.assertLessEqual(tokens, 1600)
        self.assertIn("Load at most one local playbook before the first substantive action", TEXT)
        self.assertLess(TEXT.index("release-confidence-workflow.md"), TEXT.index("release-proof-routing.md"))

    def test_release_truth_and_gate_order_remain_local(self) -> None:
        for marker in (
            "never treats a green check, push, deploy status, or `200 OK` as product proof",
            "`105-sg-check nofix`", "`005-sg-ship`", "`405-sg-prod`",
            "`103-sg-verify`", "never claim `deployed` before final verification",
        ):
            self.assertIn(marker, TEXT)

    def test_safety_and_conditional_authorities_remain_followable(self) -> None:
        for marker in (
            "project-development-mode.md", "preview-proof-routing.md",
            "master-delegation-semantics.md", "owasp-application-security-awareness.md",
            "email-work-routing.md", "production data mutation without approval", "raw HAR",
        ):
            self.assertIn(marker, TEXT)


if __name__ == "__main__":
    unittest.main()
