#!/usr/bin/env python3
"""Append collision-free ShipGlows context events, build a bounded Context Head,
and project public events into draft product update entries and roadmap items
(automatically after ``append`` when the repository has .shipglows.product-updates.json)."""

from __future__ import annotations

from dataclasses import asdict, dataclass
from datetime import date, datetime, timezone
from hashlib import sha256
from pathlib import Path, PurePosixPath
from typing import Any, Iterable
from urllib.parse import urlparse
import argparse
import json
import os
import re
import subprocess
import sys
import unicodedata
import uuid


SCHEMA_VERSION = "shipglows.context-event/v1"
CACHE_SCHEMA_VERSION = "shipglows.context-head-cache/v2"
HISTORY_RELATIVE = Path("shipglows_data/workflow/history")
CACHE_RELATIVE = Path(".shipglows")
MAX_EVENT_FILE_BYTES = 64 * 1024
MAX_FILES = 5_000
MAX_EVENTS = 5_000
DEFAULT_HEAD_EVENTS = 30
DEFAULT_HEAD_CHARACTERS = 16_000
MAX_GRAPH_SEEDS = 8
MAX_GRAPH_NODES = 40
MAX_GRAPH_POINTERS = 20
MAX_REFS = 16
MAX_INVALIDATIONS = 16
EVENT_ID_RE = re.compile(r"^evt_[a-f0-9]{32}$")
HASH_RE = re.compile(r"^[a-f0-9]{40,64}$", re.IGNORECASE)
WORKTREE_ID_RE = re.compile(r"^[a-f0-9]{24}$")
SHA256_RE = re.compile(r"^[a-f0-9]{64}$")
KINDS = {
    "CONTEXT_DECISION",
    "CONTEXT_CHANGE",
    "CONTEXT_FIX",
    "CONTEXT_PROOF",
    "CONTEXT_INVALIDATION",
    "CONTEXT_NEXT_ACTION",
}
PUBLIC_CATEGORIES = {
    "CHANGELOG_FEATURE",
    "CHANGELOG_IMPROVEMENT",
    "CHANGELOG_FIX",
    "CHANGELOG_SECURITY",
    "CHANGELOG_CONTENT",
}
DELIVERY_STATES = {
    "DELIVERY_SHIPPED",
    "DELIVERY_AVAILABLE",
    "DELIVERY_SITE_BUILD",
}
# Projection of public events into the shared update-entry contract
# (shipglows-app-engine/shared/updates, rendered by @shipglows/astro-updates).
UPDATE_KIND_BY_CATEGORY = {
    "CHANGELOG_FEATURE": ("feature", "added"),
    "CHANGELOG_IMPROVEMENT": ("improvement", "improved"),
    "CHANGELOG_FIX": ("fix", "fixed"),
    "CHANGELOG_SECURITY": ("security", "security"),
    "CHANGELOG_CONTENT": ("announcement", "improved"),
}
UPDATES_PACKAGE = "@shipglows/astro-updates"
UPDATES_RELATIVE = Path("src/content/updates")
CONTENT_MANIFEST = ".shipglows.content.json"
PUBLIC_LOCALES = ("en", "fr")
UPDATE_CTA_LABELS = {"en": "Learn more", "fr": "En savoir plus"}
UPDATE_SLUG_RE = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
UPDATE_HREF_RE = re.compile(r"^(?:/(?![/\\])[^\s]*|#[^\s]*|https://[^\s/@]+(?:[/?#][^\s]*)?)$")
MAX_PRODUCT_KEY = 40
MAX_UPDATE_SLUG_BODY = 60
# Roadmap status vocabulary (shipglows-app-engine/shared/roadmap/roadmap-statuses.json).
ROADMAP_STATUSES = ("considering", "planned", "in_progress", "shipped", "declined")
MAX_ROADMAP_CHANGES = 16
MAX_ROADMAP_ID = 100
MAX_UPDATE_SCAN_FILES = 5_000
UPDATE_HEAD_BYTES = 64 * 1024
SECRET_PATTERNS = (
    re.compile(r"-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----", re.IGNORECASE),
    re.compile(r"\bsk-[A-Za-z0-9_-]{20,}\b"),
    re.compile(r"\bgh[pousr]_[A-Za-z0-9]{20,}\b"),
    re.compile(r"\bAIza[A-Za-z0-9_-]{20,}\b"),
    re.compile(r"\bBearer\s+[A-Za-z0-9._~+/-]{16,}", re.IGNORECASE),
)


class ContextHistoryError(RuntimeError):
    """A deterministic history or Context Head contract failure."""


@dataclass(frozen=True)
class GitSnapshot:
    branch: str
    head: str
    worktreeId: str
    dirtyFingerprint: str
    dirtyCount: int


@dataclass(frozen=True)
class ContextHeadResult:
    markdown: str
    event_count: int
    markdown_path: Path
    metadata_path: Path


def _git(root: Path, *args: str) -> bytes:
    try:
        result = subprocess.run(
            ["git", *args],
            cwd=root,
            check=True,
            capture_output=True,
            timeout=10,
        )
    except (OSError, subprocess.CalledProcessError, subprocess.TimeoutExpired) as error:
        raise ContextHistoryError(f"Git context is unavailable: {' '.join(args)}") from error
    return result.stdout


def resolve_project_root(project_root: str | Path) -> Path:
    requested = Path(project_root).expanduser().resolve()
    if not requested.is_dir():
        raise ContextHistoryError(f"Project root is unavailable: {requested}")
    git_root_raw = _git(requested, "rev-parse", "--show-toplevel").decode("utf-8", errors="strict").strip()
    git_root = Path(git_root_raw).resolve()
    if git_root != requested:
        raise ContextHistoryError(f"Project root must be the Git worktree root: {git_root}")
    return requested


