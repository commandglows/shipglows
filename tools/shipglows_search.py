#!/usr/bin/env python3
"""Read-only web search with provider fallback: Firecrawl, then Parallel.

Each provider is tried in order; a missing key, exhausted credits, a rate
limit, a network error or an unsupported filter moves to the next one. When
every provider fails the command exits 3 so the calling agent falls back to
its own native web search instead of stopping.
"""

from __future__ import annotations

import argparse
from datetime import date
import json
import os
import re
import sys
from urllib.error import HTTPError, URLError
from urllib.request import Request

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from shipglows_parallel import (  # noqa: E402
    MAX_RESPONSE_BYTES,
    ParallelError,
    _open_once,
    normalize_domain,
    request_search,
    safe_message,
)

FIRECRAWL_SEARCH_URL = "https://api.firecrawl.dev/v2/search"
PROVIDERS = ("firecrawl", "parallel")
EXIT_ALL_FAILED = 3


class ProviderSkipped(RuntimeError):
    """The provider cannot serve this request; try the next one."""


def firecrawl_query(query: str, args: argparse.Namespace) -> str:
    if args.include_domain:
        return f"{query} ({' OR '.join(f'site:{domain}' for domain in args.include_domain)})"
    if args.exclude_domain:
        return " ".join([query, *(f"-site:{domain}" for domain in args.exclude_domain)])
    return query


def firecrawl_error(code: int, body: bytes, api_key: str) -> str:
    if code == 402:
        return "Firecrawl HTTP 402: credits exhausted"
    if code == 429:
        return "Firecrawl HTTP 429: rate limited"
    try:
        value = json.loads(body.decode("utf-8"))
        if isinstance(value, dict) and value.get("error"):
            return f"Firecrawl HTTP {code}: {safe_message(value['error'], api_key)}"
    except (UnicodeDecodeError, json.JSONDecodeError):
        pass
    return f"Firecrawl HTTP {code}"


def search_firecrawl(args: argparse.Namespace, queries: list[str], opener=None) -> list[dict]:
    api_key = os.environ.get("FIRECRAWL_API_KEY", "").strip()
    if not api_key:
        raise ProviderSkipped("FIRECRAWL_API_KEY is not set")
    if args.location:
        raise ProviderSkipped("--location is not supported by Firecrawl")
    results: list[dict] = []
    seen: set[str] = set()
    for query in queries:
        payload = {"query": firecrawl_query(query, args), "limit": min(args.max_results or 10, 100), "sources": ["web"]}
        if args.after_date:
            day = date.fromisoformat(args.after_date)
            payload["tbs"] = f"cdr:1,cd_min:{day.month}/{day.day}/{day.year}"
        request = Request(
            FIRECRAWL_SEARCH_URL,
            data=json.dumps(payload, ensure_ascii=False).encode("utf-8"),
            headers={"Accept": "application/json", "Content-Type": "application/json", "Authorization": f"Bearer {api_key}"},
            method="POST",
        )
        try:
            with (opener or _open_once)(request, timeout=30) as response:
                body = response.read(MAX_RESPONSE_BYTES + 1)
        except HTTPError as error:
            try:
                error_body = error.read(MAX_RESPONSE_BYTES + 1)
            finally:
                error.close()
            raise ParallelError(firecrawl_error(error.code, error_body, api_key)) from None
        except (URLError, TimeoutError, OSError) as error:
            raise ParallelError(f"Firecrawl network request failed ({type(error).__name__}).") from None
        if len(body) > MAX_RESPONSE_BYTES:
            raise ParallelError("Firecrawl response exceeded the 4 MiB safety limit.")
        try:
            data = json.loads(body.decode("utf-8"))
        except (UnicodeDecodeError, json.JSONDecodeError):
            raise ParallelError("Firecrawl returned invalid JSON.") from None
        if not isinstance(data, dict) or data.get("success") is False:
            raise ParallelError(f"Firecrawl request failed: {safe_message(data.get('error', 'unknown error') if isinstance(data, dict) else 'unexpected format', api_key)}")
        raw = data.get("data")
        items = raw.get("web") if isinstance(raw, dict) else raw
        if not isinstance(items, list):
            raise ParallelError("Firecrawl response did not contain a results list.")
        for item in items:
            url = item.get("url") if isinstance(item, dict) else None
            if not isinstance(url, str) or not url.startswith(("https://", "http://")) or url in seen:
                continue
            seen.add(url)
            description = item.get("description")
            results.append({
                "position": len(results) + 1,
                "title": item.get("title") if isinstance(item.get("title"), str) else "",
                "url": url,
                "publish_date": None,
                "excerpts": [description] if isinstance(description, str) and description else [],
            })
    return results


