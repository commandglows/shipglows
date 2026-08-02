#!/usr/bin/env python3
"""Guard the validated Flutter Android Clerk decision record."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
AUTH_REFERENCE = ROOT / "skills/109-sg-auth-debug/references/flutter-clerk-convex.md"
SDK_POLICY = ROOT / "skills/109-sg-auth-debug/references/sdk-policy.md"
BLUEPRINT = ROOT / "skills/app-blueprints/flutter-crud-content/blueprint.md"
IDENTITY_MATRIX = ROOT / "skills/references/identity-provider-selection.md"


class FlutterAndroidClerkContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.auth_reference = AUTH_REFERENCE.read_text(encoding="utf-8")
        cls.sdk_policy = SDK_POLICY.read_text(encoding="utf-8")
        cls.blueprint = BLUEPRINT.read_text(encoding="utf-8")
        cls.identity_matrix = IDENTITY_MATRIX.read_text(encoding="utf-8")

    def test_identity_provider_choice_prevents_platform_splits(self) -> None:
        self.assertIn("one owner", self.identity_matrix)
        self.assertIn("Clerk on web + Firebase Auth on native", self.identity_matrix)
        self.assertIn("migration/identity-linking contract", self.identity_matrix)
        self.assertIn("identity-provider-selection.md", self.sdk_policy)

    def test_identity_provider_matrix_requires_freshness_and_beta_proof(self) -> None:
        self.assertIn("reviewed 2026-08-02", self.identity_matrix)
        self.assertIn("Official beta", self.identity_matrix)
        self.assertIn("provider_versions_checked", self.identity_matrix)
        self.assertIn("release_spike_required", self.identity_matrix)

    def test_identity_provider_questions_use_the_matrix_before_fresh_research(self) -> None:
        self.assertIn("Always load this matrix first", self.identity_matrix)
        self.assertIn("do not browse merely to repeat it", self.identity_matrix)
        self.assertIn("roadmap timing is dynamic", self.identity_matrix)

    def test_identity_provider_shortlist_requires_continuous_launch_availability(self) -> None:
        self.assertIn("Launch availability gate", self.identity_matrix)
        self.assertIn("pause, hibernate", self.identity_matrix)
        self.assertIn("continuous_auth_availability", self.identity_matrix)
        self.assertIn("Supabase Free", self.identity_matrix)
        self.assertIn("HTTP 540", self.identity_matrix)

    def test_identity_provider_matrix_compares_launch_costs_with_availability(self) -> None:
        self.assertIn("Commercial launch snapshot", self.identity_matrix)
        self.assertIn("50,000 monthly retained users", self.identity_matrix)
        self.assertIn("Most methods", self.identity_matrix)
        self.assertIn("$25/month per organization", self.identity_matrix)
        self.assertIn("auth_cost_assumption", self.identity_matrix)

    def test_identity_provider_matrix_prevents_mru_mau_price_confusion(self) -> None:
        self.assertIn("Scale economics", self.identity_matrix)
        self.assertIn("MRU total directly", self.identity_matrix)
        self.assertIn("50,000 MAU included", self.identity_matrix)
        self.assertIn("100,000 MAU included", self.identity_matrix)
        self.assertIn("scale_forecast", self.identity_matrix)

    def test_validated_browser_oauth_is_the_unambiguous_default(self) -> None:
        self.assertIn("Default contract", self.auth_reference)
        self.assertIn("for every new Flutter Android app", self.auth_reference)
        self.assertIn("auth_profile: browser-oauth (ShipGlows default)", self.auth_reference)
        self.assertIn("signInWithOAuth", self.auth_reference)
        for text in (self.auth_reference, self.blueprint):
            self.assertIn("clerk://<Clerk application id>.callback", text)
            self.assertIn("MainActivity", text)

    def test_credential_manager_is_a_deliberate_departure_not_an_option_to_choose(self) -> None:
        self.assertIn("Non-default alternative", self.auth_reference)
        self.assertIn("Credential Manager", self.auth_reference)
        self.assertIn("signInWithIdToken", self.auth_reference)
        self.assertIn("explicit product reason", self.auth_reference)
        self.assertIn("explicitly approved departure", self.sdk_policy)

    def test_clerk_and_google_fingerprints_remain_distinct(self) -> None:
        for text in (self.auth_reference, self.blueprint):
            self.assertIn("SHA-256", text)
            self.assertIn("SHA-1", text)
        self.assertIn("interchangeable", self.sdk_policy)

    def test_each_new_app_requires_a_configuration_record_and_release_smoke(self) -> None:
        self.assertIn("auth_profile: browser-oauth (ShipGlows default)", self.auth_reference)
        self.assertIn("release_apk_commit:", self.auth_reference)
        self.assertIn("Record once per app", self.blueprint)
        self.assertIn("Required device smoke", self.blueprint)


if __name__ == "__main__":
    unittest.main()
