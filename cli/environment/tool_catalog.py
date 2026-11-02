"""Bounded reader for the shared ShipGlows tool metadata catalog.

The catalog is data only: it supplies trusted identities and exact versions to
the environment backends. It never supplies argv, never activates a backend and
never authorizes an operation. Every consumer still owns its fixed argv, its
trusted executable roots and its closed action set. A malformed catalog raises
``ToolCatalogError`` so importing a consumer fails closed.
"""

from __future__ import annotations

import json
import re
from functools import lru_cache
from pathlib import Path
from typing import Any, Dict, Mapping, Optional, Tuple
from urllib.parse import urlsplit


TOOL_CATALOG_SCHEMA = "shipglows.tool-catalog/v1"
TOOL_CATALOG_FILENAME = "ShipGlows.ToolCatalog.json"
# Installed runtime and source checkout both keep the catalog beside the
# Windows control-plane modules: cli/environment -> cli/windows.
DEFAULT_TOOL_CATALOG = Path(__file__).resolve().parents[1] / "windows" / TOOL_CATALOG_FILENAME
POLICY_FLAGS = ("executionAuthority", "activatesBackend", "argvAuthority")
ENTRY_KEYS = frozenset({"id", "kind", "owner", "version", "wingetPackageId", "provenance"})
ALLOWED_KINDS = frozenset({"manager", "toolchain", "cli"})
TOOL_ID = re.compile(r"^[a-z][a-z0-9-]{0,39}$")
EXACT_VERSION = re.compile(r"^\d{1,4}\.\d{1,4}\.\d{1,4}$")
WINGET_ID = re.compile(r"^[A-Za-z0-9][A-Za-z0-9-]{0,63}(?:\.[A-Za-z0-9][A-Za-z0-9-]{0,63}){1,7}$")
MAX_CATALOG_BYTES = 256 * 1024
MAX_TOOLS = 64


class ToolCatalogError(ValueError):
    """The shared tool catalog is missing, malformed or does not provide a field."""


def _reject_duplicate_keys(pairs: list[tuple[str, Any]]) -> Dict[str, Any]:
    result: Dict[str, Any] = {}
    for key, value in pairs:
        if key in result:
            raise ToolCatalogError(f"tool catalog repeats key {key!r}")
        result[key] = value
    return result


def _validate_provenance(value: str) -> None:
    if len(value) > 512 or re.search(r"\s|\\", value):
        raise ToolCatalogError("tool catalog provenance is not a plain HTTPS URL")
    try:
        parts = urlsplit(value)
    except ValueError as exc:
        raise ToolCatalogError("tool catalog provenance is not a valid HTTPS URL") from exc
    if parts.scheme != "https" or not parts.hostname or parts.username or parts.password:
        raise ToolCatalogError("tool catalog provenance must be an HTTPS URL without credentials")


def _validate_entry(entry: Any) -> Tuple[str, Dict[str, str]]:
    if not isinstance(entry, dict) or not set(entry) <= ENTRY_KEYS:
        raise ToolCatalogError("tool catalog entry contains unsupported fields")
    tool_id = entry.get("id")
    if not isinstance(tool_id, str) or not TOOL_ID.fullmatch(tool_id):
        raise ToolCatalogError("tool catalog entry has an invalid id")
    if not isinstance(entry.get("kind"), str) or entry["kind"] not in ALLOWED_KINDS:
        raise ToolCatalogError(f"tool catalog entry {tool_id} has an unsupported kind")
    owner = entry.get("owner")
    if not isinstance(owner, str) or not owner.strip() or len(owner) > 80:
        raise ToolCatalogError(f"tool catalog entry {tool_id} requires an owner")
    fields: Dict[str, str] = {}
    if "version" in entry:
        if not isinstance(entry["version"], str) or not EXACT_VERSION.fullmatch(entry["version"]):
            raise ToolCatalogError(f"tool catalog entry {tool_id} requires an exact version")
        fields["version"] = entry["version"]
    if "wingetPackageId" in entry:
        if not isinstance(entry["wingetPackageId"], str) or not WINGET_ID.fullmatch(entry["wingetPackageId"]):
            raise ToolCatalogError(f"tool catalog entry {tool_id} has an invalid WinGet package id")
        fields["wingetPackageId"] = entry["wingetPackageId"]
    if "provenance" in entry:
        if not isinstance(entry["provenance"], str):
            raise ToolCatalogError(f"tool catalog entry {tool_id} has an invalid provenance")
        _validate_provenance(entry["provenance"])
        fields["provenance"] = entry["provenance"]
    fields["owner"] = owner
    return tool_id, fields


def _parse_catalog(text: str) -> Dict[str, Dict[str, str]]:
    try:
        document = json.loads(text, object_pairs_hook=_reject_duplicate_keys)
    except (json.JSONDecodeError, RecursionError) as exc:
        raise ToolCatalogError("tool catalog is not valid JSON") from exc
    if not isinstance(document, dict) or set(document) != {"schema", "policy", "tools"}:
        raise ToolCatalogError("tool catalog top-level shape is unsupported")
    if document["schema"] != TOOL_CATALOG_SCHEMA:
        raise ToolCatalogError("tool catalog schema is unsupported")
    policy = document["policy"]
    if not isinstance(policy, dict) or set(policy) != set(POLICY_FLAGS) or any(policy[name] is not False for name in POLICY_FLAGS):
        raise ToolCatalogError("tool catalog policy must disable execution, activation and argv authority")
    tools = document["tools"]
    if not isinstance(tools, list) or not tools or len(tools) > MAX_TOOLS:
        raise ToolCatalogError("tool catalog must contain a bounded non-empty tool list")
    catalog: Dict[str, Dict[str, str]] = {}
    for entry in tools:
        tool_id, fields = _validate_entry(entry)
        if tool_id in catalog:
            raise ToolCatalogError(f"tool catalog repeats tool {tool_id}")
        catalog[tool_id] = fields
    return catalog


@lru_cache(maxsize=8)
def _load_cached(resolved: str) -> Mapping[str, Mapping[str, str]]:
    path = Path(resolved)
    try:
        if not path.is_file() or path.stat().st_size > MAX_CATALOG_BYTES:
            raise ToolCatalogError(f"tool catalog is missing or oversized: {path}")
        text = path.read_text(encoding="utf-8")
    except (OSError, UnicodeError) as exc:
        raise ToolCatalogError(f"tool catalog is unreadable: {path}") from exc
    return _parse_catalog(text)


def load_tool_catalog(path: Optional[Path] = None) -> Mapping[str, Mapping[str, str]]:
    """Return validated tool metadata keyed by id; ``path`` defaults to the installed sibling."""

    return _load_cached(str((path or DEFAULT_TOOL_CATALOG).resolve(strict=False)))


def tool_field(tool_id: str, field: str, path: Optional[Path] = None) -> str:
    """Return one required metadata value, failing closed when the entry or field is absent."""

    catalog = load_tool_catalog(path)
    entry = catalog.get(tool_id)
    if entry is None:
        raise ToolCatalogError(f"tool catalog has no entry for {tool_id}")
    value = entry.get(field)
    if not value:
        raise ToolCatalogError(f"tool catalog entry {tool_id} requires {field}")
    return value
