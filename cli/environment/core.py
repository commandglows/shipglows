"""Strict environment contracts plus one bounded Windows mise pilot."""

from __future__ import annotations

import hashlib
import json
import math
import os
import platform
import re
import shutil
import subprocess
import threading
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, Iterable, List, Mapping, Optional
from urllib.parse import parse_qsl, urlencode, urlsplit, urlunsplit


MANIFEST_NAME = "shipglows.environment.json"
MANIFEST_SCHEMA = "shipglows.environment/v1"
STATE_SCHEMA = "shipglows.environment-state/v1"
PLAN_SCHEMA = "shipglows.environment-plan/v1"
CAPABILITY_GROUPS = ("tools", "targets", "agents", "integrations")
STATUS_VALUES = {
    "ready",
    "pending",
    "blocked",
    "degraded",
    "drifted",
    "not_applicable",
    "unknown",
}
MAX_MANIFEST_BYTES = 1024 * 1024
MAX_STATE_BYTES = 4 * 1024 * 1024
MAX_RUNTIME_POLICY_BYTES = 64 * 1024
MAX_SOURCE_BYTES = 8 * 1024 * 1024
STATE_LOCK_STALE_SECONDS = 30.0
ROOT_FIELDS = {"schema", "project", "capabilities", "backends", "policies", "extensions"}
PROJECT_FIELDS = {"id", "name"}
CAPABILITY_FIELDS = {"id", "constraint", "platforms"}
BACKEND_PLATFORMS = {"windows", "unix", "container"}
BACKEND_FIELDS = {"mise", "flox", "winget_configuration", "devcontainer"}
POLICY_FIELDS = {"native_host_required", "consent", "secrets"}
PLAN_FIELDS = {
    "schema",
    "project",
    "source_digest",
    "platform",
    "operations",
    "effects",
    "executable",
    "pilot",
    "digest",
}
PLAN_OPERATION_FIELDS = {
    "capability",
    "owner",
    "references",
    "status",
    "executable",
    "reason",
    "action",
    "approval",
    "package_id",
    "resolved_version",
    "integrity",
    "provenance",
    "backend_version",
}
PLAN_OPERATION_REQUIRED_FIELDS = {"capability", "owner", "references", "status", "executable", "reason"}
OBSERVATION_FIELDS = {
    "kind",
    "id",
    "status",
    "source",
    "path",
    "version",
    "reason",
    "owner",
    "consumer",
    "resolved_version",
    "integrity",
}
STATE_FIELDS = {
    "schema",
    "project",
    "management",
    "source_digest",
    "plan",
    "observed",
    "observed_at",
    "desired",
    "attestation",
}
SECRET_KEY = re.compile(r"(?:token|secret|password|passwd|api[_-]?key|authorization|cookie|credential)", re.I)
CREDENTIAL_VALUE = re.compile(
    r"^(?:Bearer\s+\S+|gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|sk-[A-Za-z0-9_-]{16,}|AIza[A-Za-z0-9_-]{20,}|xox[baprs]-\S+)$",
    re.I,
)
CAPABILITY_ID = re.compile(r"^[a-z0-9][a-z0-9._-]*$")
NATIVE_SOURCES = (
    ("flox", Path(".flox/env/manifest.toml")),
    ("mise", Path("mise.toml")),
    ("winget_configuration", Path(".config/shipglows/windows.dsc.yaml")),
    ("devcontainer", Path(".devcontainer/devcontainer.json")),
)
SAFE_TOOL_PROBES = {
    "python": ("python3", "python"),
    "node": ("node",),
    "git": ("git",),
    "mise": ("mise",),
    "flox": ("flox",),
}


class ContractError(ValueError):
    """Input or persisted state violates the environment contract."""


class ApplyRefused(RuntimeError):
    """An apply request was rejected before any backend invocation."""

    def __init__(self, code: str, message: str):
        super().__init__(message)
        self.code = code


def _reject_duplicate_pairs(pairs: Iterable[tuple[str, Any]]) -> Dict[str, Any]:
    result: Dict[str, Any] = {}
    for key, value in pairs:
        if key in result:
            raise ContractError(f"duplicate JSON field: {key}")
        result[key] = value
    return result


def _reject_constant(value: str) -> None:
    raise ContractError(f"non-finite JSON number is not allowed: {value}")


def load_json_strict(path: Path, max_bytes: int = MAX_MANIFEST_BYTES, label: str = "JSON input") -> Any:
    try:
        if path.stat().st_size > max_bytes:
            raise ContractError(f"{label} exceeds the {max_bytes}-byte size limit")
        with path.open("r", encoding="utf-8-sig") as handle:
            value = json.load(
                handle,
                object_pairs_hook=_reject_duplicate_pairs,
                parse_constant=_reject_constant,
            )
    except ContractError:
        raise
    except (OSError, UnicodeError, json.JSONDecodeError, RecursionError) as exc:
        raise ContractError(f"invalid JSON in {path}: {exc}") from exc
    _reject_non_finite(value)
    return value


def _reject_non_finite(value: Any) -> None:
    if isinstance(value, float) and not math.isfinite(value):
        raise ContractError("non-finite JSON number is not allowed")
    if isinstance(value, dict):
        for nested in value.values():
            _reject_non_finite(nested)
    elif isinstance(value, list):
        for nested in value:
            _reject_non_finite(nested)


