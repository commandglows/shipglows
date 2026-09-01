#!/usr/bin/env python3
import json
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))

from cli.environment.core import build_plan, discover_project, observe_project  # noqa: E402
from cli.environment.mise_backend import ProcessResult  # noqa: E402


class ScopedToolRunner:
    def __init__(self, root: Path, *, pnpm="8.11.0", npm="11.14.1", corepack=True):
        self.root = root
        self.pnpm = pnpm
        self.npm = npm
        self.corepack = corepack
        self.requests = []

    def which(self, executable):
        if executable == "node.exe":
            return str(self.root / "node.exe")
        if executable == "corepack.cmd" and self.corepack:
            return str(self.root / "corepack.cmd")
        if executable in ("npm", "pnpm"):
            return str(self.root / "hostile-global" / executable)
        return None

    def trusted_roots(self, executable):
        return (self.root,) if executable in ("node.exe", "corepack.cmd") else ()

    def run(self, request):
        self.requests.append(request)
        if request.argv[-1] != "--version":
            raise AssertionError(request.argv)
        if request.argv[0].endswith("node.exe"):
            return ProcessResult(0, "v24.0.0\n", "", False)
        version = self.pnpm if request.argv[-2] == "pnpm" else self.npm
        return ProcessResult(0, version + "\n", "", False)


with tempfile.TemporaryDirectory() as directory:
    project = Path(directory)
    (project / ".flox/env").mkdir(parents=True)
    (project / ".flox/env/manifest.toml").write_text(
        'version = 1\n[install]\nnodejs.pkg-path = "nodejs"\n[options]\nsystems = ["x86_64-linux"]\n',
        encoding="utf-8",
    )
    (project / "src-tauri").mkdir()
    (project / "src-tauri/Cargo.toml").write_text(
        '[package]\nname = "fixture"\nversion = "0.1.0"\nrust-version = "1.88.0"\n',
        encoding="utf-8",
    )
    (project / "src-tauri/tauri.conf.json").write_text("{}\n", encoding="utf-8")
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
    (project / "site").mkdir()
    (project / "site/package.json").write_text(
        json.dumps(
            {
                "engines": {"node": ">=24.0.0"},
                "packageManager": "npm@11.14.1",
                "dependencies": {"astro": "7.2.0"},
            }
        ),
        encoding="utf-8",
    )

    desired = discover_project(project)
    capabilities = desired["manifest"]["capabilities"]
    tools = {(item["id"], item.get("scope", ".")): item for item in capabilities["tools"]}
    targets = {(item["id"], item.get("scope", ".")): item for item in capabilities["targets"]}
    integrations = {(item["id"], item.get("scope", ".")): item for item in capabilities["integrations"]}
    assert tools[("node", ".")]["constraint"] == ">=24.0.0 <25"
    assert tools[("node", "site")]["constraint"] == ">=24.0.0"
    assert tools[("pnpm", ".")]["constraint"] == "8.11.0"
    assert tools[("npm", "site")]["constraint"] == "11.14.1"
    assert tools[("rustc", ".")]["constraint"] == ">=1.88.0"
    assert tools[("cargo", ".")]["constraint"] == "*"
    assert [key for key in tools if key[0] == "cargo"] == [("cargo", ".")]
    assert tools[("rustup", ".")]["constraint"] == "*"
    assert tools[("tauri-cli", ".")]["constraint"] == "2.11.4"
    assert ("tauri-windows", ".") in targets
    assert {("msvc", "."), ("windows-sdk", "."), ("webview2", ".")} <= set(integrations)
    flox = next(source for source in desired["sources"] if source["kind"] == "flox")
    assert flox["compatibility"] == "incompatible"
    assert "Windows" in flox["reason"]

    # M1 fallback proof is deliberately provider-free.  Inject a runner with
    # no Windows provider surface so ambient installed-runtime state cannot
    # change the plan or execute a provider.
    plan = build_plan(desired, platform_name="windows", architecture="x86_64", runner=object())
    operations = {(item["capability"]["id"], item["capability"].get("scope", ".")): item for item in plan["operations"]}
    assert operations[("cargo", ".")]["status"] == "blocked"
    assert "Rust" in operations[("cargo", ".")]["reason"]
    assert operations[("tauri-windows", ".")]["status"] == "blocked"
    assert plan["operations"]

    trusted = project / "trusted-node"
    scoped_runner = ScopedToolRunner(trusted)
    scoped_plan = build_plan(desired, platform_name="windows", architecture="x86_64", runner=scoped_runner)
    scoped_operations = {(item["capability"]["id"], item["capability"].get("scope", ".")): item for item in scoped_plan["operations"]}
    assert scoped_operations[("node", ".")]["status"] == "ready"
    assert scoped_operations[("node", "site")]["status"] == "ready"
    assert scoped_operations[("pnpm", ".")]["status"] == "ready"
    assert scoped_operations[("npm", "site")]["status"] == "ready"
    assert {request.cwd for request in scoped_runner.requests if request.argv[-2:-1] == ("pnpm",)} == {project.resolve()}
    assert {request.cwd for request in scoped_runner.requests if request.argv[-2:-1] == ("npm",)} == {(project / "site").resolve()}
    assert all("hostile-global" not in " ".join(request.argv) for request in scoped_runner.requests)

    mismatch = build_plan(desired, platform_name="windows", architecture="x86_64", runner=ScopedToolRunner(trusted, pnpm="11.0.0", npm="12.0.0"))
    mismatch_operations = {(item["capability"]["id"], item["capability"].get("scope", ".")): item for item in mismatch["operations"]}
    assert mismatch_operations[("pnpm", ".")]["status"] == "incompatible"
    assert mismatch_operations[("npm", "site")]["status"] == "incompatible"
    corepack_missing = build_plan(desired, platform_name="windows", architecture="x86_64", runner=ScopedToolRunner(trusted, corepack=False))
    missing_operations = {(item["capability"]["id"], item["capability"].get("scope", ".")): item for item in corepack_missing["operations"]}
    assert missing_operations[("pnpm", ".")]["status"] == "pending"
    assert missing_operations[("npm", "site")]["status"] == "pending"

    scoped_observed = observe_project(desired, probe_versions=True, platform_name="windows", architecture="x86_64", runner=ScopedToolRunner(trusted))
    scoped_evidence = {(item["id"], item.get("scope", ".")): item for item in scoped_observed["capabilities"]}
    assert scoped_evidence[("pnpm", ".")]["version"] == "8.11.0"
    assert scoped_evidence[("npm", "site")]["version"] == "11.14.1"

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

    # An explicit manifest may add policy, but it must never erase safely
    # inferred native Tauri requirements.
    (project / "shipglows.environment.json").write_text(
        json.dumps(
            {
                "schema": "shipglows.environment/v1",
                "capabilities": {"tools": [{"id": "node", "constraint": ">=24.0.0 <25", "scope": "."}]},
            }
        ),
        encoding="utf-8",
    )
    explicit = discover_project(project)
    explicit_tools = {(item["id"], item.get("scope", ".")) for item in explicit["manifest"]["capabilities"]["tools"]}
    explicit_targets = {(item["id"], item.get("scope", ".")) for item in explicit["manifest"]["capabilities"]["targets"]}
    assert {("cargo", "."), ("rustc", "."), ("rustup", "."), ("tauri-cli", ".")} <= explicit_tools
    assert ("tauri-windows", ".") in explicit_targets

    manifest = json.loads((project / "shipglows.environment.json").read_text(encoding="utf-8"))
    manifest["capabilities"]["targets"] = [{"id": "tauri", "scope": ".", "platforms": ["windows"]}]
    (project / "shipglows.environment.json").write_text(json.dumps(manifest), encoding="utf-8")
    aliased = discover_project(project)
    assert [
        item for item in aliased["manifest"]["capabilities"]["targets"]
        if item["id"] in {"tauri", "tauri-windows"} and item.get("scope", ".") == "."
    ] == [{"id": "tauri", "scope": ".", "platforms": ["windows"]}]

