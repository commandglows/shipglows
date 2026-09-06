"""Preservation and selection proof for shared authority/reporting compaction."""
import copy
import hashlib
import json
import unittest
from pathlib import Path

from tools.authority_contract_test_support import selected_authority
from tools.skill_activation_budget import audit_scenarios

ROOT = Path(__file__).resolve().parents[1]
REFS = ROOT / 'skills/references'


class SharedAuthorityReportingLoadingTests(unittest.TestCase):
    def test_extracted_policy_sections_are_verbatim(self):
        manifest = json.loads((ROOT / 'tools/fixtures/mutation_authority_extracted_sections.json').read_text())
        for name, frozen in manifest.items():
            body = (REFS / f'{name}.md').read_text(encoding='utf-8').split('---', 2)[2].lstrip('\n')
            self.assertEqual(hashlib.sha256(body.encode()).hexdigest(), frozen['sha256'], name)

    def test_selectors_precede_sensitive_actions(self):
        core = selected_authority()
        for marker in (
            'Before any Auto candidate or write',
            'Auto/nolocal prohibitions still apply',
            'drafting a technical plan that discloses Git persistence',
            'Before selecting or promising an integration destination',
            'before executing an approved milestone or final delivery',
            'only for maintenance, audit or testing',
            'No spec, tracker, plan file, branch, backup',
            'Neutral acknowledgements',
            'Any material change to scope',
        ):
            self.assertIn(marker, core)
        self.assertNotIn('MAP-GIT-STANDING-AUTHORITY', core)
        self.assertNotIn('The same invocation authorizes bounded subagents', core)
        auto = selected_authority('mutation-auto-authority')
        self.assertIn('never permits', auto)
        self.assertIn('modify its own authority', auto)

    def test_authority_witnesses_fail_if_selected_branch_is_omitted(self):
        registry = json.loads((REFS / 'skill-invocation-registry.json').read_text(encoding='utf-8'))
        for name, leaf in (
            ('authority-auto-selection', 'mutation-auto-authority'),
            ('authority-git-selection', 'mutation-git-authority'),
            ('common-feature-approval', 'mutation-git-authority'),
        ):
            selected = copy.deepcopy(registry)
            scenario = selected['activation_profiles']['scenarios'][name]
            path = f'skills/references/{leaf}.md'
            self.assertIn(path, scenario['required_reads'])
            self.assertEqual(audit_scenarios(selected, ROOT, name)['status'], 'valid')
            scenario['reads'] = [r for r in scenario['reads'] if r['path'] != path]
            self.assertEqual(audit_scenarios(selected, ROOT, name)['status'], 'invalid')

    def test_bounded_capture_does_not_eagerly_load_unselected_authorities(self):
        registry = json.loads((REFS / 'skill-invocation-registry.json').read_text(encoding='utf-8'))
        scenario = registry['activation_profiles']['scenarios']['planning-task-capture']
        paths = {r['path'] for r in scenario['reads']}
        for leaf in ('mutation-auto-authority', 'mutation-git-authority', 'mutation-approval-pressure-scenarios'):
            self.assertNotIn(f'skills/references/{leaf}.md', paths)
        self.assertIn('skills/references/mutation-plan-approval.md', paths)

    def test_reporting_preserves_claim_and_restart_safeguards(self):
        report = (REFS / 'reporting-contract.md').read_text(encoding='utf-8')
        for marker in ('Stabilize and deliver', 'focused mechanical proof',
                       'and one blank line', 'not caller identity or blockers',
                       'Include only checks actually run', 'Never expose secrets'):
            self.assertIn(marker, report)


if __name__ == '__main__':
    unittest.main()
