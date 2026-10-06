#!/usr/bin/env python3
"""Read-only, one-query Google SERP client for the SerpApi HTTP API."""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from urllib.error import HTTPError, URLError
from urllib.parse import quote, urlencode, urlsplit
from urllib.request import Request, urlopen

API_URL = "https://serpapi.com/search"
MAX_RESPONSE_BYTES = 4 * 1024 * 1024
COUNTRY_RE = re.compile(r"^[a-z]{2}$", re.IGNORECASE)
LANGUAGE_RE = re.compile(r"^[a-z]{2,3}(?:-(?:[a-z]{2}|[0-9]{3}))?$", re.IGNORECASE)


class SerpApiError(RuntimeError):
    """An actionable error safe to display in the terminal."""


def normalize_domain(value: str) -> str:
    """Validate a hostname input and normalize it for exact/subdomain matching."""
    host = value.strip().rstrip(".").lower()
    if not host or "://" in host or "/" in host or "@" in host or ":" in host:
        raise argparse.ArgumentTypeError("domain must be a hostname such as claiire.fr")
    try:
        host = host.encode("idna").decode("ascii")
    except UnicodeError as error:
        raise argparse.ArgumentTypeError("domain is not a valid hostname") from error
    if len(host) > 253 or "." not in host:
        raise argparse.ArgumentTypeError("domain must be a fully qualified hostname")
    labels = host.split(".")
    if any(not label or len(label) > 63 or not re.fullmatch(r"[a-z0-9](?:[a-z0-9-]*[a-z0-9])?", label) for label in labels):
        raise argparse.ArgumentTypeError("domain is not a valid hostname")
    return host


def country_code(value: str) -> str:
    value = value.strip()
    if not COUNTRY_RE.fullmatch(value):
        raise argparse.ArgumentTypeError("country must be a two-letter code such as fr")
    return value.lower()


def language_code(value: str) -> str:
    value = value.strip()
    if not LANGUAGE_RE.fullmatch(value):
        raise argparse.ArgumentTypeError("language must be a code such as fr or en-gb")
    return value.lower()


def matches_domain(link: str, target: str) -> bool:
    try:
        hostname = (urlsplit(link).hostname or "").rstrip(".").lower().encode("idna").decode("ascii")
    except (UnicodeError, ValueError):
        return False
    return hostname == target or hostname.endswith("." + target)


def safe_message(message: object, api_key: str) -> str:
    """Bound and redact provider text before it can reach terminal output."""
    text = str(message)
    if api_key:
        text = text.replace(api_key, "[REDACTED]").replace(quote(api_key, safe=""), "[REDACTED]")
    return " ".join(text.split())[:300]


def parse_api_error(body: bytes, api_key: str) -> str:
    try:
        value = json.loads(body.decode("utf-8"))
        if isinstance(value, dict):
            return safe_message(value.get("error", "SerpApi request failed"), api_key)
    except (UnicodeDecodeError, json.JSONDecodeError):
        pass
    return "SerpApi request failed"


