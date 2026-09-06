"""Bounded capture pressure scenarios and complete declared-read regression guard."""
import copy
import json
import unittest
from pathlib import Path

from tools.skill_activation_budget import audit_scenarios

ROOT = Path(__file__).resolve().parents[1]
ENGINE = 'skills/011-sg-pilotage/SKILL.md'
PLAYBOOK = 'skills/011-sg-pilotage/references/tasks-playbook.md'


class PlanningTaskCaptureTests(unittest.TestCase):
    def setUp(self):
        self.engine = (ROOT / ENGINE).read_text(encoding='utf-8')
        self.playbook = (ROOT / PLAYBOOK).read_text(encoding='utf-8')
        self.registry = json.loads((ROOT / 'skills/references/skill-invocation-registry.json').read_text(encoding='utf-8'))

    def test_pressure_scenario_decisions_remain_explicit(self):
        # Prose contract checks, not a claim to execute an LLM routing policy.
        for requirement in (
            'no mode question is needed',
            'recorded, not executed',
            'ask only which project before any tracker read/write',
            'explicitly attached spec',
            'full tasks workflow and chantier tracking',
            'Clear editorial work uses',
        ):
            self.assertIn(requirement, self.engine)
        for requirement in (
            'never infer `done`', 'without evidence',
            'preserve its status and unknown fields',
            'conflicting records require clarification',
            'authoritatively re-read', 'smallest possible patch',
            're-read once and recompute', 'never reads `state_5.sqlite`',
            'does not run tests, install tools, commit, push',
        ):
            self.assertIn(requirement, self.playbook)

    def test_complete_path_retains_independent_required_reads_and_budget(self):
        result = audit_scenarios(self.registry, ROOT, 'planning-task-capture')
        self.assertEqual(result['status'], 'valid', result)
        scenario = self.registry['activation_profiles']['scenarios']['planning-task-capture']
        required = {
            ENGINE, PLAYBOOK,
            'skills/references/canonical-paths.md',
            'skills/references/operational-record-format.md',
            'skills/references/mutation-plan-approval.md',
            'skills/references/reporting-contract.md',
        }
        self.assertEqual(set(scenario['required_reads']), required)
        for path in required:
            changed = copy.deepcopy(self.registry)
            selected = changed['activation_profiles']['scenarios']['planning-task-capture']
            selected['reads'] = [r for r in selected['reads'] if r['path'] != path]
            self.assertEqual(audit_scenarios(changed, ROOT, 'planning-task-capture')['status'], 'invalid')

    def test_question_path_requires_only_factual_input_contracts(self):
        result = audit_scenarios(self.registry, ROOT, 'planning-project-question')
        self.assertEqual(result['status'], 'valid', result)
        selected = self.registry['activation_profiles']['scenarios']['planning-project-question']
        self.assertEqual(len(selected['reads']), 5)
        for path in selected['required_reads']:
            changed = copy.deepcopy(self.registry)
            scenario = changed['activation_profiles']['scenarios']['planning-project-question']
            scenario['reads'] = [r for r in scenario['reads'] if r['path'] != path]
            self.assertEqual(audit_scenarios(changed, ROOT, 'planning-project-question')['status'], 'invalid')

    def test_short_confirmation_does_not_remove_real_closure_gates(self):
        core = (ROOT / 'skills/references/reporting-contract.md').read_text(encoding='utf-8')
        self.assertIn('work-report conditions take precedence', core)
        for boundary in ('failed/uncertain writes', 'mixed execution', 'evidence-dependent status',
                         'material/security/permission decisions', 'requested detailed report/handoff',
                         'attached-spec tracing still apply', 'Recording completion is not chantier closure'):
            self.assertIn(boundary, core)
        closure = next(line for line in core.splitlines() if line.startswith('| Claim underlying work'))
        for leaf in ('reporting-closure.md', 'documentation-reflection-gate.md', 'editorial-reflection-gate.md'):
            self.assertIn(leaf, closure)
            witness = self.registry['activation_profiles']['scenarios']['quality-core-exact-correction']
            self.assertIn('skills/references/' + leaf, witness['required_reads'])

    def test_eager_full_workflow_regression_exceeds_budget(self):
        selected = self.registry['activation_profiles']['scenarios']['planning-task-capture']
        for name in ('intent-to-outcome-autonomy', 'functional-excellence-contract', 'task-registry-routing', 'chantier-tracking'):
            selected['reads'].append(dict(path=f'skills/references/{name}.md', parent=ENGINE, stage='execution', trigger='Unconditional regression', reason='Test rejects restoring unnecessary eager reads'))
        result = audit_scenarios(self.registry, ROOT, 'planning-task-capture')
        self.assertEqual(result['scenarios']['planning-task-capture']['budget_status'], 'over_budget')


if __name__ == '__main__':
    unittest.main()
