#!/usr/bin/env python3
"""Deterministic scenario-first contract checks for 008-sg-customer."""
from __future__ import annotations

import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DISPATCHER = ROOT / "skills/008-sg-customer/SKILL.md"
PLAYBOOKS = {
    "audit": "references/customer-audit-playbook.md",
    "flow": "references/customer-flow-playbook.md",
    "onboarding": "references/onboarding-playbook.md",
    "recovery": "references/customer-recovery-playbook.md",
}
ACTIVE_SURFACES = [
    DISPATCHER,
    ROOT / "skills/302-sg-help/references/help-catalog.md",
    ROOT / "shipglows-site/src/content/skills/sg-customer.md",
    ROOT / "shipglows_data/technical/skill-runtime-and-lifecycle.md",
    ROOT / "shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md",
    ROOT / "shipglows_data/workflow/playbooks/spec-driven-workflow.md",
    ROOT / "skills/001-sg-build/references/build-lifecycle-workflow.md",
]
HISTORICAL_ALLOWLIST = {
    ROOT / "shipglows_data/workflow/specs/sg-onboarding-user-activation-skill.md",
    ROOT / "shipglows_data/workflow/specs/formalize-sg-customer-modes-and-playbooks.md",
}


def read(path: Path) -> str:
    assert path.is_file(), f"missing: {path.relative_to(ROOT)}"
    return path.read_text(encoding="utf-8")


def requires(text: str, *markers: str) -> None:
    for marker in markers:
        assert marker in text, f"missing marker: {marker}"


def test_mode(mode: str, marker: str) -> None:
    text = read(DISPATCHER)
    rows = re.findall(r"^\| `008-sg-customer (audit|flow|onboarding|recovery) \[[^`]+\]` \| `([^`]+)` \|", text, re.MULTILINE)
    assert rows == list(PLAYBOOKS.items()), f"mode/playbook table drift: {rows}"
    assert rows.count((mode, marker)) == 1, f"{mode} must select exactly one primary playbook"


def main() -> None:
    dispatcher = read(DISPATCHER)
    # CA 1-4: exact modes map to one primary playbook.
    for mode, playbook in PLAYBOOKS.items():
        test_mode(mode, playbook)
        requires(read(ROOT / "skills/008-sg-customer" / playbook), "#")
    # CA 3: overlay is explicit and onboarding-only.
    requires(dispatcher, "Only onboarding may additionally load", "explicitly requested stepped overlay")
    assert "customer-audit-playbook.md" not in read(ROOT / "skills/008-sg-customer/references/onboarding-playbook.md")
    # CA 5: bare/invalid/mixed input asks among exactly these modes.
    requires(dispatcher, "Bare `audit`, invalid input, and materially mixed requests", "`audit`, `flow`, `onboarding`, and `recovery`")
    # CA 6: adjacent owners remain explicit.
    requires(dispatcher, "006-sg-design", "007-sg-content", "300-sg-docs", "107-sg-test", "108-sg-browser", "109-sg-auth-debug")
    # CA 7: trust/sensitive setup is non-negotiable.
    requires(dispatcher, "value, optionality, consequence, safe defer path, and recovery/recheck", "Never coerce access", "unsupported capability")
    # CA 8: semantic source transfer is durable and reviewed.
    matrix = read(ROOT / "skills/008-sg-customer/references/customer-contract-transfer-matrix.md")
    requires(matrix, "No active rule is retired", "completed-over-current priority")
    # CA 9-10: active discovery uses canonical owner/modes and has no legacy identity.
    forbidden = ("sg-onboarding", "sg-end-user", "sg-activation", "sg-recovery")
    for path in ACTIVE_SURFACES:
        text = read(path)
        for old in forbidden:
            assert old not in text, f"active alias {old}: {path.relative_to(ROOT)}"
    assert all(path.is_file() for path in HISTORICAL_ALLOWLIST), "historical allowlist drift"
    # CA 11: public content presents one owner and all modes.
    public = read(ROOT / "shipglows-site/src/content/skills/sg-customer.md")
    requires(public, 'title: "sg-customer"', "audit [scope]", "flow [feature-or-flow]", "onboarding [feature-or-flow]", "recovery [feature-or-state]")
    # CA 12: catalog identity remains canonical; no mode wrapper is introduced.
    catalog = json.loads(read(ROOT / "plugins/shipglows/assets/pack-catalog.json"))
    serialized = json.dumps(catalog)
    assert "008-sg-customer" in serialized, "catalog lost canonical identity"
    for runtime in (
        Path.home() / ".codex/skills/008-sg-customer",
        Path.home() / ".claude/skills/008-sg-customer",
    ):
        assert runtime.resolve() == (ROOT / "skills/008-sg-customer").resolve(), f"runtime drift: {runtime}"
    assert not any((ROOT / "skills" / name).exists() for name in forbidden), "legacy customer source exists"
    print("PASS CA 1-12: 008-sg-customer mode contract")


if __name__ == "__main__":
    main()
