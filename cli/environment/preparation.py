#!/usr/bin/env python3
"""Conservative post-clone preparation diagnosis."""
from __future__ import annotations

import hashlib
import json
import os
import re
from pathlib import Path
from typing import Any

from .core import (
    CAPABILITY_GROUPS,
    ContractError,
    _capability_key,
    _infer_native_capabilities,
    discover_project,
)

PREPARATION_SCHEMA = "shipglows.preparation/v1"
MANIFEST_SCHEMA = "shipglows.environment/v1"
MANIFEST_NAME = "shipglows.environment.json"
MAX_DEPTH = 3
IGNORED_DIRECTORIES = {".git", ".gradle", ".idea", ".next", ".pnpm-store", ".turbo", ".venv", "build", "coverage", "dist", "node_modules", "target", "vendor"}
INTERESTING_NAMES = {
    ".shipglows.env",
    "Cargo.toml",
    "main.js",
    "main.ts",
    "manifest.json",
    "package.json",
    "pnpm-lock.yaml",
    "pubspec.yaml",
    "pyproject.toml",
    "requirements.txt",
    "styles.css",
    "tauri.conf.json",
}


def _digest(value: Any) -> str:
    encoded = json.dumps(value, ensure_ascii=True, separators=(",", ":"), sort_keys=True).encode("utf-8")
    return hashlib.sha256(encoded).hexdigest()


def _bounded_files(root: Path) -> list[Path]:
    found: list[Path] = []
    for current, directories, files in os.walk(root, followlinks=False):
        current_path = Path(current)
        depth = len(current_path.relative_to(root).parts)
        directories[:] = sorted(name for name in directories if name not in IGNORED_DIRECTORIES and not name.startswith(".") and not (current_path / name).is_symlink() and depth < MAX_DEPTH)
        for name in sorted(files):
            if name in INTERESTING_NAMES or name.startswith("astro.config."):
                candidate = current_path / name
                if not candidate.is_symlink():
                    found.append(candidate)
    return sorted(found, key=lambda item: item.relative_to(root).as_posix().casefold())


def _read_package(path: Path, root: Path, blocked: list[dict[str, str]]) -> dict[str, Any] | None:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as exc:
        blocked.append({"code": "invalid-package-manifest", "path": path.relative_to(root).as_posix(), "message": f"Invalid package.json preserved: {exc}"})
        return None
    if not isinstance(value, dict):
        blocked.append({"code": "invalid-package-manifest", "path": path.relative_to(root).as_posix(), "message": "package.json must contain a JSON object; the file was preserved."})
        return None
    return value


def _obsidian_vault_configuration(project: Path) -> str:
    settings = project / ".shipglows.env"
    if not settings.is_file() or settings.is_symlink():
        return "not-configured"
    try:
        lines = settings.read_text(encoding="utf-8").splitlines()
    except (OSError, UnicodeError):
        return "invalid"
    for raw_line in lines:
        line = raw_line.strip()
        if not line.startswith("SHIPGLOWS_OBSIDIAN_VAULT="):
            continue
        declared = os.path.expandvars(line.partition("=")[2].strip())
        if not declared:
            return "not-configured"
        vault = Path(declared)
        try:
            obsidian_directory = vault / ".obsidian"
            if not vault.is_absolute() or vault.is_symlink() or not vault.is_dir():
                return "invalid"
            if obsidian_directory.is_symlink() or not obsidian_directory.is_dir():
                return "invalid"
        except OSError:
            return "invalid"
        return "configured"
    return "not-configured"


def _read_obsidian_manifest(path: Path, root: Path, blocked: list[dict[str, str]]) -> dict[str, Any] | None:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as exc:
        blocked.append({"code": "invalid-obsidian-manifest", "path": path.relative_to(root).as_posix(), "message": f"Invalid Obsidian manifest preserved: {exc}"})
        return None
    if not isinstance(value, dict):
        blocked.append({"code": "invalid-obsidian-manifest", "path": path.relative_to(root).as_posix(), "message": "Obsidian manifest.json must contain a JSON object; the file was preserved."})
        return None
    required = ("id", "name", "version", "minAppVersion")
    if any(not isinstance(value.get(name), str) or not value[name].strip() for name in required):
        blocked.append({"code": "invalid-obsidian-manifest", "path": path.relative_to(root).as_posix(), "message": "Obsidian manifest.json requires non-empty id, name, version, and minAppVersion fields; the file was preserved."})
        return None
    plugin_id = value["id"].strip()
    if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._-]{0,127}", plugin_id):
        blocked.append({"code": "invalid-obsidian-plugin-id", "path": path.relative_to(root).as_posix(), "message": "Obsidian plugin id must be a path-safe identifier; the file was preserved."})
        return None
    return value


