"""Bounded Windows Tauri capability adapter.

Repository manifests are data only.  The injected provider runner owns the
closed PowerShell bridge; plans persist identities and action names, never argv.
"""

from __future__ import annotations

import hashlib
import json
import os
import re
import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, Mapping, Optional, Protocol, Sequence

from .versions import evaluate_version_constraint


RUST_VERSION = "1.97.1"
TAURI_CLI_VERSION = "2.11.4"
OWNED_IDS = {"cargo", "rustc", "rustup", "tauri-cli", "msvc", "windows-sdk", "webview2", "tauri", "tauri-windows"}
ACTIONS = {"acquire_mise", "install_rust"}
PROVIDER_SENSITIVE_REASON = re.compile(
    r"(?i)((?:authorization\s*[:=]\s*(?:bearer|basic)\s+|(?:bearer|basic)\s+|"
    r"(?:token|password|passwd|secret|api[_-]?key|client[_-]?secret)\s*[:=]\s*))\S+"
)


def _registry_managed_powershell() -> str:
    if os.name != "nt":
        return ""
    try:
        import winreg

        with winreg.OpenKey(winreg.HKEY_CURRENT_USER, "Environment") as key:
            value, value_type = winreg.QueryValueEx(key, "SHIPGLOWS_MANAGED_PWSH")
        if value_type not in (winreg.REG_SZ, winreg.REG_EXPAND_SZ) or not isinstance(value, str):
            return ""
        return os.path.expandvars(value)
    except (ImportError, OSError):
        return ""


def _managed_powershell_root() -> Path:
    profile = os.environ.get("USERPROFILE") or str(Path.home())
    return (Path(profile) / ".shipglows" / "toolchains" / "powershell").resolve(strict=False)


def _fallback_managed_powershell() -> str:
    """Resolve the one source-controlled runtime coordinate; never enumerate PATH."""

    manifest = Path(__file__).resolve().parents[1] / "windows" / "ShipGlows.PowerShellRuntime.json"
    try:
        value = json.loads(manifest.read_text(encoding="utf-8"))
        version, platform_value = value["version"], value["platform"]
    except (OSError, KeyError, TypeError, json.JSONDecodeError):
        return ""
    if not re.fullmatch(r"\d+\.\d+\.\d+", str(version)) or not re.fullmatch(r"win-(?:x64|arm64)", str(platform_value)):
        return ""
    return str(_managed_powershell_root() / str(version) / str(platform_value) / "pwsh.exe")


def resolve_managed_powershell(explicit: str | None = None) -> str:
    candidates = (explicit, os.environ.get("SHIPGLOWS_MANAGED_PWSH"), _registry_managed_powershell(), _fallback_managed_powershell())
    root = _managed_powershell_root()
    for raw in candidates:
        if not raw:
            continue
        try:
            candidate = Path(raw).expanduser().resolve(strict=False)
            candidate.relative_to(root)
            if candidate.name.lower() != "pwsh.exe" or candidate.is_symlink() or not candidate.is_file() or candidate.stat().st_size <= 0:
                continue
            return str(candidate)
        except (OSError, ValueError):
            continue
    return ""


class WindowsTauriError(ValueError):
    pass


def _safe_provider_reason(result: Mapping[str, Any]) -> str:
    raw = result.get("reason")
    if not isinstance(raw, str) or not raw.strip():
        return "reason unavailable"
    bounded = re.sub(r"[\x00-\x1f\x7f]+", " ", raw).strip()[:320]
    return PROVIDER_SENSITIVE_REASON.sub(r"\1[REDACTED]", bounded)


@dataclass(frozen=True)
class ProviderRequest:
    argv: tuple[str, ...]
    cwd: Path
    environment: Mapping[str, str]
    stdin: str
    timeout_seconds: int


class ProviderExecutor(Protocol):
    def run_provider(self, request: ProviderRequest) -> Mapping[str, Any]: ...


