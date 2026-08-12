#!/usr/bin/env python3
"""Audit local ShipGlows skills for plugin packaging readiness."""

from __future__ import annotations

import argparse
import json
import os
import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Iterable


PLUGIN_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SHIPGLOWS_ROOT = Path(os.environ.get("SHIPGLOWS_ROOT", Path.home() / "shipglows"))
CATALOG_PATH = PLUGIN_ROOT / "assets" / "pack-catalog.json"
TOKEN_ESTIMATE_DIVISOR = 4
BODY_TOKEN_RISK = 5000


@dataclass
class SkillSource:
    name: str
    path: Path
    body: str
    description: str = ""
    origin: str = "source"


@dataclass
class PackFinding:
    severity: str
    message: str
    path: str | None = None


@dataclass
class PackReport:
    pack_id: str
    status: str
    skills: list[str]
    findings: list[PackFinding] = field(default_factory=list)
    skill_origins: dict[str, str] = field(default_factory=dict)

    @property
    def hard_count(self) -> int:
        return sum(1 for finding in self.findings if finding.severity == "Hard")

    @property
    def review_count(self) -> int:
        return sum(1 for finding in self.findings if finding.severity == "Review")

    @property
    def info_count(self) -> int:
        return sum(1 for finding in self.findings if finding.severity == "Info")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--shipglows-root",
        default=str(DEFAULT_SHIPGLOWS_ROOT),
        help="Path to the local ShipGlows source tree.",
    )
    parser.add_argument(
        "--pack",
        action="append",
        help="Limit audit to one pack id. Can be passed multiple times.",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Emit machine-readable JSON.",
    )
    parser.add_argument(
        "--matrix",
        action="store_true",
        help="Emit a Markdown portability decision matrix.",
    )
    return parser.parse_args()


def load_catalog(path: Path) -> list[dict]:
    with path.open() as handle:
        payload = json.load(handle)
    packs = payload.get("packs")
    if not isinstance(packs, list):
        raise ValueError(f"{path} must contain a list field named 'packs'.")
    return packs


def parse_frontmatter(text: str) -> dict[str, str]:
    match = re.match(r"\A---\n(.*?)\n---\n", text, re.DOTALL)
    if not match:
        return {}
    result: dict[str, str] = {}
    for line in match.group(1).splitlines():
        if ":" not in line:
            continue
        key, value = line.split(":", 1)
        result[key.strip()] = value.strip().strip('"')
    return result


def discover_skills(skills_root: Path, origin: str = "source") -> dict[str, SkillSource]:
    result: dict[str, SkillSource] = {}
    for path in sorted(skills_root.glob("*/SKILL.md")):
        body = path.read_text()
        frontmatter = parse_frontmatter(body)
        name = frontmatter.get("name") or path.parent.name
        result[name] = SkillSource(
            name=name,
            path=path,
            body=body,
            description=frontmatter.get("description", ""),
            origin=origin,
        )
    return result


def discover_plugin_skills(plugin_root: Path) -> dict[str, SkillSource]:
    """Discover skills already bundled in the plugin.

    Bundled skills override source-corpus skills for portability reports because
    they represent the current public plugin surface.
    """
    return discover_skills(plugin_root / "skills", origin="plugin")


