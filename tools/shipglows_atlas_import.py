#!/usr/bin/env python3
"""Validate and atomically import a local ShipGlows Atlas annotation patch.

The browser can only export a non-canonical patch.  This is deliberately the
only writer for an Atlas: every assertion is checked before the atlas file is
replaced, so a stale or malformed export leaves the source of truth untouched.
"""

from __future__ import annotations

import argparse
import copy
import hashlib
import json
import os
import re
import subprocess
import tempfile
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


QUALITIES = ("unknown", "red", "bronze", "silver", "gold", "diamond")
QUALITY_SET = set(QUALITIES)
DIMENSIONS = {"copy", "design", "function"}
PROTECTED_QUALITIES = {"gold", "diamond"}
SHA_PATTERN = re.compile(r"^[0-9a-f]{40,64}$")
FINGERPRINT_PATTERN = re.compile(r"^[0-9a-f]{32,128}$")
PATCH_KEYS = {"format_version", "kind", "project", "base_atlas_digest", "exported_at", "evidence_manifest", "annotations"}
ANNOTATION_KEYS = {"format_version", "captured_at", "target", "selectors", "annotation", "reference", "evidence"}


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read_object(path: Path, label: str) -> dict[str, Any]:
    value = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(value, dict):
        raise ValueError(f"{label} must be a JSON object")
    return value


def atomic_write(path: Path, value: dict[str, Any]) -> None:
    with tempfile.NamedTemporaryFile("w", encoding="utf-8", dir=path.parent, delete=False) as handle:
        json.dump(value, handle, ensure_ascii=False, indent=2)
        handle.write("\n")
        temporary = Path(handle.name)
    os.replace(temporary, path)


