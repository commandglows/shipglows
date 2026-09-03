#!/usr/bin/env python3
"""Activation-profile contracts for Wave 16 monolithic workflow compaction."""

import json
from pathlib import Path
import unittest

from tools.skill_activation_budget import audit_profiles


ROOT = Path(__file__).resolve().parents[1]
REGISTRY = ROOT / "skills" / "references" / "skill-invocation-registry.json"


class Wave16ActivationProfileTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.registry = json.loads(REGISTRY.read_text(encoding="utf-8"))
        cls.profiles = cls.registry["activation_profiles"]["skills"]

    def test_five_owners_have_bounded_profiles(self) -> None:
        expected = {
            "109-sg-auth-debug": 4,
            "200-sg-redact": 5,
            "201-sg-enrich": 5,
            "400-sg-audit": 3,
            "405-sg-prod": 5,
        }
        for skill, gate_count in expected.items():
            self.assertIn(skill, self.profiles)
            self.assertEqual(gate_count, len(self.profiles[skill]["gates"]), skill)

    def test_local_gates_are_direct_and_never_select_sibling_packs_together(self) -> None:
        for skill in ("109-sg-auth-debug", "200-sg-redact", "201-sg-enrich", "400-sg-audit", "405-sg-prod"):
            for gate, references in self.profiles[skill]["gates"].items():
                self.assertEqual(1, len(references), (skill, gate))
                self.assertTrue(references[0].startswith(f"skills/{skill}/references/"), (skill, gate))

    def test_profiles_are_valid_and_selected_baselines_stay_below_five_thousand(self) -> None:
        payload = audit_profiles(self.registry)
        self.assertEqual("valid", payload["status"], payload["errors"])
        for skill in ("109-sg-auth-debug", "200-sg-redact", "201-sg-enrich", "400-sg-audit", "405-sg-prod"):
            result = payload["skills"][skill]
            self.assertEqual([], result["missing"], skill)
            self.assertLess(result["baseline_tokens"], 5000, (skill, result["baseline_tokens"]))


if __name__ == "__main__":
    unittest.main()
