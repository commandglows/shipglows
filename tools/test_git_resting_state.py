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

    def test_squash_merged_branch_counts_as_integrated(self) -> None:
        with TemporaryDirectory() as temporary:
            repo = self._repo(Path(temporary))
            _git(repo, "switch", "-c", "squashed-topic")
            for name in ("c.txt", "d.txt"):
                (repo / name).write_text(name, encoding="utf-8")
                _git(repo, "add", name)
                _git(repo, "commit", "-m", f"add {name}")
            _git(repo, "switch", "main")
            _git(repo, "merge", "--squash", "squashed-topic")
            _git(repo, "commit", "-m", "squash topic")
            (repo / "e.txt").write_text("later", encoding="utf-8")
            _git(repo, "add", "e.txt")
            _git(repo, "commit", "-m", "later work")
            found = {item["name"]: item["disposition"] for item in resting_state(repo, pull_requests=False)["items"]}
            self.assertEqual(found["squashed-topic"], "auto")

    def test_branch_folded_into_broader_squash_counts_as_integrated(self) -> None:
        with TemporaryDirectory() as temporary:
            repo = self._repo(Path(temporary))
            for branch, names in (("folded-topic", ("c.txt", "d.txt")), ("open-topic", ("f.txt",))):
                _git(repo, "switch", "-c", branch, "main")
                for name in names:
                    (repo / name).write_text(name, encoding="utf-8")
                    _git(repo, "add", name)
                    _git(repo, "commit", "-m", f"add {name}")
            _git(repo, "switch", "main")
            _git(repo, "merge", "--squash", "folded-topic")
            (repo / "other.txt").write_text("other work", encoding="utf-8")
            _git(repo, "add", "other.txt")
            _git(repo, "commit", "-m", "broad squash (#1)", "-m", "* add c.txt\n\n* add d.txt\n\n* other work")
            found = {item["name"]: item["disposition"] for item in resting_state(repo, pull_requests=False)["items"]}
            self.assertEqual(found["folded-topic"], "auto")
            self.assertEqual(found["open-topic"], "merge")


if __name__ == "__main__":
    unittest.main()
