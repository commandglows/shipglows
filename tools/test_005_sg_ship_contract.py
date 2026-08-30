#!/usr/bin/env python3
"""Scenario-first contract checks for the compact ship activation skill."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
SKILL = ROOT / "skills" / "005-sg-ship" / "SKILL.md"
REFS = SKILL.parent / "references"
SHARED = ROOT / "skills" / "references"


class ShipSkillContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.text = SKILL.read_text(encoding="utf-8")
        cls.execution = (REFS / "ship-execution-playbook.md").read_text(encoding="utf-8")
        cls.full_close = (REFS / "full-close-playbook.md").read_text(encoding="utf-8")
        cls.reporting = (REFS / "ship-report-evidence.md").read_text(encoding="utf-8")
        cls.git_lifecycle = (SHARED / "git-temporary-artifact-lifecycle.md").read_text(
            encoding="utf-8"
        )
        cls.master_lifecycle = (SHARED / "master-workflow-lifecycle.md").read_text(
            encoding="utf-8"
        )

    def test_activation_size_is_bounded(self) -> None:
        self.assertLessEqual((len(self.text) + 3) // 4, 1600)

    def test_quick_is_default_and_full_is_explicit(self) -> None:
        for phrase in (
            "Default mode is `quick`",
            "Select `full` only when",
            "never updates `TASKS.md` or `CHANGELOG.md`",
            "never claims formal closure",
        ):
            self.assertIn(phrase, self.text)

    def test_common_playbook_precedes_mutation_and_full_is_conditional(self) -> None:
        self.assertIn("before its first Git mutation", self.execution)
        self.assertIn("Before either mode mutates Git, load exactly one local reference", self.text)
        self.assertIn("Full mode loads its full-close playbook only after", self.text)
        self.assertIn("only after explicit full-close intent", self.full_close)

    def test_secret_and_bug_stops_remain_in_activation_contract(self) -> None:
        stops = self.text.split("## Stops Before Mutation", 1)[1].split(
            "## Evidence Boundaries", 1
        )[0]
        for phrase in (
            "suspected secret",
            "required or attempted check fails",
            "linked high/critical bug",
            "Stop before staging or committing",
            "Never commit secrets",
            "Never force-push `main` or `master`",
        ):
            self.assertIn(phrase, stops)

    def test_all_dirty_requires_explicit_intent(self) -> None:
        self.assertIn("Select whole-repo staging only when", self.text)
        for alias in ("`all-dirty`", "`ship-all`", "`tout-dirty`"):
            self.assertIn(alias, self.text)
        self.assertIn("Preserve unrelated dirty work", self.text)

    def test_checks_and_push_do_not_become_product_proof(self) -> None:
        self.assertIn("A green check, clean push", self.text)
        self.assertIn("is not proof", self.text)
        self.assertIn("Never claim that green checks", self.reporting)

    def test_preview_handoff_stays_local(self) -> None:
        for phrase in (
            "For `vercel-preview-push`",
            "routes immediately to `405-sg-prod`",
            "never sends `107-sg-test` before `405-sg-prod`",
        ):
            self.assertIn(phrase, self.text)

    def test_temporary_artifacts_are_proposed_for_safe_cleanup_after_integration(self) -> None:
        for phrase in (
            "temporary by default",
            "fresh approval",
        ):
            self.assertIn(phrase, self.text)

        for phrase in (
            "Post-Ship Temporary Artifact Review",
            "refreshed intended remote target contains the temporary branch tip",
            "tracked or untracked changes",
            "never infer that an ordinary operator",
            "propose the exact cleanup scope",
            "never delete automatically",
        ):
            self.assertIn(phrase, self.execution)

        for phrase in (
            "cleanup disposition",
            "task-owned temporary branches and worktrees",
        ):
            self.assertIn(phrase, self.reporting)

    def test_agent_created_task_artifacts_have_a_terminal_git_disposition(self) -> None:
        for phrase in (
            "temporary by default",
            "intended target branch",
            "cleanup disposition",
            "`removed`",
            "`retained-explicit`",
            "review date",
        ):
            self.assertIn(phrase, self.git_lifecycle)

        for phrase in (
            "branch tip is an ancestor",
            "merged pull request",
            "source head SHA",
            "intended target branch",
            "worktree metadata",
            "local branch",
            "remote branch",
        ):
            self.assertIn(phrase, self.git_lifecycle)

        self.assertIn("terminal Git disposition", self.master_lifecycle)
        self.assertIn("cleanup disposition", self.reporting)

    def test_long_running_processes_remain_owned_until_verified_termination(self) -> None:
        for phrase in (
            "Managed Process Lifecycle",
            "controllable session handle or exact PID",
            "deterministic termination path",
            "`stopped`, `transferred-explicit`, or `retained-explicit`",
            "wait for exit",
            "verify that the exact process no longer runs",
            "broad executable name",
            "blocks clean closure",
        ):
            self.assertIn(phrase, self.master_lifecycle)

        for phrase in (
            "every task-owned managed process has a terminal disposition",
            "retained session or exact PID",
            "verified absent",
            "without broad process-name termination",
        ):
            self.assertIn(phrase, self.execution)

    def test_full_close_reloads_mutable_trackers(self) -> None:
        self.assertIn("Immediately before editing", self.full_close)
        self.assertIn("re-read the authoritative file from disk", self.full_close)
        self.assertIn("minimal targeted update", self.full_close)

    def test_skill_changes_keep_runtime_visibility_check(self) -> None:
        self.assertIn("materially update `skills/*/SKILL.md`", self.execution)
        self.assertIn("shipglows_sync_skills", self.execution)

    def test_report_reference_is_terminal_and_user_safe(self) -> None:
        self.assertIn("only after the ship attempt has reached a terminal state", self.reporting)
        self.assertIn("never expose a spec path", self.text)
        self.assertIn("Never expose internal skills", self.reporting)

    def test_full_close_exposes_documentation_reflection(self) -> None:
        for expected in (
            "documentation status",
            "`docs not checked` forbids full closure",
        ):
            self.assertIn(expected, self.text)
        self.assertIn("A material `needs review` result forbids full-closure", self.full_close)
        for expected in (
            "Every full-close report uses the shared ordered card",
            "`🧪 PREUVES`",
            "`📖 DOCUMENTATION`",
            "`✏️ ÉDITORIAL`",
            "separated by ` · `",
        ):
            self.assertIn(expected, self.reporting)


if __name__ == "__main__":
    unittest.main()