def git_snapshot(project_root: str | Path) -> GitSnapshot:
    root = resolve_project_root(project_root)
    head = _git(root, "rev-parse", "--verify", "HEAD").decode("ascii", errors="strict").strip()
    if not HASH_RE.fullmatch(head):
        raise ContextHistoryError("Git returned an invalid HEAD identifier.")
    try:
        branch = _git(root, "symbolic-ref", "--quiet", "--short", "HEAD").decode("utf-8", errors="strict").strip()
    except ContextHistoryError:
        branch = "DETACHED"
    if not branch or len(branch) > 255 or any(char in branch for char in "\r\n\0"):
        raise ContextHistoryError("Git returned an invalid branch name.")
    dirty = _git(
        root,
        "status",
        "--porcelain=v1",
        "-z",
        "--untracked-files=all",
        "--",
        ".",
        ":(exclude).shipglows",
    )
    worktree_identity = str(root).casefold() if os.name == "nt" else str(root)
    return GitSnapshot(
        branch=branch,
        head=head,
        worktreeId=sha256(worktree_identity.encode("utf-8")).hexdigest()[:24],
        dirtyFingerprint=sha256(dirty).hexdigest(),
        dirtyCount=sum(1 for item in dirty.split(b"\0") if item),
    )


def _utc_timestamp(value: str | None = None) -> str:
    if value is None:
        parsed = datetime.now(timezone.utc)
    else:
        try:
            parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
        except ValueError as error:
            raise ContextHistoryError("occurredAt must be an ISO-8601 timestamp with a timezone.") from error
        if parsed.tzinfo is None:
            raise ContextHistoryError("occurredAt must include a timezone.")
        parsed = parsed.astimezone(timezone.utc)
    return parsed.strftime("%Y-%m-%dT%H:%M:%S.%fZ")


def _bounded_string(value: Any, field: str, minimum: int, maximum: int) -> str:
    if not isinstance(value, str):
        raise ContextHistoryError(f"{field} must be a string.")
    if len(value) < minimum or len(value) > maximum or "\0" in value:
        raise ContextHistoryError(f"{field} must contain {minimum} to {maximum} characters.")
    return value


def _relative_reference(value: Any) -> str:
    reference = _bounded_string(value, "reference", 1, 300).replace("\\", "/")
    path = PurePosixPath(reference)
    if path.is_absolute() or ".." in path.parts or reference.startswith("~"):
        raise ContextHistoryError("Event references must be safe project-relative paths or opaque identifiers.")
    return reference


def _contains_secret_like_text(values: Iterable[str]) -> bool:
    combined = "\n".join(values)
    return any(pattern.search(combined) for pattern in SECRET_PATTERNS)


def _safe_link(value: Any) -> str:
    link = _bounded_string(value, "public.link", 1, 300)
    if link.startswith("/") and not link.startswith("//"):
        return link
    parsed = urlparse(link)
    if parsed.scheme != "https" or not parsed.netloc or parsed.username or parsed.password:
        raise ContextHistoryError("public.link must be a safe relative or HTTPS link.")
    return link


def _bilingual(value: Any, field: str, maximum: int) -> dict[str, str]:
    if not isinstance(value, dict) or set(value) != {"en", "fr"}:
        raise ContextHistoryError(f"{field} must contain English and French values.")
    return {locale: _bounded_string(value[locale], f"{field}.{locale}", 1, maximum) for locale in ("en", "fr")}


def _validate_delivery(value: Any) -> dict[str, str]:
    if not isinstance(value, dict) or set(value) != {"state", "proof"}:
        raise ContextHistoryError("public.delivery must contain state and proof.")
    if value.get("state") not in DELIVERY_STATES:
        raise ContextHistoryError("public.delivery.state is not a canonical delivery code.")
    return {"state": value["state"], "proof": _bounded_string(value.get("proof"), "public.delivery.proof", 1, 200)}


def _validate_roadmap(value: Any) -> list[dict[str, Any]]:
    """``public.roadmap``: roadmap items whose status this event changes, optional creation copy."""
    if not isinstance(value, list) or not 1 <= len(value) <= MAX_ROADMAP_CHANGES:
        raise ContextHistoryError(f"public.roadmap must list 1 to {MAX_ROADMAP_CHANGES} item changes.")
    changes: list[dict[str, Any]] = []
    for item in value:
        if not isinstance(item, dict) or set(item) - {"id", "status", "title", "summary"}:
            raise ContextHistoryError("public.roadmap items accept only id, status, title and summary.")
        item_id = _bounded_string(item.get("id"), "public.roadmap.id", 1, MAX_ROADMAP_ID)
        if not UPDATE_SLUG_RE.fullmatch(item_id):
            raise ContextHistoryError("public.roadmap.id must be a lowercase slug.")
        if any(change["id"] == item_id for change in changes):
            raise ContextHistoryError(f"public.roadmap lists {item_id} twice.")
        if item.get("status") not in ROADMAP_STATUSES:
            raise ContextHistoryError("public.roadmap.status is not a roadmap status.")
        change: dict[str, Any] = {"id": item_id, "status": item["status"]}
        if ("title" in item) != ("summary" in item):
            raise ContextHistoryError("public.roadmap title and summary are given together (creation copy).")
        if "title" in item:
            change["title"] = _bilingual(item["title"], "public.roadmap.title", 120)
            change["summary"] = _bilingual(item["summary"], "public.roadmap.summary", 300)
        changes.append(change)
    return changes