def _require_object(value: Any, context: str) -> Dict[str, Any]:
    if not isinstance(value, dict):
        raise ContractError(f"{context} must be an object")
    return value


def _reject_unknown(value: Mapping[str, Any], allowed: set[str], context: str) -> None:
    unknown = sorted(set(value) - allowed)
    if unknown:
        raise ContractError(f"unknown field in {context}: {unknown[0]}")


def _require_fields(value: Mapping[str, Any], required: set[str], context: str) -> None:
    missing = sorted(required - set(value))
    if missing:
        raise ContractError(f"missing field in {context}: {missing[0]}")


def _require_nonempty_string(value: Any, context: str) -> str:
    if not isinstance(value, str) or not value.strip():
        raise ContractError(f"{context} must be a non-empty string")
    return value


def resolve_project_reference(project_root: Path, reference: str) -> Path:
    root = project_root.resolve()
    normalized_reference = _require_nonempty_string(reference, "project reference")
    if any(ord(character) < 32 for character in normalized_reference):
        raise ContractError("invalid project reference: control characters are not allowed")
    try:
        candidate = (root / normalized_reference).resolve(strict=False)
    except (OSError, RuntimeError, ValueError) as exc:
        raise ContractError("invalid project reference") from exc
    try:
        candidate.relative_to(root)
    except ValueError as exc:
        raise ContractError(f"project reference escapes project root: {reference}") from exc
    if candidate == root:
        raise ContractError(f"project reference must name a file below the project root: {reference}")
    return candidate


def _validate_capabilities(value: Any) -> Dict[str, List[Dict[str, Any]]]:
    capabilities = _require_object(value, "capabilities")
    _reject_unknown(capabilities, set(CAPABILITY_GROUPS), "capabilities")
    normalized: Dict[str, List[Dict[str, Any]]] = {group: [] for group in CAPABILITY_GROUPS}
    for group in CAPABILITY_GROUPS:
        entries = capabilities.get(group, [])
        if not isinstance(entries, list):
            raise ContractError(f"capabilities.{group} must be an array")
        seen = set()
        for index, entry_value in enumerate(entries):
            entry = _require_object(entry_value, f"capabilities.{group}[{index}]")
            _reject_unknown(entry, CAPABILITY_FIELDS, f"capabilities.{group}[{index}]")
            identifier = _require_nonempty_string(entry.get("id"), f"capabilities.{group}[{index}].id")
            if not CAPABILITY_ID.fullmatch(identifier):
                raise ContractError(f"invalid capability id: {identifier}")
            if identifier in seen:
                raise ContractError(f"duplicate capability id in {group}: {identifier}")
            seen.add(identifier)
            normalized_entry: Dict[str, Any] = {"id": identifier}
            if "constraint" in entry:
                normalized_entry["constraint"] = _require_nonempty_string(
                    entry["constraint"], f"capabilities.{group}[{index}].constraint"
                )
            if "platforms" in entry:
                platforms = entry["platforms"]
                if not isinstance(platforms, list) or not platforms:
                    raise ContractError(f"capabilities.{group}[{index}].platforms must be a non-empty array")
                if any(item not in BACKEND_PLATFORMS for item in platforms) or len(set(platforms)) != len(platforms):
                    raise ContractError(f"capabilities.{group}[{index}].platforms is invalid")
                normalized_entry["platforms"] = sorted(platforms)
            normalized[group].append(normalized_entry)
        normalized[group].sort(key=lambda item: item["id"])
    return normalized


def load_manifest(path: Path, project_root: Optional[Path] = None) -> Dict[str, Any]:
    root = (project_root or path.parent).resolve()
    path = path.resolve()
    try:
        path.relative_to(root)
    except ValueError as exc:
        raise ContractError("manifest path escapes project root") from exc
    manifest = _require_object(load_json_strict(path), "manifest")
    _reject_unknown(manifest, ROOT_FIELDS, "manifest")
    if manifest.get("schema") != MANIFEST_SCHEMA:
        raise ContractError(f"unsupported schema: {manifest.get('schema')!r}")

    normalized: Dict[str, Any] = {"schema": MANIFEST_SCHEMA}
    project_value = _require_object(manifest.get("project", {}), "project")
    _reject_unknown(project_value, PROJECT_FIELDS, "project")
    project_normalized = {}
    for field in ("id", "name"):
        if field in project_value:
            project_normalized[field] = _require_nonempty_string(project_value[field], f"project.{field}")
    normalized["project"] = project_normalized
    normalized["capabilities"] = _validate_capabilities(manifest.get("capabilities", {}))

    backends = _require_object(manifest.get("backends", {}), "backends")
    _reject_unknown(backends, BACKEND_PLATFORMS, "backends")
    normalized_backends: Dict[str, Dict[str, str]] = {}
    for platform_name, raw_references in backends.items():
        references = _require_object(raw_references, f"backends.{platform_name}")
        _reject_unknown(references, BACKEND_FIELDS, f"backends.{platform_name}")
        normalized_backends[platform_name] = {
            name: str(resolve_project_reference(root, reference))
            for name, reference in sorted(references.items())
        }
    normalized["backends"] = normalized_backends

    policies = _require_object(manifest.get("policies", {}), "policies")
    _reject_unknown(policies, POLICY_FIELDS, "policies")
    if "native_host_required" in policies and not isinstance(policies["native_host_required"], bool):
        raise ContractError("policies.native_host_required must be a boolean")
    if "consent" in policies and policies["consent"] != "explicit":
        raise ContractError("policies.consent must be 'explicit'")
    if "secrets" in policies and policies["secrets"] != "redact":
        raise ContractError("policies.secrets must be 'redact'")
    normalized["policies"] = {
        "native_host_required": policies.get("native_host_required", False),
        "consent": policies.get("consent", "explicit"),
        "secrets": policies.get("secrets", "redact"),
    }

    extensions = _require_object(manifest.get("extensions", {}), "extensions")
    for key in extensions:
        if not isinstance(key, str) or not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._/-]*[./][A-Za-z0-9._/-]+", key):
            raise ContractError(f"extension key must be namespaced: {key!r}")
    normalized["extensions"] = extensions
    return normalized


