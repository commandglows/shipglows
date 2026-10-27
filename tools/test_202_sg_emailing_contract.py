from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
SKILL = ROOT / "skills" / "202-sg-emailing" / "SKILL.md"
ALIAS = ROOT / "skills" / "emailing" / "SKILL.md"
REFERENCES = ROOT / "skills" / "202-sg-emailing" / "references"
STANDARD = REFERENCES / "postmark-first-platform-standard.md"
# Superseded Resend-first standard, kept as history only.
HISTORY = REFERENCES / "resend-first-platform-standard.md"


def routing_row(standard: str, email_type: str) -> str:
    rows = [line for line in standard.splitlines() if line.startswith(f"| {email_type} |")]
    if len(rows) != 1:
        raise AssertionError(f"expected exactly one routing row for {email_type!r}, found {len(rows)}")
    return rows[0]


class EmailingContractTests(unittest.TestCase):
    def test_provider_standard_is_discoverable_from_the_owner(self) -> None:
        skill = SKILL.read_text(encoding="utf-8")
        self.assertIn("postmark-first-platform-standard.md", skill)
        self.assertIn("selecting or changing the email platform", skill)
        self.assertNotIn("resend-first-platform-standard.md", skill)
        alias = ALIAS.read_text(encoding="utf-8")
        self.assertIn("postmark-first-platform-standard.md", alias)
        self.assertNotIn("resend-first-platform-standard.md", alias)

    def test_standard_routes_product_email_through_central_postmark(self) -> None:
        standard = STANDARD.read_text(encoding="utf-8")
        self.assertIn("Provider dashboards are projections", standard)
        self.assertIn("Postmark is transport only", standard)
        self.assertIn("A purchase, account creation, payment, entitlement, trial or download never creates marketing consent.", standard)
        self.assertIn("identity-provider-selection.md", standard)
        self.assertIn("resend-first-platform-standard.md", standard)

        transactional = routing_row(standard, "Transactional and operational (receipts, access, alerts, service notices)")
        self.assertIn("/api/v1/email/messages/transactional", transactional)
        self.assertIn("transactional stream", transactional)

        product_updates = routing_row(standard, "Product updates")
        self.assertIn("ShipGlows App", product_updates)
        self.assertIn("explicit marketing consent", product_updates)
        self.assertIn("Broadcast stream", product_updates)

        content_newsletters = routing_row(standard, "Content newsletters")
        self.assertIn("ContentGlows", content_newsletters)
        self.assertIn("broadcast stream", content_newsletters)

    def test_standard_forbids_provider_tokens_and_raw_html_in_apps(self) -> None:
        standard = STANDARD.read_text(encoding="utf-8")
        self.assertIn("Apps never hold a Postmark or Resend token", standard)
        self.assertIn("never raw HTML", standard)
        self.assertIn("the central service alone renders email HTML", standard)

    def test_standard_states_data_location_is_not_sending_region(self) -> None:
        standard = STANDARD.read_text(encoding="utf-8")
        self.assertIn("## Data Location", standard)
        self.assertIn("Sending region is never account-data residency", standard)

    def test_superseded_resend_standard_is_kept_as_history(self) -> None:
        history = HISTORY.read_text(encoding="utf-8")
        self.assertIn("status: superseded", history)
        self.assertIn("postmark-first-platform-standard.md", history)
        for required in (
            "Resend",
            "Beehiiv",
            "Ghost",
            "Loops",
            "Inbound",
            "Emailit",
            "Substack",
            "source of truth",
            "purchase",
            "explicit marketing consent",
            "United States",
            "project and environment",
            "provider projection",
        ):
            self.assertIn(required, history)


if __name__ == "__main__":
    unittest.main()