def request_search(args: argparse.Namespace, opener=urlopen) -> dict:
    api_key = os.environ.get("SERPAPI_API_KEY", "").strip()
    if not api_key:
        raise SerpApiError("SERPAPI_API_KEY is not set; provide your key in the process environment.")
    query = args.query.strip()
    if not query:
        raise SerpApiError("Query must not be empty.")
    if len(query) > 512:
        raise SerpApiError("Query must be at most 512 characters.")
    location = args.location.strip() if args.location else ""
    if len(location) > 200:
        raise SerpApiError("Location must be at most 200 characters.")

    params = {
        "engine": "google",
        "q": query,
        "api_key": api_key,
        "gl": args.country,
        "hl": args.language,
        "device": args.device,
        "output": "json",
    }
    if location:
        params["location"] = location
    request = Request(
        f"{API_URL}?{urlencode(params)}",
        headers={"Accept": "application/json", "User-Agent": "ShipGlows-SerpCLI/1.0"},
    )

    try:
        with opener(request, timeout=30) as response:
            body = response.read(MAX_RESPONSE_BYTES + 1)
    except HTTPError as error:
        try:
            error_body = error.read(MAX_RESPONSE_BYTES + 1)
        finally:
            error.close()
        detail = parse_api_error(error_body, api_key)
        raise SerpApiError(f"SerpApi HTTP {error.code}: {detail}") from None
    except (URLError, TimeoutError, OSError) as error:
        # Never stringify network exceptions: they may contain the full URL/key.
        kind = "timed out" if isinstance(error, TimeoutError) else "network request failed"
        raise SerpApiError(f"SerpApi {kind}; no retry was attempted.") from None

    if len(body) > MAX_RESPONSE_BYTES:
        raise SerpApiError("SerpApi response is too large to process safely.")
    try:
        payload = json.loads(body.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as error:
        raise SerpApiError("SerpApi returned invalid JSON.") from error
    if not isinstance(payload, dict):
        raise SerpApiError("SerpApi returned an unexpected response shape.")

    metadata = payload.get("search_metadata")
    metadata = metadata if isinstance(metadata, dict) else {}
    provider_params = payload.get("search_parameters")
    provider_params = provider_params if isinstance(provider_params, dict) else {}
    resolved_location = provider_params.get("location_used")
    resolved_location = safe_message(resolved_location, api_key) if isinstance(resolved_location, str) else ""
    status = str(metadata.get("status", "")).lower()
    if payload.get("error") or status == "error":
        detail = payload.get("error") or "SerpApi reported an error"
        raise SerpApiError(f"SerpApi error: {safe_message(detail, api_key)}")
    if status and status != "success":
        raise SerpApiError(f"SerpApi search did not complete successfully (status: {safe_message(status, api_key)}).")

    organic = payload.get("organic_results", [])
    if not isinstance(organic, list):
        organic = []
    results = []
    for index, item in enumerate(organic, start=1):
        if not isinstance(item, dict):
            continue
        link = item.get("link") if isinstance(item.get("link"), str) else ""
        position = item.get("position")
        if not isinstance(position, int) or position < 1:
            position = index
        result = {
            "position": position,
            "title": safe_message(item.get("title", ""), api_key),
            "link": safe_message(link, api_key),
            "snippet": safe_message(item.get("snippet", ""), api_key),
        }
        if args.domain:
            result["matches_domain"] = bool(link and matches_domain(link, args.domain))
        results.append(result)

    target_matches = [item for item in results if item.get("matches_domain")] if args.domain else []
    safe_metadata = {}
    for key in ("id", "status", "created_at", "processed_at", "total_time_taken"):
        value = metadata.get(key)
        if isinstance(value, str):
            safe_metadata[key] = safe_message(value, api_key)
        elif isinstance(value, (int, float, bool)):
            safe_metadata[key] = value
    return {
        "source": "serpapi.google_search",
        "query": safe_message(query, api_key),
        "search_parameters": {
            "country": args.country,
            "language": args.language,
            "device": args.device,
            "location": location or None,
            "resolved_location": resolved_location or None,
        },
        "search_metadata": safe_metadata,
        "organic_results": results,
        "target_domain": args.domain,
        "target_matches": target_matches,
        "target_rank": min((item["position"] for item in target_matches), default=None),
    }


def parser() -> argparse.ArgumentParser:
    root = argparse.ArgumentParser(prog="shipglows-serp", description="One read-only localized Google SERP lookup via SerpApi")
    commands = root.add_subparsers(dest="command", required=True)
    search = commands.add_parser("search", help="query one Google SERP")
    search.add_argument("--query", "-q", required=True, help="search phrase to look up")
    search.add_argument("--country", "--gl", type=country_code, default="fr", help="Google country code (default: fr)")
    search.add_argument("--language", "--hl", type=language_code, default="fr", help="Google result language (default: fr)")
    search.add_argument("--device", choices=("desktop", "mobile", "tablet"), default="desktop")
    search.add_argument("--location", help="optional city-level location, e.g. Paris, France")
    search.add_argument("--domain", type=normalize_domain, help="optional target hostname for organic rank matches")
    search.set_defaults(handler=request_search)
    return root


def main(argv=None, opener=urlopen) -> int:
    args = parser().parse_args(argv)
    try:
        result = args.handler(args, opener=opener)
        print(json.dumps(result, ensure_ascii=False, indent=2, sort_keys=True))
        return 0
    except SerpApiError as error:
        print(f"shipglows-serp: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
