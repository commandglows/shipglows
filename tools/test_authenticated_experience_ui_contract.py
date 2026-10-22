#!/usr/bin/env python3
"""Scenario-first regression checks for authenticated experience UI doctrine."""

from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "skills/references/authenticated-experience-ui-contract.md"
SPEC = ROOT / "shipglows_data/workflow/specs/authenticated-experience-ui-contract.md"
DESIGN = ROOT / "skills/006-sg-design/SKILL.md"
AUTH = ROOT / "skills/109-sg-auth-debug/SKILL.md"


def compact(path: Path) -> str:
    return " ".join(path.read_text(encoding="utf-8").split())


class AuthenticatedExperienceUiContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.contract = compact(CONTRACT)

    def test_conditional_owner_loaders_preserve_boundaries(self) -> None:
        reference = "$SHIPGLOWS_ROOT/skills/references/authenticated-experience-ui-contract.md"
        self.assertIn(reference, compact(DESIGN))
        self.assertIn("when authentication state changes global navigation", compact(DESIGN))
        self.assertIn(reference, compact(AUTH))
        self.assertIn("when the reported defect concerns sign-in, sign-out, account UI, private navigation", compact(AUTH))
        self.assertIn("does not authenticate users or authorize data", self.contract)
        self.assertIn("UI is never an access-control boundary", self.contract)

    def test_global_state_pressure_scenario(self) -> None:
        for value in (
            "Loading or unresolved",
            "Signed out",
            "Signed in",
            "Expired or revoked",
            "Unauthorized",
            "Provider or callback error",
            "Exactly one coherent global account affordance",
            "Neither state may leave the action region empty after loading",
        ):
            self.assertIn(value, self.contract)

    def test_account_menu_and_private_orientation(self) -> None:
        for value in (
            "Product navigation",
            "Product profile/settings",
            "Account/security management",
            "Sign out",
            "aria-current=\"page\"",
            "same private navigation model",
            "Route visibility is not authorization",
        ):
            self.assertIn(value, self.contract)

    def test_accessibility_responsive_and_duplicate_widgets(self) -> None:
        for value in (
            "focus restoration to the account trigger",
            "at least 44 CSS pixels",
            "200% zoom",
            "forced colors",
            "reduced motion",
            "long localized labels",
            "responsive duplicates register conflicting account menus",
            "Prefer one behavioral widget",
        ):
            self.assertIn(value, self.contract)

    def test_recovery_redirect_and_hydration_safety(self) -> None:
        for value in (
            "Validate return targets",
            "Reject external, malformed, circular, stale, or unauthorized targets",
            "redirect loop",
            "private-content flashes",
            "during hydration",
            "session expires",
        ):
            self.assertIn(value, self.contract)

    def test_proof_does_not_end_human_session(self) -> None:
        for value in (
            "must not click a real human user's sign-out action",
            "explicit action-time authority",
            "isolated signed-out browser context",
            "authorized signed-in session",
            "Never log or capture cookies",
            "AUTH-UI-PROOF-SAFETY",
        ):
            self.assertIn(value, self.contract)

    def test_spec_keeps_provider_and_shipping_out_of_scope(self) -> None:
        if not SPEC.is_file():
            self.skipTest("spec lives in the private data corpus")
        spec = compact(SPEC)
        self.assertIn("Provider SDK, middleware, token, callback, authorization", spec)
        self.assertIn("no new skill", spec.lower())
        self.assertIn("no commit or push authorized", spec.lower())


if __name__ == "__main__":
    unittest.main()
