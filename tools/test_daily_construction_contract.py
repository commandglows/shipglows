#!/usr/bin/env python3
"""Focused contract proof for daily construction throughput and default push."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]


class DailyConstructionContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.core = (ROOT / "skills/references/master-workflow-lifecycle-core.md").read_text(encoding="utf-8")
        cls.lifecycle = (ROOT / "skills/references/master-workflow-lifecycle.md").read_text(encoding="utf-8")
        cls.ship = (ROOT / "skills/005-sg-ship/SKILL.md").read_text(encoding="utf-8")
        cls.ship_execution = (ROOT / "skills/005-sg-ship/references/ship-execution-playbook.md").read_text(encoding="utf-8")
        cls.end = (ROOT / "skills/104-sg-end/SKILL.md").read_text(encoding="utf-8")
        cls.core_build = (ROOT / "skills/900-shipglows-core/references/skill-maintenance-playbook.md").read_text(encoding="utf-8")
        cls.decision = (ROOT / "skills/references/decision-quality-contract.md").read_text(encoding="utf-8")
        cls.partnership = (ROOT / "skills/references/operator-partnership-contract.md").read_text(encoding="utf-8")
        cls.autonomy = (ROOT / "skills/references/intent-to-outcome-autonomy.md").read_text(encoding="utf-8")
        cls.questions = (ROOT / "skills/references/question-contract.md").read_text(encoding="utf-8")
        cls.delegation = (ROOT / "skills/references/master-delegation-semantics.md").read_text(encoding="utf-8")

    def test_clean_daily_completion_defaults_to_push(self) -> None:
        self.assertIn("clean completed daily chantier with durable repository artifacts proceeds to bounded commit and push by default", self.core)
        self.assertIn("default terminal route is bounded commit and push", self.lifecycle)
        self.assertIn("unpushed commits remain delivery pending", self.end)

    def test_daily_validation_is_zero_or_one_focused_check(self) -> None:
        self.assertIn("zero or one focused check", self.ship)
        self.assertIn("use no automated check for a low-risk localized change", self.ship_execution)
        self.assertIn("otherwise run one focused owner test", self.ship_execution)
        self.assertIn("zero or one focused scenario/contract check", self.core_build)

    def test_broad_validation_requires_a_material_trigger(self) -> None:
        for text in (self.core, self.lifecycle, self.ship_execution, self.core_build):
            self.assertIn("release", text.lower())
            self.assertIn("audit", text.lower())
        self.assertIn("do not automatically combine lint, typecheck, build, tests", self.ship_execution)

    def test_safety_and_truth_boundaries_remain(self) -> None:
        approval = (ROOT / "skills/references/mutation-plan-approval.md").read_text(encoding="utf-8")
        self.assertIn("explicitly requested ordinary `git push`", approval)
        self.assertIn("Force push retains every stricter gate", approval)
        self.assertIn("Never commit secrets", self.ship)
        self.assertIn("Stop on a required or attempted check failure", self.ship_execution)
        self.assertIn("never claims formal closure", self.ship)

    def test_corpus_prioritizes_shipped_business_value(self) -> None:
        self.assertIn("primary goal is shipped business and user value", self.decision)
        self.assertIn("valuable outcome -> smallest coherent slice -> create -> proportional proof -> commit/push -> activate at the real destination -> learn", self.partnership)
        self.assertIn("smallest useful deliverable", self.autonomy)
        self.assertIn("Recommend the fastest, simplest path", self.questions)

    def test_architecture_is_a_high_standard_enabler_not_ceremony(self) -> None:
        self.assertIn("coherent boundaries and maintainable architecture proportionate", self.decision)
        self.assertIn("speculative architecture, ceremonial process", self.decision)
        self.assertIn("never present avoidable process or overengineering as quality", self.decision)

    def test_delegation_must_repay_coordination_cost(self) -> None:
        self.assertIn("lowest-overhead topology", self.delegation)
        self.assertIn("coordination must buy measurable speed, isolation, or evidence", self.delegation)
        self.assertIn("Missing subagent capability is not degradation", self.delegation)


if __name__ == "__main__":
    unittest.main()
