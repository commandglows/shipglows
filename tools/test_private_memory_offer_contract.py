"""Focused textual protection checks, not a behavioral model evaluation."""
import unittest
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]

class PrivateMemoryOfferContractTests(unittest.TestCase):
    def test_offer_is_conditional_and_does_not_open_private_storage(self):
        core = (ROOT / "skills/000-shipglows/SKILL.md").read_text(encoding="utf-8")
        offer = core.split("Offer once to privately remember", 1)[1].split("\n\n", 1)[0]
        for protection in (
            "verified reusable pointers", "avoid future",
            "unless known saved or declined",
            "Do not inspect private stores or presume",
            "only after interest",
        ):
            self.assertIn(protection, offer)
        self.assertNotIn("memory-operations.md", core)
        self.assertNotIn("private_memory.py", core)

    def test_guidance_retains_record_consent_and_minimum_disclosure(self):
        leaf = (ROOT / "skills/603-sg-private/references/memory-operations.md").read_text(encoding="utf-8")
        normalized = " ".join(leaf.split())
        for protection in (
            "minimum verified non-secret pointer and metadata",
            "exact private destination and effect",
            "asking only for missing information",
            "Interest in guidance is not write consent",
            "explicit approval covering that record before persistence",
            "reusing a sufficient existing approval",
            "no authority over its target",
        ):
            self.assertIn(protection, normalized)
        self.assertIn("without `--apply`", leaf)

    def test_existing_owner_still_blocks_implicit_access_and_secrets(self):
        wrapper = (ROOT / "skills/sg-private/SKILL.md").read_text(encoding="utf-8")
        engine = (ROOT / "skills/603-sg-private/SKILL.md").read_text(encoding="utf-8")
        self.assertIn("not permission to persist or inspect", wrapper)
        self.assertIn("Never store credentials, tokens, cookies", engine)
        self.assertIn("A supplied value is transient unless", engine)
        self.assertIn("continue the original task without writing memory", engine)

if __name__ == "__main__":
    unittest.main()
