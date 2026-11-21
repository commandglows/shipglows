#!/usr/bin/env python3
"""Contract checks that keep requirements from being rationalized away."""

from __future__ import annotations

import re
import unittest
from pathlib import Path

from tools.shipglows_conversation_audit import OWNER_BY_CATEGORY, classify

ROOT = Path(__file__).resolve().parents[1]
SPEC = ROOT / "skills/references/spec-driven-development-discipline.md"
CLOSURE = ROOT / "skills/references/reporting-closure.md"
AUDIT = ROOT / "skills/705-sg-conversation-audit/SKILL.md"
VERIFY = ROOT / "skills/103-sg-verify/references/verification-baseline.md"
END = ROOT / "skills/104-sg-end/SKILL.md"
BLOCK = ROOT / "cli/windows/ShipGlows.AgentInstructions.psm1"
TEST_POLICY_SURFACES = (
    ROOT / "skills/references/flutter-engineering-playbook.md",
    ROOT / "skills/references/flutter-quality-playbook.md",
    ROOT / "skills/references/operator-roles/flutter-specialist.md",
)


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


class RequirementStickinessTests(unittest.TestCase):
    def test_spec_discipline_pins_test_first_and_external_measurement(self) -> None:
        text = read(SPEC)
        for phrase in (
            "critical or counter-intuitive requirement",
            "Never edit the test to make it pass",
            "git diff",
            "Verify claims externally",
            "never trust numbers the program prints about itself",
        ):
            self.assertIn(phrase, text)

    def test_closure_requires_enumerated_requirement_ledger(self) -> None:
        text = read(CLOSURE)
        card = text.split("```text", 1)[1].split("```", 1)[0]
        self.assertIn("📋 EXIGENCES", card)
        self.assertLess(card.index("✨ RÉSULTAT"), card.index("📋 EXIGENCES"))
        self.assertLess(card.index("📋 EXIGENCES"), card.index("🧪 PREUVES"))
        for phrase in (
            "`📋 EXIGENCES` is mandatory",
            "every requirement of the request",
            "deliberately not done",
        ):
            self.assertIn(phrase, text)
        self.assertNotIn("`⚠️ LIMITES` is conditional", text)
        self.assertNotIn("Add `⚠️ LIMITES` only when material", read(END))

    def test_conversation_audit_names_rationalized_requirement_signals(self) -> None:
        text = read(AUDIT)
        self.assertIn("`requirement_rationalized`", text)
        for signal in (
            "grader", "grading", "pass rate", "hidden tests", "follow the tests",
            "unlikely", "peu probable", "les tests attendent", "probablement pas testé",
            "self-reported",
        ):
            self.assertIn(signal, text)
        self.assertIn("a lead, not proof", text)
        self.assertIn("requirement_rationalized", OWNER_BY_CATEGORY)

    def test_classifier_flags_fr_and_en_rationalization(self) -> None:
        for sample in (
            "The grader probably only checks the output, so I dropped the limit.",
            "Hidden tests are unlikely to cover this branch.",
            "Je retire la contrainte : c'est probablement pas testé.",
            "Les tests attendent l'ancien format, je reviens en arrière.",
            "I will follow the tests instead of the spec.",
        ):
            categories = {finding.category for finding in classify(sample)}
            self.assertIn("requirement_rationalized", categories, sample)
        neutral = {finding.category for finding in classify("Implemented the limit and measured it.")}
        self.assertNotIn("requirement_rationalized", neutral)

    def test_verify_runs_independent_property_check_and_reads_diff(self) -> None:
        text = read(VERIFY)
        for phrase in (
            "distinct agent",
            "property-level check",
            "after implementation",
            "`git status`",
            "`git diff --stat`",
            "never the implementer's summary",
        ):
            self.assertIn(phrase, text)

    def test_policy_surfaces_allow_checks_and_gate_builds(self) -> None:
        stale = re.compile(r"only when the operator asks or a bug is confirmed|unless requested or a bug is confirmed")
        for path in TEST_POLICY_SURFACES:
            self.assertIsNone(stale.search(read(path)), path)
        block = read(BLOCK)
        self.assertIn("Lint, analyze, type checks and tests run without asking", block)
        self.assertIn("builds need operator approval", block)


if __name__ == "__main__":
    unittest.main()
