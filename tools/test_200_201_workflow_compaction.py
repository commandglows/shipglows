#!/usr/bin/env python3
"""Focused regression checks for Wave 16 redact/enrich compaction."""

from pathlib import Path
import re
import unittest


ROOT = Path(__file__).resolve().parents[1]
OWNERS = {
    "200-sg-redact": ("redaction-workflow.md", "redaction-"),
    "201-sg-enrich": ("enrichment-workflow.md", "enrichment-"),
}
MAX_ESTIMATED_TOKENS = 1800


def estimated_tokens(text: str) -> int:
    return (len(text) + 3) // 4


class WorkflowCompactionTests(unittest.TestCase):
    def test_owner_bodies_keep_activation_critical_gates(self) -> None:
        required = (
            "## Canonical Paths",
            "Trace category: `conditionnel`",
            "Process role: `support-de-chantier`",
            "## Report Modes",
            "decision-quality-contract.md",
            "content-quality-rubric.md",
            "## Stop Conditions",
            "leaves never load siblings",
        )
        for owner in OWNERS:
            body = (ROOT / "skills" / owner / "SKILL.md").read_text(encoding="utf-8")
            for phrase in required:
                with self.subTest(owner=owner, phrase=phrase):
                    self.assertIn(phrase, body)

    def test_indexes_are_compact_and_expose_direct_scenario_routes(self) -> None:
        for owner, (index_name, prefix) in OWNERS.items():
            refs = ROOT / "skills" / owner / "references"
            index = (refs / index_name).read_text(encoding="utf-8")
            self.assertLessEqual(estimated_tokens(index), MAX_ESTIMATED_TOKENS)
            leaves = sorted(p for p in refs.glob(f"{prefix}*.md") if p.name != index_name)
            self.assertGreaterEqual(len(leaves), 4)
            for leaf in leaves:
                self.assertIn(f"references/{leaf.name}", index)
                self.assertLessEqual(estimated_tokens(leaf.read_text(encoding="utf-8")), MAX_ESTIMATED_TOKENS)

    def test_sibling_leaves_do_not_chain(self) -> None:
        for owner, (index_name, prefix) in OWNERS.items():
            refs = ROOT / "skills" / owner / "references"
            leaves = sorted(p for p in refs.glob(f"{prefix}*.md") if p.name != index_name)
            leaf_names = {p.name for p in leaves}
            for leaf in leaves:
                text = leaf.read_text(encoding="utf-8")
                references = set(re.findall(r"references/([a-z0-9-]+\.md)", text))
                with self.subTest(owner=owner, leaf=leaf.name):
                    self.assertFalse(references & leaf_names)

    def test_security_and_fidelity_terms_remain_visible(self) -> None:
        redact = (ROOT / "skills/200-sg-redact/references/redaction-workflow.md").read_text(encoding="utf-8")
        enrich = (ROOT / "skills/201-sg-enrich/references/enrichment-workflow.md").read_text(encoding="utf-8")
        for phrase in ("Never invent", "copyright", "content schema", "author identity", "quality rubric"):
            self.assertIn(phrase, redact)
        for phrase in ("Never invent", "author voice", "content schema", "product promise", "quality rubric"):
            self.assertIn(phrase, enrich)


if __name__ == "__main__":
    unittest.main()
