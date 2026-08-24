#!/usr/bin/env python3
"""Read configured Vivaldi bookmark subtrees without touching the browser profile."""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from pathlib import Path
from typing import Any
from urllib.parse import urlsplit, urlunsplit


MAX_SOURCE_BYTES = 32 * 1024 * 1024
MAX_RESULTS = 1000
SCHEMA_VERSION = 1


class BridgeError(ValueError):
    """A bounded operator-facing bridge failure."""


def default_config_path() -> Path:
    state_root = Path(
        os.environ.get("SHIPGLOWS_RUNTIME_DIR", str(Path.home() / ".shipglows" / "state"))
    ).expanduser()
    return state_root / "sources" / "vivaldi-design-bookmarks.json"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--config", type=Path, default=default_config_path())
    parser.add_argument("--format", choices=("json", "markdown"), default="markdown")
    parser.add_argument("--limit", type=int, default=200)
    subparsers = parser.add_subparsers(dest="command", required=True)
    subparsers.add_parser("status", help="Report source and selector availability without URLs.")
    subparsers.add_parser("list", help="List configured web bookmarks.")
    search = subparsers.add_parser("search", help="Search configured web bookmarks.")
    search.add_argument("query")
    return parser.parse_args()


def read_json_file(path: Path, label: str) -> dict[str, Any]:
    try:
        raw = path.read_text(encoding="utf-8")
    except OSError as error:
        raise BridgeError(f"cannot read {label}: {path}") from error
    try:
        payload = json.loads(raw)
    except json.JSONDecodeError as error:
        raise BridgeError(f"{label} is not valid JSON") from error
    if not isinstance(payload, dict):
        raise BridgeError(f"{label} must contain a JSON object")
    return payload


def validate_source_path(raw_path: object) -> Path:
    if not isinstance(raw_path, str) or not raw_path.strip():
        raise BridgeError("configuration source.bookmarks_file must be a non-empty path")
    path = Path(raw_path).expanduser()
    if not path.is_absolute():
        raise BridgeError("configuration source.bookmarks_file must be absolute")
    try:
        resolved = path.resolve(strict=True)
    except OSError as error:
        raise BridgeError("configured Vivaldi Bookmarks source does not exist") from error
    if not resolved.is_file() or resolved.name != "Bookmarks":
        raise BridgeError("configured source must be a Vivaldi profile Bookmarks file")
    parts = [part.casefold() for part in resolved.parts]
    parent_ok = resolved.parent.name == "Default" or bool(
        re.fullmatch(r"Profile \d+", resolved.parent.name)
    )
    if "vivaldi" not in parts or "user data" not in parts or not parent_ok:
        raise BridgeError("configured source must be inside a Vivaldi profile directory")
    return resolved


def load_config(path: Path) -> tuple[str, Path, list[list[str]]]:
    config = read_json_file(path.expanduser(), "bridge configuration")
    if config.get("schema_version") != SCHEMA_VERSION:
        raise BridgeError(f"bridge configuration schema_version must be {SCHEMA_VERSION}")
    source = config.get("source")
    if not isinstance(source, dict):
        raise BridgeError("bridge configuration requires a source object")
    label = source.get("label")
    if (
        not isinstance(label, str)
        or not label.strip()
        or any(ord(character) < 32 for character in label)
    ):
        raise BridgeError("configuration source.label must be a non-empty string")
    selectors = config.get("folders")
    if not isinstance(selectors, list) or not selectors:
        raise BridgeError("bridge configuration requires at least one folder selector")
    normalized: list[list[str]] = []
    for selector in selectors:
        if (
            not isinstance(selector, list)
            or len(selector) < 2
            or not all(
                isinstance(segment, str)
                and segment
                and not any(ord(character) < 32 for character in segment)
                for segment in selector
            )
        ):
            raise BridgeError("each folder selector must contain a root key and folder names")
        normalized.append(selector)
    if len({tuple(selector) for selector in normalized}) != len(normalized):
        raise BridgeError("bridge configuration folder selectors must be unique")
    return label.strip(), validate_source_path(source.get("bookmarks_file")), normalized


def read_stable_bookmarks(path: Path) -> dict[str, Any]:
    for _attempt in range(2):
        try:
            before = path.stat()
        except OSError as error:
            raise BridgeError("configured Vivaldi Bookmarks source is unavailable") from error
        if before.st_size > MAX_SOURCE_BYTES:
            raise BridgeError("configured Vivaldi Bookmarks source exceeds the safe size limit")
        try:
            raw = path.read_bytes()
            after = path.stat()
        except OSError as error:
            raise BridgeError("cannot read configured Vivaldi Bookmarks source") from error
        stable = before.st_size == after.st_size and before.st_mtime_ns == after.st_mtime_ns
        if stable:
            try:
                payload = json.loads(raw.decode("utf-8"))
            except (UnicodeDecodeError, json.JSONDecodeError) as error:
                raise BridgeError("Vivaldi Bookmarks source is not valid JSON") from error
            if not isinstance(payload, dict):
                raise BridgeError("Vivaldi Bookmarks source must contain a JSON object")
            return payload
    raise BridgeError("Vivaldi Bookmarks changed during reading; retry after sync settles")


def node_children(node: object) -> list[dict[str, Any]]:
    if not isinstance(node, dict) or node.get("type") != "folder":
        raise BridgeError("selected Vivaldi folder has an invalid node shape")
    children = node.get("children", [])
    if not isinstance(children, list):
        raise BridgeError("selected Vivaldi folder has an invalid children collection")
    return [child for child in children if isinstance(child, dict)]


