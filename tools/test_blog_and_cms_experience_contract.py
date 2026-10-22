#!/usr/bin/env python3
"""Scenario-first regression checks for blog and CMS experience doctrine."""

from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "skills/references/blog-and-cms-experience-contract.md"
SPEC = ROOT / "shipglows_data/workflow/specs/blog-and-cms-experience-contract.md"
DESIGN = ROOT / "skills/006-sg-design/SKILL.md"
CONTENT = ROOT / "skills/007-sg-content/SKILL.md"
SEO = ROOT / "skills/406-sg-seo/SKILL.md"


def compact(path: Path) -> str:
    return " ".join(path.read_text(encoding="utf-8").split())


class BlogAndCmsExperienceContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.contract = compact(CONTRACT)

    def test_conditional_owner_loaders_preserve_boundaries(self) -> None:
        reference = "$SHIPGLOWS_ROOT/skills/references/blog-and-cms-experience-contract.md"
        self.assertIn(reference, compact(DESIGN))
        self.assertIn("when designing, implementing, auditing, or proving blog", compact(DESIGN))
        self.assertIn(reference, compact(CONTENT))
        self.assertIn("Article and CMS architecture, publication lifecycle, localization, or editorial access", compact(CONTENT))
        self.assertIn(reference, compact(SEO))
        self.assertIn("when blog or article SEO depends on canonical content fields", compact(SEO))
        self.assertIn("does not replace project editorial truth", self.contract)

    def test_canonical_model_separates_identity_from_provider_and_slug(self) -> None:
        for value in (
            "Stable article ID",
            "Provider record ID",
            "Current slug",
            "Publication status",
            "Locale relationship",
            "Correction history",
            "stable project-owned identity",
        ):
            self.assertIn(value, self.contract)

    def test_minimal_and_optional_component_anatomy(self) -> None:
        for value in (
            "Required core",
            "Optional modules",
            "Blog index",
            "Article page",
            "Article card",
            "Table of contents",
            "Related content",
            "empty, loading, error, and retired",
        ):
            self.assertIn(value, self.contract)

    def test_accessible_reading_pressure_scenario(self) -> None:
        for value in (
            "one logical h1",
            "200% zoom",
            "keyboard",
            "focus",
            "reduced motion",
            "media alternatives",
            "reading order",
            "BLOG-CMS-ACCESSIBLE-READING",
        ):
            self.assertIn(value, self.contract)

    def test_seo_and_locale_graph_are_derived(self) -> None:
        for value in (
            "canonical URL",
            "hreflang",
            "x-default",
            "structured data",
            "sitemap",
            "noindex",
            "BLOG-CMS-LOCALE-GAP",
            "never fabricate a translation",
        ):
            self.assertIn(value, self.contract)

    def test_publication_lifecycle_and_retirement_are_explicit(self) -> None:
        for value in (
            "Draft",
            "In review",
            "Scheduled",
            "Published",
            "Corrected",
            "Archived",
            "Redirected or gone",
            "BLOG-CMS-RETIRED-CONTENT",
        ):
            self.assertIn(value, self.contract)

    def test_adapter_swap_and_outage_preserve_public_truth(self) -> None:
        for value in (
            "CMS is an adapter",
            "BLOG-CMS-ADAPTER-SWAP",
            "BLOG-CMS-PROVIDER-OUTAGE",
            "last verified public artifact",
            "cache and freshness",
            "duplicate slugs",
            "redirect manifest",
        ):
            self.assertIn(value, self.contract)

    def test_drafts_and_private_editorial_data_never_leak(self) -> None:
        for value in (
            "BLOG-CMS-DRAFT-LEAK",
            "preview tokens",
            "internal notes",
            "private media URLs",
            "server-side authorization",
            "sanitize",
            "must not be indexable",
        ):
            self.assertIn(value, self.contract)

    def test_spec_keeps_provider_selection_and_projects_out_of_scope(self) -> None:
        if not SPEC.is_file():
            self.skipTest("spec lives in the private data corpus")
        spec = compact(SPEC)
        self.assertIn("Selecting, buying, installing, or configuring a CMS", spec)
        self.assertIn("product repositories", spec)
        self.assertIn("no CMS selection", spec)
        self.assertIn("no commit or push authorized", spec.lower())


if __name__ == "__main__":
    unittest.main()
