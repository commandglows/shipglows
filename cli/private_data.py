#!/usr/bin/env python3
"""Inspect and operate ShipGlows durable private data with explicit intent."""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any

MANIFEST_NAME = ".shipglows-private-data.json"
MANIFEST_SCHEMA_VERSION = 1
ALLOWED_CONFIG_KEYS = {"SHIPGLOWS_PRIVATE_DATA_REPO", "SHIPGLOWS_PRIVATE_DATA_DIR"}
ALLOWED_NAMESPACE_OPERATIONS = {"read", "write"}
WINDOWS_RESERVED_NAMES = {"CON", "PRN", "AUX", "NUL", *(f"COM{index}" for index in range(1, 10)), *(f"LPT{index}" for index in range(1, 10))}


class PrivateDataError(ValueError):
    """A redacted, operator-safe private-data failure."""


def config_path() -> Path:
    override = os.environ.get("SHIPGLOWS_PRIVATE_DATA_CONFIG_FILE")
    if override:
        return Path(override).expanduser()
    if os.name == "nt":
        return Path(os.environ.get("APPDATA", str(Path.home() / "AppData/Roaming"))) / "ShipGlows" / "private-data.env"
    return Path(os.environ.get("XDG_CONFIG_HOME", str(Path.home() / ".config"))) / "shipglows" / "private-data.env"


def load_config() -> dict[str, str]:
    path = config_path()
    values: dict[str, str] = {}
    if path.exists():
        if not path.is_file() or path.is_symlink():
            raise PrivateDataError("private-data configuration must be a regular file")
        if os.name != "nt":
            stat = path.stat()
            if stat.st_uid != os.getuid() or stat.st_mode & 0o077:
                raise PrivateDataError("private-data configuration permissions are unsafe")
        for raw in path.read_text(encoding="utf-8").splitlines():
            line = raw.strip()
            if not line or line.startswith("#"):
                continue
            if "=" not in line:
                raise PrivateDataError("private-data configuration contains an invalid declaration")
            key, value = line.split("=", 1)
            if key not in ALLOWED_CONFIG_KEYS or not value or any(ord(char) < 32 for char in value):
                raise PrivateDataError("private-data configuration contains an unsupported declaration")
            values[key] = value
    for key in ALLOWED_CONFIG_KEYS:
        if os.environ.get(key):
            values[key] = os.environ[key]
    parent = os.environ.get("SHIPGLOWS_PRIVATE_DIR", str(Path.home() / ".shipglows"))
    data_dir = Path(values.get("SHIPGLOWS_PRIVATE_DATA_DIR", str(Path(parent) / "data"))).expanduser()
    if not data_dir.is_absolute():
        raise PrivateDataError("private-data directory must be absolute")
    values["SHIPGLOWS_PRIVATE_DATA_DIR"] = str(data_dir)
    return values


def validate_repository_url(value: str) -> str:
    """Accept only explicit network Git URLs; never echo the supplied value."""
    if not value or any(character.isspace() for character in value):
        raise PrivateDataError("private-data repository URL is invalid")
    if re.match(r"^(https://|ssh://|git@)[^\s]+$", value) is None:
        raise PrivateDataError("private-data repository URL must use HTTPS or SSH")
    authority = value.split("/", 3)[2] if "://" in value else value.split(":", 1)[0]
    if ("://" in value and "@" in authority) or ":" in authority.replace("git@", "", 1):
        raise PrivateDataError("private-data repository URL must not contain credentials")
    return value


def protect_windows_path(path: Path) -> None:
    """Restrict the config to the current Windows identity when icacls is present."""
    identity = subprocess.run(
        ["powershell.exe", "-NoProfile", "-NonInteractive", "-Command", "[Security.Principal.WindowsIdentity]::GetCurrent().User.Value"],
        capture_output=True,
        text=True,
        check=False,
    )
    sid = identity.stdout.strip()
    if identity.returncode != 0 or not re.fullmatch(r"S-\d(?:-\d+)+", sid):
        raise PrivateDataError("private-data configuration permissions could not be secured")
    result = subprocess.run(["icacls.exe", str(path), "/inheritance:r", "/grant:r", f"*{sid}:(F)", "/c"], capture_output=True, text=True, check=False)
    if result.returncode != 0:
        raise PrivateDataError("private-data configuration permissions could not be secured")


