#!/usr/bin/env python3
"""Stage one ShipGlows catalog pack as a local Codex plugin candidate."""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
from datetime import datetime, timezone
from pathlib import Path


PLUGIN_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SHIPGLOWS_ROOT = Path(os.environ.get("SHIPGLOWS_ROOT", Path.home() / "shipglows"))
DEFAULT_OUTPUT_ROOT = Path.home() / ".shipglows" / "staged-packs"
CATALOG_PATH = PLUGIN_ROOT / "assets" / "pack-catalog.json"
TOKEN_ESTIMATE_DIVISOR = 4
BODY_TOKEN_RISK = 5000


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("pack", help="Pack id from assets/pack-catalog.json, for example shipglows-main.")
    parser.add_argument(
        "--shipglows-root",
        default=str(DEFAULT_SHIPGLOWS_ROOT),
        help="Path to the ShipGlows source corpus.",
    )
    parser.add_argument(
        "--output-root",
        default=str(DEFAULT_OUTPUT_ROOT),
        help="Directory where the staged pack plugin should be created.",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Replace an existing staged pack directory.",
    )
    parser.add_argument(
        "--allow-hard-findings",
        action="store_true",
        help="Stage even when hard audit findings exist. Off by default.",
    )
    return parser.parse_args()


def load_catalog() -> list[dict]:
    with CATALOG_PATH.open() as handle:
        payload = json.load(handle)
    packs = payload.get("packs")
    if not isinstance(packs, list):
        raise ValueError(f"{CATALOG_PATH} must contain a list field named 'packs'.")
    return packs


def find_pack(pack_id: str) -> dict:
    for pack in load_catalog():
        if pack.get("id") == pack_id:
            return pack
    raise ValueError(f"Pack not found in catalog: {pack_id}")


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


def discover_skill_path(shipglows_root: Path, skill_name: str) -> Path | None:
    skills_root = shipglows_root / "skills"
    exact = skills_root / skill_name / "SKILL.md"
    if exact.exists():
        return exact.parent
    for path in sorted(skills_root.glob("*/SKILL.md")):
        frontmatter = parse_frontmatter(path.read_text())
        if frontmatter.get("name") == skill_name:
            return path.parent
    return None


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


def nonportable_lines(body: str) -> list[str]:
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


def audit_skill(skill_name: str, skill_dir: Path, shipglows_root: Path) -> list[dict]:
    body = (skill_dir / "SKILL.md").read_text()
    findings: list[dict] = []

    for reference_name in sorted(shared_reference_names(body)):
        path = shipglows_root / "skills" / "references" / reference_name
        if not path.exists():
            findings.append(
                {
                    "severity": "Hard",
                    "skill": skill_name,
                    "message": f"missing shared reference {reference_name}",
                    "path": str(path),
                }
            )

    for referenced_skill, reference_name in sorted(cross_skill_references(body)):
        path = shipglows_root / "skills" / referenced_skill / "references" / reference_name
        if not path.exists():
            findings.append(
                {
                    "severity": "Hard",
                    "skill": skill_name,
                    "message": f"missing cross-skill reference {referenced_skill}/references/{reference_name}",
                    "path": str(path),
                }
            )

    for reference_name in sorted(local_reference_names(body)):
        path = skill_dir / "references" / reference_name
        if not path.exists():
            findings.append(
                {
                    "severity": "Hard",
                    "skill": skill_name,
                    "message": f"missing local reference {reference_name}",
                    "path": str(path),
                }
            )

    token_estimate = max(1, len(body) // TOKEN_ESTIMATE_DIVISOR)
    if token_estimate > BODY_TOKEN_RISK:
        findings.append(
            {
                "severity": "Review",
                "skill": skill_name,
                "message": f"body-size risk: about {token_estimate} tokens",
                "path": str(skill_dir / "SKILL.md"),
            }
        )

    lines = nonportable_lines(body)
    if lines:
        findings.append(
            {
                "severity": "Review",
                "skill": skill_name,
                "message": "source-tree assumptions to adapt before public packaging",
                "sample": lines[:3],
                "path": str(skill_dir / "SKILL.md"),
            }
        )
    return findings


def copytree(src: Path, dst: Path) -> None:
    shutil.copytree(src, dst, ignore=shutil.ignore_patterns("__pycache__", "*.pyc", ".DS_Store"))


def normalize_staged_skill(skill_path: Path) -> list[str]:
    body = skill_path.read_text()
    changes: list[str] = []
    next_body = re.sub(
        r"^disable-model-invocation:\s*true\s*$",
        "disable-model-invocation: false",
        body,
        flags=re.MULTILINE,
    )
    if next_body != body:
        changes.append("disable-model-invocation true -> false")
        skill_path.write_text(next_body)
    return changes


def copy_detected_references(skill_dir: Path, staged_root: Path, shipglows_root: Path) -> list[str]:
    body = (skill_dir / "SKILL.md").read_text()
    copied: list[str] = []
    staged_skills_root = staged_root / "skills"

    for reference_name in sorted(shared_reference_names(body)):
        src = shipglows_root / "skills" / "references" / reference_name
        if src.exists():
            dst = staged_root / "references" / "shared" / reference_name
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dst)
            copied.append(str(dst.relative_to(staged_root)))

    for referenced_skill, reference_name in sorted(cross_skill_references(body)):
        src = shipglows_root / "skills" / referenced_skill / "references" / reference_name
        if src.exists():
            dst = staged_skills_root / referenced_skill / "references" / reference_name
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dst)
            copied.append(str(dst.relative_to(staged_root)))
    return copied


