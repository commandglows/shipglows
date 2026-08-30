#!/usr/bin/env python3
"""Build and query a bounded, derived code-context graph.

Git and governed project artifacts remain authoritative. This graph contains
only reproducible pointers and hashes and is safe to discard and rebuild.
"""

from __future__ import annotations

import argparse
import ast
import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile
from contextlib import contextmanager
from collections import defaultdict, deque
from pathlib import Path
from typing import Any, Iterable


SUPPORTED_SUFFIXES = {".py", ".dart", ".sql", ".md"}
SOURCE_SUFFIXES = SUPPORTED_SUFFIXES | {".astro", ".c", ".cpp", ".cs", ".go", ".html", ".java", ".js", ".jsx", ".json", ".kt", ".php", ".rb", ".rs", ".sh", ".swift", ".toml", ".ts", ".tsx", ".vue", ".yaml", ".yml"}
SCHEMA_VERSION = "2.0"
IGNORED_PARTS = {
    ".dart_tool",
    ".git",
    ".idea",
    ".shipglows",
    ".venv",
    "build",
    "dist",
    "node_modules",
    "venv",
}
SQL_TABLE_RE = re.compile(
    r"\b(?:FROM|JOIN|INTO|UPDATE|TABLE(?:\s+IF\s+NOT\s+EXISTS)?)\s+[`\"]?([A-Za-z_][\w]*)",
    re.IGNORECASE,
)
DART_IMPORT_RE = re.compile(r"^\s*import\s+['\"]([^'\"]+)['\"]", re.MULTILINE)
DART_CLASS_RE = re.compile(r"^\s*(?:abstract\s+|sealed\s+|final\s+)?class\s+(\w+)", re.MULTILINE)
DART_FUNCTION_RE = re.compile(
    r"^\s*(?:Future<[^>]+>|Future|void|String|int|bool|double|dynamic|[A-Z]\w*(?:<[^>]+>)?)\s+(\w+)\s*\(",
    re.MULTILINE,
)
API_PATH_RE = re.compile(r"['\"](/api/[^'\"]+)['\"]")


def _relative_files(root: Path) -> list[Path]:
    resolved_root = root.resolve()
    result: list[Path] = []
    for path in root.rglob("*"):
        if path.is_symlink() or not path.is_file() or path.suffix.lower() not in SUPPORTED_SUFFIXES:
            continue
        relative = path.relative_to(root)
        if any(part in IGNORED_PARTS for part in relative.parts):
            continue
        try:
            path.resolve().relative_to(resolved_root)
        except ValueError:
            continue
        result.append(path)
    return sorted(result)


def _hash_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def _language_coverage(root: Path) -> dict[str, Any]:
    supported: dict[str, int] = defaultdict(int)
    unsupported: dict[str, int] = defaultdict(int)
    for path in root.rglob("*"):
        if path.is_symlink() or not path.is_file():
            continue
        try:
            relative = path.relative_to(root)
        except ValueError:
            continue
        if any(part in IGNORED_PARTS for part in relative.parts):
            continue
        suffix = path.suffix.lower()
        if suffix in SUPPORTED_SUFFIXES:
            supported[suffix.lstrip(".")] += 1
        elif suffix in SOURCE_SUFFIXES:
            unsupported[suffix.lstrip(".")] += 1
    return {"supported": dict(sorted(supported.items())), "unsupported": dict(sorted(unsupported.items()))}


def _fallback_files(root: Path) -> list[str]:
    return sorted(
        path.relative_to(root).as_posix()
        for path in root.rglob("*")
        if not path.is_symlink()
        and path.is_file()
        and path.suffix.lower() in SOURCE_SUFFIXES - SUPPORTED_SUFFIXES
        and not any(part in IGNORED_PARTS for part in path.relative_to(root).parts)
    )


def _node(node_id: str, kind: str, name: str, path: str | None = None, **extra: Any) -> dict[str, Any]:
    value: dict[str, Any] = {"id": node_id, "kind": kind, "name": name}
    if path is not None:
        value["path"] = path
    value.update({key: item for key, item in extra.items() if item is not None})
    return value


def _edge(source: str, target: str, kind: str) -> dict[str, str]:
    return {"source": source, "target": target, "kind": kind}


