"""Offline read-only preflight checks; no provider or subjects."""
import copy
import json
from pathlib import Path
import tempfile
import unittest
from tools import conditional_skill_routing_real_comparison_preflight as pre


class ComparisonPreparation(unittest.TestCase):
    def setUp(self):
        self.document = json.loads(pre.DEFAULT.read_bytes())

    def test_current_template_valid_but_not_ready(self):
        result = pre.check(self.document)
        self.assertTrue(result["structural_valid"])
        self.assertFalse(result["prepared_for_authorized_baseline"])
        self.assertFalse(result["ready_to_launch_baseline"])
        self.assertFalse(result["launch_performed"])
        self.assertIn("provider.model", result["deferred_launch_parameters"])

    def test_nonfinite_spend_budgets_are_rejected(self):
        for value in (float("nan"), float("inf"), float("-inf")):
            with self.subTest(max_spend=repr(value)):
                document = copy.deepcopy(self.document)
                document["budget"]["max_spend"] = value
                result = pre.check(document)
                self.assertIn("budget.spend_currency", result["missing_baseline_launch_gates"])
                self.assertFalse(result["ready_to_launch_baseline"])

    def test_declared_ready_and_proxy_claim_cannot_open_gate(self):
        self.document["ready_to_launch"] = True
        self.document["consumer"]["closure_proof_pending"] = False
        self.assertFalse(pre.check(self.document)["ready_to_launch_baseline"])

    def test_threshold_types_order_and_ac5_fail_closed(self):
        cases = []
        value = copy.deepcopy(self.document)
        value["thresholds"]["candidate_post_selection_depth_max"] = True
        cases.append(value)
        value = copy.deepcopy(self.document)
        value["design"]["variant_order"]["2"] = ["baseline", "candidate"]
        cases.append(value)
        value = copy.deepcopy(self.document)
        value["ac5"]["delivered_and_retained_evidence_required"] = False
        cases.append(value)
        for value in cases:
            result = pre.check(value)
            self.assertFalse(result["structural_valid"])
            self.assertFalse(result["ready_to_launch_baseline"])

    def test_receipt_hash_binding_and_specific_checks(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "profile.txt").write_bytes(b"synthetic profile")
            profile = pre.sha256(b"synthetic profile")
            receipt = {"gate": "fixture_only_runtime", "campaign_id": "new", "status": "pass",
                "independent_review": True, "consumer_profile_sha256": profile,
                "checks": {name: True for name in ("exact_case_owned_broker_tool_inventory", "nonbroker_native_calls_refused_before_dispatch", "immutable_schema_bindings", "unknown_calls_refused_before_dispatch", "host_secret_boundary_verified", "evaluator_resource_boundary_verified")},
                "artifact_hashes": {"profile.txt": profile}}
            raw = json.dumps(receipt).encode()
            (root / "receipt.json").write_bytes(raw)
            row = {"path": "receipt.json", "sha256": pre.sha256(raw)}
            self.assertIsNone(pre.evidence_error(root, "fixture_only_runtime", row, "new", profile))
            (root / "profile.txt").write_bytes(b"changed")
            self.assertIn("drift", pre.evidence_error(root, "fixture_only_runtime", row, "new", profile))

    def test_heldout_content_never_read_as_receipt(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            row = {"path": "evaluator-cases.json", "sha256": "a" * 64}
            (root / row["path"]).write_bytes(b"DO NOT PARSE")
            result = pre.evidence_error(root, "fresh_heldout_seal", row, "new", "b" * 64)
            self.assertIn("never held-out payload", result)

    def test_traversal_and_unreviewed_placeholder_receipts_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            result = pre.evidence_error(root, "source_closure", {"path": "../outside.json", "sha256": "a" * 64}, "new")
            self.assertIn("escapes", result)
            self.assertIsNotNone(pre.evidence_error(root, "source_closure", {"status": "pass"}, "new"))


if __name__ == "__main__":
    unittest.main()