def _infer(root: Path, files: list[Path], blocked: list[dict[str, str]]) -> tuple[dict[str, list[dict[str, Any]]], list[dict[str, Any]]]:
    capabilities = _infer_native_capabilities(root, files)
    surfaces: list[dict[str, Any]] = []

    def add(group: str, entry: dict[str, Any]) -> None:
        if not any(_capability_key(existing) == _capability_key(entry) for existing in capabilities[group]):
            capabilities[group].append(entry)

    for path in files:
        relative = path.relative_to(root).as_posix()
        if path.name == "package.json":
            package = _read_package(path, root, blocked)
            if package is None:
                continue
            scope = path.parent.relative_to(root).as_posix() or "."
            engines = package.get("engines") if isinstance(package.get("engines"), dict) else {}
            node_constraint = engines.get("node")
            node_constraint = node_constraint.strip() if isinstance(node_constraint, str) and node_constraint.strip() else "*"
            package_manager = package.get("packageManager") if isinstance(package.get("packageManager"), str) else ""
            add("tools", {"id": "node", "constraint": node_constraint, "scope": scope})
            if package_manager.startswith("pnpm@") or (path.parent / "pnpm-lock.yaml").is_file():
                add("tools", {"id": "pnpm", "constraint": package_manager.partition("@")[2] or "*", "scope": scope})
            elif package_manager.startswith("npm@"):
                add("tools", {"id": "npm", "constraint": package_manager.partition("@")[2] or "*", "scope": scope})
            dependencies = {
                **(package.get("dependencies") if isinstance(package.get("dependencies"), dict) else {}),
                **(package.get("devDependencies") if isinstance(package.get("devDependencies"), dict) else {}),
                **(package.get("peerDependencies") if isinstance(package.get("peerDependencies"), dict) else {}),
            }
            scripts = package.get("scripts") if isinstance(package.get("scripts"), dict) else {}
            obsidian_manifest_path = path.parent / "manifest.json"
            entrypoint = next((candidate for candidate in (path.parent / "main.ts", path.parent / "src" / "main.ts", path.parent / "main.js") if candidate.is_file() and not candidate.is_symlink()), None)
            development_script = next((name for name in ("dev", "watch", "start") if isinstance(scripts.get(name), str) and scripts[name].strip()), None)
            build_script = "build" if isinstance(scripts.get("build"), str) and scripts["build"].strip() else None
            if "obsidian" in dependencies and obsidian_manifest_path.is_file() and entrypoint and (development_script or build_script):
                manifest = _read_obsidian_manifest(obsidian_manifest_path, root, blocked)
                if manifest is None:
                    continue
                evidence = [
                    "manifest.json",
                    "package.json dependency:obsidian",
                    entrypoint.relative_to(path.parent).as_posix(),
                ]
                if development_script:
                    evidence.append(f"scripts.{development_script}")
                if build_script:
                    evidence.append("scripts.build")
                artifacts = [name for name in ("main.js", "manifest.json", "styles.css") if (path.parent / name).is_file() or name in {"main.js", "manifest.json"}]
                vault_configuration = _obsidian_vault_configuration(path.parent)
                main_output = path.parent / "main.js"
                input_paths = (entrypoint, path, obsidian_manifest_path)
                if vault_configuration != "configured":
                    state = "detected"
                elif main_output.is_symlink() or not main_output.is_file() or main_output.stat().st_mtime_ns < max(candidate.stat().st_mtime_ns for candidate in input_paths):
                    state = "build-required"
                else:
                    state = "configured"
                surfaces.append(
                    {
                        "kind": "obsidian-plugin",
                        "path": relative,
                        "pluginId": manifest["id"].strip(),
                        "developmentScript": development_script or "",
                        "buildScript": build_script or "",
                        "artifacts": artifacts,
                        "evidence": evidence,
                        "configurationStatus": vault_configuration,
                        "state": state,
                    }
                )
                continue
            astro = "astro" in dependencies or any(candidate.parent == path.parent and candidate.name.startswith("astro.config.") for candidate in files)
            if astro:
                add("targets", {"id": "web", "scope": scope})
            surfaces.append({"kind": "astro" if astro else "node", "path": relative})
        elif path.name == "pubspec.yaml":
            scope = path.parent.relative_to(root).as_posix() or "."
            add("tools", {"id": "flutter", "constraint": "*", "scope": scope})
            add("targets", {"id": "web", "scope": scope})
            surfaces.append({"kind": "flutter", "path": relative})
        elif path.name == "Cargo.toml":
            surfaces.append({"kind": "cargo", "path": relative})
        elif path.name in {"pyproject.toml", "requirements.txt"}:
            scope = path.parent.relative_to(root).as_posix() or "."
            add("tools", {"id": "python", "constraint": "*", "scope": scope})
            surfaces.append({"kind": "python", "path": relative})
    for group in CAPABILITY_GROUPS:
        capabilities[group].sort(key=_capability_key)
    return capabilities, sorted(surfaces, key=lambda item: (item["path"], item["kind"]))