def _python_import_target(root: Path, module: str) -> str | None:
    candidate = root.joinpath(*module.split(".")).with_suffix(".py")
    package = root.joinpath(*module.split("."), "__init__.py")
    for path in (candidate, package):
        if path.is_file():
            return path.relative_to(root).as_posix()
    return None


def _python_nodes_and_edges(root: Path, path: Path, text: str) -> tuple[list[dict[str, Any]], list[dict[str, str]]]:
    relative = path.relative_to(root).as_posix()
    file_id = f"file:{relative}"
    nodes: list[dict[str, Any]] = []
    edges: list[dict[str, str]] = []
    try:
        tree = ast.parse(text, filename=relative)
    except SyntaxError:
        return nodes, edges

    for item in ast.walk(tree):
        if isinstance(item, (ast.ClassDef, ast.FunctionDef, ast.AsyncFunctionDef)):
            kind = "class" if isinstance(item, ast.ClassDef) else "function"
            symbol_id = f"py:{relative}:{item.name}"
            nodes.append(_node(symbol_id, kind, item.name, relative, line=item.lineno, language="python"))
            edges.append(_edge(file_id, symbol_id, "declares"))
        elif isinstance(item, ast.Import):
            for alias in item.names:
                target = _python_import_target(root, alias.name)
                if target:
                    edges.append(_edge(file_id, f"file:{target}", "imports"))
        elif isinstance(item, ast.ImportFrom) and item.module:
            target = _python_import_target(root, item.module)
            if target:
                edges.append(_edge(file_id, f"file:{target}", "imports"))

    for item in tree.body:
        if not isinstance(item, (ast.FunctionDef, ast.AsyncFunctionDef)):
            continue
        for decorator in item.decorator_list:
            if not isinstance(decorator, ast.Call) or not decorator.args:
                continue
            attribute = decorator.func if isinstance(decorator.func, ast.Attribute) else None
            if attribute is None or attribute.attr.lower() not in {"get", "post", "put", "patch", "delete"}:
                continue
            path_value = decorator.args[0]
            if isinstance(path_value, ast.Constant) and isinstance(path_value.value, str):
                method = attribute.attr.upper()
                route_id = f"route:{method}:{path_value.value}"
                nodes.append(_node(route_id, "route", path_value.value, relative, method=method, line=item.lineno))
                edges.append(_edge(f"py:{relative}:{item.name}", route_id, "handles"))
                edges.append(_edge(file_id, route_id, "exposes"))
    return nodes, edges


def _dart_nodes_and_edges(root: Path, path: Path, text: str) -> tuple[list[dict[str, Any]], list[dict[str, str]]]:
    relative = path.relative_to(root).as_posix()
    file_id = f"file:{relative}"
    nodes: list[dict[str, Any]] = []
    edges: list[dict[str, str]] = []
    for match in DART_IMPORT_RE.finditer(text):
        imported = match.group(1)
        if imported.startswith("package:") or "://" in imported:
            continue
        target = (path.parent / imported).resolve()
        try:
            target_relative = target.relative_to(root.resolve()).as_posix()
        except ValueError:
            continue
        if target.is_file():
            edges.append(_edge(file_id, f"file:{target_relative}", "imports"))
    for kind, pattern in (("class", DART_CLASS_RE), ("function", DART_FUNCTION_RE)):
        for match in pattern.finditer(text):
            name = match.group(1)
            symbol_id = f"dart:{relative}:{name}"
            line = text.count("\n", 0, match.start()) + 1
            nodes.append(_node(symbol_id, kind, name, relative, line=line, language="dart"))
            edges.append(_edge(file_id, symbol_id, "declares"))
    for match in API_PATH_RE.finditer(text):
        api_path = re.sub(r"\$\w+|\$\{[^}]+\}", "{param}", match.group(1))
        api_id = f"api-path:{api_path}"
        nodes.append(_node(api_id, "api_path", api_path, relative))
        edges.append(_edge(file_id, api_id, "calls"))
    return nodes, edges


def _table_nodes_and_edges(relative: str, text: str) -> tuple[list[dict[str, Any]], list[dict[str, str]]]:
    nodes: list[dict[str, Any]] = []
    edges: list[dict[str, str]] = []
    for table in sorted(set(SQL_TABLE_RE.findall(text))):
        table_id = f"table:{table}"
        nodes.append(_node(table_id, "table", table))
        edges.append(_edge(f"file:{relative}", table_id, "accesses"))
    return nodes, edges


