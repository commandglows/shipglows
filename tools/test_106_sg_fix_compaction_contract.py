#!/usr/bin/env python3
"""Scenario-first checks for the compact 106-sg-fix activation contract."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
SKILL = ROOT / "skills" / "106-sg-fix" / "SKILL.md"
WORKFLOW = ROOT / "skills" / "106-sg-fix" / "references" / "bug-fix-workflow.md"
PROOF = ROOT / "skills" / "106-sg-fix" / "references" / "bug-proof-and-reporting.md"


class FixCompactionContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.skill = SKILL.read_text(encoding="utf-8")
        cls.workflow = WORKFLOW.read_text(encoding="utf-8")
        cls.proof = PROOF.read_text(encoding="utf-8")

    def test_body_budget_and_direct_local_references(self) -> None:
        self.assertLessEqual((len(self.skill) + 3) // 4, 1500)
        for name in ("bug-fix-workflow.md", "bug-proof-and-reporting.md"):
            self.assertIn(name, self.skill)
        self.assertNotIn("bug-proof-and-reporting.md", self.workflow)
        self.assertNotIn("bug-fix-workflow.md", self.proof)

    def test_fix_direct_before_write_loads_mutation_contracts(self) -> None:
        direct = self.skill.index("For a `direct` classification")
        before_write = self.skill.index("Before the first code write")
        self.assertLess(direct, before_write)
        for contract in ("task-application-loop.md", "clean-code-quality-contract.md"):
            self.assertIn(contract, self.skill[before_write:])
        self.assertIn("before the first code write", self.workflow)

    def test_spec_first_and_ambiguity_refs_are_conditional(self) -> None:
        self.assertIn("Load `spec-driven-development-discipline.md`; do not code", self.skill)
        self.assertIn("load `decision-quality-contract.md` before one targeted question", self.skill)
        eager = self.skill.split("## Classification", 1)[0]
        for conditional in (
            "spec-driven-development-discipline.md",
            "decision-quality-contract.md",
            "task-application-loop.md",
            "clean-code-quality-contract.md",
            "project-development-mode.md",
        ):
            self.assertNotIn(conditional, eager)

    def test_diagnostic_only_has_no_write_authority(self) -> None:
        diagnostic = self.skill.split("- `diagnostic-only`:", 1)[1].split("\n\n", 1)[0]
        self.assertIn("do not code", diagnostic)

    def test_development_mode_controls_retest_selection(self) -> None:
        marker = "Before selecting or claiming a retest surface"
        self.assertIn(marker, self.skill)
        self.assertIn("project-development-mode.md", self.skill.split(marker, 1)[1])
        for mode in ("`local`", "`vercel-preview-push`", "`hybrid`"):
            self.assertIn(mode, self.proof)

    def test_visual_proof_and_security_semantics_survive(self) -> None:
        for text in (self.skill, self.workflow, self.proof):
            self.assertIn("person validates the rendered result", text)
        self.assertIn(
            "evidence -> fix-attempted -> retest -> fixed-pending-verify -> verify",
            self.skill,
        )
        for rule in (
            "tenant/resource boundaries",
            "UI-only protection is insufficient",
            "never close without verification",
        ):
            self.assertIn(rule, self.skill)

    def test_stop_conditions_preserve_authority_and_proof_gates(self) -> None:
        stops = self.skill.split("## Security And Stop Conditions", 1)[1]
        for rule in (
            "ambiguity changes product meaning",
            "root-cause hypothesis",
            "regression/evidence path",
            "durable bug memory",
            "preview-push proof",
            "fresh external documentation",
        ):
            self.assertIn(rule, stops)


if __name__ == "__main__":
    unittest.main()
