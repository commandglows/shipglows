#!/usr/bin/env python3
"""Refresh one ShipGlows pack staging directory and validate the result."""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path


PLUGIN_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_OUTPUT_ROOT = Path.home() / ".shipglows" / "staged-packs"
DEFAULT_VALIDATOR = Path.home() / ".codex" / "skills" / ".system" / "plugin-creator" / "scripts" / "validate_plugin.py"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("pack", help="Pack id from assets/pack-catalog.json, for example shipglows-main.")
    parser.add_argument(
        "--shipglows-root",
        default=str(Path.home() / "shipglows"),
        help="Path to the ShipGlows source corpus.",
    )
    parser.add_argument(
        "--output-root",
        default=str(DEFAULT_OUTPUT_ROOT),
        help="Directory where staged packs are stored.",
    )
    parser.add_argument(
        "--validator",
        default=str(DEFAULT_VALIDATOR),
        help="Codex plugin validator path.",
    )
    parser.add_argument(
        "--keep-existing",
        action="store_true",
        help="Do not replace an existing staged pack directory.",
    )
    parser.add_argument(
        "--skip-validate",
        action="store_true",
        help="Skip Codex plugin validation after staging.",
    )
    return parser.parse_args()


def run(command: list[str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(command, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)


def read_report(staged_root: Path) -> dict:
    report_path = staged_root / "shipglows-pack-report.json"
    with report_path.open() as handle:
        return json.load(handle)


def main() -> int:
    args = parse_args()
    output_root = Path(args.output_root).expanduser().resolve()
    staged_root = output_root / args.pack
    stage_script = PLUGIN_ROOT / "scripts" / "stage_shipglows_pack.py"

    stage_command = [
        sys.executable,
        str(stage_script),
        args.pack,
        "--shipglows-root",
        args.shipglows_root,
        "--output-root",
        str(output_root),
    ]
    if not args.keep_existing:
        stage_command.append("--force")

    stage_result = run(stage_command)
    print(stage_result.stdout, end="")
    if stage_result.returncode != 0:
        return stage_result.returncode

    validation_passed: bool | None = None
    if not args.skip_validate:
        validator = Path(args.validator).expanduser().resolve()
        if not validator.exists():
            print(f"Validation skipped: validator not found at {validator}")
            validation_passed = None
        else:
            validate_result = run([sys.executable, str(validator), str(staged_root)])
            print(validate_result.stdout, end="")
            validation_passed = validate_result.returncode == 0
            if validate_result.returncode != 0:
                return validate_result.returncode

    report = read_report(staged_root)
    print()
    print("Refresh summary")
    print(f"- Pack: {args.pack}")
    print(f"- Staged root: {staged_root}")
    print(f"- Hard findings: {report.get('hard_findings')}")
    print(f"- Review findings: {report.get('review_findings')}")
    print(f"- Public ready: {str(report.get('public_ready')).lower()}")
    if validation_passed is not None:
        print(f"- Plugin validation: {'passed' if validation_passed else 'failed'}")
    print(f"- Report: {staged_root / 'shipglows-pack-report.json'}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
