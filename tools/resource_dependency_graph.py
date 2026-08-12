#!/usr/bin/env python3
"""Validate explicit ShipGlows resource dependencies without parsing prose."""

from __future__ import annotations

import argparse
from dataclasses import dataclass
import json
from pathlib import Path
import re
from typing import Iterable


ROOT = Path(__file__).resolve().parents[1]
DEPENDENCY_START = re.compile(r'^\s*-\s+artifact:\s*["\']?(.*?)["\']?\s*$')
DEPENDENCY_FIELD = re.compile(
    r'^\s+(artifact_version|required_status):\s*["\']?(.*?)["\']?\s*$'
)
TOP_LEVEL = re.compile(r'^([A-Za-z_][A-Za-z0-9_-]*):\s*["\']?(.*?)["\']?\s*$')
SEMVER = re.compile(r'^(\d+)\.(\d+)\.(\d+)$')


@dataclass(frozen=True)
class Dependency:
    artifact: str
    artifact_version: str = ""
    required_status: str = ""


@dataclass(frozen=True)
class Artifact:
    path: Path
    relative_path: str
    artifact_version: str
    status: str
    dependencies: tuple[Dependency, ...]


def _frontmatter(text: str) -> str:
    if not text.startswith("---\n"):
        return ""
    end = text.find("\n---\n", 4)
    return "" if end < 0 else text[4:end]


def parse_artifact(path: Path, root: Path = ROOT) -> Artifact:
    block = _frontmatter(path.read_text(encoding="utf-8"))
    fields: dict[str, str] = {}
    dependencies: list[Dependency] = []
    in_dependencies = False
    current: dict[str, str] | None = None
    for line in block.splitlines():
        top = TOP_LEVEL.match(line)
        if top:
            if current:
                dependencies.append(Dependency(**current))
                current = None
            key, value = top.groups()
            fields[key] = value
            in_dependencies = key == "depends_on"
            continue
        if not in_dependencies:
            continue
        start = DEPENDENCY_START.match(line)
        if start:
            if current:
                dependencies.append(Dependency(**current))
            current = {"artifact": start.group(1)}
            continue
        field = DEPENDENCY_FIELD.match(line)
        if field and current is not None:
            current[field.group(1)] = field.group(2)
    if current:
        dependencies.append(Dependency(**current))
    return Artifact(
        path=path,
        relative_path=path.resolve().relative_to(root.resolve()).as_posix(),
        artifact_version=fields.get("artifact_version", ""),
        status=fields.get("status", ""),
        dependencies=tuple(dependencies),
    )


def _version(value: str) -> tuple[int, int, int] | None:
    match = SEMVER.fullmatch(value)
    return tuple(map(int, match.groups())) if match else None


def _iter_artifacts(root: Path) -> Iterable[Path]:
    for base in (root / "skills", root / "shipglows_data"):
        if base.is_dir():
            yield from (
                path for path in sorted(base.rglob("*.md"))
                if ".git" not in path.parts and "archives" not in path.parts
            )


def profile_roots(registry: dict[str, object]) -> tuple[str, ...]:
    paths: set[str] = set()
    for profile in registry.get("activation_profiles", {}).get("skills", {}).values():
        paths.update(profile.get("baseline", []))
        for references in profile.get("gates", {}).values():
            paths.update(references)
    return tuple(sorted(paths))


def activation_profile_roots(root: Path = ROOT) -> tuple[str, ...]:
    registry_path = root / "skills" / "references" / "skill-invocation-registry.json"
    return profile_roots(json.loads(registry_path.read_text(encoding="utf-8")))


