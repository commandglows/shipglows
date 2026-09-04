#!/usr/bin/env python3
"""Validate and measure explicit reference-activation profiles."""

from __future__ import annotations

import argparse
import json
import math
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_REGISTRY = ROOT / "skills" / "references" / "skill-invocation-registry.json"


def estimate_tokens(path: Path) -> int:
    return (len(path.read_text(encoding="utf-8")) + 3) // 4


def audit_profiles(
    registry: dict[str, Any],
    root: Path = ROOT,
    selected_skill: str | None = None,
) -> dict[str, Any]:
    profiles = registry.get("activation_profiles", {}).get("skills", {})
    errors: list[str] = []
    results: dict[str, Any] = {}
    names = [selected_skill] if selected_skill else sorted(profiles)

    if selected_skill and selected_skill not in profiles:
        return {"status": "invalid", "errors": [f"missing_profile:{selected_skill}"], "skills": {}}

    for skill in names:
        profile = profiles[skill]
        body_rel = profile.get("body")
        body = root / body_rel if body_rel else None
        if body is None or not body.is_file():
            errors.append(f"missing_body:{skill}:{body_rel}")
            continue

        baseline = profile.get("baseline", [])
        gates = profile.get("gates", {})
        seen_paths: set[str] = {body_rel}
        baseline_tokens = estimate_tokens(body)
        missing: list[str] = []

        for relative in baseline:
            path = root / relative
            if not path.is_file():
                missing.append(relative)
                errors.append(f"missing_reference:{skill}:baseline:{relative}")
                continue
            if relative not in seen_paths:
                baseline_tokens += estimate_tokens(path)
                seen_paths.add(relative)

        gate_results: dict[str, Any] = {}
        worst_paths = set(seen_paths)
        worst_tokens = baseline_tokens
        for gate, references in sorted(gates.items()):
            if not references:
                errors.append(f"empty_gate:{skill}:{gate}")
            gate_tokens = 0
            gate_paths: set[str] = set()
            for relative in references:
                path = root / relative
                if not path.is_file():
                    missing.append(relative)
                    errors.append(f"missing_reference:{skill}:{gate}:{relative}")
                    continue
                if relative not in seen_paths and relative not in gate_paths:
                    gate_tokens += estimate_tokens(path)
                    gate_paths.add(relative)
                if relative not in worst_paths:
                    worst_tokens += estimate_tokens(path)
                    worst_paths.add(relative)
            gate_results[gate] = {
                "incremental_tokens": gate_tokens,
                "selected_tokens": baseline_tokens + gate_tokens,
                "references": references,
            }

        results[skill] = {
            "body_tokens": estimate_tokens(body),
            "baseline_tokens": baseline_tokens,
            "worst_case_tokens": worst_tokens,
            "baseline": baseline,
            "gates": gate_results,
            "missing": sorted(set(missing)),
        }

    return {"status": "valid" if not errors else "invalid", "errors": sorted(set(errors)), "skills": results}


def _path(relative: Any, root: Path) -> Path:
    if not isinstance(relative, str) or not relative.strip():
        raise ValueError("invalid_path")
    path = (root / relative).resolve()
    if Path(relative).is_absolute() or not path.is_relative_to(root.resolve()):
        raise ValueError(f"outside_root:{relative}")
    if not path.is_file():
        raise ValueError(f"missing_file:{relative}")
    return path


def audit_trace(trace: Any, root: Path = ROOT) -> dict[str, Any]:
    """Measure supplied observations separately; never infer a trace from declarations."""
    errors: list[str] = []
    seen: set[Path] = set()
    unique = repeated = 0
    events = trace.get("events") if isinstance(trace, dict) else None
    if not isinstance(events, list):
        return {"status": "invalid", "errors": ["invalid_events"]}
    for index, event in enumerate(events):
        try:
            if not isinstance(event, dict) or not isinstance(event.get("reason"), str) or not event["reason"].strip():
                raise ValueError("invalid_event")
            path = _path(event.get("path"), root)
            cost = estimate_tokens(path)
            if path in seen:
                repeated += cost
            else:
                unique += cost
                seen.add(path)
        except (ValueError, OSError) as error:
            errors.append(f"event:{index}:{error}")
    return {"status": "invalid" if errors else "valid", "errors": errors,
            "unique_tokens": unique, "repeated_tokens": repeated, "total_tokens": unique + repeated,
            "event_count": len(events), "unique_paths": len(seen)}


