#!/usr/bin/env python3
"""Inspect and safely edit a Vivaldi profile's complete bookmark collection."""

from __future__ import annotations

import argparse
import copy
import hashlib
import json
import os
import re
import subprocess
import sys
import time
import uuid
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Callable
from urllib.parse import parse_qsl, urlsplit

MAX_SOURCE_BYTES = 32 * 1024 * 1024
MAX_RESULTS = 1000
SCHEMA_VERSION = 2
ROOT_ORDER = ("bookmark_bar", "other", "synced", "trash")
MUTATION_COMMANDS = {"add-url", "add-folder", "update", "move", "archive", "restore"}
SENSITIVE_QUERY_KEYS = {
    "apikey", "auth", "authorization", "credential", "credentials", "jwt",
    "password", "passwd", "secret", "sig", "signature", "token",
}
SENSITIVE_QUERY_SUFFIXES = (
    "credential", "credentials", "password", "passwd", "secret", "signature", "token",
)


class BridgeError(ValueError):
    """A bounded operator-facing bridge failure."""


def runtime_root() -> Path:
    state_root = Path(os.environ.get(
        "SHIPGLOWS_RUNTIME_DIR", str(Path.home() / ".shipglows" / "state")))
    if not state_root.expanduser().is_absolute():
        raise BridgeError("SHIPGLOWS_RUNTIME_DIR must be absolute")
    return state_root.expanduser().resolve(strict=False)


def default_config_path() -> Path:
    return runtime_root() / "sources" / "vivaldi-design-bookmarks.json"


def add_write_guards(parser: argparse.ArgumentParser) -> None:
    parser.add_argument("--expected-checksum", required=True)
    parser.add_argument("--apply", action="store_true",
                        help="Commit the operation. Without this flag, report a dry run.")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--config", type=Path, default=default_config_path())
    parser.add_argument("--format", choices=("json", "markdown"), default="markdown")
    parser.add_argument("--limit", type=int, default=200)
    commands = parser.add_subparsers(dest="command", required=True)
    commands.add_parser("status", help="Report availability, counts, checksum, and write readiness.")
    commands.add_parser("list", help="List every bookmark in the configured profile.")
    search = commands.add_parser("search", help="Search titles, complete URLs, and folders.")
    search.add_argument("query")

    add_url = commands.add_parser("add-url", help="Add a URL bookmark to a folder/root.")
    add_url.add_argument("--parent", required=True)
    add_url.add_argument("--title", required=True)
    add_url.add_argument("--url", required=True)
    add_url.add_argument("--index", type=int)
    add_write_guards(add_url)

    add_folder = commands.add_parser("add-folder", help="Add a bookmark folder.")
    add_folder.add_argument("--parent", required=True)
    add_folder.add_argument("--title", required=True)
    add_folder.add_argument("--index", type=int)
    add_write_guards(add_folder)

    update = commands.add_parser("update", help="Rename a node and optionally change its URL.")
    update.add_argument("--node", required=True)
    update.add_argument("--title")
    update.add_argument("--url")
    add_write_guards(update)

    move = commands.add_parser("move", help="Move a node to another folder/root.")
    move.add_argument("--node", required=True)
    move.add_argument("--parent", required=True)
    move.add_argument("--index", type=int)
    add_write_guards(move)

    archive = commands.add_parser("archive", help="Move a node into Vivaldi Trash.")
    archive.add_argument("--node", required=True)
    add_write_guards(archive)

    restore = commands.add_parser("restore", help="Restore a node from Vivaldi Trash.")
    restore.add_argument("--node", required=True)
    restore.add_argument("--parent", required=True)
    restore.add_argument("--index", type=int)
    add_write_guards(restore)
    return parser.parse_args()


def read_json_file(path: Path, label: str) -> dict[str, Any]:
    try:
        raw = path.read_text(encoding="utf-8")
    except OSError as error:
        raise BridgeError(f"cannot read {label}: {path}") from error
    try:
        value = json.loads(raw)
    except json.JSONDecodeError as error:
        raise BridgeError(f"{label} is not valid JSON") from error
    if not isinstance(value, dict):
        raise BridgeError(f"{label} must contain a JSON object")
    return value


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
    parts = [part.casefold() for part in resolved.parts]
    parent_ok = resolved.parent.name == "Default" or bool(
        re.fullmatch(r"Profile \d+", resolved.parent.name))
    if (not resolved.is_file() or resolved.name != "Bookmarks" or
            "vivaldi" not in parts or "user data" not in parts or not parent_ok):
        raise BridgeError("configured source must be a Vivaldi profile Bookmarks file")
    return resolved