def load_runtime_policy(path: Path) -> Dict[str, Any]:
    result = {"port": None, "auto_repair": True}
    if not path.is_file():
        return result
    try:
        if path.stat().st_size > MAX_RUNTIME_POLICY_BYTES:
            raise ContractError(f"runtime policy exceeds the {MAX_RUNTIME_POLICY_BYTES}-byte size limit")
        lines = path.read_text(encoding="utf-8-sig").splitlines()
    except (OSError, UnicodeError) as exc:
        raise ContractError(f"could not read runtime policy {path}: {exc}") from exc
    seen = set()
    for number, raw_line in enumerate(lines, 1):
        line = raw_line.rstrip("\r")
        if not line or line.startswith("#"):
            continue
        if "=" not in line:
            raise ContractError(f"unsupported runtime-policy line {number} in {path}")
        key, value = line.split("=", 1)
        if key in seen:
            raise ContractError(f"duplicate runtime-policy key: {key}")
        seen.add(key)
        if key == "SHIPGLOWS_ENV_PORT":
            if value == "":
                result["port"] = None
            elif not value.isdigit() or not 1024 <= int(value) <= 65535:
                raise ContractError("SHIPGLOWS_ENV_PORT must be empty or between 1024 and 65535")
            else:
                result["port"] = int(value)
        elif key == "SHIPGLOWS_AUTO_REPAIR":
            if value not in ("true", "false"):
                raise ContractError("SHIPGLOWS_AUTO_REPAIR must be true or false")
            result["auto_repair"] = value == "true"
        else:
            raise ContractError(
                f"{key} is outside runtime-policy ownership; use {MANIFEST_NAME} for capabilities"
            )
    return result


def _sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    try:
        if path.stat().st_size > MAX_SOURCE_BYTES:
            raise ContractError(f"source exceeds the {MAX_SOURCE_BYTES}-byte size limit")
        total = 0
        with path.open("rb") as handle:
            while True:
                chunk = handle.read(1024 * 1024)
                if not chunk:
                    break
                total += len(chunk)
                if total > MAX_SOURCE_BYTES:
                    raise ContractError(f"source exceeds the {MAX_SOURCE_BYTES}-byte size limit")
                digest.update(chunk)
    except ContractError:
        raise
    except OSError as exc:
        raise ContractError(f"could not hash source {path}: {exc}") from exc
    return digest.hexdigest()


def canonical_json(value: Any) -> bytes:
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"), allow_nan=False).encode("utf-8")


def digest_value(value: Any) -> str:
    return hashlib.sha256(canonical_json(value)).hexdigest()


def _validate_project_identity(value: Any, context: str) -> Dict[str, Any]:
    project = _require_object(value, context)
    _reject_unknown(project, {"id", "root"}, context)
    _require_fields(project, {"id", "root"}, context)
    identifier = _require_nonempty_string(project["id"], f"{context}.id")
    if not re.fullmatch(r"[0-9a-f]{64}", identifier):
        raise ContractError(f"{context}.id must be a lowercase SHA-256 digest")
    _require_nonempty_string(project["root"], f"{context}.root")
    return project


