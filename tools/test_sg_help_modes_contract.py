#!/usr/bin/env python3
"""Focused contract checks for the one-line ShipGlows mode catalog."""

import json
from pathlib import Path
import re
import subprocess
import sys
import unittest


ROOT = Path(__file__).resolve().parents[1]
SKILLS_ROOT = ROOT / "skills"
HELP_SKILL = SKILLS_ROOT / "302-sg-help" / "SKILL.md"
CATALOG = SKILLS_ROOT / "302-sg-help" / "references" / "help-modes-catalog.md"
REGISTRY = SKILLS_ROOT / "references" / "skill-invocation-registry.json"
EXPERT_CATALOG = SKILLS_ROOT / "302-sg-help" / "references" / "help-modes-expert-catalog.md"


class HelpModesContractTests(unittest.TestCase):
    def catalog_lines(self, path: Path = CATALOG) -> list[str]:
        return [
            line
            for line in path.read_text(encoding="utf-8").splitlines()
            if line.startswith("`") and " — " in line
        ]

    def catalog_id(self, line: str) -> str:
        return line.split("`", 2)[1].split(" ", 1)[0]

    def test_default_catalog_has_exactly_one_line_for_every_public_skill(self) -> None:
        public = json.loads(REGISTRY.read_text(encoding="utf-8"))["public_catalog"]
        expected = [
            skill["id"]
            for domain in public["domains"]
            for skill in domain["skills"]
        ] + [public["router"]["id"]]
        lines = self.catalog_lines()
        actual = [self.catalog_id(line) for line in lines]
        self.assertEqual(expected, actual)
        self.assertEqual(len(actual), len(set(actual)))
        self.assertTrue(all(" — " in line and "\n" not in line for line in lines))

    def test_default_catalog_exposes_reusable_exact_invocation_grammar(self) -> None:
        catalog = CATALOG.read_text(encoding="utf-8")
        expected_grammar = (
            "sg-design identity [scope] | interface [scope] | system [scope] | playground [route-path] | "
            "audit <ui|tokens|components|a11y> [scope] | "
            "animation <audit|design|implement|tune> [scope] | redesign [scope] | migration [scope] | library <add|retry|approve|list|status>",
            "sg-experience <audit|flow|onboarding|recovery> <scope>",
            "sg-engineering <audit|architecture|deps|performance|migrate|github|sync|access|parity> [target]",
            "sg-help [default|mode|expert] [topic]",
            "shipglows [context|auto] <request>",
        )
        for grammar in expected_grammar:
            self.assertIn(f"`{grammar}", catalog)
        self.assertIn("angle brackets are required", catalog)
        self.assertIn("square brackets are optional", catalog)
        self.assertIn("Execution tags: `#local | #nolocal | #ci`", catalog)

    def test_default_catalog_covers_every_registered_public_mode(self) -> None:
        registry = json.loads(REGISTRY.read_text(encoding="utf-8"))
        entries = {
            self.catalog_id(line): line.split("`", 2)[1]
            for line in self.catalog_lines()
        }
        public_entries = [
            skill
            for domain in registry["public_catalog"]["domains"]
            for skill in domain["skills"]
        ] + [registry["public_catalog"]["router"]]
        for skill in public_entries:
            grammar = entries[skill["id"]]
            for mode in skill["modes"]:
                if mode == "default":
                    continue
                self.assertRegex(
                    grammar,
                    rf"(?<![A-Za-z0-9-]){re.escape(mode)}(?![A-Za-z0-9-])",
                    f"{skill['id']} is missing registered mode {mode}",
                )

    def test_expert_catalog_has_every_runtime_skill_and_is_not_the_default(self) -> None:
        registry = json.loads(REGISTRY.read_text(encoding="utf-8"))
        public = registry["public_catalog"]
        self.assertTrue(registry["internal_catalog"]["include_all_runtime_skills"])
        public_sources = {
            str(skill["public_skill"])
            for domain in public["domains"]
            for skill in domain["skills"]
        } | {str(public["router"]["public_skill"])}
        expected = {path.parent.name for path in SKILLS_ROOT.glob("*/SKILL.md")} - public_sources
        actual = {self.catalog_id(line) for line in self.catalog_lines(EXPERT_CATALOG)}
        self.assertEqual(expected, actual)
        self.assertNotEqual(
            {self.catalog_id(line) for line in self.catalog_lines()}, actual
        )

    def test_expert_catalog_covers_every_registered_strict_mode(self) -> None:
        registry = json.loads(REGISTRY.read_text(encoding="utf-8"))
        entries = {
            self.catalog_id(line): line.split(" \u2014 ", 1)[1]
            for line in self.catalog_lines(EXPERT_CATALOG)
        }
        for skill_id, rule in registry["rules"].items():
            if rule["kind"] != "modes" or skill_id not in entries:
                continue
            grammar = entries[skill_id]
            for mode in rule["modes"]:
                self.assertRegex(
                    grammar,
                    rf"(?<![A-Za-z0-9-]){re.escape(mode)}(?![A-Za-z0-9-])",
                    f"{skill_id} is missing registered mode {mode}",
                )

    def test_help_routes_exact_mode_requests_to_the_catalog(self) -> None:
        skill = HELP_SKILL.read_text(encoding="utf-8")
        self.assertIn("<mode|modes|mode --expert|help topic or route question>", skill)
        self.assertIn("If the exact request is `mode` or `modes`", skill)
        self.assertIn("one line per public métier plus `shipglows`", skill)
        self.assertIn("distinct execution-tag line", skill)
        self.assertIn("expert", skill)

    def test_explicit_help_and_animation_invocations_are_registered(self) -> None:
        registry = json.loads(REGISTRY.read_text(encoding="utf-8"))
        self.assertIn("302-sg-help", registry["rules"])
        self.assertIn("animation", registry["rules"]["006-sg-design"]["modes"])
        self.assertIn("interface", registry["rules"]["006-sg-design"]["modes"])
        self.assertIn("github", registry["rules"]["010-sg-technical"]["modes"])
        for invocation in ("302-sg-help mode", "302-sg-help modes", "006-sg-design animation audit home", "006-sg-design interface dashboard"):
            result = subprocess.run(
                [sys.executable, str(ROOT / "tools" / "skill_invocation_check.py"), invocation],
                cwd=ROOT,
                check=False,
                capture_output=True,
                text=True,
            )
            self.assertEqual(0, result.returncode, result.stdout + result.stderr)
            self.assertEqual("valid", json.loads(result.stdout)["status"])


if __name__ == "__main__":
    unittest.main()
