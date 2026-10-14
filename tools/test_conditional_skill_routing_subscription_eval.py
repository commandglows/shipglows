"""Synthetic observation intake checks. No auth, provider or held-out access."""
import base64
import copy
from pathlib import Path
import tempfile
import unittest

from tools import conditional_skill_routing_subscription_eval as evaluator
from tools.conditional_skill_routing_cli_case_launch import validate_evaluator_receipt


class SubscriptionIntakeTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix="csr-public-intake-test-")
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name) / "synthetic-intake"
        self.root.mkdir()
        self.path = self.root / "observation.json"
        content = b"PUBLIC SYNTHETIC OBSERVATION"
        self.package = {
            "schema_version": 1, "variant": "baseline", "case_id": "H1",
            "campaign_id": "public-synthetic-campaign", "run_label": "synthetic-H1",
            "consumer_profile_sha256": "a" * 64,
            "workspace_files": {"run/synthetic.bin": {
                "body_b64": base64.b64encode(content).decode(),
                "bytes": len(content), "sha256": evaluator.sha(content)}},
            "parent_provider_exchanges": [{
                "request": base64.b64encode(b"SYNTHETIC REQUEST").decode(),
                "response": base64.b64encode(b"SYNTHETIC RESPONSE").decode(),
                "response_status": 200, "response_complete": True}],
        }
        self.bind_inventory(self.package)

    @staticmethod
    def bind_inventory(package):
        inventory = {name: {key: row[key] for key in ("bytes", "sha256")}
                     for name, row in package["workspace_files"].items()}
        exchanges = package["parent_provider_exchanges"]
        if exchanges:
            encoded = evaluator.packed(exchanges)
            inventory["parent-only-provider-exchanges"] = {
                "bytes": len(encoded), "sha256": evaluator.sha(encoded)}
        package["observation_manifest_sha256"] = evaluator.sha(evaluator.packed(inventory))

    def intake(self, package=None, path=None):
        chosen = self.path if path is None else path
        chosen.write_bytes(evaluator.packed(self.package if package is None else package))
        return evaluator.intake(chosen, trusted_root=self.root)

    def test_valid_capture_is_hash_bound_inconclusive_not_semantic_pass(self):
        result = self.intake()
        self.assertTrue(result["inventory_verified"])
        self.assertTrue(result["semantic_review_pending"])
        self.assertEqual(result["model_calls"], 0)
        self.assertFalse(result["launch_performed"])
        self.assertEqual(result["package_sha256"], evaluator.sha(self.path.read_bytes()))
        receipt = validate_evaluator_receipt(result["receipt"], case_id="H1",
            campaign_id=self.package["campaign_id"],
            observation_manifest_sha256=self.package["observation_manifest_sha256"])
        self.assertEqual(receipt["status"], "INCONCLUSIVE")

    def test_corruption_and_manifest_mismatch_are_refused(self):
        for change in (lambda p: p["workspace_files"]["run/synthetic.bin"].update(body_b64="Q09SUlVQVA=="),
                       lambda p: p["workspace_files"]["run/synthetic.bin"].update(bytes=0),
                       lambda p: p.update(observation_manifest_sha256="0" * 64),
                       lambda p: p["parent_provider_exchanges"][0].update(response="Q09SUlVQVA==")):
            package = copy.deepcopy(self.package)
            change(package)
            with self.subTest(package=package), self.assertRaises(ValueError):
                self.intake(package)

    def test_observation_outside_trusted_root_is_refused(self):
        outside = Path(self.directory.name) / "outside.json"
        with self.assertRaises(ValueError):
            self.intake(path=outside)

    def test_workspace_escape_and_reserved_name_are_refused_even_with_matching_hash(self):
        for name in ("../outside", "/absolute", "run/../../outside", "run\\outside",
                     "C:outside", "parent-only-provider-exchanges"):
            package = copy.deepcopy(self.package)
            item = package["workspace_files"].pop("run/synthetic.bin")
            package["workspace_files"][name] = item
            self.bind_inventory(package)
            with self.subTest(name=name), self.assertRaises(ValueError):
                self.intake(package)

    def test_bounded_label_produces_bounded_receipt_identity(self):
        package = copy.deepcopy(self.package)
        package["run_label"] = "x" * 48
        receipt = self.intake(package)["receipt"]
        self.assertLessEqual(len(receipt["review_id"]), 128)
        validate_evaluator_receipt(receipt, case_id="H1", campaign_id=package["campaign_id"],
            observation_manifest_sha256=package["observation_manifest_sha256"])

    def test_oversized_or_unsafe_labels_are_refused(self):
        for label in ("x" * 49, "", "../outside", "name;command", "name space"):
            package = copy.deepcopy(self.package)
            package["run_label"] = label
            with self.subTest(label=label), self.assertRaises(ValueError):
                self.intake(package)

    def test_nonbaseline_or_heldout_case_is_refused(self):
        for changes in ({"case_id": "H3"}, {"variant": "candidate"},
                        {"consumer_profile_sha256": "not-a-digest"}):
            package = {**self.package, **changes}
            with self.subTest(changes=changes), self.assertRaises(ValueError):
                self.intake(package)


if __name__ == "__main__":
    unittest.main()
