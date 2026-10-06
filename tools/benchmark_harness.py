#!/usr/bin/env python3
"""Run arbitrary commands and persist comparable benchmark samples as JSONL."""

from __future__ import annotations

import argparse
from collections import defaultdict
from datetime import datetime, timezone
import json
import math
import os
from pathlib import Path
import platform
import statistics
import subprocess
import sys
import time
from typing import Any, Iterable
import uuid


SCHEMA_VERSION = "1.0"


class BenchmarkError(ValueError):
    """Raised when a benchmark definition or result stream is invalid."""


def _utc_now() -> str:
    return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")


def _percentile(values: list[int], percentile: float) -> int:
    ordered = sorted(values)
    if len(ordered) == 1:
        return ordered[0]
    rank = (len(ordered) - 1) * percentile
    lower = math.floor(rank)
    upper = math.ceil(rank)
    if lower == upper:
        return ordered[lower]
    return round(ordered[lower] + (ordered[upper] - ordered[lower]) * (rank - lower))


def load_suite(path: Path) -> dict[str, Any]:
    try:
        suite = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise BenchmarkError(f"Cannot read benchmark suite {path}: {error}") from error
    if suite.get("schema_version") != SCHEMA_VERSION:
        raise BenchmarkError(f"schema_version must be {SCHEMA_VERSION}")
    if not isinstance(suite.get("suite_id"), str) or not suite["suite_id"].strip():
        raise BenchmarkError("suite_id must be a non-empty string")
    benchmarks = suite.get("benchmarks")
    if not isinstance(benchmarks, list) or not benchmarks:
        raise BenchmarkError("benchmarks must be a non-empty array")
    seen: set[str] = set()
    for benchmark in benchmarks:
        benchmark_id = benchmark.get("id") if isinstance(benchmark, dict) else None
        command = benchmark.get("command") if isinstance(benchmark, dict) else None
        if not isinstance(benchmark_id, str) or not benchmark_id.strip() or benchmark_id in seen:
            raise BenchmarkError("each benchmark id must be non-empty and unique")
        if not isinstance(command, list) or not command or not all(isinstance(item, str) and item for item in command):
            raise BenchmarkError(f"benchmark {benchmark_id}: command must be a non-empty string array")
        for field in ("warmup", "iterations"):
            value = benchmark.get(field, 0 if field == "warmup" else 5)
            if not isinstance(value, int) or isinstance(value, bool) or value < (0 if field == "warmup" else 1):
                raise BenchmarkError(f"benchmark {benchmark_id}: {field} is invalid")
        seen.add(benchmark_id)
    return suite


def _sample(
    suite_id: str,
    benchmark: dict[str, Any],
    execution_id: str,
    iteration: int,
    phase: str,
    base_dir: Path,
) -> dict[str, Any]:
    cwd = (base_dir / benchmark.get("cwd", ".")).resolve()
    env = os.environ.copy()
    configured_env = benchmark.get("env", {})
    if not isinstance(configured_env, dict) or not all(isinstance(k, str) and isinstance(v, str) for k, v in configured_env.items()):
        raise BenchmarkError(f"benchmark {benchmark['id']}: env must contain only string values")
    env.update(configured_env)
    timeout = benchmark.get("timeout_seconds")
    if timeout is not None and (not isinstance(timeout, (int, float)) or isinstance(timeout, bool) or timeout <= 0):
        raise BenchmarkError(f"benchmark {benchmark['id']}: timeout_seconds must be positive")
    started_at = _utc_now()
    started = time.perf_counter_ns()
    timed_out = False
    try:
        completed = subprocess.run(
            benchmark["command"], cwd=cwd, env=env, capture_output=True,
            timeout=timeout, check=False,
        )
        exit_code = completed.returncode
    except subprocess.TimeoutExpired:
        exit_code = None
        timed_out = True
    duration_ns = time.perf_counter_ns() - started
    return {
        "schema_version": SCHEMA_VERSION,
        "record_type": "sample",
        "suite_id": suite_id,
        "benchmark_id": benchmark["id"],
        "execution_id": execution_id,
        "recorded_at": started_at,
        "phase": phase,
        "iteration": iteration,
        "command": benchmark["command"],
        "cwd": str(cwd),
        "status": "timeout" if timed_out else ("ok" if exit_code == 0 else "failed"),
        "exit_code": exit_code,
        "timed_out": timed_out,
        "metrics": {"duration_ns": duration_ns},
        "tags": benchmark.get("tags", {}),
        "host": {"os": platform.system(), "architecture": platform.machine(), "python": platform.python_version()},
    }