def _file_observation(root: Path, path: Path) -> dict[str, Any]:
    relative = path.relative_to(root).as_posix()
    data = path.read_bytes()
    text = data.decode("utf-8", errors="replace")
    file_id = f"file:{relative}"
    nodes = [_node(file_id, "file", path.name, relative, language=path.suffix.lstrip("."))]
    edges: list[dict[str, str]] = []
    parsed_nodes: list[dict[str, Any]] = []
    parsed_edges: list[dict[str, str]] = []
    if path.suffix.lower() == ".py":
        parsed_nodes, parsed_edges = _python_nodes_and_edges(root, path, text)
    elif path.suffix.lower() == ".dart":
        parsed_nodes, parsed_edges = _dart_nodes_and_edges(root, path, text)
    table_nodes, table_edges = _table_nodes_and_edges(relative, text)
    nodes.extend(parsed_nodes)
    nodes.extend(table_nodes)
    edges.extend(parsed_edges)
    edges.extend(table_edges)
    return {
        "hash": _hash_bytes(data),
        "nodes": sorted(nodes, key=lambda item: item["id"]),
        "edges": sorted(edges, key=lambda item: (item["source"], item["target"], item["kind"])),
    }


def _git_value(root: Path, *args: str) -> str | None:
    try:
        value = subprocess.run(
            ["git", "-C", str(root), *args], capture_output=True, check=True, text=True, encoding="utf-8"
        ).stdout.strip()
    except (OSError, subprocess.CalledProcessError):
        return None
    return value or None


def _repository_identity(root: Path) -> dict[str, Any]:
    branch = _git_value(root, "symbolic-ref", "--quiet", "--short", "HEAD")
    return {
        "branch": branch,
        "head": _git_value(root, "rev-parse", "HEAD"),
        "detached": branch is None and _git_value(root, "rev-parse", "--is-inside-work-tree") == "true",
        "worktree_id": _hash_bytes(os.path.normcase(str(root)).encode("utf-8"))[:16],
    }


def _assemble_graph(root: Path, observations: dict[str, dict[str, Any]]) -> dict[str, Any]:
    nodes: dict[str, dict[str, Any]] = {}
    edges: set[tuple[str, str, str]] = set()
    for observation in observations.values():
        for item in observation["nodes"]:
            nodes[item["id"]] = item
        for item in observation["edges"]:
            edges.add((item["source"], item["target"], item["kind"]))
    return {
        "schema_version": SCHEMA_VERSION,
        "project_root_name": root.name,
        "repository": _repository_identity(root),
        "language_coverage": _language_coverage(root),
        "fallback_files": _fallback_files(root),
        "files": {path: value["hash"] for path, value in sorted(observations.items())},
        "file_observations": dict(sorted(observations.items())),
        "nodes": [nodes[key] for key in sorted(nodes)],
        "edges": [_edge(*item) for item in sorted(edges)],
    }


def build_graph(project_root: str | Path) -> dict[str, Any]:
    root = Path(project_root).resolve()
    observations = {
        path.relative_to(root).as_posix(): _file_observation(root, path) for path in _relative_files(root)
    }
    return _assemble_graph(root, observations)


