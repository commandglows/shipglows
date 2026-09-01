#!/usr/bin/env python3
"""Contract tests for canonical delivery-posture resolution."""

from pathlib import Path
import tempfile
import unittest

from tools import project_delivery_policy as policy


class ProjectDeliveryPolicyReaderTests(unittest.TestCase):
    def write_business(self, root: Path, posture: str | None) -> None:
        path = root / policy.CANONICAL_RELATIVE
        path.parent.mkdir(parents=True)
        field = f"delivery_posture: {posture}\n" if posture is not None else ""
        path.write_text(f"---\nartifact: business_context\n{field}---\n", encoding="utf-8")

    def test_missing_business_context_requires_product_question(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            result = policy.inspect_project(Path(directory))
        self.assertEqual("missing", result.state)
        self.assertTrue(result.question_required)
        self.assertIsNone(result.integration_branch)

    def test_missing_field_does_not_infer_from_legacy_agent_file(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.write_business(root, None)
            (root / "CLAUDE.md").write_text("delivery_posture: published\n", encoding="utf-8")
            result = policy.inspect_project(root)
        self.assertEqual("missing", result.state)
        self.assertTrue(result.question_required)

    def test_development_derives_main_without_staging(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.write_business(root, "development")
            result = policy.inspect_project(root)
        self.assertEqual("resolved", result.state)
        self.assertEqual("main", result.production_branch)
        self.assertEqual("main", result.integration_branch)
        self.assertEqual("not-required", result.staging_branch)

    def test_live_postures_derive_canonical_dev(self) -> None:
        for posture in ("published", "sensitive-production"):
            with self.subTest(posture=posture), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                self.write_business(root, posture)
                result = policy.inspect_project(root)
                self.assertEqual("main", result.production_branch)
                self.assertEqual("dev", result.integration_branch)
                self.assertEqual("dev", result.staging_branch)

    def test_unknown_or_unsupported_value_requires_question(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.write_business(root, "unknown")
            result = policy.inspect_project(root)
        self.assertEqual("invalid", result.state)
        self.assertTrue(result.question_required)


if __name__ == "__main__":
    unittest.main()
