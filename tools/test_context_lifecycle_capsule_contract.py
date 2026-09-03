from __future__ import annotations

import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class ContextLifecycleCapsuleContractTests(unittest.TestCase):
    def test_material_lifecycle_owners_consume_capsule(self) -> None:
        expected = {
            "skills/101-sg-ready/SKILL.md": "bounded capsule",
            "skills/102-sg-start/references/execution-contract.md": "bounded capsule",
            "skills/103-sg-verify/references/verification-baseline.md": "bounded capsule",
            "skills/104-sg-end/SKILL.md": "bounded capsule",
            "skills/005-sg-ship/SKILL.md": "bounded capsule",
            "skills/706-continue/SKILL.md": "bounded capsule",
        }
        for relative, marker in expected.items():
            with self.subTest(relative=relative):
                self.assertIn(marker, (ROOT / relative).read_text(encoding="utf-8"))

    def test_context_owner_names_incremental_and_small_task_paths(self) -> None:
        body = (ROOT / "skills/301-sg-context/SKILL.md").read_text(encoding="utf-8")
        self.assertIn("code_context_graph.py update", body)
        self.assertIn("context_capsule.py", body)
        self.assertIn("Small deterministic tasks", body)
        self.assertIn("Never persist task text automatically", body)

    def test_recap_preserves_supplied_capsule_without_hidden_retrieval(self) -> None:
        body = (ROOT / "skills/303-sg-resume/SKILL.md").read_text(encoding="utf-8")
        self.assertIn("Context Capsule", body)
        self.assertIn("Do not regenerate", body)

    def test_recap_judges_non_disposable_thread_information_not_continuity(self) -> None:
        body = (ROOT / "skills/303-sg-resume/SKILL.md").read_text(encoding="utf-8")
        for marker in (
            "What non-disposable information still exists only in this visible conversation",
            "does not assess whether context is reliable for a future task",
            "Information to preserve",
            "No information to preserve",
        ):
            self.assertIn(marker, body)
        self.assertNotIn("Tu peux fermer / Garde ouvert", body)

    def test_closure_revalidates_context_before_documentation_classification(self) -> None:
        quality = (ROOT / "skills/references/context-quality-contract.md").read_text(encoding="utf-8")
        reflection = (ROOT / "skills/references/documentation-reflection-gate.md").read_text(encoding="utf-8")
        for marker in (
            "task-owned changed paths",
            "code-docs-map.md",
            "Context Head",
            "targeted canonical fallback",
            "before documentation classification",
        ):
            self.assertIn(marker, quality + reflection)
        self.assertIn("never replace Git or the canonical documentation map", reflection)


if __name__ == "__main__":
    unittest.main()