def validate_backup_dir(raw_path: object, source: Path) -> Path:
    if not isinstance(raw_path, str) or not raw_path.strip():
        raise BridgeError("configuration backup_dir must be a non-empty absolute path")
    backup = Path(raw_path).expanduser()
    if not backup.is_absolute():
        raise BridgeError("configuration backup_dir must be absolute")
    backup = backup.resolve(strict=False)
    try:
        backup.relative_to(runtime_root())
    except ValueError as error:
        raise BridgeError(
            "configuration backup_dir must stay under SHIPGLOWS_RUNTIME_DIR") from error
    try:
        backup.relative_to(source.parent)
    except ValueError:
        return backup
    raise BridgeError("configuration backup_dir must be outside the Vivaldi profile")


def load_config(path: Path) -> dict[str, Any]:
    config = read_json_file(path.expanduser(), "bridge configuration")
    if config.get("schema_version") != SCHEMA_VERSION:
        raise BridgeError(f"bridge configuration schema_version must be {SCHEMA_VERSION}")
    source_config = config.get("source")
    if not isinstance(source_config, dict):
        raise BridgeError("bridge configuration requires a source object")
    label = source_config.get("label")
    if not isinstance(label, str) or not label.strip() or any(ord(c) < 32 for c in label):
        raise BridgeError("configuration source.label must be a non-empty string")
    if config.get("scope") != "all":
        raise BridgeError("configuration scope must be 'all'")
    source = validate_source_path(source_config.get("bookmarks_file"))
    return {"label": label.strip(), "source": source,
            "backup_dir": validate_backup_dir(config.get("backup_dir"), source)}


def read_stable_snapshot(path: Path) -> tuple[dict[str, Any], bytes]:
    for _attempt in range(2):
        try:
            before = path.stat()
            if before.st_size > MAX_SOURCE_BYTES:
                raise BridgeError("configured Vivaldi Bookmarks source exceeds the safe size limit")
            raw = path.read_bytes()
            after = path.stat()
        except BridgeError:
            raise
        except OSError as error:
            raise BridgeError("cannot read configured Vivaldi Bookmarks source") from error
        if before.st_size == after.st_size and before.st_mtime_ns == after.st_mtime_ns:
            try:
                payload = json.loads(raw.decode("utf-8"))
            except (UnicodeDecodeError, json.JSONDecodeError) as error:
                raise BridgeError("Vivaldi Bookmarks source is not valid JSON") from error
            if not isinstance(payload, dict):
                raise BridgeError("Vivaldi Bookmarks source must contain a JSON object")
            return payload, raw
    raise BridgeError("Vivaldi Bookmarks changed during reading; retry after sync settles")


def roots(payload: dict[str, Any]) -> dict[str, dict[str, Any]]:
    value = payload.get("roots")
    if not isinstance(value, dict):
        raise BridgeError("Vivaldi Bookmarks source has no valid roots object")
    result = {key: node for key, node in value.items() if isinstance(node, dict)}
    if not all(key in result for key in ("bookmark_bar", "other", "synced")):
        raise BridgeError("Vivaldi Bookmarks source is missing a permanent root")
    return result


def ordered_root_keys(payload: dict[str, Any]) -> list[str]:
    available = roots(payload)
    return [key for key in ROOT_ORDER if key in available] + sorted(
        key for key in available if key not in ROOT_ORDER)


def children(node: dict[str, Any]) -> list[dict[str, Any]]:
    if node.get("type") != "folder" or not isinstance(node.get("children"), list):
        raise BridgeError("Vivaldi bookmark folder has an invalid node shape")
    if not all(isinstance(child, dict) for child in node["children"]):
        raise BridgeError("Vivaldi bookmark folder contains an invalid child")
    return node["children"]


def compute_checksum(payload: dict[str, Any]) -> str:
    digest = hashlib.md5()

    def walk(node: dict[str, Any]) -> None:
        node_id, name, node_type = node.get("id"), node.get("name"), node.get("type")
        if not all(isinstance(value, str) for value in (node_id, name, node_type)):
            raise BridgeError("bookmark node cannot be checksummed")
        digest.update(node_id.encode("utf-8"))
        digest.update(name.encode("utf-16-le"))
        digest.update(node_type.encode("utf-8"))
        if node_type == "url":
            url = node.get("url")
            if not isinstance(url, str):
                raise BridgeError("URL bookmark cannot be checksummed")
            digest.update(url.encode("utf-8"))
        elif node_type == "folder":
            for child in children(node):
                walk(child)
        else:
            raise BridgeError("unknown Vivaldi bookmark node type")

    for key in ordered_root_keys(payload):
        walk(roots(payload)[key])
    return digest.hexdigest()


