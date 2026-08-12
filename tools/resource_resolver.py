#!/usr/bin/env python3
"""Resolve relevant ShipGlows references and playbooks without side effects."""

from __future__ import annotations

import argparse
from dataclasses import dataclass, replace
import json
from pathlib import Path
import re
import sys
import unicodedata
from typing import Iterable


ROOT = Path(__file__).resolve().parents[1]
MAX_FILE_BYTES = 512_000
MAX_RESULTS = 20
DEFAULT_MAX_TOKENS = 12_000
INACTIVE_STATUSES = {"archived", "deprecated", "inactive", "retired", "superseded"}
TOKEN_RE = re.compile(r"[a-z0-9]+")
HEADING_RE = re.compile(r"^#{1,6}\s+(.+)$", re.MULTILINE)
SCALAR_RE = re.compile(r"^(?P<key>[A-Za-z0-9_]+):\s*(?P<value>.*)$")
STOPWORDS = {
    "a", "an", "and", "au", "aux", "avec", "ce", "ces", "de", "des", "du",
    "en", "et", "for", "from", "in", "la", "le", "les", "of", "on", "or",
    "ou", "pour", "sur", "the", "to", "un", "une", "with",
}


class ResolverError(RuntimeError):
    """A deterministic resource resolution failure."""


@dataclass(frozen=True)
class Resource:
    resource_id: str
    path: Path
    relative_path: str
    kind: str
    status: str
    scope: str
    source_skill: str
    owner_skill: str
    title: str
    linked_systems: tuple[str, ...]
    depends_on: tuple[str, ...]
    searchable: str
    headings: str
    estimated_tokens: int
    score: int = 0
    reasons: tuple[str, ...] = ()

    def public_dict(self) -> dict[str, object]:
        return {
            "resource_id": self.resource_id,
            "path": str(self.path),
            "relative_path": self.relative_path,
            "type": self.kind,
            "status": self.status,
            "scope": self.scope,
            "source_skill": self.source_skill or None,
            "estimated_tokens": self.estimated_tokens,
            "score": self.score,
            "reasons": list(self.reasons),
        }


@dataclass(frozen=True)
class ResourceExclusion:
    resource: Resource
    reason: str

    def public_dict(self) -> dict[str, object]:
        return {
            "resource_id": self.resource.resource_id,
            "status": self.resource.status,
            "estimated_tokens": self.resource.estimated_tokens,
            "score": self.resource.score,
            "reason": self.reason,
        }


@dataclass(frozen=True)
class ResourcePack:
    resources: tuple[Resource, ...]
    skipped: tuple[ResourceExclusion, ...]
    candidate_count: int
    considered_count: int
    omitted_by_result_limit: int
    max_results: int
    max_tokens: int

    @property
    def estimated_tokens(self) -> int:
        return sum(resource.estimated_tokens for resource in self.resources)


def _normalize(value: str) -> str:
    decomposed = unicodedata.normalize("NFKD", value)
    return "".join(char for char in decomposed if not unicodedata.combining(char)).lower()


def _tokens(value: str) -> set[str]:
    return {token for token in TOKEN_RE.findall(_normalize(value)) if len(token) > 1 and token not in STOPWORDS}


def _clean_scalar(value: str) -> str:
    cleaned = value.strip()
    if cleaned in {"[]", "{}", "null", "none", "~"}:
        return ""
    if len(cleaned) >= 2 and cleaned[0] == cleaned[-1] and cleaned[0] in {'"', "'"}:
        return cleaned[1:-1]
    return cleaned


