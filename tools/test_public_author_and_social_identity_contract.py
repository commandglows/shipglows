#!/usr/bin/env python3
"""Scenario-first checks for public author and social identity authority."""

from pathlib import Path
import json
import unittest

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "skills/references/public-author-and-social-identity-contract.md"
REGISTRY = ROOT / "shipglows_data/branding/public-identity-registry.json"
BLOG = ROOT / "skills/references/blog-and-cms-experience-contract.md"
EDITORIAL = ROOT / "skills/references/editorial-content-corpus.md"
SPEC = ROOT / "shipglows_data/workflow/specs/public-author-and-social-identity-authority.md"
DESIGN = ROOT / "skills/006-sg-design/SKILL.md"
CONTENT = ROOT / "skills/007-sg-content/SKILL.md"
MARKETING = ROOT / "skills/009-sg-marketing/SKILL.md"
SEO = ROOT / "skills/406-sg-seo/SKILL.md"


def compact(path: Path) -> str:
    return " ".join(path.read_text(encoding="utf-8").split())


class PublicAuthorAndSocialIdentityContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.contract = compact(CONTRACT)
        cls.registry = json.loads(REGISTRY.read_text(encoding="utf-8"))

    def test_diane_is_the_only_seeded_default_author(self) -> None:
        self.assertEqual(self.registry["defaultAuthorId"], "diane")
        self.assertEqual(set(self.registry["people"]), {"diane"})
        diane = self.registry["people"]["diane"]
        self.assertEqual(diane["kind"], "person")
        self.assertEqual(diane["displayName"], "Diane")
        self.assertEqual(diane["status"], "declared")

    def test_undisclosed_public_identity_fields_are_null_or_empty(self) -> None:
        diane = self.registry["people"]["diane"]
        for field in ("photoUrl", "photoAlt", "publicContactEmail", "homepageUrl"):
            self.assertIsNone(diane[field])
        self.assertEqual(diane["bios"], {})
        self.assertEqual(diane["socialProfileIds"], [])
        self.assertEqual(self.registry["socialProfiles"], {})
        self.assertEqual(self.registry["projects"], {})

    def test_person_project_and_share_links_are_distinct(self) -> None:
        for value in (
            "Person identity",
            "Project identity",
            "Official social profile",
            "Share action",
            "never an official profile",
            "PUBLIC-ID-PERSON-VS-PROJECT",
        ):
            self.assertIn(value, self.contract)

    def test_public_contact_and_photo_require_explicit_declaration(self) -> None:
        for value in (
            "publicContactEmail",
            "photoUrl",
            "photoAlt",
            "explicitly approved for publication",
            "login, authentication, billing, legal, support, or private email",
            "PUBLIC-ID-PRIVATE-CONTACT",
        ):
            self.assertIn(value, self.contract)

    def test_generic_and_platform_homepage_drift_is_defined(self) -> None:
        for value in (
            "CommunityGlows Team",
            "L’équipe CommunityGlows",
            "Team",
            "Editorial",
            "https://instagram.com",
            "https://linkedin.com",
            "PUBLIC-ID-GENERIC-BYLINE",
            "PUBLIC-ID-PLATFORM-HOMEPAGE",
        ):
            self.assertIn(value, self.contract)

    def test_profile_schema_has_owner_purpose_and_verification(self) -> None:
        for value in (
            "platform",
            "canonicalUrl",
            "handle",
            "ownerType",
            "ownerId",
            "purpose",
            "status",
            "verifiedAt",
            "lastCheckedAt",
        ):
            self.assertIn(value, self.contract)

    def test_blog_and_editorial_authorities_link_to_identity_contract(self) -> None:
        name = "public-author-and-social-identity-contract.md"
        self.assertIn(name, compact(BLOG))
        self.assertIn(name, compact(EDITORIAL))
        self.assertIn("authorId", compact(BLOG))

    def test_direct_consumers_load_the_authority_conditionally(self) -> None:
        reference = "$SHIPGLOWS_ROOT/skills/references/public-author-and-social-identity-contract.md"
        for path in (DESIGN, CONTENT, MARKETING, SEO):
            self.assertIn(reference, compact(path))
        self.assertIn("author cards, bylines, contact identity, or official social links", compact(DESIGN))
        self.assertIn("authorship, public contact identity, or official social profiles", compact(CONTENT))
        self.assertIn("author, founder, spokesperson, contact, or project social identity", compact(MARKETING))
        self.assertIn("Person or Organization authorship, sameAs, or project social profiles", compact(SEO))

    def test_spec_defers_product_population_and_project_mutation(self) -> None:
        spec = compact(SPEC)
        self.assertIn("Filling every product record in this run", spec)
        self.assertIn("Editing product articles", spec)
        self.assertIn("no commit or push authorized", spec.lower())


if __name__ == "__main__":
    unittest.main()
