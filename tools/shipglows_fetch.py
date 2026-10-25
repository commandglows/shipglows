#!/usr/bin/env python3
"""Read public pages as Markdown with provider fallback: plain HTTP, local Crawl4AI, Firecrawl, then Parallel.

Plain HTTP reads static HTML without a browser in a fraction of a second; a
JavaScript app shell, an HTTP error or a non-HTML answer moves the URL to the
Crawl4AI browser. Each URL goes through the cascade on its own; a stopped
local stack, a missing key, exhausted credits, a network error or an empty page
moves to the next provider. Exit 3 means at least one URL failed every
provider: use the agent's native fetch for it.
"""

from __future__ import annotations

import argparse
from concurrent.futures import ThreadPoolExecutor
import json
import os
import sys
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from shipglows_html import filter_by_query, html_to_markdown, looks_like_js_shell  # noqa: E402
from shipglows_http import ProviderError, resolve_timeout, safe_message, send_json  # noqa: E402
from shipglows_parallel import ParallelError, normalize_public_url, request_extract  # noqa: E402
from shipglows_scraping import CRAWL4AI_URL, crawl4ai_token  # noqa: E402

FIRECRAWL_SCRAPE_URL = "https://api.firecrawl.dev/v2/scrape"
PROVIDERS = ("http", "crawl4ai", "firecrawl", "parallel")
HTTP_ENV = "SHIPGLOWS_FETCH_HTTP"
HTTP_MAX_TIMEOUT = 15.0
HTTP_MAX_BYTES = 5_000_000
HTTP_USER_AGENT = "Mozilla/5.0 (compatible; ShipGlows-fetch/1.0)"
# /crawl returns each page's raw and cleaned HTML next to the Markdown; the loopback service is trusted.
CRAWL4AI_MAX_BYTES = 64 * 1024 * 1024
EXIT_ALL_FAILED = 3
TIMEOUT_ENV = "SHIPGLOWS_FETCH_TIMEOUT"
DEFAULT_TIMEOUT = 60.0
DEFAULT_MAX_CHARS = 40000


class ProviderSkipped(RuntimeError):
    """The provider cannot serve this request; try the next one."""


def require_markdown(provider: str, markdown: object) -> str:
    if not isinstance(markdown, str) or not markdown.strip():
        raise ProviderError(f"{provider} returned an empty page.")
    return markdown


def fetch_http(url: str, args: argparse.Namespace, opener=None) -> dict:
    if os.environ.get(HTTP_ENV, "").strip().lower() == "off":
        raise ProviderSkipped(f"{HTTP_ENV} is off")
    request = Request(url, headers={"User-Agent": HTTP_USER_AGENT, "Accept": "text/html,application/xhtml+xml"})
    try:
        with (opener or urlopen)(request, timeout=min(args.timeout, HTTP_MAX_TIMEOUT)) as response:
            headers = getattr(response, "headers", None)
            content_type = headers.get("Content-Type", "") if headers is not None else "text/html"
            if "html" not in content_type.lower():
                raise ProviderSkipped(f"not an HTML page ({content_type.split(';')[0] or 'unknown type'})")
            charset = headers.get_content_charset() if headers is not None and hasattr(headers, "get_content_charset") else None
            html = response.read(HTTP_MAX_BYTES).decode(charset or "utf-8", "replace")
    except HTTPError as error:
        raise ProviderError(f"HTTP {error.code}") from None
    except (URLError, TimeoutError, OSError, LookupError) as error:
        raise ProviderError(f"network error ({type(error).__name__})") from None
    title, markdown = html_to_markdown(html, url, full=args.full)
    if looks_like_js_shell(html, markdown):
        raise ProviderError("the static HTML is a JavaScript shell; a browser must render it")
    if args.query and not args.full:
        markdown = filter_by_query(markdown, args.query)
    return {"title": title, "markdown": require_markdown("HTTP", markdown)}


def fetch_http_all(urls: list[str], args: argparse.Namespace, opener=None) -> dict:
    """Read every URL over plain HTTP in parallel; map each URL to a page or the exception to report."""
    def attempt(url):
        try:
            return fetch_http(url, args, opener=opener)
        except (ProviderError, ProviderSkipped) as error:
            return error
    with ThreadPoolExecutor(max_workers=min(8, len(urls))) as pool:
        return dict(zip(urls, pool.map(attempt, urls)))


