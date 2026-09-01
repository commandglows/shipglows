"""Narrow Windows mise backend for the project-local Node 24 + pnpm 10 pilot.

The module treats repository files as data, accepts only the safe plain
``[tools]`` configuration shape for Node and pnpm, and reconstructs every
process request from fixed adapter semantics. Persisted plans never supply argv.
"""

from __future__ import annotations

import hashlib
import json
import os
import re
import shutil
import subprocess
import tomllib
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Mapping, Optional, Protocol, Sequence, Tuple
from urllib.parse import urlsplit


MISE_INSTALL_DOC = "https://mise.jdx.dev/installing-mise.html#windows-winget"
MISE_EXEC_DOC = "https://mise.jdx.dev/cli/exec.html"
MISE_LOCK_DOC = "https://mise.jdx.dev/dev-tools/mise-lock.html"
MISE_OFFLINE_DOC = "https://mise.jdx.dev/configuration/settings.html#offline"
MISE_PACKAGE_ID = "jdx.mise"
MAX_OUTPUT_CHARS = 16_384
MAX_EXECUTABLE_BYTES = 256 * 1024 * 1024
MISE_VERSION = re.compile(r"(?<!\d)(\d{4}\.\d+(?:\.\d+)?)(?!\d)")
NODE_VERSION = re.compile(r"^v?(24\.\d+\.\d+)$")
PNPM_VERSION = re.compile(r"^v?(10\.\d+\.\d+)$")
TOOL_CONSTRAINTS = {"node": "24", "pnpm": "10"}
TOOL_VERSION_PATTERNS = {"node": NODE_VERSION, "pnpm": PNPM_VERSION}
CHECKSUM = re.compile(r"^(?:(?:sha256|blake3):)?[0-9a-fA-F]{64}$")
SAFE_INHERITED_ENVIRONMENT = {
    "APPDATA",
    "COMSPEC",
    "HOMEDRIVE",
    "HOMEPATH",
    "LANG",
    "LC_ALL",
    "LOCALAPPDATA",
    "NUMBER_OF_PROCESSORS",
    "OS",
    "PATH",
    "PATHEXT",
    "PROCESSOR_ARCHITECTURE",
    "PROCESSOR_IDENTIFIER",
    "PROGRAMDATA",
    "PROGRAMFILES",
    "PROGRAMFILES(X86)",
    "PROGRAMW6432",
    "SYSTEMROOT",
    "TEMP",
    "TMP",
    "USERDOMAIN",
    "USERNAME",
    "USERPROFILE",
    "WINDIR",
}


class MisePilotError(ValueError):
    """The project or backend evidence is outside the bounded pilot."""


@dataclass(frozen=True)
class ProcessRequest:
    """Structured process invocation with bounded, non-secret overrides."""

    purpose: str
    argv: Tuple[str, ...]
    cwd: Path
    environment: Mapping[str, str]
    timeout_seconds: float


@dataclass(frozen=True)
class ProcessResult:
    returncode: Optional[int]
    stdout: str
    stderr: str
    timed_out: bool = False


@dataclass(frozen=True)
class ExecutableIdentity:
    path: str
    sha256: str


class StructuredRunner(Protocol):
    def which(self, executable: str) -> Optional[str]: ...

    def trusted_roots(self, executable: str) -> Sequence[Path]: ...

    def run(self, request: ProcessRequest) -> ProcessResult: ...


def _known_windows_folder(identifier: str) -> Optional[Path]:
    """Resolve a Windows known folder without trusting inherited path variables."""

    if os.name != "nt":
        return None
    try:
        import ctypes
        from ctypes import wintypes

        class Guid(ctypes.Structure):
            _fields_ = (
                ("data1", wintypes.DWORD),
                ("data2", wintypes.WORD),
                ("data3", wintypes.WORD),
                ("data4", ctypes.c_ubyte * 8),
            )

        guid = Guid()
        ole32 = ctypes.windll.ole32
        shell32 = ctypes.windll.shell32
        if ole32.CLSIDFromString(identifier, ctypes.byref(guid)) != 0:
            return None
        value = ctypes.c_wchar_p()
        if shell32.SHGetKnownFolderPath(ctypes.byref(guid), 0, None, ctypes.byref(value)) != 0:
            return None
        try:
            return Path(value.value).resolve(strict=False) if value.value else None
        finally:
            ole32.CoTaskMemFree(ctypes.cast(value, ctypes.c_void_p))
    except (AttributeError, OSError, ValueError):
        return None


def _windows_desktop_app_installer_roots() -> Sequence[Path]:
    """Resolve App Installer package roots without executing a shell."""

    if os.name != "nt":
        return ()
    try:
        import winreg

        key_path = (
            r"Software\Classes\Local Settings\Software\Microsoft\Windows"
            r"\CurrentVersion\AppModel\Repository\Packages"
        )
        program_files = _known_windows_folder("{905e63b6-c1bf-494e-b29c-65b732d3d21a}")
        if program_files is None:
            return ()
        windows_apps = (program_files / "WindowsApps").resolve(strict=False)
        roots = []
        with winreg.OpenKey(winreg.HKEY_CURRENT_USER, key_path) as packages:
            index = 0
            while True:
                try:
                    package_id = winreg.EnumKey(packages, index)
                except OSError:
                    break
                index += 1
                if not re.fullmatch(
                    r"Microsoft[.]DesktopAppInstaller_[0-9.]+_(?:x64|arm64|neutral)__8wekyb3d8bbwe",
                    package_id,
                    flags=re.IGNORECASE,
                ):
                    continue
                try:
                    with winreg.OpenKey(packages, package_id) as package:
                        raw_root, value_type = winreg.QueryValueEx(package, "PackageRootFolder")
                except OSError:
                    continue
                if value_type not in (winreg.REG_SZ, winreg.REG_EXPAND_SZ) or not isinstance(raw_root, str):
                    continue
                root = Path(os.path.expandvars(raw_root)).resolve(strict=False)
                try:
                    root.relative_to(windows_apps)
                except ValueError:
                    continue
                if root.name.lower() != package_id.lower():
                    continue
                roots.append(root)
        return tuple(sorted(set(roots), key=lambda item: str(item).lower(), reverse=True))
    except (ImportError, OSError, ValueError):
        return ()


