#!/usr/bin/env python3
"""Tests for explicit reference-activation profile accounting."""

import json
from pathlib import Path
from tempfile import TemporaryDirectory
import unittest

from tools.skill_activation_budget import audit_profiles
from tools.skill_invocation_check import check


ROOT = Path(__file__).resolve().parents[1]
REGISTRY = ROOT / "skills" / "references" / "skill-invocation-registry.json"


class SkillActivationBudgetTests(unittest.TestCase):
    def test_selected_profile_is_part_of_invocation_preflight(self) -> None:
        release = check("sg-release")
        entitlement = check("601-sg-product-entitlements access audit")
        self.assertEqual("004-sg-deploy", release["activation_profile"])
        self.assertEqual("601-sg-product-entitlements", entitlement["activation_profile"])

    def test_pilot_profiles_are_valid_and_separate_gates(self) -> None:
        registry = json.loads(REGISTRY.read_text(encoding="utf-8"))
        payload = audit_profiles(registry)
        self.assertEqual("valid", payload["status"], payload["errors"])
        self.assertEqual(
            {
                "004-sg-deploy", "010-sg-technical", "103-sg-verify", "109-sg-auth-debug",
                "200-sg-redact", "201-sg-enrich", "300-sg-docs", "400-sg-audit",
                "405-sg-prod", "601-sg-product-entitlements", "900-shipglows-core",
            },
            set(payload["skills"]),
        )
        for skill, result in payload["skills"].items():
            self.assertGreater(result["baseline_tokens"], result["body_tokens"], skill)
            self.assertGreater(result["worst_case_tokens"], result["baseline_tokens"], skill)
            self.assertEqual([], result["missing"], skill)

    def test_shared_reference_is_counted_once(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            (root / "body.md").write_text("b" * 40, encoding="utf-8")
            (root / "ref.md").write_text("r" * 80, encoding="utf-8")
            registry = {"activation_profiles": {"skills": {"x": {
                "body": "body.md", "baseline": ["ref.md"],
                "gates": {"again": ["ref.md"]},
            }}}}
            result = audit_profiles(registry, root)["skills"]["x"]
            self.assertEqual(30, result["baseline_tokens"])
            self.assertEqual(0, result["gates"]["again"]["incremental_tokens"])
            self.assertEqual(30, result["worst_case_tokens"])

    def test_missing_reference_blocks_profile(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            (root / "body.md").write_text("body", encoding="utf-8")
            registry = {"activation_profiles": {"skills": {"x": {
                "body": "body.md", "baseline": [], "gates": {"broken": ["missing.md"]},
            }}}}
            payload = audit_profiles(registry, root)
            self.assertEqual("invalid", payload["status"])
            self.assertIn("missing_reference:x:broken:missing.md", payload["errors"])

    def test_broken_selected_profile_blocks_invocation(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            skills = root / "skills"
            for name in ("sg-alpha", "engine-alpha"):
                folder = skills / name
                folder.mkdir(parents=True)
                (folder / "SKILL.md").write_text("skill", encoding="utf-8")
            registry = {
                "public_catalog": {"domains": [{"id": "x", "skills": [{
                    "id": "sg-alpha", "public_skill": "sg-alpha",
                    "runtime_skill": "engine-alpha", "modes": ["default"],
                }]}]},
                "activation_profiles": {"skills": {"engine-alpha": {
                    "body": "skills/engine-alpha/SKILL.md",
                    "baseline": ["skills/references/missing.md"], "gates": {},
                }}},
            }
            registry_path = root / "registry.json"
            registry_path.write_text(json.dumps(registry), encoding="utf-8")
            index_path = root / "index.md"
            index_path.write_text("", encoding="utf-8")
            payload = check("sg-alpha", index_path, registry_path, skills)
            self.assertEqual("activation_profile_invalid", payload["error"])

    def test_broken_profile_dependency_blocks_invocation_preflight(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            skills = root / "skills"
            for name in ("sg-alpha", "engine-alpha"):
                folder = skills / name
                folder.mkdir(parents=True)
                (folder / "SKILL.md").write_text(
                    f"---\nname: {name}\ndescription: test\n---\n", encoding="utf-8"
                )
            refs = skills / "references"
            refs.mkdir()
            (refs / "base.md").write_text(
                "---\nartifact: technical_guidelines\nmetadata_schema_version: \"1.0\"\n"
                "artifact_version: \"1.0.0\"\nstatus: active\n"
                "depends_on:\n  - artifact: \"skills/references/target.md\"\n"
                "    artifact_version: \"2.0.0\"\n    required_status: active\n---\n",
                encoding="utf-8",
            )
            (refs / "target.md").write_text(
                "---\nartifact: technical_guidelines\nmetadata_schema_version: \"1.0\"\n"
                "artifact_version: \"1.0.0\"\nstatus: active\ndepends_on: []\n---\n",
                encoding="utf-8",
            )
            registry = {
                "public_catalog": {"domains": [{"id": "x", "skills": [{
                    "id": "sg-alpha", "public_skill": "sg-alpha",
                    "runtime_skill": "engine-alpha", "modes": ["default"],
                }]}]},
                "activation_profiles": {"skills": {"engine-alpha": {
                    "body": "skills/engine-alpha/SKILL.md",
                    "baseline": ["skills/references/base.md"], "gates": {},
                }}},
            }
            registry_path = root / "registry.json"
            registry_path.write_text(json.dumps(registry), encoding="utf-8")
            index_path = root / "index.md"
            index_path.write_text("", encoding="utf-8")
            payload = check("sg-alpha", index_path, registry_path, skills)
            self.assertEqual("resource_dependency_graph_invalid", payload["error"])
            self.assertTrue(any(error.startswith("version:") for error in payload["dependency_errors"]))

    def test_unknown_selected_skill_is_visible(self) -> None:
        payload = audit_profiles({"activation_profiles": {"skills": {}}}, selected_skill="missing")
        self.assertEqual(["missing_profile:missing"], payload["errors"])


if __name__ == "__main__":
    unittest.main()
