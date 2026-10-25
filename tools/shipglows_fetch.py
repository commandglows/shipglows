#!/usr/bin/env python3
"""Read public pages as Markdown with provider fallback: local Crawl4AI, Firecrawl, then Parallel.

Each URL goes through the cascade on its own; a stopped local stack, a missing
key, exhausted credits, a network error or an empty page moves to the next
provider. Exit 3 means at least one URL failed every provider: use the agent's
native fetch for it.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from urllib.request import Request

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from shipglows_http import ProviderError, resolve_timeout, safe_message, send_json  # noqa: E402
from shipglows_parallel import ParallelError, normalize_public_url, request_extract  # noqa: E402
from shipglows_scraping import CRAWL4AI_URL, crawl4ai_token  # noqa: E402

FIRECRAWL_SCRAPE_URL = "https://api.firecrawl.dev/v2/scrape"
PROVIDERS = ("crawl4ai", "firecrawl", "parallel")
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


def fetch_crawl4ai(url: str, args: argparse.Namespace, opener=None) -> dict:
    if CRAWL4AI_URL.lower().endswith("off"):
        raise ProviderSkipped("SHIPGLOWS_CRAWL4AI_URL is off")
    token = crawl4ai_token()
    if not token:
        raise ProviderSkipped("no Crawl4AI token; run `shipglows-scraping up`")
    request = Request(
        f"{CRAWL4AI_URL}/md",
        data=json.dumps({"url": url, "f": "raw" if args.full else "fit"}).encode("utf-8"),
        headers={"Accept": "application/json", "Content-Type": "application/json", "Authorization": f"Bearer {token}"},
        method="POST",
    )
    # The local stack is either up or not: one attempt, then the paid providers.
    data = send_json(request, provider="Crawl4AI", secret=token, timeout=args.timeout, opener=opener, retry=False,
                     http_error=lambda code, body: f"Crawl4AI HTTP {code}: {safe_message(body[:200].decode('utf-8', 'replace'), token)}")
    if data.get("success") is False:
        raise ProviderError(f"Crawl4AI could not read the page: {safe_message(data.get('error', 'unknown error'), token)}")
    return {"title": "", "markdown": require_markdown("Crawl4AI", data.get("markdown"))}


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
        data = request_extract(argparse.Namespace(url=[url], objective=None, full_content=True, timeout=args.timeout),
                               opener=opener)
    except ParallelError as error:
        raise ProviderError(str(error)) from None
    if not data["results"]:
        reason = data["errors"][0] if data["errors"] else "no result"
        raise ProviderError(f"Parallel could not read the page: {safe_message(reason, '')}")
    item = data["results"][0]
    return {"title": item["title"], "markdown": require_markdown("Parallel", item["full_content"] or "\n\n".join(item["excerpts"]))}


FETCHERS = {"crawl4ai": fetch_crawl4ai, "firecrawl": fetch_firecrawl, "parallel": fetch_parallel}


def fetch_one(url: str, args: argparse.Namespace, opener=None) -> dict:
    attempts = []
    for provider in (PROVIDERS if args.provider == "auto" else (args.provider,)):
        try:
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
        description="Read public pages as Markdown through local Crawl4AI, falling back to Firecrawl then Parallel. "
        "Exit 3 means a URL failed every provider: use the agent's native fetch for it.")
    parser.add_argument("url", nargs="+", metavar="URL", help="public http(s) URL; up to ten")
    parser.add_argument("--provider", choices=("auto", *PROVIDERS), default="auto",
                        help="auto tries Crawl4AI, Firecrawl then Parallel (default); naming one disables fallback")
    parser.add_argument("--full", action="store_true", help="whole page instead of the main content")
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
    pages = [fetch_one(url, args, opener=opener) for url in dict.fromkeys(urls)]
    print(json.dumps({"pages": pages}, ensure_ascii=False, indent=2))
    failed = [page for page in pages if page["provider"] is None]
    for page in failed:
        for attempt in page["attempts"]:
            print(f"shipglows-fetch: {page['url']}: {attempt['provider']} {attempt['status']}: {attempt['reason']}", file=sys.stderr)
    return EXIT_ALL_FAILED if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
