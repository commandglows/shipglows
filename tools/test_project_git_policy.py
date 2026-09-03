#!/usr/bin/env python3

from pathlib import Path
import tempfile
import unittest

from tools import project_git_policy as policy


ROOT = Path(__file__).resolve().parents[1]


class ProjectGitPolicyTests(unittest.TestCase):
    def write_guidelines(
        self,
        root: Path,
        task_branch: str | None = None,
        worktree: str | None = None,
    ) -> None:
        path = root / policy.CANONICAL_RELATIVE
        path.parent.mkdir(parents=True)
        fields = ["artifact: technical_guidelines"]
        if task_branch is not None:
            fields.append(f"task_branch_policy: {task_branch}")
        if worktree is not None:
            fields.append(f"worktree_policy: {worktree}")
        path.write_text("---\n" + "\n".join(fields) + "\n---\n", encoding="utf-8")

    def test_missing_guidelines_fail_closed(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            result = policy.inspect_project(Path(directory))
        self.assertEqual("defaulted", result.state)
        self.assertEqual("forbidden", result.task_branch_policy)
        self.assertEqual("forbidden", result.worktree_policy)

    def test_missing_fields_fail_closed_independently(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.write_guidelines(root, task_branch="allowed")
            result = policy.inspect_project(root)
        self.assertEqual("defaulted", result.state)
        self.assertEqual("allowed", result.task_branch_policy)
        self.assertEqual("forbidden", result.worktree_policy)

    def test_explicit_values_are_resolved(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.write_guidelines(root, task_branch="allowed", worktree="forbidden")
            result = policy.inspect_project(root)
        self.assertEqual("resolved", result.state)
        self.assertEqual("allowed", result.task_branch_policy)
        self.assertEqual("forbidden", result.worktree_policy)

    def test_invalid_value_forbids_both_creation_lanes(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.write_guidelines(root, task_branch="sometimes", worktree="allowed")
            result = policy.inspect_project(root)
        self.assertEqual("invalid", result.state)
        self.assertEqual("forbidden", result.task_branch_policy)
        self.assertEqual("forbidden", result.worktree_policy)

    def test_context_and_git_contracts_consume_the_policy(self) -> None:
        consumers = (
            ROOT / "skills/000-shipglows/SKILL.md",
            ROOT / "skills/shipglows/SKILL.md",
            ROOT / "skills/301-sg-context/SKILL.md",
            ROOT / "skills/references/mutation-plan-approval.md",
            ROOT / "skills/references/git-temporary-artifact-lifecycle.md",
            ROOT / "skills/010-sg-technical/references/github-hygiene-playbook.md",
        )
        for path in consumers:
            with self.subTest(path=path):
                self.assertIn("project_git_policy.py", path.read_text(encoding="utf-8"))

    def test_templates_default_both_creation_lanes_to_forbidden(self) -> None:
        for path in (
            ROOT / "templates/technical_guidelines.md",
            ROOT / "shipglows_data/technical/guidelines.md",
        ):
            with self.subTest(path=path):
                text = path.read_text(encoding="utf-8")
                self.assertIn("task_branch_policy: forbidden", text)
                self.assertIn("worktree_policy: forbidden", text)


if __name__ == "__main__":
    unittest.main()
