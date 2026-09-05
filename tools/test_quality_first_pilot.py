"""Independent witnesses for declared quality pilot routes; not agent replay."""
import copy
import hashlib
import json
from pathlib import Path
import unittest

from tools.skill_activation_budget import audit_scenarios

ROOT = Path(__file__).resolve().parents[1]
REGISTRY = ROOT / 'skills/references/skill-invocation-registry.json'
BASELINE = ROOT / 'shipglows_data/workflow/reviews/quality-first-pilot-baseline.json'
NAMES = ('quality-core-exact-correction', 'quality-continue-proof-complete')
R = 'skills/references/'


class QualityPilotTests(unittest.TestCase):
    def setUp(self):
        self.registry = json.loads(REGISTRY.read_text(encoding='utf-8'))
        self.scenarios = self.registry['activation_profiles']['scenarios']

    def test_existing_scenarios_remain_unchanged(self):
        frozen = json.loads(BASELINE.read_text(encoding='utf-8'))
        for name, digest in frozen['existing_scenarios_sha256'].items():
            self.assertEqual(hashlib.sha256(json.dumps(self.scenarios[name], sort_keys=True).encode()).hexdigest(), digest, name)

    def test_complete_declared_routes_keep_structural_and_budget_results_separate(self):
        for name in NAMES:
            result = audit_scenarios(self.registry, ROOT, name)['scenarios'][name]
            self.assertEqual(result['structural_status'], 'valid')
            self.assertEqual(result['measurement'], 'declared_unique_reads')
            self.assertLessEqual(result['depth_after_selection'], 2)
            self.assertIn(result['budget_status'], ('within_budget', 'over_budget'))
            # Growth remains visible; a quality improvement does not turn it green.
            if result['selected_tokens'] > self.scenarios[name]['budget']['max_tokens']:
                self.assertIn('max_tokens', result['violations'])
            self.assertIn('not observed', self.scenarios[name]['scope'])

    def test_omitting_independent_authority_or_proof_witness_is_rejected(self):
        cases = {NAMES[0]: ['mutation-plan-approval.md', 'spec-driven-development-discipline.md', 'skill-instruction-layering.md'],
                 NAMES[1]: ['context-quality-contract.md']}
        for name, witnesses in cases.items():
            for leaf in witnesses + ['reporting-closure.md', 'documentation-reflection-gate.md', 'editorial-reflection-gate.md']:
                broken = copy.deepcopy(self.registry)
                scenario = broken['activation_profiles']['scenarios'][name]
                scenario['reads'] = [read for read in scenario['reads'] if read['path'] != R + leaf]
                result = audit_scenarios(broken, ROOT, name)['scenarios'][name]
                self.assertIn('missing_required_read:' + R + leaf, result['errors'])

    def test_exact_conditions_do_not_preload_untriggered_branches(self):
        forbidden = {R + leaf for leaf in ['question-contract.md', 'operator-partnership-contract.md',
            'master-delegation-semantics.md', 'master-workflow-lifecycle.md', 'task-application-loop.md',
            'reporting-agent-handoff.md', 'reporting-pressure-scenarios.md', 'strategic-choice-contract.md']}
        for name in NAMES:
            paths = {read['path'] for read in self.scenarios[name]['reads']}
            self.assertFalse(paths & forbidden, name)
        paths = {read['path'] for read in self.scenarios[NAMES[0]]['reads']}
        packs = {path for path in paths if path.startswith('skills/900-shipglows-core/references/')}
        self.assertEqual(packs, {'skills/900-shipglows-core/references/skill-maintenance-playbook.md'})

    def test_material_work_retains_existing_approval_case(self):
        name = 'common-feature-approval'
        self.assertIn(R + 'mutation-plan-approval.md', self.scenarios[name]['required_reads'])
        broken = copy.deepcopy(self.registry)
        scenario = broken['activation_profiles']['scenarios'][name]
        scenario['reads'] = [read for read in scenario['reads'] if read['path'] != R + 'mutation-plan-approval.md']
        self.assertIn('missing_required_read:' + R + 'mutation-plan-approval.md', audit_scenarios(broken, ROOT, name)['scenarios'][name]['errors'])


if __name__ == '__main__':
    unittest.main()
