from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
SKILL = ROOT / "skills" / "202-sg-emailing" / "SKILL.md"
ALIAS = ROOT / "skills" / "emailing" / "SKILL.md"
STANDARD = (
    ROOT
    / "skills"
    / "202-sg-emailing"
    / "references"
    / "resend-first-platform-standard.md"
)


class EmailingContractTests(unittest.TestCase):
    def test_provider_standard_is_discoverable_from_the_owner(self) -> None:
        skill = SKILL.read_text(encoding="utf-8")
        self.assertIn("resend-first-platform-standard.md", skill)
        self.assertIn("provider choice", skill)
        alias = ALIAS.read_text(encoding="utf-8")
        self.assertIn("resend-first-platform-standard.md", alias)

    def test_standard_preserves_default_exceptions_and_consent_boundary(self) -> None:
        standard = STANDARD.read_text(encoding="utf-8")
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
        ):
            self.assertIn(required, standard)

    def test_standard_keeps_provider_state_as_a_projection(self) -> None:
        standard = STANDARD.read_text(encoding="utf-8")
        self.assertIn("provider projection", standard)
        self.assertIn("Transactional", standard)
        self.assertIn("Marketing", standard)
        self.assertIn("Freshness", standard)


if __name__ == "__main__":
    unittest.main()
