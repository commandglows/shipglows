#!/usr/bin/env python3
"""Export visible user/assistant messages from one exact Codex session journal."""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import uuid
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Iterable


SCHEMA_ERROR = "unsupported or malformed Codex session journal"
ROLE_CONTENT_TYPES = {"user": "input_text", "assistant": "output_text"}


class CaptureError(RuntimeError):
    """An expected, safe capture failure."""


@dataclass(frozen=True)
class SessionMeta:
    thread_id: str
    cwd: Path
    started_at: datetime


@dataclass(frozen=True)
class Message:
    role: str
    text: str


def canonical_thread_id(value: str) -> str:
    try:
        parsed = uuid.UUID(value)
    except (ValueError, AttributeError) as exc:
        raise CaptureError("CODEX_THREAD_ID must be a canonical UUID") from exc
    canonical = str(parsed)
    if value.lower() != canonical:
        raise CaptureError("CODEX_THREAD_ID must be a canonical UUID")
    return canonical


def resolve_codex_home(explicit: Path | None = None) -> Path:
    if explicit is not None:
        return explicit.expanduser().resolve()
    configured = os.environ.get("CODEX_HOME")
    if configured:
        return Path(configured).expanduser().resolve()
    return (Path.home() / ".codex").resolve()


def find_journal(codex_home: Path, thread_id: str) -> Path:
    sessions = codex_home / "sessions"
    if not sessions.is_dir():
        raise CaptureError(f"Codex sessions directory not found: {sessions}")
    sessions_root = sessions.resolve()
    matches: list[Path] = []
    for path in sessions.rglob(f"*{thread_id}*.jsonl"):
        if not path.is_file() or path.is_symlink():
            continue
        resolved = path.resolve()
        try:
            resolved.relative_to(sessions_root)
        except ValueError as exc:
            raise CaptureError("Codex journal resolves outside the sessions directory") from exc
        matches.append(resolved)
    matches.sort()
    if len(matches) != 1:
        raise CaptureError(
            f"expected exactly one Codex journal for thread {thread_id}; found {len(matches)}"
        )
    return matches[0]


def iter_jsonl(path: Path) -> Iterable[dict]:
    with path.open("rb") as stream:
        for line_number, raw_line in enumerate(stream, start=1):
            terminated = raw_line.endswith(b"\n")
            candidate = raw_line[:-1] if terminated else raw_line
            if candidate.endswith(b"\r"):
                candidate = candidate[:-1]
            try:
                text = candidate.decode("utf-8")
                record = json.loads(text)
            except (UnicodeDecodeError, json.JSONDecodeError) as exc:
                if not terminated:
                    return
                raise CaptureError(f"{SCHEMA_ERROR} at complete line {line_number}") from exc
            if not isinstance(record, dict):
                raise CaptureError(f"{SCHEMA_ERROR} at line {line_number}")
            yield record


def parse_timestamp(value: object) -> datetime:
    if not isinstance(value, str):
        raise CaptureError(f"{SCHEMA_ERROR}: session timestamp is missing")
    try:
        parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError as exc:
        raise CaptureError(f"{SCHEMA_ERROR}: invalid session timestamp") from exc
    if parsed.tzinfo is None:
        raise CaptureError(f"{SCHEMA_ERROR}: session timestamp has no timezone")
    return parsed.astimezone(timezone.utc)


def parse_journal(path: Path, expected_thread_id: str) -> tuple[SessionMeta, list[Message]]:
    meta: SessionMeta | None = None
    messages: list[Message] = []
    seen_message_ids: set[str] = set()

    for record in iter_jsonl(path):
        record_type = record.get("type")
        payload = record.get("payload")
        if not isinstance(payload, dict):
            continue
        if record_type == "session_meta":
            if meta is not None:
                raise CaptureError(f"{SCHEMA_ERROR}: duplicate session metadata")
            session_id = payload.get("session_id") or payload.get("id")
            if session_id != expected_thread_id:
                raise CaptureError(f"{SCHEMA_ERROR}: session id does not match CODEX_THREAD_ID")
            cwd = payload.get("cwd")
            if not isinstance(cwd, str) or not cwd:
                raise CaptureError(f"{SCHEMA_ERROR}: session cwd is missing")
            meta = SessionMeta(expected_thread_id, Path(cwd), parse_timestamp(payload.get("timestamp")))
            continue

        if record_type != "response_item" or payload.get("type") != "message":
            continue
        role = payload.get("role")
        if role not in ROLE_CONTENT_TYPES:
            continue
        message_id = payload.get("id")
        if not isinstance(message_id, str) or not message_id:
            raise CaptureError(f"{SCHEMA_ERROR}: visible message id is missing")
        if message_id in seen_message_ids:
            continue
        content = payload.get("content")
        if not isinstance(content, list):
            raise CaptureError(f"{SCHEMA_ERROR}: visible message content is not a list")
        expected_type = ROLE_CONTENT_TYPES[role]
        parts: list[str] = []
        for item in content:
            if not isinstance(item, dict) or item.get("type") != expected_type:
                raise CaptureError(f"{SCHEMA_ERROR}: unsupported visible message content")
            value = item.get("text")
            if not isinstance(value, str):
                raise CaptureError(f"{SCHEMA_ERROR}: visible message text is missing")
            parts.append(value)
        seen_message_ids.add(message_id)
        messages.append(Message(role, "".join(parts)))

    if meta is None:
        raise CaptureError(f"{SCHEMA_ERROR}: session metadata not found")
    if not messages:
        raise CaptureError("the Codex journal contains no visible user or assistant messages")
    return meta, messages