def audit_dependency_graph(
    root: Path = ROOT,
    roots: Iterable[str] | None = None,
) -> dict[str, object]:
    root = root.resolve()
    profiled = roots is not None
    errors: list[str] = []
    artifacts: dict[str, Artifact] = {}
    selected: set[str]
    if not profiled:
        artifacts = {
            item.relative_path: item
            for path in _iter_artifacts(root)
            if (item := parse_artifact(path, root)).artifact_version
        }
        selected = set(artifacts)
    else:
        selected = set()
        root_paths = tuple(dict.fromkeys(path.replace("\\", "/") for path in roots or ()))
        root_set = set(root_paths)
        pending = list(root_paths)
        while pending:
            source_path = pending.pop()
            if source_path in selected:
                continue
            selected.add(source_path)
            physical = root / source_path
            if not physical.is_file():
                if source_path in root_set:
                    errors.append(f"missing_root:{source_path}")
                continue
            source = parse_artifact(physical, root)
            if not source.artifact_version:
                if source_path in root_set:
                    errors.append(f"unversioned_root:{source_path}")
                continue
            artifacts[source_path] = source
            if source_path.startswith("shipglows_data/"):
                continue
            pending.extend(
                target
                for dependency in source.dependencies
                if (
                    target := dependency.artifact.replace("\\", "/").lstrip("./")
                ).startswith(("skills/", "shipglows_data/"))
            )

    edges: dict[str, list[str]] = {path: [] for path in artifacts}
    checked = 0
    for source_path in sorted(selected):
        source = artifacts.get(source_path)
        if source is None:
            continue
        if _version(source.artifact_version) is None:
            errors.append(
                f"invalid_actual_version:{source_path}:{source.artifact_version or 'missing'}"
            )
        if source.status not in {"active", "ready", "reviewed", "draft"}:
            errors.append(
                f"invalid_actual_status:{source_path}:{source.status or 'missing'}"
            )
        if profiled and source_path.startswith("shipglows_data/"):
            continue
        for dependency in source.dependencies:
            checked += 1
            target_path = dependency.artifact.replace("\\", "/").lstrip("./")
            target = artifacts.get(target_path)
            if target is None:
                physical = root / target_path
                if not physical.is_file():
                    errors.append(f"missing:{source_path}:{target_path}")
                else:
                    errors.append(f"unversioned:{source_path}:{target_path}")
                continue
            edges[source_path].append(target_path)
            if not dependency.artifact_version:
                errors.append(f"missing_required_version:{source_path}:{target_path}")
            if not dependency.required_status:
                errors.append(f"missing_required_status:{source_path}:{target_path}")
            if dependency.required_status and target.status != dependency.required_status:
                errors.append(
                    f"status:{source_path}:{target_path}:required={dependency.required_status}:actual={target.status}"
                )
            required = _version(dependency.artifact_version)
            actual = _version(target.artifact_version)
            if actual is None:
                errors.append(f"invalid_actual_version:{target_path}:{target.artifact_version or 'missing'}")
            if dependency.artifact_version and required is None:
                errors.append(f"invalid_required_version:{source_path}:{target_path}:{dependency.artifact_version}")
            elif required and (actual is None or actual < required):
                errors.append(
                    f"version:{source_path}:{target_path}:required={dependency.artifact_version}:actual={target.artifact_version or 'missing'}"
                )

    visiting: list[str] = []
    visited: set[str] = set()
    cycles: set[str] = set()

    def visit(node: str) -> None:
        if node in visiting:
            start = visiting.index(node)
            cycle = visiting[start:] + [node]
            cycles.add(" -> ".join(cycle))
            return
        if node in visited:
            return
        visiting.append(node)
        for target in edges.get(node, []):
            visit(target)
        visiting.pop()
        visited.add(node)

    for node in sorted(selected):
        visit(node)
    errors.extend(f"cycle:{cycle}" for cycle in sorted(cycles))
    return {
        "status": "valid" if not errors else "invalid",
        "errors": sorted(set(errors)),
        "artifacts": sum(path in artifacts for path in selected),
        "dependencies": checked,
        "cycles": len(cycles),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=ROOT)
    parser.add_argument(
        "--all",
        action="store_true",
        help="Audit every current artifact instead of the executable activation-profile closure.",
    )
    parser.add_argument("--format", choices=("json", "text"), default="text")
    args = parser.parse_args()
    roots = None if args.all else activation_profile_roots(args.root)
    payload = audit_dependency_graph(args.root, roots)
    if args.format == "json":
        print(json.dumps(payload, ensure_ascii=False, sort_keys=True))
    else:
        print(
            f"Resource dependency graph: {payload['status']} · "
            f"artifacts={payload['artifacts']} dependencies={payload['dependencies']} cycles={payload['cycles']}"
        )
        for error in payload["errors"]:
            print(f"- {error}")
    return 0 if payload["status"] == "valid" else 2


if __name__ == "__main__":
    raise SystemExit(main())
