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
            "deferred/searchable current-turn tool catalogs",
            "smallest read-only Playwright probe",
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

    def test_implementation_signoff_has_shared_functional_and_visual_coverage(self) -> None:
        proof = REFS[PACKS[0]]
        for marker in (
            "BROWSER-SIGNOFF-001",
            "the operator's accepted requirements",
            "the user-visible features and behavior actually implemented",
            "every user-visible claim intended for the final report",
            "at least two safe exploratory or off-happy-path scenarios",
            "supports persistent handles",
            "normal user inputs",
            "Run visual QA separately from the functional pass",
            "initial viewport before scrolling",
            "densest realistic reachable state",
            "minimum supported viewport",
            "Visible clipping, occlusion, or cutoff remains a failure",
            "Functional correctness, viewport fit, and visual quality pass independently",
        ):
            self.assertIn(marker, proof)
        self.assertIn("Simple screenshot", SKILL)
        self.assertIn("do not trigger the full signoff matrix", SKILL)

    def test_deferred_playwright_discovery_prevents_visible_list_false_negative(self) -> None:
        runtime = (ROOT / "skills/references/agent-runtime-awareness.md").read_text(encoding="utf-8")
        playwright = (ROOT / "skills/references/playwright-mcp-runtime.md").read_text(encoding="utf-8")
        direct = runtime.index("inspect tools exposed directly")
        deferred = runtime.index("deferred or searchable tool catalog")
        probe = runtime.index("smallest read-only probe")
        unavailable = runtime.index("Absence from the first visible tool list")
        self.assertLess(direct, deferred)
        self.assertLess(deferred, probe)
        self.assertLess(probe, unavailable)
        for marker in ("ALL_TOOLS", "tool_search", "mcp__playwright__*", "`discovered`", "`callable`", "`failed`", "`not exposed`"):
            self.assertIn(marker, runtime)
        self.assertIn("default browser automation lane", playwright)
        self.assertIn("playwright-interactive", playwright)
        self.assertIn("never makes a working\nPlaywright MCP unavailable", playwright)

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
