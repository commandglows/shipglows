#!/usr/bin/env python3
"""Audit ShipGlows skill metadata and discovery budgets.

The audit intentionally uses only Python's standard library so it can run in a
fresh ShipGlows checkout before project dependencies are installed.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any


AGGREGATE_BUDGET = 8500
DESCRIPTION_TARGET_MAX = 120
DESCRIPTION_WARNING_MAX = 140
DESCRIPTION_HARD_MAX = 200
AGENT_SKILLS_DESCRIPTION_MAX = 1024
CLAUDE_LISTING_TEXT_MAX = 1536
COMPATIBILITY_MAX = 500
BODY_TOKEN_RISK = 5000
NAME_MAX = 64
DEFAULT_BATCH_SIZE = 8
VALID_NAME = re.compile(r"^[a-z0-9-]+$")
XML_TAG = re.compile(r"<[^>]+>")
GENERIC_STARTS = {
    "help",
    "manage",
    "use",
    "handle",
    "work",
    "do",
    "make",
    "create",
    "run",
}


class AuditInputError(ValueError):
    """An actionable CLI input or registry error."""


def lexical_absolute(path: Path) -> Path:
    """Return an absolute path without resolving symlinks or junctions."""

    return Path(os.path.abspath(os.fspath(path.expanduser())))


@dataclass
class SkillAudit:
    path: Path
    display_path: str
    name: str = ""
    description: str = ""
    when_to_use: str = ""
    compatibility: str = ""
    allow_implicit_invocation: bool = True
    body_lines: int = 0
    body_token_estimate: int = 0
    sentence_count: int = 0
    batch: int = 0
    errors: list[str] = field(default_factory=list)
    warnings: list[str] = field(default_factory=list)
    risks: list[str] = field(default_factory=list)

    @property
    def description_length(self) -> int:
        return len(self.description)

    @property
    def listing_text_length(self) -> int:
        return len(self.description) + len(self.when_to_use)

    @property
    def absolute_budget(self) -> int:
        """Lexical absolute discovery cost; retained as a compatibility name."""

        return len(str(lexical_absolute(self.path))) + len(self.name) + len(self.description)

    @property
    def relative_budget(self) -> int:
        """Portable source discovery cost; retained as a compatibility name."""

        return len(self.display_path) + len(self.name) + len(self.description)


@dataclass(frozen=True)
class Catalogs:
    public: frozenset[str]
    expert: frozenset[str]
    all: frozenset[str]
    errors: tuple[str, ...] = ()

    def names(self, catalog: str) -> frozenset[str]:
        return getattr(self, catalog)


@dataclass
class RuntimeReport:
    root: Path
    audits: list[SkillAudit]
    selected: list[SkillAudit]
    lexical_budget: int
    errors: list[str] = field(default_factory=list)


def positive_int(value: str) -> int:
    try:
        parsed = int(value)
    except ValueError as exc:
        raise argparse.ArgumentTypeError("must be an integer") from exc
    if parsed <= 0:
        raise argparse.ArgumentTypeError("must be greater than zero")
    return parsed


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--skills-root",
        default="skills",
        help="Directory containing source skill folders. Defaults to ./skills.",
    )
    parser.add_argument(
        "--registry",
        help="Invocation registry. Defaults to <skills-root>/references/skill-invocation-registry.json.",
    )
    parser.add_argument(
        "--catalog",
        choices=("public", "expert", "all"),
        default="all",
        help="Registry-derived catalog used for discovery budgeting. Defaults to all.",
    )
    parser.add_argument(
        "--discovery-mode",
        choices=("implicit", "installed"),
        default="implicit",
        help="Budget implicit skills only or every installed skill in the catalog. Defaults to implicit.",
    )
    parser.add_argument(
        "--runtime-skills-root",
        action="append",
        default=[],
        help="Runtime skills directory to audit lexically; repeat for multiple runtimes.",
    )
    parser.add_argument(
        "--budget",
        type=positive_int,
        default=AGGREGATE_BUDGET,
        help=f"Aggregate character budget. Defaults to {AGGREGATE_BUDGET}.",
    )
    parser.add_argument(
        "--format",
        choices=("text", "markdown"),
        default="text",
        help="Output format. Defaults to text.",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Exit non-zero when warnings are present, not only hard violations.",
    )
    parser.add_argument(
        "--check-names",
        action="store_true",
        help="Compatibility flag; name checks always run.",
    )
    parser.add_argument(
        "--check-paths",
        action="store_true",
        help="Compatibility flag; path checks always run.",
    )
    parser.add_argument(
        "--batch-size",
        type=positive_int,
        default=DEFAULT_BATCH_SIZE,
        help=f"Suggested remediation batch size. Defaults to {DEFAULT_BATCH_SIZE}.",
    )
    return parser.parse_args(argv)


def iter_skill_files(skills_root: Path) -> list[Path]:
    if not skills_root.exists():
        raise AuditInputError(f"skills root not found: {skills_root}")
    if not skills_root.is_dir():
        raise AuditInputError(f"skills root is not a directory: {skills_root}")
    files = sorted(skills_root.glob("*/SKILL.md"))
    if not files:
        raise AuditInputError(f"no skill files found under: {skills_root}")
    return files


def display_path(path: Path, skills_root: Path) -> str:
    try:
        relative = path.relative_to(skills_root)
        return str(Path(skills_root.name) / relative)
    except ValueError:
        return str(path)


def estimate_tokens(text: str) -> int:
    return (len(text) + 3) // 4


def read_frontmatter(path: Path) -> tuple[dict[str, str], list[str], int, int]:
    try:
        text = path.read_text(encoding="utf-8")
    except (OSError, UnicodeError) as exc:
        return {}, [f"cannot read SKILL.md: {exc}"], 0, 0
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return {}, ["missing YAML frontmatter"], len(lines), estimate_tokens(text)

    end_index = None
    for index, line in enumerate(lines[1:], start=1):
        if line.strip() == "---":
            end_index = index
            break
    if end_index is None:
        return {}, ["missing closing YAML frontmatter delimiter"], len(lines), estimate_tokens(text)

    fields: dict[str, str] = {}
    errors: list[str] = []
    multiline_keys: list[str] = []
    for line in lines[1:end_index]:
        stripped = line.strip()
        if not stripped or stripped.startswith("#") or stripped.startswith("-"):
            continue
        match = re.match(r"^([A-Za-z_][A-Za-z0-9_-]*):(?:\s*(.*))?$", line)
        if not match:
            continue
        key, value = match.groups()
        clean_value = (value or "").strip()
        if clean_value in {"|", ">"}:
            multiline_keys.append(key)
            fields[key] = clean_value
            continue
        fields[key] = clean_value.strip("\"'")

    if "description" in multiline_keys:
        errors.append("description must be a single-line YAML scalar")

    body_text = "\n".join(lines[end_index + 1 :])
    return fields, errors, len(lines), estimate_tokens(body_text)


def _yaml_scalar(value: str) -> str:
    return re.split(r"\s+#", value, maxsplit=1)[0].strip().strip("\"'")


def read_invocation_policy(skill_dir: Path) -> tuple[bool, list[str]]:
    """Read the one policy field needed by the audit without a YAML dependency."""

    policy_path = skill_dir / "agents" / "openai.yaml"
    if not policy_path.exists():
        return True, []
    try:
        lines = policy_path.read_text(encoding="utf-8").splitlines()
    except (OSError, UnicodeError) as exc:
        return True, [f"agents/openai.yaml cannot be read: {exc}"]

    values: list[str] = []
    in_policy = False
    policy_indent = 0
    errors: list[str] = []
    for line_number, line in enumerate(lines, start=1):
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        indent = len(line) - len(line.lstrip())
        stripped = line.strip()
        if indent == 0 and stripped.startswith("policy:"):
            in_policy = True
            policy_indent = indent
            remainder = stripped.partition(":")[2].strip()
            if remainder:
                inline = re.fullmatch(
                    r"\{\s*allow_implicit_invocation\s*:\s*([^,}]+)\s*,?\s*\}",
                    remainder,
                )
                if inline:
                    values.append(_yaml_scalar(inline.group(1)))
                elif remainder != "{}":
                    errors.append(f"agents/openai.yaml:{line_number}: policy must be a mapping")
            continue
        if indent <= policy_indent:
            in_policy = False
        if in_policy:
            match = re.match(r"^allow_implicit_invocation\s*:\s*(.*)$", stripped)
            if match:
                values.append(_yaml_scalar(match.group(1)))

    if len(values) > 1:
        errors.append("agents/openai.yaml: allow_implicit_invocation must be declared once")
    if not values:
        return True, errors
    normalized = values[-1].lower()
    if normalized not in {"true", "false"}:
        errors.append("agents/openai.yaml: allow_implicit_invocation must be true or false")
        return True, errors
    return normalized == "true", errors


def sentence_count(description: str) -> int:
    if not description:
        return 0
    boundaries = re.findall(r"[.!?](?=\s|$)", description)
    return max(1, len(boundaries))


def first_word(description: str) -> str:
    match = re.match(r"^[^A-Za-z0-9]*([A-Za-z0-9-]+)", description)
    return match.group(1).lower() if match else ""


def audit_skill(path: Path, skills_root: Path, batch: int) -> SkillAudit:
    audit = SkillAudit(path=path, display_path=display_path(path, skills_root), batch=batch)
    fields, initial_errors, body_lines, body_token_estimate = read_frontmatter(path)
    audit.errors.extend(initial_errors)
    audit.body_lines = body_lines
    audit.body_token_estimate = body_token_estimate
    audit.name = fields.get("name", "")
    audit.description = fields.get("description", "")
    audit.when_to_use = fields.get("when_to_use", "")
    audit.compatibility = fields.get("compatibility", "")
    audit.sentence_count = sentence_count(audit.description)
    implicit, policy_errors = read_invocation_policy(path.parent)
    audit.allow_implicit_invocation = implicit
    audit.errors.extend(policy_errors)

    expected_name = path.parent.name
    expected_parent = lexical_absolute(skills_root)
    actual_parent = lexical_absolute(path.parent.parent)

    if not audit.name:
        audit.errors.append("missing name")
    elif audit.name != expected_name:
        audit.errors.append(f"name must match directory ({expected_name})")
    if audit.name and len(audit.name) > NAME_MAX:
        audit.errors.append(f"name exceeds {NAME_MAX} characters")
    if audit.name and not VALID_NAME.match(audit.name):
        audit.errors.append("name must use lowercase letters, numbers, and hyphens only")
    if audit.name and (audit.name.startswith("-") or audit.name.endswith("-")):
        audit.errors.append("name must not start or end with a hyphen")
    if audit.name and "--" in audit.name:
        audit.errors.append("name must not contain consecutive hyphens")
    if audit.name and XML_TAG.search(audit.name):
        audit.errors.append("name must not contain XML/HTML tags")

    if actual_parent != expected_parent:
        audit.errors.append("path must match skills/<name>/SKILL.md")

    if not audit.description:
        audit.errors.append("missing description")
    else:
        if "Args:" in audit.description:
            audit.errors.append("description must not contain Args:")
        if XML_TAG.search(audit.description):
            audit.errors.append("description must not contain XML/HTML tags")
        if audit.description_length > AGENT_SKILLS_DESCRIPTION_MAX:
            audit.errors.append(f"description exceeds Agent Skills maximum ({AGENT_SKILLS_DESCRIPTION_MAX})")
        if audit.description_length > DESCRIPTION_HARD_MAX:
            audit.errors.append(f"description exceeds {DESCRIPTION_HARD_MAX} characters")
        elif audit.description_length > DESCRIPTION_WARNING_MAX:
            audit.warnings.append(f"description exceeds warning threshold ({DESCRIPTION_WARNING_MAX})")
        if audit.listing_text_length > CLAUDE_LISTING_TEXT_MAX:
            audit.errors.append(
                f"description + when_to_use exceeds Claude listing cap ({CLAUDE_LISTING_TEXT_MAX})"
            )
        if audit.sentence_count > 1:
            audit.errors.append("description must be one sentence maximum")
        if first_word(audit.description) in GENERIC_STARTS:
            audit.warnings.append("description starts with a generic verb; front-load trigger keywords")

    if audit.compatibility and len(audit.compatibility) > COMPATIBILITY_MAX:
        audit.errors.append(f"compatibility exceeds {COMPATIBILITY_MAX} characters")

    if audit.body_lines > 500:
        audit.risks.append("SKILL.md exceeds 500 lines; separate body-size risk, not an initial discovery blocker")
    if audit.body_token_estimate > BODY_TOKEN_RISK:
        audit.risks.append(
            f"SKILL.md body is about {audit.body_token_estimate} tokens; consider moving detail to references/"
        )

    return audit


def audit_all(skills_root: Path, batch_size: int) -> list[SkillAudit]:
    files = iter_skill_files(skills_root)
    return [
        audit_skill(path, skills_root, (index // max(1, batch_size)) + 1)
        for index, path in enumerate(files)
    ]


def load_registry(path: Path) -> dict[str, Any]:
    if not path.exists():
        raise AuditInputError(f"registry not found: {path}")
    if not path.is_file():
        raise AuditInputError(f"registry is not a file: {path}")
    try:
        registry = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as exc:
        raise AuditInputError(f"cannot read registry {path}: {exc}") from exc
    if not isinstance(registry, dict) or not isinstance(registry.get("public_catalog"), dict):
        raise AuditInputError(f"registry missing public_catalog object: {path}")
    return registry


def _public_names(registry: dict[str, Any]) -> set[str]:
    catalog = registry["public_catalog"]
    names: set[str] = set()
    for domain in catalog.get("domains", []):
        if not isinstance(domain, dict):
            continue
        for skill in domain.get("skills", []):
            if isinstance(skill, dict) and isinstance(skill.get("public_skill"), str):
                names.add(skill["public_skill"])
    router = catalog.get("router")
    if isinstance(router, dict) and isinstance(router.get("public_skill"), str):
        names.add(router["public_skill"])
    return names


def _declared_engine_names(value: Any) -> set[str]:
    names: set[str] = set()
    if isinstance(value, dict):
        for key, child in value.items():
            if key == "runtime_skill" or key == "runtime_engine":
                if isinstance(child, str):
                    names.add(child)
            elif key == "internal_engines" and isinstance(child, list):
                names.update(item for item in child if isinstance(item, str))
            else:
                names.update(_declared_engine_names(child))
    elif isinstance(value, list):
        for child in value:
            names.update(_declared_engine_names(child))
    return names


def build_catalogs(registry: dict[str, Any], available_names: set[str]) -> Catalogs:
    public = _public_names(registry)
    declared_expert = _declared_engine_names(registry.get("public_catalog", {}))
    declared_expert.update(_declared_engine_names(registry.get("codex_expert_aliases", {})))
    declared_expert.difference_update(public)

    internal = registry.get("internal_catalog", {})
    include_all = isinstance(internal, dict) and internal.get("include_all_runtime_skills") is True
    expert = (available_names - public) if include_all else (declared_expert & available_names)
    all_names = public | expert
    missing_public = sorted(public - available_names)
    errors = tuple(f"public catalog skill missing on disk: {name}" for name in missing_public)
    return Catalogs(frozenset(public), frozenset(expert), frozenset(all_names), errors)


def select_audits(
    audits: list[SkillAudit], catalogs: Catalogs, catalog: str, discovery_mode: str
) -> list[SkillAudit]:
    catalog_names = catalogs.names(catalog)
    return [
        audit
        for audit in audits
        if audit.name in catalog_names
        and (discovery_mode == "installed" or audit.allow_implicit_invocation)
    ]


def summary(audits: list[SkillAudit]) -> dict[str, float | int]:
    count = len(audits)
    absolute = sum(audit.absolute_budget for audit in audits)
    relative = sum(audit.relative_budget for audit in audits)
    description = sum(audit.description_length for audit in audits)
    return {
        "skills": count,
        "errors": sum(len(audit.errors) for audit in audits),
        "warnings": sum(len(audit.warnings) for audit in audits),
        "risks": sum(len(audit.risks) for audit in audits),
        "absolute_budget": absolute,
        "relative_budget": relative,
        "description_chars": description,
        "average_description": round(description / count, 1) if count else 0,
        "over_200": sum(1 for audit in audits if audit.description_length > DESCRIPTION_HARD_MAX),
        "over_140": sum(1 for audit in audits if audit.description_length > DESCRIPTION_WARNING_MAX),
        "over_120": sum(1 for audit in audits if audit.description_length > DESCRIPTION_TARGET_MAX),
        "long_bodies": sum(1 for audit in audits if audit.body_lines > 500),
        "body_token_risks": sum(1 for audit in audits if audit.body_token_estimate > BODY_TOKEN_RISK),
    }


def source_budget_errors(selected: list[SkillAudit], catalogs: Catalogs, budget: int) -> list[str]:
    errors = list(catalogs.errors)
    portable = sum(audit.relative_budget for audit in selected)
    if portable > budget:
        errors.append(f"portable source aggregate estimate exceeds {budget}: {portable}")
    return errors


def audit_runtime(
    root: Path,
    registry: dict[str, Any],
    catalog: str,
    discovery_mode: str,
    batch_size: int,
    budget: int,
) -> RuntimeReport:
    lexical_root = lexical_absolute(root)
    audits = audit_all(lexical_root, batch_size)
    catalogs = build_catalogs(registry, {audit.name for audit in audits if audit.name})
    selected = select_audits(audits, catalogs, catalog, discovery_mode)
    total = sum(audit.absolute_budget for audit in selected)
    errors = list(catalogs.errors)
    for audit in audits:
        errors.extend(f"{audit.display_path}: {error}" for error in audit.errors)
    if total > budget:
        errors.append(f"runtime lexical aggregate estimate exceeds {budget}: {total}")
    return RuntimeReport(lexical_root, audits, selected, total, errors)


def _print_common_text(totals: dict[str, float | int]) -> None:
    print(f"Skills: {totals['skills']}")
    print(f"Hard violations: {totals['errors']}")
    print(f"Warnings: {totals['warnings']}")
    print(f"Separate risks: {totals['risks']}")
    print(f"Average description length: {totals['average_description']}")
    print(f"Descriptions >200: {totals['over_200']}")
    print(f"Descriptions >140: {totals['over_140']}")
    print(f"Descriptions >120: {totals['over_120']}")
    print(f"Skill bodies >500 lines: {totals['long_bodies']}")
    print(f"Skill bodies >~5000 tokens: {totals['body_token_risks']}")


def print_text(
    audits: list[SkillAudit],
    selected: list[SkillAudit],
    catalog: str,
    discovery_mode: str,
    budget: int,
    aggregate_errors: list[str],
    runtimes: list[RuntimeReport],
) -> None:
    totals = summary(audits)
    selected_totals = summary(selected)
    print("Skill Budget Audit")
    _print_common_text(totals)
    print(f"Catalog: {catalog}")
    print(f"Discovery mode: {discovery_mode}")
    print(f"Budgeted skills: {selected_totals['skills']}")
    print(f"Repo-relative estimate (portable verdict): {selected_totals['relative_budget']} / {budget}")
    print(f"Absolute estimate (source diagnostic only): {selected_totals['absolute_budget']} / {budget}")
    for runtime in runtimes:
        print(
            f"Runtime lexical estimate [{runtime.root}]: {runtime.lexical_budget} / {budget} "
            f"({len(runtime.selected)} skills)"
        )
    for message in aggregate_errors:
        print(f"ERROR: {message}")
    for runtime in runtimes:
        for message in runtime.errors:
            print(f"ERROR [{runtime.root}]: {message}")
    print()

    for audit in audits:
        if not audit.errors and not audit.warnings and not audit.risks:
            continue
        print(f"{audit.display_path}")
        print(
            f"  name={audit.name or '-'} desc_len={audit.description_length} "
            f"listing_len={audit.listing_text_length} sentences={audit.sentence_count} "
            f"implicit={str(audit.allow_implicit_invocation).lower()} "
            f"lines={audit.body_lines} body_tokens~{audit.body_token_estimate} batch={audit.batch}"
        )
        for error in audit.errors:
            print(f"  ERROR: {error}")
        for warning in audit.warnings:
            print(f"  WARN: {warning}")
        for risk in audit.risks:
            print(f"  RISK: {risk}")


def markdown_escape(value: str) -> str:
    return value.replace("|", "\\|")


def print_markdown(
    audits: list[SkillAudit],
    selected: list[SkillAudit],
    catalog: str,
    discovery_mode: str,
    budget: int,
    aggregate_errors: list[str],
    runtimes: list[RuntimeReport],
) -> None:
    totals = summary(audits)
    selected_totals = summary(selected)
    print("## Skill Budget Audit")
    print()
    print(f"- Skills: {totals['skills']}")
    print(f"- Hard violations: {totals['errors']}")
    print(f"- Warnings: {totals['warnings']}")
    print(f"- Separate risks: {totals['risks']}")
    print(f"- Catalog: {catalog}")
    print(f"- Discovery mode: {discovery_mode}")
    print(f"- Budgeted skills: {selected_totals['skills']}")
    print(f"- Repo-relative estimate (portable verdict): {selected_totals['relative_budget']} / {budget}")
    print(f"- Absolute estimate (source diagnostic only): {selected_totals['absolute_budget']} / {budget}")
    print(f"- Average description length: {totals['average_description']}")
    print(f"- Descriptions >200: {totals['over_200']}")
    print(f"- Descriptions >140: {totals['over_140']}")
    print(f"- Descriptions >120: {totals['over_120']}")
    print(f"- Skill bodies >500 lines: {totals['long_bodies']}")
    print(f"- Skill bodies >~5000 tokens: {totals['body_token_risks']}")
    for runtime in runtimes:
        print(
            f"- Runtime lexical estimate `{runtime.root}`: {runtime.lexical_budget} / {budget} "
            f"({len(runtime.selected)} skills)"
        )
    for message in aggregate_errors:
        print(f"- ERROR: {message}")
    for runtime in runtimes:
        for message in runtime.errors:
            print(f"- ERROR `{runtime.root}`: {message}")
    print()
    print(
        "| Batch | Skill | Implicit | Description chars | Listing chars | Sentences | "
        "Lines | Body tokens est. | Status | Issues |"
    )
    print(
        "|-------|-------|----------|-------------------|---------------|-----------|"
        "-------|------------------|--------|--------|"
    )
    for audit in audits:
        issues = audit.errors + audit.warnings + audit.risks
        status = "fail" if audit.errors else "warn" if audit.warnings else "risk" if audit.risks else "ok"
        issue_text = "<br>".join(markdown_escape(issue) for issue in issues) or "-"
        print(
            f"| {audit.batch} | `{audit.display_path}` | {str(audit.allow_implicit_invocation).lower()} | "
            f"{audit.description_length} | {audit.listing_text_length} | {audit.sentence_count} | "
            f"{audit.body_lines} | {audit.body_token_estimate} | {status} | {issue_text} |"
        )


def run(args: argparse.Namespace) -> int:
    skills_root = lexical_absolute(Path(args.skills_root))
    registry_path = lexical_absolute(
        Path(args.registry) if args.registry else skills_root / "references" / "skill-invocation-registry.json"
    )
    audits = audit_all(skills_root, args.batch_size)
    registry = load_registry(registry_path)
    catalogs = build_catalogs(registry, {audit.name for audit in audits if audit.name})
    selected = select_audits(audits, catalogs, args.catalog, args.discovery_mode)
    aggregate_errors = source_budget_errors(selected, catalogs, args.budget)
    runtimes = [
        audit_runtime(
            Path(runtime_root),
            registry,
            args.catalog,
            args.discovery_mode,
            args.batch_size,
            args.budget,
        )
        for runtime_root in args.runtime_skills_root
    ]

    if args.format == "markdown":
        print_markdown(
            audits,
            selected,
            args.catalog,
            args.discovery_mode,
            args.budget,
            aggregate_errors,
            runtimes,
        )
    else:
        print_text(
            audits,
            selected,
            args.catalog,
            args.discovery_mode,
            args.budget,
            aggregate_errors,
            runtimes,
        )

    has_errors = any(audit.errors for audit in audits)
    has_warnings = any(audit.warnings for audit in audits)
    runtime_errors = any(runtime.errors for runtime in runtimes)
    if has_errors or aggregate_errors or runtime_errors or (args.strict and has_warnings):
        return 1
    return 0


def main(argv: list[str] | None = None) -> int:
    try:
        args = parse_args(argv)
        return run(args)
    except AuditInputError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
