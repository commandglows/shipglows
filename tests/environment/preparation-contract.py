#!/usr/bin/env python3
import json
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))
from cli.environment.core import ContractError  # noqa: E402
from cli.environment.preparation import apply_preparation_plan, build_preparation_plan  # noqa: E402

with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    empty = root / "empty"
    empty.mkdir()
    assert build_preparation_plan(empty)["classification"] == "manuelle"
    invalid = root / "invalid"
    invalid.mkdir()
    (invalid / "package.json").write_text("{", encoding="utf-8")
    assert build_preparation_plan(invalid)["classification"] == "bloquante"
    assert (invalid / "package.json").read_text(encoding="utf-8") == "{"
    monorepo = root / "monorepo"
    (monorepo / "apps" / "site").mkdir(parents=True)
    (monorepo / "apps" / "mobile").mkdir(parents=True)
    (monorepo / "package.json").write_text(json.dumps({"packageManager": "pnpm@10.33.2", "engines": {"node": ">=24"}}), encoding="utf-8")
    (monorepo / "pnpm-lock.yaml").write_text("lockfileVersion: '9.0'\n", encoding="utf-8")
    (monorepo / "apps" / "site" / "package.json").write_text(json.dumps({"dependencies": {"astro": "^5.0.0"}}), encoding="utf-8")
    (monorepo / "apps" / "mobile" / "pubspec.yaml").write_text("environment:\n  sdk: '>=3.8.0 <4.0.0'\n", encoding="utf-8")
    first = build_preparation_plan(monorepo)
    assert first == build_preparation_plan(monorepo)
    assert first["classification"] == "réparable"
    assert {item["kind"] for item in first["surfaces"]} >= {"astro", "flutter"}
    assert next(item for item in first["operation"]["content"].splitlines() if '"id": "flutter"' in item)
    generated = json.loads(first["operation"]["content"])
    assert next(item for item in generated["capabilities"]["tools"] if item["id"] == "flutter")["constraint"] == "*"
    assert apply_preparation_plan(monorepo, first["digest"])["changed"] is True
    healthy = build_preparation_plan(monorepo)
    assert healthy["classification"] == "saine"
    assert apply_preparation_plan(monorepo, healthy["digest"])["changed"] is False
    stale = root / "stale"
    stale.mkdir()
    (stale / "package.json").write_text("{}", encoding="utf-8")
    stale_plan = build_preparation_plan(stale)
    (stale / "requirements.txt").write_text("pytest\n", encoding="utf-8")
    try:
        apply_preparation_plan(stale, stale_plan["digest"])
    except ContractError:
        pass
    else:
        raise AssertionError("A stale preparation plan must be refused")
print("ShipGlows preparation contract: OK")
