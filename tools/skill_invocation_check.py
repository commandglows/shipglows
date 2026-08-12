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


def public_entries(registry: dict[str, Any]) -> dict[str, dict[str, Any]]:
    entries = {
        entry["id"]: entry
        for domain in registry.get("public_catalog", {}).get("domains", [])
        for entry in domain.get("skills", [])
    }
    router = registry.get("public_catalog", {}).get("router")
    if router:
        entries[router["id"]] = router
    return entries


def validate_activation_graph(
    registry: dict[str, Any],
    skills_root: Path = ROOT / "skills",
) -> dict[str, Any]:
    """Validate the registry-owned public-to-engine activation graph."""
    entries = public_entries(registry)
    errors: list[str] = []
    edges: set[tuple[str, str]] = set()
    owners: dict[str, set[str]] = {}

    def add_edge(owner: str, engine: str, locus: str) -> None:
        if not engine:
            errors.append(f"missing_runtime_engine:{locus}")
            return
        edges.add((owner, engine))
        owners.setdefault(engine, set()).add(owner)
        if not (skills_root / engine / "SKILL.md").is_file():
            errors.append(f"missing_engine:{locus}:{engine}")

    public_skills: set[str] = set()
    for owner, entry in entries.items():
        wrapper = entry.get("public_skill")
        if not wrapper:
            errors.append(f"missing_public_skill:{owner}")
        else:
            public_skills.add(wrapper)
            if not (skills_root / wrapper / "SKILL.md").is_file():
                errors.append(f"missing_public_wrapper:{owner}:{wrapper}")
        add_edge(owner, entry.get("runtime_skill", ""), f"{owner}.runtime_skill")
        for engine in entry.get("internal_engines", []):
            add_edge(owner, engine, f"{owner}.internal_engines")
        for mode, route in entry.get("hidden_modes", {}).items():
            add_edge(owner, route.get("runtime_engine", ""), f"{owner}.hidden_modes.{mode}")

    for alias, mapping in registry.get("codex_expert_aliases", {}).items():
        owner = mapping.get("public_owner")
        entry = entries.get(owner)
        if entry is None:
            errors.append(f"unknown_alias_owner:{alias}:{owner}")
            continue
        declared_modes = set(entry.get("modes", [])) | set(entry.get("hidden_modes", {}))
        if mapping.get("owner_mode") not in declared_modes:
            errors.append(f"unknown_alias_mode:{alias}:{owner}:{mapping.get('owner_mode')}")
        allowed = {entry.get("runtime_skill"), *entry.get("internal_engines", [])}
        allowed.update(route.get("runtime_engine") for route in entry.get("hidden_modes", {}).values())
        engine = mapping.get("runtime_engine")
        if engine not in allowed:
            errors.append(f"alias_engine_not_owned:{alias}:{owner}:{engine}")
        for index, specialist in enumerate(mapping.get("specialist_routes", [])):
            specialist_owner = specialist.get("public_owner")
            specialist_entry = entries.get(specialist_owner)
            if specialist_entry is None:
                errors.append(f"unknown_specialist_owner:{alias}:{index}:{specialist_owner}")
                continue
            specialist_modes = set(specialist_entry.get("modes", [])) | set(
                specialist_entry.get("hidden_modes", {})
            )
            if specialist.get("owner_mode") not in specialist_modes:
                errors.append(
                    f"unknown_specialist_mode:{alias}:{index}:{specialist_owner}:{specialist.get('owner_mode')}"
                )
            specialist_allowed = {
                specialist_entry.get("runtime_skill"),
                *specialist_entry.get("internal_engines", []),
            }
            specialist_allowed.update(
                route.get("runtime_engine")
                for route in specialist_entry.get("hidden_modes", {}).values()
            )
            if specialist.get("runtime_engine") not in specialist_allowed:
                errors.append(
                    f"specialist_engine_not_owned:{alias}:{index}:{specialist_owner}:{specialist.get('runtime_engine')}"
                )

    available = {
        path.parent.name
        for path in skills_root.glob("*/SKILL.md")
        if not path.parent.is_symlink()
    }
    experts = available - public_skills
    owned_experts = set(owners) & experts
    if registry.get("internal_catalog", {}).get("require_owned_expert_coverage"):
        for engine in sorted(experts - owned_experts):
            errors.append(f"unowned_expert:{engine}")

    return {
        "status": "valid" if not errors else "invalid",
        "errors": sorted(set(errors)),
        "public_skills": len(public_skills),
        "expert_skills": len(experts),
        "owned_experts": len(owned_experts),
        "edges": len(edges),
        "owners": {engine: sorted(values) for engine, values in sorted(owners.items())},
    }


