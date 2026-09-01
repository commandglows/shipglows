#!/usr/bin/env python3
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))

from cli.environment.core import ApplyRefused, apply_plan, build_plan, digest_value, discover_project, observe_project  # noqa: E402
from cli.environment.windows_tauri_backend import WindowsEnvironmentRunner, WindowsTauriError  # noqa: E402
from cli.environment.mise_backend import ProcessResult  # noqa: E402


class FakeWindowsRunner:
    def __init__(self, *, mise=True, rust=False, hosts=False, tauri=False, apply_status="applied"):
        self.mise = mise
        self.rust = rust
        self.hosts = hosts
        self.tauri = tauri
        self.apply_status = apply_status
        self.identity = {
            "path": "C:/trusted/provider.ps1", "sha256": "a" * 64,
            "powershell_path": "C:/trusted/pwsh.exe", "powershell_sha256": "b" * 64,
            "module_path": "C:/trusted/ShipGlows.MobileToolchain.psm1", "module_sha256": "c" * 64,
        }
        self.calls = []
        self.trusted_root = None

    def which(self, executable):
        if self.trusted_root and executable == "mise.exe": return str(self.trusted_root / "mise.exe")
        return None

    def trusted_roots(self, executable):
        return (self.trusted_root,) if self.trusted_root else ()

    def run(self, request):
        if request.purpose == "mise-version": return ProcessResult(0, "2026.8.6\n", "", False)
        if request.purpose.endswith("-mise-path"): return ProcessResult(1, "", "not installed", False)
        raise AssertionError(f"unexpected composed request {request.purpose}")

    def windows_environment_observe(self, project_root, scope):
        return {
            "provider": self.identity,
            "winget": {"status": "ready", "path": "C:/trusted/winget.exe", "sha256": "d" * 64},
            "mise": {"status": "ready" if self.mise else "pending", "path": "C:/trusted/mise.exe", "sha256": "b" * 64},
            "rustc": {"status": "ready" if self.rust else "pending", "version": "1.97.1" if self.rust else ""},
            "cargo": {"status": "ready" if self.rust else "pending", "version": "1.97.1" if self.rust else ""},
            "rustup": {"status": "ready" if self.rust else "pending", "version": "1.28.2" if self.rust else ""},
            "tauri-cli": {"status": "ready" if self.tauri else "pending", "version": "2.11.4" if self.tauri else ""},
            "msvc": {"status": "ready" if self.hosts else "pending"},
            "windows-sdk": {"status": "ready" if self.hosts else "pending"},
            "webview2": {"status": "ready" if self.hosts else "pending", "version": "140.0.0.0" if self.hosts else ""},
        }

    def windows_environment_apply(self, action, project_root, scope):
        self.calls.append(action)
        if self.apply_status != "applied":
            return {"status": self.apply_status, "completed": []}
        if action == "acquire_mise":
            self.mise = True
            return {"status": "applied", "completed": [action], "next_action": "replan"}
        if action == "install_rust":
            self.rust = True
            return {"status": "applied", "completed": [action], "next_action": "replan"}
        raise AssertionError(f"unexpected action {action}")


class FakeProviderExecutor:
    def __init__(self):
        self.requests = []

    def run_provider(self, request):
        self.requests.append(request)
        action = json.loads(request.stdin)["action"]
        if action == "observe":
            return FakeWindowsRunner(mise=True, rust=True, hosts=True, tauri=True).windows_environment_observe(Path("C:/fixture"), ".")
        return {"status": "applied", "completed": [action], "next_action": "replan"}


class LegacyStub:
    def which(self, executable): return None
    def trusted_roots(self, executable): return ()
    def run(self, request): raise AssertionError("legacy runner was unexpectedly called")


class RefusingRunner(FakeWindowsRunner):
    def windows_environment_observe(self, project_root, scope):
        raise OSError("Authorization: Bearer provider-secret-canary")


def fixture(root: Path):
    (root / "src-tauri").mkdir()
    (root / "package.json").write_text(json.dumps({"engines": {"node": ">=24.0.0 <25"}, "packageManager": "pnpm@8.11.0", "devDependencies": {"@tauri-apps/cli": "2.11.4"}}), encoding="utf-8")
    (root / "src-tauri/Cargo.toml").write_text('[package]\nname="x"\nversion="0.1.0"\nrust-version="1.88.0"\n', encoding="utf-8")