def summarize(records: Iterable[dict[str, Any]]) -> list[dict[str, Any]]:
    groups: dict[tuple[str, str, str], list[dict[str, Any]]] = defaultdict(list)
    for record in records:
        if record.get("schema_version") != SCHEMA_VERSION or record.get("record_type") != "sample":
            continue
        if record.get("phase") == "measure":
            groups[(record["suite_id"], record["benchmark_id"], record["execution_id"])].append(record)
    summaries = []
    for (suite_id, benchmark_id, execution_id), samples in sorted(groups.items()):
        durations = [sample["metrics"]["duration_ns"] for sample in samples]
        successes = sum(sample["status"] == "ok" for sample in samples)
        summaries.append({
            "schema_version": SCHEMA_VERSION,
            "record_type": "summary",
            "suite_id": suite_id,
            "benchmark_id": benchmark_id,
            "execution_id": execution_id,
            "recorded_at": _utc_now(),
            "sample_count": len(samples),
            "success_count": successes,
            "success_rate": successes / len(samples),
            "metrics": {
                "duration_ns": {
                    "min": min(durations),
                    "max": max(durations),
                    "mean": round(statistics.fmean(durations)),
                    "median": round(statistics.median(durations)),
                    "p95": _percentile(durations, 0.95),
                    "stdev": round(statistics.pstdev(durations)),
                }
            },
        })
    return summaries


def _write_jsonl(path: Path, records: Iterable[dict[str, Any]], append: bool) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a" if append else "w", encoding="utf-8", newline="\n") as stream:
        for record in records:
            stream.write(json.dumps(record, ensure_ascii=False, separators=(",", ":")) + "\n")


def run_suite(config_path: Path, output_path: Path, append: bool = False) -> list[dict[str, Any]]:
    suite = load_suite(config_path)
    execution_id = str(uuid.uuid4())
    records: list[dict[str, Any]] = []
    for benchmark in suite["benchmarks"]:
        for iteration in range(1, benchmark.get("warmup", 0) + 1):
            records.append(_sample(suite["suite_id"], benchmark, execution_id, iteration, "warmup", config_path.parent))
        for iteration in range(1, benchmark.get("iterations", 5) + 1):
            records.append(_sample(suite["suite_id"], benchmark, execution_id, iteration, "measure", config_path.parent))
    records.extend(summarize(records))
    _write_jsonl(output_path, records, append)
    return records


def read_jsonl(path: Path) -> list[dict[str, Any]]:
    records = []
    try:
        for line_number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            if line.strip():
                records.append(json.loads(line))
    except (OSError, json.JSONDecodeError) as error:
        raise BenchmarkError(f"Cannot read result stream {path}: {error}") from error
    return records


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="action", required=True)
    run = subparsers.add_parser("run", help="run a benchmark suite")
    run.add_argument("config", type=Path)
    run.add_argument("--output", type=Path, required=True)
    run.add_argument("--append", action="store_true")
    aggregate = subparsers.add_parser("summarize", help="aggregate sample records")
    aggregate.add_argument("results", type=Path)
    aggregate.add_argument("--output", type=Path)
    args = parser.parse_args(argv)
    try:
        if args.action == "run":
            records = run_suite(args.config, args.output, args.append)
            summaries = [record for record in records if record["record_type"] == "summary"]
        else:
            summaries = summarize(read_jsonl(args.results))
            if args.output:
                _write_jsonl(args.output, summaries, False)
        for summary in summaries:
            duration = summary["metrics"]["duration_ns"]
            print(f"{summary['benchmark_id']}: median={duration['median'] / 1_000_000:.3f} ms p95={duration['p95'] / 1_000_000:.3f} ms success={summary['success_rate']:.0%}")
        return 0 if all(item["success_rate"] == 1 for item in summaries) else 1
    except BenchmarkError as error:
        parser.error(str(error))
    return 2


if __name__ == "__main__":
    sys.exit(main())