def validate_preflight_graph(
    registry: dict[str, Any],
    skills_root: Path = ROOT / "skills",
) -> dict[str, Any]:
    """Validate ownership plus the executable profiled resource closure."""
    ownership = validate_activation_graph(registry, skills_root)
    try:
        from tools.resource_dependency_graph import audit_dependency_graph, profile_roots
    except ModuleNotFoundError:
        from resource_dependency_graph import audit_dependency_graph, profile_roots
    dependencies = audit_dependency_graph(skills_root.parent, profile_roots(registry))
    errors = [*ownership["errors"], *(f"resource:{error}" for error in dependencies["errors"])]
    return {
        **ownership,
        "status": "valid" if not errors else "invalid",
        "errors": sorted(set(errors)),
        "resource_artifacts": dependencies["artifacts"],
        "resource_dependencies": dependencies["dependencies"],
        "resource_cycles": dependencies["cycles"],
    }


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


def valid_with_profile_preflight(
    requested: str,
    registry: dict[str, Any],
    skills_root: Path,
    **details: Any,
) -> dict[str, Any]:
    selected = (
        details.get("selected_internal_engine")
        or details.get("runtime_engine")
        or details.get("resolved_skill")
    )
    profiles = registry.get("activation_profiles", {}).get("skills", {})
    if selected in profiles:
        try:
            from tools.skill_activation_budget import audit_profiles
        except ModuleNotFoundError:  # Direct `python tools/skill_invocation_check.py`.
            from skill_activation_budget import audit_profiles

        profile = audit_profiles(registry, skills_root.parent, selected)
        if profile["status"] != "valid":
            return result(
                "invalid",
                requested,
                error="activation_profile_invalid",
                message="The selected skill's activation profile is inconsistent.",
                resolved_skill=details.get("resolved_skill", selected),
                profile_errors=profile["errors"],
            )
        try:
            from tools.resource_dependency_graph import audit_dependency_graph
        except ModuleNotFoundError:  # Direct `python tools/skill_invocation_check.py`.
            from resource_dependency_graph import audit_dependency_graph
        selected_profile = profiles[selected]
        dependency_roots = list(selected_profile.get("baseline", []))
        for references in selected_profile.get("gates", {}).values():
            dependency_roots.extend(references)
        dependency_graph = audit_dependency_graph(skills_root.parent, dependency_roots)
        if dependency_graph["status"] != "valid":
            return result(
                "invalid",
                requested,
                error="resource_dependency_graph_invalid",
                message="The selected skill's explicit resource dependency graph is inconsistent.",
                resolved_skill=details.get("resolved_skill", selected),
                dependency_errors=dependency_graph["errors"],
            )
        details["activation_profile"] = selected
    return result("valid", requested, **details)


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
    skills_root: Path = ROOT / "skills",
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

    registry = json.loads(registry_path.read_text(encoding="utf-8"))
    if registry.get("internal_catalog", {}).get("require_owned_expert_coverage"):
        graph = validate_activation_graph(registry, skills_root)
        if graph["status"] != "valid":
            return result(
                "invalid",
                requested,
                error="activation_graph_invalid",
                message="The canonical skill activation graph is inconsistent.",
                graph_errors=graph["errors"],
            )
    public_catalog = public_entries(registry)

    identities = parse_index(index_path)
    first = tokens[0]
    public_entry = public_catalog.get(first)
    if public_entry is not None:
        args = tokens[1:]
        modes = public_entry.get("modes", ["default"])
        payload: dict[str, Any] = {
            "resolved_skill": public_entry.get("public_skill", first),
            "public_skill": first,
            "runtime_engine": public_entry["runtime_skill"],
        }
        if args:
            expert_alias = registry.get("codex_expert_aliases", {}).get(args[0]) if first == "shipglows" else None
            if expert_alias is not None:
                resolved_alias = expert_alias
                if expert_alias.get("resolution") == "contextual-specialist":
                    scope_tokens = {token.lower().strip(".,:;!?()[]{}") for token in args[1:]}
                    matches = [
                        route
                        for route in expert_alias.get("specialist_routes", [])
                        if scope_tokens.intersection(route.get("keywords", []))
                    ]
                    if len(matches) == 1:
                        resolved_alias = {**expert_alias, **matches[0], "resolution": "specialist"}
                payload.update(
                    {
                        "router_alias": args[0],
                        "public_owner": resolved_alias["public_owner"],
                        "mode": resolved_alias["owner_mode"],
                        "selected_internal_engine": resolved_alias["runtime_engine"],
                        "resolution": resolved_alias["resolution"],
                    }
                )
                return valid_with_profile_preflight(requested, registry, skills_root, **payload)
            hidden_mode = public_entry.get("hidden_modes", {}).get(args[0])
            if hidden_mode is not None:
                payload["mode"] = hidden_mode.get("owner_mode", args[0])
                if payload["mode"] != args[0]:
                    payload["mode_alias"] = args[0]
                payload["selected_internal_engine"] = hidden_mode["runtime_engine"]
                if "engine_mode" in hidden_mode:
                    payload["selected_engine_mode"] = hidden_mode["engine_mode"]
            elif args[0] in modes:
                payload["mode"] = args[0]
        return valid_with_profile_preflight(requested, registry, skills_root, **payload)

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
        return valid_with_profile_preflight(
            requested, registry, skills_root, resolved_skill=skill
        )

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
    return valid_with_profile_preflight(
        requested, registry, skills_root, resolved_skill=skill, mode=mode
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("invocation", nargs="?", help="Explicit invocation, without executing it")
    parser.add_argument(
        "--audit-graph",
        action="store_true",
        help="Validate and summarize the canonical public-to-engine activation graph.",
    )
    parser.add_argument("--format", choices=("json", "text"), default="json")
    args = parser.parse_args()
    if args.audit_graph:
        registry = json.loads(DEFAULT_REGISTRY.read_text(encoding="utf-8"))
        payload = validate_preflight_graph(registry)
    elif args.invocation:
        payload = check(args.invocation)
    else:
        parser.error("invocation is required unless --audit-graph is used")
    if args.format == "json":
        print(json.dumps(payload, ensure_ascii=False, sort_keys=True))
    elif payload["status"] == "valid" and args.audit_graph:
        print(
            "Valid graph: "
            f"public={payload['public_skills']} expert={payload['expert_skills']} "
            f"owned={payload['owned_experts']} edges={payload['edges']} "
            f"resources={payload['resource_artifacts']} dependencies={payload['resource_dependencies']} "
            f"cycles={payload['resource_cycles']}"
        )
    elif payload["status"] == "valid":
        print(f"Valid: {payload['resolved_skill']}")
    else:
        print(payload.get("message", "Invalid activation graph."))
        for error in payload.get("errors", payload.get("graph_errors", [])):
            print(f"- {error}")
        if "suggestion" in payload:
            print(f"Suggestion: {payload['suggestion']}")
    return 0 if payload["status"] == "valid" else 2


if __name__ == "__main__":
    raise SystemExit(main())
