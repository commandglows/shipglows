#!/usr/bin/env python3
"""Scenario-first regression checks for product access and license UI doctrine."""

from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "skills/references/product-access-and-license-ui-contract.md"
AUTH_UI = ROOT / "skills/references/authenticated-experience-ui-contract.md"
SUPPORT = ROOT / "skills/references/product-entitlement-support-and-proof.md"
DESIGN = ROOT / "skills/006-sg-design/SKILL.md"
ENTITLEMENTS = ROOT / "skills/601-sg-product-entitlements/SKILL.md"
SPEC = ROOT / "shipglows_data/workflow/specs/product-access-and-license-ui-contract.md"


def compact(path: Path) -> str:
    return " ".join(path.read_text(encoding="utf-8").split())


class ProductAccessAndLicenseUiContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.contract = compact(CONTRACT)

    def test_direct_conditional_owner_loaders_and_cross_links(self) -> None:
        ref = "$SHIPGLOWS_ROOT/skills/references/product-access-and-license-ui-contract.md"
        self.assertIn(ref, compact(DESIGN))
        self.assertIn("when UI displays plans, licenses, features", compact(DESIGN))
        self.assertIn(ref, compact(ENTITLEMENTS))
        self.assertIn("Customer-facing plan/license/feature/quota/activation UI", compact(ENTITLEMENTS))
        self.assertIn("product-access-and-license-ui-contract.md", compact(AUTH_UI))
        self.assertIn("product-access-and-license-ui-contract.md", compact(SUPPORT))

    def test_identity_provider_ledger_mirror_ui_are_distinct(self) -> None:
        for value in (
            "Identity:", "Provider event:", "Canonical entitlement:", "Mirror/cache:", "Presentation:",
            "UI, client claims, provider branding, purchase copy, and local mirrors never authorize",
        ):
            self.assertIn(value, self.contract)

    def test_plan_feature_quota_and_term_semantics(self) -> None:
        for value in (
            "customer-facing plan name", "license/term type", "authorized feature entries",
            "quota entries", "activation entries", "lifetime/perpetual entitlement",
            "Do not turn marketing comparison copy into authorization keys",
        ):
            self.assertIn(value, self.contract)

    def test_activation_boundaries_and_device_privacy(self) -> None:
        for value in (
            "used = limit", "used > limit", "2 of 3 devices activated", "This device",
            "Hide hardware IDs, fingerprints, serials, full IPs", "Concurrent activation/deactivation",
            "LICENSE-UI-ACTIVATION-BOUNDARY",
        ):
            self.assertIn(value, self.contract)

    def test_zero_unlimited_unknown_and_stale_are_distinct(self) -> None:
        for value in (
            "`0` is a known numeric value", "`unlimited` is an explicit server-owned policy",
            "`not applicable`", "`unknown`", "Stale or offline", "LICENSE-UI-UNLIMITED-UNKNOWN",
            "LICENSE-UI-STALE-ACTIVE",
        ):
            self.assertIn(value, self.contract)

    def test_accessibility_localization_and_responsive_contract(self) -> None:
        for value in (
            "Never encode active, expired, limited, or error state by color alone", "200% zoom",
            "RTL", "long plan/feature names", "forced colors", "reduced motion",
            "Tables become labeled lists/cards", "at least 44 CSS pixels",
        ):
            self.assertIn(value, self.contract)

    def test_sensitive_values_and_commercial_mutations_are_excluded(self) -> None:
        for value in (
            "raw license or activation codes", "tokens", "receipts", "device fingerprints",
            "no real commercial mutation is implicit", "UI-only evidence never proves backend authorization",
        ):
            self.assertIn(value, self.contract)
        spec = compact(SPEC).lower()
        self.assertIn("no commit or push authorized", spec)


if __name__ == "__main__":
    unittest.main()
