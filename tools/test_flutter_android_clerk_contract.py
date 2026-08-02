#!/usr/bin/env python3
"""Guard the validated Flutter Android Clerk decision record."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
AUTH_REFERENCE = ROOT / "skills/109-sg-auth-debug/references/flutter-clerk-convex.md"
SDK_POLICY = ROOT / "skills/109-sg-auth-debug/references/sdk-policy.md"
BLUEPRINT = ROOT / "skills/app-blueprints/flutter-crud-content/blueprint.md"


class FlutterAndroidClerkContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.auth_reference = AUTH_REFERENCE.read_text(encoding="utf-8")
        cls.sdk_policy = SDK_POLICY.read_text(encoding="utf-8")
        cls.blueprint = BLUEPRINT.read_text(encoding="utf-8")

    def test_validated_browser_oauth_profile_stays_explicit(self) -> None:
        self.assertIn("Profile A", self.auth_reference)
        self.assertIn("signInWithOAuth", self.auth_reference)
        for text in (self.auth_reference, self.blueprint):
            self.assertIn("clerk://<Clerk application id>.callback", text)
            self.assertIn("MainActivity", text)

    def test_credential_manager_is_not_mixed_with_browser_oauth(self) -> None:
        self.assertIn("Profile B", self.auth_reference)
        self.assertIn("Credential Manager", self.auth_reference)
        self.assertIn("signInWithIdToken", self.auth_reference)
        self.assertIn("Never mix Profile A callback setup and Profile B", self.auth_reference)
        self.assertIn("choose one documented profile", self.sdk_policy)

    def test_clerk_and_google_fingerprints_remain_distinct(self) -> None:
        for text in (self.auth_reference, self.blueprint):
            self.assertIn("SHA-256", text)
            self.assertIn("SHA-1", text)
        self.assertIn("interchangeable", self.sdk_policy)

    def test_each_new_app_requires_a_configuration_record_and_release_smoke(self) -> None:
        self.assertIn("auth_profile:", self.auth_reference)
        self.assertIn("release_apk_commit:", self.auth_reference)
        self.assertIn("Record once per app", self.blueprint)
        self.assertIn("Required device smoke", self.blueprint)


if __name__ == "__main__":
    unittest.main()
