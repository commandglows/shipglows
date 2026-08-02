#!/usr/bin/env python3
"""Append one already-formed ShipGlows event block to an operational ledger."""

from __future__ import annotations

import argparse
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
LOGS = {
    "dependency": ROOT / "shipglows_data/workflow/DEPENDENCY_LOG.md",
    "operations": ROOT / "shipglows_data/workflow/OPERATIONS_LOG.md",
}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("log", choices=sorted(LOGS))
    parser.add_argument("event_file", type=Path, help="UTF-8 file containing one complete event block")
    args = parser.parse_args()
    event = args.event_file.read_text(encoding="utf-8").strip()
    if not event.startswith("<!-- shipglows:event start -->") or not event.endswith("<!-- shipglows:event end -->"):
        parser.error("event_file must contain one shipglows event block")
    target = LOGS[args.log]
    with target.open("a", encoding="utf-8") as handle:
        handle.write("\n\n" + event + "\n")
    print(target)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
