#!/usr/bin/env python3
import json
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))
from cli.environment.core import ContractError, discover_project  # noqa: E402
from cli.environment.preparation import apply_preparation_plan, build_preparation_plan  # noqa: E402

with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    empty = root / "empty"
    empty.mkdir()
    assert build_preparation_plan(empty)["classification"] == "manual"
    invalid = root / "invalid"
    invalid.mkdir()
    (invalid / "package.json").write_text("{", encoding="utf-8")
    assert build_preparation_plan(invalid)["classification"] == "blocked"
    assert (invalid / "package.json").read_text(encoding="utf-8") == "{"
    monorepo = root / "monorepo"
    (monorepo / "apps" / "site").mkdir(parents=True)
    (monorepo / "apps" / "mobile").mkdir(parents=True)
    (monorepo / "package.json").write_text(json.dumps({"packageManager": "pnpm@10.33.2", "engines": {"node": ">=24"}}), encoding="utf-8")
    (monorepo / "pnpm-lock.yaml").write_text("lockfileVersion: '9.0'\n", encoding="utf-8")
    (monorepo / "apps" / "site" / "package.json").write_text(json.dumps({"dependencies": {"astro": "^5.0.0"}}), encoding="utf-8")
    (monorepo / "apps" / "mobile" / "pubspec.yaml").write_text("environment:\n  sdk: '>=3.8.0 <4.0.0'\n", encoding="utf-8")
    first = build_preparation_plan(monorepo)
    assert first == build_preparation_plan(monorepo)
    assert first["classification"] == "repairable"
    assert {item["kind"] for item in first["surfaces"]} >= {"astro", "flutter"}
    assert next(item for item in first["operation"]["content"].splitlines() if '"id": "flutter"' in item)
    generated = json.loads(first["operation"]["content"])
    assert next(item for item in generated["capabilities"]["tools"] if item["id"] == "flutter")["constraint"] == "*"
    malformed_engine = root / "malformed-engine"
    malformed_engine.mkdir()
    (malformed_engine / "package.json").write_text(
        json.dumps({"engines": {"node": {"unexpected": True}}}), encoding="utf-8"
    )
    malformed_plan = build_preparation_plan(malformed_engine)
    malformed_manifest = json.loads(malformed_plan["operation"]["content"])
    assert malformed_manifest["capabilities"]["tools"][0]["constraint"] == "*"
    assert apply_preparation_plan(monorepo, first["digest"])["changed"] is True
    healthy = build_preparation_plan(monorepo)
    assert healthy["classification"] == "healthy"
    assert apply_preparation_plan(monorepo, healthy["digest"])["changed"] is False
    tauri = root / "tauri"
    (tauri / "src-tauri").mkdir(parents=True)
    (tauri / "site").mkdir()
    (tauri / "package.json").write_text(
        json.dumps(
            {
                "engines": {"node": ">=24.0.0 <25"},
                "packageManager": "pnpm@8.11.0",
                "devDependencies": {"@tauri-apps/cli": "2.11.4"},
            }
        ),
        encoding="utf-8",
    )
    (tauri / "site/package.json").write_text(
        json.dumps({"engines": {"node": ">=24.0.0"}, "packageManager": "npm@11.14.1"}),
        encoding="utf-8",
    )
    (tauri / "src-tauri/Cargo.toml").write_text(
        '[package]\nname="fixture"\nversion="0.1.0"\nrust-version="1.88.0"\n',
        encoding="utf-8",
    )
    tauri_plan = build_preparation_plan(tauri)
    tauri_manifest = json.loads(tauri_plan["operation"]["content"])
    scoped_tools = {
        (item["id"], item.get("scope", "."), item.get("constraint"))
        for item in tauri_manifest["capabilities"]["tools"]
    }
    assert ("pnpm", ".", "8.11.0") in scoped_tools
    assert ("npm", "site", "11.14.1") in scoped_tools
    assert ("rustc", ".", ">=1.88.0") in scoped_tools
    assert any(item["id"] == "tauri-windows" and item.get("scope") == "." for item in tauri_manifest["capabilities"]["targets"])
    assert apply_preparation_plan(tauri, tauri_plan["digest"])["changed"] is True
    prepared = build_preparation_plan(tauri)
    assert prepared["classification"] == "healthy"
    prepared_desired = discover_project(tauri)
    assert any(
        item["id"] == "tauri-windows" and item.get("scope") == "."
        for item in prepared_desired["manifest"]["capabilities"]["targets"]
    )
    obsidian = root / "obsidian-monorepo"
    plugin = obsidian / "obsidian_plugin"
    extension = obsidian / "chrome_extension"
    (plugin / "src").mkdir(parents=True)
    extension.mkdir(parents=True)
    (plugin / "package.json").write_text(
        json.dumps(
            {
                "scripts": {"dev": "vite build --watch", "build": "vite build"},
                "devDependencies": {"obsidian": "^1.7.2", "vite": "^8.2.0"},
            }
        ),
        encoding="utf-8",
    )
    (plugin / "manifest.json").write_text(
        json.dumps(
            {
                "id": "dreamglows",
                "name": "DreamGlows",
                "version": "1.0.0",
                "minAppVersion": "0.15.0",
                "description": "Fixture",
            }
        ),
        encoding="utf-8",
    )
    (plugin / "src" / "main.ts").write_text("export default class FixturePlugin {}\n", encoding="utf-8")
    (extension / "package.json").write_text(
        json.dumps(
            {
                "scripts": {"dev": "vite", "dev:chrome": "vite -c vite.chrome.config.ts"},
                "devDependencies": {"@crxjs/vite-plugin": "^2.7.1", "vite": "^8.2.0"},
            }
        ),
        encoding="utf-8",
    )
    obsidian_plan = build_preparation_plan(obsidian)
    obsidian_surface = next(item for item in obsidian_plan["surfaces"] if item["kind"] == "obsidian-plugin")
    assert obsidian_surface["pluginId"] == "dreamglows"
    assert obsidian_surface["state"] == "detected"
    assert "manifest.json" in obsidian_surface["evidence"]
    assert obsidian_plan["classification"] == "manual"
    assert obsidian_plan["operation"] is None
    assert any(item["code"] == "obsidian-vault-not-configured" for item in obsidian_plan["notices"])
    (plugin / ".shipglows.env").write_text(
        f"SHIPGLOWS_OBSIDIAN_VAULT={root / 'missing-vault'}\nSHIPGLOWS_OBSIDIAN_SYNC_MODE=copy\n",
        encoding="utf-8",
    )
    invalid_vault_plan = build_preparation_plan(obsidian)
    invalid_vault_surface = next(item for item in invalid_vault_plan["surfaces"] if item["kind"] == "obsidian-plugin")
    assert invalid_vault_surface["state"] == "detected"
    assert invalid_vault_surface["configurationStatus"] == "invalid"
    assert invalid_vault_plan["classification"] == "manual"
    assert invalid_vault_plan["operation"] is None
    assert any(item["code"] == "obsidian-vault-invalid" for item in invalid_vault_plan["notices"])
    stale = root / "stale"
    stale.mkdir()
    (stale / "package.json").write_text("{}", encoding="utf-8")
    stale_plan = build_preparation_plan(stale)
    (stale / "requirements.txt").write_text("pytest\n", encoding="utf-8")
    try:
        apply_preparation_plan(stale, stale_plan["digest"])
    except ContractError:
        pass
    else:
        raise AssertionError("A stale preparation plan must be refused")
print("ShipGlows preparation contract: OK")