class SubprocessRunner:
    """OS runner used only after core approval and semantic validation."""

    def which(self, executable: str) -> Optional[str]:
        resolved = shutil.which(executable)
        if resolved:
            return resolved
        for raw_root in self.trusted_roots(executable):
            root = Path(raw_root).resolve(strict=False)
            candidate = root if root.name.lower() == executable.lower() else root / executable
            try:
                if candidate.is_file() and candidate.stat().st_size > 0:
                    return str(candidate)
            except OSError:
                continue
        return None

    def trusted_roots(self, executable: str) -> Sequence[Path]:
        """Return documented package-manager locations, never arbitrary PATH roots."""

        if os.name != "nt":
            return ()
        local_app_data = _known_windows_folder("{F1B32785-6FBA-4FCF-9D55-7B8E7F157091}")
        user_profile = _known_windows_folder("{5E6C858F-0E22-4760-9AFE-EA3317B67173}")
        program_files = _known_windows_folder("{905e63b6-c1bf-494e-b29c-65b732d3d21a}")
        candidates = []
        if executable.lower() == "mise.exe":
            if local_app_data:
                candidates.extend(
                    (
                        local_app_data / "Microsoft" / "WinGet" / "Links" / "mise.exe",
                        local_app_data / "mise" / "bin",
                    )
                )
                packages = local_app_data / "Microsoft" / "WinGet" / "Packages"
                if packages.is_dir():
                    for path in packages.glob("jdx.mise_*"):
                        if not path.is_dir():
                            continue
                        candidates.extend((path / "mise" / "bin" / "mise.exe", path))
            if user_profile:
                candidates.extend(
                    (
                        user_profile / "scoop" / "shims" / "mise.exe",
                        user_profile / "scoop" / "apps" / "mise",
                    )
                )
            if program_files:
                candidates.append(program_files / "mise")
        elif executable.lower() == "winget.exe":
            if local_app_data:
                candidates.append(local_app_data / "Microsoft" / "WindowsApps" / "winget.exe")
            candidates.extend(_windows_desktop_app_installer_roots())
            windows_apps = program_files / "WindowsApps" if program_files is not None else None
            if windows_apps and windows_apps.is_dir():
                candidates.extend(
                    path / "winget.exe"
                    for path in windows_apps.glob("Microsoft.DesktopAppInstaller_*")
                    if path.is_dir()
                )
        return tuple(candidates)

    def run(self, request: ProcessRequest) -> ProcessResult:
        # Keep only OS/process essentials. Backend children do not need ambient
        # application credentials, provider tokens, or unrelated project state.
        # PATH is inherited byte-for-byte but never mutated persistently.
        environment = {
            key: value
            for key, value in os.environ.items()
            if key.upper() in SAFE_INHERITED_ENVIRONMENT
        }
        environment.update(request.environment)
        try:
            process = subprocess.run(
                list(request.argv),
                cwd=str(request.cwd),
                env=environment,
                stdin=subprocess.DEVNULL,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                encoding="utf-8",
                errors="replace",
                timeout=request.timeout_seconds,
                check=False,
                shell=False,
            )
        except subprocess.TimeoutExpired as exc:
            return ProcessResult(
                None,
                _bounded_output(exc.stdout),
                _bounded_output(exc.stderr),
                True,
            )
        except OSError as exc:
            return ProcessResult(None, "", type(exc).__name__, False)
        return ProcessResult(
            process.returncode,
            _bounded_output(process.stdout),
            _bounded_output(process.stderr),
            False,
        )


def _bounded_output(value) -> str:
    if value is None:
        return ""
    if isinstance(value, bytes):
        value = value.decode("utf-8", errors="replace")
    return str(value)[:MAX_OUTPUT_CHARS]


def _platform_key(architecture: str) -> str:
    normalized = architecture.strip().lower()
    if normalized in ("x86_64", "amd64", "x64"):
        return "windows-x64"
    if normalized in ("aarch64", "arm64"):
        return "windows-arm64"
    raise MisePilotError(f"mise tool pilot does not support Windows architecture {architecture!r}")


def _sha256_executable(path: Path) -> str:
    try:
        if not path.is_file() or path.stat().st_size <= 0 or path.stat().st_size > MAX_EXECUTABLE_BYTES:
            raise MisePilotError("backend executable is absent or exceeds the size limit")
        digest = hashlib.sha256()
        with path.open("rb") as handle:
            while chunk := handle.read(1024 * 1024):
                digest.update(chunk)
        return digest.hexdigest()
    except MisePilotError:
        raise
    except OSError as exc:
        raise MisePilotError(f"backend executable identity could not be read: {type(exc).__name__}") from exc


