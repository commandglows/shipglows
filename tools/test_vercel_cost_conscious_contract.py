from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]


class VercelCostConsciousContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.contract = (ROOT / "skills/references/vercel-cost-conscious-operations.md").read_text(encoding="utf-8")
        cls.dev_mode = (ROOT / "skills/references/project-development-mode.md").read_text(encoding="utf-8")
        cls.maintenance = (ROOT / "skills/002-sg-maintain/references/maintenance-playbooks.md").read_text(encoding="utf-8")
        cls.release = (ROOT / "skills/004-sg-deploy/references/release-confidence-workflow.md").read_text(encoding="utf-8")
        cls.prod = (ROOT / "skills/405-sg-prod/references/production-verification-workflow.md").read_text(encoding="utf-8")
        cls.prod_vercel = (ROOT / "skills/405-sg-prod/references/prod-vercel-cost-and-protection.md").read_text(encoding="utf-8")
        cls.template = (ROOT / "templates/project_platform_usage.md").read_text(encoding="utf-8")
        cls.registry = (ROOT / "skills/references/skill-invocation-registry.json").read_text(encoding="utf-8")

    def test_hobby_is_portable_baseline(self) -> None:
        self.assertIn("Hobby is the portable baseline", self.contract)
        self.assertIn("VCC-HOBBY-PORTABLE", self.contract)
        self.assertIn("vercel_plan: hobby | pro | enterprise | unknown", self.dev_mode)

    def test_pro_does_not_turn_credit_into_a_target(self) -> None:
        self.assertIn("private organization repository deployments", self.contract)
        self.assertIn("Unused credit is an acceptable economical outcome", self.contract)
        self.assertIn("VCC-CREDIT-NOT-TARGET", self.contract)

    def test_build_defaults_are_economical(self) -> None:
        self.assertIn("build_machine_policy: standard-default", self.contract)
        self.assertIn("build_concurrency_policy: one-per-branch", self.contract)
        self.assertIn("expected cost boundary", self.contract)

    def test_spend_and_waf_mutations_keep_authority(self) -> None:
        self.assertIn("always requires explicit operator authority", self.contract)
        self.assertIn("log -> review -> enforce -> verify", self.contract)
        self.assertIn("VCC-SPEND-AUTHORITY", self.contract)

    def test_consumers_load_the_shared_contract(self) -> None:
        needle = "skills/references/vercel-cost-conscious-operations.md"
        self.assertIn(needle, self.maintenance)
        self.assertIn(needle, self.release)
        self.assertIn("references/prod-vercel-cost-and-protection.md", self.prod)
        self.assertIn(needle, self.prod_vercel)
        self.assertGreaterEqual(self.registry.count('"vercel-cost-conscious-operations"'), 2)

    def test_project_platform_template_captures_cost_policy(self) -> None:
        for field in (
            "Provider plan",
            "Plan capability reason",
            "Build machine policy",
            "Build concurrency policy",
            "Spend posture and owner",
            "Deployment protection",
            "Firewall/WAF review state",
            "Paid add-ons",
        ):
            self.assertIn(field, self.template)


if __name__ == "__main__":
    unittest.main()
