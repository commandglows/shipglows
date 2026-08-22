#!/usr/bin/env python3
"""Scenario-first checks for wave-12 shared activation compaction."""

import json
from pathlib import Path
import unittest

from tools.skill_activation_budget import audit_profiles


ROOT = Path(__file__).resolve().parents[1]
REFS = ROOT / "skills" / "references"
REGISTRY = REFS / "skill-invocation-registry.json"


class SharedActivationCoresWave12ContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.lifecycle = (REFS / "master-workflow-lifecycle-core.md").read_text(encoding="utf-8")
        cls.delegation = (REFS / "master-delegation-core.md").read_text(encoding="utf-8")
        cls.entitlement = (REFS / "product-entitlements-playbook.md").read_text(encoding="utf-8")
        cls.registry = json.loads(REGISTRY.read_text(encoding="utf-8"))
        cls.profiles = audit_profiles(cls.registry)["skills"]

    def test_lifecycle_core_keeps_route_and_escalation_gates(self) -> None:
        for marker in (
            "one current work item", "readiness", "owner execution",
            "checkpoint-based", "verification fails", "master-workflow-lifecycle.md",
        ):
            self.assertIn(marker, self.lifecycle)

    def test_delegation_core_keeps_safe_topology_and_receipt(self) -> None:
        for marker in (
            "two or more independent read-only", "parallel by default",
            "delegated sequential", "non-overlapping `Execution Batches`",
            "integration owner", "agents_dispatched", "master-delegation-semantics.md",
        ):
            self.assertIn(marker, self.delegation)

    def test_release_normal_multistage_gate_is_materially_smaller(self) -> None:
        release = self.profiles["004-sg-deploy"]
        core = release["gates"]["multi-stage-lifecycle"]["incremental_tokens"]
        detailed = (
            release["gates"]["detailed-lifecycle"]["incremental_tokens"]
            + release["gates"]["detailed-delegation"]["incremental_tokens"]
        )
        self.assertLess(core, 2500)
        self.assertGreater(detailed, core * 2)

    def test_entitlement_primary_doctrine_routes_three_direct_leaves(self) -> None:
        leaves = (
            "product-entitlement-ledger-and-authorization.md",
            "product-entitlement-ingestion.md",
            "product-entitlement-support-and-proof.md",
        )
        for leaf in leaves:
            self.assertIn(leaf, self.entitlement)
            leaf_text = (REFS / leaf).read_text(encoding="utf-8")
            for sibling in leaves:
                if sibling != leaf:
                    self.assertNotIn(sibling, leaf_text)

    def test_progressive_resources_do_not_restore_eager_dependencies(self) -> None:
        release_pack = (ROOT / "skills" / "004-sg-deploy" / "references" / "release-confidence-workflow.md").read_text(encoding="utf-8")
        entitlement_header = self.entitlement.split("---", 2)[1]
        self.assertIn("master-workflow-lifecycle-core.md", release_pack)
        self.assertNotIn('artifact: "skills/references/master-workflow-lifecycle.md"', release_pack)
        self.assertIn("depends_on: []", entitlement_header)

    def test_entitlement_security_and_scenarios_remain_followable(self) -> None:
        for marker in (
            "Authentication proves identity", "Fail closed", "pending_review",
            "Stripe Managed Payments", "SPE-001", "SPE-010",
        ):
            corpus = self.entitlement + (REFS / "product-entitlement-support-and-proof.md").read_text(encoding="utf-8")
            self.assertIn(marker, corpus)

    def test_trial_transition_experience_preserves_value_truth_and_recovery(self) -> None:
        support = (REFS / "product-entitlement-support-and-proof.md").read_text(encoding="utf-8")
        for marker in (
            "Value-Led Trial Transition Contract",
            "Increase information and decision clarity",
            "Transition Timeline",
            "Value Showcase",
            "retained user data are not deleted",
            "server-authorized restart",
            "founder note",
            "must not imply that the user owes a purchase",
            "TEX-001",
            "TEX-010",
        ):
            self.assertIn(marker, support)

    def test_entitlement_profile_exposes_each_branch(self) -> None:
        gates = self.profiles["601-sg-product-entitlements"]["gates"]
        for gate in ("entitlement-contract", "ledger-authorization", "provider-ingestion", "support-proof"):
            self.assertIn(gate, gates)
            self.assertGreater(gates[gate]["incremental_tokens"], 0)
        self.assertLess(gates["entitlement-contract"]["incremental_tokens"], 2500)


if __name__ == "__main__":
    unittest.main()