def _trusted_executable(
    path: str,
    expected_name: str,
    project_root: Path,
    runner: StructuredRunner,
) -> Optional[ExecutableIdentity]:
    """Accept a fixed-name executable only from the runner's canonical install roots."""

    candidate = Path(path).resolve(strict=False)
    if candidate.name.lower() != expected_name.lower():
        return None
    try:
        candidate.relative_to(project_root.resolve())
    except ValueError:
        pass
    else:
        return None
    trusted_roots = tuple(
        Path(raw_root).resolve(strict=False)
        for raw_root in runner.trusted_roots(expected_name)
    )
    trusted = False
    for root in trusted_roots:
        if candidate == root:
            trusted = True
            break
        try:
            candidate.relative_to(root)
        except ValueError:
            continue
        else:
            trusted = True
            break
    if not trusted:
        return None
    try:
        return ExecutableIdentity(str(candidate), _sha256_executable(candidate))
    except MisePilotError:
        if expected_name.lower() != "winget.exe":
            return None
    for root in trusted_roots:
        packaged_candidate = root if root.name.lower() == expected_name.lower() else root / expected_name
        if packaged_candidate == candidate or packaged_candidate.name.lower() != expected_name.lower():
            continue
        try:
            packaged_candidate.relative_to(project_root.resolve())
        except ValueError:
            pass
        else:
            continue
        try:
            return ExecutableIdentity(
                str(packaged_candidate),
                _sha256_executable(packaged_candidate),
            )
        except MisePilotError:
            continue
    return None


def _identity_references(base: Sequence[str], identity: Optional[ExecutableIdentity]) -> list[str]:
    if identity is None:
        return list(base)
    return [*base, f"executable:{identity.path}", f"sha256:{identity.sha256}"]


def _identity_from_references(references: object, base: Sequence[str]) -> Optional[ExecutableIdentity]:
    if references == list(base):
        return None
    if not isinstance(references, list) or len(references) != len(base) + 2 or references[: len(base)] != list(base):
        raise MisePilotError("approved executable identity references are invalid")
    path_value, digest_value = references[-2:]
    if not isinstance(path_value, str) or not path_value.startswith("executable:"):
        raise MisePilotError("approved executable path reference is invalid")
    if not isinstance(digest_value, str) or not re.fullmatch(r"sha256:[0-9a-f]{64}", digest_value):
        raise MisePilotError("approved executable digest reference is invalid")
    return ExecutableIdentity(path_value[len("executable:") :], digest_value[len("sha256:") :])


def _read_toml(path: Path, label: str) -> Dict:
    try:
        if path.stat().st_size > 8 * 1024 * 1024:
            raise MisePilotError(f"{label} exceeds the 8388608-byte size limit")
        with path.open("rb") as handle:
            value = tomllib.load(handle)
    except MisePilotError:
        raise
    except (OSError, tomllib.TOMLDecodeError) as exc:
        raise MisePilotError(f"invalid {label}: {type(exc).__name__}") from exc
    if not isinstance(value, dict):
        raise MisePilotError(f"{label} must be a TOML table")
    return value


def _unique_json_object(pairs):
    value = {}
    for key, item in pairs:
        if key in value:
            raise MisePilotError(f"package.json contains duplicate key {key!r}")
        value[key] = item
    return value


def _reject_json_constant(value: str):
    raise MisePilotError(f"package.json contains non-finite value {value}")


