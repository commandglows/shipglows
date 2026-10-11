#!/usr/bin/env python3
"""Export one exact Kilo session into its owning Git repository."""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path


SESSION_ID_PATTERN = re.compile(r"^ses_[A-Za-z0-9]{8,128}$")
MAX_EXPORT_BYTES = 256 * 1024 * 1024
EXPORT_TIMEOUT_SECONDS = 120


class CaptureError(RuntimeError):
    """An expected, content-safe capture failure."""


@dataclass(frozen=True)
class Message:
    role: str
    text: str


def canonical_session_id(value: str) -> str:
    if not SESSION_ID_PATTERN.fullmatch(value):
        raise CaptureError("Kilo session id is missing or invalid")
    return value


def resolved_directory(value: str, label: str) -> Path:
    if not value or "\x00" in value:
        raise CaptureError(f"{label} is missing or invalid")
    path = Path(value).expanduser().resolve()
    if not path.is_dir():
        raise CaptureError(f"{label} does not exist")
    return path


def resolve_git_root(directory: Path) -> Path:
    result = subprocess.run(
        ["git", "-C", str(directory), "rev-parse", "--show-toplevel"],
        check=False,
        capture_output=True,
        text=True,
        encoding="utf-8",
    )
    if result.returncode != 0 or not result.stdout.strip():
        raise CaptureError("Kilo worktree is not inside a Git repository")
    root = Path(result.stdout.strip()).resolve()
    if not root.is_dir():
        raise CaptureError("Git returned an invalid Kilo project root")
    return root


def run_kilo_export(command: str, session_id: str) -> dict:
    resolved_command = shutil.which(command)
    if not resolved_command:
        raise CaptureError("Kilo CLI is not available")
    invocation = [resolved_command, "export", session_id]
    if os.name == "nt" and Path(resolved_command).suffix.lower() in {".cmd", ".bat"}:
        command_processor = os.environ.get("COMSPEC") or shutil.which("cmd.exe")
        if not command_processor:
            raise CaptureError("Windows command processor is not available")
        invocation = [command_processor, "/d", "/s", "/c", subprocess.list2cmdline(invocation)]
    with tempfile.TemporaryDirectory(prefix="shipglows-kilo-export-") as temporary:
        stdout_path = Path(temporary) / "export.json"
        stderr_path = Path(temporary) / "export.stderr"
        with stdout_path.open("wb") as stdout, stderr_path.open("wb") as stderr:
            try:
                process = subprocess.Popen(invocation, stdout=stdout, stderr=stderr)
            except OSError as exc:
                raise CaptureError("Kilo export could not start") from exc
            try:
                process.wait(timeout=EXPORT_TIMEOUT_SECONDS)
            except subprocess.TimeoutExpired as exc:
                process.kill()
                process.wait()
                raise CaptureError("Kilo export timed out") from exc
        if process.returncode != 0:
            raise CaptureError("Kilo export failed")
        if stdout_path.stat().st_size > MAX_EXPORT_BYTES:
            raise CaptureError("Kilo export exceeds the supported size limit")
        try:
            with stdout_path.open("r", encoding="utf-8") as stream:
                payload = json.load(stream)
        except (UnicodeDecodeError, json.JSONDecodeError) as exc:
            raise CaptureError("Kilo export returned malformed JSON") from exc
    if not isinstance(payload, dict):
        raise CaptureError("Kilo export has an unsupported root schema")
    return payload


def parse_created(value: object) -> datetime:
    if not isinstance(value, int) or isinstance(value, bool) or value < 0:
        raise CaptureError("Kilo export has an invalid creation timestamp")
    try:
        return datetime.fromtimestamp(value / 1000, tz=timezone.utc)
    except (OverflowError, OSError, ValueError) as exc:
        raise CaptureError("Kilo export has an invalid creation timestamp") from exc