def save_config(values: dict[str, str]) -> None:
    path = config_path()
    path.parent.mkdir(parents=True, exist_ok=True)
    if os.name != "nt":
        os.chmod(path.parent, 0o700)
    contents = "".join(f"{key}={values[key]}\n" for key in sorted(ALLOWED_CONFIG_KEYS) if values.get(key))
    descriptor, temporary_name = tempfile.mkstemp(prefix=".private-data-", dir=path.parent, text=True)
    temporary = Path(temporary_name)
    try:
        if os.name != "nt":
            os.chmod(temporary, 0o600)
        with os.fdopen(descriptor, "w", encoding="utf-8", newline="\n") as handle:
            handle.write(contents)
        os.replace(temporary, path)
        if os.name == "nt":
            protect_windows_path(path)
        else:
            os.chmod(path, 0o600)
    finally:
        if temporary.exists():
            temporary.unlink()


def validate_manifest(payload: Any) -> dict[str, Any]:
    if not isinstance(payload, dict) or set(payload) != {"schema_version", "namespaces"}:
        raise PrivateDataError("private-data manifest must contain only schema_version and namespaces")
    if payload["schema_version"] != MANIFEST_SCHEMA_VERSION or not isinstance(payload["namespaces"], dict):
        raise PrivateDataError("private-data manifest schema is invalid")
    for name, namespace in payload["namespaces"].items():
        if not isinstance(name, str) or not name or "/" in name or "\\" in name or name in {".", ".."}:
            raise PrivateDataError("private-data manifest namespace is invalid")
        if not isinstance(namespace, dict) or set(namespace) != {"path", "retention", "operations"}:
            raise PrivateDataError("private-data manifest namespace declaration is invalid")
        path = namespace["path"]
        retention = namespace["retention"]
        operations = namespace["operations"]
        if not isinstance(path, str) or not path or Path(path).is_absolute() or ".." in Path(path).parts:
            raise PrivateDataError("private-data manifest namespace path is invalid")
        if not isinstance(retention, str) or not retention.strip() or len(retention) > 160:
            raise PrivateDataError("private-data manifest retention is invalid")
        if not isinstance(operations, list) or not operations or set(operations) - ALLOWED_NAMESPACE_OPERATIONS:
            raise PrivateDataError("private-data manifest operations are invalid")
    return payload


def read_manifest(data_dir: Path) -> dict[str, Any]:
    manifest_path = data_dir / MANIFEST_NAME
    if not manifest_path.is_file() or manifest_path.is_symlink():
        raise PrivateDataError("private-data manifest is unavailable")
    if manifest_path.stat().st_size > 64 * 1024:
        raise PrivateDataError("private-data manifest exceeds its size limit")
    try:
        return validate_manifest(json.loads(manifest_path.read_text(encoding="utf-8")))
    except json.JSONDecodeError as error:
        raise PrivateDataError("private-data manifest is not valid JSON") from error


