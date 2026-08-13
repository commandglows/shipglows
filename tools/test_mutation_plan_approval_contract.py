#!/usr/bin/env python3
"""Regression checks for the shared mutation-plan approval contract."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "skills" / "references" / "mutation-plan-approval.md"
STRATEGIC = ROOT / "skills" / "references" / "strategic-choice-contract.md"


class MutationPlanApprovalContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.text = CONTRACT.read_text(encoding="utf-8")

    def test_opening_identity_matches_chantier_reporting(self) -> None:
        for expected in (
            "🧭 PLAN À VALIDER (<local|spec>) : <short plan name>",
            "🎯 VALIDATION (HH:mm) : en attente",
            "Paris time",
        ):
            self.assertIn(expected, self.text)

    def test_required_sections_keep_visual_hierarchy(self) -> None:
        for expected in (
            "🎯 **Objectif**",
            "📂 **Périmètre**",
            "🔨 **Actions**",
            "✅ **Preuves**",
            "📌 **Choix**",
        ):
            self.assertIn(expected, self.text)

    def test_choices_are_contextual_and_unambiguous(self) -> None:
        for expected in (
            "two or three numbered choices",
            "adapted to the actual decision",
            "Exactly one choice may grant approval",
            "must not be a fixed menu",
            "A number-only reply",
        ):
            self.assertIn(expected, self.text)

        self.assertIn("strategic-choice-contract.md", self.text)
        strategic = STRATEGIC.read_text(encoding="utf-8")
        self.assertIn("business or product outcome", strategic)
        self.assertIn("guided follow-up", strategic)

    def test_pressure_scenarios_cover_local_spec_and_replacement(self) -> None:
        for scenario in (
            "MAP-LOCAL",
            "MAP-SPEC",
            "MAP-CONTEXTUAL-CHOICES",
            "MAP-NUMBER-ONLY",
            "MAP-REPLACEMENT",
        ):
            self.assertIn(scenario, self.text)

    def test_fast_validation_has_cumulative_eligibility_and_compact_shape(self) -> None:
        for expected in (
            "🧭 VALIDATION RAPIDE",
            "every criterion below is established",
            "explicitly requested and unambiguous",
            "exact and resolved",
            "local-only",
            "routine",
            "readily reversible",
            "one or two sentences",
            "exact action",
            "exact target",
            "main safety guarantee",
            "Do not add the four full-plan sections",
        ):
            self.assertIn(expected, self.text)

    def test_fast_validation_excludes_risky_or_external_effects(self) -> None:
        for excluded in (
            "overwrite",
            "discard",
            "delete",
            "force",
            "publish",
            "deploy",
            "message",
            "credential",
            "permission",
            "unrelated changes",
        ):
            self.assertIn(excluded, self.text)
        self.assertIn("`git push` always requires the full plan", self.text)
        self.assertIn("Force push retains every stricter gate", self.text)

    def test_fast_pressure_scenarios_cover_git_and_replacement_boundaries(self) -> None:
        for scenario in (
            "MAP-FAST-SWITCH",
            "MAP-FAST-WORKTREE",
            "MAP-FAST-INELIGIBLE",
            "MAP-FAST-REPLACEMENT",
            "MAP-REMOTE-PUSH",
        ):
            self.assertIn(scenario, self.text)

    def test_fast_switch_requires_exact_existing_branch_and_change_safety(self) -> None:
        scenario = self._scenario("MAP-FAST-SWITCH")
        for expected in (
            "exact existing local branch",
            "cannot overwrite, discard, or relocate current changes",
        ):
            self.assertIn(expected, scenario)

    def test_fast_worktree_requires_exact_available_targets_and_resolved_base(self) -> None:
        scenario = self._scenario("MAP-FAST-WORKTREE")
        for expected in (
            "exact branch availability",
            "exact path availability",
            "resolved base",
            "current worktree remains untouched",
        ):
            self.assertIn(expected, scenario)

    def test_fast_ineligible_falls_back_on_any_unproven_criterion(self) -> None:
        scenario = self._scenario("MAP-FAST-INELIGIBLE")
        self.assertIn("any fast criterion is missing, uncertain, or false", scenario)
        self.assertIn("full `🧭 PLAN À VALIDER`", scenario)

    def test_fast_replacement_invalidates_prior_approval(self) -> None:
        scenario = self._scenario("MAP-FAST-REPLACEMENT")
        for expected in ("new target, effect, or risk", "prior approval is invalid"):
            self.assertIn(expected, scenario)

    def test_remote_push_always_uses_full_plan_and_force_keeps_stricter_gates(self) -> None:
        scenario = self._scenario("MAP-REMOTE-PUSH")
        self.assertIn("every `git push` uses the full", scenario)
        self.assertIn("force push also retains all stricter", scenario)

    def test_small_change_selects_path_from_all_fast_criteria(self) -> None:
        scenario = self._scenario("MAP-SMALL-CHANGE")
        self.assertIn("only when every fast-path criterion is established", scenario)
        self.assertIn("otherwise it uses the full", scenario)

    def test_initial_request_never_approves_either_path(self) -> None:
        self.assertIn("initial imperative request does not count as approval", self.text)
        self.assertIn("both approval paths", self.text)

    def _scenario(self, name: str) -> str:
        marker = f"- `{name}`:"
        return next(line for line in self.text.splitlines() if line.startswith(marker))


if __name__ == "__main__":
    unittest.main()
