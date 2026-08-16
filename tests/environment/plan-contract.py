#!/usr/bin/env python3
import json
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))

from cli.environment.core import build_plan, discover_project  # noqa: E402


with tempfile.TemporaryDirectory() as directory:
    project = Path(directory)
    manifest = {
        "schema": "shipglows.environment/v1",
        "project": {"name": "fixture"},
        "capabilities": {
            "tools": [
                {"id": "python", "constraint": ">=3.11"},
                {"id": "node", "constraint": "24"},
            ],
            "targets": [{"id": "android"}],
        },
        "backends": {"windows": {"mise": "mise.toml"}},
    }
    (project / "mise.toml").write_text('[tools]\nnode = "24"\n', encoding="utf-8")
    (project / "shipglows.environment.json").write_text(json.dumps(manifest), encoding="utf-8")

    desired = discover_project(project)
    first = build_plan(desired, platform_name="windows", architecture="x86_64")
    second = build_plan(desired, platform_name="windows", architecture="x86_64")
    assert first == second
    assert first["digest"] == second["digest"]
    assert [item["capability"]["id"] for item in first["operations"]] == ["node", "python", "android"]
    assert all(item["executable"] is False for item in first["operations"])
    assert all(item["status"] == "pending" for item in first["operations"])
    assert first["effects"] == {"network": False, "download": False, "privilege": False, "consent": False}

    (project / "mise.toml").write_text('[tools]\nnode = "24.1.0"\n', encoding="utf-8")
    backend_changed = build_plan(discover_project(project), platform_name="windows", architecture="x86_64")
    assert backend_changed["digest"] != first["digest"]
    (project / "mise.toml").write_text('[tools]\nnode = "24"\n', encoding="utf-8")

    manifest["capabilities"]["tools"][0]["constraint"] = ">=3.12"
    (project / "shipglows.environment.json").write_text(json.dumps(manifest), encoding="utf-8")
    changed = build_plan(discover_project(project), platform_name="windows", architecture="x86_64")
    assert changed["digest"] != first["digest"]

    manifest["backends"]["windows"]["winget_configuration"] = ".config/shipglows/windows.dsc.yaml"
    (project / "shipglows.environment.json").write_text(json.dumps(manifest), encoding="utf-8")
    conflict = build_plan(discover_project(project), platform_name="windows", architecture="x86_64")
    assert all(item["status"] == "blocked" for item in conflict["operations"])
    assert all(item["owner"] is None for item in conflict["operations"])

print("ShipGlows environment plan contract: OK")
