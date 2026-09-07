"""Behavioral fixtures for immutable, first-parent audit selection."""
import json
from pathlib import Path
import subprocess
import tempfile
import unittest

from tools.core_recent_audit import AuditError, inventory


class RecentAuditTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.git("init", "-b", "integration")
        self.git("config", "user.email", "fixture@example.invalid")
        self.git("config", "user.name", "Fixture")
        self.base = self.commit("skills/example/SKILL.md", "Read only when needed.\n", "baseline")

    def git(self, *args):
        return subprocess.check_output(["git", "-C", str(self.root), *args], encoding="utf-8", stderr=subprocess.DEVNULL).strip()

    def commit(self, path, text, message):
        file = self.root / path
        file.parent.mkdir(parents=True, exist_ok=True)
        file.write_text(text, encoding="utf-8")
        self.git("add", "--", path)
        self.git("commit", "-m", message)
        return self.git("rev-parse", "HEAD")

    def test_merge_is_one_integration_and_excludes_feature_head_and_dirt(self):
        self.git("checkout", "-b", "feature")
        self.commit("skills/example/SKILL.md", "Always read full corpus.\n", "feature one")
        self.commit("skills/reference.md", "More rules.\n", "feature two")
        self.git("checkout", "integration")
        self.git("merge", "--no-ff", "feature", "-m", "integrate")
        tip = self.git("rev-parse", "HEAD")
        self.git("checkout", "-b", "next")
        self.commit("skills/unintegrated.md", "unintegrated", "next feature")
        (self.root / "skills/example/SKILL.md").write_text("DIRTY", encoding="utf-8")
        self.git("add", "skills/example/SKILL.md")
        before = self.git("status", "--porcelain")
        result = inventory(self.root, "refs/heads/integration", count=1)
        self.assertEqual((result["base"], result["tip"]), (self.base, tip))
        self.assertEqual(result["commit_count"], 1)
        self.assertNotIn("unintegrated", json.dumps(result))
        self.assertEqual(before, self.git("status", "--porcelain"))
        self.assertEqual(result["semantic_verdict"], "not-assessed")

    def test_since_rejects_merge_side_parent(self):
        self.git("checkout", "-b", "side")
        side = self.commit("skills/side.md", "side", "side")
        self.git("checkout", "integration")
        self.git("merge", "--no-ff", "side", "-m", "merge")
        with self.assertRaises(AuditError):
            inventory(self.root, "refs/heads/integration", since=side)

    def test_default_window_counts_ten_commits_including_unrelated_changes(self):
        revisions = [self.base]
        for n in range(12):
            revisions.append(self.commit("app/widget.txt", str(n), f"change {n}"))
        result = inventory(self.root, "refs/heads/integration")
        self.assertEqual(result["commit_count"], 10)
        self.assertEqual(result["base"], revisions[2])
        self.assertEqual(result["tip"], revisions[-1])

    def test_deleted_reference_is_present_in_inventory(self):
        self.git("rm", "skills/example/SKILL.md")
        self.git("commit", "-m", "delete")
        result = inventory(self.root, "refs/heads/integration", count=1)
        self.assertTrue(result["changes"][0]["before_present"])
        self.assertFalse(result["changes"][0]["after_present"])

    def test_since_is_exclusive_and_supports_empty_window(self):
        tip = self.commit("skills/reference.md", "new", "add")
        self.assertEqual(inventory(self.root, "refs/heads/integration", since=self.base)["commit_count"], 1)
        self.assertEqual(inventory(self.root, "refs/heads/integration", since=tip)["commits"], [])

    def test_short_window_and_invalid_inputs_are_visible(self):
        with self.assertRaises(AuditError):
            inventory(self.root, "refs/heads/integration")
        self.commit("README.md", "help", "help")
        result = inventory(self.root, "refs/heads/integration")
        self.assertTrue(any("short window" in w for w in result["warnings"]))
        for ref in ("HEAD", "integration", "refs/remotes/origin/HEAD", "refs/heads/missing"):
            with self.assertRaises(AuditError):
                inventory(self.root, ref)
        with self.assertRaises(AuditError):
            inventory(self.root, "refs/heads/integration", count=0)

    def test_unrelated_change_does_not_request_corpus(self):
        self.commit("app/widget.txt", "product change", "app")
        result = inventory(self.root, "refs/heads/integration", count=1)
        self.assertEqual(result["changes"], [])
        self.assertEqual(result["commits"][0]["changed_paths"], ["app/widget.txt"])

    def test_extraction_and_lost_rule_are_not_classified_by_size(self):
        self.commit("skills/example/SKILL.md", "", "lost rule")
        self.commit("skills/details.md", "Read only when needed.\n", "extraction candidate")
        result = inventory(self.root, "refs/heads/integration", since=self.base)
        self.assertEqual(result["semantic_verdict"], "not-assessed")
        self.assertEqual(len(result["changes"]), 2)

    def test_reverted_change_keeps_integration_evidence(self):
        self.commit("skills/example/SKILL.md", "Always load everything.\n", "eager")
        self.commit("skills/example/SKILL.md", "Read only when needed.\n", "repair")
        result = inventory(self.root, "refs/heads/integration", count=2)
        self.assertEqual(len(result["commits"]), 2)
        self.assertEqual(result["changes"][0]["before_estimated_tokens"], result["changes"][0]["after_estimated_tokens"])


if __name__ == "__main__":
    unittest.main()
