#!/usr/bin/env python3
"""Executable mise/Node/pnpm pilot contract with injected process evidence only."""

import json
import os
import sys
import tempfile
from pathlib import Path
from unittest import mock

sys.dont_write_bytecode = True

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))

from cli.environment.core import (  # noqa: E402
    ApplyRefused,
    apply_plan,
    build_plan,
    digest_value,
    discover_project,
    observe_project,
    read_project_state,
    verify_project,
)
from cli.environment.mise_backend import (  # noqa: E402
    ProcessRequest,
    ProcessResult,
    SubprocessRunner,
)


LOCK_CHECKSUM = "f" * 64  # Synthetic fixture evidence; never reported as an official Node checksum.


class FakeRunner:
    trusted_root = None

    def __init__(
        self,
        *,
        mise=True,
        mise_version="2026.8.6",
        node_version=None,
        pnpm_version=None,
        failures=None,
    ):
        if self.trusted_root is None:
            raise AssertionError("FakeRunner.trusted_root must be configured by the fixture")
        self.mise = mise
        self.mise_version = mise_version
        self.node_version = node_version
        self.pnpm_version = pnpm_version
        self.failures = failures or {}
        self.requests = []
        self.mise_path = str(self.trusted_root / "mise.exe")
        self.winget_path = str(self.trusted_root / "winget.exe")

    def which(self, executable):
        if executable == "mise.exe" and self.mise:
            return self.mise_path
        if executable == "winget.exe":
            return self.winget_path
        return None

    def trusted_roots(self, executable):
        return (self.trusted_root,)

    def run(self, request):
        self.requests.append(request)
        failure = self.failures.get(request.purpose)
        if failure:
            return failure
        if request.purpose == "mise-version":
            return ProcessResult(0, self.mise_version + "\n", "", False)
        if request.purpose == "node-mise-path":
            return ProcessResult(0, "C:/mise/installs/node/bin/node.exe\n", "", False) if self.node_version else ProcessResult(1, "", "node is not installed", False)
        if request.purpose == "pnpm-mise-path":
            return ProcessResult(0, "C:/mise/installs/pnpm/pnpm.exe\n", "", False) if self.pnpm_version else ProcessResult(1, "", "pnpm is not installed", False)
        if request.purpose in ("node-user-version", "node-agent-version", "node-post-install-version"):
            if self.node_version:
                return ProcessResult(0, "v" + self.node_version + "\n", "", False)
            return ProcessResult(1, "", "node is not installed", False)
        if request.purpose == "mise-install-node":
            self.node_version = "24.7.0"
            return ProcessResult(0, "installed node 24.7.0\n", "", False)
        if request.purpose in ("pnpm-user-version", "pnpm-agent-version", "pnpm-post-install-version"):
            if self.pnpm_version:
                return ProcessResult(0, self.pnpm_version + "\n", "", False)
            return ProcessResult(1, "", "pnpm is not installed", False)
        if request.purpose == "mise-install-pnpm":
            self.pnpm_version = "10.34.5"
            return ProcessResult(0, "installed pnpm 10.34.5\n", "", False)
        if request.purpose == "winget-acquire-mise":
            self.mise = True
            return ProcessResult(0, "installed jdx.mise\n", "", False)
        raise AssertionError(f"unexpected request purpose: {request.purpose}")


def write_project(
    project,
    *,
    constraint="24",
    pnpm_constraint="10",
    include_lock=True,
    unsafe_config=False,
    package_manager="pnpm@10.34.5",
):
    manifest = {
        "schema": "shipglows.environment/v1",
        "project": {"name": "mise pilot fixture"},
        "capabilities": {
            "tools": [
                {"id": "node", "constraint": constraint},
                {"id": "pnpm", "constraint": pnpm_constraint},
            ]
        },
        "backends": {"windows": {"mise": "mise.toml"}},
    }
    (project / "shipglows.environment.json").write_text(json.dumps(manifest), encoding="utf-8")
    config = '[tools]\nnode = "24"\npnpm = "10"\n'
    if unsafe_config:
        config += '\n[env]\nPILOT = "{{ exec(command=\'whoami\') }}"\n'
    (project / "mise.toml").write_text(config, encoding="utf-8")
    if package_manager is not None:
        (project / "package.json").write_text(
            json.dumps({"packageManager": package_manager}), encoding="utf-8"
        )
    if include_lock:
        (project / "mise.lock").write_text(
            """[[tools.node]]
version = "24.7.0"
backend = "core:node"

[tools.node.platforms.windows-x64]
checksum = "sha256:{checksum}"
url = "https://nodejs.org/dist/v24.7.0/node-v24.7.0-win-x64.zip"

[[tools.pnpm]]
version = "10.34.5"
backend = "aqua:pnpm/pnpm"

[tools.pnpm.platforms.windows-x64]
checksum = "sha256:{checksum}"
url = "https://github.com/pnpm/pnpm/releases/download/v10.34.5/pnpm-win-x64.exe"
""".format(checksum=LOCK_CHECKSUM),
            encoding="utf-8",
        )