def crawl4ai_payload(urls: list[str], args: argparse.Namespace) -> dict:
    params = {
        "cache_mode": "bypass",
        "remove_overlay_elements": True,
        # Leave headroom under the HTTP timeout so a slow page reports its own error.
        "page_timeout": int(max(args.timeout - 5, 5) * 1000),
    }
    if not args.full:
        params["excluded_tags"] = ["nav", "footer", "header", "aside"]
        content_filter = ({"type": "BM25ContentFilter", "params": {"user_query": args.query}} if args.query
                          else {"type": "PruningContentFilter", "params": {}})
        params["markdown_generator"] = {"type": "DefaultMarkdownGenerator", "params": {"content_filter": content_filter}}
    return {"urls": urls, "crawler_config": {"type": "CrawlerRunConfig", "params": params}}


def crawl4ai_page(item: dict, args: argparse.Namespace, token: str) -> dict:
    status = item.get("status_code")
    if item.get("success") is False or (isinstance(status, int) and status >= 400):
        reason = safe_message(item.get("error_message") or "unknown error", token)
        raise ProviderError(f"Crawl4AI could not read the page (HTTP {status}): {reason}")
    markdown = item.get("markdown") if isinstance(item.get("markdown"), dict) else {}
    raw = markdown.get("raw_markdown")
    fit = markdown.get("fit_markdown")
    # A query filter can drop everything on an off-topic page; the whole page beats nothing.
    text = raw if args.full or not isinstance(fit, str) or not fit.strip() else fit
    metadata = item.get("metadata") if isinstance(item.get("metadata"), dict) else {}
    title = metadata.get("title")
    return {"title": title if isinstance(title, str) else "", "markdown": require_markdown("Crawl4AI", text)}


def crawl4ai_batch(urls: list[str], args: argparse.Namespace, opener=None) -> dict:
    """Read every URL in one /crawl call; map each URL to a page or the exception to report."""
    if CRAWL4AI_URL.lower().endswith("off"):
        return dict.fromkeys(urls, ProviderSkipped("SHIPGLOWS_CRAWL4AI_URL is off"))
    token = crawl4ai_token()
    if not token:
        return dict.fromkeys(urls, ProviderSkipped("no Crawl4AI token; run `shipglows-scraping up`"))
    request = Request(
        f"{CRAWL4AI_URL}/crawl",
        data=json.dumps(crawl4ai_payload(urls, args)).encode("utf-8"),
        headers={"Accept": "application/json", "Content-Type": "application/json", "Authorization": f"Bearer {token}"},
        method="POST",
    )
    try:
        # The local stack is either up or not: one attempt, then the paid providers.
        data = send_json(request, provider="Crawl4AI", secret=token, timeout=args.timeout + 10 * (len(urls) - 1),
                         opener=opener, retry=False, max_bytes=CRAWL4AI_MAX_BYTES,
                         http_error=lambda code, body: f"Crawl4AI HTTP {code}: "
                                                       f"{safe_message(body[:200].decode('utf-8', 'replace'), token)}")
    except ProviderError as error:
        return dict.fromkeys(urls, error)
    items = {item.get("url"): item for item in data.get("results") or [] if isinstance(item, dict)}
    pages: dict = {}
    for url in urls:
        item = items.get(url) or items.get(url.rstrip("/")) or items.get(url + "/")
        try:
            pages[url] = crawl4ai_page(item, args, token) if item else ProviderError("Crawl4AI returned no result for this URL.")
        except ProviderError as error:
            pages[url] = error
    return pages


def fetch_firecrawl(url: str, args: argparse.Namespace, opener=None) -> dict:
    api_key = os.environ.get("FIRECRAWL_API_KEY", "").strip()
    if not api_key:
        raise ProviderSkipped("FIRECRAWL_API_KEY is not set")
    request = Request(
        FIRECRAWL_SCRAPE_URL,
        data=json.dumps({"url": url, "formats": ["markdown"], "onlyMainContent": not args.full}).encode("utf-8"),
        headers={"Accept": "application/json", "Content-Type": "application/json", "Authorization": f"Bearer {api_key}"},
        method="POST",
    )
    data = send_json(request, provider="Firecrawl", secret=api_key, timeout=args.timeout, opener=opener,
                     http_error=lambda code, _body: {402: "Firecrawl HTTP 402: credits exhausted",
                                                     429: "Firecrawl HTTP 429: rate limited"}.get(code, f"Firecrawl HTTP {code}"))
    page = data.get("data") if isinstance(data.get("data"), dict) else {}
    metadata = page.get("metadata") if isinstance(page.get("metadata"), dict) else {}
    title = metadata.get("title")
    return {"title": title if isinstance(title, str) else "", "markdown": require_markdown("Firecrawl", page.get("markdown"))}