def load_pilot_contract(project_root: Path, config_path: Path, architecture: str) -> Dict:
    """Validate the code-free mise config and exact Windows lock entry."""

    root = project_root.resolve()
    config = config_path.resolve()
    try:
        config.relative_to(root)
    except ValueError as exc:
        raise MisePilotError("mise.toml escapes the project root") from exc
    if config.name != "mise.toml" or config.parent != root:
        raise MisePilotError("the pilot accepts only a root mise.toml")

    # These files participate in mise's early or local configuration cascade.
    # The runner also forces an exact filename, but rejecting them keeps the
    # source contract auditable and defense-in-depth against future mise drift.
    alternate_config_paths = (
        root / "mise.local.toml",
        root / ".mise.toml",
        root / ".mise.local.toml",
        root / "mise" / "config.toml",
        root / ".mise" / "config.toml",
        root / ".config" / "mise.toml",
        root / ".config" / "mise" / "config.toml",
        root / ".miserc.toml",
        root / ".config" / "miserc.toml",
        root / ".shipglows-no-system-mise-config",
        root / ".shipglows-no-user-mise-config",
    )
    conf_fragments = root / ".config" / "mise" / "conf.d"
    if any(path.exists() for path in alternate_config_paths) or (
        conf_fragments.is_dir() and any(conf_fragments.glob("*.toml"))
    ):
        raise MisePilotError("alternate mise configuration is outside the bounded pilot")

    config_value = _read_toml(config, "mise.toml")
    if set(config_value) != {"tools"}:
        raise MisePilotError(
            "mise.toml is outside the code-free pilot: only [tools] is accepted"
        )
    tools = config_value.get("tools")
    if not isinstance(tools, dict) or tools != TOOL_CONSTRAINTS:
        raise MisePilotError(
            'mise.toml must contain only [tools] node = "24" and pnpm = "10"'
        )

    lock_path = root / "mise.lock"
    if not lock_path.is_file():
        raise MisePilotError(
            "mise.lock is required before approval so Node 24 and pnpm 10 resolve to exact versions"
        )
    if lock_path.resolve().parent != root:
        raise MisePilotError("mise.lock escapes the project root")
    lock_value = _read_toml(lock_path, "mise.lock")
    if set(lock_value) != {"tools"}:
        raise MisePilotError("mise.lock contains unsupported top-level data")
    lock_tools = lock_value.get("tools")
    platform_key = _platform_key(architecture)
    architecture_name = "x64" if platform_key == "windows-x64" else "arm64"
    if not isinstance(lock_tools, dict) or set(lock_tools) != set(TOOL_CONSTRAINTS):
        raise MisePilotError("mise.lock must contain exactly Node and pnpm tool entries")

    contracts = {}
    for tool in ("node", "pnpm"):
        entries = lock_tools.get(tool)
        if not isinstance(entries, list) or len(entries) != 1 or not isinstance(entries[0], dict):
            raise MisePilotError(f"mise.lock must contain exactly one [[tools.{tool}]] entry")
        entry = entries[0]
        if set(entry) - {"version", "backend", "platforms"}:
            raise MisePilotError(f"mise.lock {tool} entry contains unsupported fields")
        version = entry.get("version")
        if not isinstance(version, str) or not TOOL_VERSION_PATTERNS[tool].fullmatch(version):
            raise MisePilotError(
                f"mise.lock must pin one exact {tool} {TOOL_CONSTRAINTS[tool]} version"
            )
        expected_backend = "core:node" if tool == "node" else "aqua:pnpm/pnpm"
        if entry.get("backend") != expected_backend:
            raise MisePilotError(f"mise.lock {tool} ownership must be {expected_backend}")
        platforms = entry.get("platforms")
        platform_value = platforms.get(platform_key) if isinstance(platforms, dict) else None
        if not isinstance(platform_value, dict):
            raise MisePilotError(f"mise.lock {tool} has no {platform_key} artifact evidence")
        if set(platform_value) - {"checksum", "size", "url"}:
            raise MisePilotError(f"mise.lock {tool} platform entry contains unsupported fields")
        checksum = platform_value.get("checksum")
        url = platform_value.get("url")
        size = platform_value.get("size")
        if not isinstance(checksum, str) or not CHECKSUM.fullmatch(checksum):
            raise MisePilotError(f"mise.lock has no supported checksum for the Windows {tool} artifact")
        if size is not None and (not isinstance(size, int) or isinstance(size, bool) or size <= 0):
            raise MisePilotError(f"mise.lock has an invalid Windows {tool} artifact size")
        if not isinstance(url, str):
            raise MisePilotError(f"mise.lock has no pre-resolved Windows {tool} URL")
        parts = urlsplit(url)
        expected_host = "nodejs.org" if tool == "node" else "github.com"
        expected_path = (
            f"/dist/v{version}/node-v{version}-win-{architecture_name}.zip"
            if tool == "node"
            else f"/pnpm/pnpm/releases/download/v{version}/pnpm-win-{architecture_name}.exe"
        )
        if (
            parts.scheme != "https"
            or (parts.hostname or "").lower() != expected_host
            or parts.port not in (None, 443)
            or parts.path != expected_path
            or parts.query
            or parts.fragment
            or parts.username
            or parts.password
        ):
            raise MisePilotError(
                f"mise.lock {tool} artifact must use its official HTTPS release authority"
            )
        contracts[tool] = {
            "version": version,
            "constraint": TOOL_CONSTRAINTS[tool],
            "integrity": "mise.lock checksum",
            "provenance": f"not recorded by the {expected_backend} lock entry",
        }

    package_path = root / "package.json"
    if package_path.exists():
        try:
            if (
                not package_path.is_file()
                or package_path.is_symlink()
                or package_path.resolve().parent != root
                or package_path.stat().st_size > 8 * 1024 * 1024
            ):
                raise MisePilotError("package.json is not a bounded regular file")
            package_value = json.loads(
                package_path.read_text(encoding="utf-8"),
                object_pairs_hook=_unique_json_object,
                parse_constant=_reject_json_constant,
            )
        except MisePilotError:
            raise
        except (OSError, UnicodeError, json.JSONDecodeError) as exc:
            raise MisePilotError(f"invalid package.json: {type(exc).__name__}") from exc
        if not isinstance(package_value, dict):
            raise MisePilotError("package.json must be a JSON object")
        package_manager = package_value.get("packageManager")
        if (
            "packageManager" in package_value
            and package_manager != f"pnpm@{contracts['pnpm']['version']}"
        ):
            raise MisePilotError(
                "package.json packageManager must match the exact pnpm version in mise.lock"
            )
    return {
        "config": str(config),
        "lock": str(lock_path),
        "platform": platform_key,
        "tools": contracts,
    }


def recognize_pilot(desired: Mapping, platform_name: str, architecture: str) -> Optional[Dict]:
    if platform_name != "windows" or desired.get("management") != "explicit":
        return None
    manifest = desired.get("manifest", {})
    backends = manifest.get("backends", {}).get("windows", {})
    if "mise" not in backends:
        return None
    tools = manifest.get("capabilities", {}).get("tools", [])
    node = [item for item in tools if item.get("id") == "node" and item.get("scope", ".") == "."]
    pnpm = [item for item in tools if item.get("id") == "pnpm" and item.get("scope", ".") == "."]
    if (
        len(node) != 1
        or node[0].get("constraint") != "24"
        or len(pnpm) != 1
        or pnpm[0].get("constraint") != "10"
    ):
        return None
    return load_pilot_contract(Path(desired["project"]["root"]), Path(backends["mise"]), architecture)


