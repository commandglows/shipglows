import base64
import contextlib
import io
import json
import tempfile
import unittest
from pathlib import Path
from unittest import mock

from tools import shipglows_required_gate as gate


class RequiredGateContractTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.project = Path(self.temp.name)

    def tearDown(self):
        self.temp.cleanup()

    def write(self, relative: str, content: str = "") -> Path:
        path = self.project / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")
        return path

    def configured_contract(self) -> gate.ProjectContract:
        self.write(
            ".shipglows/required-gate.json",
            json.dumps({
                "production_branch": "main",
                "lanes": [
                    {"id": "app", "runtime": "flutter", "flutter_version": "3.47.1", "root": "app", "paths": ["app/**"], "commands": ["flutter analyze", "flutter test"]},
                    {"id": "site", "runtime": "node", "node_version": "24", "root": "site", "paths": ["site/**"], "commands": ["npm ci", "npm run check"]},
                ],
            }),
        )
        return gate.inspect_project(self.project)

    def test_gate_always_on_without_top_level_paths(self):
        workflow = gate.render_workflow(self.configured_contract())
        self.assertIn("name: ShipGlows required gate", workflow)
        self.assertIn('"on":\n  push:', workflow)
        self.assertIn("  pull_request:", workflow)
        self.assertIn("  workflow_dispatch:", workflow)
        self.assertNotRegex(workflow, r"(?m)^  paths(?:-ignore)?:")

    def test_path_selectivity_stays_inside_always_running_job(self):
        contract = self.configured_contract()
        workflow = gate.render_workflow(contract)
        self.assertIn("steps.impact.outputs['app'] == 'true'", workflow)
        self.assertIn("steps.impact.outputs['site'] == 'false'", workflow)
        self.assertIn("No site impact; lane intentionally skipped.", workflow)
        self.assertEqual({"app": False, "site": True}, gate.classify_changed_paths(contract, ["site/src/page.ts"]))
        self.assertEqual({"app": True, "site": True}, gate.classify_changed_paths(contract, [gate.WORKFLOW_RELATIVE.as_posix()]))

    def test_generate_then_audit_is_compliant(self):
        self.configured_contract()
        result = gate.main(["generate", "--project", str(self.project)])
        self.assertEqual(0, result)
        audit = gate.audit_project(self.project)
        self.assertTrue(audit["compliant"], audit["findings"])

    def test_audit_reports_drift(self):
        contract = self.configured_contract()
        path = self.write(str(gate.WORKFLOW_RELATIVE), gate.render_workflow(contract) + "# drift\n")
        self.assertTrue(path.exists())
        result = gate.audit_project(self.project)
        self.assertFalse(result["compliant"])
        self.assertIn("workflow drift: regenerate the canonical workflow", result["findings"])

    def test_audit_names_top_level_path_filter_deadlock(self):
        self.configured_contract()
        self.write(str(gate.WORKFLOW_RELATIVE), 'name: bad\n"on":\n  paths:\n    - app/**\n')
        result = gate.audit_project(self.project)
        self.assertIn("top-level path filter can deadlock the required status", result["findings"])

    def test_detects_node_and_flutter_lanes(self):
        self.write("site/package.json", json.dumps({"scripts": {"check": "astro check", "test:unit": "node --test", "build": "astro build"}}))
        self.write("site/pnpm-lock.yaml", "lockfileVersion: '9.0'\n")
        self.write(".node-version", "24\n")
        self.write("app/pubspec.yaml", "name: app\n")
        self.write("app/test/example_test.dart", "void main() {}\n")
        contract = gate.inspect_project(self.project)
        self.assertEqual(["app-flutter", "site-node"], sorted(lane.id for lane in contract.lanes))
        app_lane = next(lane for lane in contract.lanes if lane.id == "app-flutter")
        site = next(lane for lane in contract.lanes if lane.id == "site-node")
        self.assertEqual(("corepack enable && pnpm install --frozen-lockfile", "pnpm run check", "pnpm run test:unit", "pnpm run build"), site.commands)
        self.assertEqual("24", site.node_version)
        self.assertEqual("stable", app_lane.flutter_version)
        self.assertIn('node-version: "24"', gate.render_workflow(contract))

    def test_detects_node_version_from_package_engines(self):
        self.write("package.json", json.dumps({"engines": {"node": ">=24.0.0 <25"}, "scripts": {"test": "node --test"}}))
        self.write("package-lock.json", "{}")
        contract = gate.inspect_project(self.project)
        self.assertEqual(">=24.0.0 <25", contract.lanes[0].node_version)
        self.assertIn('node-version: ">=24.0.0 <25"', gate.render_workflow(contract))

    def test_rendered_flutter_lane_uses_explicit_flutter_version(self):
        self.write(
            ".shipglows/required-gate.json",
            json.dumps({
                "production_branch": "main",
                "lanes": [
                    {"id": "app", "runtime": "flutter", "flutter_version": "3.47.1", "root": "app", "paths": ["app/**"], "commands": ["flutter analyze", "flutter test"]},
                ],
            }),
        )
        contract = gate.inspect_project(self.project)
        self.assertEqual("3.47.1", contract.lanes[0].flutter_version)
        self.assertIn('flutter-version: "3.47.1"', gate.render_workflow(contract))

    def test_rejects_node_lane_without_declared_version(self):
        self.write("package.json", json.dumps({"scripts": {"test": "node --test"}}))
        self.write("package-lock.json", "{}")
        with self.assertRaisesRegex(gate.GateError, "declare Node"):
            gate.inspect_project(self.project)

    def test_ignores_legacy_agent_file_delivery_branch(self):
        self.write("CLAUDE.md", "## ShipGlows Delivery Policy\n\n- production_branch: stable\n")
        self.write("package.json", json.dumps({"engines": {"node": "24"}, "scripts": {"check": "node --check index.js"}}))
        self.write("package-lock.json", "{}")
        self.assertEqual("main", gate.inspect_project(self.project).production_branch)

    def test_unsafe_custom_command_is_rejected(self):
        self.write(
            ".shipglows/required-gate.json",
            json.dumps({"lanes": [{"id": "bad", "runtime": "shell", "paths": ["**"], "commands": ["firebase deploy"]}]}),
        )
        with self.assertRaisesRegex(gate.GateError, "forbidden command"):
            gate.inspect_project(self.project)

    def test_ruleset_plan_preserves_rules_and_requires_proven_check(self):
        contract = self.configured_contract()
        workflow = gate.render_workflow(contract)
        self.write(str(gate.WORKFLOW_RELATIVE), workflow)
        ruleset = {"id": 42, "name": "main", "target": "branch", "enforcement": "active", "conditions": {"ref_name": {"include": ["~DEFAULT_BRANCH"], "exclude": []}}, "rules": [{"type": "required_signatures"}]}
        remote = {"encoding": "base64", "content": base64.b64encode(workflow.encode()).decode()}
        with mock.patch.object(gate, "gh_api", side_effect=[remote, {"check_runs": [{"name": gate.REQUIRED_CHECK, "conclusion": "success"}]}, ruleset]):
            plan = gate.build_ruleset_plan(self.project, "owner/repo", 42)
        types = {rule["type"] for rule in plan["payload"]["rules"]}
        self.assertTrue({"required_signatures", "deletion", "non_fast_forward", "pull_request", "required_status_checks"}.issubset(types))

    def test_ruleset_plan_fails_before_protecting_unproven_check(self):
        contract = self.configured_contract()
        workflow = gate.render_workflow(contract)
        self.write(str(gate.WORKFLOW_RELATIVE), workflow)
        remote = {"encoding": "base64", "content": base64.b64encode(workflow.encode()).decode()}
        with mock.patch.object(gate, "gh_api", side_effect=[remote, {"check_runs": []}]):
            with self.assertRaisesRegex(gate.GateError, "No successful"):
                gate.build_ruleset_plan(self.project, "owner/repo", 42)

    def test_ruleset_plan_rejects_remote_workflow_drift(self):
        contract = self.configured_contract()
        workflow = gate.render_workflow(contract)
        self.write(str(gate.WORKFLOW_RELATIVE), workflow)
        remote = {"encoding": "base64", "content": base64.b64encode((workflow + "# drift\n").encode()).decode()}
        with mock.patch.object(gate, "gh_api", return_value=remote):
            with self.assertRaisesRegex(gate.GateError, "does not match"):
                gate.build_ruleset_plan(self.project, "owner/repo", 42)

    def test_ruleset_plan_rejects_wrong_branch_scope(self):
        contract = self.configured_contract()
        workflow = gate.render_workflow(contract)
        self.write(str(gate.WORKFLOW_RELATIVE), workflow)
        remote = {"encoding": "base64", "content": base64.b64encode(workflow.encode()).decode()}
        checks = {"check_runs": [{"name": gate.REQUIRED_CHECK, "conclusion": "success"}]}
        ruleset = {"name": "release", "target": "branch", "conditions": {"ref_name": {"include": ["refs/heads/release"]}}, "rules": []}
        with mock.patch.object(gate, "gh_api", side_effect=[remote, checks, ruleset]):
            with self.assertRaisesRegex(gate.GateError, "does not target production branch"):
                gate.build_ruleset_plan(self.project, "owner/repo", 42)

    def test_apply_requires_exact_confirmation(self):
        with mock.patch.object(gate, "build_ruleset_plan", return_value={"payload": {}}), mock.patch.object(gate, "gh_api") as api, contextlib.redirect_stderr(io.StringIO()):
            result = gate.main(["ruleset-apply", "--project", str(self.project), "--repository", "owner/repo", "--ruleset-id", "42", "--confirm", "no"])
        self.assertEqual(2, result)
        api.assert_not_called()

    def test_owner_surfaces_share_the_canonical_policy(self):
        root = Path(__file__).resolve().parents[1]
        delivery = (root / "skills/references/project-delivery-policy.md").read_text(encoding="utf-8")
        bootstrap = (root / "skills/305-sg-init/references/bootstrap-entrypoint-and-dev-mode.md").read_text(encoding="utf-8")
        hygiene = (root / "skills/010-sg-technical/references/github-hygiene-playbook.md").read_text(encoding="utf-8")
        verification = (root / "skills/103-sg-verify/references/verification-ci.md").read_text(encoding="utf-8")
        for surface in (delivery, bootstrap, hygiene, verification):
            self.assertIn("managed-project-ci-policy.md", surface)
            self.assertIn(gate.REQUIRED_CHECK, surface)
        self.assertIn("install plus prove", delivery)
        self.assertIn("ruleset-plan", hygiene)
        self.assertIn("no-impact", verification)


if __name__ == "__main__":
    unittest.main()
