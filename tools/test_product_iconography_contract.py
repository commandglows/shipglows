#!/usr/bin/env python3
"""Regression checks for the provider-neutral product iconography doctrine."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "skills" / "references" / "product-iconography-contract.md"
BUILD = ROOT / "skills" / "001-sg-build" / "SKILL.md"
DESIGN = ROOT / "skills" / "006-sg-design" / "SKILL.md"
PARITY = ROOT / "skills" / "602-sg-platform-parity" / "SKILL.md"


def normalized_text(path: Path) -> str:
    return " ".join(path.read_text(encoding="utf-8").split())


class ProductIconographyContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.contract = normalized_text(CONTRACT)

    def test_build_design_and_parity_load_the_shared_contract(self) -> None:
        # Owners may name a shared contract by file name inside a shared-contract loader list.
        reference = "product-iconography-contract.md"
        for owner in (BUILD, DESIGN, PARITY):
            self.assertIn(reference, normalized_text(owner))

    def test_iconoir_is_a_conditional_candidate_not_a_default(self) -> None:
        for expected in (
            "Iconoir is a strong candidate",
            "It is never an automatic dependency or universal visual direction",
            "Continue the project's existing coherent icon family",
            "Do not mix libraries glyph by glyph for convenience",
        ):
            self.assertIn(expected, self.contract)

    def test_product_semantics_are_independent_of_provider_names(self) -> None:
        for expected in (
            "stable semantic icon key",
            "Do not expose provider names such as `ArrowLeft`, `Trash`, or `CheckCircle` as the durable domain contract",
            "Product meaning and accessible names remain stable when the underlying icon provider changes",
            "Do not perform blind component-name substitution",
        ):
            self.assertIn(expected, self.contract)

    def test_accessibility_does_not_rely_on_shape_color_or_tooltips(self) -> None:
        for expected in (
            "An icon-only control requires an unambiguous accessible name",
            "A tooltip may supplement discovery",
            "never becomes the sole accessible name",
            "Do not communicate success, warning, failure, selection, required state, or destructive consequence through icon shape or color alone",
            "visible focus",
        ):
            self.assertIn(expected, self.contract)

    def test_directionality_is_semantic_not_blanket_mirroring(self) -> None:
        for expected in (
            "Classify each directional symbol before mirroring",
            "Reading/navigation direction",
            "Physical or absolute direction",
            "Media and established symbols",
            "never mirror them from a blanket CSS transform",
            "Text-bearing or brand glyphs",
        ):
            self.assertIn(expected, self.contract)

    def test_package_svg_license_and_proof_boundaries_are_explicit(self) -> None:
        for expected in (
            "selective component imports or a proven tree-shaken entrypoint",
            "a package's tree-shaking claim alone is not proof",
            "Optimization is not sanitization",
            "Record library license, attribution obligations, brand usage rules, and custom-icon provenance",
            "A recognizable icon is not automatically an accessible or product-correct icon",
        ):
            self.assertIn(expected, self.contract)

    def test_sources_and_adoption_limits_are_recorded(self) -> None:
        for expected in (
            "https://iconoir.com/",
            "https://github.com/iconoir-icons/iconoir",
            "https://lucide.dev/guide/",
            "https://developers.google.com/fonts/docs/material_symbols",
            "https://www.w3.org/WAI/ARIA/apg/patterns/button/",
            "Consulted 2026-08-15",
        ):
            self.assertIn(expected, self.contract)

    def test_public_invocation_grammar_remains_unchanged(self) -> None:
        build = normalized_text(BUILD)
        design = normalized_text(DESIGN)
        parity = normalized_text(PARITY)
        self.assertIn("[spark|codex|mini|agents|sous-agent|no-agents]", build)
        self.assertIn("library <add|retry|approve|list|status>", design)
        self.assertIn("<project | feature | spec path>", parity)
        self.assertNotIn("iconography [scope]", (build + design + parity).lower())


if __name__ == "__main__":
    unittest.main()
