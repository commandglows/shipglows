#!/usr/bin/env python3
"""Validate locale peers for a Markdown article collection using stdlib only."""

from __future__ import annotations

import argparse
from dataclasses import dataclass
from pathlib import Path
import re
from typing import Iterable


FIELD_RE = re.compile(r"^([A-Za-z][A-Za-z0-9_-]*):\s*(.*?)\s*$")


@dataclass(frozen=True)
class Article:
    path: Path
    locale: str
    key: str
    slug: str
    alternate_slug: str
    draft: str


def _unquote(value: str) -> str:
    if len(value) >= 2 and value[0] == value[-1] and value[0] in {'"', "'"}:
        return value[1:-1]
    return value


def _read_frontmatter(path: Path) -> dict[str, str]:
    lines = path.read_text(encoding="utf-8").splitlines()
    if not lines or lines[0].strip() != "---":
        return {}
    fields: dict[str, str] = {}
    for line in lines[1:]:
        if line.strip() == "---":
            break
        match = FIELD_RE.match(line)
        if match:
            fields[match.group(1)] = _unquote(match.group(2))
    return fields


def _load_articles(root: Path) -> tuple[list[Article], list[str]]:
    articles: list[Article] = []
    errors: list[str] = []
    for path in sorted(root.rglob("*.md")):
        fields = _read_frontmatter(path)
        required = ("locale", "articleKey", "slug", "draft")
        missing = [field for field in required if not fields.get(field)]
        if missing:
            errors.append(f"ARTICLE-LOCALE-METADATA {path}: missing {', '.join(missing)}")
            continue
        articles.append(
            Article(
                path=path.resolve(),
                locale=fields["locale"],
                key=fields["articleKey"],
                slug=fields["slug"],
                alternate_slug=fields.get("alternateSlug", ""),
                draft=fields["draft"].lower(),
            )
        )
    return articles, errors


def lint_article_locale_parity(
    articles_root: Path,
    locales: Iterable[str],
    article_keys: set[str] | None = None,
    changed_paths: set[Path] | None = None,
) -> list[str]:
    """Return blocking parity errors for selected article identities."""

    root = articles_root.resolve()
    declared_locales = tuple(dict.fromkeys(locales))
    if not declared_locales:
        return ["ARTICLE-LOCALE-METADATA: at least one declared locale is required"]

    articles, errors = _load_articles(root)
    grouped: dict[str, list[Article]] = {}
    for item in articles:
        grouped.setdefault(item.key, []).append(item)

    selected_keys = article_keys or set(grouped)
    normalized_changed = (
        {path.resolve() for path in changed_paths} if changed_paths is not None else None
    )

    for key in sorted(selected_keys):
        peers = grouped.get(key, [])
        by_locale: dict[str, list[Article]] = {}
        for peer in peers:
            by_locale.setdefault(peer.locale, []).append(peer)

        for locale in declared_locales:
            count = len(by_locale.get(locale, []))
            if count == 0:
                errors.append(f"ARTICLE-LOCALE-MISSING {key}: missing locale {locale}")
            elif count > 1:
                errors.append(f"ARTICLE-LOCALE-METADATA {key}: duplicate locale {locale}")

        if any(len(by_locale.get(locale, [])) != 1 for locale in declared_locales):
            continue

        selected = [by_locale[locale][0] for locale in declared_locales]
        if len({peer.draft for peer in selected}) != 1:
            errors.append(f"ARTICLE-LOCALE-METADATA {key}: publication state differs")

        if len(selected) == 2:
            first, second = selected
            if first.alternate_slug != second.slug or second.alternate_slug != first.slug:
                errors.append(
                    f"ARTICLE-LOCALE-METADATA {key}: alternate-locale mapping is not symmetric"
                )

        if normalized_changed is not None:
            touched = [peer.path in normalized_changed for peer in selected]
            if any(touched) and not all(touched):
                missing_updates = [
                    peer.locale for peer, was_touched in zip(selected, touched) if not was_touched
                ]
                errors.append(
                    f"ARTICLE-LOCALE-STALE {key}: unchanged locale peer(s) "
                    + ", ".join(missing_updates)
                )

    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--articles-root", type=Path, required=True)
    parser.add_argument("--locales", nargs="+", required=True)
    parser.add_argument("--article-key", action="append", dest="article_keys")
    parser.add_argument("--changed-path", action="append", type=Path, dest="changed_paths")
    args = parser.parse_args()
    errors = lint_article_locale_parity(
        args.articles_root,
        args.locales,
        set(args.article_keys) if args.article_keys else None,
        set(args.changed_paths) if args.changed_paths is not None else None,
    )
    if errors:
        for error in errors:
            print(error)
        return 1
    print("Article locale parity passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
