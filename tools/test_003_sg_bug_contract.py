from __future__ import annotations

import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SKILL = ROOT / "skills" / "003-sg-bug" / "SKILL.md"
REFERENCES = ROOT / "skills" / "003-sg-bug" / "references"


class BugActivationContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.text = SKILL.read_text(encoding="utf-8")

    def test_activation_body_stays_within_wave_two_budget(self) -> None:
        estimated_tokens = (len(self.text) + 3) // 4
        self.assertLessEqual(estimated_tokens, 2300)

    def test_one_bug_owner_boundary_and_phase_owners_remain_local(self) -> None:
        for required in (
            "owns one bug work item's lifecycle",
            "It does not own generic maintenance, direct code repair, or broad release orchestration",
            "107-sg-test",
            "106-sg-fix",
            "109-sg-auth-debug",
            "108-sg-browser",
            "103-sg-verify",
            "005-sg-ship",
        ):
            self.assertIn(required, self.text)

    def test_local_playbooks_are_conditional_and_direct(self) -> None:
        section = self.text.split("## Required References", 1)[1].split(
            "## Mode Detection", 1
        )[0]
        self.assertIn("Load at most one local playbook before the first substantive action", section)
        names = (
            "bug-state-routing.md",
            "bug-evidence-routing.md",
            "bug-closure-playbook.md",
        )
        for name in names:
            self.assertEqual(section.count(name), 1)
            path = REFERENCES / name
            self.assertTrue(path.is_file(), name)
            reference = path.read_text(encoding="utf-8")
            self.assertIn("Do not load another local `003-sg-bug` playbook before the first", reference)
            for other in names:
                if other != name:
                    self.assertNotIn(other, reference)

    def test_state_and_ship_gates_remain_activation_critical(self) -> None:
        for required in (
            "`open`, `needs-repro`, `needs-info`, `in-diagnosis`",
            "`fix-attempted`",
            "`fixed-pending-verify`",
            "`closed-without-retest`",
            "High or critical bugs",
            "block clean shipping",
        ):
            self.assertIn(required, self.text)

    def test_visual_proof_strings_remain_local(self) -> None:
        normalized = " ".join(self.text.split())
        for required in (
            "evidence -> fix-attempted -> retest -> fixed-pending-verify -> verify",
            "must not call it resolved, fixed, verified, or closed",
            "person validates the rendered result",
        ):
            self.assertIn(required, normalized)

    def test_long_procedures_are_not_in_activation_body(self) -> None:
        self.assertNotIn("## Step 1", self.text)
        self.assertNotIn("## Step 2", self.text)
        self.assertNotIn("## Step 3", self.text)
        self.assertNotIn("## Step 4", self.text)
        self.assertNotIn("## Step 5", self.text)
        self.assertIsNone(re.search(r"\| State \| Next safe action \|", self.text))


if __name__ == "__main__":
    unittest.main()
