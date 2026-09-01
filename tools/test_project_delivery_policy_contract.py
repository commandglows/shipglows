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
        cls.bootstrap = (
            ROOT / "skills/305-sg-init/references/bootstrap-entrypoint-and-dev-mode.md"
        ).read_text(encoding="utf-8")
        cls.start = (ROOT / "skills/102-sg-start/SKILL.md").read_text(encoding="utf-8")
        cls.verify = (ROOT / "skills/103-sg-verify/SKILL.md").read_text(encoding="utf-8")
        cls.end = (ROOT / "skills/104-sg-end/SKILL.md").read_text(encoding="utf-8")
        cls.ship = (ROOT / "skills/005-sg-ship/SKILL.md").read_text(encoding="utf-8")
        cls.deploy = (ROOT / "skills/004-sg-deploy/SKILL.md").read_text(encoding="utf-8")
        cls.prod = (ROOT / "skills/405-sg-prod/SKILL.md").read_text(encoding="utf-8")

    def test_development_never_means_local_only(self) -> None:
        for marker in (
            "Never interpret `development` as `local-only`",
            "coherent validated work to the canonical integration branch at the earliest safe opportunity",
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
            "`development` (non-live)",
            "`published` (live)",
            "production_branch: main",
            "integration_branch: main | dev",
            "staging_branch: not-required | dev",
            "gated `dev -> main`",
        ):
            with self.subTest(marker=marker):
                self.assertIn(marker, self.policy)

    def test_declared_policy_is_data_only_and_not_silently_rewritten(self) -> None:
        for marker in (
            "no secret, token, executable command",
            "never silently rewrite declared intent",
            "does not authorize non-Git environment or deployment changes",
            "Ordinary Git/GitHub configuration convergence",
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

    def test_bootstrap_records_status_driven_integration_branch(self) -> None:
        for marker in (
            "project-delivery-policy.md",
            "never infer maturity",
            "production_branch: main",
            "integration_branch: main",
            "integration_branch: dev",
            "staging_branch: dev",
            "without a validation prompt",
            "preserve legacy development mode",
        ):
            with self.subTest(marker=marker):
                self.assertIn(marker, self.bootstrap)

    def test_lifecycle_owners_consume_delivery_policy(self) -> None:
        for name, corpus in (
            ("start", self.start),
            ("verify", self.verify),
            ("end", self.end),
            ("ship", self.ship),
            ("deploy", self.deploy),
            ("prod", self.prod),
        ):
            with self.subTest(owner=name):
                self.assertIn("project-delivery-policy.md", corpus)

    def test_push_is_not_deployment_proof(self) -> None:
        self.assertIn("push proves persistence, not deployment", self.git_delivery)
        self.assertIn("push establishes remote persistence only", self.deploy)
        self.assertIn("successful Git push as deployment proof", self.prod)

    def test_git_stewardship_is_autonomous_and_status_driven(self) -> None:
        for marker in (
            "PDP-NON-LIVE-MAIN",
            "PDP-LIVE-DEV",
            "PDP-GIT-AUTONOMY",
            "project or chantier start",
            "coherent milestones",
            "chantier end",
            "adds no separate Git approval",
        ):
            self.assertIn(marker, self.policy)


if __name__ == "__main__":
    unittest.main()
