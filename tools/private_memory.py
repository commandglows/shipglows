#!/usr/bin/env python3
"""Remember and retrieve private machine-local paths and URLs by alias."""

from __future__ import annotations

import argparse
import json
import os
import sys
import uuid
from copy import deepcopy
from datetime import datetime, timezone
from pathlib import Path
from typing import Any
from urllib.parse import parse_qsl, urlsplit

SCHEMA_VERSION = 1
MAX_STORE_BYTES = 4 * 1024 * 1024
MAX_RESULTS = 200
SENSITIVE_QUERY_KEYS = {
    "apikey", "auth", "authorization", "credential", "credentials", "jwt",
    "password", "passwd", "secret", "sig", "signature", "token",
}
SENSITIVE_QUERY_SUFFIXES = (
    "credential", "credentials", "password", "passwd", "secret", "signature", "token",
)


class MemoryError(ValueError):
    """A bounded operator-facing private-memory failure."""


def default_store_path() -> Path:
    return runtime_root() / "private-memory" / "locations.json"


def runtime_root() -> Path:
    state = Path(os.environ.get(
        "SHIPGLOWS_RUNTIME_DIR", str(Path.home() / ".shipglows" / "state")))
    if not state.expanduser().is_absolute():
        raise MemoryError("SHIPGLOWS_RUNTIME_DIR must be absolute")
    return state.expanduser().resolve(strict=False)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--store", type=Path, default=default_store_path())
    parser.add_argument("--format", choices=("json", "markdown"), default="markdown")
    parser.add_argument("--limit", type=int, default=50)
    commands = parser.add_subparsers(dest="command", required=True)
    commands.add_parser("status")
    commands.add_parser("list")
    search = commands.add_parser("search")
    search.add_argument("query")
    recall = commands.add_parser("recall")
    recall.add_argument("alias")
    remember = commands.add_parser("remember")
    remember.add_argument("alias")
    remember.add_argument("target")
    remember.add_argument("--note", default="")
    remember.add_argument("--tag", action="append", default=[])
    add_write_guards(remember)
    archive = commands.add_parser("archive")
    archive.add_argument("alias")
    add_write_guards(archive)
    restore = commands.add_parser("restore")
    restore.add_argument("alias")
    add_write_guards(restore)
    return parser.parse_args()


def add_write_guards(parser: argparse.ArgumentParser) -> None:
    parser.add_argument("--expected-revision", required=True, type=int)
    parser.add_argument("--apply", action="store_true",
                        help="Persist the change. The default is a dry run.")


def empty_store() -> dict[str, Any]:
    return {"schema_version": SCHEMA_VERSION, "revision": 0,
            "entries": [], "archive": []}


def validate_store_path(path: Path) -> Path:
    expanded = path.expanduser()
    if not expanded.is_absolute():
        raise MemoryError("private memory store path must be absolute")
    resolved = expanded.resolve(strict=False)
    try:
        resolved.relative_to(runtime_root())
    except ValueError as error:
        raise MemoryError("private memory store must stay under SHIPGLOWS_RUNTIME_DIR") from error
    return resolved


def load_store(path: Path) -> tuple[dict[str, Any], bytes | None]:
    if not path.exists():
        return empty_store(), None
    try:
        if not path.is_file() or path.stat().st_size > MAX_STORE_BYTES:
            raise MemoryError("private memory store is not a bounded regular file")
        raw = path.read_bytes()
        data = json.loads(raw.decode("utf-8"))
    except MemoryError:
        raise
    except (OSError, UnicodeDecodeError, json.JSONDecodeError) as error:
        raise MemoryError("private memory store is unreadable or invalid JSON") from error
    if not isinstance(data, dict) or data.get("schema_version") != SCHEMA_VERSION:
        raise MemoryError(f"private memory schema_version must be {SCHEMA_VERSION}")
    if not isinstance(data.get("revision"), int) or data["revision"] < 0:
        raise MemoryError("private memory revision is invalid")
    for key in ("entries", "archive"):
        if not isinstance(data.get(key), list) or not all(isinstance(v, dict) for v in data[key]):
            raise MemoryError(f"private memory {key} collection is invalid")
    return data, raw


