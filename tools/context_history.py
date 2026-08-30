#!/usr/bin/env python3
"""Append collision-free ShipGlows context events and build a bounded Context Head."""

from __future__ import annotations

from dataclasses import asdict, dataclass
from datetime import datetime, timezone
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
import uuid


SCHEMA_VERSION = "shipglows.context-event/v1"
CACHE_SCHEMA_VERSION = "shipglows.context-head-cache/v1"
HISTORY_RELATIVE = Path("shipglows_data/workflow/history")
CACHE_RELATIVE = Path(".shipglows")
MAX_EVENT_FILE_BYTES = 64 * 1024
MAX_FILES = 5_000
MAX_EVENTS = 5_000
DEFAULT_HEAD_EVENTS = 30
DEFAULT_HEAD_CHARACTERS = 16_000
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


def _validate_public(value: Any) -> dict[str, Any]:
    if not isinstance(value, dict):
        raise ContextHistoryError("public must be an object.")
    allowed = {"category", "title", "summary", "delivery", "link"}
    if set(value) - allowed:
        raise ContextHistoryError("public contains unsupported fields.")
    category = value.get("category")
    if category not in PUBLIC_CATEGORIES:
        raise ContextHistoryError("public.category is not a canonical changelog code.")
    title = value.get("title")
    summary = value.get("summary")
    if not isinstance(title, dict) or set(title) != {"en", "fr"}:
        raise ContextHistoryError("public.title must contain English and French values.")
    if not isinstance(summary, dict) or set(summary) != {"en", "fr"}:
        raise ContextHistoryError("public.summary must contain English and French values.")
    normalized_title = {
        "en": _bounded_string(title["en"], "public.title.en", 1, 120),
        "fr": _bounded_string(title["fr"], "public.title.fr", 1, 120),
    }
    normalized_summary = {
        "en": _bounded_string(summary["en"], "public.summary.en", 1, 400),
        "fr": _bounded_string(summary["fr"], "public.summary.fr", 1, 400),
    }
    delivery = value.get("delivery")
    if not isinstance(delivery, dict) or set(delivery) != {"state", "proof"}:
        raise ContextHistoryError("public.delivery must contain state and proof.")
    if delivery.get("state") not in DELIVERY_STATES:
        raise ContextHistoryError("public.delivery.state is not a canonical delivery code.")
    proof = _bounded_string(delivery.get("proof"), "public.delivery.proof", 1, 200)
    public_text = (*normalized_title.values(), *normalized_summary.values(), proof)
    if _contains_secret_like_text(public_text):
        raise ContextHistoryError("Public changelog copy contains secret-like text.")
    normalized: dict[str, Any] = {
        "category": category,
        "title": normalized_title,
        "summary": normalized_summary,
        "delivery": {"state": delivery["state"], "proof": proof},
    }
    if value.get("link") is not None:
        normalized["link"] = _safe_link(value["link"])
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


def _public_from_args(args: argparse.Namespace) -> dict[str, Any] | None:
    supplied = any(
        value is not None
        for value in (
            args.public_category,
            args.public_title_en,
            args.public_title_fr,
            args.public_summary_en,
            args.public_summary_fr,
            args.delivery_state,
            args.delivery_proof,
            args.public_link,
        )
    )
    if not supplied:
        return None
    return {
        "category": args.public_category,
        "title": {"en": args.public_title_en, "fr": args.public_title_fr},
        "summary": {"en": args.public_summary_en, "fr": args.public_summary_fr},
        "delivery": {"state": args.delivery_state, "proof": args.delivery_proof},
        **({"link": args.public_link} if args.public_link is not None else {}),
    }


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

    head = commands.add_parser("head")
    head.add_argument("--max-events", type=int, default=DEFAULT_HEAD_EVENTS)
    head.add_argument("--max-characters", type=int, default=DEFAULT_HEAD_CHARACTERS)
    head.add_argument("--print", action="store_true", dest="print_markdown")
    head.add_argument("--no-write", action="store_true")

    commands.add_parser("check")
    commands.add_parser("validate")

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
            output: dict[str, Any] = {"status": "ok", "eventPath": str(path), "eventId": _read_event_file(path)["id"]}
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
        else:
            output = {"status": "ok", "eventCount": len(load_events(args.project_root))}
    except (ContextHistoryError, OSError, UnicodeError) as error:
        print(json.dumps({"status": "error", "error": str(error)}, ensure_ascii=False), file=sys.stderr)
        return 2
    print(json.dumps(output, ensure_ascii=False, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