with tempfile.TemporaryDirectory() as directory:
    monorepo = Path(directory)
    for scope in ("apps/desktop-a", "apps/desktop-b"):
        candidate = monorepo / scope
        (candidate / "src-tauri").mkdir(parents=True)
        (candidate / "package.json").write_text(
            json.dumps({"devDependencies": {"@tauri-apps/cli": "2.11.4"}}),
            encoding="utf-8",
        )
        (candidate / "src-tauri/Cargo.toml").write_text(
            '[package]\nname="fixture"\nversion="0.1.0"\nrust-version="1.88.0"\n',
            encoding="utf-8",
        )
    desired = discover_project(monorepo)
    scopes = {
        item["scope"]
        for item in desired["manifest"]["capabilities"]["targets"]
        if item["id"] == "tauri-windows"
    }
    assert scopes == {"apps/desktop-a", "apps/desktop-b"}

with tempfile.TemporaryDirectory() as directory:
    unmanaged = Path(directory)
    desired = discover_project(unmanaged)
    assert desired["management"] == "unmanaged"
    assert observe_project(desired, platform_name="windows")["status"] == "unknown"

with tempfile.TemporaryDirectory() as directory:
    api_only = Path(directory)
    (api_only / "package.json").write_text(
        json.dumps({"dependencies": {"@tauri-apps/api": "2.11.0"}}), encoding="utf-8"
    )
    desired = discover_project(api_only)
    assert not any(
        item["id"] == "tauri-windows"
        for item in desired["manifest"]["capabilities"]["targets"]
    )
    assert not any(
        item["id"] in {"cargo", "rustc", "rustup"}
        for item in desired["manifest"]["capabilities"]["tools"]
    )

with tempfile.TemporaryDirectory() as directory:
    workspace = Path(directory)
    (workspace / "desktop/src-tauri").mkdir(parents=True)
    (workspace / "Cargo.toml").write_text(
        '[workspace]\nmembers=["desktop/src-tauri"]\n[workspace.package]\nrust-version="1.91.0"\n',
        encoding="utf-8",
    )
    (workspace / "desktop/src-tauri/Cargo.toml").write_text(
        '[package]\nname="fixture"\nversion="0.1.0"\nrust-version.workspace=true\n'
        '[dependencies.fixture]\nrust-version="9.99.9"\n',
        encoding="utf-8",
    )
    desired = discover_project(workspace)
    rustc = next(
        item for item in desired["manifest"]["capabilities"]["tools"]
        if item["id"] == "rustc" and item.get("scope") == "desktop"
    )
    assert rustc["constraint"] == ">=1.91.0"

print("ShipGlows inferred project environment contract: OK")
