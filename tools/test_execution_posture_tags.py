#!/usr/bin/env python3
"""Behavioral scenarios for transversal ShipGlows execution posture tags."""

from pathlib import Path
import unittest

from tools.skill_invocation_check import check


ROOT = Path(__file__).resolve().parents[1]
TERMS = ROOT / "skills" / "references" / "shipglows-terms.md"
POSTURES = ROOT / "skills" / "references" / "execution-posture-tags.md"
CHEATSHEET = ROOT / "shipglows_data" / "technical" / "operator-guides" / "skill-launch-cheatsheet.md"
FOCUS_CHEATSHEET = ROOT / "shipglows_data" / "technical" / "operator-guides" / "focus-tags-cheatsheet.md"


class ExecutionPostureTagTests(unittest.TestCase):
    def test_nolocal_is_position_independent_for_public_commands(self) -> None:
        for invocation in (
            "sg-development feature checkout #nolocal",
            "#nolocal sg-development feature checkout",
            "sg-development #nolocal feature checkout",
        ):
            payload = check(invocation)
            self.assertEqual("valid", payload["status"], invocation)
            self.assertEqual(["#nolocal"], payload["requested_execution_tags"])
            self.assertEqual(["#nolocal"], payload["effective_execution_tags"])
            self.assertEqual("nolocal", payload["execution_posture"])

    def test_local_is_explicit_permission_not_a_forced_workload(self) -> None:
        payload = check("sg-bug fix checkout #local")
        self.assertEqual("valid", payload["status"])
        self.assertEqual(["#local"], payload["effective_execution_tags"])
        self.assertEqual("local", payload["execution_posture"])

    def test_ci_implies_nolocal_and_names_ci_as_deferred_proof_target(self) -> None:
        payload = check("sg-engineering verify checkout #ci")
        self.assertEqual("valid", payload["status"])
        self.assertEqual(["#ci"], payload["requested_execution_tags"])
        self.assertEqual(["#ci", "#nolocal"], payload["effective_execution_tags"])
        self.assertEqual("ci", payload["execution_posture"])
        self.assertEqual("ci", payload["deferred_proof_target"])

    def test_execution_posture_conflicts_fail_closed(self) -> None:
        for invocation in (
            "sg-development feature checkout #local #nolocal",
            "sg-development feature checkout #local #ci",
        ):
            payload = check(invocation)
            self.assertEqual("invalid", payload["status"], invocation)
            self.assertEqual("conflicting_execution_tags", payload["error"])

    def test_auto_implicitly_adds_nolocal_and_rejects_local(self) -> None:
        implicit = check("shipglows auto until=18:00")
        self.assertEqual("valid", implicit["status"])
        self.assertEqual([], implicit["requested_execution_tags"])
        self.assertEqual(["#nolocal"], implicit["effective_execution_tags"])
        self.assertEqual(["#nolocal"], implicit["implied_execution_tags"])

        ci = check("shipglows auto #ci until=18:00")
        self.assertEqual("valid", ci["status"])
        self.assertEqual(["#ci", "#nolocal"], ci["effective_execution_tags"])

        local = check("shipglows auto #local")
        self.assertEqual("invalid", local["status"])
        self.assertEqual("unsupported_execution_tag", local["error"])

    def test_legacy_nolocal_mode_normalizes_to_the_tag(self) -> None:
        payload = check("shipglows nolocal improve checkout")
        self.assertEqual("valid", payload["status"])
        self.assertEqual("default", payload["mode"])
        self.assertEqual("nolocal", payload["mode_alias"])
        self.assertEqual(["#nolocal"], payload["effective_execution_tags"])
        self.assertEqual("shipglows improve checkout #nolocal", payload["normalized_invocation"])

        bare = check("shipglows nolocal")
        self.assertEqual("invalid", bare["status"])
        self.assertEqual("missing_argument", bare["error"])

    def test_tags_apply_to_expert_invocations_without_consuming_focus_tags(self) -> None:
        expert = check("103-sg-verify excellence checkout #ci")
        self.assertEqual("valid", expert["status"])
        self.assertEqual(["#ci", "#nolocal"], expert["effective_execution_tags"])

        focus = check("sg-development feature checkout #docs")
        self.assertEqual("valid", focus["status"])
        self.assertNotIn("execution_posture", focus)

    def test_docs_define_posture_authority_and_shell_boundaries(self) -> None:
        postures = POSTURES.read_text(encoding="utf-8")
        terms = TERMS.read_text(encoding="utf-8")
        cheatsheets = CHEATSHEET.read_text(encoding="utf-8") + FOCUS_CHEATSHEET.read_text(encoding="utf-8")
        for tag in ("#local", "#nolocal", "#ci"):
            self.assertIn(f"`{tag}`", postures)
            self.assertIn(f"`{tag}`", terms)
            self.assertIn(f"`{tag}`", cheatsheets)
        self.assertIn("does not authorize", postures)
        self.assertIn("shell comment", postures)
        self.assertIn("legacy compatibility alias", postures)


if __name__ == "__main__":
    unittest.main()