def normalize_alias(value: object) -> str:
    if not isinstance(value, str):
        raise MemoryError("memory alias must be text")
    alias = " ".join(value.split())
    if not alias or len(alias) > 120 or any(ord(character) < 32 for character in alias):
        raise MemoryError("memory alias must be a bounded printable value")
    return alias


def normalize_note(value: object) -> str:
    if not isinstance(value, str) or len(value) > 500 or any(ord(c) < 32 and c not in "\n\t" for c in value):
        raise MemoryError("memory note must be bounded printable text")
    return value.strip()


def normalize_tags(values: list[str]) -> list[str]:
    tags = []
    for value in values:
        tag = " ".join(value.split())
        if not tag or len(tag) > 50 or any(ord(c) < 32 for c in tag):
            raise MemoryError("memory tags must be bounded printable values")
        if tag.casefold() not in {item.casefold() for item in tags}:
            tags.append(tag)
    if len(tags) > 20:
        raise MemoryError("private memory accepts at most 20 tags per entry")
    return tags


def has_authentication_query(query: str) -> bool:
    for key, _value in parse_qsl(query, keep_blank_values=True):
        compact = "".join(character for character in key.casefold() if character.isalnum())
        if compact in SENSITIVE_QUERY_KEYS or compact.endswith(SENSITIVE_QUERY_SUFFIXES):
            return True
    return False


def normalize_target(value: object) -> tuple[str, str]:
    if not isinstance(value, str) or not value.strip() or len(value) > 16384:
        raise MemoryError("memory target must be a bounded URL or absolute path")
    target = value.strip()
    try:
        parsed = urlsplit(target)
    except ValueError as error:
        raise MemoryError("memory target URL is invalid") from error
    if parsed.scheme in {"http", "https"}:
        if not parsed.netloc:
            raise MemoryError("memory URL requires a host")
        if parsed.username is not None or parsed.password is not None:
            raise MemoryError("memory URLs must not contain embedded credentials")
        if (has_authentication_query(parsed.query) or
                has_authentication_query(parsed.fragment)):
            raise MemoryError("memory URLs must not contain authentication parameters")
        return "url", target
    path = Path(target).expanduser()
    if not path.is_absolute():
        raise MemoryError("memory filesystem target must be an absolute path")
    path = path.resolve(strict=False)
    if path.is_dir():
        kind = "directory"
    elif path.is_file():
        kind = "file"
    else:
        kind = "path"
    return kind, str(path)


def find_alias(items: list[dict[str, Any]], alias: str) -> dict[str, Any] | None:
    key = normalize_alias(alias).casefold()
    matches = [item for item in items
               if isinstance(item.get("alias"), str) and item["alias"].casefold() == key]
    if len(matches) > 1:
        raise MemoryError("private memory contains an ambiguous alias")
    return matches[0] if matches else None


def public_item(item: dict[str, Any]) -> dict[str, Any]:
    result = deepcopy(item)
    result["available"] = (True if item.get("kind") == "url"
                           else Path(str(item.get("target", ""))).exists())
    return result


def backup_dir(store: Path) -> Path:
    del store
    return runtime_root() / "backups" / "private-memory"


def persist(store: Path, original: bytes | None, data: dict[str, Any]) -> Path | None:
    if store.exists():
        current = store.read_bytes()
        if original is None or current != original:
            raise MemoryError("private memory changed after planning; operation is stale")
    elif original is not None:
        raise MemoryError("private memory disappeared after planning; operation is stale")
    store.parent.mkdir(parents=True, exist_ok=True)
    backup: Path | None = None
    if original is not None:
        directory = backup_dir(store)
        directory.mkdir(parents=True, exist_ok=True)
        stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S.%fZ")
        backup = directory / f"locations.r{data['revision'] - 1}.{stamp}.json"
        with backup.open("xb") as handle:
            handle.write(original)
            handle.flush()
            os.fsync(handle.fileno())
    encoded = (json.dumps(data, ensure_ascii=False, indent=2) + "\n").encode("utf-8")
    temporary = store.parent / f".locations.{uuid.uuid4().hex}.tmp"
    try:
        with temporary.open("xb") as handle:
            handle.write(encoded)
            handle.flush()
            os.fsync(handle.fileno())
        os.replace(temporary, store)
        written, _raw = load_store(store)
        if written != data:
            raise MemoryError("private memory post-write verification failed")
    except Exception:
        if temporary.exists():
            temporary.unlink()
        if original is None:
            if store.exists():
                store.unlink()
        else:
            rollback = store.parent / f".locations.rollback.{uuid.uuid4().hex}.tmp"
            rollback.write_bytes(original)
            os.replace(rollback, store)
        raise
    return backup


