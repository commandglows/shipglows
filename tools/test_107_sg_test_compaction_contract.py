#!/usr/bin/env python3
"""Scenario-first checks for compact 107-sg-test activation."""

from pathlib import Path
import re
import unittest

from tools.skill_budget_audit import read_frontmatter

ROOT = Path(__file__).resolve().parents[1]
DIR = ROOT / "skills" / "107-sg-test"
SKILL = (DIR / "SKILL.md").read_text(encoding="utf-8")
PACKS = ("qa-scenario-and-prompt.md", "qa-records-and-routing.md")
REFS = {name: (DIR / "references" / name).read_text(encoding="utf-8") for name in PACKS}
INDEX = (DIR / "references" / "manual-qa-workflow.md").read_text(encoding="utf-8")


class TestCompactionContractTests(unittest.TestCase):
    def test_budget_and_progressive_route(self) -> None:
        _, errors, _, tokens = read_frontmatter(DIR / "SKILL.md")
        self.assertEqual(errors, [])
        self.assertLessEqual(tokens, 1500)
        self.assertLess(SKILL.index(PACKS[0]), SKILL.index(PACKS[1]))
        self.assertIn("Only after user/tool evidence exists", SKILL)
        self.assertIn("Load at most one local pack before the first substantive action", SKILL)
        self.assertIn("compatibility index only", SKILL)

    def test_no_evidence_never_becomes_a_result(self) -> None:
        for marker in (
            "Never invent test results",
            "status is `not run`",
            "Do not log pass/fail before the operator answers",
            "Technical checks never impersonate required human validation",
            "Before evidence, output only the manual test card",
        ):
            self.assertIn(marker, SKILL)

    def test_environment_security_and_record_boundaries_are_local(self) -> None:
        for marker in (
            "project-development-mode.md",
            "preview-proof-routing.md",
            "email-work-routing.md",
            "project-runtime-policy.md",
            "runtime-diagnostics-surface.md",
            "sentry-observability.md",
            "local proof there is explicitly non-authoritative",
            "405-sg-prod",
            "109-sg-auth-debug",
            "TEST_LOG.md",
            "BUG-ID.md",
            "Never mark `closed` directly",
            "Never commit or push",
            "seven ceremonial tests",
        ):
            self.assertIn(marker, SKILL)

    def test_packs_are_governed_direct_and_preserve_flow(self) -> None:
        for name, text in REFS.items():
            for marker in ("artifact: skill_reference", "status: active", "source_skill: 107-sg-test"):
                self.assertIn(marker, text, name)
            self.assertIsNone(re.search(r"skills/107-sg-test/references/[^`\s]+\.md", text), name)
        self.assertIn("Do not interpret silence as pass", REFS[PACKS[0]])
        self.assertIn("Never claim fixed, verified, closed, released, or shipped", REFS[PACKS[1]])
        self.assertIn("Do not load this index during execution", INDEX)


if __name__ == "__main__":
    unittest.main()
