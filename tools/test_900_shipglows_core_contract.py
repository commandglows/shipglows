#!/usr/bin/env python3
"""Regression checks for the 900-shipglows-core activation contract."""

from pathlib import Path
import re
import unittest


ROOT = Path(__file__).resolve().parents[1]
SKILL = ROOT / "skills" / "900-shipglows-core" / "SKILL.md"
BUILD_PLAYBOOK = ROOT / "skills" / "900-shipglows-core" / "references" / "skill-maintenance-playbook.md"
REFRESH_PLAYBOOK = ROOT / "skills" / "900-shipglows-core" / "references" / "skill-refresh-playbook.md"
PREFERRED_STACKS = ROOT / "skills" / "references" / "preferred-stacks.md"
QUESTION_CONTRACT = ROOT / "skills" / "references" / "question-contract.md"
READY_SKILL = ROOT / "skills" / "101-sg-ready" / "SKILL.md"
MAX_ACTIVATION_LINES = 220


class ShipGlowsCoreContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.text = SKILL.read_text(encoding="utf-8")
        cls.build = BUILD_PLAYBOOK.read_text(encoding="utf-8")
        cls.refresh = REFRESH_PLAYBOOK.read_text(encoding="utf-8")
        cls.preferred_stacks = PREFERRED_STACKS.read_text(encoding="utf-8")
        cls.question_contract = QUESTION_CONTRACT.read_text(encoding="utf-8")
        cls.ready_skill = READY_SKILL.read_text(encoding="utf-8")

    def test_system_improvement_fields_have_one_owner_definition(self) -> None:
        for field in (
            "`Observed problem`",
            "`System cause`",
            "`Prevention rule`",
            "`Contract/tooling improvement proposal`",
        ):
            self.assertEqual(self.text.count(field), 1, field)

    def test_scope_has_no_stale_read_only_contradiction(self) -> None:
        self.assertNotIn("Default to read-only analysis", self.text)
        self.assertIn("operator critique of ShipGlows execution authorizes a bounded repair", self.text)

    def test_observed_failure_requires_focused_proof(self) -> None:
        self.assertIn("apply the shared `Followability Gate`", self.text)
        self.assertIn("A passing generic audit is not completion proof", self.text)
        self.assertIn("Require focused mechanical or pressure-scenario proof", self.text)

    def test_validation_uses_current_tool_and_focused_test(self) -> None:
        self.assertIsNone(re.search(r"audit_shipglows_skills(?!\.py)", self.text))
        self.assertIn("audit_shipglows_skills.py", self.text)
        self.assertIn("python3 -m unittest tools.test_900_shipglows_core_contract", self.text)

    def test_activation_contract_is_compacted(self) -> None:
        self.assertLess(len(self.text.splitlines()), MAX_ACTIVATION_LINES)

    def test_packaging_uses_canonical_public_identity_without_exposing_core(self) -> None:
        self.assertIn("`shipglows` as the canonical public plugin", self.text)
        self.assertIn("`$shipglows` as its public entrypoint", self.text)
        self.assertIn("`shipglows` is a compatibility alias only", self.text)
        self.assertIn("`900-shipglows-core` internal and repo-synced", self.text)
        self.assertIn("deprecated historical pilot, never canonical or public", self.text)
        self.assertNotIn("Keep `shipglows` as the public user-facing plugin", self.text)
        self.assertNotIn("Keep `shipglows-core` internal and repo-synced", self.text)

    def test_mode_scenarios_cover_valid_invalid_and_retired_inputs(self) -> None:
        for mode in ("`audit`", "`build`", "`refresh`", "`packaging`", "`help`"):
            self.assertIn(mode, self.text)
        self.assertIn("Bare or invalid input", self.text)
        self.assertIn("without a target are invalid", self.text)
        self.assertIn("names as aliases", self.text)
        self.assertIn("Missing local playbook", self.text)

    def test_core_is_a_hard_shipglows_context_and_critique_is_a_bounded_repair(self) -> None:
        self.assertIn("hard ShipGlows-system context", self.text)
        self.assertIn("never to the current project", self.text)
        self.assertIn("select the narrowest internal\n`build` target", self.text)
        self.assertIn("without asking the operator to choose a mode", self.text)

    def test_core_critique_does_not_execute_the_quoted_project_task(self) -> None:
        self.assertIn("failure evidence only", self.text)
        self.assertIn("it does not audit either repository", self.text)
        self.assertIn("repairs the core routing rule", self.text)

    def test_build_playbook_preserves_lifecycle_runtime_and_surface_guards(self) -> None:
        for rule in (
            "Search adjacent skills",
            "Blueprint extraction",
            "100-sg-spec -> 101-sg-ready -> 102-sg-start -> 103-sg-verify -> 104-sg-end -> 005-sg-ship",
            "scenario and proof path",
            "display name to equal the exact invocation key",
            "skill-context-budget",
            "fresh-docs not needed",
            "Documentation Update Plan",
            "generic third-party generation",
            "operator-partnership-contract",
            "public by default",
        ):
            self.assertIn(rule, self.build)

    def test_refresh_playbook_preserves_conservative_contract(self) -> None:
        for rule in (
            "exact existing `skills/<name>/SKILL.md`",
            "prohibited",
            "official/primary sources",
            "decision-only",
            "update strictly obsolete checks in place",
            "skills/REFRESH_LOG.md",
            "**Sources:** N URLs consulted",
            "cross-surface coherence",
            "monthly maintenance pass",
            "Never edit its frontmatter `name:`",
            "Preserve every still-valid check",
            "Prepend one most-recent-first block",
        ):
            self.assertIn(rule, self.refresh)

    def test_build_requires_refresh_before_verify_with_narrow_exceptions(self) -> None:
        self.assertIn("900 refresh -> 103", self.text)
        self.assertIn("Every material skill edit receives conservative `refresh <target>` review", self.text)
        self.assertIn("before the final budget audit and `103-sg-verify`", self.build)
        self.assertIn("ordinary self-refresh stays prohibited", self.build)
        self.assertIn("independent manual review", self.build)
        self.assertIn("scenario-first and source-completeness proof", self.build)
        self.assertIn("`refresh not needed` only with a written justification and focused proof", self.build)
        self.assertIn("`fresh-docs not needed` is not that justification", self.build)

    def test_preferred_stack_is_cross_platform_first_not_mobile_only(self) -> None:
        for rule in (
            "first-recommendation defaults",
            "Recommend this pair first",
            "Flutter Web, iOS, and Android from the same application codebase",
            "`PSP-005 apparently mobile-only app`",
        ):
            self.assertIn(rule, self.preferred_stacks)
        self.assertIn("`SSRP-011 cross-platform first`", self.question_contract)
        self.assertIn("one mobile or browser target", self.ready_skill)


if __name__ == "__main__":
    unittest.main()
