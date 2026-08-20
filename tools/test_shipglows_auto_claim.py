#!/usr/bin/env python3
"""Behavioral tests for root-local ShipGlows auto claims."""

from concurrent.futures import ThreadPoolExecutor
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

from tools.shipglows_auto_claim import ClaimError, acquire_claim, complete_claim


class ShipGlowsAutoClaimTests(unittest.TestCase):
    def make_repo(self, parent: str | None = None) -> Path:
        root = Path(tempfile.mkdtemp(dir=parent))
        subprocess.run(["git", "init", "-q", str(root)], check=True)
        (root / ".gitignore").write_text("/.shipglows-auto/\n", encoding="utf-8")
        (root / "work.md").write_text("work\n", encoding="utf-8")
        (root / "src").mkdir()
        return root

    def test_same_candidate_race_has_exactly_one_winner(self) -> None:
        root = self.make_repo()

        def attempt(owner: str) -> str:
            try:
                acquire_claim(root, "work.md", "task-1", owner, ["src/a.py"])
                return "ok"
            except ClaimError as exc:
                return exc.code

        with ThreadPoolExecutor(max_workers=2) as pool:
            outcomes = list(pool.map(attempt, ("run-a", "run-b")))
        self.assertEqual(1, outcomes.count("ok"))
        self.assertEqual(1, outcomes.count("already_claimed"))

    def test_equivalent_work_item_paths_share_one_key(self) -> None:
        root = self.make_repo()
        first = acquire_claim(root, "work.md", "task-1", "run-a", ["src/a.py"])
        with self.assertRaises(ClaimError) as raised:
            acquire_claim(root, "src/../work.md", "task-1", "run-b", ["src/b.py"])
        self.assertEqual("already_claimed", raised.exception.code)
        self.assertEqual(24, len(first["claim_key"]))

    def test_same_candidate_is_independent_across_roots(self) -> None:
        first_root = self.make_repo()
        second_root = self.make_repo()
        first = acquire_claim(first_root, "work.md", "task-1", "run-a", ["src/a.py"])
        second = acquire_claim(second_root, "work.md", "task-1", "run-b", ["src/a.py"])
        self.assertEqual(first["claim_key"], second["claim_key"])
        self.assertNotEqual(first["captured_git_root"], second["captured_git_root"])

    def test_launch_from_subdirectory_captures_git_top_level(self) -> None:
        root = self.make_repo()
        nested = root / "src" / "nested"
        nested.mkdir()
        claim = acquire_claim(nested, "work.md", "task-1", "run-a", ["src/a.py"])
        self.assertEqual(str(root.resolve()), claim["captured_git_root"])

    def test_symlink_escape_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as parent:
            root = self.make_repo(parent)
            outside = Path(parent) / "outside"
            outside.mkdir()
            os.symlink(outside, root / "escape")
            with self.assertRaises(ClaimError) as raised:
                acquire_claim(root, "work.md", "task-1", "run-a", ["escape/a.py"])
            self.assertEqual("path_escape", raised.exception.code)

    def test_lock_symlink_escape_is_rejected_without_external_write(self) -> None:
        with tempfile.TemporaryDirectory() as parent:
            root = self.make_repo(parent)
            claims = root / ".shipglows-auto" / "claims"
            claims.mkdir(parents=True)
            outside = Path(parent) / "outside-lock"
            outside.write_bytes(b"unchanged")
            os.symlink(outside, claims / ".lock")
            with self.assertRaises(ClaimError) as raised:
                acquire_claim(root, "work.md", "task-1", "run-a", ["src/a.py"])
            self.assertEqual("unsafe_claim_storage", raised.exception.code)
            self.assertEqual(b"unchanged", outside.read_bytes())

    def test_non_git_root_cannot_claim(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            with self.assertRaises(ClaimError) as raised:
                acquire_claim(root, "work.md", "task-1", "run-a", ["src/a.py"])
            self.assertEqual("unresolved_git_root", raised.exception.code)

    def test_child_cannot_complete_parent_claim(self) -> None:
        root = self.make_repo()
        claim = acquire_claim(root, "work.md", "task-1", "parent", ["src/a.py"])
        with self.assertRaises(ClaimError) as raised:
            complete_claim(root, str(claim["claim_key"]), "child")
        self.assertEqual("owner_mismatch", raised.exception.code)
        completed = complete_claim(root, str(claim["claim_key"]), "parent")
        self.assertEqual("completed", completed["status"])

    def test_complete_rejects_claim_key_path_traversal(self) -> None:
        root = self.make_repo()
        with self.assertRaises(ClaimError) as raised:
            complete_claim(root, "../../outside", "run-a")
        self.assertEqual("invalid_claim_key", raised.exception.code)

    def test_abandoned_claim_is_never_reclaimed_silently(self) -> None:
        root = self.make_repo()
        acquire_claim(root, "work.md", "task-1", "abandoned", ["src/a.py"])
        with self.assertRaises(ClaimError) as raised:
            acquire_claim(root, "work.md", "task-1", "new-run", ["src/a.py"])
        self.assertEqual("already_claimed", raised.exception.code)

    def test_different_candidates_cannot_claim_overlapping_paths(self) -> None:
        root = self.make_repo()
        (root / "other.md").write_text("other\n", encoding="utf-8")
        acquire_claim(root, "work.md", "task-1", "run-a", ["src"])
        with self.assertRaises(ClaimError) as raised:
            acquire_claim(root, "other.md", "task-2", "run-b", ["src/a.py"])
        self.assertEqual("path_conflict", raised.exception.code)


if __name__ == "__main__":
    unittest.main()
