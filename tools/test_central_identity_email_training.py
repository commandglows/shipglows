"""Known routing/safety regressions; independent prose review owns semantic proof.

Fixtures are bounded selected-domain witnesses, not complete lifecycle read traces.
"""
import json
from pathlib import Path
import unittest

from tools.skill_activation_budget import audit_scenarios

ROOT = Path(__file__).resolve().parents[1]
SHARED = "skills/references/"
EMAIL = "skills/202-sg-emailing/references/"
COMMON = SHARED + "identity-consent-access-contract.md"
AUTH0 = SHARED + "auth0-integration-playbook.md"
POSTMARK = EMAIL + "postmark-agent-integration-playbook.md"
NEWSLETTER = EMAIL + "newsletter-components-playbook.md"
NEW = (COMMON, AUTH0, POSTMARK, NEWSLETTER)
FIXTURE = ROOT / "tools/fixtures/central_identity_email_scenarios.json"


def normalized(path):
    return " ".join((ROOT / path).read_text(encoding="utf-8").split())


# Required consumers are intentionally specified independently of fixture reads.
EDGES = {
    "skills/001-sg-build/SKILL.md": (COMMON, AUTH0, SHARED + "email-work-routing.md"),
    "skills/010-sg-technical/SKILL.md": (COMMON, AUTH0, "email-work-routing.md"),
    "skills/103-sg-verify/SKILL.md": (COMMON, AUTH0, "email-work-routing.md"),
    "skills/109-sg-auth-debug/SKILL.md": ("auth0-integration-playbook.md", "identity-consent-access-contract.md"),
    "skills/601-sg-product-entitlements/SKILL.md": (COMMON,),
    SHARED + "email-work-routing.md": (COMMON, "postmark-agent-integration-playbook.md", "newsletter-components-playbook.md"),
    "skills/202-sg-emailing/SKILL.md": ("postmark-agent-integration-playbook.md", "newsletter-components-playbook.md", COMMON),
}


def missing_edges(texts):
    return [(owner, target) for owner, targets in EDGES.items()
            for target in targets if target not in texts[owner]]


def forbidden_domain_reads(registry):
    """Semantic exclusion independent of token ceilings or fixture declarations."""
    scenarios = registry["activation_profiles"]["scenarios"]
    forbidden = {"email-copy": set(NEW), "access-consent": {AUTH0, POSTMARK, NEWSLETTER}}
    return [(name, read["path"]) for name, paths in forbidden.items()
            for read in scenarios[name]["reads"] if read["path"] in paths]


