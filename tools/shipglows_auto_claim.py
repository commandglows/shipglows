#!/usr/bin/env python3
"""Coordinate ShipGlows auto conversations inside one captured Git root."""

from __future__ import annotations

import argparse
from contextlib import contextmanager
import hashlib
import json
import os
from pathlib import Path
import re
import stat
import subprocess
import sys
from typing import Iterator


class ClaimError(RuntimeError):
    """A safe, operator-readable claim failure."""

    def __init__(self, code: str, message: str) -> None:
        super().__init__(message)
        self.code = code


def _inside(root: Path, path: Path) -> bool:
    try:
        path.relative_to(root)
    except ValueError:
        return False
    return True


def resolve_git_root(start: str | Path) -> Path:
    start_path = Path(start).resolve(strict=True)
    result = subprocess.run(
        ["git", "-C", str(start_path), "rev-parse", "--show-toplevel"],
        check=False,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0 or not result.stdout.strip():
        raise ClaimError("unresolved_git_root", "the supplied path is not inside a Git worktree")
    return Path(result.stdout.strip()).resolve(strict=True)


def _resolve_scoped_path(root: Path, value: str, *, must_exist: bool) -> tuple[str, Path]:
    candidate = Path(value)
    if candidate.is_absolute():
        raise ClaimError("path_escape", f"absolute path is outside claim syntax: {value}")
    resolved = (root / candidate).resolve(strict=must_exist)
    if not _inside(root, resolved):
        raise ClaimError("path_escape", f"path resolves outside captured root: {value}")
    relative = resolved.relative_to(root).as_posix() or "."
    return relative, resolved


def _claim_key(work_item: str, slice_id: str) -> str:
    return hashlib.sha256(f"{work_item}\0{slice_id}".encode("utf-8")).hexdigest()[:24]


def _validate_component_tree(root: Path, storage: Path) -> None:
    current = root
    for part in storage.relative_to(root).parts:
        current = current / part
        if current.exists() and current.is_symlink():
            raise ClaimError("unsafe_claim_storage", f"claim storage component is a symlink: {current}")


def _claim_dirs(root: Path) -> tuple[Path, Path, Path]:
    base = root / ".shipglows-auto" / "claims"
    ignored = subprocess.run(
        ["git", "-C", str(root), "check-ignore", "-q", ".shipglows-auto/claims/probe"],
        check=False,
    )
    if ignored.returncode != 0:
        raise ClaimError("claim_storage_not_ignored", ".shipglows-auto must be ignored by this repository")
    _validate_component_tree(root, base)
    active = base / "active"
    completed = base / "completed"
    for directory in (active, completed):
        directory.mkdir(parents=True, exist_ok=True)
        if directory.is_symlink() or not _inside(root, directory.resolve(strict=True)):
            raise ClaimError("unsafe_claim_storage", "claim storage escaped the captured root")
    return base, active, completed


@contextmanager
def _exclusive_lock(lock_path: Path) -> Iterator[None]:
    lock_path.parent.mkdir(parents=True, exist_ok=True)
    flags = os.O_RDWR | os.O_CREAT
    if hasattr(os, "O_NOFOLLOW"):
        flags |= os.O_NOFOLLOW
    try:
        descriptor = os.open(lock_path, flags, 0o600)
    except OSError as exc:
        raise ClaimError("unsafe_claim_storage", f"cannot safely open claim lock: {exc}") from exc
    try:
        opened = os.fstat(descriptor)
        visible = lock_path.lstat()
        if (
            not stat.S_ISREG(opened.st_mode)
            or stat.S_ISLNK(visible.st_mode)
            or (opened.st_dev, opened.st_ino) != (visible.st_dev, visible.st_ino)
        ):
            raise ClaimError("unsafe_claim_storage", "claim lock is not a stable regular file")
    except BaseException:
        os.close(descriptor)
        raise
    with os.fdopen(descriptor, "r+b") as handle:
        handle.seek(0, os.SEEK_END)
        if handle.tell() == 0:
            handle.write(b"0")
            handle.flush()
        handle.seek(0)
        if os.name == "nt":
            import msvcrt

            msvcrt.locking(handle.fileno(), msvcrt.LK_LOCK, 1)
            try:
                yield
            finally:
                handle.seek(0)
                msvcrt.locking(handle.fileno(), msvcrt.LK_UNLCK, 1)
        else:
            import fcntl

            fcntl.flock(handle.fileno(), fcntl.LOCK_EX)
            try:
                yield
            finally:
                fcntl.flock(handle.fileno(), fcntl.LOCK_UN)


def _read_claim(path: Path) -> dict[str, object]:
    if path.is_symlink():
        raise ClaimError("unsafe_claim_storage", f"claim file is a symlink: {path}")
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise ClaimError("invalid_claim", f"cannot read claim {path.name}: {exc}") from exc
    if not isinstance(payload, dict):
        raise ClaimError("invalid_claim", f"claim is not an object: {path.name}")
    return payload


def _paths_overlap(left: str, right: str) -> bool:
    left_parts = Path(left).parts
    right_parts = Path(right).parts
    length = min(len(left_parts), len(right_parts))
    return left_parts[:length] == right_parts[:length]


def acquire_claim(
    root_value: str | Path,
    work_item_value: str,
    slice_id: str,
    owner: str,
    owned_values: list[str],
) -> dict[str, object]:
    root = resolve_git_root(root_value)
    work_item, _ = _resolve_scoped_path(root, work_item_value, must_exist=True)
    if not slice_id.strip() or len(slice_id) > 160 or "\n" in slice_id:
        raise ClaimError("invalid_slice", "slice must be a non-empty single-line identifier")
    if not owner.strip() or len(owner) > 160 or "\n" in owner:
        raise ClaimError("invalid_owner", "owner must be a non-empty single-line run identifier")
    if not owned_values:
        raise ClaimError("missing_owned_paths", "at least one owned path is required")
    owned_paths = sorted({_resolve_scoped_path(root, value, must_exist=False)[0] for value in owned_values})
    key = _claim_key(work_item, slice_id)
    base, active, completed = _claim_dirs(root)
    active_path = active / f"{key}.json"
    completed_path = completed / f"{key}.json"

    with _exclusive_lock(base / ".lock"):
        if completed_path.exists():
            raise ClaimError("already_completed", f"candidate already completed under claim {key}")
        if active_path.exists():
            raise ClaimError("already_claimed", f"candidate already has active claim {key}")
        for existing_path in active.glob("*.json"):
            existing = _read_claim(existing_path)
            existing_owned = existing.get("owned_paths", [])
            if not isinstance(existing_owned, list):
                raise ClaimError("invalid_claim", f"owned_paths is invalid in {existing_path.name}")
            if any(
                _paths_overlap(current, prior)
                for current in owned_paths
                for prior in existing_owned
                if isinstance(prior, str)
            ):
                raise ClaimError("path_conflict", f"owned paths overlap active claim {existing_path.stem}")

        payload: dict[str, object] = {
            "version": 1,
            "status": "active",
            "claim_key": key,
            "captured_git_root": str(root),
            "work_item": work_item,
            "slice": slice_id,
            "owner": owner,
            "owned_paths": owned_paths,
        }
        flags = os.O_WRONLY | os.O_CREAT | os.O_EXCL
        descriptor = os.open(active_path, flags, 0o600)
        with os.fdopen(descriptor, "w", encoding="utf-8") as handle:
            json.dump(payload, handle, ensure_ascii=False, sort_keys=True)
            handle.write("\n")
        return payload


def complete_claim(root_value: str | Path, key: str, owner: str) -> dict[str, object]:
    root = resolve_git_root(root_value)
    if re.fullmatch(r"[0-9a-f]{24}", key) is None:
        raise ClaimError("invalid_claim_key", "claim key must be exactly 24 lowercase hexadecimal characters")
    base, active, completed = _claim_dirs(root)
    active_path = active / f"{key}.json"
    completed_path = completed / f"{key}.json"
    with _exclusive_lock(base / ".lock"):
        if completed_path.exists():
            raise ClaimError("already_completed", f"claim is already completed: {key}")
        if not active_path.exists():
            raise ClaimError("claim_not_found", f"active claim does not exist: {key}")
        payload = _read_claim(active_path)
        if payload.get("owner") != owner:
            raise ClaimError("owner_mismatch", "only the owning auto run may complete this claim")
        payload["status"] = "completed"
        temporary = active / f".{key}.{os.getpid()}.json"
        flags = os.O_WRONLY | os.O_CREAT | os.O_EXCL
        descriptor = os.open(temporary, flags, 0o600)
        with os.fdopen(descriptor, "w", encoding="utf-8") as handle:
            json.dump(payload, handle, ensure_ascii=False, sort_keys=True)
            handle.write("\n")
        os.replace(temporary, active_path)
        os.rename(active_path, completed_path)
        return payload


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="command", required=True)
    claim = subparsers.add_parser("claim", help="atomically reserve a candidate and its paths")
    claim.add_argument("--root", required=True)
    claim.add_argument("--work-item", required=True)
    claim.add_argument("--slice", required=True)
    claim.add_argument("--owner", required=True)
    claim.add_argument("--path", action="append", required=True, dest="paths")
    complete = subparsers.add_parser("complete", help="move an owned active claim to completed")
    complete.add_argument("--root", required=True)
    complete.add_argument("--claim-key", required=True)
    complete.add_argument("--owner", required=True)
    return parser


def main(argv: list[str] | None = None) -> int:
    args = _parser().parse_args(argv)
    try:
        if args.command == "claim":
            payload = acquire_claim(args.root, args.work_item, args.slice, args.owner, args.paths)
        else:
            payload = complete_claim(args.root, args.claim_key, args.owner)
    except ClaimError as exc:
        print(json.dumps({"status": "blocked", "error": exc.code, "message": str(exc)}))
        return 2
    print(json.dumps({"status": "ok", "claim": payload}, ensure_ascii=False, sort_keys=True))
    return 0


if __name__ == "__main__":
    sys.exit(main())
