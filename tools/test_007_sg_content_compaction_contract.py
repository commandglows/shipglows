#!/usr/bin/env python3
"""Scenario-first contract for compact content lifecycle activation."""

from pathlib import Path
import re
import unittest

from tools.skill_budget_audit import read_frontmatter

ROOT = Path(__file__).resolve().parents[1]
DIR = ROOT / "skills" / "007-sg-content"
SKILL = (DIR / "SKILL.md").read_text(encoding="utf-8")
PACKS = ("content-router.md", "content-governance-and-quality.md", "content-delivery-and-proof.md")
REFS = {name: (DIR / "references" / name).read_text(encoding="utf-8") for name in PACKS}


class ContentCompactionContractTests(unittest.TestCase):
    def test_budget_and_route_before_lifecycle(self) -> None:
        _, errors, _, tokens = read_frontmatter(DIR / "SKILL.md")
        self.assertEqual([], errors)
        self.assertLessEqual(tokens, 1800)
        self.assertLess(SKILL.index("content-router.md"), SKILL.index("master-workflow-lifecycle.md"))
        self.assertIn("Load at most one local playbook before the first substantive action", SKILL)

    def test_atomic_preflight_claim_and_surface_gates_remain_local(self) -> None:
        for marker in (
            "skill-invocation-preflight.md", "Do not activate it for an explicit atomic string",
            "Execute that change directly", "Never invent an undeclared public surface",
            "Treat public claims as product promises", "repurpose ... verbatim",
        ):
            self.assertIn(marker, SKILL)

    def test_conditional_authorities_are_exact_and_followable(self) -> None:
        for marker in (
            "content-owner-handoffs.md", "source-intake-classification.md", "editorial-content-corpus.md",
            "content-quality-rubric.md", "public-first-content-default.md", "repurpose-pack-storage.md",
            "documentation-freshness-gate.md", "design-inspiration-library.md",
        ):
            self.assertIn(marker, SKILL)

    def test_direct_packs_do_not_chain_locally(self) -> None:
        for name in PACKS[1:]:
            self.assertIsNone(re.search(r"skills/007-sg-content/references/[^`\s]+\.md", REFS[name]), name)
        self.assertIn("bare `repurpose` asks for a source", REFS["content-router.md"])
        self.assertIn("fresh-docs not needed", REFS["content-delivery-and-proof.md"])


if __name__ == "__main__":
    unittest.main()
