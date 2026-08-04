#!/usr/bin/env python3
"""Focused contract checks for the one-line ShipGlows mode catalog."""

import json
from pathlib import Path
import subprocess
import unittest


ROOT = Path(__file__).resolve().parents[1]
SKILLS_ROOT = ROOT / "skills"
HELP_SKILL = SKILLS_ROOT / "302-sg-help" / "SKILL.md"
CATALOG = SKILLS_ROOT / "302-sg-help" / "references" / "help-modes-catalog.md"
REGISTRY = SKILLS_ROOT / "references" / "skill-invocation-registry.json"


class HelpModesContractTests(unittest.TestCase):
    def catalog_lines(self) -> list[str]:
        return [line for line in CATALOG.read_text(encoding="utf-8").splitlines() if line.startswith("`")]

    def test_catalog_has_exactly_one_line_for_every_repo_skill(self) -> None:
        expected = sorted(path.parent.name for path in SKILLS_ROOT.glob("*/SKILL.md"))
        lines = self.catalog_lines()
        actual = [line.split("`", 2)[1] for line in lines]
        self.assertEqual(expected, actual)
        self.assertEqual(len(actual), len(set(actual)))
        self.assertTrue(all(" — " in line and "\n" not in line for line in lines))

    def test_help_routes_exact_mode_requests_to_the_catalog(self) -> None:
        skill = HELP_SKILL.read_text(encoding="utf-8")
        self.assertIn("<mode|modes|help topic or route question>", skill)
        self.assertIn("If the exact request is `mode` or `modes`", skill)
        self.assertIn("one line per skill, name and modes only", skill)

    def test_explicit_help_and_animation_invocations_are_registered(self) -> None:
        registry = json.loads(REGISTRY.read_text(encoding="utf-8"))
        self.assertIn("302-sg-help", registry["rules"])
        self.assertIn("animation", registry["rules"]["006-sg-design"]["modes"])
        self.assertIn("github", registry["rules"]["010-sg-technical"]["modes"])
        for invocation in ("302-sg-help mode", "302-sg-help modes", "006-sg-design animation audit home"):
            result = subprocess.run(
                ["python3", str(ROOT / "tools" / "skill_invocation_check.py"), invocation],
                cwd=ROOT,
                check=False,
                capture_output=True,
                text=True,
            )
            self.assertEqual(0, result.returncode, result.stdout + result.stderr)
            self.assertEqual("valid", json.loads(result.stdout)["status"])


if __name__ == "__main__":
    unittest.main()
