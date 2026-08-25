#!/usr/bin/env python3
import json
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))

from cli.environment.core import build_plan, discover_project, observe_project  # noqa: E402


with tempfile.TemporaryDirectory() as directory:
    project = Path(directory)
    (project / ".flox/env").mkdir(parents=True)
    (project / ".flox/env/manifest.toml").write_text(
        'version = 1\n[install]\nnodejs.pkg-path = "nodejs"\n[options]\nsystems = ["x86_64-linux"]\n',
        encoding="utf-8",
    )
    (project / "src-tauri").mkdir()
    (project / "src-tauri/Cargo.toml").write_text('[package]\nname = "fixture"\nversion = "0.1.0"\n', encoding="utf-8")
    (project / "package.json").write_text(
        json.dumps(
            {
                "engines": {"node": ">=24.0.0 <25"},
                "packageManager": "pnpm@8.11.0",
                "devDependencies": {"@tauri-apps/cli": "2.11.4"},
            }
        ),
        encoding="utf-8",
    )

    desired = discover_project(project)
    tools = {item["id"]: item for item in desired["manifest"]["capabilities"]["tools"]}
    targets = {item["id"]: item for item in desired["manifest"]["capabilities"]["targets"]}
    assert tools["node"]["constraint"] == ">=24.0.0 <25"
    assert tools["pnpm"]["constraint"] == "8.11.0"
    assert "cargo" in tools and "tauri" in targets
    flox = next(source for source in desired["sources"] if source["kind"] == "flox")
    assert flox["compatibility"] == "incompatible"
    assert "Windows" in flox["reason"]

    plan = build_plan(desired, platform_name="windows", architecture="x86_64")
    operations = {item["capability"]["id"]: item for item in plan["operations"]}
    assert operations["cargo"]["status"] == "blocked"
    assert "Rust" in operations["cargo"]["reason"]
    assert operations["tauri"]["status"] == "blocked"
    assert plan["operations"]

    observed = observe_project(desired, platform_name="windows")
    assert observed["status"] != "ready"
    assert observed["capabilities"]

    state_root = project / "state"
    verify = subprocess.run(
        [sys.executable, str(ROOT / "cli/environment/shipglows_environment.py"), "verify", "--project", str(project), "--state-root", str(state_root)],
        stdout=subprocess.PIPE,
        text=True,
        encoding="utf-8",
        check=False,
    )
    assert verify.returncode != 0
    status = subprocess.run(
        [sys.executable, str(ROOT / "cli/environment/shipglows_environment.py"), "status", "--project", str(project), "--state-root", str(state_root)],
        stdout=subprocess.PIPE,
        text=True,
        encoding="utf-8",
        check=False,
    )
    assert status.returncode != 0

with tempfile.TemporaryDirectory() as directory:
    unmanaged = Path(directory)
    desired = discover_project(unmanaged)
    assert desired["management"] == "unmanaged"
    assert observe_project(desired, platform_name="windows")["status"] == "unknown"

print("ShipGlows inferred project environment contract: OK")
