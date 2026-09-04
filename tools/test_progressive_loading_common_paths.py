"""Declared common-path checkpoints; never assertions of complete live execution."""
import copy
import json
from pathlib import Path
import unittest

from tools.skill_activation_budget import audit_scenarios
from tools.skill_invocation_check import check

ROOT = Path(__file__).resolve().parents[1]
REGISTRY = ROOT / "skills/references/skill-invocation-registry.json"
PREFIX = "common-"

class CommonPathLoadingTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.registry = json.loads(REGISTRY.read_text(encoding="utf-8"))
        cls.scenarios = {k: v for k, v in cls.registry["activation_profiles"]["scenarios"].items() if k.startswith(PREFIX)}

    def test_checkpoint_budgets_depth_and_baseline_receipts(self):
        measured = audit_scenarios(self.registry)
        self.assertEqual(7, len(self.scenarios))
        for name, scenario in self.scenarios.items():
            with self.subTest(name=name):
                result = measured["scenarios"][name]
                self.assertEqual("valid", result["structural_status"])
                self.assertEqual("within_budget", result["budget_status"], result)
                self.assertEqual(result["selected_tokens"], sum(result["stage_increments"].values()))
                self.assertLessEqual(result["depth_after_selection"], scenario["budget"]["max_depth_after_selection"])
                self.assertLessEqual(result["depth_after_selection"], scenario["baseline_depth_after_selection"])
                self.assertEqual(scenario["baseline_tokens"], sum(r["tokens"] for r in scenario["baseline_reads"]))
                self.assertEqual(len(scenario["reads"]), len({r["path"] for r in scenario["reads"]}))
                self.assertTrue(all(len(r["sha256"]) == 64 for r in scenario["baseline_reads"]))
                self.assertTrue(scenario["checkpoint"] and scenario["assumptions"])
                self.assertIn("not observed", scenario["scope"])

    def test_direct_routes_do_not_activate_a_business_lifecycle(self):
        expected = {"skills/shipglows/SKILL.md", "skills/000-shipglows/SKILL.md", "skills/references/canonical-paths.md", "skills/references/skill-invocation-preflight.md"}
        for suffix in ("docs-direct", "verify-direct"):
            scenario = self.scenarios[PREFIX + suffix]
            self.assertEqual(expected, {r["path"] for r in scenario["reads"]})
            self.assertEqual(4436, scenario["budget"]["max_tokens"])
        self.assertEqual("103-sg-verify", check("sg-engineering verify implemented logic")["selected_internal_engine"])

    def test_missing_target_reduction_has_explicit_questions_and_no_invented_execution(self):
        name = PREFIX + "resume-missing"
        result = audit_scenarios(self.registry)["scenarios"][name]
        self.assertGreaterEqual(result["reduction_percent"], 25)
        paths = {r["path"] for r in self.scenarios[name]["reads"]}
        for ref in ("context-quality-contract", "question-contract", "operator-partnership-contract", "strategic-choice-contract", "reporting-blocked-and-audit"):
            self.assertIn("skills/references/" + ref + ".md", paths)
        self.assertNotIn("skills/references/intent-to-outcome-execution.md", paths)

    def test_inherited_proof_cascade_and_ui_gate_are_counted(self):
        bug = self.scenarios[PREFIX + "bug-proof-selection"]
        reads = {r["path"]: r for r in bug["reads"]}
        self.assertEqual(3, bug["baseline_depth_after_selection"])
        for leaf, parent in (("project-delivery-policy", "project-development-mode"), ("zombies-edge-case-heuristic", "spec-driven-development-discipline")):
            self.assertEqual("skills/references/" + parent + ".md", reads["skills/references/" + leaf + ".md"]["parent"])
        self.assertIn("skills/references/design-system-token-contract.md", {r["path"] for r in self.scenarios[PREFIX + "feature-approval"]["reads"]})

    def test_cold_path_budgets_detect_accidental_extra_reads(self):
        registry = copy.deepcopy(self.registry)
        name = PREFIX + "docs-direct"
        scenario = registry["activation_profiles"]["scenarios"][name]
        scenario["reads"].append(dict(path="skills/references/question-contract.md", parent=scenario["selected_engine"], stage="unnecessary", trigger="Negative control", reason="Deliberate irrelevant eager read"))
        result = audit_scenarios(registry)["scenarios"][name]
        self.assertEqual("over_budget", result["budget_status"])
        self.assertIn("max_tokens", result["violations"])

    def test_known_owners_do_not_load_the_matrix_or_document_dependency_closure(self):
        for name, scenario in self.scenarios.items():
            with self.subTest(name=name):
                paths = {r["path"] for r in scenario["reads"]}
                self.assertNotIn("skills/references/entrypoint-routing.md", paths)
                self.assertNotIn("skills/references/skill-execution-fidelity.md", paths)
                self.assertTrue(all(r["trigger"].strip() and r["reason"].strip() for r in scenario["reads"]))
                self.assertIn("No depends_on closure", scenario["scope"])

if __name__ == "__main__":
    unittest.main()