def fetch_parallel(url: str, args: argparse.Namespace, opener=None) -> dict:
    if not os.environ.get("PARALLEL_API_KEY", "").strip():
        raise ProviderSkipped("PARALLEL_API_KEY is not set")
    try:
        data = request_extract(argparse.Namespace(url=[url], objective=args.query, full_content=True, timeout=args.timeout),
                               opener=opener)
    except ParallelError as error:
        raise ProviderError(str(error)) from None
    if not data["results"]:
        reason = data["errors"][0] if data["errors"] else "no result"
        raise ProviderError(f"Parallel could not read the page: {safe_message(reason, '')}")
    item = data["results"][0]
    return {"title": item["title"], "markdown": require_markdown("Parallel", item["full_content"] or "\n\n".join(item["excerpts"]))}


FETCHERS = {"firecrawl": fetch_firecrawl, "parallel": fetch_parallel}


def fetch_one(url: str, args: argparse.Namespace, local: dict, opener=None) -> dict:
    """`local` maps each local provider (http, crawl4ai) to its precomputed {url: page or exception}."""
    attempts = []
    for provider in (PROVIDERS if args.provider == "auto" else (args.provider,)):
        try:
            if provider in local:
                page = local[provider].get(url, ProviderSkipped("not attempted"))
                if isinstance(page, Exception):
                    raise page
            else:
                page = FETCHERS[provider](url, args, opener=opener)
        except ProviderSkipped as reason:
            attempts.append({"provider": provider, "status": "skipped", "reason": str(reason)})
            continue
        except ProviderError as error:
            attempts.append({"provider": provider, "status": "failed", "reason": str(error)})
            continue
        attempts.append({"provider": provider, "status": "ok"})
        markdown = page["markdown"]
        truncated = bool(args.max_chars) and len(markdown) > args.max_chars
        return {"url": url, "provider": provider, "attempts": attempts, "title": page["title"],
                "truncated": truncated, "markdown": markdown[:args.max_chars] if truncated else markdown}
    return {"url": url, "provider": None, "attempts": attempts, "error": "every provider failed"}


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="shipglows-fetch",
        description="Read public pages as Markdown: plain HTTP first, then the local Crawl4AI browser, then Firecrawl and Parallel. "
        "Exit 3 means a URL failed every provider: use the agent's native fetch for it.")
    parser.add_argument("url", nargs="+", metavar="URL", help="public http(s) URL; up to ten")
    parser.add_argument("--provider", choices=("auto", *PROVIDERS), default="auto",
                        help="auto tries HTTP, Crawl4AI, Firecrawl then Parallel (default); naming one disables fallback")
    parser.add_argument("--full", action="store_true", help="whole page instead of the main content")
    parser.add_argument("--query", help="keep the passages relevant to this query (term filter over HTTP, Crawl4AI BM25, Parallel objective)")
    parser.add_argument("--max-chars", type=int, default=DEFAULT_MAX_CHARS,
                        help=f"truncate each page's Markdown (default {DEFAULT_MAX_CHARS}; 0 keeps everything)")
    parser.add_argument("--timeout", type=float,
                        help=f"per-attempt network timeout in seconds (default: ${TIMEOUT_ENV}, else 60)")
    return parser


def main(argv: list[str] | None = None, opener=None) -> int:
    args = build_parser().parse_args(argv)
    # Page Markdown is arbitrary Unicode; a cp1252 Windows console must not crash the output.
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")
    try:
        if len(args.url) > 10:
            raise ProviderError("Fetch at most ten URLs per call.")
        if args.max_chars < 0:
            raise ProviderError("--max-chars must be 0 or more.")
        urls = [normalize_public_url(url) for url in args.url]
        args.timeout = resolve_timeout(args.timeout, DEFAULT_TIMEOUT, TIMEOUT_ENV)
    except (ProviderError, argparse.ArgumentTypeError) as error:
        print(f"shipglows-fetch: {error}", file=sys.stderr)
        return 2
    urls = list(dict.fromkeys(urls))
    local: dict = {}
    if args.provider in ("auto", "http"):
        local["http"] = fetch_http_all(urls, args, opener=opener)
    if args.provider in ("auto", "crawl4ai"):
        # Only the pages plain HTTP could not read pay for a browser.
        pending = [url for url in urls if isinstance(local.get("http", {}).get(url, ProviderError("")), Exception)]
        local["crawl4ai"] = crawl4ai_batch(pending, args, opener=opener) if pending else {}
    pages = [fetch_one(url, args, local, opener=opener) for url in urls]
    print(json.dumps({"pages": pages}, ensure_ascii=False, indent=2))
    failed = [page for page in pages if page["provider"] is None]
    for page in failed:
        for attempt in page["attempts"]:
            print(f"shipglows-fetch: {page['url']}: {attempt['provider']} {attempt['status']}: {attempt['reason']}", file=sys.stderr)
    return EXIT_ALL_FAILED if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
