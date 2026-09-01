#!/usr/bin/env python3
import io
import json
import os
import shutil
import stat
import subprocess
import sys
import tempfile
import time
from contextlib import redirect_stderr, redirect_stdout
from pathlib import Path
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))

from cli.environment.core import (  # noqa: E402
    ApplyRefused,
    ContractError,
    _acquire_lock,
    discover_project,
    load_manifest,
    observe_project,
    read_project_state,
    redact,
    verify_project,
)
from cli.environment import shipglows_environment as environment_cli  # noqa: E402


def expect_contract_error(callable_, fragment):
    try:
        callable_()
    except ContractError as exc:
        assert fragment in str(exc), str(exc)
    else:
        raise AssertionError(f"expected ContractError containing {fragment!r}")


with tempfile.TemporaryDirectory() as directory:
    fixture = Path(directory)
    project = fixture / "project"
    state_root = fixture / "state"
    project.mkdir()

    secret_canaries = (
        "auth-bearer-canary",
        "auth-basic-canary",
        "lone-bearer-canary",
        "token-assignment-canary",
        "secret-assignment-canary",
        "password-assignment-canary",
        "url-query-canary",
        "nested-key-canary",
        "apply-basic-canary",
        "encoded-query-canary",
        "encoded-path-canary",
        "encoded-fragment-canary",
    )
    contextual = redact(
        {
            "diagnostic": (
                "token validation failed: Authorization: Bearer auth-bearer-canary; "
                "Authorization = Basic auth-basic-canary"
            ),
            "standalone": "upstream rejected Bearer lone-bearer-canary while preserving context",
            "assignments": (
                'token=token-assignment-canary secret: secret-assignment-canary '
                'password "password-assignment-canary"'
            ),
            "request": (
                "fetch failed for "
                "https://user:password@example.test/private?api_key=url-query-canary&view=full"
            ),
            "encoded_urls": (
                "https://example.test/private?detail=Authorization%3A%20Bearer%20encoded-query-canary "
                "https://example.test/Authorization%3A%20Basic%20encoded-path-canary "
                "https://example.test/private#Bearer%20encoded-fragment-canary"
            ),
            "nested": [{"metadata": {"api_token": "nested-key-canary", "safe": "visible"}}],
        }
    )
    contextual_json = json.dumps(contextual)
    for canary in secret_canaries:
        assert canary not in contextual_json, f"contextual redaction leaked {canary}"
    assert "[REDACTED]" in contextual_json
    assert "token validation failed" in contextual_json
    assert "upstream rejected" in contextual_json
    assert "view=full" in contextual_json
    assert contextual["nested"][0]["metadata"]["safe"] == "visible"

    cli_error = io.StringIO()
    with patch.object(
        environment_cli,
        "discover_project",
        side_effect=ContractError(
            "inspection failed: Authorization: Bearer auth-bearer-canary"
        ),
    ), redirect_stderr(cli_error):
        cli_exit = environment_cli.main(["inspect", "--project", str(project)])
    cli_diagnostic = cli_error.getvalue()
    assert cli_exit == 2
    assert "auth-bearer-canary" not in cli_diagnostic
    assert "[REDACTED]" in cli_diagnostic
    assert "inspection failed" in cli_diagnostic

    apply_error = io.StringIO()
    with patch.object(environment_cli, "discover_project", return_value={}), patch.object(
        environment_cli, "build_plan", return_value={}
    ), patch.object(
        environment_cli,
        "apply_plan",
        side_effect=ApplyRefused(
            "backend_failed",
            "apply failed: Authorization: Basic apply-basic-canary",
        ),
    ), redirect_stdout(apply_error):
        apply_exit = environment_cli.main(
            ["apply", "--project", str(project), "--plan-digest", "f" * 64]
        )
    apply_diagnostic = apply_error.getvalue()
    assert apply_exit == 3
    assert "apply-basic-canary" not in apply_diagnostic
    assert "[REDACTED]" in apply_diagnostic
    assert "apply failed" in apply_diagnostic

    unknown_manifest = {
        "schema": "shipglows.environment/v1",
        "capabilities": {"tools": [{"id": "repository-provided-probe"}]},
    }
    (project / "shipglows.environment.json").write_text(json.dumps(unknown_manifest), encoding="utf-8")
    desired = discover_project(project)
    with patch("cli.environment.core.shutil.which", return_value=str(fixture / "repository-provided-probe")), patch(
        "cli.environment.core.subprocess.run",
        side_effect=AssertionError("an unknown manifest capability executed a process"),
    ) as process_run:
        observed = observe_project(desired, architecture="x86_64")
    assert not process_run.called
    assert observed["capabilities"][0]["status"] == "unknown"

    trusted_manifest = {
        "schema": "shipglows.environment/v1",
        "capabilities": {"tools": [{"id": "git"}]},
    }
    (project / "shipglows.environment.json").write_text(json.dumps(trusted_manifest), encoding="utf-8")
    desired = discover_project(project)
    with patch("cli.environment.core.shutil.which", return_value=str(fixture / "git")), patch(
        "cli.environment.core.subprocess.run",
        side_effect=AssertionError("inspect executed a version probe"),
    ) as process_run:
        observed = observe_project(desired, architecture="x86_64")
    assert not process_run.called
    assert observed["capabilities"][0]["status"] == "unknown"

    constrained_manifest = {
        "schema": "shipglows.environment/v1",
        "capabilities": {"tools": [{"id": "node", "constraint": "999"}]},
    }
    (project / "shipglows.environment.json").write_text(json.dumps(constrained_manifest), encoding="utf-8")
    desired = discover_project(project)
    completed = subprocess.CompletedProcess(["node", "--version"], 0, stdout="v24.0.0\n")
    with patch("cli.environment.core.shutil.which", return_value=str(fixture / "node")), patch(
        "cli.environment.core.subprocess.run", return_value=completed
    ):
        constrained = observe_project(desired, architecture="x86_64", platform_name="unix", probe_versions=True)
    assert constrained["capabilities"][0]["status"] == "unknown"

    pnpm_manifest = {
        "schema": "shipglows.environment/v1",
        "capabilities": {"tools": [{"id": "pnpm", "constraint": "8.11.0"}]},
    }
    (project / "shipglows.environment.json").write_text(json.dumps(pnpm_manifest), encoding="utf-8")
    desired = discover_project(project)
    warned_version = subprocess.CompletedProcess(
        ["pnpm", "--version"],
        0,
        stdout="WARN Issue while reading config\n8.11.0\n",
    )
    with patch("cli.environment.core.shutil.which", return_value=str(fixture / "pnpm")), patch(
        "cli.environment.core.subprocess.run", return_value=warned_version
    ):
        warned = observe_project(
            desired,
            architecture="x86_64",
            platform_name="unix",
            probe_versions=True,
        )
    assert warned["capabilities"][0]["version"] == "8.11.0"
    assert warned["capabilities"][0]["status"] == "ready"

    mismatched_version = subprocess.CompletedProcess(["pnpm", "--version"], 0, stdout="8.12.0\n")
    with patch("cli.environment.core.shutil.which", return_value=str(fixture / "pnpm")), patch(
        "cli.environment.core.subprocess.run", return_value=mismatched_version
    ):
        mismatched = observe_project(
            desired,
            architecture="x86_64",
            platform_name="unix",
            probe_versions=True,
        )
    assert mismatched["capabilities"][0]["status"] == "incompatible"

    rust_manifest = {
        "schema": "shipglows.environment/v1",
        "capabilities": {"tools": [{"id": "rustc", "constraint": ">=1.88.0", "scope": "."}]},
    }
    (project / "shipglows.environment.json").write_text(json.dumps(rust_manifest), encoding="utf-8")
    desired = discover_project(project)
    rust_version = subprocess.CompletedProcess(
        ["rustc", "--version"], 0, stdout="rustc 1.88.0 (fixture 2026-01-01)\n"
    )
    with patch("cli.environment.core.shutil.which", return_value=str(fixture / "rustc")), patch(
        "cli.environment.core.subprocess.run", return_value=rust_version
    ):
        rust = observe_project(
            desired,
            architecture="x86_64",
            platform_name="windows",
            probe_versions=True,
        )
    rust_observation = next(item for item in rust["capabilities"] if item["id"] == "rustc")
    assert rust_observation["version"] == "1.88.0"
    assert rust_observation["status"] == "ready"

    unconstrained_manifest = {
        "schema": "shipglows.environment/v1",
        "capabilities": {"tools": [{"id": "git"}]},
    }
    (project / "shipglows.environment.json").write_text(json.dumps(unconstrained_manifest), encoding="utf-8")
    desired = discover_project(project)
    empty_version = subprocess.CompletedProcess(["git", "--version"], 0, stdout="")
    with patch("cli.environment.core.shutil.which", return_value=str(fixture / "git")), patch(
        "cli.environment.core.subprocess.run", return_value=empty_version
    ):
        empty = observe_project(desired, architecture="x86_64", probe_versions=True)
    assert empty["capabilities"][0]["status"] == "degraded"

    copied_root = fixture / "copied-runtime"
    copied_environment = copied_root / "cli" / "environment"
    copied_environment.mkdir(parents=True)
    for name in ("__init__.py", "core.py", "preparation.py", "shipglows_environment.py", "versions.py"):
        shutil.copy2(ROOT / "cli" / "environment" / name, copied_environment / name)
    process = subprocess.run(
        [sys.executable, str(copied_environment / "shipglows_environment.py"), "inspect", "--project", str(project), "--state-root", str(state_root)],
        check=False,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        encoding="utf-8",
    )
    assert process.returncode == 0, process.stderr
    assert not (copied_environment / "__pycache__").exists()

    oversized_manifest = project / "oversized.json"
    with oversized_manifest.open("wb") as handle:
        handle.truncate((1024 * 1024) + 1)
    expect_contract_error(lambda: load_manifest(oversized_manifest, project), "size limit")

    outside_manifest = fixture / "outside-manifest.json"
    outside_manifest.write_text('{"schema":"shipglows.environment/v1"}', encoding="utf-8")
    linked_project = fixture / "linked-project"
    linked_project.mkdir()
    try:
        (linked_project / "shipglows.environment.json").symlink_to(outside_manifest)
    except OSError:
        pass
    else:
        expect_contract_error(lambda: discover_project(linked_project), "escapes project root")

    backend = project / "mise.toml"
    with backend.open("wb") as handle:
        handle.truncate((8 * 1024 * 1024) + 1)
    backend_manifest = {
        "schema": "shipglows.environment/v1",
        "backends": {"windows": {"mise": "mise.toml"}},
    }
    (project / "shipglows.environment.json").write_text(json.dumps(backend_manifest), encoding="utf-8")
    expect_contract_error(lambda: discover_project(project), "size limit")

    backend.write_text('[tools]\nnode = "24"\n', encoding="utf-8")
    verify_project(project, state_root)
    state_file = next(state_root.glob("*.json"))
    if os.name != "nt":
        assert stat.S_IMODE(state_root.stat().st_mode) & 0o077 == 0
        assert stat.S_IMODE(state_file.stat().st_mode) & 0o077 == 0

    lock = state_file.with_suffix(state_file.suffix + ".lock")
    lock.write_text('{"pid":99999999}', encoding="ascii")
    old = time.time() - 60
    os.utime(lock, (old, old))
    descriptor = _acquire_lock(lock, timeout_seconds=0.1)
    os.close(descriptor)
    lock.unlink()

    assert read_project_state(project, state_root)["schema"] == "shipglows.environment-state/v1"

print("ShipGlows environment security contract: OK")
