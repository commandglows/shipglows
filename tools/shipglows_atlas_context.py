#!/usr/bin/env python3
"""Generate the redacted browser context for a ShipGlows product atlas."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import tempfile
from pathlib import Path
from typing import Any


VISIBLE_QUALITIES = {"unknown", "red", "bronze", "silver", "gold", "diamond"}


def atlas_digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read_json(path: Path) -> dict[str, Any]:
    value = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(value, dict):
        raise ValueError("atlas must be a JSON object")
    return value


def quality(assessment: Any) -> dict[str, Any]:
    if not isinstance(assessment, dict):
        return {"quality": "unknown", "focus": False}
    value = assessment.get("quality", "unknown")
    if value not in VISIBLE_QUALITIES:
        raise ValueError(f"invalid quality: {value!r}")
    if value in {"gold", "diamond"} and not isinstance(assessment.get("approval"), dict):
        raise ValueError(f"protected quality {value!r} requires a baseline approval")
    return {"quality": value, "focus": bool(assessment.get("focus", False))}


def build_context(atlas: dict[str, Any], digest: str) -> dict[str, Any]:
    if atlas.get("format_version") != "2.0":
        raise ValueError("atlas format_version must be '2.0'")
    project = atlas.get("project")
    if not isinstance(project, str) or not project:
        raise ValueError("atlas project is required")

    visible_functions: dict[str, dict[str, Any]] = {}
    for function in atlas.get("functions", []):
        if not isinstance(function, dict) or not function.get("operator_observable"):
            continue
        function_id = function.get("function_id")
        label = function.get("label")
        if not isinstance(function_id, str) or not isinstance(label, str):
            raise ValueError("observable function requires function_id and label")
        visible_functions[function_id] = {
            "function_id": function_id,
            "label": label,
            "assessment": quality(function.get("assessment")),
        }

    surfaces: list[dict[str, Any]] = []
    for surface in atlas.get("surfaces", []):
        if not isinstance(surface, dict):
            raise ValueError("surface must be an object")
        surface_id = surface.get("surface_id")
        target_id = surface.get("target_id")
        label = surface.get("label")
        stable = (surface.get("selectors") or {}).get("stable")
        if not all(isinstance(value, str) and value for value in (surface_id, target_id, label, stable)):
            raise ValueError("surface requires IDs, label and stable selector")
        assessments = surface.get("assessments") or {}
        function_ids = [function_id for function_id in surface.get("function_ids", []) if function_id in visible_functions]
        surfaces.append(
            {
                "surface_id": surface_id,
                "target_id": target_id,
                "label": label,
                "route_patterns": surface.get("route_patterns", []),
                "selector": stable,
                "assessments": {"copy": quality(assessments.get("copy")), "design": quality(assessments.get("design"))},
                "functions": [visible_functions[function_id] for function_id in function_ids],
            }
        )

    return {
        "format_version": "2.0",
        "kind": "atlas_browser_context",
        "project": project,
        "atlas_digest": digest,
        "surfaces": surfaces,
    }


def atomic_write(path: Path, value: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile("w", encoding="utf-8", dir=path.parent, delete=False) as handle:
        json.dump(value, handle, ensure_ascii=False, indent=2)
        handle.write("\n")
        temporary = Path(handle.name)
    os.replace(temporary, path)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--atlas", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    atlas = read_json(args.atlas)
    atomic_write(args.output, build_context(atlas, atlas_digest(args.atlas)))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