def collect_records(payload: dict[str, Any]) -> list[dict[str, str]]:
    records: list[dict[str, str]] = []

    def walk(node: dict[str, Any], root_key: str, folder: list[str]) -> None:
        for child in children(node):
            if child.get("type") == "folder" and isinstance(child.get("name"), str):
                walk(child, root_key, [*folder, child["name"]])
            elif child.get("type") == "url" and all(
                    isinstance(child.get(key), str) for key in ("name", "url", "id")):
                records.append({"id": child["id"], "guid": str(child.get("guid", "")),
                    "title": child["name"], "url": child["url"], "root": root_key,
                    "folder": " / ".join(folder)})

    for key in ordered_root_keys(payload):
        root = roots(payload)[key]
        walk(root, key, [key])
    return sorted(records, key=lambda item: (
        item["folder"].casefold(), item["title"].casefold(), item["id"]))


def find_node(payload: dict[str, Any], reference: str) -> tuple[str, dict[str, Any], dict[str, Any] | None]:
    matches: list[tuple[str, dict[str, Any], dict[str, Any] | None]] = []

    def walk(root_key: str, node: dict[str, Any], parent: dict[str, Any] | None) -> None:
        if node.get("id") == reference or node.get("guid") == reference:
            matches.append((root_key, node, parent))
        if node.get("type") == "folder":
            for child in children(node):
                walk(root_key, child, node)

    for key in ordered_root_keys(payload):
        walk(key, roots(payload)[key], None)
    if len(matches) != 1:
        raise BridgeError("bookmark node reference was not found or is ambiguous")
    return matches[0]


def normalize_title(value: object) -> str:
    if not isinstance(value, str) or not value.strip() or any(ord(c) < 32 for c in value):
        raise BridgeError("bookmark title must be a non-empty printable string")
    return value.strip()


def has_authentication_query(query: str) -> bool:
    for key, _value in parse_qsl(query, keep_blank_values=True):
        compact = "".join(character for character in key.casefold() if character.isalnum())
        if compact in SENSITIVE_QUERY_KEYS or compact.endswith(SENSITIVE_QUERY_SUFFIXES):
            return True
    return False


def normalize_url(value: object) -> str:
    if not isinstance(value, str) or len(value) > 16384:
        raise BridgeError("bookmark URL must be a bounded HTTP(S) URL")
    try:
        parsed = urlsplit(value)
    except ValueError as error:
        raise BridgeError("bookmark URL is invalid") from error
    if parsed.scheme not in {"http", "https"} or not parsed.netloc:
        raise BridgeError("bookmark URL must use HTTP or HTTPS")
    if (parsed.username is not None or parsed.password is not None or
            has_authentication_query(parsed.query) or
            has_authentication_query(parsed.fragment)):
        raise BridgeError("bookmark URL must not contain authentication material")
    return value


def chromium_time() -> str:
    return str(int(time.time() * 1_000_000) + 11644473600000000)


def next_id(payload: dict[str, Any]) -> str:
    maximum = 0
    for record_root in roots(payload).values():
        stack = [record_root]
        while stack:
            node = stack.pop()
            try:
                maximum = max(maximum, int(node.get("id", "0")))
            except (TypeError, ValueError):
                raise BridgeError("bookmark collection contains a non-numeric node id")
            if node.get("type") == "folder":
                stack.extend(children(node))
    return str(maximum + 1)


def insert_child(parent: dict[str, Any], node: dict[str, Any], index: int | None) -> None:
    items = children(parent)
    if index is None:
        items.append(node)
    elif not 0 <= index <= len(items):
        raise BridgeError("destination index is outside the folder boundary")
    else:
        items.insert(index, node)
    parent["date_modified"] = chromium_time()


def contains_node(folder: dict[str, Any], target: dict[str, Any]) -> bool:
    if folder is target:
        return True
    return any(child.get("type") == "folder" and contains_node(child, target)
               for child in children(folder))


def remove_from_parent(node: dict[str, Any], parent: dict[str, Any] | None) -> None:
    if parent is None:
        raise BridgeError("permanent bookmark roots cannot be moved or archived")
    children(parent).remove(node)
    parent["date_modified"] = chromium_time()