def _validate_public(value: Any) -> dict[str, Any]:
    """Validate the public allowlist: changelog copy, roadmap changes, or both.

    A roadmap-only object (no changelog copy) may omit ``delivery``; a roadmap
    change to ``shipped`` always requires ``delivery`` proof.
    """
    if not isinstance(value, dict):
        raise ContextHistoryError("public must be an object.")
    allowed = {"category", "title", "summary", "delivery", "link", "roadmap"}
    if set(value) - allowed:
        raise ContextHistoryError("public contains unsupported fields.")
    normalized: dict[str, Any] = {}
    texts: list[str] = []
    changelog = bool({"category", "title", "summary", "link"} & set(value)) or "roadmap" not in value
    if changelog:
        category = value.get("category")
        if category not in PUBLIC_CATEGORIES:
            raise ContextHistoryError("public.category is not a canonical changelog code.")
        normalized["category"] = category
        normalized["title"] = _bilingual(value.get("title"), "public.title", 120)
        normalized["summary"] = _bilingual(value.get("summary"), "public.summary", 400)
        normalized["delivery"] = _validate_delivery(value.get("delivery"))
        if value.get("link") is not None:
            normalized["link"] = _safe_link(value["link"])
        texts.extend((*normalized["title"].values(), *normalized["summary"].values()))
    elif value.get("delivery") is not None:
        normalized["delivery"] = _validate_delivery(value["delivery"])
    if "delivery" in normalized:
        texts.append(normalized["delivery"]["proof"])
    if "roadmap" in value:
        normalized["roadmap"] = _validate_roadmap(value["roadmap"])
        if "delivery" not in normalized and any(item["status"] == "shipped" for item in normalized["roadmap"]):
            raise ContextHistoryError(
                "public.roadmap sets status shipped without delivery proof; add public.delivery (state and proof)."
            )
        for item in normalized["roadmap"]:
            texts.extend((*item.get("title", {}).values(), *item.get("summary", {}).values()))
    if _contains_secret_like_text(texts):
        raise ContextHistoryError("Public changelog copy contains secret-like text.")
    return normalized


def validate_event(value: Any) -> dict[str, Any]:
    if not isinstance(value, dict):
        raise ContextHistoryError("An event must be a JSON object.")
    required = {
        "schemaVersion", "id", "occurredAt", "project", "kind", "summary",
        "branch", "head", "worktreeId", "dirtyFingerprint", "dirtyCount", "refs", "invalidates",
    }
    allowed = required | {"nextAction", "public"}
    missing = required - set(value)
    unknown = set(value) - allowed
    if missing:
        raise ContextHistoryError(f"Event is missing required fields: {', '.join(sorted(missing))}.")
    if unknown:
        raise ContextHistoryError(f"Event contains unsupported fields: {', '.join(sorted(unknown))}.")
    if value["schemaVersion"] != SCHEMA_VERSION:
        raise ContextHistoryError("Unsupported context event schema version.")
    event_id = _bounded_string(value["id"], "id", 36, 36)
    if not EVENT_ID_RE.fullmatch(event_id):
        raise ContextHistoryError("Event id must use the evt_<32 lowercase hex> format.")
    occurred_at = _utc_timestamp(value["occurredAt"])
    project = _bounded_string(value["project"], "project", 1, 128)
    if value["kind"] not in KINDS:
        raise ContextHistoryError("Event kind is not a canonical context event code.")
    summary = _bounded_string(value["summary"], "summary", 1, 500)
    branch = _bounded_string(value["branch"], "branch", 1, 255)
    if not isinstance(value["head"], str) or not HASH_RE.fullmatch(value["head"]):
        raise ContextHistoryError("Event head is invalid.")
    if not isinstance(value["worktreeId"], str) or not WORKTREE_ID_RE.fullmatch(value["worktreeId"]):
        raise ContextHistoryError("Event worktreeId is invalid.")
    if not isinstance(value["dirtyFingerprint"], str) or not SHA256_RE.fullmatch(value["dirtyFingerprint"]):
        raise ContextHistoryError("Event dirtyFingerprint is invalid.")
    if not isinstance(value["dirtyCount"], int) or isinstance(value["dirtyCount"], bool) or value["dirtyCount"] < 0:
        raise ContextHistoryError("Event dirtyCount must be a non-negative integer.")
    if not isinstance(value["refs"], list) or len(value["refs"]) > MAX_REFS:
        raise ContextHistoryError(f"Event refs must be an array with at most {MAX_REFS} items.")
    refs = [_relative_reference(item) for item in value["refs"]]
    if not isinstance(value["invalidates"], list) or len(value["invalidates"]) > MAX_INVALIDATIONS:
        raise ContextHistoryError(f"Event invalidates must contain at most {MAX_INVALIDATIONS} items.")
    invalidates = [_bounded_string(item, "invalidation", 1, 120) for item in value["invalidates"]]
    normalized: dict[str, Any] = {
        "schemaVersion": SCHEMA_VERSION,
        "id": event_id,
        "occurredAt": occurred_at,
        "project": project,
        "kind": value["kind"],
        "summary": summary,
        "branch": branch,
        "head": value["head"].lower(),
        "worktreeId": value["worktreeId"],
        "dirtyFingerprint": value["dirtyFingerprint"],
        "dirtyCount": value["dirtyCount"],
        "refs": refs,
        "invalidates": invalidates,
    }
    if value.get("nextAction") is not None:
        normalized["nextAction"] = _bounded_string(value["nextAction"], "nextAction", 1, 300)
    if value.get("public") is not None:
        normalized["public"] = _validate_public(value["public"])
    return normalized


def _canonical_json(value: Any) -> str:
    return json.dumps(value, ensure_ascii=False, separators=(",", ":"), sort_keys=True)


def _history_root(root: Path) -> Path:
    return root / HISTORY_RELATIVE


def _event_files(root: Path) -> list[Path]:
    history = _history_root(root)
    if not history.exists():
        return []
    if history.is_symlink() or not history.is_dir():
        raise ContextHistoryError("History root must be a real directory, not a symlink.")
    files: list[Path] = []
    for path in history.rglob("*"):
        if path.is_symlink():
            raise ContextHistoryError(f"History cannot contain symbolic links: {path}")
        if not path.is_file():
            continue
        if path.suffix != ".jsonl":
            continue
        resolved = path.resolve()
        if not resolved.is_relative_to(history):
            raise ContextHistoryError("History file escaped the history root.")
        files.append(path)
        if len(files) > MAX_FILES:
            raise ContextHistoryError(f"History contains more than {MAX_FILES} event files.")
    return sorted(files)


def _read_event_file(path: Path) -> dict[str, Any]:
    size = path.stat().st_size
    if size <= 0 or size > MAX_EVENT_FILE_BYTES:
        raise ContextHistoryError(f"History event file has an invalid size: {path}")
    raw = path.read_text(encoding="utf-8")
    lines = [line for line in raw.splitlines() if line.strip()]
    if len(lines) != 1:
        raise ContextHistoryError(f"Each history shard must contain exactly one JSON line: {path}")
    try:
        parsed = json.loads(lines[0])
    except json.JSONDecodeError as error:
        raise ContextHistoryError(f"History event contains invalid JSON: {path}") from error
    return validate_event(parsed)


