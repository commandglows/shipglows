#!/usr/bin/env python3
"""Scenario-first checks for progressive 001-sg-build activation."""

from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
DIR = ROOT / "skills/001-sg-build"
SKILL = (DIR / "SKILL.md").read_text(encoding="utf-8")
NAMES = (
    "build-lifecycle-workflow.md",
    "build-greenfield-route.md",
    "build-readiness-route.md",
    "build-delivery-route.md",
)
REFS = {name: (DIR / "references" / name).read_text(encoding="utf-8") for name in NAMES}


class BuildCompactionContractTests(unittest.TestCase):
    def test_body_budget(self):
        self.assertLessEqual((len(SKILL) + 3) // 4, 2000)

    def test_early_reroute_precedes_route_packs(self):
        self.assertIn("BUILD-EARLY-REROUTE", REFS["build-lifecycle-workflow.md"])
        self.assertLess(SKILL.index("build-lifecycle-workflow.md"), SKILL.index("build-greenfield-route.md"))

    def test_scenarios_and_owner_boundaries(self):
        corpus = SKILL + "\n".join(REFS.values())
        for marker in ("BUILD-READY-SPEC", "BUILD-GREENFIELD", "BUILD-PROOF-OWNER", "BUILD-CONTINUE-THROUGH-SHIP"):
            self.assertIn(marker, corpus)
        for marker in ("103-sg-verify -> 104-sg-end -> 005-sg-ship", "108-sg-browser", "109-sg-auth-debug", "405-sg-prod", "107-sg-test", "all-dirty"):
            self.assertIn(marker, SKILL)

    def test_delegation_and_reporting_strings_remain_local(self):
        for marker in ("delegated sequential", "read-only parallel", "Execution Batches", "integration owner", "Agents: <count> · <mode>", "report=user", "report=agent"):
            self.assertIn(marker, SKILL)

    def test_explicit_preflight_and_no_agents_remain_activation_critical(self):
        self.assertIn("skill-invocation-preflight.md", SKILL)
        self.assertLess(SKILL.index("skill-invocation-preflight.md"), SKILL.index("build-lifecycle-workflow.md"))
        for marker in ("`no-agents` selects main-only/no-subagent", "never bypasses lifecycle, readiness, proof, or ship gates"):
            self.assertIn(marker, SKILL)

    def test_exact_conditional_loaders_remain_discoverable(self):
        for marker in (
            "profile-activation.md",
            "design-system-token-contract.md",
            "email-work-routing.md",
            "actionable-failure-contract.md",
        ):
            self.assertIn(marker, SKILL)
        greenfield = REFS["build-greenfield-route.md"]
        self.assertIn("preferred-stacks.md", greenfield)
        self.assertIn("app-blueprints.md", greenfield)
        readiness = REFS["build-readiness-route.md"]
        for marker in ("question-contract.md", "operator-partnership-contract.md", "704-sg-model/references/model-routing.md"):
            self.assertIn(marker, readiness)

    def test_refs_have_metadata_and_do_not_chain(self):
        for name, text in REFS.items():
            for marker in ("artifact: skill_reference", 'metadata_schema_version: "1.0"', "status: active", "source_skill: 001-sg-build"):
                self.assertIn(marker, text, name)
            self.assertIsNone(re.search(r"\$SHIPGLOWS_ROOT/skills/001-sg-build/references/", text), name)

    def test_blueprint_and_ship_authority_stay_local(self):
        for marker in ("ambiguous spec ownership", "blueprint conflict", "provider lock-in", "never commit or push directly"):
            self.assertIn(marker, SKILL)


if __name__ == "__main__":
    unittest.main()
