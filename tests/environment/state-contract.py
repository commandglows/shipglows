#!/usr/bin/env python3
import json
import subprocess
import sys
import tempfile
import threading
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))

from cli.environment.core import (  # noqa: E402
    ContractError,
    discover_project,
    read_project_state,
    render_attestation,
    status_project,
    verify_project,
)


with tempfile.TemporaryDirectory() as directory:
    fixture = Path(directory)
    project = fixture / "project"
    state_root = fixture / "state"
    project.mkdir()

    empty = discover_project(project)
    assert empty["management"] == "unmanaged"
    assert empty["sources"] == []

    (project / "mise.toml").write_text('[tools]\nnode = "24"\n', encoding="utf-8")
    (project / ".shipglows.env").write_text("SHIPGLOWS_AUTO_REPAIR=true\n", encoding="utf-8")
    discovered = discover_project(project)
    assert discovered["management"] == "inferred"
    assert discovered["runtime_policy"] == {"port": None, "auto_repair": True}
    assert discovered["sources"][0]["kind"] == "mise"
    assert discovered["sources"][0]["precedence"] == 50

    (project / "shipglows.environment.json").write_text(
        json.dumps(
            {
                "schema": "shipglows.environment/v1",
                "project": {"name": "fixture"},
                "capabilities": {"tools": [{"id": "git"}]},
                "extensions": {"fixture.secret": {"api_token": "state-canary"}},
            }
        ),
        encoding="utf-8",
    )
    inspect_process = subprocess.run(
        [sys.executable, str(ROOT / "cli/environment/shipglows_environment.py"), "inspect", "--project", str(project), "--state-root", str(state_root)],
        check=True,
        stdout=subprocess.PIPE,
        text=True,
        encoding="utf-8",
    )
    assert "state-canary" not in inspect_process.stdout

    results = []
    threads = [
        threading.Thread(target=lambda: results.append(verify_project(project, state_root)))
        for _ in range(4)
    ]
    for thread in threads:
        thread.start()
    for thread in threads:
        thread.join()
    assert len(results) == 4

    state = read_project_state(project, state_root)
    assert state["schema"] == "shipglows.environment-state/v1"
    assert state["project"]["root"] == str(project.resolve())
    assert state["attestation"].startswith("# ShipGlows Environment Attestation\n")
    raw_state = json.dumps(state)
    assert "state-canary" not in raw_state
    assert not list(state_root.glob("*.tmp"))
    assert not list(state_root.glob("*.lock"))

    state_file = next(state_root.glob("*.json"))
    tampered_attestation = json.loads(json.dumps(state))
    tampered_attestation["attestation"] = "# forged attestation\n"
    state_file.write_text(json.dumps(tampered_attestation), encoding="utf-8")
    try:
        read_project_state(project, state_root)
    except ContractError:
        pass
    else:
        raise AssertionError("an attestation inconsistent with its structured evidence must not be trusted")
    verify_project(project, state_root)
    state = read_project_state(project, state_root)

    semantic_corruption = json.loads(json.dumps(state))
    semantic_corruption["observed"]["status"] = "impossible"
    state_file.write_text(json.dumps(semantic_corruption), encoding="utf-8")
    try:
        read_project_state(project, state_root)
    except ContractError:
        pass
    else:
        raise AssertionError("a semantically invalid state record must not be trusted")
    verify_project(project, state_root)
    state = read_project_state(project, state_root)

    attestation = render_attestation(state)
    assert "ShipGlows Environment Attestation" in attestation
    assert "state-canary" not in attestation
    assert str(project.resolve()) not in attestation

    stale = status_project(project, state_root, max_age_seconds=-1)
    assert stale["status"] in ("drifted", "unknown")

    state_file.write_text("{truncated", encoding="utf-8")
    try:
        read_project_state(project, state_root)
    except ContractError:
        pass
    else:
        raise AssertionError("a truncated state record must not be trusted")
    verify_project(project, state_root)
    assert read_project_state(project, state_root)["schema"] == "shipglows.environment-state/v1"

print("ShipGlows environment state contract: OK")
