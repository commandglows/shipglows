#!/usr/bin/env python3
"""Focused tests for the Git storage upkeep check."""

import unittest

from tools.git_storage_check import assess, count_prunable_worktrees, parse_count_objects


class GitStorageCheckTests(unittest.TestCase):
    def test_healthy_repository_is_not_due(self) -> None:
        stats = parse_count_objects("count: 378\nsize: 1660\nin-pack: 29711\npacks: 4\ngarbage: 0\n")
        self.assertEqual(assess(stats, 0)["due"], False)

    def test_storage_and_worktree_signals_map_to_bounded_actions(self) -> None:
        stats = {"count": 5000, "size": 10, "packs": 25, "garbage": 0}
        porcelain = "worktree /a\nHEAD x\n\nworktree /gone\nHEAD y\nprunable gitdir file points to non-existent location\n"
        result = assess(stats, count_prunable_worktrees(porcelain))
        self.assertTrue(result["due"])
        self.assertEqual(result["actions"], ["git worktree prune", "git gc"])
        self.assertNotIn("--prune=now", " ".join(result["actions"]))


if __name__ == "__main__":
    unittest.main()
