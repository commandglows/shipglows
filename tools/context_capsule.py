#!/usr/bin/env python3
"""Create a bounded, explainable task-context capsule from a derived graph."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import tempfile
from collections import defaultdict, deque
from pathlib import Path
from typing import Any, Iterable


SCHEMA_VERSION = "shipglows.context-capsule/v1"
TOKEN_RE = re.compile(r"[A-Za-z_][A-Za-z0-9_./:-]{2,}")
STOP_WORDS = {
    "and", "avec", "dans", "des", "for", "from", "les", "pour", "that", "the", "this", "une", "with",
}


def _task_fingerprint(task: str) -> str:
    return hashlib.sha256(task.encode("utf-8")).hexdigest()[:16]


def _task_terms(task: str) -> list[str]:
    return sorted({token.casefold() for token in TOKEN_RE.findall(task) if token.casefold() not in STOP_WORDS})[:24]


def _matches(node: dict[str, Any], term: str) -> bool:
    values = (str(node.get("id", "")), str(node.get("name", "")), str(node.get("path", "")))
    return any(term in value.casefold() for value in values)


def rank_context(
    graph: dict[str, Any], task: str, explicit_seeds: Iterable[str] = (), *, max_items: int = 40, max_depth: int = 2
) -> dict[str, Any]:
    nodes = {node["id"]: node for node in graph.get("nodes", [])}
    for path in graph.get("fallback_files", []):
        node_id = f"fallback-file:{path}"
        nodes[node_id] = {"id": node_id, "kind": "fallback_file", "name": Path(path).name, "path": path}
    reasons: dict[str, set[str]] = defaultdict(set)
    scores: dict[str, int] = defaultdict(int)
    missing: list[str] = []
    seed_ids: set[str] = set()
    for seed in dict.fromkeys(explicit_seeds):
        matches = {node_id for node_id, node in nodes.items() if _matches(node, seed.casefold())}
        if not matches:
            missing.append(seed)
        for node_id in matches:
            seed_ids.add(node_id)
            fallback = nodes[node_id].get("kind") == "fallback_file"
            reasons[node_id].add("targeted_filename_fallback" if fallback else "explicit_seed")
            scores[node_id] += 60 if fallback else 100
    for term in _task_terms(task):
        for node_id, node in nodes.items():
            if _matches(node, term):
                seed_ids.add(node_id)
                fallback = node.get("kind") == "fallback_file"
                reasons[node_id].add("targeted_filename_fallback" if fallback else "task_term")
                scores[node_id] += 15 if fallback else 20
    adjacency: dict[str, list[tuple[str, str]]] = defaultdict(list)
    for edge in graph.get("edges", []):
        adjacency[edge["source"]].append((edge["target"], edge["kind"]))
        adjacency[edge["target"]].append((edge["source"], edge["kind"]))
    queue = deque((node_id, 0) for node_id in sorted(seed_ids))
    best_depth = {node_id: 0 for node_id in seed_ids}
    while queue:
        node_id, depth = queue.popleft()
        if depth >= max_depth:
            continue
        for neighbor, edge_kind in sorted(adjacency[node_id]):
            next_depth = depth + 1
            if neighbor not in nodes:
                continue
            reasons[neighbor].add(f"graph_edge:{edge_kind}:depth_{next_depth}")
            scores[neighbor] += max(1, 10 - next_depth)
            if neighbor not in best_depth or next_depth < best_depth[neighbor]:
                best_depth[neighbor] = next_depth
                queue.append((neighbor, next_depth))
    ranked = sorted(reasons, key=lambda node_id: (-scores[node_id], node_id))
    selected = ranked[:max_items]
    return {
        "items": [
            {"node": nodes[node_id], "score": scores[node_id], "reasons": sorted(reasons[node_id])}
            for node_id in selected
        ],
        "missing_seeds": missing,
        "candidate_count": len(ranked),
        "truncated": len(ranked) > len(selected),
    }


def build_capsule(
    graph: dict[str, Any], *, task: str, accepted_outcome: str, explicit_seeds: Iterable[str] = (), max_items: int = 40
) -> dict[str, Any]:
    ranked = rank_context(graph, task, explicit_seeds, max_items=max_items)
    repository = graph.get("repository", {})
    evidence = []
    for item in ranked["items"]:
        node = item["node"]
        evidence.append(
            {
                "kind": node.get("kind"),
                "pointer": node.get("id"),
                "path": node.get("path"),
                "line": node.get("line"),
                "authority": "derived_discovery",
                "certainty": "evidence_backed",
                "freshness": "current_index",
                "score": item["score"],
                "reasons": item["reasons"],
            }
        )
    gaps = [
        {"kind": "missing_seed", "seed_fingerprint": _task_fingerprint(seed), "state": "unknown", "fallback": "targeted_canonical_retrieval"}
        for seed in ranked["missing_seeds"]
    ]
    if ranked["truncated"]:
        gaps.append({"kind": "truncation", "state": "unknown", "fallback": "narrow_seeds_or_targeted_retrieval"})
    unsupported = graph.get("language_coverage", {}).get("unsupported", {})
    if unsupported:
        gaps.append(
            {
                "kind": "unsupported_languages",
                "languages": sorted(unsupported),
                "file_count": sum(int(count) for count in unsupported.values()),
                "state": "unknown",
                "fallback": "targeted_canonical_retrieval",
            }
        )
    return {
        "schema_version": SCHEMA_VERSION,
        "target": {
            "project": graph.get("project_root_name"),
            "branch": repository.get("branch"),
            "head": repository.get("head"),
            "worktree_id": repository.get("worktree_id"),
            "work_item": _task_fingerprint(task),
        },
        "accepted_outcome": accepted_outcome,
        "qualified_truth": [],
        "constraints": ["canonical_truth_outranks_derived_context", "context_never_authorizes_mutation"],
        "evidence": evidence,
        "gaps": gaps,
        "bounds": {"max_items": max_items, "candidate_count": ranked["candidate_count"], "truncated": ranked["truncated"]},
        "next_action": "revalidate decision-changing evidence against canonical sources",
    }


def evaluate_selection(capsule: dict[str, Any], *, expected_paths: Iterable[str]) -> dict[str, Any]:
    expected = set(expected_paths)
    selected = {item.get("path") for item in capsule.get("evidence", []) if item.get("path")}
    hits = len(expected & selected)
    return {
        "schema_version": "shipglows.context-evaluation/v1",
        "expected_count": len(expected),
        "selected_count": len(selected),
        "relevant_count": hits,
        "miss_count": len(expected) - hits,
        "noise_count": len(selected - expected),
        "recall": 1.0 if not expected else round(hits / len(expected), 6),
        "truncated": bool(capsule.get("bounds", {}).get("truncated")),
        "fallback_count": len(capsule.get("gaps", [])),
    }


def write_evaluation(path: Path, evaluation: dict[str, Any]) -> None:
    allowed = {
        "schema_version", "expected_count", "selected_count", "relevant_count", "miss_count",
        "noise_count", "recall", "truncated", "fallback_count",
    }
    if set(evaluation) - allowed:
        raise ValueError("evaluation contains non-aggregate fields")
    path.parent.mkdir(parents=True, exist_ok=True)
    handle, temporary = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    try:
        with os.fdopen(handle, "w", encoding="utf-8", newline="\n") as stream:
            stream.write(json.dumps(evaluation, indent=2, sort_keys=True) + "\n")
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--graph", type=Path, required=True)
    parser.add_argument("--task", required=True)
    parser.add_argument("--accepted-outcome", required=True)
    parser.add_argument("--seed", action="append", default=[])
    parser.add_argument("--max-items", type=int, default=40)
    parser.add_argument("--expected-path", action="append", default=[])
    parser.add_argument("--evaluation-output", type=Path)
    args = parser.parse_args()
    graph = json.loads(args.graph.read_text(encoding="utf-8"))
    capsule = build_capsule(graph, task=args.task, accepted_outcome=args.accepted_outcome, explicit_seeds=args.seed, max_items=args.max_items)
    print(json.dumps(capsule, indent=2, ensure_ascii=False))
    if args.evaluation_output:
        write_evaluation(args.evaluation_output, evaluate_selection(capsule, expected_paths=args.expected_path))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
