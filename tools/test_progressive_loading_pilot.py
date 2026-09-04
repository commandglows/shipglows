"""Complete-path budgets and activation-critical invariants for the bounded pilot."""

import json
from pathlib import Path
import unittest

from tools.skill_activation_budget import audit_scenarios
from tools.skill_invocation_check import check


ROOT = Path(__file__).resolve().parents[1]
REFS = ROOT / "skills/references"


class ProgressiveLoadingPilotTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.registry = json.loads((REFS / "skill-invocation-registry.json").read_text(encoding="utf-8"))
        cls.scenarios = cls.registry["activation_profiles"]["scenarios"]
        cls.router = (ROOT / "skills/000-shipglows/SKILL.md").read_text(encoding="utf-8")
        cls.report = (REFS / "reporting-contract.md").read_text(encoding="utf-8")

    def test_complete_paths_meet_independent_budgets(self):
        result = audit_scenarios(self.registry)
        self.assertEqual("valid", result["status"], result["errors"])
        for name, scenario in self.scenarios.items():
            with self.subTest(name=name):
                measured = result["scenarios"][name]
                self.assertEqual(sum(measured["stage_increments"].values()), measured["selected_tokens"])
                self.assertLessEqual(measured["depth_after_selection"], scenario["budget"]["max_depth_after_selection"])
                if not name.startswith("common-"):
                    self.assertLessEqual(measured["depth_after_selection"], 2)
                self.assertEqual(sum(item["tokens"] for item in scenario["baseline_reads"]), scenario["baseline_tokens"])
                self.assertEqual(len(scenario["baseline_reads"]), len({item["path"] for item in scenario["baseline_reads"]}))
                self.assertTrue(all(len(item["sha256"]) == 64 for item in scenario["baseline_reads"]))
                if name.startswith("core-"):
                    self.assertGreaterEqual(measured["reduction_percent"], 40)

    def test_help_has_preflight_and_reporting_but_no_procedural_pack(self):
        scenario = self.scenarios["core-help"]
        paths = {item["path"] for item in scenario["reads"]}
        self.assertEqual({
            "skills/shipglows/SKILL.md", "skills/000-shipglows/SKILL.md",
            "skills/900-shipglows-core/SKILL.md",
            "skills/references/canonical-paths.md",
            "skills/references/expert-mode-aliases.md",
            "skills/references/skill-invocation-preflight.md",
            "skills/references/reporting-contract.md",
            "skills/references/next-outcome-selection.md",
        }, paths)
        self.assertIn("Pure help needs no outcome", self.router)
        self.assertIn("Do not load the matrix after a route is resolved", self.router)
        core = (ROOT / "skills/900-shipglows-core/SKILL.md").read_text(encoding="utf-8")
        self.assertIn("`help`: explain modes only; load no procedural pack", core)

    def test_audit_keeps_fidelity_execution_and_unfinished_choice(self):
        reads = {item["path"]: item for item in self.scenarios["core-skill-audit"]["reads"]}
        for name in ("intent-to-outcome-execution", "functional-excellence-contract", "skill-execution-fidelity"):
            self.assertIn(f"skills/references/{name}.md", reads)
        for name in ("reporting-blocked-and-audit", "strategic-choice-contract"):
            self.assertEqual("skills/references/reporting-contract.md", reads[f"skills/references/{name}.md"]["parent"])
        self.assertIn("Unfinished user result needs operator choices", self.report)
        leaf = (REFS / "reporting-blocked-and-audit.md").read_text(encoding="utf-8").split("---", 2)[2]
        self.assertNotIn("Load `skills/references/strategic-choice-contract.md`", leaf)
        self.assertIn("already selected by the reporting owner", leaf)

    def test_closure_authorities_remain_visible_before_leaf_selection(self):
        row = next(line for line in self.report.splitlines() if line.startswith("| Claim closed"))
        for name in ("reporting-closure.md", "documentation-reflection-gate.md", "editorial-reflection-gate.md"):
            self.assertIn(name, row)
        for name in ("reporting-start", "reporting-closure"):
            leaf = (REFS / f"{name}.md").read_text(encoding="utf-8").split("---", 2)[2]
            self.assertNotIn("Load `", leaf)
        self.assertIn("Missing required references block", self.report)
        self.assertIn("Include only checks actually run", self.report)
        self.assertIn("Never expose secrets", self.report)

    def test_direct_bounded_execution_and_scope_stop_are_preserved(self):
        self.assertLess(self.router.index("## Bounded Direct-Execution Gate"), self.router.index("## Shared Routing Reference"))
        self.assertIn("Do not load a domain or lifecycle skill", self.router)
        self.assertIn("Before any direct or routed mutation", self.router)
        self.assertIn("mutation-plan-approval.md", self.router)
        self.assertIn("does not authorize a chantier", self.router)
        self.assertIn("missing or invalid", (ROOT / "skills/shipglows/SKILL.md").read_text(encoding="utf-8"))
        self.assertIn("Material", (REFS / "intent-to-outcome-autonomy.md").read_text(encoding="utf-8"))

    def test_aliases_keep_authority_and_invalid_invocations_fail_closed(self):
        self.assertEqual("900-shipglows-core", check("shipglows core help")["selected_internal_engine"])
        self.assertEqual("invalid", check("shipglows auto #local")["status"])
        self.assertEqual("invalid", check("shipglows nolocal")["status"])
        result = check("shipglows nolocal inspect current project")
        self.assertEqual(["#nolocal"], result["effective_execution_tags"])
        self.assertIn("loads `no-local-execution-policy.md`", self.router)

    def test_advisory_and_document_validity_never_authorize_eager_reads(self):
        discovery = (REFS / "resource-discovery.md").read_text(encoding="utf-8")
        self.assertIn("This resolver is advisory discovery", discovery)
        self.assertIn("Read only the resources needed for the current decision", discovery)
        self.assertIn("not eager reads", self.report)
        for scenario in self.scenarios.values():
            self.assertTrue(all(item["trigger"].strip() and item["reason"].strip() for item in scenario["reads"]))


if __name__ == "__main__":
    unittest.main()
