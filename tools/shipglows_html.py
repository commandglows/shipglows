#!/usr/bin/env python3
"""Turn static HTML into readable Markdown without a browser (standard library only).

Keeps headings, paragraphs, lists, links, code and table rows; drops scripts,
styles, forms, images and page chrome. Prefers <main> or <article> when the page has
one. `looks_like_js_shell` tells when the HTML is an empty app shell that only
a browser can fill.
"""

from __future__ import annotations

from html import unescape
from html.parser import HTMLParser
import re
import unicodedata
from urllib.parse import urljoin

SKIP_TAGS = {"script", "style", "noscript", "template", "svg", "canvas", "iframe", "form", "button", "select", "dialog"}
CHROME_TAGS = {"nav", "footer", "header", "aside"}
BLOCK_TAGS = {"p", "div", "section", "article", "main", "blockquote", "figure", "figcaption", "table", "tr", "ul", "ol",
              "dl", "dt", "dd", "br", "hr", "body"}
VOID_TAGS = {"br", "hr", "img", "input", "meta", "link", "source", "wbr", "area", "base", "col", "embed", "track"}
MIN_TEXT_CHARS = 400


class _Converter(HTMLParser):
    def __init__(self, base_url: str, keep_chrome: bool):
        super().__init__(convert_charrefs=True)
        self.base_url = base_url
        self.keep_chrome = keep_chrome
        self.stack: list[str] = []
        self.skip_depth = 0
        self.out: list[str] = []
        self.title = ""
        self.og_title = ""
        self.in_title = False
        self.in_pre = 0
        self.href: str | None = None
        self.link_text: list[str] = []
        self.list_depth = 0
        self.main_start: int | None = None
        self.main_end: int | None = None

    def _skipping(self) -> bool:
        return self.skip_depth > 0

    def _emit(self, text: str) -> None:
        if self.href is not None:
            self.link_text.append(text)
        else:
            self.out.append(text)

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == "meta" and attrs.get("property") == "og:title" and attrs.get("content"):
            self.og_title = attrs["content"].strip()
        if tag not in VOID_TAGS:
            self.stack.append(tag)
        if tag == "title":
            self.in_title = True
            return
        hidden = attrs.get("hidden") is not None or attrs.get("aria-hidden") == "true"
        if self._skipping() or tag in SKIP_TAGS or hidden or (tag in CHROME_TAGS and not self.keep_chrome):
            if tag not in VOID_TAGS:
                self.skip_depth += 1
            return
        if tag in ("main", "article") and self.main_start is None:
            self.main_start = len(self.out)
            self.main_tag = tag
            self.main_depth = len(self.stack)
        if re.fullmatch(r"h[1-6]", tag):
            self.out.append("\n\n" + "#" * int(tag[1]) + " ")
        elif tag == "li":
            self.out.append("\n" + "  " * max(self.list_depth - 1, 0) + "- ")
        elif tag in ("ul", "ol"):
            self.list_depth += 1
            self.out.append("\n")
        elif tag == "pre":
            self.in_pre += 1
            self.out.append("\n\n```\n")
        elif tag == "code" and not self.in_pre:
            self._emit("`")
        elif tag in ("td", "th"):
            self.out.append(" | ")
        elif tag in ("strong", "b"):
            self._emit("**")
        elif tag in ("em", "i"):
            self._emit("*")
        elif tag == "a" and attrs.get("href") and self.href is None:
            href = attrs["href"].strip()
            if not href.startswith(("javascript:", "#", "mailto:", "tel:")):
                self.href = urljoin(self.base_url, href)
                self.link_text = []
        elif tag in BLOCK_TAGS:
            self.out.append("\n\n" if tag not in ("br", "tr", "dt", "dd") else "\n")

    def handle_endtag(self, tag):
        if tag not in self.stack:
            return
        while self.stack:
            open_tag = self.stack.pop()
            self._close(open_tag)
            if open_tag == tag:
                break

    def _close(self, tag: str) -> None:
        if tag == "title":
            self.in_title = False
            return
        if self._skipping():
            self.skip_depth -= 1
            return
        if tag in ("main", "article") and self.main_start is not None and self.main_end is None \
                and tag == getattr(self, "main_tag", None) and len(self.stack) + 1 == self.main_depth:
            self.main_end = len(self.out)
        if tag == "a" and self.href is not None:
            text = " ".join("".join(self.link_text).split())
            href, self.href = self.href, None
            self.out.append(f"[{text}]({href})" if text else "")
        elif tag in ("ul", "ol"):
            self.list_depth = max(self.list_depth - 1, 0)
            self.out.append("\n")
        elif tag == "pre":
            self.in_pre = max(self.in_pre - 1, 0)
            self.out.append("\n```\n\n")
        elif tag == "code" and not self.in_pre:
            self._emit("`")
        elif tag in ("strong", "b"):
            self._emit("**")
        elif tag in ("em", "i"):
            self._emit("*")
        elif re.fullmatch(r"h[1-6]", tag) or tag in BLOCK_TAGS:
            self.out.append("\n\n" if tag != "tr" else "\n")

    def handle_data(self, data):
        if self.in_title:
            self.title += data
            return
        if self._skipping():
            return
        if self.in_pre:
            self.out.append(data)
            return
        text = re.sub(r"\s+", " ", data)
        if text.strip() or (self.out and not self.out[-1].endswith((" ", "\n"))):
            self._emit(text)