def build_preparation_plan(project_root: str | Path) -> dict[str, Any]:
    root = Path(project_root).resolve(strict=True)
    if not root.is_dir():
        raise ContractError(f"Project path is not a directory: {root}")
    manifest_path = root / MANIFEST_NAME
    files = _bounded_files(root)
    blocked: list[dict[str, str]] = []
    capabilities, surfaces = _infer(root, files, blocked)
    notices: list[dict[str, str]] = []
    operation: dict[str, Any] | None = None
    unconfigured_obsidian = [surface for surface in surfaces if surface["kind"] == "obsidian-plugin" and surface["state"] == "detected"]
    for surface in unconfigured_obsidian:
        plugin_root = Path(surface["path"]).parent.as_posix()
        invalid = surface.get("configurationStatus") == "invalid"
        notices.append(
            {
                "code": "obsidian-vault-invalid" if invalid else "obsidian-vault-not-configured",
                "path": plugin_root,
                "message": (
                    "The declared Obsidian vault must be an existing absolute directory containing .obsidian; correct SHIPGLOWS_OBSIDIAN_VAULT in the plugin .shipglows.env."
                    if invalid
                    else "Obsidian plugin detected but no vault is configured. Declare SHIPGLOWS_OBSIDIAN_VAULT=<absolute-vault-path> in the plugin .shipglows.env; ShipGlows will not discover or select a personal vault."
                ),
            }
        )
    if manifest_path.exists():
        try:
            discover_project(root)
        except (ContractError, OSError, UnicodeError, json.JSONDecodeError) as exc:
            blocked.append({"code": "invalid-shipglows-manifest", "path": MANIFEST_NAME, "message": f"Existing ShipGlows manifest preserved: {exc}"})
        classification = "blocked" if blocked else ("manual" if unconfigured_obsidian else "healthy")
    elif blocked:
        classification = "blocked"
    elif unconfigured_obsidian:
        classification = "manual"
    elif surfaces:
        manifest = {"schema": MANIFEST_SCHEMA, "project": {"name": root.name}, "capabilities": capabilities, "backends": {}}
        operation = {"action": "create", "owner": "shipglows", "path": MANIFEST_NAME, "content": json.dumps(manifest, ensure_ascii=True, indent=2, sort_keys=True) + "\n"}
        classification = "repairable"
        notices.append({"code": "missing-shipglows-manifest", "path": MANIFEST_NAME, "message": "A bounded ShipGlows environment manifest can be created from detected project surfaces."})
    else:
        classification = "manual"
        notices.append({"code": "no-trustworthy-project-surface", "path": ".", "message": "No trustworthy project surface was detected; no configuration was invented."})
    source_records = [{"path": path.relative_to(root).as_posix(), "sha256": hashlib.sha256(path.read_bytes()).hexdigest()} for path in files + ([manifest_path] if manifest_path.exists() else [])]
    payload = {"schema": PREPARATION_SCHEMA, "project": str(root), "classification": classification, "surfaces": surfaces, "notices": notices, "blocked": blocked, "operation": operation, "sources": source_records}
    payload["digest"] = _digest(payload)
    return payload


def apply_preparation_plan(project_root: str | Path, expected_digest: str) -> dict[str, Any]:
    plan = build_preparation_plan(project_root)
    if plan["digest"] != expected_digest:
        raise ContractError("Preparation plan is stale; run shipglows env prepare again.")
    if plan["classification"] == "healthy":
        return {"status": "converged", "changed": False, "path": MANIFEST_NAME, "digest": expected_digest}
    if plan["classification"] != "repairable" or not plan["operation"]:
        raise ContractError(f"Preparation cannot be applied while classification is {plan['classification']}.")
    target = Path(project_root).resolve(strict=True) / plan["operation"]["path"]
    try:
        with target.open("x", encoding="utf-8", newline="\n") as handle:
            handle.write(plan["operation"]["content"])
    except FileExistsError as exc:
        raise ContractError(f"Refusing to overwrite existing configuration: {target}") from exc
    return {"status": "applied", "changed": True, "path": MANIFEST_NAME, "digest": expected_digest}
