#!/usr/bin/env python3
"""Read-only web search with provider fallback: local SearXNG, DeepSeek, Firecrawl, then Parallel.

DeepSeek comes first among the paid providers: $0.75 per 1,000 successful
requests, and empty results are not billed.

Each provider is tried in order; a stopped local service, a missing key,
exhausted credits, a rate limit, a network error, an empty result set or an
unsupported filter moves to the next one. When
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
from urllib.parse import urlencode
from urllib.request import Request

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from shipglows_http import (  # noqa: E402
    GATEWAY_HTTP_CODES,
    RETRYABLE_HTTP_CODES,
    ProviderError,
    resolve_timeout,
    safe_message,
    send_json,
)
from shipglows_parallel import normalize_domain, request_search  # noqa: E402

FIRECRAWL_SEARCH_URL = "https://api.firecrawl.dev/v2/search"
DEEPSEEK_SEARCH_URL = "https://api.deepseek.com/v1/tools/search"
DEEPSEEK_MAX_QUERY = 128
SEARXNG_URL_ENV = "SHIPGLOWS_SEARXNG_URL"
DEFAULT_SEARXNG_URL = "http://127.0.0.1:8888"
SEARXNG_MAX_TIMEOUT = 15.0
PROVIDERS = ("searxng", "deepseek", "firecrawl", "parallel")
EXIT_ALL_FAILED = 3
TIMEOUT_ENV = "SHIPGLOWS_SEARCH_TIMEOUT"
DEFAULT_TIMEOUT = 30.0


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


def deepseek_error(code: int, body: bytes, api_key: str) -> str:
    if code == 402:
        return "DeepSeek HTTP 402: insufficient balance"
    if code == 429:
        return "DeepSeek HTTP 429: rate limited"
    try:
        value = json.loads(body.decode("utf-8"))
        error = value.get("error") if isinstance(value, dict) else None
        if isinstance(error, dict) and error.get("message"):
            return f"DeepSeek HTTP {code}: {safe_message(error['message'], api_key)}"
    except (UnicodeDecodeError, json.JSONDecodeError):
        pass
    return f"DeepSeek HTTP {code}"


def search_searxng(args: argparse.Namespace, queries: list[str], opener=None) -> list[dict]:
    base_url = os.environ.get(SEARXNG_URL_ENV, DEFAULT_SEARXNG_URL).strip().rstrip("/")
    if not base_url or base_url.lower() == "off":
        raise ProviderSkipped(f"{SEARXNG_URL_ENV} is off")
    if args.after_date:
        raise ProviderSkipped("--after-date is not supported by SearXNG")
    if args.location:
        raise ProviderSkipped("--location is not supported by SearXNG")
    # A stopped local service fails fast and is not worth retrying: the paid providers are next.
    timeout = min(args.timeout, SEARXNG_MAX_TIMEOUT)
    results: list[dict] = []
    seen: set[str] = set()
    for query in queries:
        request = Request(
            f"{base_url}/search?{urlencode({'q': firecrawl_query(query, args), 'format': 'json'})}",
            headers={"Accept": "application/json"},
        )
        data = send_json(
            request, provider="SearXNG", secret="", timeout=timeout, opener=opener, retry=False,
            http_error=lambda code, _body: f"SearXNG HTTP {code}",
        )
        items = data.get("results")
        if not isinstance(items, list):
            raise ProviderError("SearXNG response did not contain a results list.")
        kept = 0
        for item in items:
            url = item.get("url") if isinstance(item, dict) else None
            if not isinstance(url, str) or not url.startswith(("https://", "http://")) or url in seen:
                continue
            if args.max_results and kept >= args.max_results:
                break
            seen.add(url)
            kept += 1
            content = item.get("content")
            published = item.get("publishedDate")
            results.append({
                "position": len(results) + 1,
                "title": item.get("title") if isinstance(item.get("title"), str) else "",
                "url": url,
                "publish_date": published[:10] if isinstance(published, str) and published else None,
                "excerpts": [content] if isinstance(content, str) and content else [],
            })
    if not results:
        raise ProviderError("SearXNG returned no results (its upstream engines may be blocked).")
    return results


def search_deepseek(args: argparse.Namespace, queries: list[str], opener=None) -> list[dict]:
    api_key = os.environ.get("DEEPSEEK_API_KEY", "").strip()
    if not api_key:
        raise ProviderSkipped("DEEPSEEK_API_KEY is not set")
    if args.location:
        raise ProviderSkipped("--location is not supported by DeepSeek")
    full_queries = [firecrawl_query(query, args) + (f" after:{args.after_date}" if args.after_date else "")
                    for query in queries]
    if any(len(query) > DEEPSEEK_MAX_QUERY for query in full_queries):
        raise ProviderSkipped(f"DeepSeek queries are limited to {DEEPSEEK_MAX_QUERY} characters")
    retry_codes = GATEWAY_HTTP_CODES if args.provider == "auto" else RETRYABLE_HTTP_CODES
    results: list[dict] = []
    seen: set[str] = set()
    for query in full_queries:
        payload = {"query": query, "count": min(args.max_results or 10, 50)}
        if args.objective:
            payload["ori_question"] = args.objective[:DEEPSEEK_MAX_QUERY]
        request = Request(
            DEEPSEEK_SEARCH_URL,
            data=json.dumps(payload, ensure_ascii=False).encode("utf-8"),
            headers={"Accept": "application/json", "Content-Type": "application/json", "Authorization": f"Bearer {api_key}"},
            method="POST",
        )
        data = send_json(
            request, provider="DeepSeek", secret=api_key, timeout=args.timeout, opener=opener,
            retry_codes=retry_codes, http_error=lambda code, body: deepseek_error(code, body, api_key),
        )
        items = data.get("results")
        if not isinstance(items, list):
            raise ProviderError("DeepSeek response did not contain a results list.")
        for item in items:
            url = item.get("url") if isinstance(item, dict) else None
            if not isinstance(url, str) or not url.startswith(("https://", "http://")) or url in seen:
                continue
            seen.add(url)
            excerpt = item.get("summary") or item.get("snippet")
            published = item.get("date")
            results.append({
                "position": len(results) + 1,
                "title": item.get("title") if isinstance(item.get("title"), str) else "",
                "url": url,
                "publish_date": published[:10] if isinstance(published, str) and published else None,
                "excerpts": [excerpt] if isinstance(excerpt, str) and excerpt else [],
            })
    if not results:
        raise ProviderError("DeepSeek returned no results.")
    return results


def search_firecrawl(args: argparse.Namespace, queries: list[str], opener=None) -> list[dict]:
    api_key = os.environ.get("FIRECRAWL_API_KEY", "").strip()
    if not api_key:
        raise ProviderSkipped("FIRECRAWL_API_KEY is not set")
    if args.location:
        raise ProviderSkipped("--location is not supported by Firecrawl")
    # With a fallback provider waiting, credits (402) and rate limits (429) move on at once;
    # only gateway errors and network failures are worth retrying here.
    retry_codes = GATEWAY_HTTP_CODES if args.provider == "auto" else RETRYABLE_HTTP_CODES
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
        data = send_json(
            request, provider="Firecrawl", secret=api_key, timeout=args.timeout, opener=opener,
            retry_codes=retry_codes, http_error=lambda code, body: firecrawl_error(code, body, api_key),
        )
        if data.get("success") is False:
            raise ProviderError(f"Firecrawl request failed: {safe_message(data.get('error', 'unknown error'), api_key)}")
        raw = data.get("data")
        items = raw.get("web") if isinstance(raw, dict) else raw
        if not isinstance(items, list):
            raise ProviderError("Firecrawl response did not contain a results list.")
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
        after_date=args.after_date, location=args.location, max_results=args.max_results, timeout=args.timeout,
    )
    results = request_search(parallel_args, opener=opener)["results"]
    for result in results:
        result.pop("matches_domain", None)
    return results


SEARCHERS = {"searxng": search_searxng, "deepseek": search_deepseek, "firecrawl": search_firecrawl,
             "parallel": search_parallel}


def validate(args: argparse.Namespace) -> list[str]:
    queries = [query.strip() for query in [*args.terms, *(args.query or [])]]
    if not queries or any(not query for query in queries):
        raise ProviderError("At least one non-empty query is required (positional or --query).")
    if len(queries) > 5 or any(len(query) > 200 for query in queries):
        raise ProviderError("Use at most five queries of at most 200 characters each.")
    if len(args.include_domain or args.exclude_domain or []) > 10:
        raise ProviderError("At most ten source domains may be set per request.")
    if args.after_date:
        try:
            if not re.fullmatch(r"\d{4}-\d{2}-\d{2}", args.after_date):
                raise ValueError
            date.fromisoformat(args.after_date)
        except ValueError:
            raise ProviderError("--after-date must use YYYY-MM-DD.") from None
    if args.location and not re.fullmatch(r"[A-Za-z]{2}", args.location):
        raise ProviderError("--location must be a two-letter ISO country code.")
    if args.max_results is not None and args.max_results < 1:
        raise ProviderError("--max-results must be a positive integer.")
    args.timeout = resolve_timeout(args.timeout, DEFAULT_TIMEOUT, TIMEOUT_ENV)
    return queries


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Search the web through local SearXNG, falling back to DeepSeek, Firecrawl then Parallel. Exit 3 means "
        "every provider failed: use the agent's native web search.")
    parser.add_argument("terms", nargs="*", metavar="QUERY", help="keyword query (same as --query)")
    parser.add_argument("--query", action="append", help="keyword query; repeat up to five times")
    parser.add_argument("--objective", help="natural-language research objective (used by DeepSeek and Parallel)")
    parser.add_argument("--provider", choices=("auto", *PROVIDERS), default="auto",
                        help="auto tries SearXNG, DeepSeek, Firecrawl then Parallel (default); naming one disables fallback")
    policy = parser.add_mutually_exclusive_group()
    policy.add_argument("--include-domain", action="append", type=normalize_domain, help="restrict sources to this domain")
    policy.add_argument("--exclude-domain", action="append", type=normalize_domain, help="exclude this source domain")
    parser.add_argument("--after-date", help="only pages published on or after YYYY-MM-DD")
    parser.add_argument("--location", help="two-letter country code (Parallel only)")
    parser.add_argument("--max-results", type=int, help="maximum number of results per query")
    parser.add_argument("--timeout", type=float,
                        help=f"per-attempt network timeout in seconds for every provider (default: ${TIMEOUT_ENV}, else 30)")
    return parser


def main(argv: list[str] | None = None, opener=None) -> int:
    args = build_parser().parse_args(argv)
    try:
        queries = validate(args)
    except ProviderError as error:
        print(f"shipglows-search: {error}", file=sys.stderr)
        return 2
    attempts = []
    for provider in (PROVIDERS if args.provider == "auto" else (args.provider,)):
        try:
            results = SEARCHERS[provider](args, queries, opener=opener)
        except ProviderSkipped as reason:
            attempts.append({"provider": provider, "status": "skipped", "reason": str(reason)})
            continue
        except ProviderError as error:
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