def _tidy(parts: list[str]) -> str:
    text = "".join(parts)
    lines = [line.rstrip() for line in text.splitlines()]
    text = "\n".join(line if line.strip() not in ("-", "|", "**", "*") else "" for line in lines)
    text = re.sub(r"\n{3,}", "\n\n", text)
    return unescape(text).strip()


def html_to_markdown(html: str, base_url: str, *, full: bool = False) -> tuple[str, str]:
    """Return (title, markdown). `full` keeps navigation, header and footer."""
    parser = _Converter(base_url, keep_chrome=full)
    parser.feed(html)
    parser.close()
    parts = parser.out
    if not full and parser.main_start is not None:
        main = parts[parser.main_start:parser.main_end]
        # A tiny <main> is usually a wrapper fragment; the whole body is safer then.
        if len(_tidy(main)) >= MIN_TEXT_CHARS:
            parts = main
    title = " ".join((parser.og_title or parser.title).split())
    return title, _tidy(parts)


def visible_text_length(markdown: str) -> int:
    text = re.sub(r"\]\([^)]*\)", "]", markdown)
    return len(re.sub(r"[#*`|\[\]\-\s]+", "", text))


def looks_like_js_shell(html: str, markdown: str) -> bool:
    """True when the static HTML carries too little text: a browser has to render it."""
    text = visible_text_length(markdown)
    if text < 50:
        return True
    lowered = html[:500000].lower()
    if text < MIN_TEXT_CHARS:
        # A short page is genuine when it is short HTML too; scripts or bulk around little text mean an app shell.
        return lowered.count("<script") >= 3 or len(html) > 50 * text
    return "enable javascript" in lowered and text < 2 * MIN_TEXT_CHARS


def _fold(text: str) -> str:
    return unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode().lower()


def filter_by_query(markdown: str, query: str) -> str:
    """Keep the blocks mentioning a query term, with their nearest heading; everything when none match."""
    terms = {term for term in re.findall(r"\w{3,}", _fold(query))}
    if not terms:
        return markdown
    blocks = [block for block in re.split(r"\n{2,}", markdown) if block.strip()]
    kept: list[str] = []
    heading = None
    for block in blocks:
        if block.lstrip().startswith("#"):
            heading = block
            continue
        if terms & set(re.findall(r"\w{3,}", _fold(block))):
            if heading:
                kept.append(heading)
                heading = None
            kept.append(block)
    return "\n\n".join(kept) if kept else markdown
