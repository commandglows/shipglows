from __future__ import annotations

import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class VisualBugProofFidelityContractTests(unittest.TestCase):
    def test_minor_exception_waives_only_durable_bug_file(self) -> None:
        fix_skill = (ROOT / "skills" / "106-sg-fix" / "SKILL.md").read_text(encoding="utf-8")
        workflow = (
            ROOT / "skills" / "106-sg-fix" / "references" / "bug-fix-workflow.md"
        ).read_text(encoding="utf-8")
        for text in (fix_skill, workflow):
            self.assertIn("only waives creation of a new durable bug file", text)
            self.assertIn("implemented", text)
            self.assertIn("person validates the rendered result", text)

    def test_visual_technical_checks_cannot_close_the_bug(self) -> None:
        discipline = (
            ROOT / "skills" / "references" / "spec-driven-development-discipline.md"
        ).read_text(encoding="utf-8")
        bug_skill = (ROOT / "skills" / "003-sg-bug" / "SKILL.md").read_text(encoding="utf-8")
        normalized_discipline = " ".join(discipline.split())
        normalized_bug_skill = " ".join(bug_skill.split())
        self.assertIn("VISUAL-IMPLEMENTED-NOT-RESOLVED", normalized_discipline)
        self.assertIn("HTTP 200", normalized_discipline)
        self.assertIn("person validates the rendered result", normalized_discipline)
        self.assertIn("evidence -> fix-attempted -> retest -> fixed-pending-verify -> verify", normalized_bug_skill)
        self.assertIn("must not call it resolved, fixed, verified, or closed", normalized_bug_skill)


class SessionRenameActivationContractTests(unittest.TestCase):
    def test_missing_status_requires_one_question_and_no_mutation(self) -> None:
        skill = (ROOT / "skills" / "309-sg-tasks" / "SKILL.md").read_text(encoding="utf-8")
        playbook = (
            ROOT
            / "shipglows_data"
            / "workflow"
            / "playbooks"
            / "conversation-tracker-sync-playbook.md"
        ).read_text(encoding="utf-8")
        for text in (skill, playbook):
            normalized = " ".join(text.split())
            self.assertIn("CONVERSATION-RENAME-MISSING-STATUS", normalized)
            self.assertIn("ask for exactly one supported status", normalized)
            self.assertIn("do not derive a title, inspect sessions, call the helper, or mutate", normalized)


if __name__ == "__main__":
    unittest.main()
