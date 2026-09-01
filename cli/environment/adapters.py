"""Fixed composition registry for environment adapters.

The registry is code-owned: repository data can select declared capabilities,
but can neither add adapters nor supply executable arguments.
"""

from __future__ import annotations

from typing import Any, Dict, Mapping

from . import mise_backend, windows_tauri_backend


WINDOWS_ADAPTERS = ("mise", "windows_tauri")


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
    tauri = windows_tauri_backend.observe_capabilities(desired, runner, offline=offline)
    if tauri is not None:
        observations.extend(tauri)
    for item in observations:
        owned.add((item["kind"], item["id"], item.get("scope", ".")))
    return {"observations": observations, "owned": owned}