def plugin_manifest(pack: dict, staged_skill_names: list[str]) -> dict:
    pack_id = str(pack["id"])
    return {
        "name": pack_id,
        "version": "0.1.0",
        "description": f"ShipGlows optional pack staged from catalog entry {pack_id}.",
        "author": {"name": "ShipGlows"},
        "homepage": "https://shipglowszsite.vercel.app/",
        "repository": "https://github.com/commandglows/shipglows",
        "license": "UNLICENSED",
        "keywords": ["codex", "shipglows", "workflow", "pack"],
        "skills": "./skills/",
        "interface": {
            "displayName": pack_id,
            "shortDescription": f"Optional ShipGlows pack: {pack_id}.",
            "longDescription": (
                f"{pack_id} is a staged optional ShipGlows pack. Review the generated "
                "audit report before treating it as public-ready."
            ),
            "developerName": "ShipGlows",
            "category": "Productivity",
            "capabilities": ["Read", "Write"],
            "defaultPrompt": [f"${staged_skill_names[0]} help"] if staged_skill_names else [],
            "brandColor": "#0F766E",
        },
    }


def write_json(path: Path, payload: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2) + "\n")


def stage_pack(args: argparse.Namespace) -> int:
    pack = find_pack(args.pack)
    shipglows_root = Path(args.shipglows_root).expanduser().resolve()
    output_root = Path(args.output_root).expanduser().resolve()
    staged_root = output_root / str(pack["id"])
    skills_root = staged_root / "skills"
    skill_names = [str(name) for name in pack.get("skills", [])]

    if not (shipglows_root / "skills").exists():
        raise FileNotFoundError(f"Missing ShipGlows skills root: {shipglows_root / 'skills'}")

    if staged_root.exists():
        if not args.force:
            raise FileExistsError(f"Staged pack already exists: {staged_root}. Use --force to replace it.")
        shutil.rmtree(staged_root)

    audit_findings: list[dict] = []
    skill_dirs: dict[str, Path] = {}
    for skill_name in skill_names:
        skill_dir = discover_skill_path(shipglows_root, skill_name)
        if skill_dir is None:
            audit_findings.append(
                {
                    "severity": "Hard",
                    "skill": skill_name,
                    "message": "missing source skill",
                    "path": str(shipglows_root / "skills" / skill_name),
                }
            )
            continue
        skill_dirs[skill_name] = skill_dir
        audit_findings.extend(audit_skill(skill_name, skill_dir, shipglows_root))

    hard_count = sum(1 for finding in audit_findings if finding["severity"] == "Hard")
    if hard_count and not args.allow_hard_findings:
        payload = {
            "pack": pack["id"],
            "shipglows_root": str(shipglows_root),
            "hard_findings": hard_count,
            "findings": audit_findings,
        }
        print(json.dumps(payload, indent=2))
        return 1

    staged_root.mkdir(parents=True)
    (staged_root / ".codex-plugin").mkdir()
    skills_root.mkdir()

    copied_references: list[str] = []
    normalized_skills: dict[str, list[str]] = {}
    staged_skill_names: list[str] = []
    for skill_name, skill_dir in skill_dirs.items():
        destination = skills_root / skill_dir.name
        copytree(skill_dir, destination)
        changes = normalize_staged_skill(destination / "SKILL.md")
        if changes:
            normalized_skills[skill_name] = changes
        copied_references.extend(copy_detected_references(skill_dir, staged_root, shipglows_root))
        staged_skill_names.append(skill_name)

    write_json(staged_root / ".codex-plugin" / "plugin.json", plugin_manifest(pack, staged_skill_names))
    write_json(
        staged_root / "shipglows-pack-report.json",
        {
            "generated_at": datetime.now(timezone.utc).replace(microsecond=0).isoformat(),
            "pack": pack,
            "shipglows_root": str(shipglows_root),
            "staged_root": str(staged_root),
            "skills": staged_skill_names,
            "copied_references": sorted(set(copied_references)),
            "normalized_skills": normalized_skills,
            "hard_findings": hard_count,
            "review_findings": sum(1 for finding in audit_findings if finding["severity"] == "Review"),
            "findings": audit_findings,
            "public_ready": hard_count == 0 and not any(
                finding["severity"] == "Review" for finding in audit_findings
            ),
        },
    )
    (staged_root / "README.md").write_text(
        f"# {pack['id']}\n\n"
        "This is a staged ShipGlows optional pack generated from `assets/pack-catalog.json`.\n"
        "Review `shipglows-pack-report.json` before installing or publishing it.\n",
    )

    print(f"Staged pack: {staged_root}")
    print(f"Skills copied: {len(staged_skill_names)}")
    print(f"Hard findings: {hard_count}")
    print(f"Review findings: {sum(1 for finding in audit_findings if finding['severity'] == 'Review')}")
    return 0


def main() -> int:
    return stage_pack(parse_args())


if __name__ == "__main__":
    raise SystemExit(main())