def inspect_manifest(data_dir: Path) -> tuple[str, str, dict[str, Any] | None]:
    """Classify repository generations without treating old or future schemas alike."""
    manifest_path = data_dir / MANIFEST_NAME
    if not manifest_path.exists():
        return "legacy", "missing", None
    if not manifest_path.is_file() or manifest_path.is_symlink():
        return "invalid", "invalid", None
    if manifest_path.stat().st_size > 64 * 1024:
        return "invalid", "invalid", None
    try:
        raw = json.loads(manifest_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return "invalid", "invalid", None
    if isinstance(raw, dict) and isinstance(raw.get("schema_version"), int) and raw["schema_version"] != MANIFEST_SCHEMA_VERSION:
        return "unsupported", "unsupported", None
    try:
        return "current", "valid", validate_manifest(raw)
    except PrivateDataError:
        return "invalid", "invalid", None


def is_windows_compatible_git_path(value: str) -> bool:
    for segment in value.replace("\\", "/").split("/"):
        if not segment or any(character in segment for character in ':*?"<>|') or segment.endswith((".", " ")):
            return False
        basename = segment.split(".", 1)[0].upper()
        if basename in WINDOWS_RESERVED_NAMES:
            return False
    return True


def repository_is_windows_portable(data_dir: Path) -> bool:
    result = subprocess.run(["git", "-C", str(data_dir), "ls-files", "-z"], capture_output=True, check=False)
    if result.returncode != 0:
        return False
    return all(is_windows_compatible_git_path(raw.decode("utf-8", errors="surrogateescape")) for raw in result.stdout.split(b"\0") if raw)


def git_state(data_dir: Path) -> str:
    result = subprocess.run(["git", "-C", str(data_dir), "status", "--porcelain"], capture_output=True, text=True, check=False)
    if result.returncode != 0:
        return "not_git"
    return "clean" if not result.stdout.strip() else "dirty"


def status() -> dict[str, Any]:
    values = load_config()
    data_dir = Path(values["SHIPGLOWS_PRIVATE_DATA_DIR"])
    payload: dict[str, Any] = {
        "configured": bool(values.get("SHIPGLOWS_PRIVATE_DATA_REPO")),
        "available": data_dir.is_dir(),
        "git_state": git_state(data_dir) if data_dir.is_dir() else "unavailable",
        "manifest": "unavailable",
        "repository_generation": "unavailable",
        "compatibility": "unavailable",
        "windows_portable": False,
        "namespaces": [],
    }
    if data_dir.is_dir() and payload["git_state"] != "not_git":
        generation, manifest_state, manifest = inspect_manifest(data_dir)
        payload["repository_generation"] = generation
        payload["manifest"] = manifest_state
        payload["compatibility"] = {"legacy": "migration_required", "current": "current", "unsupported": "unsupported", "invalid": "invalid"}[generation]
        payload["windows_portable"] = repository_is_windows_portable(data_dir)
        if manifest is not None:
            payload["namespaces"] = sorted(manifest["namespaces"].keys())
    return payload


def require_namespace(name: str, operation: str) -> dict[str, Any]:
    if operation not in ALLOWED_NAMESPACE_OPERATIONS:
        raise PrivateDataError("private-data operation is invalid")
    values = load_config()
    data_dir = Path(values["SHIPGLOWS_PRIVATE_DATA_DIR"])
    if not data_dir.is_dir() or git_state(data_dir) == "not_git":
        raise PrivateDataError("private-data repository is unavailable")
    manifest = read_manifest(data_dir)
    namespace = manifest["namespaces"].get(name)
    if namespace is None or operation not in namespace["operations"]:
        raise PrivateDataError("private-data namespace is unavailable for the requested operation")
    repository_root = data_dir.resolve()
    namespace_root = (data_dir / namespace["path"]).resolve()
    try:
        namespace_root.relative_to(repository_root)
    except ValueError as error:
        raise PrivateDataError("private-data namespace resolves outside its repository") from error
    if not namespace_root.is_dir():
        raise PrivateDataError("private-data namespace directory is unavailable")
    return {"capability": "granted", "namespace": name, "operation": operation}


def sync(direction: str, apply: bool) -> dict[str, Any]:
    values = load_config()
    data_dir = Path(values["SHIPGLOWS_PRIVATE_DATA_DIR"])
    if not data_dir.is_dir() or git_state(data_dir) == "not_git":
        raise PrivateDataError("private-data repository is unavailable")
    if git_state(data_dir) != "clean":
        raise PrivateDataError("private-data synchronization requires a clean repository")
    upstream = subprocess.run(["git", "-C", str(data_dir), "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{upstream}"], capture_output=True, text=True, check=False)
    if upstream.returncode != 0 or not upstream.stdout.strip():
        raise PrivateDataError("private-data synchronization requires a configured upstream")
    if not apply:
        return {"sync": "planned", "direction": direction, "git_state": "clean"}
    command = ["git", "-C", str(data_dir), "pull", "--ff-only"] if direction == "pull" else ["git", "-C", str(data_dir), "push"]
    result = subprocess.run(command, capture_output=True, text=True, check=False)
    if result.returncode != 0:
        raise PrivateDataError("private-data synchronization did not complete")
    return {"sync": "applied", "direction": direction, "git_state": "clean"}


def connect(repository_url: str, apply: bool, existing: bool, directory: str | None) -> dict[str, Any]:
    repository_url = validate_repository_url(repository_url)
    values = load_config()
    data_dir = Path(directory).expanduser() if directory else Path(values["SHIPGLOWS_PRIVATE_DATA_DIR"])
    if not data_dir.is_absolute():
        raise PrivateDataError("private-data directory must be absolute")
    if existing:
        if not data_dir.is_dir() or data_dir.is_symlink() or git_state(data_dir) == "not_git":
            raise PrivateDataError("existing private-data repository is unavailable")
        if git_state(data_dir) != "clean":
            raise PrivateDataError("existing private-data repository must be clean")
        remote = subprocess.run(["git", "-C", str(data_dir), "remote", "get-url", "origin"], capture_output=True, text=True, check=False)
        if remote.returncode != 0 or remote.stdout.strip() != repository_url:
            raise PrivateDataError("existing private-data repository remote does not match")
    elif data_dir.exists() or data_dir.is_symlink():
        raise PrivateDataError("private-data destination already exists")
    if not apply:
        return {"connect": "planned", "mode": "adopt" if existing else "clone"}
    if not existing:
        data_dir.parent.mkdir(parents=True, exist_ok=True)
        result = subprocess.run(["git", "clone", "--", repository_url, str(data_dir)], capture_output=True, text=True, check=False)
        if result.returncode != 0:
            # A failed clone may leave a partial directory; preserve it for operator inspection.
            raise PrivateDataError("private-data clone did not complete")
    values["SHIPGLOWS_PRIVATE_DATA_REPO"] = repository_url
    values["SHIPGLOWS_PRIVATE_DATA_DIR"] = str(data_dir)
    save_config(values)
    connected_status = status()
    return {"connect": "applied", "mode": "adopt" if existing else "clone", "manifest": connected_status["manifest"], "compatibility": connected_status["compatibility"]}


def migrate(manifest_source: str, apply: bool) -> dict[str, Any]:
    values = load_config()
    data_dir = Path(values["SHIPGLOWS_PRIVATE_DATA_DIR"])
    if not data_dir.is_dir() or git_state(data_dir) == "not_git":
        raise PrivateDataError("private-data repository is unavailable")
    if git_state(data_dir) != "clean":
        raise PrivateDataError("private-data migration requires a clean repository")
    generation, _, _ = inspect_manifest(data_dir)
    if generation == "current":
        return {"migration": "not_needed", "from_generation": "current", "to_schema": MANIFEST_SCHEMA_VERSION}
    if generation != "legacy":
        raise PrivateDataError("private-data repository generation cannot be migrated automatically")
    source = Path(manifest_source).expanduser()
    if not source.is_absolute() or not source.is_file() or source.is_symlink() or source.stat().st_size > 64 * 1024:
        raise PrivateDataError("private-data migration manifest is unavailable")
    try:
        manifest = validate_manifest(json.loads(source.read_text(encoding="utf-8")))
    except json.JSONDecodeError as error:
        raise PrivateDataError("private-data migration manifest is not valid JSON") from error
    for namespace in manifest["namespaces"].values():
        namespace_root = (data_dir / namespace["path"]).resolve()
        try:
            namespace_root.relative_to(data_dir.resolve())
        except ValueError as error:
            raise PrivateDataError("private-data migration namespace resolves outside its repository") from error
        if not namespace_root.is_dir():
            raise PrivateDataError("private-data migration namespace directory is unavailable")
    if not apply:
        return {"migration": "planned", "from_generation": "legacy", "to_schema": MANIFEST_SCHEMA_VERSION}
    target = data_dir / MANIFEST_NAME
    descriptor, temporary_name = tempfile.mkstemp(prefix=".private-data-manifest-", dir=data_dir, text=True)
    temporary = Path(temporary_name)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8", newline="\n") as handle:
            json.dump(manifest, handle, ensure_ascii=False, indent=2, sort_keys=True)
            handle.write("\n")
        os.replace(temporary, target)
    finally:
        if temporary.exists():
            temporary.unlink()
    return {"migration": "applied", "from_generation": "legacy", "to_schema": MANIFEST_SCHEMA_VERSION}


def open_data_dir(apply: bool) -> dict[str, Any]:
    values = load_config()
    data_dir = Path(values["SHIPGLOWS_PRIVATE_DATA_DIR"])
    if not data_dir.is_dir() or git_state(data_dir) == "not_git":
        raise PrivateDataError("private-data repository is unavailable")
    if not apply:
        return {"open": "planned"}
    if os.name == "nt":
        os.startfile(str(data_dir))  # type: ignore[attr-defined]
    elif sys.platform == "darwin":
        subprocess.Popen(["open", str(data_dir)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    else:
        opener = shutil.which("xdg-open")
        if opener is None:
            raise PrivateDataError("no supported folder opener is available")
        subprocess.Popen([opener, str(data_dir)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return {"open": "applied"}


def render(payload: dict[str, Any], output_format: str) -> None:
    if output_format == "json":
        print(json.dumps(payload, ensure_ascii=False, sort_keys=True))
        return
    for key, value in payload.items():
        print(f"{key}: {value}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--format", choices=("json", "text"), default="text")
    commands = parser.add_subparsers(dest="command", required=True)
    commands.add_parser("status")
    commands.add_parser("doctor")
    capability = commands.add_parser("capability")
    capability.add_argument("namespace")
    capability.add_argument("operation", choices=sorted(ALLOWED_NAMESPACE_OPERATIONS))
    sync_command = commands.add_parser("sync")
    sync_command.add_argument("direction", choices=("pull", "push"))
    sync_command.add_argument("--apply", action="store_true", help="Perform the explicitly planned Git synchronization.")
    connect_command = commands.add_parser("connect")
    connect_command.add_argument("--repo", required=True, help="HTTPS or SSH Git URL; it is never printed by this command.")
    connect_command.add_argument("--existing", action="store_true", help="Adopt an existing clean clone instead of cloning it.")
    connect_command.add_argument("--dir", help="Absolute existing or clone destination; it is never printed by this command.")
    connect_command.add_argument("--apply", action="store_true", help="Clone and persist the explicit private-data connection.")
    migrate_command = commands.add_parser("migrate")
    migrate_command.add_argument("--manifest", required=True, help="Absolute path to a schema-current manifest proposal.")
    migrate_command.add_argument("--apply", action="store_true", help="Atomically apply the planned repository-format migration.")
    open_command = commands.add_parser("open")
    open_command.add_argument("--apply", action="store_true", help="Open the private-data folder in the local file manager.")
    return parser.parse_args()


def main() -> int:
    try:
        args = parse_args()
        if args.command in {"status", "doctor"}:
            payload = status()
            healthy = bool(payload["available"] and payload["git_state"] == "clean" and payload["compatibility"] == "current" and payload["windows_portable"])
            payload["healthy"] = healthy
            if args.command == "doctor" and not healthy:
                render(payload, args.format)
                return 2
        elif args.command == "capability":
            payload = require_namespace(args.namespace, args.operation)
        elif args.command == "sync":
            payload = sync(args.direction, args.apply)
        elif args.command == "connect":
            payload = connect(args.repo, args.apply, args.existing, args.dir)
        elif args.command == "migrate":
            payload = migrate(args.manifest, args.apply)
        else:
            payload = open_data_dir(args.apply)
        render(payload, args.format)
        return 0
    except PrivateDataError as error:
        print(f"ShipGlows private data: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
