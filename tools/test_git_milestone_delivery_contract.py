#!/usr/bin/env python3
"""Pressure-scenario proof for mandatory milestone commits and final push."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "skills/references/git-milestone-delivery-contract.md"


class GitMilestoneDeliveryContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.contract = CONTRACT.read_text(encoding="utf-8")
        cls.approval = (ROOT / "skills/references/mutation-plan-approval.md").read_text(encoding="utf-8")
        cls.lifecycle = (ROOT / "skills/references/master-workflow-lifecycle.md").read_text(encoding="utf-8")
        cls.start = (ROOT / "skills/102-sg-start/SKILL.md").read_text(encoding="utf-8")
        cls.end = (ROOT / "skills/104-sg-end/SKILL.md").read_text(encoding="utf-8")
        cls.ship = (ROOT / "skills/005-sg-ship/SKILL.md").read_text(encoding="utf-8")
        cls.execution = (ROOT / "skills/005-sg-ship/references/ship-execution-playbook.md").read_text(encoding="utf-8")

    def test_milestone_is_coherent_and_not_message_driven(self) -> None:
        for marker in (
            "coherent completed slice",
            "proportional passing proof",
            "assistant message",
            "failing experiment",
            "arbitrary elapsed interval",
            "before starting the next milestone",
        ):
            with self.subTest(marker=marker):
                self.assertIn(marker, self.contract)

    def test_checkpoint_commit_preserves_exact_scope_and_secrets_gate(self) -> None:
        for marker in (
            "exact owned paths",
            "exclude every unrelated or pre-existing path",
            "suspected secrets or sensitive data",
            "non-interactive commit",
            "nothing to commit",
        ):
            with self.subTest(marker=marker):
                self.assertIn(marker, self.contract)
        self.assertIn("005-sg-ship checkpoint", self.lifecycle)
        self.assertIn("005-sg-ship checkpoint", self.start)
        self.assertIn("`checkpoint` commits one validated milestone", self.ship)
        self.assertIn("return to implementation without pushing", self.execution)

    def test_final_delivery_requires_push_without_empty_commit(self) -> None:
        for marker in (
            "push all owned commits",
            "do not claim clean closure until that push succeeds",
            "latest owned milestone commit as the final commit",
            "never create an empty ceremonial commit",
        ):
            with self.subTest(marker=marker):
                self.assertIn(marker, self.contract)
        self.assertIn("Mandatory final delivery authority", self.approval)
        self.assertIn("no second closing approval", self.approval)
        self.assertIn("final commit/push", self.end)

    def test_failure_preserves_local_commit_and_blocks_clean_closure(self) -> None:
        for marker in (
            "keep the local commits intact",
            "delivery pending",
            "Never amend, reset, force, merge, switch branches, or widen staging",
        ):
            with self.subTest(marker=marker):
                self.assertIn(marker, self.contract)
        self.assertIn("Push failure", self.approval)
        self.assertIn("forbids standard clean closure", self.lifecycle)

    def test_pressure_scenarios_cover_required_boundaries(self) -> None:
        for scenario in (
            "GMD-MILESTONE-COMMIT",
            "GMD-NO-MESSAGE-COMMITS",
            "GMD-FINAL-PUSH",
            "GMD-NO-EMPTY-FINAL",
            "GMD-UNRELATED-DIRTY",
            "GMD-PUSH-FAILURE",
            "GMD-NON-GIT",
            "MAP-MILESTONE-COMMIT",
            "MAP-FINAL-DELIVERY",
        ):
            corpus = self.contract + self.approval
            with self.subTest(scenario=scenario):
                self.assertIn(scenario, corpus)


if __name__ == "__main__":
    unittest.main()