def _mise_environment(project_root: Path, *, offline: bool, auto_install: bool) -> Dict[str, str]:
    root = project_root.resolve()
    environment = {
        "MISE_SAFE": "1",
        "MISE_NO_HOOKS": "1",
        "MISE_NO_ENV": "1",
        "MISE_ENV": "",
        "MISE_AUTO_ENV": "false",
        "MISE_OVERRIDE_CONFIG_FILENAMES": "mise.toml",
        "MISE_OVERRIDE_TOOL_VERSIONS_FILENAMES": "none",
        "MISE_CONFIG_DIR": str(root / ".shipglows-no-user-mise-config"),
        "MISE_GLOBAL_CONFIG_FILE": os.devnull,
        "MISE_SYSTEM_CONFIG_FILE": os.devnull,
        "MISE_SYSTEM_CONFIG_DIR": str(root / ".shipglows-no-system-mise-config"),
        # mise stops discovery before reading a path named as a ceiling. The
        # parent therefore fences traversal while still allowing the project
        # root's validated mise.toml to load.
        "MISE_CEILING_PATHS": str(root.parent),
        "MISE_AUTO_INSTALL": "true" if auto_install else "false",
        "MISE_EXEC_AUTO_INSTALL": "true" if auto_install else "false",
        "MISE_NOT_FOUND_AUTO_INSTALL": "true" if auto_install else "false",
        "MISE_RUN_AUTO_INSTALL": "true" if auto_install else "false",
        "MISE_LOCKFILE": "1",
        "MISE_SYSTEM_DEPS": "ignore",
    }
    if offline:
        environment["MISE_OFFLINE"] = "1"
    return environment


def _request(
    purpose: str,
    argv: Sequence[str],
    project_root: Path,
    *,
    offline: bool = False,
    auto_install: bool = False,
    timeout: float = 10,
) -> ProcessRequest:
    return ProcessRequest(
        purpose,
        tuple(str(value) for value in argv),
        project_root.resolve(),
        _mise_environment(project_root, offline=offline, auto_install=auto_install),
        timeout,
    )


def _version_result(result: ProcessResult, label: str, pattern: re.Pattern) -> Tuple[Optional[str], Optional[str]]:
    if result.timed_out:
        return None, f"{label} probe timed out"
    if result.returncode != 0:
        return None, f"{label} probe exited {result.returncode}"
    first_line = (result.stdout or "").strip().splitlines()
    if not first_line:
        return None, f"{label} probe returned empty evidence"
    match = pattern.search(first_line[0].strip())
    if not match:
        return None, f"{label} probe returned unrecognized version evidence"
    return match.group(1), None


def _mise_tool_path_state(result: ProcessResult, tool: str) -> Tuple[bool, Optional[str]]:
    if result.timed_out:
        return False, f"mise which {tool} timed out"
    if result.returncode == 0:
        if (result.stdout or "").strip():
            return True, None
        return False, f"mise which {tool} returned empty ownership evidence"
    return False, None


