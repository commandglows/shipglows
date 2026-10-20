#!/usr/bin/env python3
"""Read-only web search client for the Parallel Search API."""

from __future__ import annotations

import argparse
from datetime import date
import ipaddress
import json
import os
import re
import sys
from urllib.parse import quote, urlencode, urlsplit
from urllib.request import Request

try:
    from .shipglows_http import (
        MAX_RESPONSE_BYTES, ProviderError, _NoRedirectHandler, _open_once, resolve_timeout as _resolve_timeout,
        safe_message, send_json,
    )
except ImportError:  # run as a script or imported from the tools directory
    from shipglows_http import (  # type: ignore[no-redef]
        MAX_RESPONSE_BYTES, ProviderError, _NoRedirectHandler, _open_once, resolve_timeout as _resolve_timeout,
        safe_message, send_json,
    )

API_URL = "https://api.parallel.ai/v1/search"
EXTRACT_API_URL = "https://api.parallel.ai/v1/extract"
API_ROOT = "https://api.parallel.ai/v1"
MODES = ("turbo", "fast", "basic", "advanced")
TASK_PROCESSORS = ("lite", "base", "core", "pro", "ultra", "lite-fast", "base-fast", "core-fast", "pro-fast", "ultra-fast")
MONITOR_FREQUENCIES = ("1h", "1d", "1w")
MAX_EXTRACT_URLS = 20
TIMEOUT_ENV = "SHIPGLOWS_PARALLEL_TIMEOUT"
DEFAULT_TIMEOUT = 30.0


class ParallelError(ProviderError):
    """An actionable Parallel error safe to display in the terminal."""


def normalize_domain(value: str) -> str:
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


def matches_domain(link: str, target: str) -> bool:
    try:
        hostname = (urlsplit(link).hostname or "").rstrip(".").lower().encode("idna").decode("ascii")
    except (UnicodeError, ValueError):
        return False
    return hostname == target or hostname.endswith("." + target)


def _error_text(value: object, api_key: str) -> str:
    if isinstance(value, dict):
        error = value.get("error", "Parallel request failed")
        if isinstance(error, dict):
            error = error.get("message", "Parallel request failed")
        return safe_message(error, api_key)
    return "Parallel request failed"


def provider_error(body: bytes, api_key: str) -> str:
    try:
        return _error_text(json.loads(body.decode("utf-8")), api_key)
    except (UnicodeDecodeError, json.JSONDecodeError):
        return "Parallel request failed"


def resolve_timeout(value: float | None, default: float = DEFAULT_TIMEOUT) -> float:
    """Return --timeout, else SHIPGLOWS_PARALLEL_TIMEOUT, else the command default."""
    return _resolve_timeout(value, default, TIMEOUT_ENV, ParallelError)


def send_request(request: Request, api_key: str, *, timeout: float, opener=None, retry: bool = True) -> dict:
    """Send a Parallel request through the shared retrying transport and reject in-body errors."""
    data = send_json(
        request, provider="Parallel", secret=api_key, timeout=timeout, opener=opener, retry=retry,
        http_error=lambda code, body: f"Parallel HTTP {code}: {provider_error(body, api_key)}",
        error_cls=ParallelError,
    )
    if data.get("type") == "error" or data.get("error"):
        raise ParallelError(_error_text(data, api_key))
    return data


def normalize_result(item: object, position: int, target_domain: str | None) -> dict | None:
    if not isinstance(item, dict):
        return None
    url = item.get("url")
    if not isinstance(url, str) or not url.startswith(("https://", "http://")):
        return None
    title = item.get("title")
    excerpts = item.get("excerpts")
    return {
        "position": position,
        "title": title if isinstance(title, str) else "",
        "url": url,
        "publish_date": item.get("publish_date") if isinstance(item.get("publish_date"), str) else None,
        "excerpts": [entry for entry in excerpts if isinstance(entry, str)] if isinstance(excerpts, list) else [],
        "matches_domain": bool(target_domain and matches_domain(url, target_domain)),
    }


