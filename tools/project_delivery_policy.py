#!/usr/bin/env python3
"""Read the canonical project delivery posture and derive Git policy."""

from __future__ import annotations

import argparse
import json
import re
from dataclasses import asdict, dataclass
from pathlib import Path


CANONICAL_RELATIVE = Path("shipglows_data/business/business.md")
LAUNCH_PROTECTION_RELATIVE = Path("shipglows_data/workflow/launch-protection.md")
VALID_POSTURES = {"development", "published", "sensitive-production"}
VALID_PROTECTION_STATES = {"not_applicable", "protected", "unprotected", "unverified"}
VALID_EMAIL_CAPTURE_STATES = {"inactive", "configured", "verified"}


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
    product_status: str | None = None
    launch_protection_review_required: bool = False
    launch_protection_state: str = "not_applicable"
    email_capture_state: str = "inactive"
    email_provider: str | None = None
    public_url: str | None = None
    launch_reference: str | None = None
    launch_protection_issue: str | None = None


def _frontmatter(text: str) -> str:
    if not text.startswith("---"):
        return ""
    parts = text.split("---", 2)
    return parts[1] if len(parts) == 3 else ""


def _canonical_scalar(frontmatter: str, name: str) -> tuple[str | None, str | None]:
    """Read one top-level scalar without interpreting general YAML."""
    if any(
        re.match(rf"^[ \t]+{re.escape(name)}[ \t]*:", line)
        for line in frontmatter.splitlines()
    ):
        return None, f"canonical field must be top-level: {name}"
    values = [
        match.group(1)
        for line in frontmatter.splitlines()
        if (match := re.match(rf"^{re.escape(name)}[ \t]*:(.*)$", line))
    ]
    if len(values) > 1:
        return None, f"duplicate canonical field: {name}"
    if not values:
        return None, None

    raw = values[0]
    if raw and raw[0] not in " \t":
        return None, f"ambiguous YAML scalar for {name}: whitespace required after ':'"
    raw = raw.strip()
    if not raw or raw.startswith("#"):
        return None, None

    if raw[0] in "\"'":
        quote = raw[0]
        end = raw.find(quote, 1)
        if end < 0:
            return None, f"unterminated quoted scalar for {name}"
        value = raw[1:end]
        suffix = raw[end + 1 :]
        if suffix and not suffix[0].isspace():
            return None, f"ambiguous trailing content for {name}"
        suffix = suffix.strip()
        if suffix and not suffix.startswith("#"):
            return None, f"ambiguous trailing content for {name}"
    else:
        value = re.split(r"[ \t]+#", raw, maxsplit=1)[0].strip()

    if value.lower() in {"", "none", "null", "~"}:
        return None, None
    return value, None


def _field(frontmatter: str, name: str) -> str | None:
    """Read an optional launch-protection field conservatively."""
    value, issue = _canonical_scalar(frontmatter, name)
    return None if issue else value


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

    posture, posture_issue = _canonical_scalar(
        _frontmatter(source.read_text(encoding="utf-8")), "delivery_posture"
    )
    if posture_issue:
        return DeliveryPolicy(
            "invalid", None, relative, None, None, None, True, posture_issue
        )
    if posture is None:
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
    launch_source = root / LAUNCH_PROTECTION_RELATIVE
    values: dict[str, str | None] = {}
    launch_protection_issue: str | None = None
    if launch_source.is_file():
        launch_frontmatter = _frontmatter(launch_source.read_text(encoding="utf-8"))
        values = {name: _field(launch_frontmatter, name) for name in (
            "protection_status", "email_capture_status", "email_provider", "public_url"
        )}
        protection_state = values["protection_status"] or "unverified"
        capture_state = values["email_capture_status"] or "inactive"
        invalid = (
            ("protection_status", protection_state)
            if protection_state not in VALID_PROTECTION_STATES
            else (("email_capture_status", capture_state) if capture_state not in VALID_EMAIL_CAPTURE_STATES else None)
        )
        if invalid:
            launch_protection_issue = f"unsupported {invalid[0]}: {invalid[1]}"
            if invalid[0] == "protection_status":
                protection_state = "invalid"
            else:
                capture_state = "invalid"
    else:
        protection_state = "missing" if not live else "not_applicable"
        capture_state = "inactive"
    return DeliveryPolicy(
        "resolved",
        posture,
        relative,
        "main",
        "dev" if live else "main",
        "dev" if live else "not-required",
        False,
        "canonical business posture resolved",
        "Live" if live else "Dev",
        not live,
        protection_state,
        capture_state,
        values.get("email_provider"),
        values.get("public_url"),
        LAUNCH_PROTECTION_RELATIVE.as_posix() if launch_source.is_file() else None,
        launch_protection_issue,
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
        print(f"product_status={policy.product_status or 'unresolved'}")
        print(f"launch_protection_review_required={'yes' if policy.launch_protection_review_required else 'no'}")
        print(f"launch_protection_state={policy.launch_protection_state}")
        print(f"email_capture_state={policy.email_capture_state}")
        print(f"email_provider={policy.email_provider or 'none'}")
        print(f"public_url={policy.public_url or 'none'}")
        print(f"launch_reference={policy.launch_reference or 'none'}")
        print(f"launch_protection_issue={policy.launch_protection_issue or 'none'}")
    return 0 if policy.state == "resolved" else 2


if __name__ == "__main__":
    raise SystemExit(main())
