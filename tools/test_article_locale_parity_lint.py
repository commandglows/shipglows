#!/usr/bin/env python3
"""Regression scenarios for article locale parity validation."""

from pathlib import Path
from tempfile import TemporaryDirectory
import unittest

from tools.article_locale_parity_lint import lint_article_locale_parity


def article(locale: str, key: str, slug: str, alternate: str, draft: str = "false") -> str:
    return f'''---
title: "{locale} title"
locale: "{locale}"
articleKey: "{key}"
slug: "{slug}"
alternateSlug: "{alternate}"
draft: {draft}
---

Body in {locale}.
'''


class ArticleLocaleParityLintTests(unittest.TestCase):
    def write(self, root: Path, locale: str, name: str, content: str) -> Path:
        path = root / locale / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")
        return path

    def test_missing_declared_locale_blocks(self) -> None:
        with TemporaryDirectory() as tmp:
            root = Path(tmp)
            self.write(root, "fr", "guide.md", article("fr", "guide", "guide-fr", "guide-en"))
            errors = lint_article_locale_parity(root, ("en", "fr"), {"guide"}, None)
            self.assertTrue(any("ARTICLE-LOCALE-MISSING" in error for error in errors))

    def test_complete_pair_passes(self) -> None:
        with TemporaryDirectory() as tmp:
            root = Path(tmp)
            en = self.write(root, "en", "guide.md", article("en", "guide", "guide-en", "guide-fr"))
            fr = self.write(root, "fr", "guide.md", article("fr", "guide", "guide-fr", "guide-en"))
            errors = lint_article_locale_parity(root, ("en", "fr"), {"guide"}, {en, fr})
            self.assertEqual([], errors)

    def test_asymmetric_alternate_slug_blocks(self) -> None:
        with TemporaryDirectory() as tmp:
            root = Path(tmp)
            self.write(root, "en", "guide.md", article("en", "guide", "guide-en", "wrong-fr"))
            self.write(root, "fr", "guide.md", article("fr", "guide", "guide-fr", "guide-en"))
            errors = lint_article_locale_parity(root, ("en", "fr"), {"guide"}, None)
            self.assertTrue(any("ARTICLE-LOCALE-METADATA" in error for error in errors))

    def test_one_sided_material_update_blocks(self) -> None:
        with TemporaryDirectory() as tmp:
            root = Path(tmp)
            en = self.write(root, "en", "guide.md", article("en", "guide", "guide-en", "guide-fr"))
            self.write(root, "fr", "guide.md", article("fr", "guide", "guide-fr", "guide-en"))
            errors = lint_article_locale_parity(root, ("en", "fr"), {"guide"}, {en})
            self.assertTrue(any("ARTICLE-LOCALE-STALE" in error for error in errors))

    def test_explicit_monolingual_surface_passes(self) -> None:
        with TemporaryDirectory() as tmp:
            root = Path(tmp)
            fr = self.write(root, "fr", "guide.md", article("fr", "guide", "guide-fr", ""))
            errors = lint_article_locale_parity(root, ("fr",), {"guide"}, {fr})
            self.assertEqual([], errors)


if __name__ == "__main__":
    unittest.main()