class CentralIdentityEmailTrainingTests(unittest.TestCase):
    def test_activation_profiles_keep_new_guidance_conditional(self):
        profiles = json.loads((ROOT / (SHARED + "skill-invocation-registry.json")).read_text())["activation_profiles"]["skills"]
        for owner in ("109-sg-auth-debug", "601-sg-product-entitlements", "103-sg-verify", "010-sg-technical"):
            profile = profiles[owner]
            self.assertNotIn(COMMON, profile["baseline"])
            self.assertNotIn(AUTH0, profile["baseline"])
            self.assertEqual([COMMON], profile["gates"]["central-identity-consent-access"])
            if owner != "601-sg-product-entitlements":
                self.assertEqual([AUTH0], profile["gates"]["auth0-integration"])

    def test_direct_consumers_and_existing_provider_routes(self):
        self.assertEqual([], missing_edges({p: normalized(p) for p in EDGES}))
        self.assertIn("resend-agent-integration-playbook.md", normalized(SHARED + "email-work-routing.md"))
        self.assertIn("Clerk:", normalized("skills/109-sg-auth-debug/references/auth-provider-routing.md"))

    def test_removed_loader_is_detected(self):
        for owner, targets in EDGES.items():
            for target in targets:
                texts = {p: normalized(p) for p in EDGES}
                texts[owner] = texts[owner].replace(target, "missing-reference")
                self.assertIn((owner, target), missing_edges(texts))

    def test_scoped_activation_and_existing_project_choice(self):
        for path, marker in (
            ("skills/001-sg-build/SKILL.md", "task changes or diagnoses the selected Auth0 integration"),
            ("skills/109-sg-auth-debug/SKILL.md", "Unrelated diagnosis loads neither"),
            ("skills/601-sg-product-entitlements/SKILL.md", "unrelated entitlement work does not activate"),
            (SHARED + "email-work-routing.md", "plain copywriting does not activate"),
            (SHARED + "identity-provider-selection.md", "Existing project decisions take precedence"),
        ):
            self.assertIn(marker, normalized(path))

    def test_leaves_do_not_cascade_or_leak_project_configuration(self):
        for path in NEW:
            body = normalized(path)
            self.assertIn("This leaf does not load other leaves", body)
            for other in NEW:
                if other != path:
                    self.assertNotIn(Path(other).name, body)
            self.assertNotRegex(body, r"Diane DEFORES|[A-Z]:[\\/]|sk_live_|Bearer eyJ")

    def test_identity_access_and_marketing_are_independent(self):
        body = normalized(COMMON)
        for marker in (
            "Purchase does not subscribe marketing", "Unsubscribe preserves account and license",
            "anonymous newsletter signup", "Verified email alone never authorizes account linking",
            "Provider events cannot grant entitlements or consent", "does not require newsletter opt-in",
            "business, product, purpose and environment", "immediately before dispatch",
        ):
            self.assertIn(marker, body)

    def test_postmark_uncertainty_suppression_and_proof(self):
        body = normalized(POSTMARK)
        for marker in (
            "does not support send idempotency keys", "is unknown, not permission to resend",
            "ErrorCode and MessageID", "MessageID alone is insufficient",
            "Authenticate webhooks before processing", "stream-scoped",
            "independently scoped brands", "does not require newsletter opt-in",
            "Sandbox Delivered is simulated", "per-event verified/paused",
        ):
            self.assertIn(marker, body)
        self.assertIn("real sends", body)

    def test_auth0_backend_token_and_logout_boundaries(self):
        body = normalized(AUTH0)
        for marker in (
            "issuer + subject", "Authorization Code with PKCE", "never embed a client secret",
            "ID token as a generic API bearer token", "official Auth0 adapter has its own token/audience contract",
            "useConvexAuth", "getUserIdentity", "Logout alone does not revoke",
            "authenticated-but-unlicensed denial", "configuration checked, app running, login verified",
        ):
            self.assertIn(marker, body)

    def test_newsletter_errors_scanners_and_static_hosting(self):
        body = normalized(NEWSLETTER)
        for marker in (
            "unchecked explicit consent", "hidden browser fields are untrusted",
            "HTTP 200 alone is insufficient", "scanner GET", "withdrawal supersedes pending confirmations",
            "static Astro build needs an actual", "edits invalidate it", "one-recipient pilot",
        ):
            self.assertIn(marker.lower(), body.lower())

    def test_declared_branch_witnesses_fit_frozen_budgets(self):
        registry = json.loads(FIXTURE.read_text())
        self.assertEqual([], forbidden_domain_reads(registry))
        result = audit_scenarios(registry, ROOT)
        self.assertEqual("valid", result["status"], result["errors"])

    def test_missing_required_leaf_fails_evaluator(self):
        registry = json.loads(FIXTURE.read_text())
        scenario = registry["activation_profiles"]["scenarios"]["newsletter-postmark"]
        scenario["reads"] = [r for r in scenario["reads"] if r["path"] != POSTMARK]
        self.assertEqual("invalid", audit_scenarios(registry, ROOT)["status"])

    def test_eager_provider_pack_in_plain_copy_is_detected(self):
        registry = json.loads(FIXTURE.read_text())
        scenario = registry["activation_profiles"]["scenarios"]["email-copy"]
        scenario["reads"].append({"path": POSTMARK, "parent": scenario["entry"],
            "stage": "domain", "trigger": "unrelated eager load", "reason": "mutation test"})
        self.assertEqual("invalid", audit_scenarios(registry, ROOT)["status"])
        # The routing exclusion must still fail even with generous token budgets.
        scenario["budget"]["max_tokens"] = 100_000
        scenario["baseline_tokens"] = 100_000
        self.assertEqual("valid", audit_scenarios(registry, ROOT)["status"])
        self.assertEqual([("email-copy", POSTMARK)], forbidden_domain_reads(registry))

    def test_required_witnesses_are_not_inferred_from_reads(self):
        registry = json.loads(FIXTURE.read_text())
        scenarios = registry["activation_profiles"]["scenarios"]
        expected = {"newsletter-postmark": {COMMON, POSTMARK, NEWSLETTER, SHARED + "email-work-routing.md"},
                    "auth0-boundary": {AUTH0, COMMON}, "access-consent": {COMMON},
                    "email-copy": {EMAIL + "accessible-email-writing-playbook.md"}}
        for name, paths in expected.items():
            self.assertTrue(paths <= set(scenarios[name]["required_reads"]))
        reads = {r["path"] for r in scenarios["email-copy"]["reads"]}
        self.assertFalse(reads.intersection(NEW))


if __name__ == "__main__":
    unittest.main()