def resolve_git_root(cwd: Path) -> Path:
    if not cwd.is_dir():
        raise CaptureError(f"session project directory does not exist: {cwd}")
    result = subprocess.run(
        ["git", "-C", str(cwd), "rev-parse", "--show-toplevel"],
        check=False,
        capture_output=True,
        text=True,
        encoding="utf-8",
    )
    if result.returncode != 0 or not result.stdout.strip():
        raise CaptureError(f"session directory is not inside a Git repository: {cwd}")
    root = Path(result.stdout.strip()).resolve()
    if not root.is_dir():
        raise CaptureError("Git returned an invalid project root")
    return root


def base_filename(meta: SessionMeta) -> str:
    stamp = meta.started_at.strftime("%Y%m%d-%H%M%S")
    return f"conversation-codex-{stamp}-{meta.thread_id[:8]}.md"


def render_transcript(meta: SessionMeta, messages: list[Message]) -> str:
    stamp = meta.started_at.strftime("%Y-%m-%d %H:%M:%S UTC")
    chunks = [
        f"# Conversation Codex — {stamp}\n\n",
        f"Session: `{meta.thread_id}`\n\n",
    ]
    for message in messages:
        label = "Utilisateur" if message.role == "user" else "Assistant"
        chunks.extend((f"## {label}\n\n", message.text, "\n\n"))
    return "".join(chunks)


def available_path(directory: Path, filename: str) -> Path:
    candidate = directory / filename
    if not candidate.exists():
        return candidate
    stem = candidate.stem
    suffix = candidate.suffix
    index = 2
    while True:
        numbered = directory / f"{stem}-{index}{suffix}"
        if not numbered.exists():
            return numbered
        index += 1


def write_exclusive(directory: Path, filename: str, content: str) -> Path:
    directory.mkdir(parents=True, exist_ok=True)
    while True:
        destination = available_path(directory, filename)
        try:
            descriptor = os.open(destination, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
        except FileExistsError:
            continue
        with os.fdopen(descriptor, "w", encoding="utf-8", newline="") as stream:
            stream.write(content)
        return destination


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", action="store_true", help="Resolve and validate without writing")
    parser.add_argument("--thread-id", help="Exact thread UUID; defaults to CODEX_THREAD_ID")
    parser.add_argument("--codex-home", type=Path, help="Codex home override for fixtures")
    return parser


def run(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    raw_thread_id = args.thread_id or os.environ.get("CODEX_THREAD_ID")
    if not raw_thread_id:
        raise CaptureError("CODEX_THREAD_ID is not available in this Codex session")
    thread_id = canonical_thread_id(raw_thread_id)
    journal = find_journal(resolve_codex_home(args.codex_home), thread_id)
    meta, messages = parse_journal(journal, thread_id)
    root = resolve_git_root(meta.cwd)
    output_dir = root / "shipglows_data" / "workflow" / "conversations"
    filename = base_filename(meta)

    if args.dry_run:
        print("Capture mode: codex-session-journal")
        print(f"Project root: {root}")
        print(f"Destination directory: {output_dir}")
        print(f"Messages: {len(messages)}")
        print("Write: no (dry run)")
        return 0

    destination = write_exclusive(output_dir, filename, render_transcript(meta, messages))
    print(f"Conversation captured: {destination}")
    print(f"Open with Neovim: nvim {destination}")
    return 0


def main() -> int:
    try:
        return run()
    except CaptureError as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