def validate_plan_record(value: Any) -> Dict[str, Any]:
    plan = _require_object(value, "environment plan")
    _reject_unknown(plan, PLAN_FIELDS, "environment plan")
    _require_fields(plan, PLAN_FIELDS, "environment plan")
    if plan["schema"] != PLAN_SCHEMA:
        raise ContractError("unsupported environment plan schema")
    _validate_project_identity(plan["project"], "environment plan project")
    if not re.fullmatch(r"[0-9a-f]{64}", str(plan["source_digest"])):
        raise ContractError("environment plan source_digest is invalid")
    platform_value = _require_object(plan["platform"], "environment plan platform")
    _reject_unknown(platform_value, {"name", "architecture"}, "environment plan platform")
    _require_fields(platform_value, {"name", "architecture"}, "environment plan platform")
    if platform_value["name"] not in BACKEND_PLATFORMS:
        raise ContractError("environment plan platform name is invalid")
    _require_nonempty_string(platform_value["architecture"], "environment plan platform architecture")
    if not isinstance(plan["operations"], list):
        raise ContractError("environment plan operations must be an array")
    for index, operation_value in enumerate(plan["operations"]):
        context = f"environment plan operations[{index}]"
        operation = _require_object(operation_value, context)
        _reject_unknown(operation, PLAN_OPERATION_FIELDS, context)
        _require_fields(operation, PLAN_OPERATION_REQUIRED_FIELDS, context)
        capability = _require_object(operation["capability"], f"{context}.capability")
        _reject_unknown(capability, CAPABILITY_FIELDS | {"kind"}, f"{context}.capability")
        _require_fields(capability, {"kind", "id"}, f"{context}.capability")
        if capability["kind"] not in tuple(group[:-1] for group in CAPABILITY_GROUPS) + ("backend",):
            raise ContractError(f"{context}.capability kind is invalid")
        if not CAPABILITY_ID.fullmatch(str(capability["id"])):
            raise ContractError(f"{context}.capability id is invalid")
        if operation["owner"] is not None and not isinstance(operation["owner"], str):
            raise ContractError(f"{context}.owner must be null or a string")
        if not isinstance(operation["references"], list) or any(
            not isinstance(reference, str) for reference in operation["references"]
        ):
            raise ContractError(f"{context}.references must be a string array")
        if operation["status"] not in STATUS_VALUES:
            raise ContractError(f"{context}.status is invalid")
        if not isinstance(operation["executable"], bool):
            raise ContractError(f"{context}.executable must be a boolean")
        _require_nonempty_string(operation["reason"], f"{context}.reason")
        action = operation.get("action")
        if action is not None and action not in ("acquire_mise", "install_node", "install_pnpm"):
            raise ContractError(f"{context}.action is invalid")
        approval = operation.get("approval")
        if approval is not None and approval not in ("required", "not_required"):
            raise ContractError(f"{context}.approval is invalid")
        for field in ("package_id", "resolved_version", "integrity", "provenance", "backend_version"):
            if operation.get(field) is not None and not isinstance(operation[field], str):
                raise ContractError(f"{context}.{field} must be null or a string")
    effects = _require_object(plan["effects"], "environment plan effects")
    expected_effects = {"network", "download", "privilege", "consent"}
    _reject_unknown(effects, expected_effects, "environment plan effects")
    _require_fields(effects, expected_effects, "environment plan effects")
    if any(not isinstance(effects[name], bool) for name in expected_effects):
        raise ContractError("environment plan effects must be booleans")
    if not isinstance(plan["executable"], bool):
        raise ContractError("environment plan executable must be a boolean")
    pilot = plan["pilot"]
    if pilot is not None:
        pilot = _require_object(pilot, "environment plan pilot")
        _reject_unknown(pilot, {"backend", "capability", "offline", "documentation"}, "environment plan pilot")
        _require_fields(pilot, {"backend", "capability", "offline", "documentation"}, "environment plan pilot")
        if (
            pilot["backend"] != "mise"
            or pilot["capability"] != "node@24+pnpm@10"
            or not isinstance(pilot["offline"], bool)
        ):
            raise ContractError("environment plan pilot is invalid")
        documentation = _require_object(pilot["documentation"], "environment plan pilot documentation")
        _reject_unknown(documentation, {"install", "exec", "lock", "offline"}, "environment plan pilot documentation")
        _require_fields(documentation, {"install", "exec", "lock", "offline"}, "environment plan pilot documentation")
        if any(not isinstance(value, str) or not value.startswith("https://mise.jdx.dev/") for value in documentation.values()):
            raise ContractError("environment plan pilot documentation authority is invalid")
    if not re.fullmatch(r"[0-9a-f]{64}", str(plan["digest"])) or plan["digest"] != _plan_digest(plan):
        raise ContractError("environment plan digest is invalid")
    return plan


def _validate_state_record(value: Any) -> Dict[str, Any]:
    state = _require_object(value, "environment state")
    _reject_unknown(state, STATE_FIELDS, "environment state")
    _require_fields(state, STATE_FIELDS, "environment state")
    if state["schema"] != STATE_SCHEMA:
        raise ContractError("unsupported environment state schema")
    project = _validate_project_identity(state["project"], "environment state project")
    if state["management"] not in ("explicit", "inferred", "unmanaged"):
        raise ContractError("environment state management is invalid")
    if not re.fullmatch(r"[0-9a-f]{64}", str(state["source_digest"])):
        raise ContractError("environment state source_digest is invalid")
    plan = validate_plan_record(state["plan"])
    if plan["project"] != project or plan["source_digest"] != state["source_digest"]:
        raise ContractError("environment state plan identity does not match state identity")
    observed = _require_object(state["observed"], "environment state observed")
    _reject_unknown(observed, {"status", "capabilities"}, "environment state observed")
    _require_fields(observed, {"status", "capabilities"}, "environment state observed")
    if observed["status"] not in STATUS_VALUES:
        raise ContractError("environment state observed status is invalid")
    if not isinstance(observed["capabilities"], list):
        raise ContractError("environment state observed capabilities must be an array")
    for index, capability_value in enumerate(observed["capabilities"]):
        context = f"environment state observed capabilities[{index}]"
        capability = _require_object(capability_value, context)
        _reject_unknown(capability, OBSERVATION_FIELDS, context)
        _require_fields(capability, {"kind", "id", "status", "source"}, context)
        if capability["kind"] not in tuple(group[:-1] for group in CAPABILITY_GROUPS) + ("backend",):
            raise ContractError(f"{context}.kind is invalid")
        if not CAPABILITY_ID.fullmatch(str(capability["id"])):
            raise ContractError(f"{context}.id is invalid")
        if capability["status"] not in STATUS_VALUES:
            raise ContractError(f"{context}.status is invalid")
        _require_nonempty_string(capability["source"], f"{context}.source")
    if not isinstance(state["observed_at"], str):
        raise ContractError("environment state observed_at must be a string")
    try:
        observed_at = datetime.fromisoformat(state["observed_at"].replace("Z", "+00:00"))
    except ValueError as exc:
        raise ContractError("environment state observed_at is invalid") from exc
    if observed_at.utcoffset() is None:
        raise ContractError("environment state observed_at must include a timezone")
    desired = _require_object(state["desired"], "environment state desired")
    if desired.get("project") != project or desired.get("source_digest") != state["source_digest"]:
        raise ContractError("environment state desired identity does not match state identity")
    if not isinstance(state["attestation"], str):
        raise ContractError("environment state attestation must be a string")
    if state["attestation"] != render_attestation(state):
        raise ContractError("environment state attestation does not match its structured evidence")
    return state