def apply_operation(payload: dict[str, Any], args: argparse.Namespace) -> dict[str, Any]:
    command = args.command
    if command in {"add-url", "add-folder"}:
        _root, parent, _grandparent = find_node(payload, args.parent)
        if parent.get("type") != "folder":
            raise BridgeError("destination parent must be a folder")
        now = chromium_time()
        if command == "add-folder":
            node = {"id": next_id(payload), "guid": str(uuid.uuid4()), "type": "folder",
                    "name": normalize_title(args.title), "date_added": now,
                    "date_last_used": "0", "date_modified": now, "children": []}
        else:
            node = {"id": next_id(payload), "guid": str(uuid.uuid4()), "type": "url",
                    "name": normalize_title(args.title), "url": normalize_url(args.url),
                    "date_added": now, "date_last_used": "0"}
        insert_child(parent, node, args.index)
    elif command == "update":
        _root, node, parent = find_node(payload, args.node)
        if parent is None:
            raise BridgeError("permanent bookmark roots cannot be updated")
        if args.title is None and args.url is None:
            raise BridgeError("update requires --title or --url")
        if args.title is not None:
            node["name"] = normalize_title(args.title)
        if args.url is not None:
            if node.get("type") != "url":
                raise BridgeError("only URL bookmarks accept --url")
            node["url"] = normalize_url(args.url)
        parent["date_modified"] = chromium_time()
    else:
        source_root, node, old_parent = find_node(payload, args.node)
        if command == "archive":
            if source_root == "trash":
                raise BridgeError("bookmark node is already archived")
            destination = roots(payload).get("trash")
            if not isinstance(destination, dict):
                raise BridgeError("Vivaldi Trash root is unavailable")
            index = None
        else:
            destination_root, destination, _destination_parent = find_node(payload, args.parent)
            if destination.get("type") != "folder":
                raise BridgeError("destination parent must be a folder")
            if command == "restore" and source_root != "trash":
                raise BridgeError("restore only accepts a node from Vivaldi Trash")
            if command == "restore" and destination_root == "trash":
                raise BridgeError("restore destination must be outside Vivaldi Trash")
            index = args.index
        if node.get("type") == "folder" and contains_node(node, destination):
            raise BridgeError("a folder cannot be moved inside itself")
        remove_from_parent(node, old_parent)
        insert_child(destination, node, index)
    return {"id": str(node.get("id", "")), "guid": str(node.get("guid", "")),
            "type": str(node.get("type", "")), "title": str(node.get("name", ""))}


def is_live_profile(path: Path) -> bool:
    local = os.environ.get("LOCALAPPDATA")
    if not local:
        return False
    live_root = (Path(local) / "Vivaldi" / "User Data").resolve(strict=False)
    try:
        path.resolve(strict=False).relative_to(live_root)
        return True
    except ValueError:
        return False


def vivaldi_is_running() -> bool:
    if os.name != "nt":
        return False
    try:
        result = subprocess.run(["tasklist", "/FI", "IMAGENAME eq vivaldi.exe", "/NH"],
                                capture_output=True, text=True, timeout=5, check=False)
    except (OSError, subprocess.SubprocessError):
        raise BridgeError("cannot verify whether Vivaldi is closed")
    return "vivaldi.exe" in result.stdout.casefold()


def atomic_commit(source: Path, backup_dir: Path, original: bytes,
                  payload: dict[str, Any], write_guard: Callable[[], None]) -> Path:
    write_guard()
    if source.read_bytes() != original:
        raise BridgeError("Vivaldi Bookmarks changed after planning; operation is stale")
    backup_dir.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S.%fZ")
    backup = backup_dir / f"Bookmarks.{timestamp}.{payload['_old_checksum']}.json"
    with backup.open("xb") as handle:
        handle.write(original)
        handle.flush()
        os.fsync(handle.fileno())
    payload.pop("_old_checksum")
    encoded = (json.dumps(payload, ensure_ascii=False, indent=2) + "\n").encode("utf-8")
    temporary = source.parent / f".Bookmarks.shipglows.{uuid.uuid4().hex}.tmp"
    try:
        with temporary.open("xb") as handle:
            handle.write(encoded)
            handle.flush()
            os.fsync(handle.fileno())
        write_guard()
        if source.read_bytes() != original:
            raise BridgeError("Vivaldi Bookmarks changed before commit; operation is stale")
        os.replace(temporary, source)
        written, _raw = read_stable_snapshot(source)
        if written.get("checksum") != compute_checksum(written):
            raise BridgeError("post-write checksum verification failed")
    except Exception:
        if temporary.exists():
            temporary.unlink()
        if source.read_bytes() != original:
            rollback = source.parent / f".Bookmarks.shipglows.rollback.{uuid.uuid4().hex}.tmp"
            rollback.write_bytes(original)
            os.replace(rollback, source)
        raise
    return backup


