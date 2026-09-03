#!/usr/bin/env python3
"""Regression checks for the shared mutation-plan approval contract."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "skills" / "references" / "mutation-plan-approval.md"
STRATEGIC = ROOT / "skills" / "references" / "strategic-choice-contract.md"
LIFECYCLE = ROOT / "skills" / "references" / "master-workflow-lifecycle.md"
DELEGATION = ROOT / "skills" / "references" / "master-delegation-semantics.md"
ROUTER = ROOT / "skills" / "000-shipglows" / "SKILL.md"
WINDOWS_AGENT_INSTRUCTIONS = ROOT / "cli" / "windows" / "ShipGlows.AgentInstructions.psm1"
PUBLIC_PLUGIN = ROOT / "plugins" / "shipglows" / "skills" / "shipglows" / "SKILL.md"
REPORTING = ROOT / "skills" / "references" / "reporting-contract.md"
NEXT_OUTCOME = ROOT / "skills" / "references" / "next-outcome-selection.md"


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
            "clear, bounded, and unambiguous",
            "exact and resolved",
            "few and enumerable",
            "material direction",
            "one or two sentences",
            "exact action",
            "exact target",
            "main safety guarantee",
            "Do not add the four full-plan sections",
        ):
            self.assertIn(expected, self.text)

    def test_dedicated_safety_boundaries_are_not_chantier_classifiers(self) -> None:
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
        self.assertIn("Local versus remote is not an approval classifier", self.text)
        self.assertIn("ordinary `git push`", self.text)
        self.assertIn("Force push retains every stricter gate", self.text)

    def test_fast_pressure_scenarios_cover_git_and_replacement_boundaries(self) -> None:
        for scenario in (
            "MAP-FAST-SWITCH",
            "MAP-FAST-WORKTREE",
            "MAP-FAST-INELIGIBLE",
            "MAP-FAST-REPLACEMENT",
            "MAP-BOUNDED-PUSH",
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

    def test_explicit_bounded_push_executes_directly_and_force_keeps_stricter_gates(self) -> None:
        scenario = self._scenario("MAP-BOUNDED-PUSH")
        self.assertIn("ordinary push", scenario)
        self.assertIn("execute directly", scenario)
        self.assertIn("force push retains all stricter", scenario)

    def test_small_change_uses_direct_request_authority_before_validation(self) -> None:
        scenario = self._scenario("MAP-SMALL-CHANGE")
        self.assertIn("execute it from the operator's exact request", scenario)
        self.assertIn("without an approval prompt", scenario)
        self.assertIn("becomes a chantier", scenario)

    def test_clear_bounded_request_is_authority_for_its_enumerable_actions(self) -> None:
        for expected in (
            "## Clear bounded-request authority",
            "The operator's initial imperative is authority",
            "does not create or approve a chantier",
            "few, coherent, and enumerable",
            "material direction",
            "targeted file modification",
            "ordinary exact-scope commit",
            "ordinary push",
            "without another approval message",
            "MAP-BOUNDED-REQUEST",
            "MAP-BOUNDED-EXPANSION",
        ):
            self.assertIn(expected, self.text)

        direct = self._scenario("MAP-BOUNDED-REQUEST")
        self.assertIn("initial request is the authority", direct)
        self.assertIn("no validation prompt", direct)

        boundary = self._scenario("MAP-BOUNDED-EXPANSION")
        self.assertIn("expands materially", boundary)
        self.assertIn("full plan", boundary)

    def test_authorized_exact_scope_commit_never_gets_a_separate_prompt(self) -> None:
        for expected in (
            "An ordinary exact-scope commit records authorized work",
            "never requires a separate approval prompt",
            "unrelated and pre-existing changes remain unstaged",
        ):
            self.assertIn(expected, self.text)

    def test_direct_authority_is_propagated_to_primary_runtime_surfaces(self) -> None:
        for path in (ROUTER, WINDOWS_AGENT_INSTRUCTIONS, PUBLIC_PLUGIN):
            surface = path.read_text(encoding="utf-8")
            self.assertIn("clear bounded request", surface, str(path))
            self.assertIn("few", surface, str(path))
            self.assertIn("material direction", surface, str(path))
            self.assertIn("does not authorize a chantier", surface, str(path))

    def test_classification_is_invariant_across_reasoning_effort(self) -> None:
        for expected in (
            "Classification is invariant across reasoning-effort settings",
            "request clarity",
            "enumerable action and target count",
            "directional discretion",
            "never the selected reasoning effort",
            "MAP-EFFORT-INVARIANT",
        ):
            self.assertIn(expected, self.text)

        scenario = self._scenario("MAP-EFFORT-INVARIANT")
        for effort in ("low", "medium", "high", "xhigh"):
            self.assertIn(f"`{effort}`", scenario)

    def test_supplied_link_register_append_uses_original_request_authority(self) -> None:
        for expected in (
            "## Supplied-link register authority",
            "Do not ask for a second confirmation",
            "append supplied public links",
            "exact existing internal reference register",
            "the category requested by the operator, `candidate` status",
            "append-only, local-only, readily reversible",
            "no market analysis, competitor claim, product claim, pricing",
            "MAP-SUPPLIED-LINK-REGISTER",
        ):
            self.assertIn(expected, self.text)

        scenario = self._scenario("MAP-SUPPLIED-LINK-REGISTER")
        self.assertIn("do not request a second approval", scenario)
        self.assertIn("uses the normal gate", scenario)

    def test_initial_request_does_not_approve_a_chantier_or_risky_action(self) -> None:
        self.assertIn("Every mutation outside those named paths", self.text)
        self.assertIn("explicit approval given after its message", self.text)
        self.assertIn("A clear bounded request never authorizes a chantier", self.text)

    def test_git_stewardship_has_standing_authority_without_validation(self) -> None:
        for marker in (
            "## Git/GitHub stewardship authority",
            "without asking for validation",
            "non-live `development` projects integrate directly into `main`",
            "live `published` and `sensitive-production` projects integrate into canonical `dev`",
            "without a separate Git validation",
            "deletion of temporary local/remote branches or worktrees only after exact ownership and integration are mechanically proven",
            "Preserve and diagnose uncertain state instead of asking for a Git validation",
            "MAP-GIT-STANDING-AUTHORITY",
            "MAP-GIT-NON-LIVE-MAIN",
            "MAP-GIT-LIVE-DEV",
            "MAP-GIT-PROMOTION",
            "MAP-GIT-CONTINUAL-CONVERGENCE",
            "MAP-GIT-UNCERTAIN-PRESERVE",
        ):
            self.assertIn(marker, self.text)

    def test_reporting_continues_through_merge_ready_pr_and_cleanup(self) -> None:
        reporting = REPORTING.read_text(encoding="utf-8")
        for expected in (
            "remains active in-scope delivery, not a next-step suggestion",
            "attempt reconciliation into the resolved integration branch",
            "proven-integrated temporary-artifact cleanup",
            "Never stop merely because the pull request was opened or became green",
        ):
            self.assertIn(expected, reporting)

    def test_reporting_allows_true_closure_without_invented_work(self) -> None:
        reporting = REPORTING.read_text(encoding="utf-8")
        selection = NEXT_OUTCOME.read_text(encoding="utf-8")
        for expected in (
            "use exactly `🧭 SUITE\\nChantier clos.`",
            "never invent urgency, authority, or unrelated work",
        ):
            self.assertIn(expected, reporting)
        for expected in (
            "proof, delivery, reconciliation, and owned cleanup are complete",
            "Do not inspect unrelated branches, trackers, audits, repositories, or product surfaces solely to manufacture continuation",
            "SUITE-FALSE-CLOSURE",
            "SUITE-INVENTED",
        ):
            self.assertIn(expected, selection)

    def test_v_is_a_bounded_immediate_approval_shortcut(self) -> None:
        for expected in (
            "consisting only of `v`",
            "case-insensitive, ignoring surrounding whitespace",
            "immediately preceding pending fast validation",
            "immediately preceding pending plan",
            "exactly one approval outcome",
            "It never authorizes a replaced, ambiguous, paused, materially changed, or cancelled proposal",
            "MAP-V-SHORTCUT",
        ):
            self.assertIn(expected, self.text)

        scenario = self._scenario("MAP-V-SHORTCUT")
        for boundary in (
            "standalone `v` or `V`",
            "immediately preceding pending approval message",
            "does nothing before an approval message",
            "still-current unchanged proposal",
            "explicitly preserved the `v` mapping",
        ):
            self.assertIn(boundary, scenario)

    def test_non_material_clarification_keeps_proposal_pending_without_reissue(self) -> None:
        for expected in (
            "non-material clarification",
            "answer it without reissuing or restating the unchanged approval message",
            "same proposal remains pending",
            "MAP-PENDING-CLARIFICATION",
        ):
            self.assertIn(expected, self.text)

        scenario = self._scenario("MAP-PENDING-CLARIFICATION")
        self.assertIn("answer the question", scenario)
        self.assertIn("do not repeat the validation or plan", scenario)

    def test_neutral_acknowledgement_neither_approves_nor_reprompts(self) -> None:
        for expected in (
            "Neutral acknowledgements",
            "`ok`, `compris`, `merci`, or `thanks`",
            "neither authorize mutation nor trigger another approval prompt",
            "MAP-NEUTRAL-ACK",
        ):
            self.assertIn(expected, self.text)

    def test_later_explicit_approval_can_authorize_unchanged_proposal(self) -> None:
        for expected in (
            "later explicit and unambiguous action approval",
            "still-current unchanged proposal",
            "without restating it",
            "MAP-LATER-APPROVAL",
        ):
            self.assertIn(expected, self.text)

    def test_material_change_still_invalidates_pending_proposal(self) -> None:
        scenario = self._scenario("MAP-PENDING-MATERIAL-CHANGE")
        for boundary in (
            "scope, behavior, target, risk, data, permissions",
            "destructive or external effects",
            "proof strategy",
            "replacement approval message",
        ):
            self.assertIn(boundary, scenario)

    def test_technical_plan_approval_includes_milestone_persistence_authority(self) -> None:
        for expected in (
            "Cumulative milestone persistence authority",
            "ordinary milestone commits and pushes by default",
            "without a second approval message",
            "unrelated and pre-existing changes remain unstaged",
            "secret and sensitive-data checks pass",
            "multiple small coherent commits",
            "do not interrupt merely to ask permission",
        ):
            self.assertIn(expected, self.text)

    def test_implicit_commit_authority_keeps_strict_boundaries(self) -> None:
        for expected in (
            "no amend, rebase, squash, reset, tag, force, hook bypass, merge, deployment, or unrelated remote effect",
            "resolved unambiguous upstream",
            "substantive editorial judgment",
            "broad mixed-scope consolidation",
            "explicitly requested ordinary push may use clear bounded-request authority",
            "MAP-TECHNICAL-COMMIT",
            "MAP-MILESTONE-COMMIT",
            "MAP-COMMIT-BOUNDARY",
        ):
            self.assertIn(expected, self.text)

    def test_master_contracts_propagate_commit_authority_without_duplicate_prompt(self) -> None:
        lifecycle = LIFECYCLE.read_text(encoding="utf-8")
        delegation = DELEGATION.read_text(encoding="utf-8")
        self.assertIn("Git/GitHub stewardship is the standing exception", lifecycle)
        self.assertIn("Exact-scope staging for an already approved technical commit", lifecycle)
        self.assertIn("ordinary exact-scope milestone commits and pushes", delegation)
        self.assertIn("unapproved staging", delegation)

    def test_master_contract_propagates_pending_proposal_turn_semantics(self) -> None:
        delegation = DELEGATION.read_text(encoding="utf-8")
        for expected in (
            "A non-material clarification keeps the unchanged proposal pending",
            "Neutral acknowledgements such as `ok`, `compris`, `merci`, or `thanks`",
            "neither approve nor trigger a repeated approval prompt",
            "A later explicit and unambiguous action approval may authorize that still-current unchanged proposal",
            "Material changes invalidate it",
        ):
            self.assertIn(expected, delegation)

    def test_approved_technical_scope_includes_directly_mapped_closure_docs(self) -> None:
        for expected in (
            "directly mapped canonical project documentation",
            "keep the approved technical behavior truthful at closure",
            "It does not include substantive editorial rewriting",
            "broad documentation migration",
        ):
            self.assertIn(expected, self.text)

    def _scenario(self, name: str) -> str:
        marker = f"- `{name}`:"
        return next(line for line in self.text.splitlines() if line.startswith(marker))


if __name__ == "__main__":
    unittest.main()
