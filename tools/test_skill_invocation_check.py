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
        self.assertEqual(payload["suggestion"], "sg-development excellence [task or scope]")

    def test_public_hidden_excellence_shortcut_uses_the_verification_engine(self) -> None:
        payload = check("sg-development excellence checkout")
        self.assertEqual(payload["status"], "valid")
        self.assertEqual(payload["resolved_skill"], "sg-development")
        self.assertEqual(payload["selected_internal_engine"], "103-sg-verify")
        self.assertEqual(payload["selected_engine_mode"], "excellence")

    def test_codex_expert_alias_resolves_through_public_owner_mode(self) -> None:
        payload = check("shipglows spec checkout")
        self.assertEqual(payload["status"], "valid")
        self.assertEqual(payload["router_alias"], "spec")
        self.assertEqual(payload["public_owner"], "sg-planning")
        self.assertEqual(payload["mode"], "spec")
        self.assertEqual(payload["selected_internal_engine"], "100-sg-spec")
        self.assertEqual(payload["resolution"], "direct")

    def test_git_alias_routes_to_engineering_github_hygiene(self) -> None:
        payload = check("shipglows git reconcile current repo")
        self.assertEqual(payload["status"], "valid")
        self.assertEqual(payload["router_alias"], "git")
        self.assertEqual(payload["public_owner"], "sg-engineering")
        self.assertEqual(payload["mode"], "github")
        self.assertEqual(payload["selected_internal_engine"], "010-sg-technical")
        self.assertEqual(payload["resolution"], "direct")

    def test_capture_aliases_resolve_to_the_content_capture_engine(self) -> None:
        for invocation in ("shipglows capture", "shipglows tmux"):
            payload = check(invocation)
            self.assertEqual(payload["status"], "valid", invocation)
            self.assertEqual(payload["public_owner"], "sg-content")
            self.assertEqual(payload["mode"], "capture")
            self.assertEqual(payload["selected_internal_engine"], "800-tmux-capture-conversation")

        canonical = check("sg-content capture")
        self.assertEqual(canonical["status"], "valid")
        self.assertEqual(canonical["mode"], "capture")

        alias = check("sg-content tmux")
        self.assertEqual(alias["status"], "valid")
        self.assertEqual(alias["mode"], "capture")
        self.assertEqual(alias["mode_alias"], "tmux")
        self.assertEqual(alias["selected_internal_engine"], "800-tmux-capture-conversation")

    def test_contextual_verify_alias_keeps_specialist_resolution_visible(self) -> None:
        payload = check("shipglows verify accessibility")
        self.assertEqual(payload["status"], "valid")
        self.assertEqual(payload["public_owner"], "sg-design")
        self.assertEqual(payload["mode"], "audit")
        self.assertEqual(payload["selected_internal_engine"], "006-sg-design")
        self.assertEqual(payload["resolution"], "specialist")

    def test_contextual_verify_alias_uses_engineering_fallback_without_specialist_scope(self) -> None:
        payload = check("shipglows verify implementation quality")
        self.assertEqual(payload["status"], "valid")
        self.assertEqual(payload["public_owner"], "sg-engineering")
        self.assertEqual(payload["mode"], "verify")
        self.assertEqual(payload["selected_internal_engine"], "103-sg-verify")
        self.assertEqual(payload["resolution"], "contextual-specialist")

    def test_hidden_public_expert_mode_routes_to_declared_engine(self) -> None:
        payload = check("sg-planning status")
        self.assertEqual(payload["status"], "valid")
        self.assertEqual(payload["resolved_skill"], "sg-planning")
        self.assertEqual(payload["mode"], "status")
        self.assertEqual(payload["selected_internal_engine"], "308-sg-status")

    def test_expert_excellence_engine_remains_valid_when_explicitly_available(self) -> None:
        payload = check("103-sg-verify excellence")
        self.assertEqual(payload["status"], "valid")
        self.assertEqual(payload["mode"], "excellence")

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
