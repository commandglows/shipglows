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

    def test_contract_separates_domain_and_instance_identity(self):
        text = (ROOT / "skills/references/clean-code-quality-contract.md").read_text()

        for marker in (
            "Domain Identifier Gate",
            "technical instance ID",
            "canonical domain code",
            "localized label",
            "ASCII uppercase",
            "nontranslated",
            "never renamed",
            "never recycled",
            "never used as machine identity",
        ):
            with self.subTest(marker=marker):
                self.assertIn(marker, text)

    def test_contract_defines_registry_lifecycle_and_alias_invariants(self):
        text = (ROOT / "skills/references/clean-code-quality-contract.md").read_text()

        for marker in (
            "domain-owned registry",
            "domain`, `namespace`, `owner`, and `version",
            "code`, lifecycle `status`, and `introduced_in",
            "deprecated_in",
            "replaced_by",
            "reserved tombstone",
            "input-only",
            "compatibility owner",
            "proof-based removal criterion",
            "missing targets",
            "self-replacements",
            "alias or replacement cycles",
        ):
            with self.subTest(marker=marker):
                self.assertIn(marker, text)

    def test_contract_defines_fail_closed_migration_and_exception_boundaries(self):
        text = (ROOT / "skills/references/clean-code-quality-contract.md").read_text()

        for marker in (
            "empty or malformed codes",
            "duplicate codes",
            "alias-to-code collision",
            "ambiguous aliases",
            "At a trust boundary",
            "actionable error",
            "forward-compatibility contract",
            "additive",
            "reversibly",
            "dual-read",
            "backfill",
            "authoritative server-side authorization",
            "Alias normalization must not widen privileges",
            "universal EAV registry",
            "external or vendor identifiers",
            "generated identifiers",
            "protocol-defined identifiers",
            "project-documented constraint",
            "isolate the external form and map it",
            "Domain Identifier Gate` verdict",
        ):
            with self.subTest(marker=marker):
                self.assertIn(marker, text)

    def test_contract_names_domain_identifier_pressure_scenarios(self):
        text = (ROOT / "skills/references/clean-code-quality-contract.md").read_text()

        for scenario in (
            "ID-LABEL-LOCALE",
            "ID-ALIAS-MIGRATION",
            "ID-DEPRECATE-REPLACE",
            "ID-TECHNICAL-INSTANCE",
            "ID-COLLISION",
            "ID-UNKNOWN",
            "ID-REGISTRY-OWNERSHIP",
            "ID-ADDITIVE-MIGRATION",
            "ID-AUTHORIZATION-BOUNDARY",
            "ID-EXTERNAL-MAPPING",
        ):
            with self.subTest(scenario=scenario):
                self.assertIn(scenario, text)


if __name__ == "__main__":
    unittest.main()
