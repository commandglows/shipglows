"""Focused contract for an unparseable Rust constraint in the Tauri adapter.

Run from the repository root with the environment-contract suite. This test
uses an injected observation only; it never launches PowerShell or installs a
toolchain.
"""

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))

from cli.environment.windows_tauri_backend import plan_operations


class ReadyProvider:
    def windows_environment_observe(self, project_root: Path, scope: str):
        return {
            "provider": {
                "path": "C:/ShipGlows/provider.ps1",
                "sha256": "a" * 64,
                "powershell_path": "C:/ShipGlows/pwsh.exe",
                "powershell_sha256": "b" * 64,
                "module_path": "C:/ShipGlows/ShipGlows.MobileToolchain.psm1",
                "module_sha256": "c" * 64,
            },
            "winget": {"status": "ready", "path": "C:/Windows/winget.exe", "sha256": "d" * 64},
            "mise": {"status": "ready", "path": "C:/ShipGlows/mise.exe"},
            "rustc": {"status": "ready", "version": "1.97.1"},
            "cargo": {"status": "ready"},
            "rustup": {"status": "ready"},
            "tauri-cli": {"status": "ready", "version": "2.11.4"},
            "msvc": {"status": "ready"},
            "windows-sdk": {"status": "pending"},
            "webview2": {"status": "ready", "version": "140.0.0.0"},
        }


def _desired(root: Path, rust_constraint: str):
    return {
        "project": {"root": str(root)},
        "manifest": {
            "capabilities": {
                "tools": [
                    {"id": "rustc", "constraint": rust_constraint, "scope": "."},
                    {"id": "cargo", "constraint": "*", "scope": "."},
                    {"id": "rustup", "constraint": "*", "scope": "."},
                    {"id": "tauri-cli", "constraint": "2.11.4", "scope": "."},
                ],
                "integrations": [],
                "targets": [{"id": "tauri-windows", "scope": "."}],
            },
        },
    }


def test_unknown_rust_constraint_never_plans_install():
    plan = plan_operations(_desired(Path("C:/fixture"), "^1.97"), ReadyProvider())
    rust_operations = [
        item for item in plan["operations"]
        if item["capability"]["id"] in {"rustc", "cargo", "rustup"}
    ]

    assert len(rust_operations) == 3
    assert all(item["status"] == "blocked" for item in rust_operations)
    assert all(not item.get("executable") for item in rust_operations)
    assert not any(item.get("action") == "install_rust" for item in plan["operations"])
    rustc = next(item for item in rust_operations if item["capability"]["id"] == "rustc")
    assert "unsupported" in rustc["reason"]


if __name__ == "__main__":
    test_unknown_rust_constraint_never_plans_install()
