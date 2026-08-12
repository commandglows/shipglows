#!/usr/bin/env python3
"""Scenario-first checks for compact 109-sg-auth-debug activation."""

from pathlib import Path
import re
import unittest

from tools.skill_budget_audit import read_frontmatter

ROOT = Path(__file__).resolve().parents[1]
DIR = ROOT / "skills" / "109-sg-auth-debug"
SKILL = (DIR / "SKILL.md").read_text(encoding="utf-8")
CORE = (DIR / "references" / "auth-debug-workflow.md").read_text(encoding="utf-8")
LEAVES = (
    "auth-intake-and-authority.md",
    "auth-provider-routing.md",
    "auth-browser-proof.md",
    "auth-diagnosis-and-report.md",
)
REFS = {name: (DIR / "references" / name).read_text(encoding="utf-8") for name in LEAVES}


class AuthDebugCompactionContractTests(unittest.TestCase):
    def test_budget_and_direct_progressive_routes(self) -> None:
        _, errors, _, tokens = read_frontmatter(DIR / "SKILL.md")
        self.assertEqual(errors, [])
        self.assertLessEqual(tokens, 1850)
        self.assertIn("mandatory compact first-decision core", SKILL)
        self.assertIn("No leaf may load a sibling leaf", SKILL)
        for name in LEAVES:
            self.assertIn(name, SKILL)
            self.assertIn(name, CORE)

    def test_activation_keeps_owner_authority_and_security_stops(self) -> None:
        for marker in (
            "108-sg-browser", "107-sg-test", "405-sg-prod", "106-sg-fix",
            "Never bypass auth", "weaken authorization", "primary account",
            "provider/production state", "local success is not authoritative",
            "secrets, cookies, tokens, OTPs", "Stop Conditions",
        ):
            self.assertIn(marker, SKILL)

    def test_core_keeps_proof_and_redaction_stops(self) -> None:
        for marker in (
            "Never expose or request raw secrets", "raw HAR", "Never bypass auth",
            "hosted authority is required", "partial", "blocked", "human step",
        ):
            self.assertIn(marker, CORE)

    def test_leaves_are_governed_and_do_not_chain_to_siblings(self) -> None:
        for name, body in REFS.items():
            for marker in ("artifact: skill_reference", "status: active", "source_skill: 109-sg-auth-debug"):
                self.assertIn(marker, body, name)
            for sibling in LEAVES:
                if sibling != name:
                    self.assertIsNone(re.search(rf"(?:references/)?{re.escape(sibling)}", body), name)

    def test_browser_and_report_proof_remain_actionable(self) -> None:
        browser = REFS["auth-browser-proof.md"]
        for marker in ("playwright-mcp-runtime.md", "405-sg-prod", "raw HAR", "Sentry", "Paris/UTC", "partial"):
            self.assertIn(marker, browser)
        report = REFS["auth-diagnosis-and-report.md"]
        for marker in ("symptom, observation, hypothesis", "automation status", "100-sg-spec", "103-sg-verify", "PII"):
            self.assertIn(marker, report)


if __name__ == "__main__":
    unittest.main()