def run_git(project_root: Path, *arguments: str) -> str:
    result = subprocess.run(
        ["git", "-C", str(project_root), *arguments],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if result.returncode != 0:
        detail = result.stderr.strip() or "Git command failed"
        raise ValueError(f"cannot create a protected baseline: {detail}")
    return result.stdout.strip()


def clean_git_commit(project_root: Path) -> str:
    if not project_root.is_dir():
        raise ValueError("protected baseline project root does not exist")
    if run_git(project_root, "status", "--porcelain"):
        raise ValueError("cannot create a protected baseline from a dirty repository; commit or stash the current work first")
    commit = run_git(project_root, "rev-parse", "HEAD")
    if not SHA_PATTERN.fullmatch(commit):
        raise ValueError("cannot create a protected baseline without a full Git commit SHA")
    return commit


def parse_timestamp(value: Any, label: str) -> None:
    if not isinstance(value, str) or not value:
        raise ValueError(f"{label} must be a non-empty ISO-8601 timestamp")
    try:
        datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError as error:
        raise ValueError(f"{label} must be a valid ISO-8601 timestamp") from error


def relative_reference(value: Any, label: str) -> None:
    if not isinstance(value, str) or not value or value.startswith(("/", "~", "http:", "https:", "file:")):
        raise ValueError(f"{label} must be a non-empty project-relative reference")
    if "\\" in value or any(part in {"", ".", ".."} for part in value.split("/")):
        raise ValueError(f"{label} must not escape the project")


def exact_keys(value: dict[str, Any], allowed: set[str], label: str) -> None:
    unknown = set(value) - allowed
    if unknown:
        raise ValueError(f"{label} contains unsupported fields: {', '.join(sorted(unknown))}")


def index_atlas(atlas: dict[str, Any]) -> tuple[dict[str, dict[str, Any]], dict[str, dict[str, Any]]]:
    if atlas.get("format_version") != "2.0":
        raise ValueError("atlas format_version must be '2.0'")
    raw_surfaces = atlas.get("surfaces")
    raw_functions = atlas.get("functions")
    if not isinstance(raw_surfaces, list) or not isinstance(raw_functions, list):
        raise ValueError("atlas requires surfaces and functions lists")
    surfaces = {item.get("surface_id"): item for item in raw_surfaces if isinstance(item, dict)}
    functions = {item.get("function_id"): item for item in raw_functions if isinstance(item, dict)}
    if None in surfaces or None in functions or len(surfaces) != len(raw_surfaces) or len(functions) != len(raw_functions):
        raise ValueError("atlas IDs must be present and unique")
    return surfaces, functions


def validate_stored_assessment(value: Any, label: str) -> None:
    if not isinstance(value, dict) or value.get("quality") not in QUALITY_SET or not isinstance(value.get("focus"), bool):
        raise ValueError(f"{label} must contain a valid quality and boolean focus")
    quality = value["quality"]
    approval = value.get("approval")
    if quality in PROTECTED_QUALITIES:
        validate_approval(approval, {"approval": None})
    elif approval is not None:
        raise ValueError(f"{label} must not retain an approval outside gold or diamond")


def validate_atlas(atlas: dict[str, Any], surfaces: dict[str, dict[str, Any]], functions: dict[str, dict[str, Any]]) -> None:
    for surface_id, surface in surfaces.items():
        if not all(isinstance(surface.get(key), str) and surface[key] for key in ("surface_id", "target_id", "label")):
            raise ValueError("surface requires stable IDs and a label")
        if not isinstance(surface.get("route_patterns"), list) or not all(isinstance(route, str) and route for route in surface["route_patterns"]):
            raise ValueError(f"surface {surface_id} has invalid route patterns")
        if not isinstance((surface.get("selectors") or {}).get("stable"), str) or not surface["selectors"]["stable"]:
            raise ValueError(f"surface {surface_id} requires a stable selector")
        assessments = surface.get("assessments")
        if not isinstance(assessments, dict):
            raise ValueError(f"surface {surface_id} requires assessments")
        for dimension in ("copy", "design"):
            validate_stored_assessment(assessments.get(dimension), f"surface {surface_id} {dimension} assessment")
        if not isinstance(surface.get("function_ids", []), list) or any(function_id not in functions for function_id in surface.get("function_ids", [])):
            raise ValueError(f"surface {surface_id} references an unknown function")
        if any(surface_id not in functions[function_id].get("surface_ids", []) for function_id in surface.get("function_ids", [])):
            raise ValueError(f"surface {surface_id} has a non-reciprocal function link")
    for function_id, function in functions.items():
        if not isinstance(function.get("surface_ids"), list) or any(surface_id not in surfaces for surface_id in function["surface_ids"]):
            raise ValueError(f"function {function_id} references an unknown surface")
        if function.get("operator_observable") and not function["surface_ids"]:
            raise ValueError(f"observable function {function_id} requires a surface")
        if any(function_id not in surfaces[surface_id].get("function_ids", []) for surface_id in function["surface_ids"]):
            raise ValueError(f"function {function_id} has a non-reciprocal surface link")
        validate_stored_assessment(function.get("assessment"), f"function {function_id} assessment")


def validate_patch_header(patch: dict[str, Any], atlas: dict[str, Any], atlas_path: Path) -> list[dict[str, Any]]:
    exact_keys(patch, PATCH_KEYS, "patch")
    if patch.get("format_version") != "2.0" or patch.get("kind") != "atlas_annotation_patch":
        raise ValueError("unsupported patch format")
    if patch.get("project") != atlas.get("project"):
        raise ValueError("patch project does not match atlas")
    if patch.get("base_atlas_digest") != digest(atlas_path):
        raise ValueError("atlas digest is stale; no changes written")
    parse_timestamp(patch.get("exported_at"), "patch.exported_at")
    if "evidence_manifest" in patch and not isinstance(patch["evidence_manifest"], list):
        raise ValueError("patch.evidence_manifest must be a list")
    annotations = patch.get("annotations")
    if not isinstance(annotations, list) or not annotations:
        raise ValueError("patch annotations must be a non-empty list")
    return annotations


def validate_context(annotation: dict[str, Any], surface: dict[str, Any], functions: dict[str, dict[str, Any]]) -> tuple[dict[str, Any], dict[str, Any], str, str, str | None]:
    exact_keys(annotation, ANNOTATION_KEYS, "annotation")
    if annotation.get("format_version") != "2.0":
        raise ValueError("annotation format_version must be '2.0'")
    parse_timestamp(annotation.get("captured_at"), "annotation.captured_at")
    target = annotation.get("target")
    selectors = annotation.get("selectors")
    change = annotation.get("annotation")
    reference = annotation.get("reference")
    evidence = annotation.get("evidence")
    if not all(isinstance(value, dict) for value in (target, selectors, change, reference, evidence)):
        raise ValueError("annotation requires target, selectors, annotation, reference and evidence objects")
    exact_keys(target, {"surface_id", "target_id", "route", "function_ids", "label", "state", "parent_target_id"}, "annotation.target")
    exact_keys(selectors, {"stable", "css_fallback", "xpath_fallback"}, "annotation.selectors")
    exact_keys(change, {"dimension", "quality", "focus", "function_id", "approval"}, "annotation.annotation")
    exact_keys(reference, {"commit", "viewport", "context_fingerprint", "config_fingerprint", "unavailable_reason"}, "annotation.reference")
    exact_keys(evidence, {"local_ref", "screenshot_ref", "dom_hash", "unavailable_reason"}, "annotation.evidence")
    if target.get("surface_id") != surface.get("surface_id") or target.get("target_id") != surface.get("target_id"):
        raise ValueError("annotation references an unknown surface or target")
    route = target.get("route")
    if not isinstance(route, str) or not route or route not in surface.get("route_patterns", []) and "/*" not in surface.get("route_patterns", []):
        raise ValueError("annotation route is not registered for the surface")
    if selectors.get("stable") != (surface.get("selectors") or {}).get("stable"):
        raise ValueError("annotation stable selector does not match the atlas")
    dimension = change.get("dimension")
    quality = change.get("quality")
    if dimension not in DIMENSIONS or quality not in QUALITY_SET or not isinstance(change.get("focus"), bool):
        raise ValueError("annotation has an invalid dimension, quality or focus value")
    function_id = change.get("function_id")
    if dimension == "function":
        if not isinstance(function_id, str) or function_id not in functions or not functions[function_id].get("operator_observable"):
            raise ValueError("annotation references an unknown or internal function")
        if surface["surface_id"] not in functions[function_id].get("surface_ids", []):
            raise ValueError("function is not linked to the annotated surface")
        declared = target.get("function_ids")
        if declared is not None and (not isinstance(declared, list) or function_id not in declared):
            raise ValueError("annotation function is missing from target.function_ids")
    elif function_id is not None:
        raise ValueError("only function annotations may contain function_id")
    commit = reference.get("commit")
    viewport = reference.get("viewport")
    if commit is not None and (not isinstance(commit, str) or not SHA_PATTERN.fullmatch(commit)):
        raise ValueError("annotation.reference.commit must be null or a full Git SHA")
    if viewport is not None and (not isinstance(viewport, dict) or not all(isinstance(viewport.get(key), (int, float)) and not isinstance(viewport.get(key), bool) and viewport[key] > 0 for key in ("width", "height", "dpr"))):
        raise ValueError("annotation.reference.viewport must contain positive width, height and dpr")
    if (commit is None or viewport is None) and (not isinstance(reference.get("unavailable_reason"), str) or not reference["unavailable_reason"].strip()):
        raise ValueError("annotation.reference requires unavailable_reason when required context is unavailable")
    local_ref = evidence.get("local_ref")
    if local_ref is None:
        if not isinstance(evidence.get("unavailable_reason"), str) or not evidence["unavailable_reason"].strip():
            raise ValueError("annotation.evidence requires unavailable_reason when local_ref is unavailable")
    else:
        relative_reference(local_ref, "annotation.evidence.local_ref")
    return target, change, dimension, quality, function_id


def validate_approval(value: Any, current: dict[str, Any]) -> dict[str, Any]:
    if not isinstance(value, dict):
        raise ValueError("gold and diamond require an approval baseline")
    required = {"commit", "context_fingerprint", "evidence_local_ref", "operator_decision", "approved_at", "previous_baseline_ref"}
    if set(value) != required:
        raise ValueError("approval must contain the complete baseline contract")
    if not isinstance(value["commit"], str) or not SHA_PATTERN.fullmatch(value["commit"]):
        raise ValueError("approval.commit must be a full Git SHA")
    if not isinstance(value["context_fingerprint"], str) or not FINGERPRINT_PATTERN.fullmatch(value["context_fingerprint"]):
        raise ValueError("approval.context_fingerprint must be a reproducible fingerprint")
    relative_reference(value["evidence_local_ref"], "approval.evidence_local_ref")
    if not isinstance(value["operator_decision"], str) or not value["operator_decision"].strip():
        raise ValueError("approval.operator_decision is required")
    parse_timestamp(value["approved_at"], "approval.approved_at")
    previous = value["previous_baseline_ref"]
    if previous is not None and (not isinstance(previous, str) or not previous):
        raise ValueError("approval.previous_baseline_ref must be null or a non-empty reference")
    previous_approval = current.get("approval")
    if previous_approval is not None and previous is None:
        raise ValueError("a renewed protected baseline must reference the previous baseline")
    return copy.deepcopy(value)


def current_assessment(surface: dict[str, Any], functions: dict[str, dict[str, Any]], dimension: str, function_id: str | None) -> dict[str, Any]:
    if dimension == "function":
        assert function_id is not None
        value = functions[function_id].get("assessment", {})
    else:
        value = surface.get("assessments", {}).get(dimension, {})
    return value if isinstance(value, dict) else {}


def generated_context_fingerprint(atlas: dict[str, Any], annotation: dict[str, Any], commit: str) -> str:
    target = annotation["target"]
    change = annotation["annotation"]
    reference = annotation["reference"]
    payload = {
        "project": atlas["project"], "commit": commit,
        "surface_id": target["surface_id"], "target_id": target["target_id"],
        "route": target["route"], "dimension": change["dimension"],
        "function_id": change.get("function_id"), "selector": annotation["selectors"]["stable"],
        "viewport": reference.get("viewport"),
    }
    return hashlib.sha256(json.dumps(payload, sort_keys=True, separators=(",", ":")).encode("utf-8")).hexdigest()


def add_generated_protected_baselines(atlas: dict[str, Any], patch: dict[str, Any], commit: str, patch_digest: str) -> dict[str, Any]:
    """Fill only missing protected baselines after an explicit local opt-in."""
    prepared = copy.deepcopy(patch)
    candidate = copy.deepcopy(atlas)
    surfaces, functions = index_atlas(candidate)
    validate_atlas(candidate, surfaces, functions)
    evidence_ref = f"shipglows_data/workflow/atlas/approved-surfaces.json#import:{patch_digest}"
    approved_at = datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")
    for item in prepared["annotations"]:
        if not isinstance(item, dict):
            raise ValueError("annotation must be an object")
        target = item.get("target")
        if not isinstance(target, dict) or target.get("surface_id") not in surfaces:
            raise ValueError("annotation references an unknown surface or target")
        surface = surfaces[target["surface_id"]]
        _, change, dimension, quality, function_id = validate_context(item, surface, functions)
        if quality in PROTECTED_QUALITIES and change.get("approval") is None:
            previous = current_assessment(surface, functions, dimension, function_id).get("approval")
            change["approval"] = {
                "commit": commit,
                "context_fingerprint": generated_context_fingerprint(atlas, item, commit),
                "evidence_local_ref": evidence_ref,
                "operator_decision": "Approved from an explicit Atlas Gold/Diamond confirmation.",
                "approved_at": approved_at,
                "previous_baseline_ref": f"commit:{previous['commit']}" if isinstance(previous, dict) and isinstance(previous.get("commit"), str) else None,
            }
            item["reference"]["commit"] = commit
            item["reference"].pop("unavailable_reason", None)
            item["evidence"]["local_ref"] = evidence_ref
            item["evidence"].pop("unavailable_reason", None)
        apply_annotation(candidate, item, surfaces, functions)
    return prepared


def apply_annotation(atlas: dict[str, Any], annotation: dict[str, Any], surfaces: dict[str, dict[str, Any]], functions: dict[str, dict[str, Any]]) -> None:
    target = annotation.get("target")
    if not isinstance(target, dict) or target.get("surface_id") not in surfaces:
        raise ValueError("annotation references an unknown surface or target")
    surface = surfaces[target["surface_id"]]
    _, change, dimension, quality, function_id = validate_context(annotation, surface, functions)
    current = functions[function_id].get("assessment", {}) if dimension == "function" else surface.get("assessments", {}).get(dimension, {})
    current_quality = current.get("quality", "unknown") if isinstance(current, dict) else "unknown"
    expected = QUALITIES[(QUALITIES.index(current_quality) + 1) % len(QUALITIES)] if current_quality in QUALITY_SET else "red"
    if quality != expected:
        raise ValueError(f"annotation quality must follow the fixed cycle: expected {expected}, got {quality}")
    if quality not in PROTECTED_QUALITIES and change.get("approval") is not None:
        raise ValueError("only gold and diamond annotations may contain an approval baseline")
    approval = validate_approval(change.get("approval"), current) if quality in PROTECTED_QUALITIES else None
    assessment = {"quality": quality, "focus": change["focus"], "approval": approval}
    if dimension == "function":
        functions[function_id]["assessment"] = assessment
    else:
        surface.setdefault("assessments", {})[dimension] = assessment


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--atlas", type=Path, required=True)
    parser.add_argument("--patch", type=Path, required=True)
    parser.add_argument("--approve-protected", action="store_true", help="Create missing Gold/Diamond baselines from the current clean Git commit.")
    parser.add_argument("--project-root", type=Path, default=Path.cwd(), help="Git repository used only when --approve-protected is set (default: current directory).")
    args = parser.parse_args()
    try:
        atlas = read_object(args.atlas, "atlas")
        patch = read_object(args.patch, "patch")
        annotations = validate_patch_header(patch, atlas, args.atlas)
        if args.approve_protected:
            project_root = args.project_root.resolve()
            if not args.atlas.resolve().is_relative_to(project_root):
                raise ValueError("atlas must remain inside the protected baseline project root")
            patch = add_generated_protected_baselines(atlas, patch, clean_git_commit(project_root), hashlib.sha256(args.patch.read_bytes()).hexdigest())
            annotations = patch["annotations"]
        candidate = copy.deepcopy(atlas)
        surfaces, functions = index_atlas(candidate)
        validate_atlas(candidate, surfaces, functions)
        for annotation in annotations:
            if not isinstance(annotation, dict):
                raise ValueError("annotation must be an object")
            apply_annotation(candidate, annotation, surfaces, functions)
    except (OSError, ValueError, json.JSONDecodeError) as error:
        raise SystemExit(f"refused: {error}") from error
    candidate["updated_at"] = datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")
    candidate.setdefault("import_history", []).append({"imported_at": candidate["updated_at"], "patch_digest": hashlib.sha256(args.patch.read_bytes()).hexdigest(), "count": len(annotations)})
    atomic_write(args.atlas, candidate)
    print(json.dumps({"status": "imported", "count": len(annotations), "atlas": str(args.atlas)}))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