def plan_operations(
    desired: Mapping,
    architecture: str,
    runner: StructuredRunner,
    *,
    offline: bool = False,
) -> Optional[Dict]:
    """Return the narrow pilot plan, or ``None`` outside its exact boundary."""

    try:
        contract = recognize_pilot(desired, "windows", architecture)
    except MisePilotError as exc:
        return {
            "operations": [_blocked_tool("node", str(exc))],
            "backend": {"status": "invalid", "reason": str(exc)},
        }
    if contract is None:
        return None

    project_root = Path(desired["project"]["root"])
    raw_mise_path = runner.which("mise.exe")
    mise_identity = (
        _trusted_executable(raw_mise_path, "mise.exe", project_root, runner)
        if raw_mise_path
        else None
    )
    if raw_mise_path and not mise_identity:
        reason = "mise executable resolution is outside canonical trusted install roots"
        operations = [
            _tool_operation(tool, contract, "blocked", False, reason, None, None)
            for tool in ("node", "pnpm")
        ]
        return {"operations": operations, "backend": {"status": "broken", "reason": reason}}
    if not mise_identity:
        raw_winget_path = runner.which("winget.exe")
        winget_identity = (
            _trusted_executable(raw_winget_path, "winget.exe", project_root, runner)
            if raw_winget_path
            else None
        )
        acquisition = {
            "capability": {"kind": "backend", "id": "mise"},
            "owner": "winget",
            "references": _identity_references(["jdx.mise"], winget_identity if not offline else None),
            "status": "pending" if winget_identity and not offline else "blocked",
            "executable": bool(winget_identity and not offline),
            "reason": (
                "official jdx.mise acquisition requires a separate approved online operation"
                if winget_identity and not offline
                else "offline mode cannot acquire mise"
                if offline
                else "canonical Windows App Installer WinGet is unavailable for the official jdx.mise acquisition operation"
            ),
            "action": "acquire_mise",
            "approval": "required",
            "package_id": MISE_PACKAGE_ID,
            "resolved_version": None,
            "integrity": "WinGet package identity; exact artifact integrity remains WinGet-owned",
            "provenance": MISE_INSTALL_DOC,
        }
        return {
            "operations": [
                acquisition,
                *[
                    {
                        **_blocked_tool(
                            tool,
                            f"{tool} installation waits for approved mise acquisition and fresh observation",
                        ),
                        "action": f"install_{tool}",
                        "approval": "required",
                        "package_id": None,
                        "resolved_version": contract["tools"][tool]["version"],
                        "integrity": contract["tools"][tool]["integrity"],
                        "provenance": contract["tools"][tool]["provenance"],
                    }
                    for tool in ("node", "pnpm")
                ],
            ],
            "backend": {"status": "missing", "version": None},
        }

    mise_result = runner.run(
        _request("mise-version", (mise_identity.path, "--version"), project_root, offline=offline)
    )
    mise_version, mise_error = _version_result(mise_result, "mise", MISE_VERSION)
    if mise_error:
        operations = [
            _tool_operation(tool, contract, "blocked", False, mise_error, None, mise_identity)
            for tool in ("node", "pnpm")
        ]
        return {"operations": operations, "backend": {"status": "broken", "reason": mise_error}}

    operations = []
    for tool in ("node", "pnpm"):
        path_result = runner.run(
            _request(
                f"{tool}-mise-path",
                (mise_identity.path, "--locked", "which", tool),
                project_root,
                offline=offline,
            )
        )
        installed_by_mise, path_error = _mise_tool_path_state(path_result, tool)
        if not installed_by_mise:
            status = "blocked" if path_error or offline else "pending"
            reason = path_error or (
                "offline install is unsupported without the exact mise installed cache"
                if offline
                else f"exact locked {tool} is not installed; mise owns the project-local installation"
            )
            operations.append(
                _tool_operation(
                    tool,
                    contract,
                    status,
                    status == "pending",
                    reason,
                    mise_version,
                    mise_identity,
                )
            )
            continue
        result = runner.run(
            _request(
                f"{tool}-user-version",
                (mise_identity.path, "--locked", "exec", "--", tool, "--version"),
                project_root,
                offline=offline,
            )
        )
        expected = contract["tools"][tool]["version"]
        version, error = _version_result(
            result, f"mise exec {tool}", TOOL_VERSION_PATTERNS[tool]
        )
        if version == expected:
            operation = _tool_operation(
                tool,
                contract,
                "ready",
                False,
                f"exact locked {tool} is already available through mise exec",
                mise_version,
                mise_identity,
            )
        elif version:
            operation = _tool_operation(
                tool,
                contract,
                "blocked",
                False,
                f"mise exec returned a {tool} version that differs from mise.lock",
                mise_version,
                mise_identity,
            )
        elif result.timed_out or result.returncode == 0:
            operation = _tool_operation(
                tool,
                contract,
                "blocked",
                False,
                error or f"unusable {tool} evidence",
                mise_version,
                mise_identity,
            )
        elif offline:
            operation = _tool_operation(
                tool,
                contract,
                "blocked",
                False,
                "offline install is unsupported without the exact mise installed cache",
                mise_version,
                mise_identity,
            )
        else:
            operation = _tool_operation(
                tool,
                contract,
                "pending",
                True,
                f"exact locked {tool} is not installed; mise owns the project-local installation",
                mise_version,
                mise_identity,
            )
        operations.append(operation)
    if any(operation["status"] == "blocked" for operation in operations):
        for operation in operations:
            if operation["status"] == "pending":
                operation.update(
                    {
                        "status": "blocked",
                        "executable": False,
                        "approval": "not_required",
                        "reason": "toolchain apply waits until every locked tool has trustworthy evidence",
                    }
                )
    return {"operations": operations, "backend": {"status": "ready", "version": mise_version}}


def _blocked_tool(tool: str, reason: str) -> Dict:
    return {
        "capability": {"kind": "tool", "id": tool, "constraint": TOOL_CONSTRAINTS[tool]},
        "owner": "mise",
        "references": ["mise"],
        "status": "blocked",
        "executable": False,
        "reason": reason,
    }


def _tool_operation(
    tool: str,
    contract: Mapping,
    status: str,
    executable: bool,
    reason: str,
    mise_version: Optional[str],
    mise_identity: Optional[ExecutableIdentity],
) -> Dict:
    tool_contract = contract["tools"][tool]
    return {
        "capability": {"kind": "tool", "id": tool, "constraint": TOOL_CONSTRAINTS[tool]},
        "owner": "mise",
        "references": _identity_references(["mise", "mise.lock"], mise_identity),
        "status": status,
        "executable": executable,
        "reason": reason,
        "action": f"install_{tool}",
        "approval": "required" if executable else "not_required",
        "package_id": None,
        "resolved_version": tool_contract["version"],
        "integrity": tool_contract["integrity"],
        "provenance": tool_contract["provenance"],
        "backend_version": mise_version,
    }


