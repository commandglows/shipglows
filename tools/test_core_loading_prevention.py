"""Injected loading regressions must fail existing accounting/protection checks."""
import copy
import json
from pathlib import Path
import unittest

from tools.skill_activation_budget import audit_scenarios
from tools import test_progressive_loading_pilot as pilot_tests

ROOT = Path(__file__).resolve().parents[1]
REFS = ROOT / "skills/references"


class CoreLoadingPreventionTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.registry = json.loads((REFS / "skill-invocation-registry.json").read_text(encoding="utf-8"))

    def test_gate_is_visible_without_loading_procedure_for_help(self):
        core = (ROOT / "skills/900-shipglows-core/SKILL.md").read_text(encoding="utf-8")
        self.assertIn("Before changing references, triggers, shared doctrine or protections", core)
        self.assertIn("even when files shrink", core)
        self.assertIn("need/trigger/timing", core)
        self.assertIn("sole internal DX lifecycle owner", core)
        help_reads = self.registry["activation_profiles"]["scenarios"]["core-help"]["reads"]
        self.assertNotIn("skills/references/skill-context-budget.md", {r["path"] for r in help_reads})
        self.assertIn("`help`: explain modes only; load no procedural pack", core)
        for name in ("skill-maintenance-playbook", "skill-refresh-playbook", "core-audit-and-improvement"):
            pack = (ROOT / "skills/900-shipglows-core/references" / (name + ".md")).read_text(encoding="utf-8")
            self.assertIn("Loading Change Gate", pack)
            self.assertIn("even when files shrink", pack)

    def test_policy_keeps_proof_and_arbitration_separate_from_smaller_numbers(self):
        policy = (REFS / "skill-context-budget.md").read_text(encoding="utf-8")
        for text in ("including reporting", "Independently", "required_reads",
                     "never generates them", "explicit operator arbitration",
                     "never silently raise ceilings", "independent review remains required"):
            self.assertIn(text, policy)

    def test_unnecessary_eager_read_fails_unchanged_budget(self):
        r = copy.deepcopy(self.registry)
        s = r["activation_profiles"]["scenarios"]["common-docs-direct"]
        s["reads"].append(dict(path="skills/references/question-pressure-scenarios.md",
                               parent=s["selected_engine"], stage="extra", trigger="Injected eager read",
                               reason="Must not load cold examples for an exact edit"))
        result = audit_scenarios(r, selected_scenario="common-docs-direct")["scenarios"]["common-docs-direct"]
        self.assertIn("max_tokens", result["violations"])

    def test_cascade_fails_even_without_new_file_tokens(self):
        r = copy.deepcopy(self.registry)
        s = r["activation_profiles"]["scenarios"]["core-help"]
        parents = {
            "skills/references/reporting-contract.md": s["selected_engine"],
            "skills/references/skill-invocation-preflight.md": "skills/references/reporting-contract.md",
            "skills/references/canonical-paths.md": "skills/references/skill-invocation-preflight.md",
        }
        for read in s["reads"]:
            if read["path"] in parents:
                read["parent"] = parents[read["path"]]
        result = audit_scenarios(r, selected_scenario="core-help")["scenarios"]["core-help"]
        self.assertIn("max_depth_after_selection", result["violations"])
        self.assertNotIn("max_tokens", result["violations"])

    def test_omitted_required_read_cannot_win_on_tokens(self):
        r = copy.deepcopy(self.registry)
        s = r["activation_profiles"]["scenarios"]["common-docs-direct"]
        s["reads"] = [x for x in s["reads"] if not x["path"].endswith("canonical-paths.md")]
        result = audit_scenarios(r, selected_scenario="common-docs-direct")["scenarios"]["common-docs-direct"]
        self.assertEqual("invalid", result["structural_status"])
        self.assertEqual("not_evaluated", result["budget_status"])

    def test_removed_protection_fails_existing_independent_contract_check(self):
        proof = pilot_tests.ProgressiveLoadingPilotTests("test_direct_bounded_execution_and_scope_stop_are_preserved")
        proof.router = (ROOT / "skills/000-shipglows/SKILL.md").read_text(encoding="utf-8")
        proof.test_direct_bounded_execution_and_scope_stop_are_preserved()
        proof.router = proof.router.replace("Before any direct or routed mutation", "Mutation gate removed")
        with self.assertRaises(AssertionError):
            proof.test_direct_bounded_execution_and_scope_stop_are_preserved()


if __name__ == "__main__":
    unittest.main()
