#!/usr/bin/env python3
"""Pressure-scenario proof for project delivery posture and remote persistence."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
POLICY = ROOT / "skills/references/project-delivery-policy.md"


class ProjectDeliveryPolicyContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.policy = POLICY.read_text(encoding="utf-8")
        cls.development_mode = (
            ROOT / "skills/references/project-development-mode.md"
        ).read_text(encoding="utf-8")
        cls.git_delivery = (
            ROOT / "skills/references/git-milestone-delivery-contract.md"
        ).read_text(encoding="utf-8")

    def test_development_never_means_local_only(self) -> None:
        for marker in (
            "Never interpret `development` as `local-only`",
            "required after every validated milestone",
            "remote_persistence: milestone-and-final",
            "PDP-DEVELOPMENT-NOT-LOCAL-ONLY",
        ):
            with self.subTest(marker=marker):
                self.assertIn(marker, self.policy)
        self.assertIn("GMD-MILESTONE-PUSH", self.git_delivery)

    def test_policy_axes_are_independent(self) -> None:
        for marker in (
            "delivery_posture",
            "development_mode",
            "provider_state",
            "One axis never overrides another",
            "PDP-SEPARATE-AXES",
        ):
            with self.subTest(marker=marker):
                self.assertIn(marker, self.policy)

    def test_posture_defaults_are_proportional(self) -> None:
        for marker in (
            "`development`",
            "`published`",
            "`sensitive-production`",
            "required before production merge",
            "documented equivalent isolation",
            "production_branch: main",
            "work_branch_strategy: short-lived",
        ):
            with self.subTest(marker=marker):
                self.assertIn(marker, self.policy)

    def test_declared_policy_is_data_only_and_not_silently_rewritten(self) -> None:
        for marker in (
            "no secret, token, executable command",
            "never silently rewrite declared intent",
            "does not authorize configuration changes",
            "Provider configuration changes",
            "PDP-DECLARED-VS-OBSERVED",
        ):
            with self.subTest(marker=marker):
                self.assertIn(marker, self.policy)

    def test_legacy_development_mode_remains_compatible(self) -> None:
        for mode in ("local", "vercel-preview-push", "hybrid"):
            with self.subTest(mode=mode):
                self.assertIn(mode, self.development_mode)
        self.assertIn("Existing projects", self.policy)
        self.assertIn("preserve their existing mode", self.policy)
        self.assertIn("PDP-LEGACY-MODE", self.policy)


if __name__ == "__main__":
    unittest.main()
