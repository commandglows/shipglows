#!/usr/bin/env python3
"""Read the canonical project delivery posture and derive Git policy."""

from __future__ import annotations

import argparse
import json
import re
from dataclasses import asdict, dataclass
from pathlib import Path


CANONICAL_RELATIVE = Path("shipglows_data/business/business.md")
VALID_POSTURES = {"development", "published", "sensitive-production"}


@dataclass(frozen=True)
class DeliveryPolicy:
    state: str
    delivery_posture: str | None
    canonical_source: str
    production_branch: str | None
    integration_branch: str | None
    staging_branch: str | None
    question_required: bool
    reason: str


def _frontmatter(text: str) -> str:
    if not text.startswith("---"):
        return ""
    parts = text.split("---", 2)
    return parts[1] if len(parts) == 3 else ""


def inspect_project(project: Path) -> DeliveryPolicy:
    root = project.resolve()
    source = root / CANONICAL_RELATIVE
    relative = CANONICAL_RELATIVE.as_posix()
    if not source.is_file():
        return DeliveryPolicy(
            "missing",
            None,
            relative,
            None,
            None,
            None,
            True,
            "canonical business context is missing",
        )

    match = re.search(
        r"(?mi)^delivery_posture:\s*[\"']?([^\s\"']+)[\"']?\s*$",
        _frontmatter(source.read_text(encoding="utf-8")),
    )
    if not match:
        return DeliveryPolicy(
            "missing",
            None,
            relative,
            None,
            None,
            None,
            True,
            "delivery_posture is missing from canonical business context",
        )

    posture = match.group(1)
    if posture not in VALID_POSTURES:
        return DeliveryPolicy(
            "invalid",
            posture,
            relative,
            None,
            None,
            None,
            True,
            f"unsupported delivery_posture: {posture}",
        )

    live = posture in {"published", "sensitive-production"}
    return DeliveryPolicy(
        "resolved",
        posture,
        relative,
        "main",
        "dev" if live else "main",
        "dev" if live else "not-required",
        False,
        "canonical business posture resolved",
    )


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Inspect canonical ShipGlows delivery posture without mutating the project."
    )
    parser.add_argument("--project", type=Path, default=Path.cwd())
    parser.add_argument("--format", choices=("json", "text"), default="text")
    args = parser.parse_args(argv)
    policy = inspect_project(args.project)
    if args.format == "json":
        print(json.dumps(asdict(policy), sort_keys=True))
    else:
        print(f"state={policy.state}")
        print(f"canonical_source={policy.canonical_source}")
        print(f"delivery_posture={policy.delivery_posture or 'missing'}")
        print(f"production_branch={policy.production_branch or 'unresolved'}")
        print(f"integration_branch={policy.integration_branch or 'unresolved'}")
        print(f"staging_branch={policy.staging_branch or 'unresolved'}")
        print(f"question_required={'yes' if policy.question_required else 'no'}")
        print(f"reason={policy.reason}")
    return 0 if policy.state == "resolved" else 2


if __name__ == "__main__":
    raise SystemExit(main())
