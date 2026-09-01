#!/usr/bin/env python3
"""Focused static/unit contract for the closed project.create control plane."""

import importlib.util
import json
from pathlib import Path
import tempfile
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location("project_control", ROOT / "cli" / "project_control.py")
module = importlib.util.module_from_spec(spec)
assert spec.loader
spec.loader.exec_module(module)

with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    repository = root / "repo"
    (repository / ".git").mkdir(parents=True)
    registry = root / "registry.json"
    request = {"idempotencyKey": "retry_key_123456", "displayName": "Mon projet", "ownerAccountId": "usr_firebase_1234",
               "repository": {"id": "12345", "fullName": "owner/repo", "rootPath": str(repository)}}
    encoded = json.dumps(request).encode()
    environment = {"SHIPGLOWS_CLI_PROJECT_REGISTRY_FILE": str(registry), "SHIPGLOWS_PROJECTS_DIR": str(root)}
    with patch.dict(module.os.environ, environment), \
         patch.object(module.sys, "stdin") as stdin, patch.object(module, "refresh_catalog"):
        stdin.buffer.read.return_value = encoded
        first = module.create(ROOT / "cli")
        stdin.buffer.read.return_value = encoded
        second = module.create(ROOT / "cli")
    assert first["id"] == second["id"] and first["id"].startswith("prj_")
    assert len(json.loads(registry.read_text(encoding="utf-8"))["projects"]) == 1

    conflict = dict(request, displayName="Autre projet")
    with patch.dict(module.os.environ, environment), \
         patch.object(module.sys, "stdin") as stdin:
        stdin.buffer.read.return_value = json.dumps(conflict).encode()
        try:
            module.create(ROOT / "cli")
            raise AssertionError("conflicting replay accepted")
        except module.Refused as exc:
            assert exc.code == "idempotencyConflict"

source = (ROOT / "cli" / "project_control.py").read_text(encoding="utf-8")
assert "shell=True" not in source
assert "stdout=subprocess.DEVNULL" in source and "stderr=subprocess.DEVNULL" in source
print("project create contract: ok")