def update_graph(graph: dict[str, Any], project_root: str | Path) -> tuple[dict[str, Any], dict[str, Any]]:
    root = Path(project_root).resolve()
    if graph.get("schema_version") != SCHEMA_VERSION or "file_observations" not in graph:
        rebuilt = build_graph(root)
        return rebuilt, {"added": sorted(rebuilt["files"]), "changed": [], "renamed": [], "deleted": [], "rebuilt": True}
    previous = dict(graph["file_observations"])
    current_paths = {path.relative_to(root).as_posix(): path for path in _relative_files(root)}
    current_hashes = {relative: _hash_bytes(path.read_bytes()) for relative, path in current_paths.items()}
    old_paths = set(previous)
    new_paths = set(current_paths)
    added = sorted(new_paths - old_paths)
    deleted = sorted(old_paths - new_paths)
    changed = sorted(path for path in old_paths & new_paths if previous[path]["hash"] != current_hashes[path])
    renamed: list[dict[str, str]] = []
    remaining_added = set(added)
    remaining_deleted = set(deleted)
    deleted_by_hash: dict[str, list[str]] = defaultdict(list)
    for path in deleted:
        deleted_by_hash[previous[path]["hash"]].append(path)
    for target in added:
        candidates = deleted_by_hash.get(current_hashes[target], [])
        source = next((item for item in candidates if item in remaining_deleted), None)
        if source is not None:
            renamed.append({"from": source, "to": target})
            remaining_deleted.remove(source)
            remaining_added.remove(target)
    removed_ids = {node["id"] for path in deleted for node in previous[path]["nodes"]}
    dependent_paths = {
        edge["source"].removeprefix("file:")
        for observation in previous.values()
        for edge in observation["edges"]
        if edge["target"] in removed_ids and edge["source"].startswith("file:")
    } & new_paths
    invalidated = set(deleted) | set(changed) | dependent_paths
    observations = {path: value for path, value in previous.items() if path not in invalidated}
    for path in sorted(remaining_added | set(changed) | dependent_paths | {item["to"] for item in renamed}):
        observations[path] = _file_observation(root, current_paths[path])
    impacted_ids = removed_ids | {
        node["id"]
        for path in set(changed) | remaining_added | {item["to"] for item in renamed}
        for node in observations[path]["nodes"]
    }
    revalidate = {
        edge["source"].removeprefix("file:")
        for observation in [*previous.values(), *observations.values()]
        for edge in observation["edges"]
        if edge["target"] in impacted_ids and edge["source"].startswith("file:")
    }
    revalidate.update(dependent_paths)
    return _assemble_graph(root, observations), {
        "added": sorted(remaining_added),
        "changed": changed,
        "renamed": sorted(renamed, key=lambda item: (item["from"], item["to"])),
        "deleted": sorted(remaining_deleted),
        "revalidate": sorted(revalidate),
        "rebuilt": False,
    }


def find_stale_files(graph: dict[str, Any], project_root: str | Path) -> list[str]:
    root = Path(project_root).resolve()
    stale: list[str] = []
    for relative, expected_hash in graph.get("files", {}).items():
        path = root / relative
        if not path.is_file() or _hash_bytes(path.read_bytes()) != expected_hash:
            stale.append(relative)
    indexed = set(graph.get("files", {}))
    stale.extend(path.relative_to(root).as_posix() for path in _relative_files(root) if path.relative_to(root).as_posix() not in indexed)
    return sorted(stale)


def graph_status(graph: dict[str, Any], project_root: str | Path) -> dict[str, Any]:
    root = Path(project_root).resolve()
    indexed = set(graph.get("files", {}))
    current = {path.relative_to(root).as_posix() for path in _relative_files(root)}
    stale = find_stale_files(graph, root)
    identity = _repository_identity(root)
    repository = graph.get("repository", {})
    return {
        "schema_version": graph.get("schema_version"),
        "compatible": graph.get("schema_version") == SCHEMA_VERSION,
        "freshness": "fresh" if not stale and repository == identity else "stale",
        "indexed_file_count": len(indexed),
        "node_count": len(graph.get("nodes", [])),
        "edge_count": len(graph.get("edges", [])),
        "stale_file_count": len(set(stale) & indexed),
        "new_file_count": len(current - indexed),
        "identity_changed": repository != identity,
    }


def query_graph(
    graph: dict[str, Any], seeds: Iterable[str], *, max_depth: int = 2, max_nodes: int = 100
) -> dict[str, Any]:
    nodes_by_id = {node["id"]: node for node in graph.get("nodes", [])}
    normalized_seeds = [seed.casefold() for seed in seeds]
    selected_ids: list[str] = []
    missing: list[str] = []
    for original, seed in zip(seeds, normalized_seeds):
        matches = sorted(
            node_id
            for node_id, node in nodes_by_id.items()
            if seed in node_id.casefold() or seed == str(node.get("name", "")).casefold()
        )
        if matches:
            selected_ids.extend(matches)
        else:
            missing.append(original)
    adjacency: dict[str, set[str]] = defaultdict(set)
    for edge in graph.get("edges", []):
        adjacency[edge["source"]].add(edge["target"])
        adjacency[edge["target"]].add(edge["source"])
    queue = deque((node_id, 0) for node_id in dict.fromkeys(selected_ids))
    visited: set[str] = set()
    depths: dict[str, int] = {}
    while queue and len(visited) < max_nodes:
        node_id, depth = queue.popleft()
        if node_id in visited or node_id not in nodes_by_id:
            continue
        visited.add(node_id)
        depths[node_id] = depth
        if depth < max_depth:
            for neighbor in sorted(adjacency[node_id]):
                queue.append((neighbor, depth + 1))
    selected_edges = [
        edge for edge in graph.get("edges", []) if edge["source"] in visited and edge["target"] in visited
    ]
    return {
        "seeds": list(seeds),
        "missing_seeds": missing,
        "nodes": [nodes_by_id[node_id] for node_id in sorted(visited)],
        "edges": selected_edges,
        "selection_reasons": [
            {
                "node_id": node_id,
                "reason": "seed_match" if depths[node_id] == 0 else "graph_neighbor",
                "depth": depths[node_id],
            }
            for node_id in sorted(visited)
        ],
        "truncated": bool(queue),
    }


