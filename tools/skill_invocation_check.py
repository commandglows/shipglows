#!/usr/bin/env python3
"""Validate an explicit ShipGlows skill invocation without executing it."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_INDEX = ROOT / "skills/references/skill-code-index.md"
DEFAULT_REGISTRY = ROOT / "skills/references/skill-invocation-registry.json"
ROW_RE = re.compile(r"^\|\s*`(?P<code>\d{3})`\s*\|\s*`[^`]+`\s*\|\s*`(?P<skill>[^`]+)`")


def parse_index(path: Path) -> dict[str, str]:
    identities: dict[str, str] = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        match = ROW_RE.match(line)
        if not match:
            continue
        code, skill = match.group("code"), match.group("skill")
        identities[skill] = skill
        identities[code] = skill
        identities[skill.replace("-", "")] = skill
        identities[f"{code} {skill[4:]}"] = skill
    return identities


def result(status: str, requested: str, **details: Any) -> dict[str, Any]:
    return {"status": status, "requested": requested, **details}


def edit_distance(left: str, right: str) -> int:
    """Return Levenshtein distance without external dependencies."""
    previous = list(range(len(right) + 1))
    for left_index, left_char in enumerate(left, start=1):
        current = [left_index]
        for right_index, right_char in enumerate(right, start=1):
            current.append(
                min(
                    current[-1] + 1,
                    previous[right_index] + 1,
                    previous[right_index - 1] + (left_char != right_char),
                )
            )
        previous = current
    return previous[-1]


def close_typo_candidates(value: str, candidates: set[str]) -> list[str]:
    """Return only equally closest safe spellings; uncertainty stays visible."""
    ranked = sorted((edit_distance(value, candidate), candidate) for candidate in candidates)
    if not ranked:
        return []
    distance = ranked[0][0]
    closest = [candidate for candidate_distance, candidate in ranked if candidate_distance == distance]
    maximum = max(1, min(len(candidate) for candidate in closest) // 4)
    return closest if distance <= maximum else []


def check(
    invocation: str,
    index_path: Path = DEFAULT_INDEX,
    registry_path: Path = DEFAULT_REGISTRY,
) -> dict[str, Any]:
    requested = invocation.strip()
    tokens = requested.removeprefix("$").removeprefix("/").split()
    if not tokens:
        return result(
            "invalid",
            requested,
            error="empty_invocation",
            message="Name a ShipGlows skill and its instruction.",
        )

    identities = parse_index(index_path)
    first = tokens[0]
    skill = identities.get(first)
    consumed = 1
    if skill is None and len(tokens) >= 2 and re.fullmatch(r"\d{3}", first):
        skill = identities.get(f"{first} {tokens[1]}")
        consumed = 2 if skill else 1
    if skill is None:
        return result(
            "invalid",
            requested,
            error="unknown_skill",
            message="This skill is not registered in the canonical code index.",
        )

    registry = json.loads(registry_path.read_text(encoding="utf-8"))
    rule = registry["rules"].get(skill)
    if rule is None:
        return result(
            "invalid",
            requested,
            resolved_skill=skill,
            error="missing_schema",
            message="This registered skill has no invocation schema yet.",
        )

    args = tokens[consumed:]
    if rule["kind"] == "freeform":
        if len(args) < rule.get("min_args", 0):
            return result(
                "invalid",
                requested,
                resolved_skill=skill,
                error="missing_argument",
                message="This skill needs an instruction or target.",
            )
        return result("valid", requested, resolved_skill=skill)

    if not args:
        return result(
            "invalid",
            requested,
            resolved_skill=skill,
            error="missing_mode",
            message="Choose one of this skill's declared modes.",
            allowed_modes=sorted(rule["modes"]),
        )

    mode, rest = args[0], args[1:]
    mode_rule = rule["modes"].get(mode)
    if mode_rule is None:
        known_suggestions = registry.get("mode_suggestions", {})
        typo_candidates = close_typo_candidates(mode, set(rule["modes"]) | set(known_suggestions))
        if len(typo_candidates) > 1:
            return result(
                "ambiguous",
                requested,
                resolved_skill=skill,
                error="ambiguous_mode",
                mode=mode,
                candidates=typo_candidates,
                message="More than one registered mode is an equally close match.",
            )
        corrected_mode = typo_candidates[0] if typo_candidates else None
        suggestion = known_suggestions.get(corrected_mode) if corrected_mode else None
        payload: dict[str, Any] = {
            "resolved_skill": skill,
            "error": "unknown_mode",
            "mode": mode,
            "allowed_modes": sorted(rule["modes"]),
            "message": "This mode is not supported by the selected skill.",
        }
        if corrected_mode:
            payload["did_you_mean"] = corrected_mode
        if suggestion and suggestion["skill"] != skill:
            payload["suggestion"] = suggestion["template"]
        elif corrected_mode in rule["modes"]:
            payload["suggestion"] = f"{skill} {corrected_mode}"
        return result("invalid", requested, **payload)

    if len(rest) < mode_rule.get("min_args", 0):
        return result(
            "invalid",
            requested,
            resolved_skill=skill,
            error="missing_argument",
            mode=mode,
            message="This mode needs an additional target or scope.",
        )
    return result("valid", requested, resolved_skill=skill, mode=mode)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("invocation", help="Explicit invocation, without executing it")
    parser.add_argument("--format", choices=("json", "text"), default="json")
    args = parser.parse_args()
    payload = check(args.invocation)
    if args.format == "json":
        print(json.dumps(payload, ensure_ascii=False, sort_keys=True))
    elif payload["status"] == "valid":
        print(f"Valid: {payload['resolved_skill']}")
    else:
        print(payload["message"])
        if "suggestion" in payload:
            print(f"Suggestion: {payload['suggestion']}")
    return 0 if payload["status"] == "valid" else 2


if __name__ == "__main__":
    raise SystemExit(main())