def estimate_tokens(text: str) -> int:
    return max(1, len(text) // TOKEN_ESTIMATE_DIVISOR)


def shared_reference_names(body: str) -> set[str]:
    return set(re.findall(r"skills/references/([A-Za-z0-9_.-]+\.md)", body))


def cross_skill_references(body: str) -> set[tuple[str, str]]:
    return set(
        re.findall(
            r"skills/([0-9]{3}-[A-Za-z0-9_.-]+)/references/([A-Za-z0-9_.-]+\.md)",
            body,
        )
    )


def local_reference_names(body: str) -> set[str]:
    names = set(re.findall(r"(?<!skills/)references/([A-Za-z0-9_.-]+\.md)", body))
    cross_skill_names = {reference_name for _, reference_name in cross_skill_references(body)}
    return {name for name in names if name != "pack-catalog.md" and name not in cross_skill_names}


def find_nonportable_lines(body: str) -> list[str]:
    patterns = [
        "$SHIPGLOWS_ROOT",
        "$HOME/.shipglows/runtime",
        "/home/claude/shipglows",
        "shipglows_data/",
        "tools/",
    ]
    lines: list[str] = []
    for line_number, line in enumerate(body.splitlines(), start=1):
        if any(pattern in line for pattern in patterns):
            lines.append(f"L{line_number}: {line.strip()}")
    return lines


def add_finding(
    report: PackReport,
    severity: str,
    message: str,
    path: Path | None = None,
) -> None:
    report.findings.append(
        PackFinding(
            severity=severity,
            message=message,
            path=str(path) if path is not None else None,
        )
    )


def audit_skill(
    report: PackReport,
    skill: SkillSource,
    shipglows_root: Path,
) -> None:
    shared_root = shipglows_root / "skills" / "references"
    for reference_name in sorted(shared_reference_names(skill.body)):
        reference_path = shared_root / reference_name
        if not reference_path.exists():
            add_finding(
                report,
                "Hard",
                f"{skill.name} references missing shared reference {reference_name}",
                skill.path,
            )

    for skill_name, reference_name in sorted(cross_skill_references(skill.body)):
        reference_path = shipglows_root / "skills" / skill_name / "references" / reference_name
        if not reference_path.exists():
            add_finding(
                report,
                "Hard",
                f"{skill.name} references missing cross-skill reference {skill_name}/references/{reference_name}",
                skill.path,
            )

    for reference_name in sorted(local_reference_names(skill.body)):
        reference_path = skill.path.parent / "references" / reference_name
        if not reference_path.exists():
            add_finding(
                report,
                "Hard",
                f"{skill.name} references missing skill-local reference {reference_name}",
                skill.path,
            )

    token_estimate = estimate_tokens(skill.body)
    if token_estimate > BODY_TOKEN_RISK:
        add_finding(
            report,
            "Review",
            f"{skill.name} body-size risk: about {token_estimate} tokens",
            skill.path,
        )

    nonportable_lines = find_nonportable_lines(skill.body)
    if nonportable_lines:
        sample = "; ".join(nonportable_lines[:2])
        add_finding(
            report,
            "Review",
            f"{skill.name} has source-tree assumptions to adapt before public packaging ({sample})",
            skill.path,
        )


def audit_pack(
    pack: dict,
    skills_by_name: dict[str, SkillSource],
    plugin_skills_by_name: dict[str, SkillSource],
    shipglows_root: Path,
) -> PackReport:
    pack_id = str(pack.get("id", "unknown"))
    status = str(pack.get("status", "unknown"))
    skill_names = [str(name) for name in pack.get("skills", [])]
    report = PackReport(pack_id=pack_id, status=status, skills=skill_names)

    for skill_name in skill_names:
        skill = plugin_skills_by_name.get(skill_name) or skills_by_name.get(skill_name)
        if skill is None:
            report.skill_origins[skill_name] = "missing"
            add_finding(report, "Hard", f"Missing source skill {skill_name}")
            continue
        report.skill_origins[skill_name] = skill.origin
        audit_skill(report, skill, shipglows_root)

    if not report.findings:
        add_finding(report, "Info", "No packaging findings for cataloged skills")
    return report


def select_packs(packs: Iterable[dict], selected: set[str] | None) -> list[dict]:
    result = []
    for pack in packs:
        pack_id = str(pack.get("id", "unknown"))
        if selected is None or pack_id in selected:
            result.append(pack)
    return result


def report_as_json(reports: list[PackReport], shipglows_root: Path) -> None:
    payload = {
        "shipglows_root": str(shipglows_root),
        "packs": [
            {
                "id": report.pack_id,
                "status": report.status,
                "skills": report.skills,
                "hard_findings": report.hard_count,
                "review_findings": report.review_count,
                "info_findings": report.info_count,
                "skill_origins": report.skill_origins,
                "findings": [
                    {
                        "severity": finding.severity,
                        "message": finding.message,
                        "path": finding.path,
                    }
                    for finding in report.findings
                ],
            }
            for report in reports
        ],
    }
    print(json.dumps(payload, indent=2))


def report_as_text(reports: list[PackReport], shipglows_root: Path) -> None:
    print(f"Auditing ShipGlows packaging under {shipglows_root}")
    print()
    total_hard = sum(report.hard_count for report in reports)
    total_review = sum(report.review_count for report in reports)
    total_info = sum(report.info_count for report in reports)
    print("Summary")
    print(f"- Packs audited: {len(reports)}")
    print(f"- Hard findings: {total_hard}")
    print(f"- Review findings: {total_review}")
    print(f"- Info findings: {total_info}")
    print()

    for report in reports:
        print(f"{report.pack_id} ({report.status})")
        print(f"  Skills: {len(report.skills)}")
        visible_findings = report.findings[:8]
        for finding in visible_findings:
            suffix = f" [{finding.path}]" if finding.path else ""
            print(f"  {finding.severity}: {finding.message}{suffix}")
        hidden_count = len(report.findings) - len(visible_findings)
        if hidden_count > 0:
            print(f"  ... {hidden_count} more finding(s)")
        print()

    if total_hard:
        print("Hard findings must be fixed before packaging those packs.")
    elif total_review:
        print("Review findings need a portability pass before public packaging.")
    else:
        print("Cataloged packs are ready for a first packaging copy pass.")


def classify_portability(finding: PackFinding) -> str:
    message = finding.message
    if "source-tree assumptions" in message:
        return "source-root dependency"
    if "missing shared reference" in message:
        return "missing shared reference"
    if "missing cross-skill reference" in message:
        return "missing cross-skill reference"
    if "missing skill-local reference" in message:
        return "missing local reference"
    if "body-size risk" in message:
        return "body-size risk"
    if "Missing source skill" in message:
        return "missing source skill"
    return "other"


def recommended_action(category: str) -> str:
    if category == "source-root dependency":
        return "Adapt before bundling: replace source-tree assumptions with plugin-local references, complete-corpus setup access, or explicit non-bundled status."
    if category in {"missing shared reference", "missing cross-skill reference", "missing local reference"}:
        return "Package execution-critical reference locally or require complete ShipGlows corpus setup."
    if category == "body-size risk":
        return "Move bulky playbook detail into references before public bundling."
    if category == "missing source skill":
        return "Do not bundle until the source skill exists in the public source corpus."
    return "Review manually before public packaging."


def report_as_matrix(reports: list[PackReport], shipglows_root: Path) -> None:
    print("# ShipGlows Plugin Portability Matrix")
    print()
    print(f"Source corpus: `{shipglows_root}`")
    print()
    print("| Pack | Skill | Status | Finding type | Decision | Recommended action |")
    print("| --- | --- | --- | --- | --- | --- |")
    for report in reports:
        findings_by_skill: dict[str, list[PackFinding]] = {skill: [] for skill in report.skills}
        pack_level_findings: list[PackFinding] = []
        for finding in report.findings:
            matched = False
            for skill in report.skills:
                if finding.message.startswith(skill):
                    findings_by_skill[skill].append(finding)
                    matched = True
                    break
            if not matched:
                pack_level_findings.append(finding)

        for skill in report.skills:
            findings = findings_by_skill.get(skill, [])
            if not findings:
                origin = report.skill_origins.get(skill, "source")
                if origin == "plugin":
                    decision = "bundled public skill"
                    action = "Already bundled in the plugin; keep plugin-local references aligned with the catalog."
                else:
                    decision = "packable candidate"
                    action = "No portability finding from audit."
                print(
                    f"| `{report.pack_id}` | `{skill}` | `{report.status}` | none | {decision} | {action} |"
                )
                continue
            categories = sorted({classify_portability(finding) for finding in findings})
            action = " ".join(recommended_action(category) for category in categories)
            decision = "not public-bundlable yet" if any(f.severity != "Info" for f in findings) else "packable candidate"
            print(
                f"| `{report.pack_id}` | `{skill}` | `{report.status}` | {', '.join(categories)} | {decision} | {action} |"
            )

        for finding in pack_level_findings:
            category = classify_portability(finding)
            decision = "blocked" if finding.severity == "Hard" else "review"
            print(
                f"| `{report.pack_id}` | pack-level | `{report.status}` | {category} | {decision} | {recommended_action(category)} |"
            )


def main() -> int:
    args = parse_args()
    shipglows_root = Path(args.shipglows_root).expanduser().resolve()
    skills_root = shipglows_root / "skills"

    if not CATALOG_PATH.exists():
        raise FileNotFoundError(f"Missing pack catalog: {CATALOG_PATH}")
    if not skills_root.exists():
        raise FileNotFoundError(f"Missing local ShipGlows skills root: {skills_root}")

    packs = load_catalog(CATALOG_PATH)
    selected = set(args.pack) if args.pack else None
    audited_packs = select_packs(packs, selected)
    if not audited_packs:
        raise ValueError("No matching packs found.")

    skills_by_name = discover_skills(skills_root)
    plugin_skills_by_name = discover_plugin_skills(PLUGIN_ROOT)
    reports = [
        audit_pack(pack, skills_by_name, plugin_skills_by_name, shipglows_root)
        for pack in audited_packs
    ]

    if args.json:
        report_as_json(reports, shipglows_root)
    elif args.matrix:
        report_as_matrix(reports, shipglows_root)
    else:
        report_as_text(reports, shipglows_root)
    return 1 if any(report.hard_count for report in reports) else 0


if __name__ == "__main__":
    raise SystemExit(main())
