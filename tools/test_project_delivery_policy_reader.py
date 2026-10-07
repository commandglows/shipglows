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

    def write_launch_protection(self, root: Path, capture: str = "configured") -> None:
        path = root / policy.LAUNCH_PROTECTION_RELATIVE
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(
            "---\nartifact: launch_protection\npublic_surface: holding-page\n"
            "public_url: https://example.com\nprotection_status: protected\n"
            f"email_capture_status: {capture}\nemail_provider: sendgrid\n---\n",
            encoding="utf-8",
        )

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
        self.assertEqual("Dev", result.product_status)
        self.assertTrue(result.launch_protection_review_required)
        self.assertEqual("missing", result.launch_protection_state)

    def test_dev_project_with_waitlist_exposes_compact_state(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.write_business(root, "development")
            self.write_launch_protection(root)
            result = policy.inspect_project(root)
        self.assertEqual("protected", result.launch_protection_state)
        self.assertEqual("configured", result.email_capture_state)
        self.assertEqual("sendgrid", result.email_provider)
        self.assertEqual("https://example.com", result.public_url)

    def test_invalid_waitlist_state_is_separate_from_product_posture(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.write_business(root, "development")
            self.write_launch_protection(root, "collecting")
            result = policy.inspect_project(root)
        self.assertEqual("resolved", result.state)
        self.assertEqual("main", result.integration_branch)
        self.assertFalse(result.question_required)
        self.assertEqual("invalid", result.email_capture_state)
        self.assertIn("email_capture_status", result.launch_protection_issue or "")

    def test_invalid_launch_protection_does_not_erase_resolved_product_posture(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.write_business(root, "development")
            self.write_launch_protection(root)
            launch_path = root / policy.LAUNCH_PROTECTION_RELATIVE
            launch_path.write_text(
                launch_path.read_text(encoding="utf-8").replace(
                    "protection_status: protected", "protection_status: maybe"
                ),
                encoding="utf-8",
            )
            result = policy.inspect_project(root)
        self.assertEqual("resolved", result.state)
        self.assertEqual("development", result.delivery_posture)
        self.assertEqual("main", result.production_branch)
        self.assertEqual("main", result.integration_branch)
        self.assertFalse(result.question_required)
        self.assertEqual("invalid", result.launch_protection_state)
        self.assertEqual("configured", result.email_capture_state)
        self.assertIn("protection_status", result.launch_protection_issue or "")

    def test_live_postures_derive_canonical_dev(self) -> None:
        for posture in ("published", "sensitive-production"):
            with self.subTest(posture=posture), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                self.write_business(root, posture)
                result = policy.inspect_project(root)
                self.assertEqual("main", result.production_branch)
                self.assertEqual("dev", result.integration_branch)
                self.assertEqual("dev", result.staging_branch)
                self.assertEqual("Live", result.product_status)
                self.assertFalse(result.launch_protection_review_required)

    def test_unknown_or_unsupported_value_requires_question(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.write_business(root, "unknown")
            result = policy.inspect_project(root)
        self.assertEqual("invalid", result.state)
        self.assertTrue(result.question_required)

    def test_posture_comments_are_supported_but_duplicate_keys_fail_closed(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            path = root / policy.CANONICAL_RELATIVE
            path.parent.mkdir(parents=True)
            path.write_text(
                "---\nartifact: business_context\n"
                "# delivery_posture: published\n"
                "delivery_posture: development # current decision\n---\n",
                encoding="utf-8",
            )
            commented = policy.inspect_project(root)
            path.write_text(
                "---\nartifact: business_context\n"
                "delivery_posture: development # first value\n"
                "delivery_posture: published # conflicting value\n---\n",
                encoding="utf-8",
            )
            duplicate = policy.inspect_project(root)
        self.assertEqual("resolved", commented.state)
        self.assertEqual("development", commented.delivery_posture)
        self.assertEqual("invalid", duplicate.state)
        self.assertTrue(duplicate.question_required)
        self.assertIn("duplicate canonical field", duplicate.reason)
        self.assertIsNone(duplicate.integration_branch)


if __name__ == "__main__":
    unittest.main()
