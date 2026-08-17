#!/usr/bin/env python3
"""Mechanical checks for ShipGlows delegation and parallelism doctrine."""

from pathlib import Path
import re
import unittest


ROOT = Path(__file__).resolve().parents[1]
SKILLS = ROOT / "skills"
CONTRACT_PATH = SKILLS / "references" / "master-delegation-semantics.md"
MASTER_SKILLS = (
    "000-shipglows",
    "001-sg-build",
    "002-sg-maintain",
    "003-sg-bug",
    "004-sg-deploy",
    "006-sg-design",
    "007-sg-content",
    "400-sg-audit",
    "900-shipglows-core",
)
CONSUMER_SKILLS = ("102-sg-start", "706-continue")


def section(text: str, heading: str) -> str:
    match = re.search(
        rf"^## {re.escape(heading)}\n(?P<body>.*?)(?=^## |\Z)",
        text,
        flags=re.MULTILINE | re.DOTALL,
    )
    if not match:
        raise AssertionError(f"Missing section: {heading}")
    return match.group("body")


class MasterDelegationContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.contract = CONTRACT_PATH.read_text(encoding="utf-8")

    def test_declared_masters_load_the_canonical_contract(self) -> None:
        for skill in MASTER_SKILLS:
            body = (SKILLS / skill / "SKILL.md").read_text(encoding="utf-8")
            self.assertIn("master-delegation-semantics.md", body, skill)

    def test_read_only_parallel_has_its_own_default_matrix(self) -> None:
        body = section(self.contract, "Read-Only Parallel Batch Matrix")
        for required in (
            "two or more independent",
            "materially improve elapsed time or coverage",
            "selected batch matrix",
            "read-only constraint",
            "requested evidence",
            "integration owner",
        ):
            self.assertIn(required, body)
        self.assertNotIn("`Execution Batches`", body)

    def test_parallel_writes_require_predeclared_execution_batches(self) -> None:
        body = section(self.contract, "Write Execution Batches")
        for required in (
            "ready spec",
            "before dispatch",
            "non-overlapping write ownership",
            "dependency order",
            "per-batch validation",
            "integration owner",
        ):
            self.assertIn(required, body)

    def test_absolute_parallelism_contradictions_are_absent(self) -> None:
        forbidden = (
            "Parallelism means simultaneous subagents. It is allowed only through ready `Execution Batches`.",
            "Without ready batches, parallelism is blocked.",
            "Parallel work is allowed only from ready `Execution Batches`",
            "Use sequential subagents by default; use parallel subagents only",
            "requested parallelism has no safe `Execution Batches`",
            "delegated sequential defaults and spec/batch-gated parallelism",
        )
        corpus = "\n".join(
            [
                self.contract,
                (SKILLS / "references" / "master-workflow-lifecycle.md").read_text(
                    encoding="utf-8"
                ),
                (SKILLS / "references" / "reporting-contract.md").read_text(
                    encoding="utf-8"
                ),
                (
                    SKILLS
                    / "001-sg-build"
                    / "references"
                    / "build-lifecycle-workflow.md"
                ).read_text(encoding="utf-8"),
            ]
            + [
                (SKILLS / skill / "SKILL.md").read_text(encoding="utf-8")
                for skill in MASTER_SKILLS
            ]
        )
        for phrase in forbidden:
            self.assertNotIn(phrase, corpus)

    def test_executable_work_has_a_structured_receipt(self) -> None:
        for required in (
            "`topology`",
            "`agents_dispatched`",
            "`model_status`",
            "`read_only_batch_matrix`",
            "`write_execution_batches`",
            "`integration_result`",
            "Agents: <count>",
            "only agents directly dispatched successfully",
        ):
            self.assertIn(required, self.contract)

        reporting = (SKILLS / "references" / "reporting-contract.md").read_text(
            encoding="utf-8"
        )
        self.assertIn("Agents: <count> · <mode>", reporting)

    def test_execution_consumers_load_contract_and_emit_receipt(self) -> None:
        for skill in CONSUMER_SKILLS:
            body = (SKILLS / skill / "SKILL.md").read_text(encoding="utf-8")
            self.assertIn("master-delegation-semantics.md", body, skill)
            self.assertIn("Agents: <count> · <mode>", body, skill)

    def test_execution_consumers_encode_low_overhead_topology(self) -> None:
        corpus = "\n".join(
            (
                (SKILLS / "102-sg-start" / "SKILL.md").read_text(encoding="utf-8"),
                (SKILLS / "102-sg-start" / "references" / "execution-workflow.md").read_text(encoding="utf-8"),
                (SKILLS / "706-continue" / "SKILL.md").read_text(encoding="utf-8"),
            )
        )
        for required in (
            "independent read-only",
            "net time/coverage gain",
            "lowest-overhead",
            "delegated sequential",
            "non-overlapping `Execution Batches`",
            "integration owner",
        ):
            self.assertIn(required, corpus)

    def test_main_only_is_valid_for_bounded_delivery(self) -> None:
        for required in (
            "main-only` for one cohesive bounded mission",
            "coordination must buy measurable speed, isolation, or evidence",
            "Missing subagent capability is not degradation",
            "one cohesive bounded mutation, focused check, closure, or ship",
        ):
            self.assertIn(required, self.contract)

    def test_execution_consumers_do_not_duplicate_legacy_model_catalogue(self) -> None:
        paths = (
            SKILLS / "102-sg-start" / "SKILL.md",
            SKILLS / "102-sg-start" / "references" / "execution-workflow.md",
            SKILLS / "706-continue" / "SKILL.md",
            SKILLS / "references" / "master-workflow-lifecycle.md",
            ROOT / "shipglows_data" / "technical" / "skill-runtime-and-lifecycle.md",
        )
        corpus = "\n".join(path.read_text(encoding="utf-8") for path in paths)
        for legacy in ("gpt-5.4", "gpt-5.5"):
            self.assertNotIn(legacy, corpus)
        for current in ("Sol", "Terra", "Luna", "`codex`"):
            self.assertIn(current, corpus)


if __name__ == "__main__":
    unittest.main()
