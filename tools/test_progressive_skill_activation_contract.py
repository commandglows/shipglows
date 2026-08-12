#!/usr/bin/env python3
"""Contract checks for the compact 704/706 activation pilots."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
MODEL_SKILL = ROOT / "skills" / "704-sg-model" / "SKILL.md"
CONTINUE_ROOT = ROOT / "skills" / "706-continue"
CONTINUE_SKILL = CONTINUE_ROOT / "SKILL.md"
CONTINUE_PLAYBOOK = CONTINUE_ROOT / "references" / "continuation-playbook.md"

MIN_BODY_TOKENS = 800
MAX_BODY_TOKENS = 1_800


def body_token_estimate(text: str) -> int:
    """Match the deterministic estimate used by the skill budget audit."""
    parts = text.split("---", 2)
    body = parts[2] if len(parts) == 3 else text
    return max(1, len(body) // 4)


class ProgressiveSkillActivationContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.model = MODEL_SKILL.read_text(encoding="utf-8")
        cls.continue_skill = CONTINUE_SKILL.read_text(encoding="utf-8")
        cls.continue_playbook = CONTINUE_PLAYBOOK.read_text(encoding="utf-8")

    def test_pilot_bodies_are_compact_but_decision_complete(self) -> None:
        for path, text in (
            (MODEL_SKILL, self.model),
            (CONTINUE_SKILL, self.continue_skill),
        ):
            estimate = body_token_estimate(text)
            self.assertGreaterEqual(estimate, MIN_BODY_TOKENS, path)
            self.assertLessEqual(estimate, MAX_BODY_TOKENS, path)

    def test_model_skill_loads_one_matrix_and_keeps_runtime_truth(self) -> None:
        for required in (
            "decision-quality-contract.md",
            "704-sg-model/references/model-routing.md",
            "reporting-contract.md",
            "current conversation acceptable",
            "subagent override applied",
            "subagent override recommended, not applied",
            "switch recommended for next run",
            "Never infer access from documentation",
            "Stop Conditions",
            "Validation",
        ):
            self.assertIn(required, self.model)

    def test_continue_loads_only_its_bounded_local_playbook(self) -> None:
        local_refs = sorted((CONTINUE_ROOT / "references").glob("*.md"))
        self.assertEqual(local_refs, [CONTINUE_PLAYBOOK])
        self.assertIn("references/continuation-playbook.md", self.continue_skill)
        self.assertIn("the only local substantive playbook", self.continue_skill)
        for required in (
            "master-delegation-semantics.md",
            "704-sg-model/references/model-routing.md",
            "question-contract.md",
            "reporting-contract.md",
            "Agents: <count> · <mode>",
            "Stop Conditions",
            "Integration And Proof",
        ):
            self.assertIn(required, self.continue_skill)

    def test_continue_playbook_preserves_resolution_and_ready_boundary(self) -> None:
        for required in (
            "Target Resolution",
            "Next Ready Action",
            "durable local evidence",
            "first unresolved ready boundary",
            "Do not skip an earlier failed check",
            "explicit owned and forbidden surfaces",
            "one next concrete step",
        ):
            self.assertIn(required, self.continue_playbook)

    def test_activation_contracts_do_not_duplicate_catalogues_or_templates(self) -> None:
        corpus = self.model + "\n" + self.continue_skill
        for duplicated_detail in (
            "gpt-5.6-sol",
            "gpt-5.6-terra",
            "gpt-5.6-luna",
            "gpt-5.3-codex-spark",
            "You are an explorer agent",
            "You are a worker agent",
            "Delegation Prompt Template",
            "Codex/OpenAI routing matrix",
            "Claude Code routing matrix",
        ):
            self.assertNotIn(duplicated_detail, corpus)


if __name__ == "__main__":
    unittest.main()
