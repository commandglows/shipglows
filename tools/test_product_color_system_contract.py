#!/usr/bin/env python3
"""Scenario-first regression checks for the product color-system doctrine."""

from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "skills/references/product-color-system-contract.md"
SPEC = ROOT / "shipglows_data/workflow/specs/product-color-system-contract.md"
OWNERS = (
    ROOT / "skills/001-sg-build/SKILL.md",
    ROOT / "skills/006-sg-design/SKILL.md",
    ROOT / "skills/602-sg-platform-parity/SKILL.md",
)


def text(path: Path) -> str:
    return " ".join(path.read_text(encoding="utf-8").split())


class ProductColorSystemContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.contract = text(CONTRACT)

    def test_conditional_owner_loaders(self) -> None:
        # Owners may name a shared contract by file name inside a shared-contract loader list.
        reference = "product-color-system-contract.md"
        for owner in OWNERS:
            value = text(owner)
            self.assertIn(reference, value)
            self.assertTrue(" when " in value.lower() or " whenever " in value.lower())

    def test_semantic_roles_survive_provider_substitution(self) -> None:
        for value in (
            "Define stable roles before raw values",
            "Product meaning and semantic roles remain stable when a palette, provider, color space, or platform implementation changes",
            "canvas and layered surfaces",
            "keyboard focus indicators",
            "data-visualization series",
            "They are aids only",
        ):
            self.assertIn(value, self.contract)

    def test_wide_gamut_has_explicit_fallback(self) -> None:
        for value in (
            "sRGB remains the interoperability baseline",
            "Display-P3",
            "OKLCH",
            "Every wide-gamut or modern-color use has an explicit fallback strategy",
            "clipped, locally adjusted, or mapped",
            "source coordinates equal displayed pixels",
        ):
            self.assertIn(value, self.contract)

    def test_forced_colors_and_dark_mode_retain_accessibility(self) -> None:
        for value in (
            "light, dark, high-contrast, and forced-colors",
            "Use `color-scheme`",
            "Prefer native semantics and system colors for controls and focus",
            "Do not broadly disable forced-color adaptation",
            "Visible focus must remain identifiable",
        ):
            self.assertIn(value, self.contract)

    def test_meaning_is_not_color_only(self) -> None:
        for value in (
            "Never encode information, required action, status, selection, validation, or navigation through color alone",
            "disabled, visited, loading, invalid, error, warning, success",
            "use labels, direct annotations, shapes, strokes, patterns",
            "simulators can reveal candidate collisions",
            "supporting heuristics only",
        ):
            self.assertIn(value, self.contract)

    def test_resolved_overlay_gradient_and_image_contrast(self) -> None:
        for value in (
            "final resolved foreground/background combination",
            "Transparency, opacity, disabled styling, scrims, gradients",
            "background images, video, and user-supplied media",
            "Sample or calculate relevant worst-case regions after compositing",
            "resolved computed styles",
        ):
            self.assertIn(value, self.contract)

    def test_platform_parity_migration_and_proof(self) -> None:
        for value in (
            "Define parity by product meaning and accessibility outcome, not identical color coordinates",
            "platform-native values or adaptation",
            "never perform a blind hue-name or provider-token substitution",
            "Define rollback triggers",
            "browser and real-device/platform checks",
            "assistive-mode and keyboard proof",
        ):
            self.assertIn(value, self.contract)

    def test_wcag_22_remains_normative_baseline(self) -> None:
        for value in (
            "Use WCAG 2.2 as the normative conformance baseline",
            "WCAG 3 is a draft and APCA is an emerging contrast evaluation approach",
            "APCA alone must never replace applicable WCAG 2.2 checks",
            "https://www.w3.org/TR/WCAG22/",
            "https://www.w3.org/TR/wcag-3.0/",
            "Do not invent a universal palette size",
        ):
            self.assertIn(value, self.contract)
        if SPEC.is_file():  # the spec lives in the private data corpus
            self.assertIn("104-sg-end`: ready for operator review", text(SPEC))
            self.assertIn("005-sg-ship`: out of scope", text(SPEC))


if __name__ == "__main__":
    unittest.main()
