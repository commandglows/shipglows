#!/usr/bin/env python3
import json
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))

from cli.environment.core import ApplyRefused, apply_plan, build_plan, digest_value, discover_project  # noqa: E402


def expect_refusal(callable_, code):
    try:
        callable_()
    except ApplyRefused as exc:
        assert exc.code == code, (exc.code, str(exc))
    else:
        raise AssertionError(f"expected apply refusal {code}")


with tempfile.TemporaryDirectory() as directory:
    project = Path(directory)
    manifest = {
        "schema": "shipglows.environment/v1",
        "capabilities": {"tools": [{"id": "node", "constraint": "24"}]},
    }
    (project / "shipglows.environment.json").write_text(json.dumps(manifest), encoding="utf-8")
    desired = discover_project(project)
    plan = build_plan(desired, platform_name="windows", architecture="x86_64")
    calls = []
    expect_refusal(lambda: apply_plan(plan, plan["digest"], lambda operation: calls.append(operation)), "no_active_backend")
    assert calls == []

    stale = dict(plan)
    stale["digest"] = "0" * 64
    expect_refusal(lambda: apply_plan(stale, plan["digest"], lambda operation: calls.append(operation)), "stale_plan")
    assert calls == []

    forged = json.loads(json.dumps(plan))
    forged["operations"][0]["executable"] = True
    forged_body = dict(forged)
    forged_body.pop("digest")
    forged["digest"] = digest_value(forged_body)
    expect_refusal(
        lambda: apply_plan(forged, forged["digest"], lambda operation: calls.append(operation)),
        "no_active_backend",
    )
    assert calls == []

print("ShipGlows environment executor contract: OK")
