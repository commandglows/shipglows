"""Fixed composition registry for environment adapters.

The registry is code-owned: repository data can select declared capabilities,
but can neither add adapters nor supply executable arguments.
"""

from __future__ import annotations

import re
from pathlib import Path
from typing import Any, Dict, Mapping

from . import mise_backend, windows_tauri_backend
from .versions import evaluate_version_constraint


WINDOWS_ADAPTERS = ("mise", "windows_tauri")
SCOPED_TOOL_IDS = {"node", "pnpm", "npm"}


def _trusted_tool(runner, name: str) -> str:
    resolved = runner.which(name)
    if not resolved:
        return ""
    candidate = Path(resolved).resolve(strict=False)
    for raw_root in runner.trusted_roots(name):
        root = Path(raw_root).resolve(strict=False)
        try:
            candidate.relative_to(root if root.is_dir() or root.suffix == "" else root.parent)
            return str(candidate)
        except ValueError:
            continue
    return ""


def _probe_version(runner, desired: Mapping[str, Any], capability: Mapping[str, Any]) -> Dict[str, Any]:
    identifier = capability["id"]
    scope = capability.get("scope", ".")
    project_root = Path(desired["project"]["root"]).resolve()
    cwd = project_root if scope == "." else (project_root / scope).resolve()
    try:
        cwd.relative_to(project_root)
    except ValueError:
        return {"status": "blocked", "reason": "tool scope escapes the managed project"}
    if not all(hasattr(runner, name) for name in ("which", "trusted_roots", "run")):
        return {"status": "pending", "reason": "trusted scoped tool runner is unavailable"}
    node = _trusted_tool(runner, "node.exe")
    if not node:
        return {"status": "pending", "reason": "trusted Node executable is unavailable"}
    if identifier == "node":
        executable, argv, purpose = node, (node, "--version"), f"scoped-node-{scope}"
    else:
        corepack = _trusted_tool(runner, "corepack.cmd")
        if not corepack or Path(corepack).parent != Path(node).parent:
            return {"status": "pending", "reason": "trusted Corepack beside Node is unavailable"}
        executable, argv, purpose = corepack, (corepack, identifier, "--version"), f"scoped-{identifier}-{scope}"
    environment = {
        "PATH": str(Path(node).parent),
        "COREPACK_ENABLE_NETWORK": "0",
        "COREPACK_DEFAULT_TO_LATEST": "0",
        "COREPACK_ENABLE_DOWNLOAD_PROMPT": "0",
    }
    result = runner.run(mise_backend.ProcessRequest(purpose, argv, cwd, environment, 10))
    output = (result.stdout or result.stderr).strip()
    match = re.search(r"(?m)^v?(\d+(?:\.\d+){1,3}(?:[-+][0-9A-Za-z.-]+)?)\s*$", output)
    if result.timed_out:
        return {"status": "blocked", "reason": "scoped version probe timed out"}
    if result.returncode != 0 or not match:
        return {"status": "pending", "reason": "scoped version probe returned no usable evidence"}
    version = match.group(1)
    status = evaluate_version_constraint(version, capability.get("constraint", "*"))
    reason = "trusted scoped version satisfies the declared constraint" if status == "ready" else "trusted scoped version does not satisfy the declared constraint" if status == "incompatible" else "declared constraint grammar is unsupported"
    return {"status": status, "reason": reason, "version": version, "path": executable}


def _scoped_tool_operations(desired: Mapping[str, Any], runner, excluded=frozenset()):
    operations = []
    if desired["manifest"].get("backends", {}).get("windows"):
        return operations
    for capability in desired["manifest"]["capabilities"]["tools"]:
        key = ("tool", capability["id"], capability.get("scope", "."))
        if capability["id"] not in SCOPED_TOOL_IDS or key in excluded:
            continue
        evidence = _probe_version(runner, desired, capability)
        operations.append({
            "capability": {"kind": "tool", **capability},
            "owner": "windows_scoped_tools",
            "references": ["trusted-node-corepack-scoped-probe"],
            "status": evidence["status"],
            "executable": False,
            "reason": evidence["reason"],
        })
    return operations


def default_windows_runner():
    legacy = mise_backend.SubprocessRunner()
    if __import__("os").environ.get("SHIPGLOWS_ENVIRONMENT_PROVIDER_DISABLED") == "1":
        return legacy
    return windows_tauri_backend.WindowsEnvironmentRunner(legacy)


def plan_windows(
    desired: Mapping[str, Any],
    architecture: str,
    runner,
    *,
    offline: bool = False,
) -> Dict[str, Any]:
    operations = []
    pilot = None

    legacy = mise_backend.plan_operations(desired, architecture, runner, offline=offline)
    if legacy is not None:
        operations.extend(legacy["operations"])
        pilot = {
            "backend": "mise",
            "capability": "node@24+pnpm@10",
            "offline": offline,
            "documentation": {
                "install": mise_backend.MISE_INSTALL_DOC,
                "exec": mise_backend.MISE_EXEC_DOC,
                "lock": mise_backend.MISE_LOCK_DOC,
                "offline": mise_backend.MISE_OFFLINE_DOC,
            },
        }

    legacy_owned = {
        (item["capability"]["kind"], item["capability"]["id"], item["capability"].get("scope", "."))
        for item in operations if item["capability"]["kind"] != "backend"
    }
    operations.extend(_scoped_tool_operations(desired, runner, legacy_owned))

    tauri = windows_tauri_backend.plan_operations(desired, runner, offline=offline)
    if tauri is not None:
        if any(item.get("executable") for item in operations):
            for item in tauri["operations"]:
                if item.get("executable"):
                    item.update(
                        status="blocked",
                        executable=False,
                        approval="not_required",
                        reason="Windows Tauri apply waits for the approved mise operation and replan",
                    )
        operations.extend(tauri["operations"])

    owned = {
        (
            operation["capability"]["kind"],
            operation["capability"]["id"],
            operation["capability"].get("scope", "."),
        )
        for operation in operations
        if operation["capability"]["kind"] != "backend"
    }
    return {"operations": operations, "pilot": pilot, "owned": owned}


def observe_windows(desired: Mapping[str, Any], architecture: str, runner, *, offline: bool = False):
    observations = []
    owned = set()
    legacy = mise_backend.observe_tools(desired, architecture, runner, offline=offline)
    if legacy is not None:
        observations.extend(legacy)
    legacy_owned = {(item["kind"], item["id"], item.get("scope", ".")) for item in observations}
    scoped_enabled = not desired["manifest"].get("backends", {}).get("windows")
    for capability in desired["manifest"]["capabilities"]["tools"]:
        key = ("tool", capability["id"], capability.get("scope", "."))
        if not scoped_enabled or capability["id"] not in SCOPED_TOOL_IDS or key in legacy_owned:
            continue
        observed = _probe_version(runner, desired, capability)
        item = {"kind": "tool", "id": capability["id"], "scope": capability.get("scope", "."), "status": observed["status"], "source": "trusted_node_corepack", "owner": "windows_scoped_tools", "reason": observed["reason"]}
        if observed.get("version"):
            item["version"] = observed["version"]
        observations.append(item)
    tauri = windows_tauri_backend.observe_capabilities(desired, runner, offline=offline)
    if tauri is not None:
        observations.extend(tauri)
    for item in observations:
        owned.add((item["kind"], item["id"], item.get("scope", ".")))
    return {"observations": observations, "owned": owned}