def project_identity(project_root: Path) -> Dict[str, str]:
    root = project_root.resolve()
    normalized = os.path.normcase(str(root))
    return {"id": hashlib.sha256(normalized.encode("utf-8")).hexdigest(), "root": str(root)}


def discover_project(project_root: Path) -> Dict[str, Any]:
    root = project_root.resolve()
    if not root.is_dir():
        raise ContractError(f"project root is not a directory: {root}")
    manifest_path = resolve_project_reference(root, MANIFEST_NAME)
    sources: List[Dict[str, Any]] = []
    if manifest_path.is_file():
        manifest = load_manifest(manifest_path, root)
        sources.append(
            {"kind": "shipglows", "role": "manifest", "path": str(manifest_path), "explicit": True, "precedence": 100, "exists": True, "sha256": _sha256_file(manifest_path)}
        )
        management = "explicit"
    else:
        manifest = {
            "schema": MANIFEST_SCHEMA,
            "project": {},
            "capabilities": {group: [] for group in CAPABILITY_GROUPS},
            "backends": {},
            "policies": {"native_host_required": False, "consent": "explicit", "secrets": "redact"},
            "extensions": {},
        }
        management = "unmanaged"

    for platform_name, references in manifest.get("backends", {}).items():
        for kind, reference in references.items():
            referenced_path = Path(reference)
            exists = referenced_path.is_file()
            source = {
                "kind": kind,
                "role": "backend_reference",
                "platform": platform_name,
                "path": str(referenced_path),
                "explicit": True,
                "precedence": 90,
                "exists": exists,
                "sha256": _sha256_file(referenced_path) if exists else None,
            }
            sources.append(source)
            lock_name = "mise.lock" if kind == "mise" else "manifest.lock" if kind == "flox" else None
            if lock_name:
                lock_path = resolve_project_reference(root, str(referenced_path.parent.joinpath(lock_name).relative_to(root)))
                if lock_path.is_file():
                    sources.append(
                        {
                            "kind": kind,
                            "role": "lock",
                            "platform": platform_name,
                            "path": str(lock_path),
                            "explicit": True,
                            "precedence": 85,
                            "exists": True,
                            "sha256": _sha256_file(lock_path),
                        }
                    )

    for kind, relative in NATIVE_SOURCES:
        candidate = resolve_project_reference(root, str(relative))
        if candidate.is_file():
            sources.append(
                {"kind": kind, "role": "native_manifest", "path": str(candidate), "explicit": False, "precedence": 50, "exists": True, "sha256": _sha256_file(candidate)}
            )
    if management == "unmanaged" and sources:
        management = "inferred"
    sources.sort(key=lambda item: (-item["precedence"], item["kind"], item["path"], item["role"]))
    desired = {
        "schema": MANIFEST_SCHEMA,
        "project": project_identity(root),
        "management": management,
        "manifest": manifest,
        "runtime_policy": load_runtime_policy(resolve_project_reference(root, ".shipglows.env")),
        "sources": sources,
    }
    desired["source_digest"] = digest_value({"manifest": manifest, "runtime_policy": desired["runtime_policy"], "sources": sources})
    return desired


def _redact_url(value: str) -> str:
    try:
        parts = urlsplit(value)
    except ValueError:
        return "[REDACTED]"
    if parts.scheme not in ("http", "https"):
        return value
    netloc = parts.netloc
    if parts.username is not None or parts.password is not None:
        host = parts.hostname or "redacted.invalid"
        try:
            port = parts.port
        except ValueError:
            return "[REDACTED]"
        if port:
            host = f"{host}:{port}"
        netloc = host
    query = []
    for query_key, query_value in parse_qsl(parts.query, keep_blank_values=True):
        query.append((query_key, "[REDACTED]" if SECRET_KEY.search(query_key) else query_value))
    fragment = "[REDACTED]" if SECRET_KEY.search(parts.fragment) else parts.fragment
    return urlunsplit((parts.scheme, netloc, parts.path, urlencode(query), fragment))


def redact(value: Any, key: str = "") -> Any:
    if key and SECRET_KEY.search(key):
        return "[REDACTED]"
    if isinstance(value, dict):
        return {str(item_key): redact(item_value, str(item_key)) for item_key, item_value in value.items()}
    if isinstance(value, list):
        return [redact(item) for item in value]
    if isinstance(value, str):
        if CREDENTIAL_VALUE.fullmatch(value.strip()):
            return "[REDACTED]"
        return _redact_url(value)
    return value


