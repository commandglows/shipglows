#!/usr/bin/env python3
"""Validate and measure explicit reference-activation profiles."""

from __future__ import annotations

import argparse
import json
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


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--registry", type=Path, default=DEFAULT_REGISTRY)
    parser.add_argument("--skill")
    parser.add_argument("--format", choices=("text", "json"), default="text")
    args = parser.parse_args()
    registry = json.loads(args.registry.read_text(encoding="utf-8"))
    payload = audit_profiles(registry, selected_skill=args.skill)

    if args.format == "json":
        print(json.dumps(payload, ensure_ascii=False, sort_keys=True))
    else:
        for skill, result in payload["skills"].items():
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
