#!/usr/bin/env python3
"""Validate ShipGlows artifact frontmatter.

The linter intentionally uses only Python's standard library so it can run in
fresh projects before dependencies are installed.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


BASE_DEFAULT_TARGETS = (
    "shipglows_data",
    "AGENT.md",
    "CONTEXT.md",
    "CONTEXT-FUNCTION-TREE.md",
    "CONTENT_MAP.md",
    "BUSINESS.md",
    "BRANDING.md",
    "PRODUCT.md",
    "ARCHITECTURE.md",
    "GTM.md",
    "GUIDELINES.md",
    "TASKS.md",
    "AUDIT_LOG.md",
    "BUGS.md",
    "TEST_LOG.md",
)
LEGACY_ROOT_CANONICAL = {
    "AUDIT_LOG.md": "shipglows_data/workflow/AUDIT_LOG.md",
    "AFFILIATES.md": "shipglows_data/business/affiliate-programs.md",
    "ARCHITECTURE.md": "shipglows_data/technical/architecture.md",
    "BRANDING.md": "shipglows_data/branding/branding.md",
    "BUSINESS.md": "shipglows_data/business/business.md",
    "BUGS.md": "shipglows_data/workflow/BUGS.md",
    "CONTENT_MAP.md": "shipglows_data/editorial/content-map.md",
    "CONTEXT-FUNCTION-TREE.md": "shipglows_data/technical/context-function-tree.md",
    "CONTEXT.md": "shipglows_data/technical/context.md",
    "GTM.md": "shipglows_data/business/gtm.md",
    "GUIDELINES.md": "shipglows_data/technical/guidelines.md",
    "INSPIRATION.md": "shipglows_data/business/project-competitors-and-inspirations.md",
    "PRODUCT.md": "shipglows_data/business/product.md",
    "TASKS.md": "shipglows_data/workflow/TASKS.md",
    "TEST_LOG.md": "shipglows_data/workflow/TEST_LOG.md",
}
VALID_STATUSES = {"draft", "reviewed", "ready", "active", "stale", "superseded"}
VALID_CONFIDENCE = {"low", "medium", "high", "unknown"}
VALID_RISK = {"low", "medium", "high", "critical", "unknown"}
VALID_BUG_STATUSES = {
    "open",
    "needs-info",
    "needs-repro",
    "in-diagnosis",
    "fix-attempted",
    "fixed-pending-verify",
    "closed",
    "closed-without-retest",
    "duplicate",
    "wontfix",
}
VALID_BUG_SEVERITY = {"low", "medium", "high", "critical", "unknown"}
VALID_BUG_REDACTION = {"not-reviewed", "redacted", "not-required", "rejected"}
VALID_BUG_REPRODUCIBILITY = {"always", "intermittent", "unknown"}

COMMON_REQUIRED = {
    "artifact",
    "metadata_schema_version",
    "artifact_version",
    "project",
    "created",
    "updated",
    "status",
    "source_skill",
    "scope",
    "owner",
    "confidence",
    "risk_level",
    "security_impact",
    "docs_impact",
    "evidence",
    "depends_on",
    "supersedes",
    "next_step",
}

ARTIFACT_REQUIRED = {
    "spec": {"user_story", "linked_systems"},
    "business_context": {"target_audience", "value_proposition", "business_model", "market", "next_review"},
    "brand_context": {"brand_voice", "trust_posture", "next_review"},
    "brand_contract": {"next_review"},
    "brand_voice": {"next_review"},
    "brand_messaging": {"next_review"},
    "brand_visual_identity": {"next_review"},
    "brand_rules": {"next_review"},
    "brand_assets_index": {"next_review"},
    "product_context": {"target_user", "user_problem", "desired_outcomes", "non_goals", "next_review"},
    "architecture_context": {"linked_systems", "external_dependencies", "invariants", "next_review"},
    "gtm_context": {"target_segment", "offer", "channels", "proof_points", "next_review"},
    "competitive_intelligence": {"target_projects", "reference_categories", "source_policy", "next_review"},
    "affiliate_program_registry": {
        "target_projects",
        "program_statuses",
        "disclosure_policy",
        "secrets_policy",
        "next_review",
    },
    "technical_guidelines": {"linked_systems", "next_review"},
    "audit_report": {"domains", "issue_counts"},
    "verification_report": {"verified_outcomes", "assumptions"},
    "readiness_report": {"user_story", "verified_outcomes", "assumptions"},
    "review_report": {"period", "verified_outcomes", "assumptions"},
    "conversation_audit": {"categories", "findings", "owner_routes"},
    "research_report": {"source_count", "primary_sources", "recommendation"},
    "decision_record": {"decision", "rationale", "consequences"},
    "content_map": {"content_surfaces", "next_review"},
    "technical_module_context": {"linked_systems", "next_review"},
    "editorial_content_context": {"content_surfaces", "claim_register", "page_intent", "next_review"},
    "bug_record": {
        "bug_id",
        "title",
        "bug_status",
        "severity",
        "reported_by",
        "first_observed",
        "last_observed",
        "environment",
        "reproducibility",
        "redaction_status",
        "related_bugs",
        "related_artifacts",
    },
    "manual_test_checklist": {
        "target_scope",
        "stack_profile",
        "proof_profile",
    },
}

SKIP_ARTIFACT_TRACKERS = {"AUDIT_LOG.md", "BUGS.md", "PROJECTS.md", "TASKS.md", "TEST_LOG.md"}
OFFICIAL_ARTIFACT_PATHS = {
    "AGENT.md",
    "CONTEXT.md",
    "shipglows_data/AGENT.md",
    "CONTEXT-FUNCTION-TREE.md",
    "CONTENT_MAP.md",
    "shipglows_data/editorial/content-map.md",
    "BUSINESS.md",
    "BRANDING.md",
    "PRODUCT.md",
    "ARCHITECTURE.md",
    "GTM.md",
    "GUIDELINES.md",
    "shipglows_data/business/business.md",
    "shipglows_data/business/product.md",
    "shipglows_data/branding/branding.md",
    "shipglows_data/branding/voice-and-tone.md",
    "shipglows_data/branding/messaging-pillars.md",
    "shipglows_data/branding/visual-identity.md",
    "shipglows_data/branding/brand-rules.md",
    "shipglows_data/branding/assets/README.md",
    "shipglows_data/business/gtm.md",
    "shipglows_data/business/project-competitors-and-inspirations.md",
    "shipglows_data/business/affiliate-programs.md",
    "shipglows_data/technical/code-docs-map.md",
    "shipglows_data/technical/README.md",
    "shipglows_data/technical/context.md",
    "shipglows_data/editorial/README.md",
    "shipglows_data/workflow/specs",
}


def default_targets() -> list[str]:
    return list(BASE_DEFAULT_TARGETS)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "paths",
        nargs="*",
        help="Files or directories to lint. Defaults to canonical ShipGlows artifact paths plus supported root entrypoints and legacy-root guards.",
    )
    parser.add_argument(
        "--all-markdown",
        action="store_true",
        help="Lint every markdown file under the provided paths, including files without ShipGlows artifact markers.",
    )
    return parser.parse_args()


def iter_markdown(paths: list[str]) -> list[Path]:
    files: list[Path] = []
    for raw in paths or default_targets():
        path = Path(raw)
        if not path.exists():
            continue
        if path.is_dir():
            files.extend(
                p
                for p in path.rglob("*.md")
                if ".git" not in p.parts and "archive" not in p.parts
            )
        elif path.suffix.lower() in {".md", ".mdx"}:
            files.append(path)
    return sorted(set(files))


def read_frontmatter(path: Path) -> tuple[dict[str, str], list[str]]:
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---\n"):
        return {}, ["missing YAML frontmatter"]
    end = text.find("\n---\n", 4)
    if end == -1:
        return {}, ["missing closing YAML frontmatter delimiter"]

    fields: dict[str, str] = {}
    errors: list[str] = []
    for line in text[4:end].splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#") or stripped.startswith("-"):
            continue
        match = re.match(r"^([A-Za-z_][A-Za-z0-9_-]*):(?:\s*(.*))?$", line)
        if not match:
            continue
        key, value = match.groups()
        fields[key] = (value or "").strip().strip("\"'")
    return fields, errors


def should_lint(path: Path, fields: dict[str, str], all_markdown: bool) -> bool:
    if len(path.parts) == 1 and path.name in LEGACY_ROOT_CANONICAL:
        return True
    if path.name in SKIP_ARTIFACT_TRACKERS:
        return False
    if all_markdown:
        return True
    if fields.get("metadata_schema_version") or fields.get("artifact_version"):
        return True
    path_key = path.as_posix()
    if path.name in OFFICIAL_ARTIFACT_PATHS or any(
        path_key == official_path or path_key.endswith(f"/{official_path}")
        for official_path in OFFICIAL_ARTIFACT_PATHS
    ):
        return True
    if "specs" in path.parts:
        return True
    return False


def validate_bug_record(fields: dict[str, str]) -> list[str]:
    errors: list[str] = []
    bug_status = fields.get("bug_status")
    if bug_status and bug_status not in VALID_BUG_STATUSES:
        errors.append("bug_status must be one of: " + ", ".join(sorted(VALID_BUG_STATUSES)))

    severity = fields.get("severity")
    if severity and severity not in VALID_BUG_SEVERITY:
        errors.append("severity must be one of: " + ", ".join(sorted(VALID_BUG_SEVERITY)))

    redaction_status = fields.get("redaction_status")
    if redaction_status and redaction_status not in VALID_BUG_REDACTION:
        errors.append("redaction_status must be one of: " + ", ".join(sorted(VALID_BUG_REDACTION)))

    reproducibility = fields.get("reproducibility")
    if reproducibility and reproducibility not in VALID_BUG_REPRODUCIBILITY:
        errors.append("reproducibility must be one of: " + ", ".join(sorted(VALID_BUG_REPRODUCIBILITY)))

    bug_id = fields.get("bug_id", "")
    if bug_id and "YYYY" not in bug_id and not re.match(r"^BUG-\d{4}-\d{2}-\d{2}-\d{3}$", bug_id):
        errors.append("bug_id must match BUG-YYYY-MM-DD-NNN, for example BUG-2026-04-27-001")

    return errors


def validate(path: Path, fields: dict[str, str], initial_errors: list[str]) -> list[str]:
    errors = list(initial_errors)
    if errors:
        return errors

    if len(path.parts) == 1 and path.name in LEGACY_ROOT_CANONICAL:
        errors.append(
            f"legacy root ShipGlows artifact; move to {LEGACY_ROOT_CANONICAL[path.name]} "
            "or keep only as a temporary migration source"
        )

    missing = sorted(key for key in COMMON_REQUIRED if key not in fields)
    if missing:
        errors.append("missing required fields: " + ", ".join(missing))

    artifact = fields.get("artifact", "")
    extra_required = ARTIFACT_REQUIRED.get(artifact, set())
    missing_extra = sorted(key for key in extra_required if key not in fields)
    if missing_extra:
        errors.append(f"missing {artifact} fields: " + ", ".join(missing_extra))

    if fields.get("metadata_schema_version") != "1.0":
        errors.append("metadata_schema_version must be \"1.0\"")

    artifact_version = fields.get("artifact_version", "")
    if artifact_version and not re.match(r"^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$", artifact_version):
        errors.append("artifact_version must use semantic versioning, for example 0.1.0 or 1.0.0")

    status = fields.get("status")
    if status and status not in VALID_STATUSES:
        errors.append("status must be one of: " + ", ".join(sorted(VALID_STATUSES)))

    confidence = fields.get("confidence")
    if confidence and confidence not in VALID_CONFIDENCE:
        errors.append("confidence must be one of: " + ", ".join(sorted(VALID_CONFIDENCE)))

    risk_level = fields.get("risk_level")
    if risk_level and risk_level not in VALID_RISK:
        errors.append("risk_level must be one of: " + ", ".join(sorted(VALID_RISK)))

    if fields.get("status") in {"reviewed", "ready", "active"} and artifact_version.startswith("0."):
        errors.append("reviewed/ready/active artifacts should use artifact_version >= 1.0.0")

    if fields.get("status") == "superseded" and not fields.get("superseded_by"):
        errors.append("superseded artifacts must set superseded_by")

    if artifact == "bug_record":
        errors.extend(validate_bug_record(fields))

    return errors


def main() -> int:
    args = parse_args()
    files = iter_markdown(args.paths)
    checked = 0
    failures: list[tuple[Path, list[str]]] = []

    for path in files:
        fields, initial_errors = read_frontmatter(path)
        if not should_lint(path, fields, args.all_markdown):
            continue
        checked += 1
        errors = validate(path, fields, initial_errors)
        if errors:
            failures.append((path, errors))

    if failures:
        for path, errors in failures:
            print(f"{path}:")
            for error in errors:
                print(f"  - {error}")
        print(f"\nShipGlows metadata lint failed: {len(failures)} file(s) invalid, {checked} checked.")
        return 1

    print(f"ShipGlows metadata lint passed: {checked} file(s) checked.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