def _tool_observation(
    identifier: str, probe_version: bool = False, constraint: Optional[str] = None
) -> Dict[str, Any]:
    candidates = SAFE_TOOL_PROBES.get(identifier)
    if candidates is None:
        return {
            "kind": "tool",
            "id": identifier,
            "status": "unknown",
            "source": "no_trusted_probe",
            "reason": "the foundation does not execute repository-provided capability names",
        }
    executable = None
    for candidate in candidates:
        executable = shutil.which(candidate)
        if executable:
            break
    evidence: Dict[str, Any] = {"kind": "tool", "id": identifier, "status": "pending", "source": "trusted_process_probe"}
    if not executable:
        evidence["reason"] = "not visible in the current process PATH"
        return evidence
    evidence["path"] = executable
    if not probe_version:
        evidence.update(
            {
                "status": "unknown",
                "reason": "PATH presence observed without process execution; run verify for a trusted version probe",
            }
        )
        return evidence
    try:
        process = subprocess.run(
            [executable, "--version"],
            stdin=subprocess.DEVNULL,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=5,
            check=False,
            shell=False,
        )
        evidence["version"] = (process.stdout or "").strip().splitlines()[0][:240] if process.stdout else ""
        if process.returncode != 0:
            evidence.update({"status": "degraded", "reason": f"version probe exited {process.returncode}"})
        elif not evidence["version"]:
            evidence.update({"status": "degraded", "reason": "version probe returned no version evidence"})
        elif constraint:
            evidence.update(
                {
                    "status": "unknown",
                    "reason": "version captured; constraint evaluation requires an active capability adapter",
                }
            )
        else:
            evidence["status"] = "ready"
    except (OSError, subprocess.SubprocessError) as exc:
        evidence.update({"status": "degraded", "reason": f"version probe failed: {type(exc).__name__}"})
    return evidence


def observe_project(
    desired: Mapping[str, Any],
    probe_versions: bool = False,
    runner=None,
    platform_name: Optional[str] = None,
    architecture: Optional[str] = None,
    offline: bool = False,
) -> Dict[str, Any]:
    platform_value = platform_name or current_platform()
    architecture_value = architecture or platform.machine().lower() or "unknown"
    pilot_observations = None
    if probe_versions and platform_value == "windows":
        from .mise_backend import SubprocessRunner, observe_node

        pilot_observations = observe_node(
            desired,
            architecture_value,
            runner or SubprocessRunner(),
            offline=offline,
        )
    observations: List[Dict[str, Any]] = []
    capabilities = desired["manifest"]["capabilities"]
    for group in CAPABILITY_GROUPS:
        for capability in capabilities[group]:
            applicable = not capability.get("platforms") or platform_value in capability["platforms"]
            if not applicable:
                observations.append(
                    {"kind": group[:-1], "id": capability["id"], "status": "not_applicable", "source": "platform"}
                )
            elif (
                group == "tools"
                and capability["id"] in ("node", "pnpm")
                and pilot_observations is not None
            ):
                observations.extend(
                    item
                    for item in pilot_observations
                    if item["id"] == capability["id"]
                )
            elif group == "tools":
                observations.append(
                    _tool_observation(
                        capability["id"],
                        probe_version=probe_versions,
                        constraint=capability.get("constraint"),
                    )
                )
            else:
                observations.append(
                    {
                        "kind": group[:-1],
                        "id": capability["id"],
                        "status": "unknown",
                        "source": "no_active_backend",
                        "reason": "no observation adapter is active in the foundation slice",
                    }
                )
    observations.sort(key=lambda item: (CAPABILITY_GROUPS.index(item["kind"] + "s"), item["id"]))
    if not observations:
        overall = "unknown"
    elif all(item["status"] in ("ready", "not_applicable") for item in observations):
        overall = "ready"
    elif any(item["status"] == "blocked" for item in observations):
        overall = "blocked"
    else:
        overall = "pending"
    return {"status": overall, "capabilities": observations}


def current_platform() -> str:
    if os.name == "nt":
        return "windows"
    return "unix"