def _estimate_tokens(text: str) -> int:
    """Return a deterministic, tokenizer-independent content estimate."""
    return max(1, (len(text) + 3) // 4)


def _parse_frontmatter(text: str) -> tuple[dict[str, str], dict[str, tuple[str, ...]], str]:
    if not text.startswith("---\n"):
        return {}, {}, text
    closing = text.find("\n---\n", 4)
    if closing < 0:
        raise ResolverError("Malformed frontmatter: missing closing delimiter")
    block = text[4:closing]
    body = text[closing + 5 :]
    scalars: dict[str, str] = {}
    lists: dict[str, list[str]] = {}
    current_key = ""
    for line in block.splitlines():
        scalar = SCALAR_RE.match(line)
        if scalar:
            current_key = scalar.group("key")
            scalars[current_key] = _clean_scalar(scalar.group("value"))
            lists.setdefault(current_key, [])
            continue
        stripped = line.strip()
        if not current_key or not stripped.startswith("-"):
            continue
        item = stripped[1:].strip()
        if item.startswith("artifact:"):
            item = item.split(":", 1)[1].strip()
        item = _clean_scalar(item)
        if item:
            lists[current_key].append(item)
    return scalars, {key: tuple(values) for key, values in lists.items()}, body


def _stable_fragment(path: Path) -> str:
    fragment = path.with_suffix("").as_posix().strip("/")
    fragment = re.sub(r"[^a-z0-9/._-]+", "-", _normalize(fragment))
    return re.sub(r"-+", "-", fragment).strip("-")


def _resource_from_path(
    root: Path,
    base: Path,
    path: Path,
    namespace: str,
    owner_skill: str = "",
) -> Resource:
    resolved_root = root.resolve()
    resolved_base = base.resolve()
    resolved_path = path.resolve()
    if not resolved_path.is_relative_to(resolved_base) or not resolved_path.is_relative_to(resolved_root):
        raise ResolverError(f"Resource escapes its canonical root: {path}")
    if resolved_path.stat().st_size > MAX_FILE_BYTES:
        raise ResolverError(f"Resource exceeds {MAX_FILE_BYTES} bytes: {path}")
    text = resolved_path.read_text(encoding="utf-8")
    scalars, lists, body = _parse_frontmatter(text)
    relative_path = resolved_path.relative_to(resolved_root).as_posix()
    relative_to_base = resolved_path.relative_to(resolved_base)
    resource_id = f"{namespace}:{_stable_fragment(relative_to_base)}"
    headings = " ".join(HEADING_RE.findall(body))
    title_match = HEADING_RE.search(body)
    title = title_match.group(1).strip() if title_match else resolved_path.stem.replace("-", " ").title()
    searchable = " ".join(
        (
            resource_id,
            relative_path,
            scalars.get("scope", ""),
            scalars.get("artifact", ""),
            scalars.get("source_skill", ""),
            title,
            headings,
            " ".join(lists.get("linked_systems", ())),
            " ".join(lists.get("depends_on", ())),
            body,
        )
    )
    return Resource(
        resource_id=resource_id,
        path=resolved_path,
        relative_path=relative_path,
        kind=scalars.get("artifact", "reference") or "reference",
        status=(scalars.get("status", "unknown") or "unknown").lower(),
        scope=scalars.get("scope", ""),
        source_skill=scalars.get("source_skill", ""),
        owner_skill=owner_skill,
        title=title,
        linked_systems=lists.get("linked_systems", ()),
        depends_on=lists.get("depends_on", ()),
        searchable=searchable,
        headings=headings,
        estimated_tokens=_estimate_tokens(text),
    )


def _iter_markdown(base: Path) -> Iterable[Path]:
    if not base.exists():
        return ()
    return (
        path
        for path in sorted(base.rglob("*.md"))
        if "design-inspiration" not in path.relative_to(base).parts
    )


def build_catalog(root: Path = ROOT, include_inactive: bool = False) -> dict[str, Resource]:
    root = root.resolve()
    skills_root = root / "skills"
    if not skills_root.is_dir():
        raise ResolverError(f"Missing canonical skills root: {skills_root}")

    resources: list[Resource] = []
    shared = skills_root / "references"
    for path in _iter_markdown(shared):
        resources.append(_resource_from_path(root, shared, path, "shared"))

    for skill_dir in sorted(skills_root.iterdir()):
        local = skill_dir / "references"
        if not skill_dir.is_dir() or not local.is_dir():
            continue
        for path in _iter_markdown(local):
            resources.append(_resource_from_path(root, local, path, skill_dir.name, skill_dir.name))

    playbooks = root / "shipglows_data/workflow/playbooks"
    for path in _iter_markdown(playbooks):
        resources.append(_resource_from_path(root, playbooks, path, "workflow"))

    catalog: dict[str, Resource] = {}
    for resource in resources:
        if not include_inactive and resource.status in INACTIVE_STATUSES:
            continue
        folded_id = resource.resource_id.casefold()
        if folded_id in catalog:
            raise ResolverError(f"Duplicate resource ID: {resource.resource_id}")
        catalog[folded_id] = resource
    return catalog


def _validate_limit(limit: int) -> None:
    if not 1 <= limit <= MAX_RESULTS:
        raise ResolverError(f"limit must be between 1 and {MAX_RESULTS}")


def _validate_token_limit(max_tokens: int) -> None:
    if max_tokens < 1:
        raise ResolverError("max_tokens must be at least 1")


def _rank_resource(resource: Resource, skill: str, mode: str, intent: str) -> Resource | None:
    score = 0
    reasons: list[str] = []
    normalized_id = _normalize(resource.resource_id)
    normalized_scope = _normalize(resource.scope)
    normalized_title = _normalize(resource.title)
    normalized_links = _normalize(" ".join(resource.linked_systems + resource.depends_on))
    normalized_headings = _normalize(resource.headings)
    normalized_searchable = _normalize(resource.searchable)

    if resource.owner_skill == skill:
        score += 35
        reasons.append("skill-local resource")
    if resource.source_skill == skill:
        score += 20
        reasons.append("declared source skill")
    if skill in normalized_links:
        score += 15
        reasons.append("declared link to active skill")

    mode_tokens = _tokens(mode)
    if mode_tokens:
        if mode_tokens <= _tokens(" ".join((normalized_id, normalized_scope, normalized_title))):
            score += 35
            reasons.append("mode match in identity or scope")
        elif mode_tokens & _tokens(normalized_searchable):
            score += 5
            reasons.append("mode mentioned in resource")

    intent_tokens = _tokens(intent)
    matched_terms: list[str] = []
    identity_tokens = _tokens(" ".join((normalized_id, normalized_scope, normalized_title)))
    link_tokens = _tokens(normalized_links)
    heading_tokens = _tokens(normalized_headings)
    body_tokens = _tokens(normalized_searchable)
    for token in sorted(intent_tokens):
        token_score = 0
        if token in identity_tokens:
            token_score = 14
        elif token in link_tokens:
            token_score = 8
        elif token in heading_tokens:
            token_score = 6
        elif token in body_tokens:
            token_score = 2
        if token_score:
            score += token_score
            matched_terms.append(token)
    if matched_terms:
        reasons.append("intent terms: " + ", ".join(matched_terms[:8]))

    normalized_intent = " ".join(sorted(intent_tokens))
    if normalized_intent and normalized_intent in normalized_searchable:
        score += 15
        reasons.append("intent phrase match")

    if resource.status == "active":
        score += 5
    elif resource.status in {"draft", "review", "reviewed"}:
        score -= 5
        reasons.append(f"status: {resource.status}")
    elif resource.status != "active":
        score -= 10
        reasons.append(f"status: {resource.status}")

    if score <= 0:
        return None
    return replace(resource, score=score, reasons=tuple(reasons))


def _bounded_pack(
    ranked: Iterable[Resource],
    limit: int,
    max_tokens: int,
) -> ResourcePack:
    _validate_limit(limit)
    _validate_token_limit(max_tokens)
    candidates = tuple(ranked)
    unique: list[Resource] = []
    skipped: list[ResourceExclusion] = []
    seen_paths: set[str] = set()
    for resource in candidates:
        path_key = str(resource.path).casefold()
        if path_key in seen_paths:
            skipped.append(ResourceExclusion(resource, "duplicate canonical resource"))
            continue
        seen_paths.add(path_key)
        unique.append(resource)

    considered = unique[:limit]
    selected: list[Resource] = []
    used_tokens = 0
    for resource in considered:
        if resource.estimated_tokens > max_tokens - used_tokens:
            skipped.append(ResourceExclusion(resource, "estimated token budget exceeded"))
            continue
        selected.append(resource)
        used_tokens += resource.estimated_tokens

    return ResourcePack(
        resources=tuple(selected),
        skipped=tuple(skipped),
        candidate_count=len(candidates),
        considered_count=len(considered),
        omitted_by_result_limit=max(0, len(unique) - len(considered)),
        max_results=limit,
        max_tokens=max_tokens,
    )


def resolve_resource_pack(
    root: Path,
    skill: str,
    mode: str = "",
    intent: str = "",
    limit: int = 8,
    include_inactive: bool = False,
    max_tokens: int = DEFAULT_MAX_TOKENS,
) -> ResourcePack:
    _validate_limit(limit)
    _validate_token_limit(max_tokens)
    root = root.resolve()
    if not (root / "skills" / skill / "SKILL.md").is_file():
        raise ResolverError(f"Unknown ShipGlows skill: {skill}")
    if not intent.strip() and not mode.strip():
        raise ResolverError("Provide a mode or intent for responsible resource ranking")
    catalog = build_catalog(root, include_inactive=include_inactive)
    ranked = [
        ranked_resource
        for resource in catalog.values()
        if (ranked_resource := _rank_resource(resource, skill, mode, intent)) is not None
    ]
    ordered = sorted(ranked, key=lambda item: (-item.score, item.resource_id))
    return _bounded_pack(ordered, limit, max_tokens)


def resolve_resources(
    root: Path,
    skill: str,
    mode: str = "",
    intent: str = "",
    limit: int = 8,
    include_inactive: bool = False,
    max_tokens: int = DEFAULT_MAX_TOKENS,
) -> list[Resource]:
    return list(
        resolve_resource_pack(root, skill, mode, intent, limit, include_inactive, max_tokens).resources
    )


def get_resource(
    root: Path,
    resource_id: str,
    include_inactive: bool = False,
) -> Resource:
    catalog = build_catalog(root, include_inactive=include_inactive)
    resource = catalog.get(resource_id.casefold())
    if resource is None:
        raise ResolverError(f"Unknown resource ID: {resource_id}")
    return replace(resource, score=100, reasons=("exact stable resource ID",))


def _canonical_relation(value: str) -> str:
    cleaned = value.strip().strip('"').strip("'")
    if cleaned.startswith("artifact:"):
        cleaned = cleaned.split(":", 1)[1].strip().strip('"').strip("'")
    return cleaned


def expand_resource_pack(
    root: Path,
    resource_id: str,
    limit: int = 8,
    include_inactive: bool = False,
    max_tokens: int = DEFAULT_MAX_TOKENS,
) -> ResourcePack:
    _validate_limit(limit)
    _validate_token_limit(max_tokens)
    catalog = build_catalog(root, include_inactive=include_inactive)
    target = catalog.get(resource_id.casefold())
    if target is None:
        raise ResolverError(f"Unknown resource ID: {resource_id}")

    target_relations = {_canonical_relation(value) for value in target.linked_systems + target.depends_on}
    related: list[Resource] = []
    for candidate in catalog.values():
        if candidate.resource_id == target.resource_id:
            continue
        candidate_relations = {
            _canonical_relation(value) for value in candidate.linked_systems + candidate.depends_on
        }
        score = 0
        reasons: list[str] = []
        if candidate.relative_path in target_relations:
            score += 100
            reasons.append("declared by selected resource")
        if target.relative_path in candidate_relations:
            score += 90
            reasons.append("declares selected resource")
        if target.source_skill and (
            candidate.owner_skill == target.source_skill or candidate.source_skill == target.source_skill
        ):
            score += 20
            reasons.append("same declared owner domain")
        shared_terms = (_tokens(target.resource_id) & _tokens(candidate.resource_id)) - {
            "contract",
            "playbook",
            "reference",
            "shared",
            "workflow",
        }
        if shared_terms:
            score += min(12, 3 * len(shared_terms))
            reasons.append("shared identity terms: " + ", ".join(sorted(shared_terms)[:4]))
        if score:
            related.append(replace(candidate, score=score, reasons=tuple(reasons)))
    ordered = sorted(related, key=lambda item: (-item.score, item.resource_id))
    return _bounded_pack(ordered, limit, max_tokens)


def expand_resource(
    root: Path,
    resource_id: str,
    limit: int = 8,
    include_inactive: bool = False,
    max_tokens: int = DEFAULT_MAX_TOKENS,
) -> list[Resource]:
    return list(expand_resource_pack(root, resource_id, limit, include_inactive, max_tokens).resources)


def _print_text(resources: list[Resource], pack: ResourcePack | None = None) -> None:
    for resource in resources:
        reasons = "; ".join(resource.reasons)
        print(
            f"{resource.resource_id} [{resource.score}] "
            f"[{resource.status}] [~{resource.estimated_tokens} tokens] {resource.path}"
        )
        print(f"  {reasons}")
    if pack is None:
        return
    print(
        f"Selected {len(pack.resources)}/{pack.max_results} resources, "
        f"~{pack.estimated_tokens}/{pack.max_tokens} tokens; "
        f"{pack.omitted_by_result_limit} omitted by result limit."
    )
    for exclusion in pack.skipped:
        resource = exclusion.resource
        print(
            f"Skipped {resource.resource_id} [{resource.status}] "
            f"[~{resource.estimated_tokens} tokens]: {exclusion.reason}"
        )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--skill", help="Registered ShipGlows skill identity")
    parser.add_argument("--mode", default="", help="Selected skill mode")
    parser.add_argument("--intent", default="", help="Natural-language bounded intent")
    parser.add_argument("--get", help="Resolve one stable resource ID")
    parser.add_argument("--expand", help="Stable resource ID to expand")
    parser.add_argument("--limit", type=int, default=8)
    parser.add_argument(
        "--max-tokens",
        type=int,
        default=DEFAULT_MAX_TOKENS,
        help="Maximum deterministic estimated tokens for a ranked starter pack",
    )
    parser.add_argument("--include-inactive", action="store_true")
    parser.add_argument("--format", choices=("json", "text"), default="json")
    args = parser.parse_args()

    try:
        selected_actions = sum(bool(value) for value in (args.skill, args.get, args.expand))
        if selected_actions != 1:
            raise ResolverError("Choose exactly one of --skill, --get, or --expand")
        if args.get:
            resources = [get_resource(ROOT, args.get, args.include_inactive)]
            pack = None
            query = {"get": args.get}
        elif args.expand:
            pack = expand_resource_pack(
                ROOT,
                args.expand,
                args.limit,
                args.include_inactive,
                args.max_tokens,
            )
            resources = list(pack.resources)
            query = {"expand": args.expand}
        else:
            pack = resolve_resource_pack(
                ROOT,
                args.skill,
                args.mode,
                args.intent,
                args.limit,
                args.include_inactive,
                args.max_tokens,
            )
            resources = list(pack.resources)
            query = {"skill": args.skill, "mode": args.mode or None, "intent": args.intent or None}
    except (OSError, UnicodeError, json.JSONDecodeError, ResolverError) as error:
        print(json.dumps({"status": "error", "error": str(error)}, ensure_ascii=False), file=sys.stderr)
        return 2

    if args.format == "text":
        _print_text(resources, pack)
    else:
        budget = None
        skipped: list[dict[str, object]] = []
        if pack is not None:
            budget = {
                "candidate_count": pack.candidate_count,
                "considered_count": pack.considered_count,
                "estimated_tokens": pack.estimated_tokens,
                "max_results": pack.max_results,
                "max_tokens": pack.max_tokens,
                "omitted_by_result_limit": pack.omitted_by_result_limit,
                "skipped_count": len(pack.skipped),
            }
            skipped = [exclusion.public_dict() for exclusion in pack.skipped]
        print(
            json.dumps(
                {
                    "status": "ok",
                    "query": query,
                    "count": len(resources),
                    "results": [resource.public_dict() for resource in resources],
                    "budget": budget,
                    "skipped": skipped,
                },
                ensure_ascii=False,
                indent=2,
                sort_keys=True,
            )
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