def execute_mutation(config: dict[str, Any], payload: dict[str, Any], original: bytes,
                     args: argparse.Namespace,
                     running_check: Callable[[], bool] = vivaldi_is_running) -> dict[str, Any]:
    stored = payload.get("checksum")
    computed = compute_checksum(payload)
    if not isinstance(stored, str) or stored != computed:
        raise BridgeError("stored Vivaldi checksum does not match bookmark contents")
    if args.expected_checksum != stored:
        raise BridgeError("expected checksum is stale; refresh status before retrying")
    changed = copy.deepcopy(payload)
    node = apply_operation(changed, args)
    new_checksum = compute_checksum(changed)
    changed["checksum"] = new_checksum
    result: dict[str, Any] = {"source": config["label"], "command": args.command,
        "dry_run": not args.apply, "previous_checksum": stored,
        "checksum": new_checksum, "node": node}
    if args.apply:
        live_profile = is_live_profile(config["source"])

        def require_closed() -> None:
            if live_profile and running_check():
                raise BridgeError("Vivaldi is running; close every Vivaldi process before writing")

        require_closed()
        changed["_old_checksum"] = stored
        backup = atomic_commit(config["source"], config["backup_dir"], original, changed,
                               require_closed)
        result["backup"] = str(backup)
    return result


def run(args: argparse.Namespace) -> dict[str, Any]:
    if not 1 <= args.limit <= MAX_RESULTS:
        raise BridgeError(f"--limit must be between 1 and {MAX_RESULTS}")
    config = load_config(args.config)
    payload, original = read_stable_snapshot(config["source"])
    records = collect_records(payload)
    if args.command == "status":
        return {"source": config["label"], "command": "status", "source_available": True,
            "bookmarks": len(records), "roots": {key: sum(
                item["root"] == key for item in records) for key in ordered_root_keys(payload)},
            "checksum": str(payload.get("checksum", "")),
            "checksum_valid": payload.get("checksum") == compute_checksum(payload),
            "write_ready": not (is_live_profile(config["source"]) and vivaldi_is_running())}
    if args.command in MUTATION_COMMANDS:
        return execute_mutation(config, payload, original, args)
    if args.command == "search":
        query = args.query.strip().casefold()
        if not query:
            raise BridgeError("search query must not be empty")
        records = [item for item in records if any(query in item[field].casefold()
                   for field in ("title", "url", "folder", "root"))]
    limited = records[:args.limit]
    return {"source": config["label"], "command": args.command,
            "count": len(limited), "truncated": len(records) > len(limited), "items": limited}


def markdown_escape(value: object) -> str:
    return str(value).replace("|", "\\|").replace("\r", " ").replace("\n", " ")


def render(payload: dict[str, Any], fmt: str) -> None:
    if fmt == "json":
        print(json.dumps(payload, ensure_ascii=False, indent=2))
        return
    print(f"# Vivaldi Bookmark Bridge — {markdown_escape(payload['source'])}")
    print()
    if payload["command"] == "status":
        print(f"- Bookmarks: {payload['bookmarks']}")
        print(f"- Checksum valid: {'yes' if payload['checksum_valid'] else 'no'}")
        print(f"- Write ready: {'yes' if payload['write_ready'] else 'no'}")
        print(f"- Checksum: {payload['checksum']}")
    elif "items" in payload:
        print(f"- Results: {payload['count']}")
        print("\n| ID | Title | Folder | URL |\n| --- | --- | --- | --- |")
        for item in payload["items"]:
            print(f"| {markdown_escape(item['id'])} | {markdown_escape(item['title'])} | "
                  f"{markdown_escape(item['folder'])} | {markdown_escape(item['url'])} |")
    else:
        print(f"- Operation: {payload['command']}")
        print(f"- Dry run: {'yes' if payload['dry_run'] else 'no'}")
        print(f"- Node: {markdown_escape(payload['node']['title'])} ({payload['node']['guid']})")
        print(f"- Checksum: {payload['checksum']}")


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    try:
        args = parse_args()
        render(run(args), args.format)
    except BridgeError as error:
        print(f"Vivaldi bookmark bridge: {error}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
