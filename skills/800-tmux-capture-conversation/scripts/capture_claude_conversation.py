#!/usr/bin/env python3
"""Export visible user/assistant messages from one exact Claude Code session journal."""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import uuid
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path

from capture_codex_conversation import (
    CaptureError,
    iter_jsonl,
    parse_timestamp,
    resolve_git_root,
    write_exclusive,
)


SCHEMA_ERROR = "unsupported or malformed Claude Code session journal"

# Harness-injected blocks inside user messages are context, not operator speech.
INJECTED_BLOCK_RE = re.compile(
    r"<(system-reminder|command-message|command-args|local-command-stdout|local-command-caveat)>.*?</\1>",
    re.DOTALL,
)


@dataclass(frozen=True)
class SessionMeta:
    session_id: str
    cwd: Path
    started_at: datetime


@dataclass
class Message:
    role: str
    text: str
    message_id: str | None = None


def canonical_session_id(value: str) -> str:
    try:
        canonical = str(uuid.UUID(value))
    except (ValueError, AttributeError) as exc:
        raise CaptureError("CLAUDE_CODE_SESSION_ID must be a canonical UUID") from exc
    if value.lower() != canonical:
        raise CaptureError("CLAUDE_CODE_SESSION_ID must be a canonical UUID")
    return canonical


def resolve_claude_home(explicit: Path | None = None) -> Path:
    if explicit is not None:
        return explicit.expanduser().resolve()
    configured = os.environ.get("CLAUDE_CONFIG_DIR")
    if configured:
        return Path(configured).expanduser().resolve()
    return (Path.home() / ".claude").resolve()


def find_journal(claude_home: Path, session_id: str) -> Path:
    projects = claude_home / "projects"
    if not projects.is_dir():
        raise CaptureError(f"Claude Code projects directory not found: {projects}")
    # Top-level session journals only; subagent sidechains live in subfolders.
    matches = sorted(
        path.resolve()
        for path in projects.glob(f"*/{session_id}.jsonl")
        if path.is_file() and not path.is_symlink()
    )
    if len(matches) != 1:
        raise CaptureError(
            f"expected exactly one Claude Code journal for session {session_id}; found {len(matches)}"
        )
    return matches[0]


def visible_text(content: object) -> str:
    if isinstance(content, str):
        return content
    if not isinstance(content, list):
        raise CaptureError(f"{SCHEMA_ERROR}: message content is neither text nor a block list")
    # tool_use, tool_result, thinking and images are execution detail.
    return "\n".join(
        block["text"]
        for block in content
        if isinstance(block, dict) and block.get("type") == "text" and isinstance(block.get("text"), str)
    )


def parse_journal(path: Path, expected_session_id: str) -> tuple[SessionMeta, list[Message]]:
    meta: SessionMeta | None = None
    messages: list[Message] = []

    for record in iter_jsonl(path):
        role = record.get("type")
        if role not in ("user", "assistant"):
            continue
        if record.get("sessionId") != expected_session_id:
            raise CaptureError(f"{SCHEMA_ERROR}: session id does not match CLAUDE_CODE_SESSION_ID")
        if meta is None:
            cwd = record.get("cwd")
            if not isinstance(cwd, str) or not cwd:
                raise CaptureError(f"{SCHEMA_ERROR}: session cwd is missing")
            meta = SessionMeta(expected_session_id, Path(cwd), parse_timestamp(record.get("timestamp")))
        if record.get("isSidechain") or record.get("isMeta"):
            continue
        message = record.get("message")
        if not isinstance(message, dict):
            raise CaptureError(f"{SCHEMA_ERROR}: message payload is missing")
        text = INJECTED_BLOCK_RE.sub("", visible_text(message.get("content"))).strip()
        if not text:
            continue
        # One assistant API message is journaled as one line per content block.
        message_id = message.get("id") if role == "assistant" else None
        if message_id and messages and messages[-1].message_id == message_id:
            messages[-1].text += "\n\n" + text
            continue
        messages.append(Message(role, text, message_id))

    if meta is None:
        raise CaptureError(f"{SCHEMA_ERROR}: no user or assistant record found")
    if not messages:
        raise CaptureError("the Claude Code journal contains no visible user or assistant messages")
    return meta, messages


def base_filename(meta: SessionMeta) -> str:
    stamp = meta.started_at.strftime("%Y%m%d-%H%M%S")
    return f"conversation-claude-{stamp}-{meta.session_id[:8]}.md"


def render_transcript(meta: SessionMeta, messages: list[Message]) -> str:
    stamp = meta.started_at.strftime("%Y-%m-%d %H:%M:%S UTC")
    chunks = [
        f"# Conversation Claude Code — {stamp}\n\n",
        f"Session: `{meta.session_id}`\n\n",
    ]
    for message in messages:
        label = "Utilisateur" if message.role == "user" else "Assistant"
        chunks.extend((f"## {label}\n\n", message.text, "\n\n"))
    return "".join(chunks)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", action="store_true", help="Resolve and validate without writing")
    parser.add_argument("--session-id", help="Exact session UUID; defaults to CLAUDE_CODE_SESSION_ID")
    parser.add_argument("--claude-home", type=Path, help="Claude config directory override for fixtures")
    return parser


def run(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    raw_session_id = args.session_id or os.environ.get("CLAUDE_CODE_SESSION_ID")
    if not raw_session_id:
        raise CaptureError("CLAUDE_CODE_SESSION_ID is not available in this Claude Code session")
    session_id = canonical_session_id(raw_session_id)
    journal = find_journal(resolve_claude_home(args.claude_home), session_id)
    meta, messages = parse_journal(journal, session_id)
    root = resolve_git_root(meta.cwd)
    output_dir = root / "shipglows_data" / "workflow" / "conversations"
    filename = base_filename(meta)

    if args.dry_run:
        print("Capture mode: claude-session-journal")
        print(f"Project root: {root}")
        print(f"Destination directory: {output_dir}")
        print(f"Messages: {len(messages)}")
        print("Write: no (dry run)")
        return 0

    destination = write_exclusive(output_dir, filename, render_transcript(meta, messages))
    print(f"Conversation captured: {destination}")
    return 0


def main() -> int:
    try:
        return run()
    except CaptureError as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
