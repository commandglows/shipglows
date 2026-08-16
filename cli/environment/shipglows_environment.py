#!/usr/bin/env python3
"""CLI adapter for the ShipGlows environment control-plane foundation."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.dont_write_bytecode = True

if __package__ in (None, ""):
    sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
    from cli.environment.core import (  # type: ignore
        ApplyRefused,
        ContractError,
        apply_plan,
        build_plan,
        default_state_root,
        discover_project,
        observe_project,
        redact,
        status_project,
        verify_project,
    )
else:
    from .core import (
        ApplyRefused,
        ContractError,
        apply_plan,
        build_plan,
        default_state_root,
        discover_project,
        observe_project,
        redact,
        status_project,
        verify_project,
    )


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="shipglows env")
    parser.add_argument("command", choices=("inspect", "plan", "verify", "status", "apply"))
    parser.add_argument("--project", default=".")
    parser.add_argument("--state-root")
    parser.add_argument("--plan-digest")
    parser.add_argument("--offline", action="store_true")
    return parser


def _emit(value, stream=sys.stdout):
    json.dump(value, stream, ensure_ascii=False, sort_keys=True, indent=2, allow_nan=False)
    stream.write("\n")


def main(argv=None) -> int:
    arguments = _parser().parse_args(argv)
    project = Path(arguments.project).expanduser().resolve()
    state_root = Path(arguments.state_root).expanduser().resolve() if arguments.state_root else default_state_root()
    try:
        if arguments.command == "inspect":
            desired = discover_project(project)
            result = redact({"command": "inspect", "desired": desired, "observed": observe_project(desired), "mutated": False})
        elif arguments.command == "plan":
            result = redact(
                {
                    "command": "plan",
                    "plan": build_plan(discover_project(project), offline=arguments.offline),
                    "mutated": False,
                }
            )
        elif arguments.command == "verify":
            result = {
                "command": "verify",
                "state": verify_project(project, state_root, offline=arguments.offline),
                "mutated": True,
            }
        elif arguments.command == "status":
            result = redact({"command": "status", "state": status_project(project, state_root), "mutated": False})
        else:
            if not arguments.plan_digest:
                raise ApplyRefused(
                    "wrong_approval",
                    "apply requires the exact digest copied from a separately reviewed plan",
                )
            plan = build_plan(discover_project(project), offline=arguments.offline)
            applied = apply_plan(plan, arguments.plan_digest)
            result = redact({"command": "apply", "result": applied, "mutated": applied["status"] == "applied"})
        _emit(result)
        return 0
    except ApplyRefused as exc:
        _emit({"command": arguments.command, "status": "refused", "code": exc.code, "message": str(exc), "mutated": False})
        return 3
    except ContractError as exc:
        _emit({"command": arguments.command, "status": "invalid", "code": "contract_error", "message": str(exc), "mutated": False}, sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
