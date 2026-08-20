#!/usr/bin/env python3
"""Contract checks for progressive public/expert skill discovery."""

from __future__ import annotations

import json
from pathlib import Path
import re
import unittest


ROOT = Path(__file__).resolve().parents[1]
SKILLS = ROOT / "skills"
REGISTRY = SKILLS / "references" / "skill-invocation-registry.json"


def read_invocation_policy(path: Path) -> bool:
    """Read the one boolean policy field without accepting YAML-like ambiguity."""

    lines = path.read_text(encoding="utf-8").splitlines()
    policy_index = next(
        (index for index, line in enumerate(lines) if line == "policy:"),
        None,
    )
    if policy_index is None:
        raise AssertionError(f"missing top-level policy block: {path}")

    value: str | None = None
    for line in lines[policy_index + 1 :]:
        if line and not line.startswith((" ", "\t")):
            break
        match = re.fullmatch(r"  allow_implicit_invocation:\s*(true|false)", line)
        if match:
            if value is not None:
                raise AssertionError(f"duplicate invocation policy: {path}")
            value = match.group(1)
    if value is None:
        raise AssertionError(f"missing boolean invocation policy: {path}")
    return value == "true"


class SkillInvocationPolicyContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.registry = json.loads(REGISTRY.read_text(encoding="utf-8"))
        catalog = cls.registry["public_catalog"]
        cls.public_entries = [
            entry
            for domain in catalog["domains"]
            for entry in domain["skills"]
        ] + [catalog["router"]]
        cls.public = {str(entry["public_skill"]) for entry in cls.public_entries}
        cls.installed = {
            path.parent.name for path in SKILLS.glob("*/SKILL.md") if path.is_file()
        }
        cls.expert = cls.installed - cls.public

    def test_registry_drives_exact_public_and_expert_partitions(self) -> None:
        self.assertEqual(14, len(self.public))
        self.assertEqual(66, len(self.installed))
        self.assertEqual(52, len(self.expert))
        self.assertFalse(self.public & self.expert)
        self.assertEqual(self.installed, self.public | self.expert)
        self.assertTrue(self.registry["internal_catalog"]["include_all_runtime_skills"])

    def test_only_public_wrappers_allow_implicit_invocation(self) -> None:
        implicit: set[str] = set()
        for skill in self.installed:
            policy = SKILLS / skill / "agents" / "openai.yaml"
            self.assertTrue(policy.is_file(), skill)
            if read_invocation_policy(policy):
                implicit.add(skill)

        self.assertEqual(self.public, implicit)
        self.assertEqual(14, len(implicit))
        self.assertTrue(all(not read_invocation_policy(SKILLS / skill / "agents" / "openai.yaml") for skill in self.expert))

    def test_explicit_only_experts_remain_installed_and_named_for_dollar_invocation(self) -> None:
        for skill in self.expert:
            source = SKILLS / skill / "SKILL.md"
            self.assertTrue(source.is_file(), skill)
            frontmatter = source.read_text(encoding="utf-8").split("---", 2)[1]
            self.assertRegex(frontmatter, rf"(?m)^name:\s*{re.escape(skill)}\s*$", skill)

    def test_public_loaders_use_registry_engines_from_the_canonical_root(self) -> None:
        for entry in self.public_entries:
            public_skill = str(entry["public_skill"])
            runtime_skill = str(entry["runtime_skill"])
            body = (SKILLS / public_skill / "SKILL.md").read_text(encoding="utf-8")
            canonical = f"$SHIPGLOWS_ROOT/skills/{runtime_skill}/SKILL.md"
            self.assertIn(canonical, body, public_skill)
            self.assertIn("root", body.lower(), public_skill)
            self.assertIn("file", body.lower(), public_skill)
            self.assertIn("stop with a visible error", body, public_skill)
            self.assertIn("never fall back to a sibling runtime path", body, public_skill)
            self.assertNotRegex(body, r"\.\./(?:\d{3}-[^/]+|emailing)/SKILL\.md", public_skill)


if __name__ == "__main__":
    unittest.main()
