#!/usr/bin/env python3
"""Focused tests for the Git resting-state check."""

from pathlib import Path
import subprocess
from tempfile import TemporaryDirectory
import unittest

from tools.git_resting_state import resting_state


def _git(repo: Path, *args: str) -> None:
    subprocess.run(["git", "-C", str(repo), *args], check=True, capture_output=True)


class GitRestingStateTests(unittest.TestCase):
    def _repo(self, root: Path) -> Path:
        repo = root / "repo"
        repo.mkdir()
        _git(repo, "init", "-b", "main")
        _git(repo, "config", "user.email", "t@example.com")
        _git(repo, "config", "user.name", "T")
        (repo / "a.txt").write_text("a", encoding="utf-8")
        _git(repo, "add", "a.txt")
        _git(repo, "commit", "-m", "init")
        return repo

    def test_clean_main_is_at_rest(self) -> None:
        with TemporaryDirectory() as temporary:
            repo = self._repo(Path(temporary))
            self.assertTrue(resting_state(repo, pull_requests=False)["resting"])

    def test_leftovers_get_dispositions(self) -> None:
        with TemporaryDirectory() as temporary:
            repo = self._repo(Path(temporary))
            _git(repo, "branch", "merged-topic")
            _git(repo, "switch", "-c", "open-topic")
            (repo / "b.txt").write_text("b", encoding="utf-8")
            _git(repo, "add", "b.txt")
            _git(repo, "commit", "-m", "work")
            _git(repo, "switch", "main")
            (repo / "dirty.txt").write_text("x", encoding="utf-8")
            result = resting_state(repo, pull_requests=False)
            found = {(item["kind"], item["name"]): item["disposition"] for item in result["items"]}
            self.assertFalse(result["resting"])
            self.assertEqual(found[("local-branch", "merged-topic")], "auto")
            self.assertEqual(found[("local-branch", "open-topic")], "merge")
            self.assertEqual(found[("worktree-changes", ".")], "ask")


if __name__ == "__main__":
    unittest.main()