def request_search(args: argparse.Namespace, opener=None) -> dict:
    api_key = os.environ.get("PARALLEL_API_KEY", "").strip()
    if not api_key:
        raise ParallelError("PARALLEL_API_KEY is not set; provide your key in the process environment.")
    queries = [query.strip() for query in [*getattr(args, "terms", []), *(args.query or [])]]
    if not queries or any(not query for query in queries):
        raise ParallelError("At least one non-empty query is required (positional or --query).")
    if len(queries) > 5:
        raise ParallelError("Parallel accepts at most five search queries per request.")
    if any(len(query) > 200 for query in queries):
        raise ParallelError("Each search query must be at most 200 characters.")
    objective = args.objective.strip() if args.objective else ""
    if len(objective) > 5000:
        raise ParallelError("Objective must be at most 5000 characters.")

    payload = {"search_queries": queries, "mode": args.mode}
    if objective:
        payload["objective"] = objective
    advanced = {}
    source_policy = {}
    if len(args.include_domain or args.exclude_domain or []) > 10:
        raise ParallelError("At most ten source domains may be set per request.")
    if args.after_date:
        if not re.fullmatch(r"\d{4}-\d{2}-\d{2}", args.after_date):
            raise ParallelError("--after-date must use YYYY-MM-DD.")
        try:
            date.fromisoformat(args.after_date)
        except ValueError:
            raise ParallelError("--after-date must use YYYY-MM-DD.") from None
    if args.location and not re.fullmatch(r"[A-Za-z]{2}", args.location):
        raise ParallelError("--location must be a two-letter ISO country code.")
    if args.max_results is not None and args.max_results < 1:
        raise ParallelError("--max-results must be a positive integer.")
    if args.include_domain:
        source_policy["include_domains"] = args.include_domain
    if args.exclude_domain:
        source_policy["exclude_domains"] = args.exclude_domain
    if args.after_date:
        source_policy["after_date"] = args.after_date
    if source_policy:
        advanced["source_policy"] = source_policy
    if args.location:
        advanced["location"] = args.location.upper()
    if args.max_results:
        advanced["max_results"] = args.max_results
    if advanced:
        payload["advanced_settings"] = advanced
    request = Request(
        API_URL,
        data=json.dumps(payload, ensure_ascii=False).encode("utf-8"),
        headers={"Accept": "application/json", "Content-Type": "application/json", "x-api-key": api_key},
        method="POST",
    )
    data = send_request(request, api_key, timeout=resolve_timeout(getattr(args, "timeout", None)), opener=opener)
    raw_results = data.get("results")
    if not isinstance(raw_results, list):
        raise ParallelError("Parallel response did not contain a results list.")
    results = []
    for raw in raw_results:
        result = normalize_result(raw, len(results) + 1, args.domain)
        if result is not None:
            results.append(result)
    return {
        "provider": "parallel",
        "search_id": data.get("search_id") if isinstance(data.get("search_id"), str) else None,
        "objective": objective or None,
        "search_queries": queries,
        "mode": args.mode,
        "filters": {key: value for key, value in {
            "include_domains": args.include_domain, "exclude_domains": args.exclude_domain,
            "after_date": args.after_date, "location": args.location.upper() if args.location else None,
            "max_results": args.max_results,
        }.items() if value is not None},
        "result_order": "Parallel relevance order; not a Google SERP position.",
        "results": results,
    }


def normalize_public_url(value: str) -> str:
    url = value.strip()
    try:
        parsed = urlsplit(url)
        hostname = parsed.hostname
        if (parsed.scheme not in ("http", "https") or not hostname or parsed.username or parsed.password
                or hostname.lower() == "localhost" or hostname.lower().endswith(".localhost")):
            raise ValueError
        try:
            address = ipaddress.ip_address(hostname)
        except ValueError:
            address = None
        if address is not None and not address.is_global:
            raise ValueError
        return url
    except ValueError:
        raise argparse.ArgumentTypeError("URL must be an HTTP(S) public page URL without embedded credentials") from None


def normalize_webhook_url(value: str) -> str:
    url = normalize_public_url(value)
    if not url.startswith("https://"):
        raise argparse.ArgumentTypeError("webhook URL must use HTTPS")
    return url


