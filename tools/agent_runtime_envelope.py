#!/usr/bin/env python3
"""Report the current agent execution envelope without starting any runtime."""

from __future__ import annotations

from dataclasses import dataclass
import argparse
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
    command_line: str = ""


def _ancestry(records: Iterable[ProcessRecord], start_pid: int) -> list[ProcessRecord]:
    by_pid = {record.pid: record for record in records}
    chain: list[ProcessRecord] = []
    seen: set[int] = set()
    current = by_pid.get(start_pid)
    while current is not None and current.pid not in seen and len(chain) < 32:
        chain.append(current)
        seen.add(current.pid)
        current = by_pid.get(current.ppid)
    return chain


def _contains(chain: Iterable[ProcessRecord], *needles: str) -> bool:
    haystack = "\n".join(
        f"{item.name}\n{item.executable}\n{item.command_line}" for item in chain
    ).casefold()
    return any(needle.casefold() in haystack for needle in needles)


def classify_runtime(
    records: Iterable[ProcessRecord],
    current_pid: int,
    environment: Mapping[str, str],
    operating_system: str,
    computer_system: Mapping[str, str],
) -> dict[str, object]:
    chain = _ancestry(records, current_pid)
    names = [item.name for item in chain]

    if environment.get("SSH_CONNECTION") or environment.get("SSH_CLIENT"):
        session_location = "remote"
    elif environment.get("WSL_DISTRO_NAME"):
        session_location = "wsl"
    elif environment.get("CI"):
        session_location = "ci"
    else:
        session_location = "local"

    system_label = " ".join(
        str(computer_system.get(key, "")) for key in ("manufacturer", "model")
    ).casefold()
    if Path("/.dockerenv").exists() or environment.get("container"):
        machine_kind = "container"
    elif any(token in system_label for token in ("virtual machine", "vmware", "virtualbox", "kvm", "qemu", "parallels")):
        machine_kind = "virtual-machine"
    else:
        machine_kind = "physical-or-undetected"

    if _contains(chain, "windowsapps\\openai.codex_", "chatgpt.exe", "codex desktop"):
        agent_surface = "codex-desktop"
    elif _contains(chain, "@openai\\codex", "@openai/codex", "codex.js"):
        agent_surface = "codex-cli"
    elif _contains(chain, "code.exe", "visual studio code"):
        agent_surface = "ide-extension-or-terminal"
    else:
        agent_surface = "unknown"

    if _contains(chain, "rio.exe"):
        terminal_host = "rio"
    elif _contains(chain, "windowsterminal.exe", "openconsole.exe"):
        terminal_host = "windows-terminal"
    elif _contains(chain, "code.exe"):
        terminal_host = "vscode"
    elif agent_surface == "codex-desktop":
        terminal_host = "codex-desktop"
    else:
        terminal_host = "unknown"

    if agent_surface == "codex-desktop":
        computer_use_transport = "expected-but-must-probe"
        recovery = "Probe the native transport; if absent, verify the Computer Use server and skill toggles in Codex Desktop."
    elif agent_surface == "codex-cli":
        computer_use_transport = "not-provided-by-standalone-cli"
        recovery = "Run the GUI-dependent task from Codex Desktop; restarting the same standalone CLI host cannot create the Desktop native pipe."
    else:
        computer_use_transport = "unknown-must-probe"
        recovery = "Identify the agent host before recommending a transport restart or configuration change."

    return {
        "schema_version": "shipglows.agent-runtime-envelope.v1",
        "operating_system": operating_system.casefold(),
        "agent_surface": agent_surface,
        "terminal_host": terminal_host,
        "session_location": session_location,
        "machine_kind": machine_kind,
        "computer_use_native_transport": computer_use_transport,
        "computer_use_recovery": recovery,
        "process_ancestry": names,
    }


def _windows_observation() -> tuple[list[ProcessRecord], dict[str, str]]:
    command = r"""
$processes = Get-CimInstance Win32_Process | Select-Object Name,ProcessId,ParentProcessId,ExecutablePath,CommandLine
$system = Get-CimInstance Win32_ComputerSystem | Select-Object Manufacturer,Model
@{ processes = @($processes); system = $system } | ConvertTo-Json -Compress -Depth 4
"""
    completed = subprocess.run(
        ["powershell.exe", "-NoProfile", "-NonInteractive", "-Command", command],
        check=True,
        capture_output=True,
        text=True,
        encoding="utf-8",
        timeout=15,
    )
    payload = json.loads(completed.stdout)
    records = [
        ProcessRecord(
            int(item.get("ProcessId") or 0),
            int(item.get("ParentProcessId") or 0),
            str(item.get("Name") or ""),
            str(item.get("ExecutablePath") or ""),
            str(item.get("CommandLine") or ""),
        )
        for item in payload.get("processes", [])
    ]
    system = payload.get("system") or {}
    return records, {
        "manufacturer": str(system.get("Manufacturer") or ""),
        "model": str(system.get("Model") or ""),
    }


def _proc_observation() -> tuple[list[ProcessRecord], dict[str, str]]:
    records: list[ProcessRecord] = []
    proc = Path("/proc")
    if not proc.is_dir():
        return records, {}
    for entry in proc.iterdir():
        if not entry.name.isdigit():
            continue
        try:
            status = (entry / "status").read_text(encoding="utf-8", errors="replace")
            values = dict(line.split(":", 1) for line in status.splitlines() if ":" in line)
            command_line = (entry / "cmdline").read_bytes().replace(b"\0", b" ").decode("utf-8", "replace")
            records.append(
                ProcessRecord(
                    int(entry.name),
                    int(values.get("PPid", "0").strip()),
                    values.get("Name", "").strip(),
                    "",
                    command_line,
                )
            )
        except (OSError, ValueError):
            continue
    return records, {}


def observe_runtime() -> dict[str, object]:
    operating_system = platform.system()
    try:
        records, computer_system = (
            _windows_observation() if operating_system == "Windows" else _proc_observation()
        )
        result = classify_runtime(records, os.getpid(), os.environ, operating_system, computer_system)
        result["observation_state"] = "observed"
        return result
    except (OSError, subprocess.SubprocessError, json.JSONDecodeError) as error:
        return {
            "schema_version": "shipglows.agent-runtime-envelope.v1",
            "operating_system": operating_system.casefold(),
            "agent_surface": "unknown",
            "terminal_host": "unknown",
            "session_location": "unknown",
            "machine_kind": "unknown",
            "computer_use_native_transport": "unknown-must-probe",
            "computer_use_recovery": "Host observation failed; retain unknown state and use current-turn tool evidence.",
            "process_ancestry": [],
            "observation_state": "failed",
            "error_type": type(error).__name__,
        }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--format", choices=("json", "text"), default="json")
    args = parser.parse_args()
    result = observe_runtime()
    if args.format == "json":
        print(json.dumps(result, ensure_ascii=False, sort_keys=True))
    else:
        for key, value in result.items():
            print(f"{key}: {value}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