class SubprocessProviderExecutor:
    def run_provider(self, request: ProviderRequest) -> Mapping[str, Any]:
        try:
            completed = subprocess.run(
                request.argv,
                cwd=request.cwd,
                env=dict(request.environment),
                input=request.stdin,
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
            return {"status": "timeout", "reason": type(exc).__name__}
        if completed.returncode != 0:
            return {"status": "refused", "reason": f"provider exited {completed.returncode}"}
        if len(completed.stdout) > 65536:
            return {"status": "refused", "reason": "provider output exceeded the bound"}
        try:
            value = json.loads(completed.stdout)
        except (json.JSONDecodeError, TypeError):
            return {"status": "refused", "reason": "provider returned invalid JSON"}
        return value if isinstance(value, dict) else {"status": "refused", "reason": "provider returned a non-object"}


class WindowsEnvironmentRunner:
    """Composite legacy mise runner plus the closed Windows provider bridge."""

    SAFE_ENVIRONMENT = {
        "LOCALAPPDATA", "PATH", "PROGRAMDATA", "SHIPGLOWS_ROOT", "SYSTEMROOT", "TEMP", "TMP", "USERPROFILE", "WINDIR",
    }

    def __init__(self, legacy_runner, executor: ProviderExecutor | None = None, provider_path: Path | None = None, powershell_path: str | None = None):
        self.legacy_runner = legacy_runner
        self.executor = executor or SubprocessProviderExecutor()
        self.provider_path = (provider_path or Path(__file__).resolve().parents[1] / "windows" / "shipglows-environment-provider.ps1").resolve()
        self.powershell_path = resolve_managed_powershell(powershell_path)

    @staticmethod
    def _file_sha256(path: Path) -> str:
        if path.is_symlink() or not path.is_file() or path.stat().st_size <= 0 or path.stat().st_size > 512 * 1024 * 1024:
            raise WindowsTauriError("trusted provider dependency identity is invalid")
        digest = hashlib.sha256()
        with path.open("rb") as handle:
            while chunk := handle.read(1024 * 1024):
                digest.update(chunk)
        return digest.hexdigest()

    def which(self, executable: str):
        return self.legacy_runner.which(executable)

    def trusted_roots(self, executable: str):
        return self.legacy_runner.trusted_roots(executable)

    def run(self, request):
        return self.legacy_runner.run(request)

    def _identity(self) -> Dict[str, str]:
        powershell = Path(self.powershell_path)
        module = self.provider_path.parent / "ShipGlows.MobileToolchain.psm1"
        if not self.provider_path.is_file() or not powershell.is_file() or not powershell.is_absolute() or not module.is_file():
            raise WindowsTauriError("trusted Windows environment provider is unavailable")
        return {
            "path": str(self.provider_path),
            "sha256": self._file_sha256(self.provider_path),
            "powershell_path": str(powershell.resolve()),
            "powershell_sha256": self._file_sha256(powershell),
            "module_path": str(module.resolve()),
            "module_sha256": self._file_sha256(module),
        }

    def _invoke(self, action: str, project_root: Path, scope: str) -> Dict[str, Any]:
        if action not in ("observe", "acquire_mise", "install_rust"):
            raise WindowsTauriError("unrecognized Windows environment provider action")
        try:
            self.provider_path.relative_to(project_root.resolve())
        except ValueError:
            pass
        else:
            raise WindowsTauriError("Windows environment provider cannot be loaded from the managed project")
        identity = self._identity()
        payload = json.dumps({"action": action, "projectRoot": str(project_root.resolve()), "scope": scope}, separators=(",", ":"))
        environment = {name: os.environ[name] for name in self.SAFE_ENVIRONMENT if os.environ.get(name)}
        request = ProviderRequest(
            (self.powershell_path, "-NoLogo", "-NoProfile", "-NonInteractive", "-File", str(self.provider_path)),
            self.provider_path.parent,
            environment,
            payload,
            60 if action == "observe" else 1800,
        )
        result = dict(self.executor.run_provider(request))
        if action == "observe":
            result["provider"] = identity
        return result

    def windows_environment_observe(self, project_root: Path, scope: str):
        result = self._invoke("observe", project_root, scope)
        if result.get("status") in ("timeout", "refused"):
            raise WindowsTauriError(str(result.get("reason") or result["status"]))
        return result

    def windows_environment_apply(self, action: str, project_root: Path, scope: str):
        return self._invoke(action, project_root, scope)


def _targets(desired: Mapping[str, Any]) -> Sequence[Mapping[str, Any]]:
    return [item for item in desired["manifest"]["capabilities"]["targets"] if item["id"] in ("tauri", "tauri-windows")]


def recognize(desired: Mapping[str, Any], platform_name: str) -> Optional[str]:
    if platform_name != "windows":
        return None
    targets = _targets(desired)
    if not targets:
        return None
    if len(targets) != 1:
        raise WindowsTauriError("multiple Tauri Windows targets require one explicit project scope")
    return str(targets[0].get("scope", "."))


def _references(observed: Mapping[str, Any]) -> list[str]:
    provider = observed.get("provider", {})
    fields = ("path", "sha256", "powershell_path", "powershell_sha256", "module_path", "module_sha256")
    if any(not isinstance(provider.get(name), str) for name in fields) or any(
        not re.fullmatch(r"[0-9a-f]{64}", provider[name])
        for name in ("sha256", "powershell_sha256", "module_sha256")
    ):
        return ["windows-environment-provider"]
    references = [
        "windows-environment-provider",
        f"provider:{provider['path']}", f"provider-sha256:{provider['sha256']}",
        f"powershell:{provider['powershell_path']}", f"powershell-sha256:{provider['powershell_sha256']}",
        f"module:{provider['module_path']}", f"module-sha256:{provider['module_sha256']}",
    ]
    winget = observed.get("winget", {})
    if (
        isinstance(winget.get("path"), str)
        and isinstance(winget.get("sha256"), str)
        and re.fullmatch(r"[0-9a-f]{64}", winget["sha256"])
    ):
        references.extend((f"winget:{winget['path']}", f"winget-sha256:{winget['sha256']}"))
    return references


def _operation(capability: Mapping[str, Any], status: str, reason: str, observed: Mapping[str, Any], *, action: str | None = None, executable: bool = False) -> Dict[str, Any]:
    result: Dict[str, Any] = {
        "capability": dict(capability),
        "owner": "windows_tauri",
        "references": _references(observed),
        "status": status,
        "executable": executable,
        "reason": reason,
    }
    if action:
        result.update({"action": action, "approval": "required" if executable else "not_required"})
    return result


def plan_operations(desired: Mapping[str, Any], runner, *, offline: bool = False) -> Optional[Dict[str, Any]]:
    try:
        scope = recognize(desired, "windows")
    except WindowsTauriError as exc:
        return {"scope": None, "operations": [_operation({"kind": "target", "id": "tauri-windows"}, "blocked", str(exc), {})]}
    if scope is None:
        return None
    capabilities = []
    for group in ("tools", "integrations", "targets"):
        kind = group[:-1]
        capabilities.extend(
            {"kind": kind, **item}
            for item in desired["manifest"]["capabilities"][group]
            if item["id"] in OWNED_IDS and item.get("scope", ".") == scope
        )
    if not hasattr(runner, "windows_environment_observe"):
        return {"scope": scope, "operations": []}
    try:
        observed = runner.windows_environment_observe(Path(desired["project"]["root"]), scope)
    except (WindowsTauriError, OSError, subprocess.SubprocessError):
        reason = "Windows environment provider observation was refused or unavailable"
        return {
            "scope": scope,
            "operations": [_operation(capability, "blocked", reason, {}) for capability in capabilities],
            "observed": {},
        }
    reference_count = len(_references(observed))
    provider_bound = reference_count in (7, 9)
    winget_bound = reference_count == 9
    constraints = {item["id"]: item.get("constraint", "*") for item in capabilities}
    rust_constraint_status = evaluate_version_constraint(RUST_VERSION, constraints.get("rustc", "*"))
    rust_ready = (
        all(observed.get(name, {}).get("status") == "ready" for name in ("rustc", "cargo", "rustup"))
        and observed.get("rustc", {}).get("version") == RUST_VERSION
        and rust_constraint_status == "ready"
    )
    mise_ready = observed.get("mise", {}).get("status") == "ready"
    host_ready = all(observed.get(name, {}).get("status") == "ready" for name in ("msvc", "windows-sdk", "webview2"))
    tauri_constraint_status = evaluate_version_constraint(TAURI_CLI_VERSION, constraints.get("tauri-cli", "*"))
    tauri_ready = (
        observed.get("tauri-cli", {}).get("status") == "ready"
        and observed.get("tauri-cli", {}).get("version") == TAURI_CLI_VERSION
        and tauri_constraint_status == "ready"
    )

    operations = []
    acquisition_emitted = False
    rust_install_emitted = False
    for capability in capabilities:
        identifier = capability["id"]
        if not provider_bound:
            operations.append(_operation(capability, "blocked", "trusted provider, PowerShell, and module identities are unavailable", observed))
            continue
        if not mise_ready:
            if not acquisition_emitted:
                can_acquire = not offline and provider_bound and winget_bound
                operations.append(_operation({"kind": "backend", "id": "mise"}, "pending" if can_acquire else "blocked", "offline mode cannot acquire mise" if offline else "trusted WinGet identity is unavailable" if not winget_bound else "trusted mise acquisition requires separate approval and replan", observed, action="acquire_mise", executable=can_acquire))
                acquisition_emitted = True
            operations.append(_operation(capability, "blocked", f"{identifier} waits for mise acquisition and replan", observed))
        elif identifier == "rustc" and rust_constraint_status == "incompatible":
            operations.append(_operation(capability, "incompatible", f"ShipGlows Rust {RUST_VERSION} does not satisfy the project constraint", observed))
        elif identifier in ("cargo", "rustup") and rust_constraint_status == "incompatible":
            operations.append(_operation(capability, "blocked", "Cargo and rustup wait for a compatible Rust baseline decision", observed))
        elif identifier in ("rustc", "cargo", "rustup") and not rust_ready:
            if identifier == "rustc" and not rust_install_emitted:
                operations.append(_operation(capability, "blocked" if offline else "pending", "offline mode cannot install an uncached Rust toolchain" if offline else f"install ShipGlows Rust {RUST_VERSION} and runtime wrappers", observed, action="install_rust", executable=not offline and provider_bound))
                rust_install_emitted = True
            else:
                operations.append(_operation(capability, "blocked", "Cargo and rustup converge with the approved Rust toolchain operation", observed))
        elif identifier in ("rustc", "cargo", "rustup"):
            operations.append(_operation(capability, "ready", "validated Rust toolchain is observed through managed wrappers", observed))
        elif identifier == "tauri-cli":
            state = "incompatible" if tauri_constraint_status == "incompatible" else "ready" if tauri_ready else "pending"
            operations.append(_operation(capability, state, "exact local Tauri CLI is observed" if tauri_ready else "ShipGlows Tauri CLI baseline does not satisfy the project constraint" if state == "incompatible" else "exact local Tauri CLI is not yet observed", observed))
        elif identifier in ("msvc", "windows-sdk", "webview2"):
            state = observed.get(identifier, {}).get("status", "pending")
            operations.append(_operation(capability, "ready" if state == "ready" else "pending", f"Windows host {identifier} is {'observed' if state == 'ready' else 'not yet observed'}", observed))
        else:
            ready = rust_ready and host_ready and tauri_ready
            operations.append(_operation(capability, "ready" if ready else "blocked", "Tauri Windows prerequisites are ready" if ready else "Tauri Windows waits for Rust, local CLI, MSVC/SDK, and WebView2", observed))
    return {"scope": scope, "operations": operations, "observed": observed}


def validate_apply(plan: Mapping[str, Any], desired: Mapping[str, Any], runner) -> tuple[str, str]:
    scope = recognize(desired, "windows")
    executable = [item for item in plan["operations"] if item.get("executable") and item.get("owner") == "windows_tauri"]
    if len(executable) != 1 or executable[0].get("action") not in ACTIONS:
        raise WindowsTauriError("Windows Tauri apply requires exactly one closed executable action")
    expected_effects = {
        "network": True,
        "download": True,
        "privilege": executable[0]["action"] == "acquire_mise",
        "consent": True,
    }
    if not plan.get("executable") or plan.get("effects") != expected_effects:
        raise WindowsTauriError("Windows Tauri plan effects disagree with the approved action")
    fresh = plan_operations(desired, runner, offline=False)
    approved_owned = [item for item in plan["operations"] if item.get("owner") == "windows_tauri"]
    fresh_owned = [item for item in fresh["operations"] if item.get("owner") == "windows_tauri"]
    fresh_executable = [item for item in fresh_owned if item.get("executable")]
    if len(fresh_executable) != 1 or fresh_owned != approved_owned:
        raise WindowsTauriError("Windows environment provider identity or operation changed after approval")
    return executable[0]["action"], scope


def observe_capabilities(desired: Mapping[str, Any], runner, *, offline: bool = False) -> Optional[Sequence[Dict[str, Any]]]:
    """Return provider-backed evidence without exposing provider argv."""

    planned = plan_operations(desired, runner, offline=offline)
    if planned is None or not planned.get("operations"):
        return None
    raw = planned.get("observed", {})
    evidence = []
    for operation in planned["operations"]:
        capability = operation["capability"]
        if capability["kind"] == "backend":
            continue
        identifier = capability["id"]
        item = {
            "kind": capability["kind"],
            "id": identifier,
            "status": operation["status"],
            "source": "windows_environment_provider",
            "owner": "windows_tauri",
        }
        if "scope" in capability:
            item["scope"] = capability["scope"]
        observed = raw.get(identifier, {})
        if observed.get("version"):
            item["version"] = observed["version"]
        if operation["status"] != "ready":
            item["reason"] = operation["reason"]
        evidence.append(item)
    return evidence


def apply_operations(plan: Mapping[str, Any], desired: Mapping[str, Any], runner) -> Dict[str, Any]:
    action, scope = validate_apply(plan, desired, runner)
    if not hasattr(runner, "windows_environment_apply"):
        raise WindowsTauriError("Windows environment provider is unavailable")
    result = runner.windows_environment_apply(action, Path(desired["project"]["root"]), scope)
    if not isinstance(result, dict):
        raise WindowsTauriError("Windows environment provider returned invalid apply evidence")
    status = result.get("status")
    if status == "refused":
        raise WindowsTauriError(f"Windows environment provider refused the approved action: {_safe_provider_reason(result)}")
    if status == "offline":
        raise WindowsTauriError("Windows environment provider is offline")
    if status == "timeout":
        raise WindowsTauriError("Windows environment provider timed out")
    if status == "stale":
        raise WindowsTauriError("Windows environment provider identity changed")
    if status not in ("applied", "partial"):
        raise WindowsTauriError("Windows environment provider returned invalid apply evidence")
    return result
