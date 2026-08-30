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
import re
from collections import defaultdict, deque
from pathlib import Path
from typing import Any, Iterable


SUPPORTED_SUFFIXES = {".py", ".dart", ".sql", ".md"}
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
    return sorted(
        path
        for path in root.rglob("*")
        if path.is_file()
        and path.suffix.lower() in SUPPORTED_SUFFIXES
        and not any(part in IGNORED_PARTS for part in path.relative_to(root).parts)
    )


def _hash_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


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


def build_graph(project_root: str | Path) -> dict[str, Any]:
    root = Path(project_root).resolve()
    nodes: dict[str, dict[str, Any]] = {}
    edges: set[tuple[str, str, str]] = set()
    files: dict[str, str] = {}
    for path in _relative_files(root):
        relative = path.relative_to(root).as_posix()
        data = path.read_bytes()
        files[relative] = _hash_bytes(data)
        text = data.decode("utf-8", errors="replace")
        file_id = f"file:{relative}"
        nodes[file_id] = _node(file_id, "file", path.name, relative, language=path.suffix.lstrip("."))
        parsed_nodes: list[dict[str, Any]] = []
        parsed_edges: list[dict[str, str]] = []
        if path.suffix == ".py":
            parsed_nodes, parsed_edges = _python_nodes_and_edges(root, path, text)
        elif path.suffix == ".dart":
            parsed_nodes, parsed_edges = _dart_nodes_and_edges(root, path, text)
        table_nodes, table_edges = _table_nodes_and_edges(relative, text)
        for item in [*parsed_nodes, *table_nodes]:
            nodes[item["id"]] = item
        for item in [*parsed_edges, *table_edges]:
            edges.add((item["source"], item["target"], item["kind"]))
    return {
        "schema_version": "1.0",
        "project_root_name": root.name,
        "files": dict(sorted(files.items())),
        "nodes": [nodes[key] for key in sorted(nodes)],
        "edges": [_edge(*item) for item in sorted(edges)],
    }


def find_stale_files(graph: dict[str, Any], project_root: str | Path) -> list[str]:
    root = Path(project_root).resolve()
    stale: list[str] = []
    for relative, expected_hash in graph.get("files", {}).items():
        path = root / relative
        if not path.is_file() or _hash_bytes(path.read_bytes()) != expected_hash:
            stale.append(relative)
    return sorted(stale)


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
    while queue and len(visited) < max_nodes:
        node_id, depth = queue.popleft()
        if node_id in visited or node_id not in nodes_by_id:
            continue
        visited.add(node_id)
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
        "truncated": bool(queue),
    }


def _read_graph(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project-root", type=Path, required=True)
    subparsers = parser.add_subparsers(dest="command", required=True)
    build_parser = subparsers.add_parser("build")
    build_parser.add_argument("--output", type=Path)
    query_parser = subparsers.add_parser("query")
    query_parser.add_argument("--graph", type=Path, required=True)
    query_parser.add_argument("--seed", action="append", required=True)
    query_parser.add_argument("--max-depth", type=int, default=2)
    query_parser.add_argument("--max-nodes", type=int, default=100)
    stale_parser = subparsers.add_parser("stale")
    stale_parser.add_argument("--graph", type=Path, required=True)
    args = parser.parse_args()

    if args.command == "build":
        result = build_graph(args.project_root)
        rendered = json.dumps(result, indent=2, ensure_ascii=False) + "\n"
        if args.output:
            args.output.write_text(rendered, encoding="utf-8")
        else:
            print(rendered, end="")
        return 0
    graph = _read_graph(args.graph)
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
    raise SystemExit(main())