def expect_refusal(callable_, code):
    try:
        callable_()
    except ApplyRefused as exc:
        assert exc.code == code, (exc.code, str(exc))
    else:
        raise AssertionError(f"expected refusal {code}")


with tempfile.TemporaryDirectory() as directory:
    fixture = Path(directory)
    trusted_root = fixture / "trusted package binaries"
    trusted_root.mkdir()
    (trusted_root / "mise.exe").write_bytes(b"synthetic mise executable identity")
    (trusted_root / "winget.exe").write_bytes(b"synthetic winget executable identity")
    FakeRunner.trusted_root = trusted_root
    project = fixture / "pro jéct & [agent]"
    project.mkdir()
    write_project(project)

    # Exercise the OS boundary only against a fixed Python child fixture: no
    # package manager or project-provided executable is involved.
    inherited_mise = os.environ.get("MISE_OVERRIDE_CONFIG_FILENAMES")
    inherited_secret_canary = os.environ.get("SHIPGLOWS_SECRET_CANARY")
    os.environ["MISE_OVERRIDE_CONFIG_FILENAMES"] = "hostile-parent-value.toml"
    os.environ["SHIPGLOWS_SECRET_CANARY"] = "must-not-reach-backend-child"
    try:
        isolation_result = SubprocessRunner().run(
            ProcessRequest(
                "agent-child-environment-isolation",
                (
                    sys.executable,
                    "-c",
                    "import json, os; print(json.dumps({k:v for k,v in os.environ.items() if k.startswith('MISE_')})); print(os.environ.get('PATH','')); print(os.environ.get('SHIPGLOWS_SECRET_CANARY',''))",
                ),
                project,
                {"MISE_SAFE": "1"},
                5,
            )
        )
    finally:
        if inherited_mise is None:
            os.environ.pop("MISE_OVERRIDE_CONFIG_FILENAMES", None)
        else:
            os.environ["MISE_OVERRIDE_CONFIG_FILENAMES"] = inherited_mise
        if inherited_secret_canary is None:
            os.environ.pop("SHIPGLOWS_SECRET_CANARY", None)
        else:
            os.environ["SHIPGLOWS_SECRET_CANARY"] = inherited_secret_canary
    assert isolation_result.returncode == 0 and not isolation_result.timed_out
    child_lines = isolation_result.stdout.splitlines()
    assert json.loads(child_lines[0]) == {"MISE_SAFE": "1"}
    assert child_lines[1] == os.environ.get("PATH", "")
    assert child_lines[2] == ""

    poisoned_known_folder = fixture / "poisoned-known-folder"
    inherited_folders = {name: os.environ.get(name) for name in ("LOCALAPPDATA", "USERPROFILE", "ProgramFiles")}
    try:
        for name in inherited_folders:
            os.environ[name] = str(poisoned_known_folder)
        real_roots = SubprocessRunner().trusted_roots("mise.exe")
    finally:
        for name, value in inherited_folders.items():
            if value is None:
                os.environ.pop(name, None)
            else:
                os.environ[name] = value
    assert all(poisoned_known_folder.resolve() not in Path(root).resolve().parents for root in real_roots)

    class FreshInstallRunner(SubprocessRunner):
        def trusted_roots(self, executable):
            return (trusted_root / executable,)

    with mock.patch("cli.environment.mise_backend.shutil.which", return_value=None):
        fresh_install_path = FreshInstallRunner().which("mise.exe")
        assert fresh_install_path is not None
        assert Path(fresh_install_path).resolve() == (trusted_root / "mise.exe").resolve()

    alias_root = fixture / "windows app execution aliases"
    package_root = fixture / "desktop app installer package"
    alias_root.mkdir()
    package_root.mkdir()
    winget_alias = alias_root / "winget.exe"
    packaged_winget = package_root / "winget.exe"
    winget_alias.write_bytes(b"")
    packaged_winget.write_bytes(b"synthetic packaged winget executable")

    class AliasWingetRunner(FakeRunner):
        def __init__(self):
            super().__init__(mise=False)
            self.winget_path = str(winget_alias)

        def trusted_roots(self, executable):
            if executable == "winget.exe":
                return (winget_alias, package_root)
            return super().trusted_roots(executable)

    alias_runner = AliasWingetRunner()
    alias_plan = build_plan(
        discover_project(project),
        platform_name="windows",
        architecture="x86_64",
        runner=alias_runner,
    )
    assert alias_plan["operations"][0]["references"][-2] == f"executable:{packaged_winget.resolve()}"

    missing = FakeRunner(mise=False)
    acquisition = build_plan(
        discover_project(project),
        platform_name="windows",
        architecture="x86_64",
        runner=missing,
    )
    assert [operation["action"] for operation in acquisition["operations"]] == [
        "acquire_mise",
        "install_node",
        "install_pnpm",
    ]
    assert acquisition["operations"][0]["package_id"] == "jdx.mise"
    assert acquisition["operations"][0]["approval"] == "required"
    assert acquisition["operations"][0]["references"][-2] == f"executable:{Path(missing.winget_path).resolve()}"
    assert acquisition["operations"][0]["references"][-1].startswith("sha256:")
    assert acquisition["operations"][1]["status"] == "blocked"
    assert acquisition["operations"][2]["status"] == "blocked"
    assert acquisition["effects"] == {
        "network": True,
        "download": True,
        "privilege": True,
        "consent": True,
    }
    expect_refusal(lambda: apply_plan(acquisition, "0" * 64, missing), "stale_plan")
    assert missing.requests == []
    approved_winget_bytes = Path(missing.winget_path).read_bytes()
    Path(missing.winget_path).write_bytes(b"changed winget after approval")
    expect_refusal(lambda: apply_plan(acquisition, acquisition["digest"], missing), "backend_drift")
    assert missing.requests == []
    Path(missing.winget_path).write_bytes(approved_winget_bytes)
    result = apply_plan(acquisition, acquisition["digest"], missing)
    assert result["status"] == "applied"
    assert [request.purpose for request in missing.requests] == ["winget-acquire-mise"]
    assert missing.requests[0].argv == (
        str(Path(missing.winget_path).resolve()),
        "install",
        "--id",
        "jdx.mise",
        "--exact",
        "--source",
        "winget",
        "--disable-interactivity",
    )

    runner = FakeRunner(node_version=None, pnpm_version=None)
    install = build_plan(
        discover_project(project),
        platform_name="windows",
        architecture="x86_64",
        runner=runner,
    )
    assert install["pilot"]["capability"] == "node@24+pnpm@10"
    assert [operation["action"] for operation in install["operations"]] == [
        "install_node",
        "install_pnpm",
    ]
    assert install["operations"][0]["resolved_version"] == "24.7.0"
    assert install["operations"][0]["integrity"] == "mise.lock checksum"
    assert install["operations"][0]["provenance"] == "not recorded by the core:node lock entry"
    assert install["operations"][1]["resolved_version"] == "10.34.5"
    assert install["operations"][1]["capability"] == {
        "kind": "tool",
        "id": "pnpm",
        "constraint": "10",
    }
    assert install["operations"][0]["references"][-2] == f"executable:{Path(runner.mise_path).resolve()}"
    assert install["operations"][0]["references"][-1].startswith("sha256:")
    runner.requests.clear()
    forged = json.loads(json.dumps(install))
    forged["operations"][0]["owner"] = "repository-command"
    forged_body = dict(forged)
    forged_body.pop("digest")
    forged["digest"] = digest_value(forged_body)
    expect_refusal(lambda: apply_plan(forged, forged["digest"], runner), "invalid_backend")
    assert runner.requests == []

    approved_mise_bytes = Path(runner.mise_path).read_bytes()
    Path(runner.mise_path).write_bytes(b"changed executable after approval")
    expect_refusal(lambda: apply_plan(install, install["digest"], runner), "backend_drift")
    assert runner.requests == []
    Path(runner.mise_path).write_bytes(approved_mise_bytes)

    applied = apply_plan(install, install["digest"], runner)
    assert applied["status"] == "applied"
    assert [request.purpose for request in runner.requests] == [
        "mise-version",
        "mise-install-node",
        "node-mise-path",
        "node-post-install-version",
        "mise-install-pnpm",
        "pnpm-mise-path",
        "pnpm-post-install-version",
    ]
    install_request = runner.requests[1]
    assert install_request.argv[1:] == ("--locked", "install", "node")
    assert runner.requests[4].argv[1:] == ("--locked", "install", "pnpm")
    assert install_request.cwd == project.resolve()
    assert install_request.environment["MISE_SAFE"] == "1"
    assert install_request.environment["MISE_NO_HOOKS"] == "1"
    assert install_request.environment["MISE_NO_ENV"] == "1"
    assert install_request.environment["MISE_AUTO_ENV"] == "false"
    assert install_request.environment["MISE_AUTO_INSTALL"] == "false"
    assert install_request.environment["MISE_EXEC_AUTO_INSTALL"] == "false"
    assert install_request.environment["MISE_NOT_FOUND_AUTO_INSTALL"] == "false"
    assert install_request.environment["MISE_RUN_AUTO_INSTALL"] == "false"
    assert install_request.environment["MISE_OVERRIDE_CONFIG_FILENAMES"] == "mise.toml"
    assert install_request.environment["MISE_OVERRIDE_TOOL_VERSIONS_FILENAMES"] == "none"
    assert install_request.environment["MISE_CONFIG_DIR"].endswith(".shipglows-no-user-mise-config")
    assert Path(install_request.environment["MISE_CEILING_PATHS"]) == project.resolve().parent
    assert install_request.environment["MISE_SYSTEM_DEPS"] == "ignore"
    assert "PATH" not in install_request.environment

    partial_runner = FakeRunner(node_version="24.7.0", pnpm_version=None)
    partial_plan = build_plan(
        discover_project(project),
        platform_name="windows",
        architecture="x86_64",
        runner=partial_runner,
    )
    assert [operation["status"] for operation in partial_plan["operations"]] == [
        "ready",
        "pending",
    ]

    class GlobalFallbackRunner(FakeRunner):
        def run(self, request):
            if request.purpose == "node-mise-path":
                self.requests.append(request)
                return ProcessResult(1, "", "node is not installed by mise", False)
            return super().run(request)

    global_fallback = GlobalFallbackRunner(node_version="24.7.0", pnpm_version=None)
    fallback_plan = build_plan(
        discover_project(project),
        platform_name="windows",
        architecture="x86_64",
        runner=global_fallback,
    )
    assert fallback_plan["operations"][0]["status"] == "pending"
    assert "node-user-version" not in [request.purpose for request in global_fallback.requests]

    partial_runner.requests.clear()
    partial_result = apply_plan(partial_plan, partial_plan["digest"], partial_runner)
    assert partial_result["operations"] == 1
    assert [request.purpose for request in partial_runner.requests] == [
        "mise-version",
        "mise-install-pnpm",
        "pnpm-mise-path",
        "pnpm-post-install-version",
    ]

    mixed_drift_runner = FakeRunner(node_version=None, pnpm_version="10.34.4")
    mixed_drift_plan = build_plan(
        discover_project(project),
        platform_name="windows",
        architecture="x86_64",
        runner=mixed_drift_runner,
    )
    assert mixed_drift_plan["executable"] is False
    assert all(operation["status"] == "blocked" for operation in mixed_drift_plan["operations"])
    mixed_drift_runner.requests.clear()
    expect_refusal(
        lambda: apply_plan(
            mixed_drift_plan, mixed_drift_plan["digest"], mixed_drift_runner
        ),
        "plan_blocked",
    )
    assert mixed_drift_runner.requests == []

    drift_runner = FakeRunner(node_version=None, pnpm_version=None)
    drift_plan = build_plan(
        discover_project(project),
        platform_name="windows",
        architecture="x86_64",
        runner=drift_runner,
    )
    lock_path = project / "mise.lock"
    original_lock = lock_path.read_text(encoding="utf-8")
    lock_path.write_text(original_lock.replace("f" * 64, "e" * 64), encoding="utf-8")
    drift_runner.requests.clear()
    expect_refusal(lambda: apply_plan(drift_plan, drift_plan["digest"], drift_runner), "stale_plan")
    assert drift_runner.requests == []
    lock_path.write_text(original_lock, encoding="utf-8")

    runner.requests.clear()
    converged = build_plan(
        discover_project(project),
        platform_name="windows",
        architecture="x86_64",
        runner=runner,
    )
    assert converged["operations"][0]["status"] == "ready"
    assert converged["operations"][1]["status"] == "ready"
    assert converged["operations"][0]["executable"] is False
    assert apply_plan(converged, converged["digest"], runner)["status"] == "converged"
    apply_purposes = [request.purpose for request in runner.requests]
    assert "mise-install-node" not in apply_purposes

    runner.requests.clear()
    observed = observe_project(
        discover_project(project),
        probe_versions=True,
        runner=runner,
        platform_name="windows",
        architecture="x86_64",
    )
    node_evidence = [item for item in observed["capabilities"] if item["id"] == "node"]
    pnpm_evidence = [item for item in observed["capabilities"] if item["id"] == "pnpm"]
    assert {item["consumer"] for item in node_evidence} == {"powershell", "agent_child"}
    assert all(item["status"] == "ready" for item in node_evidence)
    assert all(item["owner"] == "mise_project" for item in node_evidence)
    assert all("C:\\External Tools" not in json.dumps(item) for item in node_evidence)
    assert {item["consumer"] for item in pnpm_evidence} == {"powershell", "agent_child"}
    assert all(item["status"] == "ready" for item in pnpm_evidence)
    assert all(item["owner"] == "mise_project" for item in pnpm_evidence)
    exec_requests = [request for request in runner.requests if request.purpose.endswith("-version")]
    assert all(request.argv[1:4] == ("--locked", "exec", "--") for request in exec_requests)

    state_root = fixture / "private state"
    verified = verify_project(
        project,
        state_root,
        runner=runner,
        platform_name="windows",
        architecture="x86_64",
    )
    assert "owner=mise_project" in verified["attestation"]
    assert "agent_child" in verified["attestation"]
    assert r"C:\External Tools" not in verified["attestation"]
    persisted = read_project_state(project, state_root)
    assert persisted["observed"]["capabilities"][0]["owner"] == "mise_project"

    offline_ready = build_plan(
        discover_project(project),
        platform_name="windows",
        architecture="x86_64",
        runner=runner,
        offline=True,
    )
    assert offline_ready["operations"][0]["status"] == "ready"
    offline_missing_runner = FakeRunner(node_version=None, pnpm_version=None)
    offline_missing = build_plan(
        discover_project(project),
        platform_name="windows",
        architecture="x86_64",
        runner=offline_missing_runner,
        offline=True,
    )
    assert offline_missing["operations"][0]["status"] == "blocked"
    assert "installed cache" in offline_missing["operations"][0]["reason"]
    offline_missing_runner.requests.clear()
    expect_refusal(
        lambda: apply_plan(offline_missing, offline_missing["digest"], offline_missing_runner),
        "plan_blocked",
    )
    assert offline_missing_runner.requests == []

    broken = FakeRunner(mise_version="")
    broken_plan = build_plan(
        discover_project(project),
        platform_name="windows",
        architecture="x86_64",
        runner=broken,
    )
    assert broken_plan["operations"][0]["status"] == "blocked"
    assert broken_plan["executable"] is False

    timed_out = FakeRunner(
        failures={"mise-version": ProcessResult(None, "", "", True)}
    )
    timeout_plan = build_plan(
        discover_project(project),
        platform_name="windows",
        architecture="x86_64",
        runner=timed_out,
    )
    assert timeout_plan["operations"][0]["status"] == "blocked"
    assert "timed out" in timeout_plan["operations"][0]["reason"]

    nonzero = FakeRunner(
        failures={"mise-version": ProcessResult(7, "", "backend broken", False)}
    )
    nonzero_plan = build_plan(
        discover_project(project),
        platform_name="windows",
        architecture="x86_64",
        runner=nonzero,
    )
    assert nonzero_plan["operations"][0]["status"] == "blocked"
    assert "exited 7" in nonzero_plan["operations"][0]["reason"]

    for failed_result, expected_code in (
        (ProcessResult(9, "", "install failed", False), "backend_failed"),
        (ProcessResult(None, "", "", True), "backend_timeout"),
        (ProcessResult(0, "", "", False), "backend_failed"),
    ):
        failing_apply = FakeRunner(node_version=None, pnpm_version=None)
        failing_plan = build_plan(
            discover_project(project),
            platform_name="windows",
            architecture="x86_64",
            runner=failing_apply,
        )
        failing_apply.requests.clear()
        failing_apply.failures["mise-install-node"] = failed_result
        expect_refusal(
            lambda plan=failing_plan, fake=failing_apply: apply_plan(plan, plan["digest"], fake),
            expected_code,
        )

    for failed_result, expected_code in (
        (ProcessResult(9, "", "acquisition failed", False), "backend_failed"),
        (ProcessResult(None, "", "", True), "backend_timeout"),
        (ProcessResult(0, "", "", False), "backend_failed"),
    ):
        failing_acquisition = FakeRunner(mise=False)
        failing_acquisition.failures["winget-acquire-mise"] = failed_result
        acquisition_plan = build_plan(
            discover_project(project),
            platform_name="windows",
            architecture="x86_64",
            runner=failing_acquisition,
        )
        failing_acquisition.requests.clear()
        expect_refusal(
            lambda plan=acquisition_plan, fake=failing_acquisition: apply_plan(plan, plan["digest"], fake),
            expected_code,
        )

    global_conflict = FakeRunner(node_version="24.7.0", pnpm_version="10.34.5")
    global_conflict.global_node = r"C:\Program Files\nodejs\node.exe"
    conflict_plan = build_plan(
        discover_project(project),
        platform_name="windows",
        architecture="x86_64",
        runner=global_conflict,
    )
    assert conflict_plan["operations"][0]["status"] == "ready"
    assert all("global_node" not in json.dumps(operation) for operation in conflict_plan["operations"])

    repository_executable = FakeRunner(node_version="24.7.0", pnpm_version="10.34.5")
    repository_executable.mise_path = str(project / "mise.exe")
    repository_plan = build_plan(
        discover_project(project),
        platform_name="windows",
        architecture="x86_64",
        runner=repository_executable,
    )
    assert repository_plan["operations"][0]["status"] == "blocked"
    assert repository_executable.requests == []

    arbitrary_external = FakeRunner(node_version="24.7.0", pnpm_version="10.34.5")
    arbitrary_external.mise_path = str(fixture / "untrusted-path" / "mise.exe")
    arbitrary_plan = build_plan(
        discover_project(project),
        platform_name="windows",
        architecture="x86_64",
        runner=arbitrary_external,
    )
    assert arbitrary_plan["operations"][0]["status"] == "blocked"
    assert arbitrary_external.requests == []

    arbitrary_winget = FakeRunner(mise=False)
    arbitrary_winget.winget_path = str(fixture / "untrusted-path" / "winget.exe")
    arbitrary_acquisition = build_plan(
        discover_project(project),
        platform_name="windows",
        architecture="x86_64",
        runner=arbitrary_winget,
    )
    assert arbitrary_acquisition["operations"][0]["status"] == "blocked"
    assert arbitrary_acquisition["operations"][0]["executable"] is False
    assert arbitrary_winget.requests == []

    unsafe = fixture / "unsafe"
    unsafe.mkdir()
    write_project(unsafe, unsafe_config=True)
    unsafe_plan = build_plan(
        discover_project(unsafe),
        platform_name="windows",
        architecture="x86_64",
        runner=FakeRunner(),
    )
    assert unsafe_plan["operations"][0]["status"] == "blocked"
    assert unsafe_plan["executable"] is False

    unlocked = fixture / "unlocked"
    unlocked.mkdir()
    write_project(unlocked, include_lock=False)
    unlocked_plan = build_plan(
        discover_project(unlocked),
        platform_name="windows",
        architecture="x86_64",
        runner=FakeRunner(),
    )
    assert unlocked_plan["operations"][0]["status"] == "blocked"
    assert "mise.lock" in unlocked_plan["operations"][0]["reason"]

    alternate = fixture / "alternate-config"
    alternate.mkdir()
    write_project(alternate)
    (alternate / "mise.local.toml").write_text(
        '[tasks.bad]\nrun = "repository supplied command"\n',
        encoding="utf-8",
    )
    alternate_runner = FakeRunner()
    alternate_plan = build_plan(
        discover_project(alternate),
        platform_name="windows",
        architecture="x86_64",
        runner=alternate_runner,
    )
    assert alternate_plan["operations"][0]["status"] == "blocked"
    assert "alternate mise configuration" in alternate_plan["operations"][0]["reason"]
    assert alternate_runner.requests == []

    mismatched_package_manager = fixture / "mismatched-package-manager"
    mismatched_package_manager.mkdir()
    write_project(mismatched_package_manager, package_manager="pnpm@10.34.4")
    mismatch_runner = FakeRunner(node_version="24.7.0", pnpm_version="10.34.5")
    mismatch_plan = build_plan(
        discover_project(mismatched_package_manager),
        platform_name="windows",
        architecture="x86_64",
        runner=mismatch_runner,
    )
    assert mismatch_plan["operations"][0]["status"] == "blocked"
    assert "packageManager" in mismatch_plan["operations"][0]["reason"]
    assert mismatch_runner.requests == []

    missing_package_json = fixture / "missing-package-json"
    missing_package_json.mkdir()
    write_project(missing_package_json, package_manager=None)
    missing_package_plan = build_plan(
        discover_project(missing_package_json),
        platform_name="windows",
        architecture="x86_64",
        runner=FakeRunner(node_version="24.7.0", pnpm_version="10.34.5"),
    )
    assert all(operation["status"] == "ready" for operation in missing_package_plan["operations"])

    duplicate_package_manager = fixture / "duplicate-package-manager"
    duplicate_package_manager.mkdir()
    write_project(duplicate_package_manager)
    (duplicate_package_manager / "package.json").write_text(
        '{"packageManager":"pnpm@10.34.5","packageManager":"pnpm@10.34.5"}',
        encoding="utf-8",
    )
    duplicate_runner = FakeRunner(node_version="24.7.0", pnpm_version="10.34.5")
    duplicate_plan = build_plan(
        discover_project(duplicate_package_manager),
        platform_name="windows",
        architecture="x86_64",
        runner=duplicate_runner,
    )
    assert duplicate_plan["operations"][0]["status"] == "blocked"
    assert "duplicate key" in duplicate_plan["operations"][0]["reason"]
    assert duplicate_runner.requests == []

    for name, target, replacement, reason_fragment in (
        ("wrong-pnpm-config", 'pnpm = "10"', 'pnpm = "11"', "pnpm"),
        (
            "wrong-pnpm-backend",
            "aqua:pnpm/pnpm",
            "npm:pnpm",
            "ownership",
        ),
        (
            "wrong-pnpm-authority",
            "https://github.com/pnpm/pnpm/",
            "https://example.invalid/pnpm/pnpm/",
            "official HTTPS",
        ),
    ):
        rejected = fixture / name
        rejected.mkdir()
        write_project(rejected)
        source = rejected / ("mise.toml" if name == "wrong-pnpm-config" else "mise.lock")
        source.write_text(
            source.read_text(encoding="utf-8").replace(target, replacement),
            encoding="utf-8",
        )
        rejected_runner = FakeRunner(node_version="24.7.0", pnpm_version="10.34.5")
        rejected_plan = build_plan(
            discover_project(rejected),
            platform_name="windows",
            architecture="x86_64",
            runner=rejected_runner,
        )
        assert rejected_plan["operations"][0]["status"] == "blocked"
        assert reason_fragment in rejected_plan["operations"][0]["reason"]
        assert rejected_runner.requests == []

print("ShipGlows mise backend contract: OK")