def audit_scenarios(registry: dict[str, Any], root: Path = ROOT,
                    selected_scenario: str | None = None) -> dict[str, Any]:
    """Audit explicit reads and optional, independently reviewed required-read witnesses.

    Witnesses are not inferred from reads, prose, or document validity dependencies.
    Their completeness and continued protection of behavior require independent review.
    """
    if not isinstance(registry, dict):
        return {"status": "invalid", "errors": ["invalid_registry"], "scenarios": {}}
    profiles = registry.get("activation_profiles", {})
    scenarios = profiles.get("scenarios", {}) if isinstance(profiles, dict) else None
    if not isinstance(scenarios, dict) or any(not isinstance(name, str) or not name.strip() for name in scenarios):
        return {"status": "invalid", "errors": ["invalid_scenarios"], "scenarios": {}}
    if selected_scenario and selected_scenario not in scenarios:
        return {"status": "invalid", "errors": [f"missing_scenario:{selected_scenario}"], "scenarios": {}}
    if not scenarios:
        return {"status": "invalid", "errors": ["missing_scenarios"], "scenarios": {}}
    results: dict[str, Any] = {}
    all_errors: list[str] = []
    for name in ([selected_scenario] if selected_scenario else sorted(scenarios)):
        scenario = scenarios[name]
        errors: list[str] = []
        result: dict[str, Any] = {"structural_status": "invalid", "budget_status": "not_evaluated"}
        try:
            if not isinstance(scenario, dict):
                raise ValueError("invalid_scenario")
            reads = scenario.get("reads")
            if not isinstance(reads, list) or not reads:
                raise ValueError("invalid_reads")
            nodes: dict[str, Any] = {}
            physical: set[Path] = set()
            stages: dict[str, int] = {}
            for read in reads:
                if not isinstance(read, dict):
                    raise ValueError("invalid_read")
                for field in ("stage", "trigger", "reason"):
                    if not isinstance(read.get(field), str) or not read[field].strip():
                        raise ValueError(f"invalid_read_{field}")
                if "parent" not in read or (read["parent"] is not None and not isinstance(read["parent"], str)):
                    raise ValueError("invalid_parent")
                path = _path(read.get("path"), root)
                if path in physical:
                    raise ValueError(f"duplicate_path:{read['path']}")
                physical.add(path)
                nodes[read["path"]] = read
                stages[read["stage"]] = stages.get(read["stage"], 0) + estimate_tokens(path)
            if "required_reads" in scenario:
                required = scenario["required_reads"]
                if not isinstance(required, list) or not required:
                    raise ValueError("invalid_required_reads")
                required_paths: set[Path] = set()
                for relative in required:
                    if (not isinstance(relative, str) or not relative.strip()
                            or "\\" in relative
                            or any(part in ("", ".", "..") for part in relative.split("/"))):
                        raise ValueError("invalid_required_read_path")
                    path = _path(relative, root)
                    if path in required_paths:
                        raise ValueError(f"duplicate_required_read:{relative}")
                    required_paths.add(path)
                    if path not in physical:
                        raise ValueError(f"missing_required_read:{relative}")
            entry, engine = scenario.get("entry"), scenario.get("selected_engine")
            if not isinstance(entry, str) or entry not in nodes:
                raise ValueError("missing_entry")
            if not isinstance(engine, str) or engine not in nodes:
                raise ValueError("missing_selected_engine")
            depth = 0
            for path in nodes:
                chain: list[str] = []
                current = path
                while current is not None:
                    if current in chain:
                        raise ValueError(f"cycle:{current}")
                    if current not in nodes:
                        raise ValueError(f"missing_parent:{current}")
                    chain.append(current)
                    current = nodes[current]["parent"]
                if chain[-1] != entry:
                    raise ValueError(f"unreachable_entry:{path}")
                if engine in chain:
                    depth = max(depth, chain.index(engine))
            budget = scenario.get("budget")
            if not isinstance(budget, dict):
                raise ValueError("invalid_budget")
            for field in ("max_tokens", "max_depth_after_selection"):
                if type(budget.get(field)) is not int or budget[field] < 0:
                    raise ValueError(f"invalid_budget_{field}")
            baseline, minimum = scenario.get("baseline_tokens"), scenario.get("min_reduction_percent")
            if type(baseline) is not int or baseline <= 0:
                raise ValueError("invalid_baseline_tokens")
            if type(minimum) not in (int, float) or not math.isfinite(minimum) or not 0 <= minimum <= 100:
                raise ValueError("invalid_min_reduction_percent")
            tokens = sum(stages.values())
            reduction = 100 * (baseline - tokens) / baseline
            violations = []
            if tokens > budget["max_tokens"]:
                violations.append("max_tokens")
            if depth > budget["max_depth_after_selection"]:
                violations.append("max_depth_after_selection")
            if reduction < minimum:
                violations.append("min_reduction_percent")
            result.update(structural_status="valid", budget_status="over_budget" if violations else "within_budget",
                          selected_tokens=tokens, stage_increments=stages, depth_after_selection=depth,
                          baseline_tokens=baseline, reduction_percent=reduction, violations=violations,
                          measurement="declared_unique_reads")
            errors.extend(f"budget:{violation}" for violation in violations)
        except (ValueError, OSError) as error:
            errors.append(str(error))
        result["errors"] = errors
        results[name] = result
        all_errors.extend(f"scenario:{name}:{error}" for error in errors)
    return {"status": "invalid" if all_errors else "valid", "errors": all_errors, "scenarios": results}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--registry", type=Path, default=DEFAULT_REGISTRY)
    parser.add_argument("--skill")
    selection = parser.add_mutually_exclusive_group()
    selection.add_argument("--scenario")
    selection.add_argument("--scenarios", action="store_true")
    parser.add_argument("--trace", type=Path)
    parser.add_argument("--format", choices=("text", "json"), default="text")
    args = parser.parse_args()
    if args.trace and not (args.scenario or args.scenarios):
        parser.error("--trace requires --scenario or --scenarios")
    if args.skill and (args.scenario or args.scenarios):
        parser.error("--skill cannot be combined with scenarios")
    try:
        registry = json.loads(args.registry.read_text(encoding="utf-8"))
        if not isinstance(registry, dict):
            raise ValueError("invalid_registry: expected object")
        payload = (audit_scenarios(registry, selected_scenario=args.scenario)
                   if args.scenario or args.scenarios else audit_profiles(registry, selected_skill=args.skill))
    except (ValueError, OSError, TypeError, AttributeError, KeyError) as error:
        payload = {"status": "invalid", "errors": [f"registry:{error}"]}
    if args.trace:
        try:
            payload["observed_trace"] = audit_trace(json.loads(args.trace.read_text(encoding="utf-8")))
        except (ValueError, OSError) as error:
            payload["observed_trace"] = {"status": "invalid", "errors": [f"trace:{error}"]}
        if payload["observed_trace"]["status"] != "valid":
            payload["status"] = "invalid"

    if args.format == "json":
        print(json.dumps(payload, ensure_ascii=False, sort_keys=True))
    else:
        for name, result in payload.get("scenarios", {}).items():
            print(f"{name}: declared={result.get('selected_tokens')} depth={result.get('depth_after_selection')} "
                  f"structure={result['structural_status']} budget={result['budget_status']}")
        if "observed_trace" in payload:
            print("observed_trace: " + json.dumps(payload["observed_trace"], sort_keys=True))
        for skill, result in payload.get("skills", {}).items():
            print(
                f"{skill}: body={result['body_tokens']} baseline={result['baseline_tokens']} "
                f"worst={result['worst_case_tokens']} gates={len(result['gates'])}"
            )
            for gate, gate_result in result["gates"].items():
                print(
                    f"  {gate}: +{gate_result['incremental_tokens']} "
                    f"selected={gate_result['selected_tokens']}"
                )
        for error in payload["errors"]:
            print(f"ERROR {error}")
    return 0 if payload["status"] == "valid" else 2


if __name__ == "__main__":
    raise SystemExit(main())
