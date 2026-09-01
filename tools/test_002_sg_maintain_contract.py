#!/usr/bin/env python3
"""Regression checks for the compact 002-sg-maintain activation contract."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
SKILL = ROOT / "skills" / "002-sg-maintain" / "SKILL.md"
PLAYBOOK = ROOT / "skills" / "002-sg-maintain" / "references" / "maintenance-playbooks.md"
MAX_SKILL_LINES = 220


class MaintainContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.skill = SKILL.read_text(encoding="utf-8")
        cls.playbook = PLAYBOOK.read_text(encoding="utf-8")

    def test_activation_contract_retains_required_gates(self) -> None:
        for phrase in (
            "Canonical Paths",
            "Trace category: `obligatoire`",
            "Process role: `lifecycle`",
            "reporting-contract.md",
            "skill-invocation-preflight.md",
            "master-delegation-semantics.md",
            "master-workflow-lifecycle.md",
            "Mode Detection",
            "Stop Conditions",
            "003-sg-bug",
            "010-sg-technical deps|audit|migrate",
            "103-sg-verify",
            "005-sg-ship",
            "004-sg-deploy",
        ):
            self.assertIn(phrase, self.skill)

    def test_detailed_maintenance_doctrine_has_a_named_local_home(self) -> None:
        self.assertIn("maintenance-playbooks.md", self.skill)
        for heading in (
            "## Context Discovery",
            "## Quick Triage",
            "## Full Lane Order",
            "## Delegated Roles",
            "## Security Lane",
            "## Detailed Report",
        ):
            self.assertIn(heading, self.playbook)

    def test_activation_contract_stays_below_its_compaction_ceiling(self) -> None:
        self.assertLessEqual(len(self.skill.splitlines()), MAX_SKILL_LINES)

    def test_hygiene_mode_preserves_non_git_mutation_gate_and_autonomous_git(self) -> None:
        for phrase in (
            "`hygiene` -> comprehensive hygiene audit for the current project",
            "Git and temporary worktree residue",
            "dependencies and supply-chain posture",
            "security and trust-boundary gaps",
            "documentation and governance drift",
            "checks, audits, and quality debt",
            "grouped correction proposal",
            "standing-authority Git/GitHub convergence",
            "without a validation",
            "Never invoke native `git clean`",
            "No non-Git correction is authorized by the hygiene invocation",
        ):
            self.assertIn(phrase, self.skill + self.playbook)


if __name__ == "__main__":
    unittest.main()
