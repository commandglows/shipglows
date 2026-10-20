#!/usr/bin/env python3
"""Scenario-first regression checks for the web typography doctrine."""

from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "skills/references/web-typography-contract.md"
SPEC = ROOT / "shipglows_data/workflow/specs/web-typography-contract.md"
OWNERS = (
    ROOT / "skills/001-sg-build/SKILL.md",
    ROOT / "skills/006-sg-design/SKILL.md",
    ROOT / "skills/010-sg-technical/references/performance-audit-playbook.md",
)
TECHNICAL = ROOT / "skills/010-sg-technical/SKILL.md"


def text(path: Path) -> str:
    return " ".join(path.read_text(encoding="utf-8").split())


class WebTypographyContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.contract = text(CONTRACT)

    def test_conditional_owner_loaders(self) -> None:
        # Owners may name a shared contract by file name inside a shared-contract loader list.
        reference = "web-typography-contract.md"
        for owner in OWNERS:
            value = text(owner)
            self.assertIn(reference, value)
            self.assertTrue(" when " in value.lower() or " whenever " in value.lower())

    def test_provider_substitution_preserves_roles(self) -> None:
        for value in (
            "Define stable product roles",
            "semantic type roles remain stable when the font source, family, or delivery provider changes",
            "Self-hosting, Google Fonts, and Fontsource are contextual options, not automatic defaults",
            "FontJoy and Font Brief",
            "exploration aids only",
        ):
            self.assertIn(value, self.contract)

    def test_real_variants_axes_and_locales(self) -> None:
        for value in (
            "Ship real bold and italic faces",
            "Use `font-synthesis` controls",
            "axes and ranges actually included",
            "A subset must not drop localized glyphs",
            "Test shaping, joining, kerning, vertical forms, bidirectional text",
            "Treat emoji as a separate rendering decision",
        ):
            self.assertIn(value, self.contract)

    def test_loading_and_layout_shift_are_bounded(self) -> None:
        for value in (
            "Prefer WOFF2",
            "Preload only proven critical faces",
            "indiscriminate preload competes with other critical resources",
            "contextual strategies, not universal winners",
            "An unacceptable fallback swap layout shift is a failed typography change",
            "`size-adjust`, `ascent-override`, `descent-override`, and `line-gap-override`",
        ):
            self.assertIn(value, self.contract)

    def test_accessibility_privacy_and_rollback_pressure(self) -> None:
        for value in (
            "User text spacing and zoom must not clip, overlap, hide",
            "Fixed heights, viewport-only font sizes",
            "Do not claim WCAG conformance from type tokens",
            "Keep CSP `font-src`, `style-src`",
            "External font requests can disclose visitor network metadata",
            "never perform a blind family-name replacement",
            "Define rollback triggers for missing glyphs, unacceptable shift",
        ):
            self.assertIn(value, self.contract)

    def test_sources_budgets_and_public_grammar(self) -> None:
        for value in (
            "https://www.w3.org/TR/css-fonts-4/",
            "https://www.w3.org/WAI/WCAG22/Understanding/text-spacing",
            "https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/At-rules/%40font-face",
            "https://web.dev/articles/font-best-practices",
            "https://developers.google.com/fonts/docs/css2",
            "https://fontsource.org/docs/getting-started/introduction",
            "Do not invent absolute universal thresholds",
            "Use browser network evidence and rendered proof",
        ):
            self.assertIn(value, self.contract)
        if SPEC.is_file():  # the spec lives in the private data corpus
            self.assertIn("No universal threshold or new public invocation grammar", text(SPEC))
        technical = text(TECHNICAL)
        self.assertIn("<audit|architecture|deps|performance|migrate|github|sync|access|parity|help>", technical)
        self.assertNotIn("typography [", technical.lower())


if __name__ == "__main__":
    unittest.main()