def apply_operations(plan: Mapping, runner: StructuredRunner) -> Dict:
    """Apply already validated pilot operations using only fixed argv."""

    project_root = Path(plan["project"]["root"]).resolve()
    operations = plan["operations"]
    executable = [operation for operation in operations if operation["executable"]]
    if not executable:
        if any(operation["status"] == "blocked" for operation in operations):
            raise MisePilotError("the approved plan is blocked and has no executable recovery operation")
        return {"status": "converged", "operations": 0}
    action = executable[0].get("action")
    if action == "acquire_mise":
        if len(executable) != 1:
            raise MisePilotError("mise acquisition must remain a separate approved operation")
        operation = executable[0]
        approved_identity = _identity_from_references(operation.get("references"), [MISE_PACKAGE_ID])
        if approved_identity is None:
            raise MisePilotError("WinGet executable identity was not bound to the approved plan")
        raw_winget = runner.which("winget.exe")
        winget_identity = (
            _trusted_executable(raw_winget, "winget.exe", project_root, runner)
            if raw_winget
            else None
        )
        if winget_identity != approved_identity:
            raise MisePilotError("WinGet executable identity changed after approval")
        request = ProcessRequest(
            "winget-acquire-mise",
            (
                winget_identity.path,
                "install",
                "--id",
                MISE_PACKAGE_ID,
                "--exact",
                "--source",
                "winget",
                "--disable-interactivity",
            ),
            project_root,
            {},
            900,
        )
        result = runner.run(request)
        _require_success(result, "mise acquisition")
        return {"status": "applied", "operations": 1, "next_action": "replan after observing mise"}
    if any(operation.get("action") not in ("install_node", "install_pnpm") for operation in executable):
        raise MisePilotError("unrecognized executable operation")

    approved_identities = [
        _identity_from_references(operation.get("references"), ["mise", "mise.lock"])
        for operation in executable
    ]
    if any(identity is None for identity in approved_identities) or len(set(approved_identities)) != 1:
        raise MisePilotError("mise executable identity was not consistently bound to the approved plan")
    approved_identity = approved_identities[0]
    raw_mise = runner.which("mise.exe")
    mise_identity = (
        _trusted_executable(raw_mise, "mise.exe", project_root, runner)
        if raw_mise
        else None
    )
    if mise_identity != approved_identity:
        raise MisePilotError("mise executable identity changed after approval")
    offline = bool(plan.get("pilot", {}).get("offline", False))
    version_result = runner.run(_request("mise-version", (mise_identity.path, "--version"), project_root, offline=offline))
    version, error = _version_result(version_result, "mise", MISE_VERSION)
    if error or any(version != operation.get("backend_version") for operation in executable):
        raise MisePilotError(error or "mise version changed after approval")
    observed = []
    for operation in executable:
        tool = operation["capability"]["id"]
        install = runner.run(
            _request(
                f"mise-install-{tool}",
                (mise_identity.path, "--locked", "install", tool),
                project_root,
                offline=offline,
                timeout=1800,
            )
        )
        _require_success(install, f"mise {tool} installation")
        path_proof = runner.run(
            _request(
                f"{tool}-mise-path",
                (mise_identity.path, "--locked", "which", tool),
                project_root,
                offline=offline,
            )
        )
        installed_by_mise, path_error = _mise_tool_path_state(path_proof, tool)
        if not installed_by_mise:
            raise MisePilotError(path_error or f"mise did not prove ownership of installed {tool}")
        proof = runner.run(
            _request(
                f"{tool}-post-install-version",
                (mise_identity.path, "--locked", "exec", "--", tool, "--version"),
                project_root,
                offline=offline,
            )
        )
        installed_version, proof_error = _version_result(
            proof, f"installed {tool}", TOOL_VERSION_PATTERNS[tool]
        )
        if proof_error or installed_version != operation.get("resolved_version"):
            raise MisePilotError(
                proof_error or f"installed {tool} does not match the approved lock version"
            )
        observed.append(
            {"id": tool, "owner": "mise_project", "version": installed_version}
        )
    return {
        "status": "applied",
        "operations": len(executable),
        "observed": observed,
    }


def validate_apply_semantics(plan: Mapping, contract: Mapping) -> None:
    """Reject digest-valid plans that do not match the complete pilot grammar."""

    operations = plan["operations"]
    executable = [operation for operation in operations if operation["executable"]]
    if plan["executable"] != bool(executable):
        raise MisePilotError("plan executable summary disagrees with its operations")
    expected_effects = {
        "network": bool(executable),
        "download": bool(executable),
        # WinGet packages can be installer-scoped and may require elevation;
        # report that possibility instead of promising an unprivileged apply.
        "privilege": any(operation.get("action") == "acquire_mise" for operation in executable),
        "consent": bool(executable),
    }
    if plan["effects"] != expected_effects:
        raise MisePilotError("plan effects disagree with the bounded pilot operation")
    if len(executable) > 2:
        raise MisePilotError("the pilot permits at most two executable tool operations")

    actions = [operation.get("action") for operation in operations]
    if actions == ["acquire_mise", "install_node", "install_pnpm"]:
        acquire = operations[0]
        acquire_identity = _identity_from_references(acquire.get("references"), [MISE_PACKAGE_ID])
        if (
            acquire.get("capability") != {"kind": "backend", "id": "mise"}
            or acquire.get("owner") != "winget"
            or acquire.get("package_id") != MISE_PACKAGE_ID
            or acquire.get("integrity") != "WinGet package identity; exact artifact integrity remains WinGet-owned"
            or acquire.get("provenance") != MISE_INSTALL_DOC
            or acquire.get("resolved_version") is not None
            or acquire.get("approval") != "required"
            or acquire.get("status") not in ("pending", "blocked")
        ):
            raise MisePilotError("mise acquisition plan has invalid semantics")
        if acquire["executable"] != (acquire_identity is not None):
            raise MisePilotError("mise acquisition executable identity is inconsistent")
        if acquire["status"] == "pending" and not acquire["executable"]:
            raise MisePilotError("pending mise acquisition is not executable")
        if acquire["status"] == "blocked" and acquire["executable"]:
            raise MisePilotError("blocked mise acquisition is executable")
        for tool, operation in zip(("node", "pnpm"), operations[1:]):
            tool_contract = contract["tools"][tool]
            if (
                operation.get("capability")
                != {"kind": "tool", "id": tool, "constraint": TOOL_CONSTRAINTS[tool]}
                or operation.get("owner") != "mise"
                or operation.get("references") != ["mise"]
                or operation.get("status") != "blocked"
                or operation.get("executable")
                or operation.get("approval") != "required"
                or operation.get("package_id") is not None
                or operation.get("resolved_version") != tool_contract["version"]
                or operation.get("integrity") != tool_contract["integrity"]
                or operation.get("provenance") != tool_contract["provenance"]
            ):
                raise MisePilotError("mise acquisition tool plan has invalid semantics")
        return

    if actions == ["install_node", "install_pnpm"]:
        identities = []
        for tool, operation in zip(("node", "pnpm"), operations):
            tool_contract = contract["tools"][tool]
            identity = _identity_from_references(
                operation.get("references"), ["mise", "mise.lock"]
            )
            if (
                operation.get("capability")
                != {"kind": "tool", "id": tool, "constraint": TOOL_CONSTRAINTS[tool]}
                or operation.get("owner") != "mise"
                or operation.get("package_id") is not None
                or operation.get("resolved_version") != tool_contract["version"]
                or operation.get("integrity") != tool_contract["integrity"]
                or operation.get("provenance") != tool_contract["provenance"]
                or operation.get("status") not in ("pending", "ready", "blocked")
                or operation.get("approval")
                != ("required" if operation["executable"] else "not_required")
            ):
                raise MisePilotError(f"mise {tool} plan has invalid semantics")
            if operation["executable"] != (operation["status"] == "pending"):
                raise MisePilotError(f"mise {tool} execution state is inconsistent")
            if identity is None:
                raise MisePilotError(f"mise {tool} plan has no approved executable identity")
            if operation.get("backend_version") is not None and not MISE_VERSION.search(
                operation["backend_version"]
            ):
                raise MisePilotError("mise backend version evidence is invalid")
            identities.append(identity)
        if identities[0] != identities[1]:
            raise MisePilotError("mise tool operations disagree on executable identity")
        return

    # Invalid code-free config plans intentionally have one actionless blocked
    # diagnostic. They remain visible but can never cross apply.
    if len(operations) == 1 and operations[0]["status"] == "blocked" and not executable:
        return
    raise MisePilotError("plan operations are outside the bounded mise pilot grammar")


