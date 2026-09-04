#!/usr/bin/env python3
"""Tests for explicit reference-activation profile accounting."""

import json
import subprocess
import sys
from pathlib import Path
from tempfile import TemporaryDirectory
import unittest
from unittest.mock import patch

from tools.skill_activation_budget import audit_profiles, audit_scenarios, audit_trace
from tools.skill_invocation_check import check


ROOT = Path(__file__).resolve().parents[1]
REGISTRY = ROOT / "skills" / "references" / "skill-invocation-registry.json"


class ScenarioTests(unittest.TestCase):
    def setUp(self):
        self.temporary = TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        for name, count in (("entry", 40), ("engine", 80), ("leaf", 120), ("other", 160)):
            (self.root / name).write_text("x" * count, encoding="utf-8")
        self.scenario = {
            "entry": "entry", "selected_engine": "engine",
            "reads": [{"path": name, "parent": parent, "stage": stage,
                       "trigger": "fixture task", "reason": "fixture decision"}
                      for name, parent, stage in (("entry", None, "entry"),
                                                   ("engine", "entry", "selection"),
                                                   ("leaf", "engine", "action"))],
            "budget": {"max_tokens": 60, "max_depth_after_selection": 1},
            "baseline_tokens": 100, "min_reduction_percent": 40,
        }

    def audit(self):
        return audit_scenarios({"activation_profiles": {"scenarios": {"fixture": self.scenario}}}, self.root)

    def test_exact_thresholds_and_stages(self):
        payload = self.audit()
        self.assertEqual("valid", payload["status"], payload)
        result = payload["scenarios"]["fixture"]
        self.assertEqual(60, result["selected_tokens"])
        self.assertEqual({"entry": 10, "selection": 20, "action": 30}, result["stage_increments"])
        self.assertEqual(1, result["depth_after_selection"])
        self.assertEqual(40, result["reduction_percent"])

    def test_budget_failure_preserves_structural_validity(self):
        self.scenario["budget"] = {"max_tokens": 59, "max_depth_after_selection": 0}
        self.scenario["min_reduction_percent"] = 41
        result = self.audit()["scenarios"]["fixture"]
        self.assertEqual("valid", result["structural_status"])
        self.assertEqual("over_budget", result["budget_status"])
        self.assertEqual(3, len(result["violations"]))

    def test_required_reads_are_optional_and_do_not_change_cost(self):
        original = self.audit()
        self.scenario["required_reads"] = ["entry", "leaf"]
        self.assertEqual(original, self.audit())

    def test_omitted_required_read_fails_even_when_file_and_dependency_remain(self):
        (self.root / "engine").write_text(
            '---\nlinked_systems:\n  - leaf\ndepends_on:\n  - artifact: "leaf"\n'
            '    artifact_version: "1.0.0"\n    required_status: active\n---\n', encoding="utf-8")
        self.scenario["reads"].pop()
        self.assertEqual("valid", self.audit()["status"])
        self.scenario["required_reads"] = ["leaf"]
        self.assertTrue((self.root / "leaf").is_file())
        result = self.audit()["scenarios"]["fixture"]
        self.assertEqual("invalid", result["structural_status"])
        self.assertEqual("not_evaluated", result["budget_status"])
        self.assertIn("missing_required_read:leaf", result["errors"])

    def test_malformed_required_reads_fail_closed(self):
        for required in (None, [], "leaf", {}, [None], [1], [""], [" "],
                         ["leaf", "leaf"], ["./leaf"], ["../leaf"], ["a//leaf"],
                         ["a\\leaf"], ["missing"], [str(self.root / "leaf")]):
            with self.subTest(required=required):
                self.scenario["required_reads"] = required
                result = self.audit()["scenarios"]["fixture"]
                self.assertEqual("invalid", result["structural_status"])
                self.assertEqual("not_evaluated", result["budget_status"])

    def test_missing_cycle_outside_and_malformed(self):
        mutations = [
            lambda s: s["reads"][2].update(path="missing"),
            lambda s: s["reads"][1].update(parent="leaf"),
            lambda s: s["reads"][2].update(path="../outside"),
            lambda s: s["reads"][2].update(parent="undeclared"),
            lambda s: s["reads"][2].update(parent=None),
            lambda s: s["reads"][2].update(reason=""),
            lambda s: s.update(selected_engine=[]),
            lambda s: s.update(reads="bad"),
            lambda s: s.update(baseline_tokens=True),
            lambda s: s["budget"].update(max_tokens="60"),
            lambda s: s["reads"].append(dict(s["reads"][0])),
        ]
        original = json.dumps(self.scenario)
        for mutate in mutations:
            with self.subTest(mutation=mutate):
                self.scenario = json.loads(original)
                mutate(self.scenario)
                result = self.audit()["scenarios"]["fixture"]
                self.assertEqual("invalid", result["structural_status"])
                self.assertEqual("not_evaluated", result["budget_status"])

    def test_scenarios_do_not_union_alternatives(self):
        other = json.loads(json.dumps(self.scenario))
        other["reads"][2]["path"] = "other"
        other["budget"]["max_tokens"] = 70
        other["min_reduction_percent"] = 30
        payload = audit_scenarios({"activation_profiles": {"scenarios": {
            "first": self.scenario, "other": other}}}, self.root)
        self.assertEqual("valid", payload["status"], payload)
        self.assertEqual([60, 70], [r["selected_tokens"] for r in payload["scenarios"].values()])

    def test_observed_repeats_are_separate(self):
        result = audit_trace({"events": [{"path": p, "reason": "observed"}
                                         for p in ("entry", "engine", "entry")]}, self.root)
        self.assertEqual("valid", result["status"])
        self.assertEqual((30, 10, 40), (result["unique_tokens"], result["repeated_tokens"], result["total_tokens"]))
        self.assertEqual("invalid", audit_trace({"events": [{"path": "missing", "reason": "x"}]}, self.root)["status"])
        self.assertEqual("invalid", audit_trace([], self.root)["status"])

    def test_invalid_scenario_map_and_unknown_name(self):
        self.assertEqual("invalid", audit_scenarios({"activation_profiles": {"scenarios": []}})["status"])
        self.assertEqual("invalid", audit_scenarios({}, selected_scenario="unknown")["status"])
        for registry in ([], None, {"activation_profiles": []}, {},
                         {"activation_profiles": {"scenarios": {}}},
                         {"activation_profiles": {"scenarios": {1: {}, "text": {}}}}):
            with self.subTest(registry=registry):
                self.assertEqual("invalid", audit_scenarios(registry)["status"])

    def test_unreadable_and_non_utf8_reads_fail_closed(self):
        trace = {"events": [{"path": "entry", "reason": "observed"}]}
        (self.root / "entry").write_bytes(b"\xff")
        self.assertEqual("invalid", self.audit()["status"])
        self.assertEqual("invalid", audit_trace(trace, self.root)["status"])
        with patch("tools.skill_activation_budget.estimate_tokens", side_effect=PermissionError("unreadable")):
            self.assertEqual("invalid", self.audit()["status"])
            self.assertEqual("invalid", audit_trace(trace, self.root)["status"])

    def test_cli_input_errors_are_structured(self):
        registry = self.root / "registry.json"
        trace = self.root / "trace.json"
        base = [sys.executable, str(ROOT / "tools/skill_activation_budget.py"),
                "--registry", str(registry), "--format", "json"]
        for raw in (b"{", b"[]", b"null", b"\xff", b'{"activation_profiles": []}'):
            registry.write_bytes(raw)
            for selection in ([], ["--scenarios"]):
                result = subprocess.run(base + selection, capture_output=True, text=True, check=False)
                self.assertEqual(2, result.returncode, result.stderr)
                self.assertEqual("invalid", json.loads(result.stdout)["status"])
                self.assertNotIn("Traceback", result.stderr)
        registry.write_text("{}", encoding="utf-8")
        for raw in (b"{", b"[]", b"\xff"):
            trace.write_bytes(raw)
            result = subprocess.run(base + ["--scenarios", "--trace", str(trace)],
                                    capture_output=True, text=True, check=False)
            self.assertEqual(2, result.returncode, result.stderr)
            self.assertEqual("invalid", json.loads(result.stdout)["observed_trace"]["status"])
            self.assertNotIn("Traceback", result.stderr)
        registry.unlink()
        result = subprocess.run(base + ["--scenarios"], capture_output=True, text=True, check=False)
        self.assertEqual(2, result.returncode)
        self.assertEqual("invalid", json.loads(result.stdout)["status"])

    def test_cli_gates_scenario_and_trace_failures(self):
        with TemporaryDirectory(dir=ROOT) as temporary:
            folder = Path(temporary)
            read = folder / "read.md"
            read.write_text("x" * 40, encoding="utf-8")
            relative = read.relative_to(ROOT).as_posix()
            scenario = {"entry": relative, "selected_engine": relative,
                        "reads": [{"path": relative, "parent": None, "stage": "entry",
                                   "trigger": "test", "reason": "test"}],
                        "budget": {"max_tokens": 10, "max_depth_after_selection": 0},
                        "baseline_tokens": 20, "min_reduction_percent": 50}
            registry = folder / "registry.json"
            def run():
                registry.write_text(json.dumps({"activation_profiles": {"scenarios": {"test": scenario}}}), encoding="utf-8")
                return subprocess.run([sys.executable, str(ROOT / "tools/skill_activation_budget.py"),
                                       "--registry", str(registry), "--scenario", "test", "--format", "json"],
                                      capture_output=True, text=True, check=False)
            success = run()
            self.assertEqual(0, success.returncode, success.stderr)
            scenario["budget"]["max_tokens"] = 9
            failure = run()
            self.assertEqual(2, failure.returncode, failure.stderr)
            self.assertEqual("over_budget", json.loads(failure.stdout)["scenarios"]["test"]["budget_status"])
            scenario["reads"][0]["path"] = "does-not-exist"
            self.assertEqual(2, run().returncode)


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
                "405-sg-prod", "601-sg-product-entitlements", "603-sg-private", "708-sg-auto",
                "900-shipglows-core",
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