def mutate(data: dict[str, Any], args: argparse.Namespace) -> tuple[dict[str, Any], dict[str, Any]]:
    changed = deepcopy(data)
    active = changed["entries"]
    archived = changed["archive"]
    now = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
    if args.command == "remember":
        alias = normalize_alias(args.alias)
        if find_alias(active, alias) or find_alias(archived, alias):
            raise MemoryError("memory alias already exists")
        kind, target = normalize_target(args.target)
        item = {"id": str(uuid.uuid4()), "alias": alias, "kind": kind,
                "target": target, "note": normalize_note(args.note),
                "tags": normalize_tags(args.tag), "created_at": now, "updated_at": now}
        active.append(item)
    elif args.command == "archive":
        item = find_alias(active, args.alias)
        if item is None:
            raise MemoryError("active memory alias was not found")
        active.remove(item)
        item["archived_at"] = now
        archived.append(item)
    else:
        item = find_alias(archived, args.alias)
        if item is None:
            raise MemoryError("archived memory alias was not found")
        if find_alias(active, item["alias"]):
            raise MemoryError("active memory alias already exists")
        archived.remove(item)
        item.pop("archived_at", None)
        item["updated_at"] = now
        active.append(item)
    changed["revision"] += 1
    return changed, item


def run(args: argparse.Namespace) -> dict[str, Any]:
    if not 1 <= args.limit <= MAX_RESULTS:
        raise MemoryError(f"--limit must be between 1 and {MAX_RESULTS}")
    store = validate_store_path(args.store)
    data, raw = load_store(store)
    if args.command == "status":
        return {"command": "status", "available": True, "revision": data["revision"],
                "active": len(data["entries"]), "archived": len(data["archive"])}
    if args.command in {"remember", "archive", "restore"}:
        if args.expected_revision != data["revision"]:
            raise MemoryError("expected revision is stale; refresh status before retrying")
        changed, item = mutate(data, args)
        result: dict[str, Any] = {"command": args.command, "dry_run": not args.apply,
            "revision": changed["revision"], "item": public_item(item)}
        if args.apply:
            backup = persist(store, raw, changed)
            result["backup_created"] = backup is not None
        return result
    if args.command == "recall":
        item = find_alias(data["entries"], args.alias)
        if item is None:
            raise MemoryError("active memory alias was not found")
        return {"command": "recall", "revision": data["revision"], "item": public_item(item)}
    items = [public_item(item) for item in data["entries"]]
    if args.command == "search":
        query = args.query.strip().casefold()
        if not query:
            raise MemoryError("search query must not be empty")
        items = [item for item in items if any(query in str(item[field]).casefold()
                 for field in ("alias", "target", "note", "tags"))]
    items = sorted(items, key=lambda item: item["alias"].casefold())
    limited = items[:args.limit]
    return {"command": args.command, "revision": data["revision"],
            "count": len(limited), "truncated": len(items) > len(limited), "items": limited}


def render(payload: dict[str, Any], fmt: str) -> None:
    if fmt == "json":
        print(json.dumps(payload, ensure_ascii=False, indent=2))
        return
    print("# ShipGlows Private Memory")
    print()
    if payload["command"] == "status":
        print(f"- Revision: {payload['revision']}")
        print(f"- Active entries: {payload['active']}")
        print(f"- Archived entries: {payload['archived']}")
    elif "items" in payload:
        print(f"- Results: {payload['count']}")
        for item in payload["items"]:
            print(f"- {item['alias']}: {item['target']} ({item['kind']})")
    else:
        item = payload["item"]
        print(f"- Alias: {item['alias']}")
        print(f"- Target: {item['target']}")
        print(f"- Type: {item['kind']}")
        print(f"- Available: {'yes' if item['available'] else 'no'}")
        if "dry_run" in payload:
            print(f"- Dry run: {'yes' if payload['dry_run'] else 'no'}")


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    try:
        args = parse_args()
        render(run(args), args.format)
    except MemoryError as error:
        print(f"ShipGlows private memory: {error}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