def _require_success(result: ProcessResult, label: str) -> None:
    if result.timed_out:
        raise MisePilotError(f"{label} timed out")
    if result.returncode != 0:
        raise MisePilotError(f"{label} exited {result.returncode}")
    if not (result.stdout or result.stderr).strip():
        raise MisePilotError(f"{label} returned empty evidence")


def observe_tools(
    desired: Mapping,
    architecture: str,
    runner: StructuredRunner,
    *,
    offline: bool = False,
) -> Optional[Sequence[Dict]]:
    try:
        contract = recognize_pilot(desired, "windows", architecture)
    except MisePilotError as exc:
        return [
            {
                "kind": "tool",
                "id": tool,
                "status": "blocked",
                "source": "mise_project",
                "owner": "mise_project",
                "consumer": "powershell",
                "reason": str(exc),
            }
            for tool in ("node", "pnpm")
        ]
    if contract is None:
        return None
    project_root = Path(desired["project"]["root"])
    raw_mise = runner.which("mise.exe")
    mise_identity = (
        _trusted_executable(raw_mise, "mise.exe", project_root, runner)
        if raw_mise
        else None
    )
    if not mise_identity:
        return [
            {
                "kind": "tool",
                "id": tool,
                "status": "pending",
                "source": "mise_project",
                "owner": "mise_project",
                "consumer": consumer,
                "reason": "mise is not observed",
            }
            for tool in ("node", "pnpm")
            for consumer in ("powershell", "agent_child")
        ]
    evidence = []
    for tool in ("node", "pnpm"):
        tool_contract = contract["tools"][tool]
        path_result = runner.run(
            _request(
                f"{tool}-mise-path",
                (mise_identity.path, "--locked", "which", tool),
                project_root,
                offline=offline,
            )
        )
        installed_by_mise, path_error = _mise_tool_path_state(path_result, tool)
        if not installed_by_mise:
            evidence.extend(
                {
                    "kind": "tool",
                    "id": tool,
                    "status": "blocked" if path_error else "pending",
                    "source": "mise_project",
                    "owner": "mise_project",
                    "consumer": consumer,
                    "reason": path_error or f"{tool} is not installed by mise",
                }
                for consumer in ("powershell", "agent_child")
            )
            continue
        for consumer, purpose in (
            ("powershell", f"{tool}-user-version"),
            ("agent_child", f"{tool}-agent-version"),
        ):
            result = runner.run(
                _request(
                    purpose,
                    (mise_identity.path, "--locked", "exec", "--", tool, "--version"),
                    project_root,
                    offline=offline,
                )
            )
            version, error = _version_result(
                result, f"{consumer} {tool}", TOOL_VERSION_PATTERNS[tool]
            )
            status = (
                "ready"
                if version == tool_contract["version"]
                else "degraded"
                if version
                else "pending"
            )
            item = {
                "kind": "tool",
                "id": tool,
                "status": status,
                "source": "mise_exec",
                "owner": "mise_project",
                "consumer": consumer,
                "resolved_version": tool_contract["version"],
                "integrity": tool_contract["integrity"],
            }
            if version:
                item["version"] = version
            if status != "ready":
                item["reason"] = error or f"observed {tool} differs from the exact lock version"
            evidence.append(item)
    return evidence


# Compatibility name retained for the first adapter integration point. The
# returned sequence now contains both Node and pnpm evidence.
observe_node = observe_tools
