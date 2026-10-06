#!/usr/bin/env python3
"""Observe bounded host hints; never infer tool or transport availability."""

from __future__ import annotations

import argparse
from dataclasses import dataclass
import json
import os
from pathlib import Path
import platform
import subprocess
from typing import Iterable, Mapping


@dataclass(frozen=True)
class ProcessRecord:
    pid: int
    ppid: int
    name: str
    executable: str = ""


def classify_runtime(
    records: Iterable[ProcessRecord], current_pid: int,
    environment: Mapping[str, str], operating_system: str,
    computer_system: Mapping[str, str], *, container_detected: bool = False,
) -> dict[str, str]:
    """Pure classification of supplied observations; no host reads or probes."""
    indexed = {record.pid: record for record in records}
    chain = []
    seen = set()
    pid = current_pid
    while pid in indexed and pid not in seen and len(chain) < 32:
        seen.add(pid)
        record = indexed[pid]
        chain.append(record)
        pid = record.ppid
    names = {record.name.casefold() for record in chain}
    paths = [record.executable.replace("\\", "/").casefold() for record in chain]
    agent_hint = "unknown"
    if any("/windowsapps/openai.codex_" in path for path in paths):
        agent_hint = "packaged-codex-ancestor"
    elif any("/@openai/codex/" in path for path in paths):
        agent_hint = "codex-cli-ancestor"
    elif "codex" in names or "codex.exe" in names:
        agent_hint = "codex-process-ancestor"
    terminal_hint = "unknown"
    for candidates, label in (
        ({"rio", "rio.exe"}, "rio"),
        ({"windowsterminal.exe"}, "windows-terminal"),
        ({"code", "code.exe"}, "vscode-ancestor"),
    ):
        if names & candidates:
            terminal_hint = label
            break
    if environment.get("SSH_CONNECTION") or environment.get("SSH_CLIENT"):
        location = "remote"
    elif environment.get("WSL_DISTRO_NAME"):
        location = "wsl"
    elif environment.get("CI", "").casefold() in {"1", "true", "yes"}:
        location = "ci"
    else:
        location = "unknown"
    model = " ".join(computer_system.get(key, "") for key in ("manufacturer", "model")).casefold()
    if container_detected or environment.get("container"):
        machine = "container"
    elif any(token in model for token in ("virtual machine", "vmware", "virtualbox", "kvm", "qemu", "parallels")):
        machine = "virtual-machine"
    else:
        machine = "unknown"
    return {
        "schema_version": "shipglows.agent-runtime-envelope.v1",
        "operating_system": operating_system.casefold(),
        "agent_surface": "unknown",
        "agent_process_hint": agent_hint,
        "terminal_host_hint": terminal_hint,
        "session_location": location,
        "machine_kind": machine,
        "native_transport": "not-probed",
    }


def _read_bounded(path: Path) -> str:
    with path.open("rb") as stream:
        return stream.read(8192).decode("utf-8", "replace")


def _proc_observation() -> tuple[list[ProcessRecord], dict[str, str]]:
    records = []
    pid = os.getpid()
    seen = set()
    while pid > 0 and pid not in seen and len(records) < 32:
        seen.add(pid)
        directory = Path("/proc") / str(pid)
        try:
            values = dict(line.split(":", 1) for line in _read_bounded(directory / "status").splitlines() if ":" in line)
            parent = int(values.get("PPid", "0").strip())
            try:
                executable = os.readlink(directory / "exe")
            except OSError:
                executable = ""
            records.append(ProcessRecord(pid, parent, values.get("Name", "").strip(), executable))
            pid = parent
        except (OSError, ValueError):
            break
    system = {}
    for key, filename in (("manufacturer", "sys_vendor"), ("model", "product_name")):
        try:
            system[key] = _read_bounded(Path("/sys/class/dmi/id") / filename).strip()
        except OSError:
            pass
    return records, system


def _windows_observation() -> tuple[list[ProcessRecord], dict[str, str]]:
    # Follow only this Python process's ancestry. Never collect command lines.
    command = r"""$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$cursor = [int]$env:SHIPGLOWS_ENVELOPE_PID
$seen = @{}
$records = @()
while ($cursor -gt 0 -and -not $seen.ContainsKey($cursor) -and $records.Count -lt 32) {
    $seen[$cursor] = $true
    $item = Get-CimInstance Win32_Process -Filter "ProcessId = $cursor" | Select-Object Name,ProcessId,ParentProcessId,ExecutablePath
    if (-not $item) { break }
    $records += $item
    $cursor = [int]$item.ParentProcessId
}
$system = Get-CimInstance Win32_ComputerSystem | Select-Object Manufacturer,Model
@{ processes = @($records); system = $system } | ConvertTo-Json -Compress -Depth 4
"""
    environment = dict(os.environ, SHIPGLOWS_ENVELOPE_PID=str(os.getpid()))
    completed = subprocess.run(
        ["powershell.exe", "-NoProfile", "-NonInteractive", "-Command", command],
        env=environment, check=True, capture_output=True, text=True,
        encoding="utf-8-sig", timeout=15,
    )
    if len(completed.stdout) > 65536:
        raise ValueError("Host observation exceeds output bound")
    payload = json.loads(completed.stdout)
    records = [ProcessRecord(int(item["ProcessId"]), int(item["ParentProcessId"]),
                             str(item.get("Name") or ""), str(item.get("ExecutablePath") or ""))
               for item in payload["processes"]]
    system = payload.get("system") or {}
    return records, {"manufacturer": str(system.get("Manufacturer") or ""),
                     "model": str(system.get("Model") or "")}


def observe_runtime() -> dict[str, str]:
    operating_system = platform.system()
    result = classify_runtime([], 0, {}, operating_system, {})
    try:
        if operating_system == "Windows":
            records, system = _windows_observation()
        else:
            records, system = _proc_observation()
        result = classify_runtime(records, os.getpid(), os.environ, operating_system,
                                  system, container_detected=Path("/.dockerenv").exists())
        result["observation_state"] = "observed" if records else "unavailable"
    except (OSError, subprocess.SubprocessError, ValueError, KeyError, TypeError, AttributeError) as error:
        result["observation_state"] = "failed"
        result["error_type"] = type(error).__name__
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--format", choices=("json", "text"), default="json")
    arguments = parser.parse_args()
    result = observe_runtime()
    if arguments.format == "json":
        print(json.dumps(result, sort_keys=True))
    else:
        for key, value in result.items():
            print(f"{key}: {value}")
    return 0 if result["observation_state"] == "observed" else 2


if __name__ == "__main__":
    raise SystemExit(main())
