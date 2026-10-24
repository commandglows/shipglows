#!/usr/bin/env python3
"""Read, update, and resolve the ShipGlows default execution profile.

The profile records which local workloads an agent may run by default:
builds, tests (lint, analyze, type check, tests), dev servers and browser
proof, commits, and CI as a proof destination. Precedence, highest first:
explicit invocation tags, mode defaults, project profile, user profile,
built-in defaults.
"""
from __future__ import annotations

import argparse
import json
import os
import sys
import tempfile
from pathlib import Path

AXES = ("build", "test", "server", "commit", "ci")
VALUES = ("allow", "deny")
BUILTIN = {"build": "deny", "test": "allow", "server": "allow", "commit": "allow", "ci": "deny"}
PROJECT_RELATIVE = Path("shipglows_data") / "execution-profile.json"
# Mode defaults sit between explicit tags and saved profiles.
MODE_DEFAULTS = {
    "auto": {"test": "allow", "server": "allow", "commit": "allow"},
    "blitz": {"build": "deny", "test": "deny", "server": "deny", "commit": "deny"},
}
# Tags that set one axis; #nolocal and #local are presets.
TAG_EFFECTS = {
    "build": {"build": "allow"}, "nobuild": {"build": "deny"},
    "test": {"test": "allow"}, "notest": {"test": "deny"},
    "server": {"server": "allow"}, "noserver": {"server": "deny"},
    "commit": {"commit": "allow"}, "nocommit": {"commit": "deny"},
    "ci": {"ci": "allow", "build": "deny", "test": "deny", "server": "deny", "commit": "deny"},
    "noci": {"ci": "deny"},
    "nolocal": {"build": "deny", "test": "deny", "server": "deny", "commit": "deny"},
    "local": {"test": "allow", "server": "allow", "commit": "allow"},
}


class ProfileError(Exception):
    """Raised for an invalid profile file or request."""


def user_profile_path() -> Path:
    return Path.home() / ".shipglows" / "state" / "execution-profile.json"


def project_profile_path(project: str | Path) -> Path:
    return Path(project).resolve() / PROJECT_RELATIVE


def _load(path: Path) -> dict[str, str]:
    if not path.is_file():
        return {}
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise ProfileError(f"unreadable profile {path}: {exc}") from exc
    if not isinstance(data, dict) or data.get("schemaVersion") != 1:
        raise ProfileError(f"unsupported profile schema in {path}")
    axes = data.get("axes", {})
    if not isinstance(axes, dict):
        raise ProfileError(f"invalid axes in {path}")
    for axis, value in axes.items():
        if axis not in AXES or value not in VALUES:
            raise ProfileError(f"invalid entry {axis}={value} in {path}")
    return dict(axes)


def _write(path: Path, axes: dict[str, str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    payload = {"schemaVersion": 1, "axes": {axis: axes[axis] for axis in AXES if axis in axes}}
    fd, tmp = tempfile.mkstemp(dir=path.parent, prefix=".execution-profile-", suffix=".tmp")
    try:
        with os.fdopen(fd, "w", encoding="utf-8", newline="\n") as handle:
            json.dump(payload, handle, indent=2)
            handle.write("\n")
        os.replace(tmp, path)
    except BaseException:
        Path(tmp).unlink(missing_ok=True)
        raise


def parse_assignments(items: list[str]) -> dict[str, str]:
    changes: dict[str, str] = {}
    for item in items:
        axis, sep, value = item.partition("=")
        if not sep or axis not in AXES or value not in VALUES:
            raise ProfileError(f"expected <axis>=allow|deny with axis in {', '.join(AXES)}: {item}")
        changes[axis] = value
    return changes


def resolve(project: str | Path | None, mode: str | None, tags: list[str]) -> dict[str, object]:
    effective = dict(BUILTIN)
    sources = {axis: "builtin" for axis in AXES}
    layers: list[tuple[str, dict[str, str]]] = [("user", _load(user_profile_path()))]
    if project:
        layers.append(("project", _load(project_profile_path(project))))
    if mode:
        layers.append((f"mode:{mode}", MODE_DEFAULTS.get(mode, {})))
    normalized = [tag.lstrip("#").casefold() for tag in tags]
    unknown = [tag for tag in normalized if tag not in TAG_EFFECTS]
    if unknown:
        raise ProfileError(f"unknown execution tags: {', '.join('#' + tag for tag in unknown)}")
    tag_axes: dict[str, str] = {}
    # Presets apply first so explicit single-axis tags refine them.
    for tag in sorted(normalized, key=lambda t: t not in ("local", "nolocal", "ci")):
        tag_axes.update(TAG_EFFECTS[tag])
    layers.append(("tag", tag_axes))
    for name, axes in layers:
        for axis, value in axes.items():
            effective[axis] = value
            sources[axis] = name
    return {"axes": effective, "sources": sources}


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    sub = parser.add_subparsers(dest="command", required=True)
    show = sub.add_parser("show", help="Show saved profiles")
    show.add_argument("--project")
    setp = sub.add_parser("set", help="Save default axes, e.g. test=deny server=allow")
    setp.add_argument("assignments", nargs="+")
    setp.add_argument("--scope", choices=("user", "project"), default="user")
    setp.add_argument("--project")
    res = sub.add_parser("resolve", help="Resolve effective axes for one invocation")
    res.add_argument("--project")
    res.add_argument("--mode")
    res.add_argument("--tags", nargs="*", default=[])
    args = parser.parse_args(argv)
    try:
        if args.command == "show":
            out: dict[str, object] = {"builtin": BUILTIN, "user": {"path": str(user_profile_path()), "axes": _load(user_profile_path())}}
            if args.project:
                path = project_profile_path(args.project)
                out["project"] = {"path": str(path), "axes": _load(path)}
        elif args.command == "set":
            if args.scope == "project" and not args.project:
                raise ProfileError("--project is required with --scope project")
            path = user_profile_path() if args.scope == "user" else project_profile_path(args.project)
            axes = _load(path)
            axes.update(parse_assignments(args.assignments))
            _write(path, axes)
            out = {"path": str(path), "axes": axes}
        else:
            out = resolve(args.project, args.mode, args.tags)
    except ProfileError as exc:
        print(json.dumps({"error": str(exc)}), file=sys.stderr)
        return 2
    print(json.dumps(out, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
