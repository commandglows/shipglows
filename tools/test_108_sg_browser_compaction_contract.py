#!/usr/bin/env python3
"""Scenario-first checks for compact 108-sg-browser activation."""

from pathlib import Path
import re
import unittest

from tools.skill_budget_audit import read_frontmatter

ROOT = Path(__file__).resolve().parents[1]
DIR = ROOT / "skills" / "108-sg-browser"
SKILL = (DIR / "SKILL.md").read_text(encoding="utf-8")
PACKS = ("browser-proof-playbook.md", "browser-report-and-routing.md")
REFS = {name: (DIR / "references" / name).read_text(encoding="utf-8") for name in PACKS}
INDEX = (DIR / "references" / "browser-evidence.md").read_text(encoding="utf-8")


class BrowserCompactionContractTests(unittest.TestCase):
    def test_budget_and_progressive_route(self) -> None:
        _, errors, _, tokens = read_frontmatter(DIR / "SKILL.md")
        self.assertEqual(errors, [])
        self.assertLessEqual(tokens, 1700)
        self.assertLess(SKILL.index(PACKS[0]), SKILL.index(PACKS[1]))
        self.assertIn("Load at most one local pack before the first substantive action", SKILL)
        self.assertIn("compatibility index only", SKILL)

    def test_owner_preflight_and_environment_routes_are_local(self) -> None:
        for marker in (
            "109-sg-auth-debug",
            "107-sg-test",
            "405-sg-prod",
            "106-sg-fix",
            "project-development-mode.md",
            "preview-proof-routing.md",
            "playwright-mcp-runtime.md",
            "blocks app diagnosis",
        ):
            self.assertIn(marker, SKILL)

    def test_read_only_production_and_redaction_are_activation_critical(self) -> None:
        for marker in (
            "Default is read-only",
            "Explicit approval is required",
            "purchase, deletion, publish, invite, email, webhook",
            "Never bypass auth",
            "raw HAR",
            "PII",
            "unsafe-action",
            "a narrow pass never proves the whole feature",
        ):
            self.assertIn(marker, SKILL)

    def test_evidence_mismatch_and_diagnostics_are_preserved(self) -> None:
        proof = REFS[PACKS[0]]
        self.assertIn("screenshot and accessibility state disagree", proof)
        self.assertIn("`partial` or `blocked`", proof)
        self.assertIn("Copy diagnostics", proof)
        self.assertIn("Paris/UTC build-time", proof)

    def test_packs_are_governed_direct_and_report_compatible(self) -> None:
        for name, text in REFS.items():
            for marker in ("artifact: skill_reference", "status: active", "source_skill: 108-sg-browser"):
                self.assertIn(marker, text, name)
            self.assertIsNone(re.search(r"skills/108-sg-browser/references/[^`\s]+\.md", text), name)
        self.assertIn("Do not load this index during execution", INDEX)
        self.assertIn("## Report Modes", SKILL)
        self.assertIn("## Final Report Shape", SKILL)
        self.assertIn("🎯 VERDICT (HH:mm)", SKILL)


if __name__ == "__main__":
    unittest.main()