def request_extract(args: argparse.Namespace, opener=None) -> dict:
    api_key = os.environ.get("PARALLEL_API_KEY", "").strip()
    if not api_key:
        raise ParallelError("PARALLEL_API_KEY is not set; provide your key in the process environment.")
    urls = [normalize_public_url(url) for url in args.url]
    if not urls or len(urls) > MAX_EXTRACT_URLS:
        raise ParallelError("Provide between 1 and 20 URLs per Extract request.")
    if len(set(urls)) != len(urls):
        raise ParallelError("Duplicate URLs are not allowed in one Extract request.")
    objective = args.objective.strip() if args.objective else ""
    if len(objective) > 5000:
        raise ParallelError("Objective must be at most 5000 characters.")
    payload = {"urls": urls}
    if objective:
        payload["objective"] = objective
    if args.full_content:
        payload["advanced_settings"] = {"full_content": True}
    request = Request(
        EXTRACT_API_URL,
        data=json.dumps(payload, ensure_ascii=False).encode("utf-8"),
        headers={"Accept": "application/json", "Content-Type": "application/json", "x-api-key": api_key},
        method="POST",
    )
    data = send_request(request, api_key, timeout=resolve_timeout(getattr(args, "timeout", None), 60.0), opener=opener)
    raw_results = data.get("results")
    if not isinstance(raw_results, list):
        raise ParallelError("Parallel response did not contain a results list.")
    results = []
    for item in raw_results:
        if not isinstance(item, dict) or not isinstance(item.get("url"), str):
            continue
        results.append({
            "url": item["url"],
            "title": item.get("title") if isinstance(item.get("title"), str) else "",
            "publish_date": item.get("publish_date") if isinstance(item.get("publish_date"), str) else None,
            "excerpts": [entry for entry in item.get("excerpts", []) if isinstance(entry, str)] if isinstance(item.get("excerpts"), list) else [],
            "full_content": item.get("full_content") if isinstance(item.get("full_content"), str) else None,
        })
    errors = data.get("errors")
    return {
        "provider": "parallel",
        "extract_id": data.get("extract_id") if isinstance(data.get("extract_id"), str) else None,
        "objective": objective or None,
        "full_content_requested": args.full_content,
        "results": results,
        "errors": errors if isinstance(errors, list) else [],
    }


def api_request(method: str, path: str, payload: dict | None = None, *, query: dict | None = None,
                opener=None, timeout: float = 45.0) -> dict:
    """Call a Task/Monitor endpoint; only GET is retried because POSTs create or cancel resources."""
    api_key = os.environ.get("PARALLEL_API_KEY", "").strip()
    if not api_key:
        raise ParallelError("PARALLEL_API_KEY is not set; provide your key in the process environment.")
    url = f"{API_ROOT}/{path.lstrip('/')}"
    if query:
        url += "?" + urlencode({key: value for key, value in query.items() if value is not None}, doseq=True)
    data = json.dumps(payload, ensure_ascii=False).encode("utf-8") if payload is not None else None
    headers = {"Accept": "application/json", "x-api-key": api_key}
    if data is not None:
        headers["Content-Type"] = "application/json"
    request = Request(url, data=data, headers=headers, method=method)
    return send_request(request, api_key, timeout=timeout, opener=opener, retry=method == "GET")


def request_research(args: argparse.Namespace, opener=None) -> dict:
    if args.research_action == "run":
        prompt = args.input.strip()
        if not prompt or len(prompt) > 15000:
            raise ParallelError("Research input must contain 1 to 15000 characters.")
        payload = {"input": prompt, "processor": args.processor}
        if args.output == "text":
            payload["task_spec"] = {"output_schema": {"type": "text"}}
        if len(args.include_domain or args.exclude_domain or []) > 10:
            raise ParallelError("At most ten source domains may be set per request.")
        if args.include_domain:
            payload["source_policy"] = {"include_domains": args.include_domain}
        elif args.exclude_domain:
            payload["source_policy"] = {"exclude_domains": args.exclude_domain}
        timeout = resolve_timeout(args.timeout, 45.0)
        return {"provider": "parallel", **api_request("POST", "tasks/runs", payload, opener=opener, timeout=timeout)}
    run_id = args.run_id.strip()
    if not re.fullmatch(r"trun_[A-Za-z0-9_-]{8,200}", run_id):
        raise ParallelError("Run ID must be a Parallel task ID such as trun_…")
    encoded_id = quote(run_id, safe="")
    suffix = "" if args.research_action == "status" else "/result"
    timeout = resolve_timeout(args.timeout, 90.0)
    return {"provider": "parallel", **api_request("GET", f"tasks/runs/{encoded_id}{suffix}", opener=opener, timeout=timeout)}