def build_plan(
    desired: Mapping[str, Any],
    platform_name: Optional[str] = None,
    architecture: Optional[str] = None,
    runner=None,
    offline: bool = False,
) -> Dict[str, Any]:
    platform_value = platform_name or current_platform()
    architecture_value = architecture or platform.machine().lower() or "unknown"
    if platform_value not in BACKEND_PLATFORMS:
        raise ContractError(f"unsupported platform fact: {platform_value}")
    if not isinstance(architecture_value, str) or not architecture_value.strip():
        raise ContractError("architecture fact must be a non-empty string")
    operations: List[Dict[str, Any]] = []
    pilot = None
    if platform_value == "windows":
        from .mise_backend import (
            MISE_EXEC_DOC,
            MISE_INSTALL_DOC,
            MISE_LOCK_DOC,
            MISE_OFFLINE_DOC,
            SubprocessRunner,
            plan_operations,
        )

        pilot_result = plan_operations(
            desired,
            architecture_value,
            runner or SubprocessRunner(),
            offline=offline,
        )
        if pilot_result is not None:
            operations = pilot_result["operations"]
            pilot = {
                "backend": "mise",
                "capability": "node@24+pnpm@10",
                "offline": offline,
                "documentation": {
                    "install": MISE_INSTALL_DOC,
                    "exec": MISE_EXEC_DOC,
                    "lock": MISE_LOCK_DOC,
                    "offline": MISE_OFFLINE_DOC,
                },
            }
    capabilities = desired["manifest"]["capabilities"]
    platform_backends = desired["manifest"].get("backends", {}).get(platform_value, {})
    references = sorted(platform_backends)
    if pilot is None:
        for group in CAPABILITY_GROUPS:
            for capability in capabilities[group]:
                applicable = not capability.get("platforms") or platform_value in capability["platforms"]
                ownership_conflict = applicable and len(references) > 1
                operations.append(
                    {
                        "capability": {"kind": group[:-1], **capability},
                        "owner": references[0] if len(references) == 1 else None,
                        "references": references,
                        "status": "blocked" if ownership_conflict else ("pending" if applicable else "not_applicable"),
                        "executable": False,
                        "reason": (
                            "multiple backend references exist and no explicit capability owner is selected"
                            if ownership_conflict
                            else "backend adapters are not active outside the bounded Windows mise pilot"
                            if applicable
                            else f"capability does not apply to {platform_value}"
                        ),
                    }
                )
    executable = any(operation["executable"] for operation in operations)
    network = any(
        operation.get("action") in ("acquire_mise", "install_node", "install_pnpm")
        and operation["executable"]
        for operation in operations
    )
    privilege = any(operation.get("action") == "acquire_mise" and operation["executable"] for operation in operations)
    body: Dict[str, Any] = {
        "schema": PLAN_SCHEMA,
        "project": desired["project"],
        "source_digest": desired["source_digest"],
        "platform": {"name": platform_value, "architecture": architecture_value},
        "operations": operations,
        "effects": {
            "network": network,
            "download": network,
            "privilege": privilege,
            "consent": executable,
        },
        "executable": executable,
        "pilot": pilot,
    }
    body["digest"] = digest_value(body)
    return body


def _plan_digest(plan: Mapping[str, Any]) -> str:
    body = dict(plan)
    body.pop("digest", None)
    return digest_value(body)


def apply_plan(plan: Mapping[str, Any], approved_digest: str, runner=None) -> Dict[str, Any]:
    actual_digest = _plan_digest(plan)
    recorded_digest = plan.get("digest")
    if recorded_digest != actual_digest or approved_digest != recorded_digest:
        raise ApplyRefused("stale_plan", "plan digest changed after approval; no operation was started")
    try:
        validate_plan_record(plan)
    except ContractError as exc:
        raise ApplyRefused("invalid_plan", f"plan validation failed; no operation was started: {exc}") from exc
    if plan.get("pilot") is None:
        raise ApplyRefused(
            "no_active_backend",
            "apply is unavailable outside the bounded Windows mise Node 24 and pnpm 10 pilot",
        )

    root = Path(plan["project"]["root"]).resolve()
    if project_identity(root) != plan["project"]:
        raise ApplyRefused("invalid_plan", "plan project identity is invalid; no operation was started")
    try:
        desired = discover_project(root)
    except ContractError as exc:
        raise ApplyRefused("stale_plan", f"project sources cannot be revalidated: {exc}") from exc
    if desired["source_digest"] != plan["source_digest"]:
        raise ApplyRefused("stale_plan", "project sources changed after approval; no operation was started")

    from .mise_backend import (
        MisePilotError,
        SubprocessRunner,
        apply_operations,
        recognize_pilot,
        validate_apply_semantics,
    )

    try:
        contract = recognize_pilot(
            desired,
            plan["platform"]["name"],
            plan["platform"]["architecture"],
        )
        if contract is None:
            raise MisePilotError(
                "plan no longer matches the bounded mise Node 24 and pnpm 10 pilot"
            )
        validate_apply_semantics(plan, contract)
        return apply_operations(plan, runner or SubprocessRunner())
    except MisePilotError as exc:
        message = str(exc)
        if "timed out" in message:
            code = "backend_timeout"
        elif "exited" in message or "empty evidence" in message:
            code = "backend_failed"
        elif "changed" in message or "disappeared" in message:
            code = "backend_drift"
        elif "approved plan is blocked" in message:
            code = "plan_blocked"
        else:
            code = "invalid_backend"
        raise ApplyRefused(code, f"mise pilot refused: {message}") from exc


def default_state_root() -> Path:
    configured = os.environ.get("SHIPGLOWS_ENVIRONMENT_STATE_ROOT")
    if configured:
        return Path(configured).expanduser().resolve(strict=False)
    if os.name == "nt":
        local_app_data = os.environ.get("LOCALAPPDATA")
        if not local_app_data:
            raise ContractError("LOCALAPPDATA is unavailable; set SHIPGLOWS_ENVIRONMENT_STATE_ROOT")
        return Path(local_app_data) / "ShipGlows" / "Environment"
    xdg_state = os.environ.get("XDG_STATE_HOME")
    return (Path(xdg_state) if xdg_state else Path.home() / ".local" / "state") / "shipglows" / "environment"


def _state_path(project_root: Path, state_root: Path) -> Path:
    return state_root / f"{project_identity(project_root)['id']}.json"


def _acquire_lock(lock_path: Path, timeout_seconds: float = 5.0) -> int:
    deadline = time.monotonic() + timeout_seconds
    while True:
        try:
            descriptor = os.open(str(lock_path), os.O_CREAT | os.O_EXCL | os.O_WRONLY, 0o600)
            os.write(descriptor, f"{os.getpid()}\n".encode("ascii"))
            os.fsync(descriptor)
            return descriptor
        except FileExistsError:
            try:
                age = max(0.0, time.time() - lock_path.stat().st_mtime)
            except FileNotFoundError:
                continue
            if age >= STATE_LOCK_STALE_SECONDS:
                try:
                    lock_path.unlink()
                except FileNotFoundError:
                    pass
                except OSError:
                    pass
                else:
                    continue
            if time.monotonic() >= deadline:
                raise ContractError(f"state lock timeout: {lock_path}")
            time.sleep(0.02)


