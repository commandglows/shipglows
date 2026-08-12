#!/usr/bin/env python3
"""Scenario-first checks for progressive 100-sg-spec activation."""

from pathlib import Path
import re
import unittest

from tools.skill_budget_audit import read_frontmatter


ROOT = Path(__file__).resolve().parents[1]
DIR = ROOT / "skills" / "100-sg-spec"
SKILL = (DIR / "SKILL.md").read_text(encoding="utf-8")
PACKS = (
    "spec-intake-and-investigation.md",
    "spec-contract-authoring.md",
    "spec-review-and-persistence.md",
)
REFS = {name: (DIR / "references" / name).read_text(encoding="utf-8") for name in PACKS}
INDEX = (DIR / "references" / "spec-creation-workflow.md").read_text(encoding="utf-8")


class SpecCompactionContractTests(unittest.TestCase):
    def test_body_budget_and_activation_signals(self) -> None:
        _, errors, _, tokens = read_frontmatter(DIR / "SKILL.md")
        self.assertEqual(errors, [])
        self.assertLessEqual(tokens, 1700)
        for marker in (
            "## Mission",
            "## Scope Gate",
            "## Progressive Spec Packs",
            "## Conditional Authorities",
            "## Stop Conditions",
            "## Validation",
        ):
            self.assertIn(marker, SKILL)

    def test_route_is_progressive_and_legacy_workflow_is_index_only(self) -> None:
        positions = [SKILL.index(name) for name in PACKS]
        self.assertEqual(positions, sorted(positions))
        self.assertIn("Load at most one local pack before the first substantive decision", SKILL)
        self.assertIn("compatibility index only", SKILL)
        self.assertIn("Do not load this index during execution", INDEX)
        self.assertIn("**Rapport final :**", INDEX)

    def test_owner_and_critical_gates_remain_local(self) -> None:
        for marker in (
            "not readiness approval, implementation, verification, closure, or shipping",
            "Chantier potentiel",
            "decision-quality-contract.md",
            "$SHIPGLOWS_ROOT/skills/references/design-system-token-contract.md",
            "$SHIPGLOWS_ROOT/skills/references/preferred-stacks.md",
            "product-decision-chain.md",
            "$SHIPGLOWS_ROOT/skills/references/zombies-edge-case-heuristic.md",
            "$SHIPGLOWS_ROOT/skills/references/owasp-application-security-awareness.md",
            "OWASP Security Gate",
            "TASKS.md",
            "before → after",
        ):
            self.assertIn(marker, SKILL)

    def test_leaf_packs_are_governed_and_do_not_chain(self) -> None:
        for name, text in REFS.items():
            for marker in (
                "artifact: skill_reference",
                'metadata_schema_version: "1.0"',
                "status: active",
                "source_skill: 100-sg-spec",
            ):
                self.assertIn(marker, text, name)
            self.assertIsNone(re.search(r"skills/100-sg-spec/references/[^`\s]+\.md", text), name)

    def test_contract_is_autonomous_and_ready_is_external(self) -> None:
        authoring = REFS["spec-contract-authoring.md"]
        review = REFS["spec-review-and-persistence.md"]
        for marker in ("Minimal Behavior Contract", "Success Behavior", "Error Behavior", "Test Contract", "ZOMBIES coverage"):
            self.assertIn(marker, authoring)
        self.assertIn("`101-sg-ready` owns transition to `ready`", review)
        self.assertIn("Never implement", review)


if __name__ == "__main__":
    unittest.main()
