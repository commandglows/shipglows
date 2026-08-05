#!/usr/bin/env python3
"""Regression checks for owner-bound Codex expert aliases."""

import json
from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
PUBLIC_ROUTER = ROOT / "skills" / "000-shipglows" / "SKILL.md"
COMPAT_ROUTER = ROOT / ".agents" / "skills" / "shipglows" / "SKILL.md"
CORE = ROOT / "skills" / "900-shipglows-core" / "SKILL.md"
REGISTRY = ROOT / "skills" / "references" / "skill-invocation-registry.json"
ALIASES = ROOT / "skills" / "references" / "expert-mode-aliases.md"

EXPECTED_ALIASES = {
    "core",
    "explore",
    "spec",
    "status",
    "resume",
    "build",
    "fix",
    "verify",
    "test",
    "browser",
    "capture",
    "tmux",
    "ship",
    "deploy",
    "prod",
}


class ShipGlowsCoreAliasContractTests(unittest.TestCase):
    def test_core_is_a_hard_shipglows_context_in_every_entrypoint(self) -> None:
        public = PUBLIC_ROUTER.read_text(encoding="utf-8")
        compatibility = COMPAT_ROUTER.read_text(encoding="utf-8")
        core = CORE.read_text(encoding="utf-8")

        self.assertIn("Never\nredirect any part of a `core` instruction to the current project", public)
        self.assertIn("every remaining word as ShipGlows-system work", compatibility)
        self.assertIn("No later project name, repository path, request, or quoted outcome overrides", core)
        self.assertIn("it does not audit either repository", core)

    def test_every_alias_has_one_public_owner_mode_and_internal_engine(self) -> None:
        registry = json.loads(REGISTRY.read_text(encoding="utf-8"))
        aliases = registry["codex_expert_aliases"]
        self.assertEqual(EXPECTED_ALIASES, set(aliases))

        entries = {
            entry["id"]: entry
            for domain in registry["public_catalog"]["domains"]
            for entry in domain["skills"]
        }
        router = registry["public_catalog"]["router"]
        entries[router["id"]] = router

        for alias, mapping in aliases.items():
            owner = entries[mapping["public_owner"]]
            declared_modes = set(owner.get("modes", [])) | set(owner.get("hidden_modes", {}))
            self.assertIn(mapping["owner_mode"], declared_modes, alias)
            engines = set(owner.get("internal_engines", [])) | {owner["runtime_skill"]}
            if alias == "core":
                engines.add("900-shipglows-core")
            self.assertIn(mapping["runtime_engine"], engines, alias)

            for specialist in mapping.get("specialist_routes", []):
                specialist_owner = entries[specialist["public_owner"]]
                specialist_modes = set(specialist_owner.get("modes", [])) | set(specialist_owner.get("hidden_modes", {}))
                self.assertIn(specialist["owner_mode"], specialist_modes, alias)
                specialist_engines = set(specialist_owner.get("internal_engines", [])) | {specialist_owner["runtime_skill"]}
                self.assertIn(specialist["runtime_engine"], specialist_engines, alias)
                self.assertTrue(specialist["keywords"], alias)

    def test_alias_reference_shows_public_owner_before_internal_engine(self) -> None:
        alias_text = ALIASES.read_text(encoding="utf-8")
        for expected in (
            "| `build` | `sg-development` | `build` | `001-sg-build` |",
            "| `spec` | `sg-planning` | `spec` | `100-sg-spec` |",
            "| `ship` | `sg-release` | `ship` | `005-sg-ship` |",
            "| `capture` | `sg-content` | `capture` | `800-tmux-capture-conversation` |",
            "| `tmux` | `sg-content` | `capture` | `800-tmux-capture-conversation` |",
        ):
            self.assertIn(expected, alias_text)

    def test_verify_preserves_specialist_ownership(self) -> None:
        public = PUBLIC_ROUTER.read_text(encoding="utf-8")
        aliases = ALIASES.read_text(encoding="utf-8")
        for owner in ("`sg-design`", "`sg-seo`", "`sg-release`", "`sg-bug`"):
            self.assertIn(owner, aliases)
        self.assertIn("Generic verification never", public)


if __name__ == "__main__":
    unittest.main()