def write_project_state(project_root: Path, state_root: Path, state: Mapping[str, Any]) -> Path:
    state_root.mkdir(mode=0o700, parents=True, exist_ok=True)
    if os.name != "nt":
        os.chmod(state_root, 0o700)
    target = _state_path(project_root, state_root)
    lock = target.with_suffix(target.suffix + ".lock")
    descriptor = _acquire_lock(lock)
    temporary: Optional[Path] = None
    try:
        safe_state = redact(dict(state))
        temporary = target.with_name(f".{target.name}.{os.getpid()}.{threading.get_ident()}.{time.time_ns()}.tmp")
        temporary_descriptor = os.open(str(temporary), os.O_CREAT | os.O_EXCL | os.O_WRONLY, 0o600)
        with os.fdopen(temporary_descriptor, "wb") as handle:
            handle.write(canonical_json(safe_state) + b"\n")
            handle.flush()
            os.fsync(handle.fileno())
        os.replace(temporary, target)
        if os.name != "nt":
            os.chmod(target, 0o600)
            directory_descriptor = os.open(str(state_root), os.O_RDONLY)
            try:
                os.fsync(directory_descriptor)
            finally:
                os.close(directory_descriptor)
        return target
    finally:
        os.close(descriptor)
        if temporary is not None:
            try:
                temporary.unlink()
            except FileNotFoundError:
                pass
        try:
            lock.unlink()
        except FileNotFoundError:
            pass


def read_project_state(project_root: Path, state_root: Optional[Path] = None) -> Optional[Dict[str, Any]]:
    root = state_root or default_state_root()
    target = _state_path(project_root, root)
    if not target.is_file():
        return None
    return _validate_state_record(load_json_strict(target, MAX_STATE_BYTES, "environment state"))


def verify_project(
    project_root: Path,
    state_root: Optional[Path] = None,
    runner=None,
    platform_name: Optional[str] = None,
    architecture: Optional[str] = None,
    offline: bool = False,
) -> Dict[str, Any]:
    root = project_root.resolve()
    desired = discover_project(root)
    observed = observe_project(
        desired,
        probe_versions=True,
        runner=runner,
        platform_name=platform_name,
        architecture=architecture,
        offline=offline,
    )
    plan = build_plan(
        desired,
        platform_name=platform_name,
        architecture=architecture,
        runner=runner,
        offline=offline,
    )
    state = {
        "schema": STATE_SCHEMA,
        "project": desired["project"],
        "management": desired["management"],
        "source_digest": desired["source_digest"],
        "plan": plan,
        "observed": observed,
        "observed_at": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        "desired": desired,
    }
    state["attestation"] = render_attestation(state)
    write_project_state(root, state_root or default_state_root(), state)
    return redact(state)


def status_project(project_root: Path, state_root: Optional[Path] = None, max_age_seconds: int = 3600) -> Dict[str, Any]:
    state = read_project_state(project_root, state_root)
    if state is None:
        return {"schema": STATE_SCHEMA, "project": project_identity(project_root), "status": "unknown", "reason": "verify has not recorded evidence"}
    status = state.get("observed", {}).get("status", "unknown")
    try:
        observed_at = datetime.fromisoformat(str(state["observed_at"]).replace("Z", "+00:00"))
        age = max(0.0, (datetime.now(timezone.utc) - observed_at).total_seconds())
    except (KeyError, TypeError, ValueError):
        age = float("inf")
    if age > max_age_seconds:
        status = "drifted" if status == "ready" else "unknown"
    return {**state, "status": status, "evidence_age_seconds": None if math.isinf(age) else round(age, 3)}


def render_attestation(state: Mapping[str, Any]) -> str:
    safe = redact(dict(state))
    project = safe.get("project", {})
    declared_project = safe.get("desired", {}).get("manifest", {}).get("project", {})
    project_label = declared_project.get("name") or declared_project.get("id") or str(project.get("id", "unknown"))[:12]
    observed = safe.get("observed", {})
    lines = [
        "# ShipGlows Environment Attestation",
        "",
        f"- Project: `{project_label}`",
        f"- Status: `{observed.get('status', safe.get('status', 'unknown'))}`",
        f"- Observed at: `{safe.get('observed_at', 'not recorded')}`",
        f"- Source digest: `{safe.get('source_digest', 'unknown')}`",
        "",
        "## Capabilities",
        "",
    ]
    capabilities = observed.get("capabilities", [])
    if not capabilities:
        lines.append("No capability evidence is recorded.")
    else:
        for capability in capabilities:
            label = f"{capability.get('kind')}/{capability.get('id')}"
            if capability.get("consumer"):
                label += f" [{capability['consumer']}]"
            details = []
            if capability.get("owner"):
                details.append(f"owner={capability['owner']}")
            if capability.get("version"):
                details.append(f"version={capability['version']}")
            suffix = f" ({'; '.join(details)})" if details else ""
            lines.append(f"- `{label}`: `{capability.get('status')}`{suffix}")
    return "\n".join(lines) + "\n"
