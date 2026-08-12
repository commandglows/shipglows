#!/usr/bin/env python3
"""Scenario-first contract for compact local-cloud sync activation."""

from pathlib import Path
import re
import unittest

from tools.skill_budget_audit import read_frontmatter

ROOT = Path(__file__).resolve().parents[1]
DIR = ROOT / "skills" / "600-sg-local-cloud-sync"
SKILL = (DIR / "SKILL.md").read_text(encoding="utf-8")
LEAF = (DIR / "references" / "sync-contract-proof-and-report.md").read_text(encoding="utf-8")


class LocalCloudSyncCompactionContractTests(unittest.TestCase):
    def test_budget_and_progressive_loading(self) -> None:
        _, errors, _, tokens = read_frontmatter(DIR / "SKILL.md")
        self.assertEqual([], errors)
        self.assertLessEqual(tokens, 1600)
        self.assertIn("Load at most one local playbook before the first substantive action", SKILL)
        self.assertLess(SKILL.index("local-cloud-sync-doctrine.md"), SKILL.index("sync-contract-proof-and-report.md"))

    def test_data_loss_and_security_stops_remain_local(self) -> None:
        for marker in (
            "Never silently wipe local data", "replay it across accounts", "Latest-wins requires",
            "Secrets, credentials, tokens", "server/provider ownership", "`saved locally` is not `synced`",
            "durable remote write and hydration proof",
        ):
            self.assertIn(marker, SKILL)

    def test_routes_and_conditional_authorities_are_followable(self) -> None:
        for marker in (
            "601-sg-product-entitlements", "008-sg-customer", "spec-driven-development-discipline.md",
            "master-workflow-lifecycle.md", "documentation-freshness-gate.md",
            "sync-guidance-overlay-and-merge-pattern.md", "flutter-implementation-checklist.md",
        ):
            self.assertIn(marker, SKILL)

    def test_leaf_is_governed_and_does_not_chain_locally(self) -> None:
        self.assertIn("artifact: skill_reference", LEAF)
        self.assertIn("status: active", LEAF)
        self.assertIn("Documentation Update Plan", LEAF)
        self.assertIsNone(re.search(r"skills/600-sg-local-cloud-sync/references/[^`\s]+\.md", LEAF))


if __name__ == "__main__":
    unittest.main()
