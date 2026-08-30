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


if __name__ == "__main__":
    unittest.main()
