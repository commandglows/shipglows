#!/usr/bin/env python3
"""Resolve Atlas surface/function impact before an agent changes project files."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


PROTECTED = {"gold", "diamond"}
USER_DIMENSIONS = {"copy", "design", "function"}


def read_atlas(path: Path) -> dict[str, Any]:
    value = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(value, dict) or value.get("format_version") != "2.0":
        raise ValueError("atlas must be a v2 JSON object")
    return value


def project_path(value: str, root: Path) -> str:
    path = Path(value)
    if path.is_absolute():
        try:
            path = path.resolve().relative_to(root.resolve())
        except ValueError as error:
            raise ValueError(f"changed path escapes project root: {value}") from error
    if any(part in {"", ".", ".."} for part in path.parts):
        raise ValueError(f"changed path must be project-relative: {value}")
    return path.as_posix()


def related(left: str, right: str) -> bool:
    return left == right or left.startswith(right + "/") or right.startswith(left + "/")


def protected(assessment: Any) -> tuple[str, bool]:
    quality = assessment.get("quality", "unknown") if isinstance(assessment, dict) else "unknown"
    return quality, quality in PROTECTED


def parsed_impact_paths(surface: dict[str, Any]) -> list[tuple[str, list[str]]]:
    paths: list[tuple[str, list[str]]] = []
    for entry in surface.get("impact_paths", []):
        if isinstance(entry, str):
            paths.append((entry, list(surface.get("impact_categories", []))))
        elif isinstance(entry, dict) and isinstance(entry.get("path"), str) and isinstance(entry.get("dimensions"), list):
            paths.append((entry["path"], entry["dimensions"]))
    return paths


def parse_allow(value: str) -> tuple[str, str]:
    try:
        subject_id, dimension = value.rsplit(":", 1)
    except ValueError as error:
        raise ValueError("authorization must use <surface-or-function-id>:<dimension>") from error
    if not subject_id or dimension not in USER_DIMENSIONS:
        raise ValueError("authorization must name a target and copy, design or function")
    return subject_id, dimension


def build_report(atlas: dict[str, Any], changed: list[str], allowed: set[tuple[str, str]]) -> dict[str, Any]:
    surfaces = {item.get("surface_id"): item for item in atlas.get("surfaces", []) if isinstance(item, dict)}
    functions = {item.get("function_id"): item for item in atlas.get("functions", []) if isinstance(item, dict)}
    impacts: list[dict[str, Any]] = []
    matched_paths: set[str] = set()

    for surface_id, surface in surfaces.items():
        for source_path, dimensions in parsed_impact_paths(surface):
            for path in changed:
                if related(path, source_path):
                    matched_paths.add(path)
                    for dimension in dimensions:
                        quality, is_protected = protected((surface.get("assessments") or {}).get(dimension)) if dimension in USER_DIMENSIONS else ("unknown", False)
                        impacts.append({"subject_type": "surface", "subject_id": surface_id, "dimension": dimension, "quality": quality, "protected": is_protected, "path": path, "mapped_path": source_path})

    for function_id, function in functions.items():
        dependencies = function.get("dependencies") or {}
        for group in ("frontend", "backend"):
            for source_path in dependencies.get(group, []):
                if not isinstance(source_path, str):
                    continue
                for path in changed:
                    if related(path, source_path):
                        matched_paths.add(path)
                        quality, is_protected = protected(function.get("assessment"))
                        impacts.append({"subject_type": "function", "subject_id": function_id, "dimension": "function", "quality": quality, "protected": is_protected, "path": path, "mapped_path": source_path})

    unique = {(item["subject_type"], item["subject_id"], item["dimension"], item["path"], item["mapped_path"]): item for item in impacts}
    impacts = list(unique.values())
    blocked = [item for item in impacts if item["protected"] and (item["subject_id"], item["dimension"]) not in allowed]
    unknown = [path for path in changed if path not in matched_paths]
    verdict = "block" if blocked else "review" if unknown else "clear"
    return {
        "kind": "atlas_preflight_report", "format_version": "2.0", "project": atlas.get("project"), "verdict": verdict,
        "changed_paths": changed, "impacts": impacts, "blocked": blocked, "unknown_paths": unknown,
        "authorization_required": sorted({f"{item['subject_id']}:{item['dimension']}" for item in blocked}),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--atlas", type=Path, required=True)
    parser.add_argument("--project-root", type=Path, default=Path.cwd())
    parser.add_argument("--changed", action="append", required=True, help="Project-relative changed path; repeat for every intended file.")
    parser.add_argument("--allow", action="append", default=[], help="Explicit authorization <surface-or-function-id>:<dimension>.")
    args = parser.parse_args()
    try:
        root = args.project_root.resolve()
        report = build_report(read_atlas(args.atlas), [project_path(path, root) for path in args.changed], {parse_allow(value) for value in args.allow})
    except (OSError, ValueError, json.JSONDecodeError) as error:
        raise SystemExit(f"refused: {error}") from error
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return 2 if report["verdict"] == "block" else 0


if __name__ == "__main__":
    raise SystemExit(main())