def request_monitor(args: argparse.Namespace, opener=None) -> dict:
    action = args.monitor_action
    timeout = resolve_timeout(args.timeout, 45.0)
    if action == "create":
        query_text = args.query.strip()
        if not query_text or len(query_text) > 5000:
            raise ParallelError("Monitor query must contain 1 to 5000 characters.")
        settings = {"query": query_text}
        advanced = {}
        source_policy = {}
        if args.include_domain:
            source_policy["include_domains"] = args.include_domain
        if args.exclude_domain:
            source_policy["exclude_domains"] = args.exclude_domain
        if source_policy:
            advanced["source_policy"] = source_policy
        if args.location:
            if not re.fullmatch(r"[A-Za-z]{2}", args.location):
                raise ParallelError("--location must be a two-letter ISO country code.")
            advanced["location"] = args.location.upper()
        if len(args.include_domain or args.exclude_domain or []) > 10:
            raise ParallelError("At most ten source domains may be set per request.")
        if advanced:
            settings["advanced_settings"] = advanced
        payload = {"type": "event_stream", "frequency": args.frequency, "processor": args.processor, "settings": settings}
        if args.webhook:
            payload["webhook"] = {"url": args.webhook, "event_types": ["monitor.event.detected"]}
        return {"provider": "parallel", **api_request("POST", "monitors", payload, opener=opener, timeout=timeout)}
    if action == "list":
        if args.limit < 1 or args.limit > 10000:
            raise ParallelError("Monitor list --limit must be between 1 and 10000.")
        return {"provider": "parallel", **api_request("GET", "monitors", query={"limit": args.limit, "status": args.status}, opener=opener, timeout=timeout)}
    monitor_id = args.monitor_id.strip()
    if not re.fullmatch(r"monitor_[A-Za-z0-9_-]{8,200}", monitor_id):
        raise ParallelError("Monitor ID must be a Parallel monitor ID such as monitor_…")
    encoded_id = quote(monitor_id, safe="")
    if action == "get":
        return {"provider": "parallel", **api_request("GET", f"monitors/{encoded_id}", opener=opener, timeout=timeout)}
    if action == "cancel":
        return {"provider": "parallel", **api_request("POST", f"monitors/{encoded_id}/cancel", opener=opener, timeout=timeout)}
    if args.limit < 1 or args.limit > 10000:
        raise ParallelError("Monitor events --limit must be between 1 and 10000.")
    query = {"limit": args.limit, "event_group_id": args.event_group_id}
    return {"provider": "parallel", **api_request("GET", f"monitors/{encoded_id}/events", query=query, opener=opener, timeout=timeout)}


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Search the web with Parallel and return cited page excerpts.")
    common = argparse.ArgumentParser(add_help=False)
    common.add_argument("--timeout", type=float, help=(
        f"per-attempt network timeout in seconds (default: ${TIMEOUT_ENV}, else 30 for search, "
        "60 for extract, 45 for research run/monitor, 90 for research status/result)"))
    subparsers = parser.add_subparsers(dest="command", required=True)
    search = subparsers.add_parser("search", parents=[common], help="make one Parallel Search API request")
    search.add_argument("terms", nargs="*", metavar="QUERY", help="keyword query as a positional argument (same as --query)")
    search.add_argument("--query", action="append", help="keyword query; repeat up to five times (positional queries count too)")
    search.add_argument("--objective", help="optional natural-language research objective")
    search.add_argument("--mode", choices=MODES, default="fast", help="search mode (default: fast)")
    search.add_argument("--domain", type=normalize_domain, help="mark exact-domain and subdomain results")
    policy = search.add_mutually_exclusive_group()
    policy.add_argument("--include-domain", action="append", type=normalize_domain, help="restrict sources to this domain; repeat up to ten times")
    policy.add_argument("--exclude-domain", action="append", type=normalize_domain, help="exclude this source domain; repeat up to ten times")
    search.add_argument("--after-date", help="only include pages published on or after YYYY-MM-DD")
    search.add_argument("--location", help="two-letter country code for localized results")
    search.add_argument("--max-results", type=int, help="maximum number of results")
    extract = subparsers.add_parser("extract", parents=[common], help="retrieve markdown content from specific public URLs")
    extract.add_argument("--url", action="append", required=True, type=normalize_public_url, help="public HTTP(S) URL; repeat up to 20 times")
    extract.add_argument("--objective", help="optional objective for focused excerpts")
    extract.add_argument("--full-content", action="store_true", help="request complete page markdown (may return large content)")
    research = subparsers.add_parser("research", help="run or retrieve asynchronous Parallel deep research")
    research_sub = research.add_subparsers(dest="research_action", required=True)
    run = research_sub.add_parser("run", parents=[common], help="start a cited research task and return its run ID")
    run.add_argument("--input", required=True, help="research prompt, up to 15000 characters")
    run.add_argument("--processor", choices=TASK_PROCESSORS, default="pro", help="processor tier (default: pro; may affect cost and latency)")
    run.add_argument("--output", choices=("text", "auto"), default="text", help="human-readable cited report or provider-structured output")
    run_policy = run.add_mutually_exclusive_group()
    run_policy.add_argument("--include-domain", action="append", type=normalize_domain)
    run_policy.add_argument("--exclude-domain", action="append", type=normalize_domain)
    for action in ("status", "result"):
        command = research_sub.add_parser(action, parents=[common], help=f"retrieve research task {action}")
        command.add_argument("--run-id", required=True)
    monitor = subparsers.add_parser("monitor", help="create and inspect scheduled web-monitor jobs")
    monitor_sub = monitor.add_subparsers(dest="monitor_action", required=True)
    create = monitor_sub.add_parser("create", parents=[common], help="create a recurring event-stream monitor")
    create.add_argument("--query", required=True, help="natural-language change signal to watch")
    create.add_argument("--frequency", choices=MONITOR_FREQUENCIES, default="1d")
    create.add_argument("--processor", choices=("lite", "base"), default="lite")
    create_policy = create.add_mutually_exclusive_group()
    create_policy.add_argument("--include-domain", action="append", type=normalize_domain)
    create_policy.add_argument("--exclude-domain", action="append", type=normalize_domain)
    create.add_argument("--location", help="two-letter country code for localized monitoring")
    create.add_argument("--webhook", type=normalize_webhook_url, help="public HTTPS webhook URL for change notifications")
    monitor_sub.add_parser("list", parents=[common], help="list active monitors")
    for action in ("get", "cancel", "events"):
        command = monitor_sub.add_parser(action, parents=[common], help=f"{action.capitalize()} a monitor")
        command.add_argument("--monitor-id", required=True)
        if action == "events":
            command.add_argument("--event-group-id")
            command.add_argument("--limit", type=int, default=100)
        if action == "cancel":
            command.add_argument("--confirm", action="store_true", required=True, help="confirm permanent cancellation")
    monitor_sub.choices["list"].add_argument("--status", choices=("active", "cancelled"), default="active")
    monitor_sub.choices["list"].add_argument("--limit", type=int, default=100)
    return parser


def main(argv: list[str] | None = None, opener=None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    try:
        if args.command == "search":
            result = request_search(args, opener=opener)
        elif args.command == "extract":
            result = request_extract(args, opener=opener)
        elif args.command == "research":
            result = request_research(args, opener=opener)
        else:
            result = request_monitor(args, opener=opener)
    except ParallelError as error:
        print(f"shipglows-parallel: {error}", file=sys.stderr)
        return 2
    print(json.dumps(result, ensure_ascii=True, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
