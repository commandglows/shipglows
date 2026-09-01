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
    from cli.environment.preparation import apply_preparation_plan, build_preparation_plan  # type: ignore
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
    from .preparation import apply_preparation_plan, build_preparation_plan


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="shipglows env")
    parser.add_argument("command", choices=("inspect", "plan", "verify", "status", "apply", "prepare", "prepare-apply"))
    parser.add_argument("--project", default=".")
    parser.add_argument("--state-root")
    parser.add_argument("--plan-digest")
    parser.add_argument("--offline", action="store_true")
    return parser


def _emit(value, stream=None):
    if stream is None:
        stream = sys.stdout
    json.dump(redact(value), stream, ensure_ascii=False, sort_keys=True, indent=2, allow_nan=False)
    stream.write("\n")


def _semantic_exit(status: str, management: str) -> int:
    if management == "unmanaged":
        return 0
    return 0 if status == "ready" else 4


def main(argv=None) -> int:
    arguments = _parser().parse_args(argv)
    project = Path(arguments.project).expanduser().resolve()
    state_root = Path(arguments.state_root).expanduser().resolve() if arguments.state_root else default_state_root()
    exit_code = 0
    try:
        if arguments.command == "prepare":
            result = build_preparation_plan(project)
        elif arguments.command == "prepare-apply":
            if not arguments.plan_digest:
                raise ContractError("prepare-apply requires --plan-digest")
            result = apply_preparation_plan(project, arguments.plan_digest)
        elif arguments.command == "inspect":
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
            state = verify_project(project, state_root, offline=arguments.offline)
            result = {
                "command": "verify",
                "state": state,
                "mutated": True,
            }
            exit_code = _semantic_exit(state["observed"]["status"], state["management"])
        elif arguments.command == "status":
            state = status_project(project, state_root)
            result = redact({"command": "status", "state": state, "mutated": False})
            exit_code = _semantic_exit(state["status"], state.get("management", "unmanaged"))
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
        return exit_code
    except ApplyRefused as exc:
        _emit({"command": arguments.command, "status": "refused", "code": exc.code, "message": str(exc), "mutated": False})
        return 3
    except ContractError as exc:
        _emit({"command": arguments.command, "status": "invalid", "code": "contract_error", "message": str(exc), "mutated": False}, sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