def parse_export(payload: dict, session_id: str) -> tuple[Path, datetime, list[Message]]:
    info = payload.get("info")
    raw_messages = payload.get("messages")
    if not isinstance(info, dict) or not isinstance(raw_messages, list):
        raise CaptureError("Kilo export has an unsupported session schema")
    if info.get("id") != session_id:
        raise CaptureError("Kilo export session does not match the active session")
    export_directory = info.get("directory")
    if not isinstance(export_directory, str):
        raise CaptureError("Kilo export directory is missing")
    time = info.get("time")
    if not isinstance(time, dict):
        raise CaptureError("Kilo export timestamp is missing")
    created_at = parse_created(time.get("created"))

    messages: list[Message] = []
    for raw_message in raw_messages:
        if not isinstance(raw_message, dict):
            raise CaptureError("Kilo export contains a malformed message")
        message_info = raw_message.get("info")
        parts = raw_message.get("parts")
        if not isinstance(message_info, dict) or not isinstance(parts, list):
            raise CaptureError("Kilo export contains a malformed message")
        role = message_info.get("role")
        if role not in {"user", "assistant"}:
            continue
        texts: list[str] = []
        for part in parts:
            if not isinstance(part, dict):
                raise CaptureError("Kilo export contains a malformed message part")
            if part.get("type") != "text" or part.get("synthetic") is True:
                continue
            text = part.get("text")
            if not isinstance(text, str):
                raise CaptureError("Kilo visible text is malformed")
            texts.append(text)
        if texts:
            messages.append(Message(role=role, text="".join(texts)))
    if not messages:
        raise CaptureError("Kilo session contains no visible user or assistant text")
    return Path(export_directory).expanduser().resolve(), created_at, messages


def validate_binding(export_directory: Path, directory: Path, worktree: Path) -> Path:
    root = resolve_git_root(worktree)
    for candidate, label in ((directory, "active Kilo directory"), (export_directory, "export directory")):
        try:
            candidate.relative_to(root)
        except ValueError as exc:
            raise CaptureError(f"{label} is outside the active Kilo worktree") from exc
    return root


def render_transcript(session_id: str, created_at: datetime, messages: list[Message]) -> str:
    stamp = created_at.strftime("%Y-%m-%d %H:%M:%S UTC")
    chunks = [f"# Conversation KiloCode — {stamp}\n\n", f"Session: `{session_id}`\n\n"]
    for message in messages:
        label = "Utilisateur" if message.role == "user" else "Assistant"
        chunks.extend((f"## {label}\n\n", message.text, "\n\n"))
    return "".join(chunks)


def write_exclusive(directory: Path, filename: str, content: str) -> Path:
    directory.mkdir(parents=True, exist_ok=True)
    stem = Path(filename).stem
    suffix = Path(filename).suffix
    index = 1
    while True:
        candidate = directory / (filename if index == 1 else f"{stem}-{index}{suffix}")
        try:
            descriptor = os.open(candidate, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
        except FileExistsError:
            index += 1
            continue
        with os.fdopen(descriptor, "w", encoding="utf-8", newline="") as stream:
            stream.write(content)
        return candidate


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--session-id", required=True)
    parser.add_argument("--directory", required=True)
    parser.add_argument("--worktree", required=True)
    parser.add_argument("--kilo-command", default=os.environ.get("KILO_COMMAND", "kilo"))
    parser.add_argument("--export-file", type=Path, help=argparse.SUPPRESS)
    parser.add_argument("--dry-run", action="store_true")
    return parser


def run(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    session_id = canonical_session_id(args.session_id)
    directory = resolved_directory(args.directory, "active Kilo directory")
    worktree = resolved_directory(args.worktree, "active Kilo worktree")
    if args.export_file:
        try:
            payload = json.loads(args.export_file.read_text(encoding="utf-8"))
        except (OSError, UnicodeDecodeError, json.JSONDecodeError) as exc:
            raise CaptureError("Kilo fixture export is unreadable") from exc
    else:
        payload = run_kilo_export(args.kilo_command, session_id)
    export_directory, created_at, messages = parse_export(payload, session_id)
    root = validate_binding(export_directory, directory, worktree)
    output_dir = root / "shipglows_data" / "workflow" / "conversations"
    filename = f"conversation-kilocode-{created_at:%Y%m%d-%H%M%S}-{session_id[4:12]}.md"
    if args.dry_run:
        print("Capture mode: kilocode-official-export")
        print(f"Project root: {root}")
        print(f"Destination directory: {output_dir}")
        print(f"Messages: {len(messages)}")
        print("Write: no (dry run)")
        return 0
    destination = write_exclusive(output_dir, filename, render_transcript(session_id, created_at, messages))
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
