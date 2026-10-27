from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
SKILL = ROOT / "skills" / "202-sg-emailing" / "SKILL.md"
ALIAS = ROOT / "skills" / "emailing" / "SKILL.md"
REFERENCES = ROOT / "skills" / "202-sg-emailing" / "references"
STANDARD = REFERENCES / "postmark-first-platform-standard.md"
# Superseded Resend-first standard, kept as history only.
HISTORY = REFERENCES / "resend-first-platform-standard.md"


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
        for required in (
            "CommandGlows",
            "Postmark",
            "Convex",
            "Clerk",
            "transactional",
            "broadcast",
            "purchase",
            "explicit marketing consent",
            "provider dashboard",
            "Resend",
            "resend-first-platform-standard.md",
        ):
            self.assertIn(required, standard)

    def test_standard_forbids_provider_tokens_and_raw_html_in_apps(self) -> None:
        standard = STANDARD.read_text(encoding="utf-8")
        self.assertIn("Apps never hold a Postmark or Resend token", standard)
        self.assertIn("Apps send blocks, never raw HTML", standard)

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