def resolve_selector(payload: dict[str, Any], selector: list[str]) -> dict[str, Any]:
    roots = payload.get("roots")
    root = roots.get(selector[0]) if isinstance(roots, dict) else None
    if not isinstance(root, dict) or root.get("type") != "folder":
        raise BridgeError(f"configured folder not found or ambiguous: {' / '.join(selector)}")
    current = root
    for segment in selector[1:]:
        matches = [
            child
            for child in node_children(current)
            if child.get("type") == "folder" and child.get("name") == segment
        ]
        if len(matches) != 1:
            raise BridgeError(f"configured folder not found or ambiguous: {' / '.join(selector)}")
        current = matches[0]
    return current


def sanitize_web_url(url: str) -> str | None:
    try:
        parsed = urlsplit(url)
    except ValueError:
        return None
    if parsed.scheme not in {"http", "https"} or not parsed.netloc:
        return None
    safe_netloc = parsed.netloc.rsplit("@", 1)[-1]
    return urlunsplit((parsed.scheme, safe_netloc, parsed.path, "", ""))


def collect_bookmarks(
    node: dict[str, Any], selector: list[str]
) -> tuple[list[dict[str, str]], int]:
    records: list[dict[str, str]] = []
    skipped = 0

    def walk(current: dict[str, Any], folder: list[str]) -> None:
        nonlocal skipped
        for child in node_children(current):
            node_type = child.get("type")
            name = child.get("name")
            if node_type == "folder" and isinstance(name, str):
                walk(child, [*folder, name])
            elif node_type == "url":
                url = child.get("url")
                safe_url = sanitize_web_url(url) if isinstance(url, str) else None
                if not isinstance(name, str) or safe_url is None:
                    skipped += 1
                    continue
                records.append(
                    {
                        "title": name.strip(),
                        "url": safe_url,
                        "folder": " / ".join(folder),
                    }
                )

    walk(node, selector)
    return records, skipped


def selected_records(
    payload: dict[str, Any], selectors: list[list[str]]
) -> tuple[list[dict[str, str]], int, int, list[dict[str, object]]]:
    records: list[dict[str, str]] = []
    skipped = 0
    folder_status: list[dict[str, object]] = []
    for selector in selectors:
        folder = resolve_selector(payload, selector)
        selected, selected_skipped = collect_bookmarks(folder, selector)
        records.extend(selected)
        skipped += selected_skipped
        folder_status.append({"folder": " / ".join(selector), "bookmarks": len(selected)})
    unique = {
        (record["folder"], record["title"], record["url"]): record for record in records
    }
    duplicates_collapsed = len(records) - len(unique)
    ordered = sorted(
        unique.values(),
        key=lambda item: (
            item["folder"].casefold(),
            item["title"].casefold(),
            item["url"].casefold(),
        ),
    )
    return ordered, skipped, duplicates_collapsed, folder_status


def markdown_escape(value: str) -> str:
    return value.replace("|", "\\|").replace("\r", " ").replace("\n", " ")


def render(payload: dict[str, Any], fmt: str) -> None:
    if fmt == "json":
        print(json.dumps(payload, ensure_ascii=False, indent=2))
        return
    print(f"# Vivaldi Bookmark Bridge — {markdown_escape(str(payload['source']))}")
    print()
    if payload["command"] == "status":
        print(f"- Source available: {'yes' if payload['source_available'] else 'no'}")
        print(f"- Selected bookmarks: {payload['selected_bookmarks']}")
        print(f"- Skipped unsupported URLs: {payload['skipped_unsupported_urls']}")
        print(f"- Duplicate records collapsed: {payload['duplicates_collapsed']}")
        for folder in payload["folders"]:
            print(f"- {markdown_escape(str(folder['folder']))}: {folder['bookmarks']}")
        return
    print(f"- Results: {payload['count']}")
    print(f"- Skipped unsupported URLs: {payload['skipped_unsupported_urls']}")
    print(f"- Duplicate records collapsed: {payload['duplicates_collapsed']}")
    print()
    print("| Title | Folder | URL |")
    print("| --- | --- | --- |")
    for item in payload["items"]:
        print(
            f"| {markdown_escape(item['title'])} | {markdown_escape(item['folder'])} | "
            f"{markdown_escape(item['url'])} |"
        )


def run(args: argparse.Namespace) -> dict[str, Any]:
    if not 1 <= args.limit <= MAX_RESULTS:
        raise BridgeError(f"--limit must be between 1 and {MAX_RESULTS}")
    label, source_path, selectors = load_config(args.config)
    payload = read_stable_bookmarks(source_path)
    records, skipped, duplicates_collapsed, folder_status = selected_records(payload, selectors)
    if args.command == "status":
        return {
            "source": label,
            "command": "status",
            "source_available": True,
            "folders": folder_status,
            "selected_bookmarks": len(records),
            "skipped_unsupported_urls": skipped,
            "duplicates_collapsed": duplicates_collapsed,
        }
    if args.command == "search":
        query = args.query.strip().casefold()
        if not query:
            raise BridgeError("search query must not be empty")
        records = [
            record
            for record in records
            if query in record["title"].casefold()
            or query in record["url"].casefold()
            or query in record["folder"].casefold()
        ]
    limited = records[: args.limit]
    return {
        "source": label,
        "command": args.command,
        "count": len(limited),
        "truncated": len(records) > len(limited),
        "skipped_unsupported_urls": skipped,
        "duplicates_collapsed": duplicates_collapsed,
        "items": limited,
    }


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")
    if hasattr(sys.stderr, "reconfigure"):
        sys.stderr.reconfigure(encoding="utf-8")
    args = parse_args()
    try:
        result = run(args)
    except BridgeError as error:
        print(f"Vivaldi bookmark bridge: {error}", file=sys.stderr)
        return 2
    render(result, args.format)
    return 0


if __name__ == "__main__":
    sys.exit(main())
