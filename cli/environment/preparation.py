#!/usr/bin/env python3
"""Conservative post-clone preparation diagnosis."""
from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path
from typing import Any

from .core import ContractError, discover_project

PREPARATION_SCHEMA = "shipglows.preparation/v1"
MANIFEST_SCHEMA = "shipglows.environment/v1"
MANIFEST_NAME = "shipglows.environment.json"
MAX_DEPTH = 3
IGNORED_DIRECTORIES = {".git", ".gradle", ".idea", ".next", ".pnpm-store", ".turbo", ".venv", "build", "coverage", "dist", "node_modules", "target", "vendor"}
INTERESTING_NAMES = {"Cargo.toml", "package.json", "pnpm-lock.yaml", "pubspec.yaml", "pyproject.toml", "requirements.txt"}


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


def _infer(root: Path, files: list[Path], blocked: list[dict[str, str]]) -> tuple[list[dict[str, str]], list[dict[str, str]], list[dict[str, str]]]:
    tools: dict[str, str] = {}
    targets: set[str] = set()
    surfaces: list[dict[str, str]] = []
    lock_present = any(path.name == "pnpm-lock.yaml" for path in files)
    for path in files:
        relative = path.relative_to(root).as_posix()
        if path.name == "package.json":
            package = _read_package(path, root, blocked)
            if package is None:
                continue
            engines = package.get("engines") if isinstance(package.get("engines"), dict) else {}
            package_manager = package.get("packageManager") if isinstance(package.get("packageManager"), str) else ""
            tools.setdefault("node", str(engines.get("node", "*")))
            if package_manager.startswith("pnpm@") or lock_present:
                tools.setdefault("pnpm", package_manager.partition("@")[2] or "*")
            dependencies = {**(package.get("dependencies") if isinstance(package.get("dependencies"), dict) else {}), **(package.get("devDependencies") if isinstance(package.get("devDependencies"), dict) else {})}
            astro = "astro" in dependencies or any(candidate.parent == path.parent and candidate.name.startswith("astro.config.") for candidate in files)
            if astro:
                targets.add("web")
            surfaces.append({"kind": "astro" if astro else "node", "path": relative})
        elif path.name == "pubspec.yaml":
            tools.setdefault("flutter", "*")
            targets.add("web")
            surfaces.append({"kind": "flutter", "path": relative})
        elif path.name == "Cargo.toml":
            tools.setdefault("cargo", "*")
            surfaces.append({"kind": "cargo", "path": relative})
        elif path.name in {"pyproject.toml", "requirements.txt"}:
            tools.setdefault("python", "*")
            surfaces.append({"kind": "python", "path": relative})
    return ([{"id": key, "constraint": tools[key]} for key in sorted(tools)], [{"id": key} for key in sorted(targets)], sorted(surfaces, key=lambda item: (item["path"], item["kind"])))


def build_preparation_plan(project_root: str | Path) -> dict[str, Any]:
    root = Path(project_root).resolve(strict=True)
    if not root.is_dir():
        raise ContractError(f"Project path is not a directory: {root}")
    manifest_path = root / MANIFEST_NAME
    files = _bounded_files(root)
    blocked: list[dict[str, str]] = []
    tools, targets, surfaces = _infer(root, files, blocked)
    notices: list[dict[str, str]] = []
    operation: dict[str, Any] | None = None
    if manifest_path.exists():
        try:
            discover_project(root)
        except (ContractError, OSError, UnicodeError, json.JSONDecodeError) as exc:
            blocked.append({"code": "invalid-shipglows-manifest", "path": MANIFEST_NAME, "message": f"Existing ShipGlows manifest preserved: {exc}"})
        classification = "bloquante" if blocked else "saine"
    elif blocked:
        classification = "bloquante"
    elif surfaces:
        manifest = {"schema": MANIFEST_SCHEMA, "project": {"name": root.name}, "capabilities": {"tools": tools, "targets": targets}, "backends": {}}
        operation = {"action": "create", "owner": "shipglows", "path": MANIFEST_NAME, "content": json.dumps(manifest, ensure_ascii=True, indent=2, sort_keys=True) + "\n"}
        classification = "réparable"
        notices.append({"code": "missing-shipglows-manifest", "path": MANIFEST_NAME, "message": "A bounded ShipGlows environment manifest can be created from detected project surfaces."})
    else:
        classification = "manuelle"
        notices.append({"code": "no-trustworthy-project-surface", "path": ".", "message": "No trustworthy project surface was detected; no configuration was invented."})
    source_records = [{"path": path.relative_to(root).as_posix(), "sha256": hashlib.sha256(path.read_bytes()).hexdigest()} for path in files + ([manifest_path] if manifest_path.exists() else [])]
    payload = {"schema": PREPARATION_SCHEMA, "project": str(root), "classification": classification, "surfaces": surfaces, "notices": notices, "blocked": blocked, "operation": operation, "sources": source_records}
    payload["digest"] = _digest(payload)
    return payload


def apply_preparation_plan(project_root: str | Path, expected_digest: str) -> dict[str, Any]:
    plan = build_preparation_plan(project_root)
    if plan["digest"] != expected_digest:
        raise ContractError("Preparation plan is stale; run shipglows env prepare again.")
    if plan["classification"] == "saine":
        return {"status": "converged", "changed": False, "path": MANIFEST_NAME, "digest": expected_digest}
    if plan["classification"] != "réparable" or not plan["operation"]:
        raise ContractError(f"Preparation cannot be applied while classification is {plan['classification']}.")
    target = Path(project_root).resolve(strict=True) / plan["operation"]["path"]
    try:
        with target.open("x", encoding="utf-8", newline="\n") as handle:
            handle.write(plan["operation"]["content"])
    except FileExistsError as exc:
        raise ContractError(f"Refusing to overwrite existing configuration: {target}") from exc
    return {"status": "applied", "changed": True, "path": MANIFEST_NAME, "digest": expected_digest}