def load_events(project_root: str | Path) -> list[dict[str, Any]]:
    root = resolve_project_root(project_root)
    by_id: dict[str, tuple[str, dict[str, Any]]] = {}
    for path in _event_files(root):
        event = _read_event_file(path)
        canonical = _canonical_json(event)
        previous = by_id.get(event["id"])
        if previous is not None and previous[0] != canonical:
            raise ContextHistoryError(f"Event {event['id']} has a conflicting duplicate and is immutable.")
        by_id[event["id"]] = (canonical, event)
        if len(by_id) > MAX_EVENTS:
            raise ContextHistoryError(f"History contains more than {MAX_EVENTS} events.")
    return sorted((item[1] for item in by_id.values()), key=lambda item: (item["occurredAt"], item["id"]))


def append_event(
    project_root: str | Path,
    project: str,
    kind: str,
    summary: str,
    *,
    occurred_at: str | None = None,
    refs: Iterable[str] = (),
    invalidates: Iterable[str] = (),
    next_action: str | None = None,
    public: dict[str, Any] | None = None,
    event_id: str | None = None,
) -> Path:
    root = resolve_project_root(project_root)
    snapshot = git_snapshot(root)
    timestamp = _utc_timestamp(occurred_at)
    identity = event_id or f"evt_{uuid.uuid4().hex}"
    payload: dict[str, Any] = {
        "schemaVersion": SCHEMA_VERSION,
        "id": identity,
        "occurredAt": timestamp,
        "project": project,
        "kind": kind,
        "summary": summary,
        **asdict(snapshot),
        "refs": list(refs),
        "invalidates": list(invalidates),
    }
    if next_action is not None:
        payload["nextAction"] = next_action
    if public is not None:
        payload["public"] = public
    normalized = validate_event(payload)
    canonical = _canonical_json(normalized)

    for existing_path in _event_files(root):
        existing = _read_event_file(existing_path)
        if existing["id"] != identity:
            continue
        if _canonical_json(existing) != canonical:
            raise ContextHistoryError(f"Event {identity} already exists with different content and is immutable.")
        return existing_path

    parsed_time = datetime.fromisoformat(timestamp.replace("Z", "+00:00"))
    directory = _history_root(root) / f"{parsed_time.year:04d}" / f"{parsed_time.month:02d}" / f"{parsed_time.day:02d}"
    directory.mkdir(parents=True, exist_ok=True)
    if any(parent.is_symlink() for parent in (directory, *directory.parents) if parent.is_relative_to(root)):
        raise ContextHistoryError("History directory cannot use symbolic links.")
    filename = f"{parsed_time.strftime('%Y%m%dT%H%M%S%fZ')}-{identity}.jsonl"
    target = directory / filename
    try:
        with target.open("x", encoding="utf-8", newline="\n") as handle:
            handle.write(canonical + "\n")
    except FileExistsError:
        existing = _read_event_file(target)
        if _canonical_json(existing) != canonical:
            raise ContextHistoryError(f"Event {identity} collided with different immutable content.")
    return target


def _cache_paths(root: Path) -> tuple[Path, Path]:
    cache = root / CACHE_RELATIVE
    return cache / "CONTEXT_HEAD.md", cache / "CONTEXT_HEAD.json"


