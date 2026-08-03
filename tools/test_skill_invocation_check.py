#!/usr/bin/env python3
"""Scenario tests for the explicit ShipGlows invocation checker."""

import json
from pathlib import Path
from tempfile import TemporaryDirectory
import unittest

from tools.skill_invocation_check import check


class SkillInvocationCheckTests(unittest.TestCase):
    def test_valid_master_invocations_are_silent_and_valid(self) -> None:
        for command in (
            "001-sg-build improve checkout",
            "006-sg-design audit ui homepage",
            "007-sg-content repurpose source",
            "900-shipglows-core build router",
        ):
            payload = check(command)
            self.assertEqual(payload["status"], "valid", command)

    def test_observed_cross_skill_mode_failure_is_blocked_with_correction(self) -> None:
        payload = check("006-sg-design repurpose verbatim 4")
        self.assertEqual(payload["status"], "invalid")
        self.assertEqual(payload["error"], "unknown_mode")
        self.assertEqual(payload["resolved_skill"], "006-sg-design")
        self.assertEqual(payload["suggestion"], "007-sg-content repurpose <source> verbatim")

    def test_clear_typo_suggests_but_never_validates_or_executes(self) -> None:
        payload = check("006-sg-design regurgose verbatim 4")
        self.assertEqual(payload["status"], "invalid")
        self.assertEqual(payload["did_you_mean"], "repurpose")
        self.assertEqual(payload["suggestion"], "007-sg-content repurpose <source> verbatim")

    def test_ambiguous_or_distant_typo_gets_no_suggestion(self) -> None:
        payload = check("006-sg-design zzzzzzzzz")
        self.assertEqual(payload["status"], "invalid")
        self.assertNotIn("did_you_mean", payload)
        self.assertNotIn("suggestion", payload)

    def test_equally_close_modes_are_ambiguous_and_never_corrected(self) -> None:
        with TemporaryDirectory() as temporary:
            temporary_root = Path(temporary)
            index = temporary_root / "index.md"
            registry = temporary_root / "registry.json"
            index.write_text(
                "| `006` | `sg-design` | `006-sg-design` | Master |\n",
                encoding="utf-8",
            )
            registry.write_text(
                json.dumps(
                    {
                        "rules": {
                            "006-sg-design": {
                                "kind": "modes",
                                "modes": {"plan": {"min_args": 0}, "play": {"min_args": 0}},
                            }
                        },
                        "mode_suggestions": {},
                    }
                ),
                encoding="utf-8",
            )
            payload = check("006-sg-design plai", index, registry)
            self.assertEqual(payload["status"], "ambiguous")
            self.assertEqual(payload["candidates"], ["plan", "play"])
            self.assertNotIn("suggestion", payload)

    def test_known_excellence_mode_routes_to_verification_owner(self) -> None:
        payload = check("900-shipglows-core excellence")
        self.assertEqual(payload["status"], "invalid")
        self.assertEqual(payload["error"], "unknown_mode")
        self.assertEqual(payload["suggestion"], "103-sg-verify mode=excellence <task or scope>")

    def test_missing_required_arguments_do_not_reuse_context(self) -> None:
        payload = check("900-shipglows-core build")
        self.assertEqual(payload["status"], "invalid")
        self.assertEqual(payload["error"], "missing_argument")

    def test_unknown_skill_never_invents_an_owner(self) -> None:
        payload = check("999-sg-imaginary audit")
        self.assertEqual(payload["status"], "invalid")
        self.assertEqual(payload["error"], "unknown_skill")
        self.assertNotIn("suggestion", payload)

    def test_numeric_compact_identity_resolves_from_canonical_index(self) -> None:
        payload = check("006sgdesign audit ui")
        self.assertEqual(payload["status"], "valid")
        self.assertEqual(payload["resolved_skill"], "006-sg-design")

    def test_all_declared_masters_load_the_same_preflight_contract(self) -> None:
        root = Path(__file__).resolve().parents[1]
        masters = (
            "000-shipglows",
            "001-sg-build",
            "002-sg-maintain",
            "003-sg-bug",
            "004-sg-deploy",
            "006-sg-design",
            "007-sg-content",
            "008-sg-customer",
            "009-sg-marketing",
            "010-sg-technical",
            "900-shipglows-core",
        )
        for skill in masters:
            text = (root / "skills" / skill / "SKILL.md").read_text(encoding="utf-8")
            self.assertIn("skill-invocation-preflight.md", text, skill)

    def test_registry_is_json_and_declares_every_checked_master(self) -> None:
        registry = Path(__file__).resolve().parents[1] / "skills/references/skill-invocation-registry.json"
        rules = json.loads(registry.read_text(encoding="utf-8"))["rules"]
        self.assertIn("006-sg-design", rules)
        self.assertIn("900-shipglows-core", rules)

    def test_registry_identities_exist_in_the_canonical_index_and_on_disk(self) -> None:
        root = Path(__file__).resolve().parents[1]
        registry_path = root / "skills/references/skill-invocation-registry.json"
        rules = json.loads(registry_path.read_text(encoding="utf-8"))["rules"]
        index_text = (root / "skills/references/skill-code-index.md").read_text(encoding="utf-8")
        for skill in rules:
            self.assertIn(f"`{skill}`", index_text, skill)
            self.assertTrue((root / "skills" / skill / "SKILL.md").is_file(), skill)


if __name__ == "__main__":
    unittest.main()
