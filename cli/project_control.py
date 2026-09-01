#!/usr/bin/env python3
"""Closed non-interactive project creation control plane."""

from __future__ import annotations

import json
import os
from pathlib import Path
import re
import secrets
import subprocess
import sys
import tempfile
from datetime import datetime, timezone
import unicodedata

SCHEMA = "shipglows.cli-project-registry.v1"
NAME_MAX = 120
IDEMPOTENCY_RE = re.compile(r"^[A-Za-z0-9_-]{16,128}$")
ACCOUNT_RE = re.compile(r"^[A-Za-z][A-Za-z0-9_-]{7,128}$")
REPOSITORY_ID_RE = re.compile(r"^[0-9]+$")
REPOSITORY_NAME_RE = re.compile(r"^[A-Za-z0-9_.-]{1,100}/[A-Za-z0-9_.-]{1,100}$")


class Refused(Exception):
    def __init__(self, code: str) -> None:
        super().__init__(code)
        self.code = code


def emit(payload: dict, *, error: bool = False) -> None:
    print(json.dumps(payload, separators=(",", ":")), file=sys.stderr if error else sys.stdout)


def normalized_name(value: object) -> str:
    if not isinstance(value, str):
        raise Refused("invalidProjectName")
    value = unicodedata.normalize("NFC", value).strip()
    if not value or len(value) > NAME_MAX or any(unicodedata.category(char) == "Cc" for char in value):
        raise Refused("invalidProjectName")
    return value


def canonical_repository_root(value: object) -> str:
    if not isinstance(value, str) or not value or "\x00" in value:
        raise Refused("invalidRepositoryBinding")
    root = Path(value)
    if not root.is_absolute() or not root.is_dir() or not (root / ".git").exists():
        raise Refused("repositoryUnavailable")
    resolved = root.resolve()
    projects_root = Path(os.environ.get("SHIPGLOWS_PROJECTS_DIR", str(Path.home()))).resolve()
    try:
        resolved.relative_to(projects_root)
    except ValueError:
        raise Refused("repositoryUnavailable")
    return str(resolved)


def read_request() -> dict:
    try:
        raw = sys.stdin.buffer.read(65537)
        if len(raw) > 65536:
            raise Refused("invalidRequest")
        data = json.loads(raw)
    except (UnicodeDecodeError, json.JSONDecodeError):
        raise Refused("invalidRequest")
    if not isinstance(data, dict) or set(data) != {"idempotencyKey", "displayName", "ownerAccountId", "repository"}:
        raise Refused("invalidRequest")
    repository = data["repository"]
    if not isinstance(repository, dict) or set(repository) != {"id", "fullName", "rootPath"}:
        raise Refused("invalidRepositoryBinding")
    if not isinstance(data["idempotencyKey"], str) or not IDEMPOTENCY_RE.fullmatch(data["idempotencyKey"]):
        raise Refused("invalidIdempotencyKey")
    if not isinstance(data["ownerAccountId"], str) or not ACCOUNT_RE.fullmatch(data["ownerAccountId"]):
        raise Refused("invalidOwner")
    repository_id = str(repository["id"])
    if not REPOSITORY_ID_RE.fullmatch(repository_id) or not isinstance(repository["fullName"], str) or not REPOSITORY_NAME_RE.fullmatch(repository["fullName"]):
        raise Refused("invalidRepositoryBinding")
    return {"idempotencyKey": data["idempotencyKey"], "displayName": normalized_name(data["displayName"]),
            "ownerAccountId": data["ownerAccountId"], "repositoryId": repository_id,
            "repositoryFullName": repository["fullName"], "cwd": canonical_repository_root(repository["rootPath"])}


def load_registry(path: Path) -> dict:
    if not path.exists():
        return {"schemaVersion": SCHEMA, "projects": []}
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        raise Refused("registryUnavailable")
    if not isinstance(data, dict) or data.get("schemaVersion") != SCHEMA or not isinstance(data.get("projects"), list):
        raise Refused("registryUnavailable")
    return data