def _write_atomic(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.{uuid.uuid4().hex}.tmp")
    temporary.write_text(content, encoding="utf-8", newline="\n")
    temporary.replace(path)


def _code_graph_context(root: Path, events: list[dict[str, Any]]) -> dict[str, Any]:
    """Build a bounded structural view around recent event references.

    The graph is derived and disposable. Failure to build it must not make the
    canonical event history unreadable, so expected local I/O/import failures
    degrade to an explicit unavailable state.
    """
    try:
        try:
            from tools.code_context_graph import build_graph
            from tools.context_capsule import build_capsule
        except ModuleNotFoundError:
            # Direct ``python tools/context_history.py`` execution places the
            # tools directory, rather than the repository root, on sys.path.
            from code_context_graph import build_graph
            from context_capsule import build_capsule

        graph = build_graph(root)
    except (ImportError, OSError, UnicodeError, ValueError, TypeError) as error:
        return {"status": "unavailable", "reason": type(error).__name__}

    referenced_paths: list[str] = []
    for event in reversed(events):
        for reference in event["refs"]:
            normalized = reference.replace("\\", "/")
            if normalized in graph["files"] and normalized not in referenced_paths:
                referenced_paths.append(normalized)
            if len(referenced_paths) >= MAX_GRAPH_SEEDS:
                break
        if len(referenced_paths) >= MAX_GRAPH_SEEDS:
            break

    capsule = build_capsule(
        graph,
        task=" ".join(referenced_paths),
        accepted_outcome="Resume from recent significant event references.",
        explicit_seeds=[f"file:{path}" for path in referenced_paths],
        max_items=MAX_GRAPH_NODES,
    ) if referenced_paths else {"evidence": [], "bounds": {"truncated": False}, "gaps": []}
    all_pointers = sorted(
        {
            str(item["path"])
            for item in capsule["evidence"]
            if item.get("path") and str(item["path"]) in graph["files"]
        }
    )
    pointers = all_pointers[:MAX_GRAPH_POINTERS]
    digest_payload = {
        "files": graph["files"],
        "nodes": graph["nodes"],
        "edges": graph["edges"],
    }
    return {
        "status": "ready",
        "schemaVersion": graph["schema_version"],
        "digest": sha256(_canonical_json(digest_payload).encode("utf-8")).hexdigest(),
        "fileCount": len(graph["files"]),
        "nodeCount": len(graph["nodes"]),
        "edgeCount": len(graph["edges"]),
        "seedRefs": referenced_paths,
        "queryNodeCount": len(capsule["evidence"]),
        "queryEdgeCount": sum(
            1 for item in capsule["evidence"] for reason in item["reasons"] if reason.startswith("graph_edge:")
        ),
        "relatedPointers": pointers,
        "truncated": bool(capsule["bounds"]["truncated"] or len(all_pointers) > MAX_GRAPH_POINTERS),
        "selectionReasonCount": sum(len(item["reasons"]) for item in capsule["evidence"]),
    }


def generate_context_head(
    project_root: str | Path,
    *,
    max_events: int = DEFAULT_HEAD_EVENTS,
    max_characters: int = DEFAULT_HEAD_CHARACTERS,
    write_cache: bool = True,
) -> ContextHeadResult:
    if not 1 <= max_events <= 100:
        raise ContextHistoryError("max_events must be between 1 and 100.")
    if not 1_000 <= max_characters <= 64_000:
        raise ContextHistoryError("max_characters must be between 1000 and 64000.")
    root = resolve_project_root(project_root)
    snapshot = git_snapshot(root)
    events = load_events(root)[-max_events:]
    code_graph = _code_graph_context(root, events)
    generated_at = _utc_timestamp()
    latest_next = next((event.get("nextAction") for event in reversed(events) if event.get("nextAction")), None)
    invalidations: list[str] = []
    for event in events:
        for item in event["invalidates"]:
            if item not in invalidations:
                invalidations.append(item)

    lines = [
        "# CONTEXT_HEAD",
        "",
        "> Generated projection. Git, specs, governed project files, and recorded proofs remain canonical.",
        "",
        "## Current worktree",
        "",
        f"- Generated: `{generated_at}`",
        f"- Branch: `{snapshot.branch}`",
        f"- HEAD: `{snapshot.head}`",
        f"- Worktree: `{snapshot.worktreeId}`",
        f"- Dirty entries: `{snapshot.dirtyCount}`",
        f"- Dirty fingerprint: `{snapshot.dirtyFingerprint}`",
        "",
        "## Recent significant events",
        "",
    ]
    if events:
        for event in reversed(events):
            lines.append(f"- `{event['occurredAt']}` · `{event['kind']}` · {event['summary']} · `{event['id']}`")
    else:
        lines.append("- No significant event has been recorded yet.")
    lines.extend(["", "## Code context", ""])
    if code_graph["status"] == "ready":
        lines.append(
            f"- Derived graph: `{code_graph['fileCount']}` files, `{code_graph['nodeCount']}` nodes, "
            f"`{code_graph['edgeCount']}` edges."
        )
        lines.append(
            f"- Recent-reference query: `{code_graph['queryNodeCount']}` nodes, "
            f"`{code_graph['queryEdgeCount']}` edges, truncated: `{str(code_graph['truncated']).lower()}`."
        )
        if code_graph["relatedPointers"]:
            lines.extend(f"- `{path}`" for path in code_graph["relatedPointers"])
        else:
            lines.append("- No recent event reference maps to a supported source file.")
    else:
        lines.append(f"- Derived graph unavailable (`{code_graph['reason']}`); use canonical targeted retrieval.")
    lines.extend(["", "## Invalidated context", ""])
    if invalidations:
        lines.extend(f"- {item}" for item in invalidations[-MAX_INVALIDATIONS:])
    else:
        lines.append("- No explicit invalidation is currently recorded.")
    lines.extend(["", "## Next action", "", latest_next or "Re-derive the next action from canonical project truth.", ""])
    markdown = "\n".join(lines)
    if len(markdown) > max_characters:
        suffix = "\n\n> Context Head truncated at the configured character budget.\n"
        markdown = markdown[: max_characters - len(suffix)].rstrip() + suffix

    markdown_path, metadata_path = _cache_paths(root)
    metadata = {
        "schemaVersion": CACHE_SCHEMA_VERSION,
        "generatedAt": generated_at,
        "git": asdict(snapshot),
        "eventIds": [event["id"] for event in events],
        "codeGraph": code_graph,
        "markdownSha256": sha256(markdown.encode("utf-8")).hexdigest(),
    }
    if write_cache:
        _write_atomic(markdown_path, markdown)
        _write_atomic(metadata_path, json.dumps(metadata, ensure_ascii=False, indent=2, sort_keys=True) + "\n")
    return ContextHeadResult(markdown, len(events), markdown_path, metadata_path)


def cache_status(project_root: str | Path) -> dict[str, Any]:
    root = resolve_project_root(project_root)
    current = asdict(git_snapshot(root))
    markdown_path, metadata_path = _cache_paths(root)
    if not markdown_path.is_file() or not metadata_path.is_file():
        return {"stale": True, "reason": "missing", "changed": sorted(current)}
    try:
        metadata = json.loads(metadata_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise ContextHistoryError("Context Head cache metadata is unreadable.") from error
    if metadata.get("schemaVersion") != CACHE_SCHEMA_VERSION or not isinstance(metadata.get("git"), dict):
        return {"stale": True, "reason": "schema", "changed": ["schemaVersion"]}
    changed = sorted(key for key, value in current.items() if metadata["git"].get(key) != value)
    digest = sha256(markdown_path.read_bytes()).hexdigest()
    if metadata.get("markdownSha256") != digest:
        changed.append("markdownSha256")
    return {"stale": bool(changed), "reason": "changed" if changed else "fresh", "changed": changed}


def _slugify(text: str) -> str:
    folded = unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode("ascii").lower()
    slug = re.sub(r"[^a-z0-9]+", "-", folded).strip("-")
    if len(slug) > MAX_UPDATE_SLUG_BODY:
        cut = slug[:MAX_UPDATE_SLUG_BODY]
        slug = (cut.rsplit("-", 1)[0] if "-" in cut else cut).strip("-")
    return slug


def update_entry_id(product: str, event: dict[str, Any]) -> str:
    """Deterministic readable id: ``<product>-<english title slug>``."""
    base = _slugify(event["public"]["title"]["en"])
    if not base:
        return f"{product}-{event['id'][4:12]}"
    if base == product or base.startswith(f"{product}-"):
        return base
    return f"{product}-{base}"


def has_update_copy(event: dict[str, Any]) -> bool:
    """True when the event's public object carries changelog copy (not only roadmap changes)."""
    return "category" in event.get("public", {})


def build_update_entry(
    event: dict[str, Any],
    product: str | Iterable[str],
    locale: str,
    entry_id: str,
    *,
    related_roadmap: Iterable[str] = (),
) -> dict[str, Any]:
    """Map one public context event to one draft update-entry contract object."""
    public = event["public"]
    kind, group = UPDATE_KIND_BY_CATEGORY[public["category"]]
    products = [product] if isinstance(product, str) else list(dict.fromkeys(product))
    entry: dict[str, Any] = {
        "id": entry_id,
        "title": public["title"][locale],
        "summary": public["summary"][locale],
        "publishedAt": event["occurredAt"][:10],
        "products": products,
        "locale": locale,
        "status": "draft",
        "kind": kind,
        "changes": [{"group": group, "items": [public["summary"][locale]]}],
    }
    link = public.get("link")
    if link is not None and UPDATE_HREF_RE.fullmatch(link):
        entry["cta"] = {"label": UPDATE_CTA_LABELS[locale], "href": link}
    related = list(dict.fromkeys(related_roadmap))
    if related:
        entry["relatedRoadmap"] = related
    entry["source"] = {"producer": "agent", "ref": event["id"]}
    return entry


def render_update_markdown(entry: dict[str, Any]) -> str:
    """Render the site Markdown file: path carries id and locale, the rest is frontmatter."""
    def quoted(value: str) -> str:
        return json.dumps(value, ensure_ascii=False)

    lines = [
        "---",
        f"title: {quoted(entry['title'])}",
        f"summary: {quoted(entry['summary'])}",
        f"publishedAt: {quoted(entry['publishedAt'])}",
        f"products: [{', '.join(quoted(item) for item in entry['products'])}]",
        f"status: {entry['status']}",
        f"kind: {entry['kind']}",
        "changes:",
    ]
    for change in entry["changes"]:
        lines.extend([f"  - group: {change['group']}", "    items:"])
        lines.extend(f"      - {quoted(item)}" for item in change["items"])
    if "cta" in entry:
        lines.append(f"cta: {{ label: {quoted(entry['cta']['label'])}, href: {quoted(entry['cta']['href'])} }}")
    if entry.get("relatedRoadmap"):
        lines.append(f"relatedRoadmap: [{', '.join(entry['relatedRoadmap'])}]")
    lines.append(f"source: {{ producer: {entry['source']['producer']}, ref: {quoted(entry['source']['ref'])} }}")
    lines.extend(["---", ""])
    return "\n".join(lines)


def site_declares_package(site: Path, package_name: str) -> bool:
    manifest = site / "package.json"
    try:
        package = json.loads(manifest.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise ContextHistoryError(f"Site package.json is unreadable: {manifest}") from error
    declared: set[str] = set()
    for section in ("dependencies", "devDependencies"):
        if isinstance(package.get(section), dict):
            declared.update(package[section])
    return package_name in declared


def _require_updates_package(site: Path) -> None:
    if not site_declares_package(site, UPDATES_PACKAGE):
        raise ContextHistoryError(f"Site does not declare {UPDATES_PACKAGE}; no update entry is projected.")


def _update_locales(site: Path, requested: Iterable[str]) -> tuple[list[str], list[str]]:
    locales = list(dict.fromkeys(requested))
    if not locales:
        manifest = site / CONTENT_MANIFEST
        if not manifest.is_file():
            raise ContextHistoryError(f"Site has no {CONTENT_MANIFEST}; pass --locale explicitly.")
        try:
            declared = json.loads(manifest.read_text(encoding="utf-8")).get("locales")
        except (OSError, json.JSONDecodeError, AttributeError) as error:
            raise ContextHistoryError(f"{CONTENT_MANIFEST} is unreadable.") from error
        if not isinstance(declared, list) or not all(isinstance(item, str) for item in declared):
            raise ContextHistoryError(f"{CONTENT_MANIFEST} must declare a locales array.")
        locales = list(dict.fromkeys(declared))
    supported = [locale for locale in locales if locale in PUBLIC_LOCALES]
    if not supported:
        raise ContextHistoryError("Public events only carry English and French copy; no site locale matches.")
    return supported, [locale for locale in locales if locale not in PUBLIC_LOCALES]


def _frontmatter_head(path: Path) -> str:
    with path.open("r", encoding="utf-8", errors="replace") as handle:
        text = handle.read(UPDATE_HEAD_BYTES)
    if not text.startswith("---"):
        return ""
    end = text.find("\n---", 3)
    return text[: end if end != -1 else len(text)]


def _updates_directory(site: Path, locale: str) -> Path:
    directory = site / UPDATES_RELATIVE / locale
    for parent in (directory, *directory.parents):
        if parent == site:
            break
        if parent.is_symlink():
            raise ContextHistoryError("The updates collection cannot use symbolic links.")
    return directory


def _projected_elsewhere(directory: Path, target: Path, event_id: str) -> Path | None:
    if not directory.is_dir():
        return None
    for index, candidate in enumerate(sorted(directory.glob("*.md"))):
        if index >= MAX_UPDATE_SCAN_FILES:
            raise ContextHistoryError(f"Updates collection exceeds {MAX_UPDATE_SCAN_FILES} files per locale.")
        if candidate != target and candidate.is_file() and event_id in _frontmatter_head(candidate):
            return candidate
    return None


def project_updates(
    project_root: str | Path,
    site_root: str | Path,
    product: str,
    *,
    event_ids: Iterable[str] = (),
    since: str | None = None,
    locales: Iterable[str] = (),
    dry_run: bool = False,
) -> dict[str, Any]:
    """Write one draft update entry per site locale for each selected public event.

    Never overwrites: an existing file is reported ``unchanged`` when identical,
    ``skipped-edited`` otherwise, and ``already-projected`` when another file of
    the locale already references the event id.
    """
    root = resolve_project_root(project_root)
    requested_ids = list(dict.fromkeys(event_ids))
    if not requested_ids and since is None:
        raise ContextHistoryError("Select events with --event-id or --since.")
    if len(product) > MAX_PRODUCT_KEY or not UPDATE_SLUG_RE.fullmatch(product):
        raise ContextHistoryError("product must be a lowercase slug of at most 40 characters.")
    if since is not None:
        try:
            date.fromisoformat(since)
        except ValueError as error:
            raise ContextHistoryError("since must be an ISO calendar date (YYYY-MM-DD).") from error
    site = Path(site_root).expanduser().resolve()
    if not site.is_dir():
        raise ContextHistoryError(f"Site root is unavailable: {site}")
    _require_updates_package(site)
    selected_locales, skipped_locales = _update_locales(site, locales)

    events = load_events(root)
    by_id = {event["id"]: event for event in events}
    chosen: list[dict[str, Any]] = []
    for event_id in requested_ids:
        if event_id not in by_id:
            raise ContextHistoryError(f"Unknown event id: {event_id}")
        chosen.append(by_id[event_id])
    if since is not None:
        chosen.extend(event for event in events if event["occurredAt"][:10] >= since and event not in chosen)

    entries: list[dict[str, str]] = []
    not_public: list[str] = []
    roadmap_only: list[str] = []
    for event in chosen:
        if "public" not in event:
            not_public.append(event["id"])
            continue
        if not has_update_copy(event):
            roadmap_only.append(event["id"])
            continue
        plan = plan_update_projection(site, event, product, selected_locales)
        entries.extend(write_update_projection(site, event, [product], plan, dry_run=dry_run))
    return {
        "dryRun": dry_run,
        "siteRoot": str(site),
        "entries": entries,
        "notPublic": not_public,
        "roadmapOnly": roadmap_only,
        "skippedLocales": skipped_locales,
    }


@dataclass(frozen=True)
class UpdatePlan:
    """Where one event's update entry lands in one locale, before anything is written."""

    locale: str
    entry_id: str
    target: Path
    elsewhere: Path | None

    @property
    def effective_id(self) -> str:
        """Id the site actually uses for this event in this locale (a renamed file keeps its name)."""
        return self.elsewhere.stem if self.elsewhere is not None else self.entry_id


def plan_update_projection(site: Path, event: dict[str, Any], product: str, locales: Iterable[str]) -> list[UpdatePlan]:
    """Choose the entry id (suffixed on a foreign collision) and detect earlier projections."""
    locales = list(locales)
    entry_id = update_entry_id(product, event)
    for locale in locales:
        existing = _updates_directory(site, locale) / f"{entry_id}.md"
        if existing.exists() and event["id"] not in _frontmatter_head(existing):
            entry_id = f"{entry_id}-{event['id'][4:12]}"
            break
    plans: list[UpdatePlan] = []
    for locale in locales:
        directory = _updates_directory(site, locale)
        target = directory / f"{entry_id}.md"
        plans.append(UpdatePlan(locale, entry_id, target, _projected_elsewhere(directory, target, event["id"])))
    return plans


def write_update_projection(
    site: Path,
    event: dict[str, Any],
    products: list[str],
    plans: list[UpdatePlan],
    *,
    related_roadmap: dict[str, list[str]] | None = None,
    dry_run: bool = False,
) -> list[dict[str, str]]:
    """Create missing draft files; never overwrite an existing or renamed one."""
    entries: list[dict[str, str]] = []
    for plan in plans:
        related = (related_roadmap or {}).get(plan.locale, [])
        content = render_update_markdown(
            build_update_entry(event, products, plan.locale, plan.entry_id, related_roadmap=related)
        )
        target = plan.target
        if plan.elsewhere is not None:
            action, path = "already-projected", plan.elsewhere
        elif target.exists():
            same = target.read_text(encoding="utf-8", errors="replace") == content
            action, path = ("unchanged" if same else "skipped-edited"), target
        elif dry_run:
            action, path = "would-create", target
        else:
            target.parent.mkdir(parents=True, exist_ok=True)
            _updates_directory(site, plan.locale)
            try:
                with target.open("x", encoding="utf-8", newline="\n") as handle:
                    handle.write(content)
                action = "created"
            except FileExistsError:
                action = "skipped-edited"
            path = target
        entries.append({
            "eventId": event["id"],
            "id": plan.entry_id,
            "locale": plan.locale,
            "action": action,
            "path": path.relative_to(site).as_posix(),
        })
    return entries


def _roadmap_from_args(values: Iterable[str]) -> list[dict[str, str]]:
    changes: list[dict[str, str]] = []
    for value in values:
        item_id, separator, status = value.rpartition(":")
        if not separator or not item_id or not status:
            raise ContextHistoryError("--roadmap expects <item id>:<status>, for example export-pdf:shipped.")
        changes.append({"id": item_id, "status": status})
    return changes


def _public_from_args(args: argparse.Namespace) -> dict[str, Any] | None:
    changelog_supplied = any(
        value is not None
        for value in (
            args.public_category,
            args.public_title_en,
            args.public_title_fr,
            args.public_summary_en,
            args.public_summary_fr,
            args.public_link,
        )
    )
    delivery_supplied = args.delivery_state is not None or args.delivery_proof is not None
    roadmap = _roadmap_from_args(args.roadmap)
    if args.public_file is not None:
        if changelog_supplied or delivery_supplied or roadmap:
            raise ContextHistoryError("--public-file replaces the --public-*, --delivery-* and --roadmap options.")
        try:
            loaded = json.loads(Path(args.public_file).read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as error:
            raise ContextHistoryError(f"--public-file is unreadable JSON: {args.public_file}") from error
        if not isinstance(loaded, dict):
            raise ContextHistoryError("--public-file must contain one JSON object.")
        return loaded
    public: dict[str, Any] = {}
    if changelog_supplied:
        public.update({
            "category": args.public_category,
            "title": {"en": args.public_title_en, "fr": args.public_title_fr},
            "summary": {"en": args.public_summary_en, "fr": args.public_summary_fr},
            **({"link": args.public_link} if args.public_link is not None else {}),
        })
    if changelog_supplied or delivery_supplied:
        public["delivery"] = {"state": args.delivery_state, "proof": args.delivery_proof}
    if roadmap:
        public["roadmap"] = roadmap
    return public or None


def _product_updates_module() -> Any:
    # Script execution runs this file as __main__: expose it under its module name
    # so product_updates shares the same classes (ContextHistoryError) instead of a copy.
    if __name__ == "__main__":
        sys.modules.setdefault("context_history", sys.modules[__name__])
    try:
        from tools import product_updates
    except ModuleNotFoundError:
        import product_updates  # type: ignore[no-redef]
    return product_updates


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project-root", default=".")
    commands = parser.add_subparsers(dest="command", required=True)

    append = commands.add_parser("append")
    append.add_argument("--project", required=True)
    append.add_argument("--kind", required=True, choices=sorted(KINDS))
    append.add_argument("--summary", required=True)
    append.add_argument("--occurred-at")
    append.add_argument("--event-id")
    append.add_argument("--ref", action="append", default=[])
    append.add_argument("--invalidate", action="append", default=[])
    append.add_argument("--next-action")
    append.add_argument("--public-category", choices=sorted(PUBLIC_CATEGORIES))
    append.add_argument("--public-title-en")
    append.add_argument("--public-title-fr")
    append.add_argument("--public-summary-en")
    append.add_argument("--public-summary-fr")
    append.add_argument("--delivery-state", choices=sorted(DELIVERY_STATES))
    append.add_argument("--delivery-proof")
    append.add_argument("--public-link")
    append.add_argument(
        "--roadmap", action="append", default=[], metavar="ID:STATUS",
        help="Roadmap item status change carried by public.roadmap (repeatable).",
    )
    append.add_argument("--public-file", help="JSON file holding the whole public object (creation copy included).")
    append.add_argument(
        "--no-project", action="store_true",
        help="Do not project the public object into the sites of .shipglows.product-updates.json.",
    )

    head = commands.add_parser("head")
    head.add_argument("--max-events", type=int, default=DEFAULT_HEAD_EVENTS)
    head.add_argument("--max-characters", type=int, default=DEFAULT_HEAD_CHARACTERS)
    head.add_argument("--print", action="store_true", dest="print_markdown")
    head.add_argument("--no-write", action="store_true")

    commands.add_parser("check")
    commands.add_parser("validate")

    updates = commands.add_parser(
        "project-updates",
        help="Write draft update entries (src/content/updates/<locale>/<id>.md) from public events.",
    )
    updates.add_argument("--site-root", required=True)
    updates.add_argument("--product", required=True)
    updates.add_argument("--event-id", action="append", default=[])
    updates.add_argument("--since")
    updates.add_argument("--locale", action="append", default=[])
    updates.add_argument("--dry-run", action="store_true")

    project = commands.add_parser(
        "project",
        help="Project public events into every site of .shipglows.product-updates.json (updates and roadmap).",
    )
    project.add_argument("--event-id", action="append", default=[])
    project.add_argument("--since")
    project.add_argument("--dry-run", action="store_true")

    pending = commands.add_parser("pending", help="List draft updates and hidden roadmap items awaiting review.")
    pending.add_argument("--format", choices=("json", "text"), default="json")

    publish = commands.add_parser(
        "publish", help="Publish reviewed drafts (status: published) and hidden items (visibility: public), all locales.",
    )
    publish.add_argument("--id", action="append", default=[], dest="ids")
    publish.add_argument("--all", action="store_true", dest="publish_all")
    publish.add_argument("--kind", choices=("update", "roadmap"))
    publish.add_argument("--dry-run", action="store_true")

    args = parser.parse_args()
    try:
        if args.command == "append":
            path = append_event(
                args.project_root,
                args.project,
                args.kind,
                args.summary,
                occurred_at=args.occurred_at,
                refs=args.ref,
                invalidates=args.invalidate,
                next_action=args.next_action,
                public=_public_from_args(args),
                event_id=args.event_id,
            )
            event = _read_event_file(path)
            output: dict[str, Any] = {"status": "ok", "eventPath": str(path), "eventId": event["id"]}
            if args.no_project:
                output["projection"] = {"status": "disabled"}
            else:
                output["projection"] = _product_updates_module().project_after_append(args.project_root, event)
        elif args.command == "project":
            output = {
                "status": "ok",
                **_product_updates_module().project_configured(
                    args.project_root, event_ids=args.event_id, since=args.since, dry_run=args.dry_run,
                ),
            }
        elif args.command == "pending":
            report = _product_updates_module().pending(args.project_root)
            if args.format == "text":
                print(_product_updates_module().render_pending_text(report))
                return 0
            output = {"status": "ok", **report}
        elif args.command == "publish":
            output = {
                "status": "ok",
                **_product_updates_module().publish(
                    args.project_root, ids=args.ids, publish_all=args.publish_all, kind=args.kind,
                    dry_run=args.dry_run,
                ),
            }
        elif args.command == "head":
            result = generate_context_head(
                args.project_root,
                max_events=args.max_events,
                max_characters=args.max_characters,
                write_cache=not args.no_write,
            )
            if args.print_markdown:
                print(result.markdown)
                return 0
            output = {
                "status": "ok",
                "eventCount": result.event_count,
                "markdownPath": str(result.markdown_path),
                "metadataPath": str(result.metadata_path),
            }
        elif args.command == "check":
            output = {"status": "ok", **cache_status(args.project_root)}
        elif args.command == "project-updates":
            output = {
                "status": "ok",
                **project_updates(
                    args.project_root,
                    args.site_root,
                    args.product,
                    event_ids=args.event_id,
                    since=args.since,
                    locales=args.locale,
                    dry_run=args.dry_run,
                ),
            }
        else:
            output = {"status": "ok", "eventCount": len(load_events(args.project_root))}
    except (ContextHistoryError, OSError, UnicodeError) as error:
        print(json.dumps({"status": "error", "error": str(error)}, ensure_ascii=False), file=sys.stderr)
        return 2
    print(json.dumps(output, ensure_ascii=False, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