def search_parallel(args: argparse.Namespace, queries: list[str], opener=None) -> list[dict]:
    if not os.environ.get("PARALLEL_API_KEY", "").strip():
        raise ProviderSkipped("PARALLEL_API_KEY is not set")
    parallel_args = argparse.Namespace(
        terms=[], query=queries, objective=args.objective, mode="fast", domain=None,
        include_domain=args.include_domain, exclude_domain=args.exclude_domain,
        after_date=args.after_date, location=args.location, max_results=args.max_results,
    )
    results = request_search(parallel_args, opener=opener)["results"]
    for result in results:
        result.pop("matches_domain", None)
    return results


SEARCHERS = {"firecrawl": search_firecrawl, "parallel": search_parallel}


def validate(args: argparse.Namespace) -> list[str]:
    queries = [query.strip() for query in [*args.terms, *(args.query or [])]]
    if not queries or any(not query for query in queries):
        raise ParallelError("At least one non-empty query is required (positional or --query).")
    if len(queries) > 5 or any(len(query) > 200 for query in queries):
        raise ParallelError("Use at most five queries of at most 200 characters each.")
    if len(args.include_domain or args.exclude_domain or []) > 10:
        raise ParallelError("At most ten source domains may be set per request.")
    if args.after_date:
        try:
            if not re.fullmatch(r"\d{4}-\d{2}-\d{2}", args.after_date):
                raise ValueError
            date.fromisoformat(args.after_date)
        except ValueError:
            raise ParallelError("--after-date must use YYYY-MM-DD.") from None
    if args.location and not re.fullmatch(r"[A-Za-z]{2}", args.location):
        raise ParallelError("--location must be a two-letter ISO country code.")
    if args.max_results is not None and args.max_results < 1:
        raise ParallelError("--max-results must be a positive integer.")
    return queries


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Search the web through Firecrawl, falling back to Parallel. Exit 3 means every provider "
        "failed: use the agent's native web search.")
    parser.add_argument("terms", nargs="*", metavar="QUERY", help="keyword query (same as --query)")
    parser.add_argument("--query", action="append", help="keyword query; repeat up to five times")
    parser.add_argument("--objective", help="natural-language research objective (used by Parallel)")
    parser.add_argument("--provider", choices=("auto", *PROVIDERS), default="auto",
                        help="auto tries Firecrawl then Parallel (default); naming one disables fallback")
    policy = parser.add_mutually_exclusive_group()
    policy.add_argument("--include-domain", action="append", type=normalize_domain, help="restrict sources to this domain")
    policy.add_argument("--exclude-domain", action="append", type=normalize_domain, help="exclude this source domain")
    parser.add_argument("--after-date", help="only pages published on or after YYYY-MM-DD")
    parser.add_argument("--location", help="two-letter country code (Parallel only)")
    parser.add_argument("--max-results", type=int, help="maximum number of results per query")
    return parser


def main(argv: list[str] | None = None, opener=None) -> int:
    args = build_parser().parse_args(argv)
    try:
        queries = validate(args)
    except ParallelError as error:
        print(f"shipglows-search: {error}", file=sys.stderr)
        return 2
    attempts = []
    for provider in (PROVIDERS if args.provider == "auto" else (args.provider,)):
        try:
            results = SEARCHERS[provider](args, queries, opener=opener)
        except ProviderSkipped as reason:
            attempts.append({"provider": provider, "status": "skipped", "reason": str(reason)})
            continue
        except ParallelError as error:
            attempts.append({"provider": provider, "status": "failed", "reason": str(error)})
            continue
        attempts.append({"provider": provider, "status": "ok"})
        print(json.dumps({
            "provider": provider,
            "attempts": attempts,
            "search_queries": queries,
            "result_order": f"{provider} relevance order; not a Google SERP position.",
            "results": results,
        }, ensure_ascii=True, indent=2))
        return 0
    for attempt in attempts:
        print(f"shipglows-search: {attempt['provider']} {attempt['status']}: {attempt['reason']}", file=sys.stderr)
    print("shipglows-search: all providers failed; use the agent's native web search (WebSearch/WebFetch).", file=sys.stderr)
    return EXIT_ALL_FAILED


if __name__ == "__main__":
    raise SystemExit(main())
