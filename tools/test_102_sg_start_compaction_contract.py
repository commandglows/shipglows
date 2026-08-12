#!/usr/bin/env python3
"""Scenario-first checks for progressive 102-sg-start activation."""

from pathlib import Path
import re
import unittest


ROOT = Path(__file__).resolve().parents[1]
SKILL_DIR = ROOT / "skills" / "102-sg-start"
SKILL = SKILL_DIR / "SKILL.md"
REFS = SKILL_DIR / "references"
LOCAL_REFS = (
    "execution-workflow.md",
    "execution-contract.md",
    "execution-topology.md",
    "implementation-and-proof.md",
    "execution-report.md",
)
MAX_BODY_ESTIMATED_TOKENS = 1600


class StartCompactionContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.skill = SKILL.read_text(encoding="utf-8")
        cls.refs = {name: (REFS / name).read_text(encoding="utf-8") for name in LOCAL_REFS}

    def test_activation_body_meets_budget(self) -> None:
        self.assertLessEqual((len(self.skill) + 3) // 4, MAX_BODY_ESTIMATED_TOKENS)

    def test_start_direct_and_spec_first_classify_before_mutation_detail(self) -> None:
        body = self.refs["execution-workflow.md"]
        for scenario in ("START-DIRECT", "START-SPEC-FIRST", "START-MALFORMED-REF"):
            self.assertIn(scenario, body)
        self.assertNotIn("# Implementation And Proof", body)
        self.assertLess(self.skill.index("execution-workflow.md"), self.skill.index("implementation-and-proof.md"))

    def test_contract_topology_mutation_and_report_are_directly_routed(self) -> None:
        for name in LOCAL_REFS:
            self.assertIn(f"references/{name}", self.skill)
        for name, text in self.refs.items():
            for other in LOCAL_REFS:
                self.assertNotIn(f"references/{other}", text, f"{name} chains to {other}")

    def test_auto_verify_scenarios_preserve_owner_boundary(self) -> None:
        corpus = self.skill + self.refs["implementation-and-proof.md"]
        for phrase in (
            "START-AUTO-VERIFY-ELIGIBLE",
            "START-AUTO-VERIFY-SKIPPED",
            "auto-verify: run",
            "auto-verify: skipped",
            "owner_skill",
            "scenario",
            "target_or_environment",
            "never commits, pushes, ships, deploys",
        ):
            self.assertIn(phrase, corpus)

    def test_result_semantics_and_stops_remain_local(self) -> None:
        for phrase in (
            "`implemented` means",
            "Use `partial` only",
            "103-sg-verify partial",
            "## Stop Conditions",
            "Passing technical checks never proves",
            "Agents: <count> · <mode>",
        ):
            self.assertIn(phrase, self.skill)

    def test_each_local_reference_has_metadata_and_no_nested_local_loader(self) -> None:
        required = (
            "artifact: skill_reference",
            'metadata_schema_version: "1.0"',
            "artifact_version:",
            "status: active",
            "source_skill: 102-sg-start",
        )
        for name, text in self.refs.items():
            for marker in required:
                self.assertIn(marker, text, f"{name}: {marker}")
            self.assertIsNone(re.search(r"\$SHIPGLOWS_ROOT/skills/102-sg-start/references/", text), name)


if __name__ == "__main__":
    unittest.main()
