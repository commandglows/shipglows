#!/usr/bin/env python3
import json
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))

from cli.environment.core import (  # noqa: E402
    ContractError,
    load_manifest,
    load_runtime_policy,
    redact,
    resolve_project_reference,
)


def expect_error(callable_, fragment):
    try:
        callable_()
    except ContractError as exc:
        assert fragment in str(exc), str(exc)
    else:
        raise AssertionError(f"expected ContractError containing {fragment!r}")


with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    manifest = root / "shipglows.environment.json"
    manifest.write_text(
        json.dumps(
            {
                "schema": "shipglows.environment/v1",
                "project": {"name": "fixture"},
                "capabilities": {
                    "tools": [{"id": "node", "constraint": "24"}],
                    "targets": [],
                    "agents": [],
                    "integrations": [],
                },
                "backends": {"windows": {"mise": "mise.toml"}},
                "policies": {
                    "native_host_required": False,
                    "consent": "explicit",
                    "secrets": "redact",
                },
                "extensions": {"example.test": {"enabled": True}},
            }
        ),
        encoding="utf-8",
    )
    parsed = load_manifest(manifest, root)
    assert parsed["capabilities"]["tools"][0]["id"] == "node"
    assert parsed["backends"]["windows"]["mise"].endswith("mise.toml")

    manifest.write_text('{"schema":"shipglows.environment/v1","schema":"duplicate"}', encoding="utf-8")
    expect_error(lambda: load_manifest(manifest, root), "duplicate")
    manifest.write_text('{"schema":"shipglows.environment/v1","project":{"name":NaN}}', encoding="utf-8")
    expect_error(lambda: load_manifest(manifest, root), "non-finite")
    manifest.write_text('{"schema":"shipglows.environment/v2"}', encoding="utf-8")
    expect_error(lambda: load_manifest(manifest, root), "unsupported schema")
    manifest.write_text('{"schema":"shipglows.environment/v1","surprise":true}', encoding="utf-8")
    expect_error(lambda: load_manifest(manifest, root), "unknown field")

    runtime = root / ".shipglows.env"
    runtime.write_text("SHIPGLOWS_ENV_PORT=9000\nSHIPGLOWS_AUTO_REPAIR=false\n", encoding="utf-8")
    assert load_runtime_policy(runtime) == {"port": 9000, "auto_repair": False}
    runtime.write_text("SHIPGLOWS_NODE_VERSION=24\n", encoding="utf-8")
    expect_error(lambda: load_runtime_policy(runtime), "outside runtime-policy ownership")

    outside = root.parent / "outside.toml"
    expect_error(lambda: resolve_project_reference(root, "../outside.toml"), "escapes project root")
    expect_error(lambda: resolve_project_reference(root, "bad\x00reference"), "invalid project reference")
    link = root / "linked-outside"
    try:
        link.symlink_to(outside)
    except OSError:
        pass
    else:
        expect_error(lambda: resolve_project_reference(root, "linked-outside"), "escapes project root")

redacted = redact(
    {
        "token": "canary-secret",
        "url": "https://user:password@example.test/private?api_key=query-canary&view=full",
        "credential": "ghp_abcdefghijklmnopqrstuvwxyz123456",
        "safe": "visible",
    }
)
encoded = json.dumps(redacted)
assert "canary-secret" not in encoded and "password" not in encoded and "query-canary" not in encoded
assert "ghp_" not in encoded
assert redacted["safe"] == "visible"

print("ShipGlows environment schema contract: OK")