with tempfile.TemporaryDirectory() as directory:
    project = Path(directory)
    fixture(project)
    desired = discover_project(project)

    stale_environment = dict(os.environ)
    stale_environment.pop("SHIPGLOWS_MANAGED_PWSH", None)
    stale_environment["PATH"] = ""
    resolver_probe = subprocess.run(
        [sys.executable, "-c", "from cli.environment.windows_tauri_backend import WindowsEnvironmentRunner; from cli.environment.mise_backend import SubprocessRunner; print(WindowsEnvironmentRunner(SubprocessRunner()).powershell_path)"],
        cwd=ROOT,
        env=stale_environment,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        encoding="utf-8",
        check=False,
    )
    assert resolver_probe.returncode == 0, resolver_probe.stderr
    resolved_powershell = Path(resolver_probe.stdout.strip())
    assert resolved_powershell.is_file()
    assert resolved_powershell.name.lower() == "pwsh.exe"
    assert resolved_powershell.is_relative_to(Path(os.environ["USERPROFILE"]) / ".shipglows" / "toolchains" / "powershell")

    missing = FakeWindowsRunner(mise=False)
    acquisition = build_plan(desired, platform_name="windows", architecture="x86_64", runner=missing)
    actions = [item.get("action") for item in acquisition["operations"] if item["executable"]]
    assert actions == ["acquire_mise"]
    assert acquisition["effects"] == {"network": True, "download": True, "privilege": True, "consent": True}
    assert apply_plan(acquisition, acquisition["digest"], missing)["next_action"] == "replan"
    assert missing.calls == ["acquire_mise"]

    install = build_plan(desired, platform_name="windows", architecture="x86_64", runner=missing)
    actions = [item.get("action") for item in install["operations"] if item["executable"]]
    assert actions == ["install_rust"]
    assert install["effects"] == {"network": True, "download": True, "privilege": False, "consent": True}

    drifted = json.loads(json.dumps(install))
    drifted["operations"][-1]["reason"] = "forged"
    drifted["digest"] = digest_value({key: value for key, value in drifted.items() if key != "digest"})
    try:
        apply_plan(drifted, drifted["digest"], missing)
    except ApplyRefused:
        pass
    else:
        raise AssertionError("semantic plan forgery was accepted")

    missing.identity = {**missing.identity, "sha256": "d" * 64}
    try:
        apply_plan(install, install["digest"], missing)
    except ApplyRefused as exc:
        assert exc.code == "backend_drift"
    else:
        raise AssertionError("provider identity drift was accepted")

    missing.identity = {**missing.identity, "sha256": "a" * 64}
    missing.identity = {**missing.identity, "module_sha256": "e" * 64}
    try:
        apply_plan(install, install["digest"], missing)
    except ApplyRefused as exc:
        assert exc.code == "backend_drift"
    else:
        raise AssertionError("provider module identity drift was accepted")
    missing.identity = {**missing.identity, "module_sha256": "c" * 64}
    assert apply_plan(install, install["digest"], missing)["status"] == "applied"

    default_runner = FakeWindowsRunner(mise=True)
    default_plan = build_plan(desired, platform_name="windows", architecture="x86_64", runner=default_runner)
    with patch("cli.environment.adapters.default_windows_runner", return_value=default_runner):
        assert apply_plan(default_plan, default_plan["digest"])["status"] == "applied"
    converged_runner = FakeWindowsRunner(mise=True, rust=True, hosts=True, tauri=True)
    converged = build_plan(desired, platform_name="windows", architecture="x86_64", runner=converged_runner)
    assert not converged["executable"]
    assert all(item["status"] == "ready" for item in converged["operations"] if item["capability"]["id"] in {"cargo", "rustc", "rustup", "tauri-cli", "msvc", "windows-sdk", "webview2", "tauri-windows"})

    unbound_runner = FakeWindowsRunner(mise=True, rust=True, hosts=True, tauri=True)
    unbound_runner.identity = {}
    unbound = build_plan(desired, platform_name="windows", architecture="x86_64", runner=unbound_runner)
    assert not unbound["executable"] and any(item["status"] == "blocked" for item in unbound["operations"])

    refused_plan = build_plan(desired, platform_name="windows", architecture="x86_64", runner=RefusingRunner())
    assert not refused_plan["executable"]
    assert all("provider-secret-canary" not in item["reason"] for item in refused_plan["operations"])
    refused_observation = observe_project(desired, probe_versions=True, platform_name="windows", architecture="x86_64", runner=RefusingRunner())
    assert refused_observation["status"] == "blocked"
    cli_environment = dict(os.environ)
    cli_environment.pop("SHIPGLOWS_ENVIRONMENT_PROVIDER_DISABLED", None)
    cli_environment["SHIPGLOWS_MANAGED_PWSH"] = str(project / "absent-pwsh.exe")
    cli = subprocess.run(
        [sys.executable, str(ROOT / "cli/environment/shipglows_environment.py"), "verify", "--project", str(project), "--state-root", str(project / "provider-state")],
        env=cli_environment, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, encoding="utf-8", check=False,
    )
    assert cli.returncode == 4, (cli.returncode, cli.stdout, cli.stderr)
    assert "Traceback" not in cli.stdout + cli.stderr

    incompatible = json.loads(json.dumps(desired))
    next(item for item in incompatible["manifest"]["capabilities"]["tools"] if item["id"] == "rustc")["constraint"] = ">=1.98.0"
    next(item for item in incompatible["manifest"]["capabilities"]["tools"] if item["id"] == "tauri-cli")["constraint"] = "2.12.0"
    mismatch = build_plan(incompatible, platform_name="windows", architecture="x86_64", runner=converged_runner)
    assert next(item for item in mismatch["operations"] if item["capability"]["id"] == "rustc")["status"] != "ready"
    assert next(item for item in mismatch["operations"] if item["capability"]["id"] == "tauri-cli")["status"] != "ready"
    assert next(item for item in mismatch["operations"] if item["capability"]["id"] == "tauri-windows")["status"] == "blocked"
    observed = observe_project(
        desired,
        probe_versions=True,
        platform_name="windows",
        architecture="x86_64",
        runner=converged_runner,
    )
    assert all(
        item["status"] == "ready"
        for item in observed["capabilities"]
        if item["id"] in {"cargo", "rustc", "rustup", "tauri-cli", "msvc", "windows-sdk", "webview2", "tauri-windows"}
    )

    offline = FakeWindowsRunner(mise=False)
    offline_plan = build_plan(desired, platform_name="windows", architecture="x86_64", runner=offline, offline=True)
    assert not offline_plan["executable"]
    assert any(item["status"] == "blocked" for item in offline_plan["operations"])

    for provider_status, expected_code in (
        ("refused", "backend_refused"),
        ("offline", "backend_offline"),
        ("timeout", "backend_timeout"),
        ("stale", "backend_drift"),
    ):
        failure_runner = FakeWindowsRunner(mise=True, apply_status=provider_status)
        failure_plan = build_plan(
            desired, platform_name="windows", architecture="x86_64", runner=failure_runner
        )
        try:
            apply_plan(failure_plan, failure_plan["digest"], failure_runner)
        except ApplyRefused as exc:
            assert exc.code == expected_code, (provider_status, exc.code)
        else:
            raise AssertionError(f"provider {provider_status} was accepted")

    partial_runner = FakeWindowsRunner(mise=True, apply_status="partial")
    partial_plan = build_plan(
        desired, platform_name="windows", architecture="x86_64", runner=partial_runner
    )
    assert apply_plan(partial_plan, partial_plan["digest"], partial_runner)["status"] == "partial"

    stale_runner = FakeWindowsRunner(mise=True)
    stale_plan = build_plan(
        desired, platform_name="windows", architecture="x86_64", runner=stale_runner
    )
    cargo_path = project / "src-tauri/Cargo.toml"
    original_cargo = cargo_path.read_text(encoding="utf-8")
    cargo_path.write_text(original_cargo + "\n# drift\n", encoding="utf-8")
    try:
        apply_plan(stale_plan, stale_plan["digest"], stale_runner)
    except ApplyRefused as exc:
        assert exc.code == "stale_plan"
    else:
        raise AssertionError("source-stale plan was accepted")
    cargo_path.write_text(original_cargo, encoding="utf-8")

    trusted_bridge_root = Path(tempfile.mkdtemp(prefix="sg-trusted-bridge-"))
    provider = trusted_bridge_root / "trusted-provider.ps1"
    provider.write_text("# fixture provider\n", encoding="utf-8")
    (trusted_bridge_root / "ShipGlows.MobileToolchain.psm1").write_text("# fixture module\n", encoding="utf-8")
    powershell = trusted_bridge_root / "pwsh.exe"
    powershell.write_bytes(b"fixture powershell")
    executor = FakeProviderExecutor()
    with patch("cli.environment.windows_tauri_backend._managed_powershell_root", return_value=trusted_bridge_root.resolve()):
        bridge = WindowsEnvironmentRunner(
            LegacyStub(), executor=executor, provider_path=provider, powershell_path=str(powershell.resolve())
        )
    bridge_observed = bridge.windows_environment_observe(project, ".")
    assert bridge_observed["provider"]["path"] == str(provider.resolve())
    assert bridge.windows_environment_apply("install_rust", project, ".")["status"] == "applied"
    assert [json.loads(item.stdin)["action"] for item in executor.requests] == ["observe", "install_rust"]
    assert all(str(project.resolve()) not in " ".join(item.argv) for item in executor.requests)
    assert all(item.argv[-1] == str(provider.resolve()) for item in executor.requests)
    repository_provider = project / "repository-provider.ps1"
    repository_provider.write_text("# untrusted\n", encoding="utf-8")
    (project / "ShipGlows.MobileToolchain.psm1").write_text("# untrusted\n", encoding="utf-8")
    with patch("cli.environment.windows_tauri_backend._managed_powershell_root", return_value=trusted_bridge_root.resolve()):
        repository_bridge = WindowsEnvironmentRunner(
            LegacyStub(), executor=executor, provider_path=repository_provider, powershell_path=str(powershell.resolve())
        )
    try:
        repository_bridge.windows_environment_observe(project, ".")
    except WindowsTauriError:
        pass
    else:
        raise AssertionError("provider inside the managed repository was accepted")

    (project / "mise.toml").write_text('[tools]\nnode="24"\npnpm="10"\n', encoding="utf-8")
    package_document=json.loads((project / "package.json").read_text(encoding="utf-8"));package_document["packageManager"]="pnpm@10.34.5";(project / "package.json").write_text(json.dumps(package_document),encoding="utf-8")
    (project / "mise.lock").write_text(
        '[[tools.node]]\nversion="24.7.0"\nbackend="core:node"\n[tools.node.platforms.windows-x64]\nchecksum="sha256:' + 'f'*64 + '"\nurl="https://nodejs.org/dist/v24.7.0/node-v24.7.0-win-x64.zip"\n'
        '[[tools.pnpm]]\nversion="10.34.5"\nbackend="aqua:pnpm/pnpm"\n[tools.pnpm.platforms.windows-x64]\nchecksum="sha256:' + 'e'*64 + '"\nurl="https://github.com/pnpm/pnpm/releases/download/v10.34.5/pnpm-win-x64.exe"\n',
        encoding="utf-8",
    )
    composed = json.loads(json.dumps(desired))
    composed["management"] = "explicit"
    composed["manifest"]["backends"] = {"windows": {"mise": str(project / "mise.toml")}}
    for item in composed["manifest"]["capabilities"]["tools"]:
        if item["id"] == "node" and item.get("scope", ".") == ".": item["constraint"] = "24"
        if item["id"] == "pnpm" and item.get("scope", ".") == ".": item["constraint"] = "10"
    composed_runner = FakeWindowsRunner(mise=True)
    composed_runner.trusted_root = trusted_bridge_root
    (trusted_bridge_root / "mise.exe").write_bytes(b"fixture mise")
    composed_plan = build_plan(composed, platform_name="windows", architecture="x86_64", runner=composed_runner)
    assert {item["capability"]["id"] for item in composed_plan["operations"]} >= {"node", "pnpm", "rustc", "tauri-windows"}
    executable_owners={item["owner"] for item in composed_plan["operations"] if item.get("executable")}
    assert executable_owners == {"mise"}, executable_owners

    legacy = json.loads(json.dumps(desired))
    legacy_target = next(
        item for item in legacy["manifest"]["capabilities"]["targets"]
        if item["id"] == "tauri-windows"
    )
    legacy_target["id"] = "tauri"
    legacy_plan = build_plan(
        legacy, platform_name="windows", architecture="x86_64", runner=converged_runner
    )
    assert any(
        item["capability"]["id"] == "tauri" and item["status"] == "ready"
        for item in legacy_plan["operations"]
    )

print("ShipGlows composable Windows Tauri backend contract: OK")