def _read_graph(path: Path) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as error:
        raise ValueError("graph is unreadable") from error
    if not isinstance(value, dict):
        raise ValueError("graph root must be an object")
    return value


def _write_atomic(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    handle, temporary = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    try:
        with os.fdopen(handle, "w", encoding="utf-8", newline="\n") as stream:
            stream.write(content)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


@contextmanager
def _index_lock(path: Path):
    lock_path = path.with_name(f".{path.name}.lock")
    try:
        descriptor = os.open(lock_path, os.O_CREAT | os.O_EXCL | os.O_WRONLY)
    except FileExistsError as error:
        raise RuntimeError("graph refresh already in progress") from error
    try:
        os.write(descriptor, str(os.getpid()).encode("ascii"))
        os.close(descriptor)
        yield
    finally:
        try:
            lock_path.unlink()
        except FileNotFoundError:
            pass


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project-root", type=Path, required=True)
    subparsers = parser.add_subparsers(dest="command", required=True)
    build_parser = subparsers.add_parser("build")
    build_parser.add_argument("--output", type=Path)
    update_parser = subparsers.add_parser("update")
    update_parser.add_argument("--graph", type=Path, required=True)
    query_parser = subparsers.add_parser("query")
    query_parser.add_argument("--graph", type=Path, required=True)
    query_parser.add_argument("--seed", action="append", required=True)
    query_parser.add_argument("--max-depth", type=int, default=2)
    query_parser.add_argument("--max-nodes", type=int, default=100)
    stale_parser = subparsers.add_parser("stale")
    stale_parser.add_argument("--graph", type=Path, required=True)
    status_parser = subparsers.add_parser("status")
    status_parser.add_argument("--graph", type=Path, required=True)
    explain_parser = subparsers.add_parser("explain")
    explain_parser.add_argument("--graph", type=Path, required=True)
    explain_parser.add_argument("--seed", action="append", required=True)
    explain_parser.add_argument("--max-depth", type=int, default=2)
    explain_parser.add_argument("--max-nodes", type=int, default=100)
    args = parser.parse_args()

    if args.command == "build":
        result = build_graph(args.project_root)
        rendered = json.dumps(result, indent=2, ensure_ascii=False) + "\n"
        if args.output:
            _write_atomic(args.output, rendered)
        else:
            print(rendered, end="")
        return 0
    if args.command == "update":
        with _index_lock(args.graph):
            graph = _read_graph(args.graph)
            result, changes = update_graph(graph, args.project_root)
            _write_atomic(args.graph, json.dumps(result, indent=2, ensure_ascii=False) + "\n")
        print(json.dumps(changes, indent=2, ensure_ascii=False))
        return 0
    graph = _read_graph(args.graph)
    if args.command == "status":
        print(json.dumps(graph_status(graph, args.project_root), indent=2))
        return 0
    if args.command == "explain":
        result = query_graph(graph, args.seed, max_depth=args.max_depth, max_nodes=args.max_nodes)
        print(json.dumps({"seeds": result["seeds"], "missing_seeds": result["missing_seeds"], "selection_reasons": result["selection_reasons"], "truncated": result["truncated"]}, indent=2, ensure_ascii=False))
        return 0
    if args.command == "query":
        print(
            json.dumps(
                query_graph(graph, args.seed, max_depth=args.max_depth, max_nodes=args.max_nodes),
                indent=2,
                ensure_ascii=False,
            )
        )
        return 0
    stale = find_stale_files(graph, args.project_root)
    print(json.dumps({"stale_files": stale}, indent=2))
    return 1 if stale else 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, RuntimeError) as error:
        print(json.dumps({"status": "error", "reason": type(error).__name__, "message": str(error)}), file=sys.stderr)
        raise SystemExit(2)
