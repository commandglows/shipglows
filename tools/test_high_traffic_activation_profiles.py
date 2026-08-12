#!/usr/bin/env python3
"""Contracts for Wave 14 high-traffic activation profiles."""

import json
from pathlib import Path
import unittest

from tools.skill_activation_budget import audit_profiles
from tools.skill_invocation_check import check


ROOT = Path(__file__).resolve().parents[1]
REGISTRY_PATH = ROOT / "skills" / "references" / "skill-invocation-registry.json"


class HighTrafficActivationProfileTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.registry = json.loads(REGISTRY_PATH.read_text(encoding="utf-8"))
        cls.profiles = cls.registry["activation_profiles"]["skills"]

    def test_profiles_preserve_exact_mandatory_baselines(self) -> None:
        expected = {
            "010-sg-technical": [
                "skills/references/canonical-paths.md",
                "skills/references/intent-to-outcome-autonomy.md",
                "skills/references/decision-quality-contract.md",
                "skills/010-sg-technical/references/technical-router.md",
            ],
            "103-sg-verify": [
                "skills/references/canonical-paths.md",
                "skills/references/shipglows-owned-preflight.md",
                "skills/103-sg-verify/references/verification-baseline.md",
                "skills/references/decision-quality-contract.md",
            ],
            "300-sg-docs": [
                "skills/references/canonical-paths.md",
                "skills/references/intent-to-outcome-autonomy.md",
            ],
        }
        for skill, baseline in expected.items():
            self.assertEqual(baseline, self.profiles[skill]["baseline"], skill)

    def test_technical_modes_remain_independent_direct_gates(self) -> None:
        gates = self.profiles["010-sg-technical"]["gates"]
        expected = {
            "deps": "dependency-audit-playbook.md",
            "performance": "performance-audit-playbook.md",
            "migrate": "migration-playbook.md",
            "github": "github-hygiene-playbook.md",
        }
        for gate, filename in expected.items():
            self.assertEqual(1, len(gates[gate]))
            self.assertTrue(gates[gate][0].endswith(filename))
        union = "\n".join(path for refs in gates.values() for path in refs)
        for routed_engine in ("600-sg-local-cloud-sync", "601-sg-product-entitlements", "602-sg-platform-parity"):
            self.assertNotIn(routed_engine, union)

    def test_docs_families_are_direct_and_compatibility_index_is_not_loaded(self) -> None:
        gates = self.profiles["300-sg-docs"]["gates"]
        self.assertEqual(["skills/300-sg-docs/references/simple-bootstrap-playbooks.md"], gates["simple-family"])
        self.assertEqual(2, len(gates["governance-family"]))
        self.assertEqual(6, len(gates["private-project-family"]))
        corpus = "\n".join(path for refs in gates.values() for path in refs)
        self.assertNotIn("mode-playbooks.md", corpus)

    def test_verify_standard_is_baseline_and_conditional_packs_stay_separate(self) -> None:
        gates = self.profiles["103-sg-verify"]["gates"]
        self.assertNotIn("standard", gates)
        self.assertEqual(["skills/103-sg-verify/references/verification-excellence.md"], gates["excellence"])
        self.assertEqual(["skills/103-sg-verify/references/verification-security-ui-runtime.md"], gates["security-ui-runtime"])
        self.assertEqual(["skills/103-sg-verify/references/verification-coherence.md"], gates["coherence"])
        self.assertNotIn("verification-gates.md", "\n".join(path for refs in gates.values() for path in refs))

    def test_public_and_direct_invocations_select_new_profiles(self) -> None:
        cases = {
            "sg-engineering deps": "010-sg-technical",
            "103-sg-verify excellence": "103-sg-verify",
            "sg-docs technical": "300-sg-docs",
            "300-sg-docs technical": "300-sg-docs",
            "sg-docs migrate": "300-sg-docs",
            "300-sg-docs duplicata": "300-sg-docs",
        }
        for invocation, profile in cases.items():
            payload = check(invocation)
            self.assertEqual("valid", payload["status"], (invocation, payload))
            self.assertEqual(profile, payload["activation_profile"], invocation)

    def test_profile_measurements_expose_large_baselines_without_missing_files(self) -> None:
        payload = audit_profiles(self.registry)
        self.assertEqual("valid", payload["status"], payload["errors"])
        for skill in ("010-sg-technical", "103-sg-verify", "300-sg-docs"):
            result = payload["skills"][skill]
            self.assertEqual([], result["missing"], skill)
            self.assertGreater(result["baseline_tokens"], 5000, skill)


if __name__ == "__main__":
    unittest.main()