def atomic_write(path: Path, data: dict) -> None:
    path.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
    descriptor, temp_name = tempfile.mkstemp(prefix=".project-registry-", dir=path.parent)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as stream:
            json.dump(data, stream, ensure_ascii=False, indent=2)
            stream.write("\n")
            stream.flush()
            os.fsync(stream.fileno())
        os.chmod(temp_name, 0o600)
        os.replace(temp_name, path)
    finally:
        try:
            os.unlink(temp_name)
        except FileNotFoundError:
            pass


def refresh_catalog(script_dir: Path) -> None:
    command = ['source "$1/lib.sh"; refresh_cli_project_catalog']
    completed = subprocess.run(["bash", "-c", command[0], "shipglows-project-create", str(script_dir)],
                               stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                               timeout=30, check=False)
    if completed.returncode != 0:
        raise Refused("catalogRefreshFailed")


def _create_locked(script_dir: Path, request: dict, registry_path: Path) -> dict:
    state_dir = Path(os.environ.get("SHIPGLOWS_STATE_DIR", str(Path.home() / ".shipglows")))
    registry = load_registry(registry_path)
    matching_key = next((item for item in registry["projects"] if item.get("idempotencyKey") == request["idempotencyKey"]), None)
    fingerprint = tuple(request[key] for key in ("displayName", "ownerAccountId", "repositoryId", "repositoryFullName", "cwd"))
    if matching_key:
        existing = tuple(matching_key.get(key) for key in ("displayName", "ownerAccountId", "repositoryId", "repositoryFullName", "cwd"))
        if existing != fingerprint:
            raise Refused("idempotencyConflict")
        return matching_key
    try:
        maximum = int(os.environ.get("SHIPGLOWS_CLI_PROJECT_CATALOG_MAX_PROJECTS", "256"))
    except ValueError:
        raise Refused("projectCreateUnavailable")
    if maximum < 1 or len(registry["projects"]) >= maximum:
        raise Refused("projectCapacityReached")
    if any(item.get("repositoryId") == request["repositoryId"] or item.get("cwd") == request["cwd"] for item in registry["projects"]):
        raise Refused("repositoryAlreadyRegistered")
    project = {"id": f"prj_{secrets.token_hex(16)}", **request,
               "createdAt": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")}
    original = json.loads(json.dumps(registry))
    registry["projects"].append(project)
    atomic_write(registry_path, registry)
    try:
        refresh_catalog(script_dir)
    except Exception:
        atomic_write(registry_path, original)
        raise
    return project


def create(script_dir: Path) -> dict:
    request = read_request()
    state_dir = Path(os.environ.get("SHIPGLOWS_STATE_DIR", str(Path.home() / ".shipglows")))
    registry_path = Path(os.environ.get("SHIPGLOWS_CLI_PROJECT_REGISTRY_FILE", str(state_dir / "cli-project-registry.v1.json")))
    registry_path.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
    lock_path = registry_path.with_name(f".{registry_path.name}.lock")
    try:
        lock_path.mkdir(mode=0o700)
    except FileExistsError:
        raise Refused("projectCreateBusy")
    try:
        return _create_locked(script_dir, request, registry_path)
    finally:
        lock_path.rmdir()


def main() -> int:
    if sys.argv[1:] != ["create"]:
        emit({"status": "invalid", "code": "unsupportedCommand"}, error=True)
        return 2
    try:
        project = create(Path(__file__).resolve().parent)
        emit({"status": "created", "project": {"id": project["id"], "displayName": project["displayName"],
             "ownerAccountId": project["ownerAccountId"], "repository": {"id": project["repositoryId"],
             "fullName": project["repositoryFullName"]}, "createdAt": project["createdAt"]}})
        return 0
    except Refused as exc:
        emit({"status": "refused", "code": exc.code}, error=True)
        return 1
    except (OSError, subprocess.SubprocessError):
        emit({"status": "unavailable", "code": "projectCreateUnavailable"}, error=True)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
