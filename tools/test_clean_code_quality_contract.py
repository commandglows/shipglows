import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class CleanCodeQualityContractTest(unittest.TestCase):
    def test_contract_has_observable_and_non_dogmatic_gates(self):
        text = (ROOT / "skills/references/clean-code-quality-contract.md").read_text()
        for marker in (
            "Intent-revealing names",
            "Cohesive responsibility",
            "Controlled complexity",
            "Evidence-based abstraction",
            "Explicit errors and side effects",
            "Useful comments and documentation",
            "No unjustified dead code",
            "Behavior-focused tests",
            "Clean Code Gate",
        ):
            self.assertIn(marker, text)
        self.assertIn("Prefer a small amount of honest duplication", text)
        self.assertIn("Do not enforce arbitrary function-length", text)
        self.assertIn("Correctness, security, privacy", text)

    def test_execution_fix_audit_and_verification_load_contract(self):
        consumers = (
            "skills/102-sg-start/SKILL.md",
            "skills/103-sg-verify/SKILL.md",
            "skills/106-sg-fix/SKILL.md",
            "skills/010-sg-technical/SKILL.md",
            "skills/010-sg-technical/references/technical-audit-protocol.md",
        )
        for relative_path in consumers:
            with self.subTest(relative_path=relative_path):
                text = (ROOT / relative_path).read_text()
                self.assertIn("clean-code-quality-contract.md", text)

    def test_verification_exposes_clean_code_gate(self):
        text = (ROOT / "skills/103-sg-verify/SKILL.md").read_text()
        self.assertIn("`Clean Code Gate` pass/partial/fail/not applicable", text)


if __name__ == "__main__":
    unittest.main()
