import copy
import unittest
import tempfile
import json
import base64
from pathlib import Path
from unittest.mock import patch

from tools import conditional_skill_routing_shared_campaign as c
from tools import conditional_skill_routing_runner as r


class SharedCampaignTests(unittest.TestCase):
    def cases(self):
        return [{'id': f'case-{n}', 'posture': 'cold' if n % 2 == 0 else 'continuation',
                 'split': 'tuning' if n < 8 else 'heldout'} for n in range(16)]

    def record(self):
        return {'run_id': 'observed', 'subject_id': 'actual-subject',
                'raw_observation_events': [{'id': 'output-1', 'type': 'response',
                                            'content': 'A paraphrased factual response.'},
                                           {'id': 'checkpoint-1', 'type': 'checkpoint',
                                            'kind': 'Factual explanation delivered'}],
                'final_sensitive_matches': [], 'final_matches_last_recorded_response': True}

    def review(self, record):
        return {'independent': True, 'reviewer': 'distinct-evaluator',
                'record_sha256': c.digest(record), 'protocol_sha256': c.digest(c.PROTOCOL),
                'judgements': {name: {'verdict': 'pass', 'reason': 'Actual evidence preserves intent.',
                                     'event_ids': ['output-1']} for name in c.REVIEW_FIELDS}}

    def test_all_96_slots_and_alternation(self):
        rows = c.schedule(self.cases(), 'campaign')
        self.assertEqual(96, len(rows))
        self.assertEqual(96, len({x['run_id'] for x in rows}))
        self.assertEqual(['baseline', 'candidate', 'candidate', 'baseline', 'baseline', 'candidate'],
                         [x['variant'] for x in rows[:6]])

    def test_paraphrase_review_preserves_events_and_unknown_measurement(self):
        record = self.record(); original = copy.deepcopy(record)
        result = c.semantic_review(record, self.review(record))
        self.assertEqual('pass', result['behavior'])
        self.assertEqual('inconclusive', result['measurement'])
        self.assertEqual('no-go', result['migration'])
        self.assertEqual(original, record)

    def test_semantic_pass_needs_actual_reference(self):
        record = self.record(); review = self.review(record)
        review['judgements']['owner_preserved']['event_ids'] = ['invented']
        with self.assertRaises(r.RunnerError): c.semantic_review(record, review)
        review['judgements']['owner_preserved']['event_ids'] = []
        with self.assertRaises(r.RunnerError): c.semantic_review(record, review)

    def test_failure_is_preserved_and_sensitive_output_fails(self):
        record = self.record(); review = self.review(record)
        review['judgements']['claims_supported']['verdict'] = 'fail'
        self.assertEqual('fail', c.semantic_review(record, review)['behavior'])
        record['final_sensitive_matches'] = [True]
        self.assertEqual('fail', c.semantic_review(record, self.review(record))['behavior'])

    def test_placeholder_and_absent_checkpoints_never_receive_credit(self):
        record = self.record(); record['raw_observation_events'][-1]['kind'] = 'actual checkpoint'
        self.assertEqual('inconclusive', c.semantic_review(record, self.review(record))['behavior'])
        record['raw_observation_events'].pop()
        self.assertEqual('inconclusive', c.semantic_review(record, self.review(record))['behavior'])

    def test_record_and_protocol_identity_bound(self):
        record = self.record(); review = self.review(record)
        review['protocol_sha256'] = '0' * 64
        with self.assertRaises(r.RunnerError): c.semantic_review(record, review)
        review = self.review(record); record['raw_observation_events'][0]['content'] = 'Changed.'
        with self.assertRaises(r.RunnerError): c.semantic_review(record, review)

    def test_completion_requires_unique_sealed_actual_subject_slots(self):
        rows = c.schedule(self.cases(), 'campaign')
        records = [dict(x, sealed=True, subject_id=f'subject-{i}') for i, x in enumerate(rows)]
        self.assertTrue(c.completion(rows, records)['complete'])
        self.assertFalse(c.completion(rows, records[:-1])['complete'])
        with self.assertRaises(r.RunnerError): c.completion(rows, records + [records[0]])
        records[0]['sealed'] = False
        with self.assertRaises(r.RunnerError): c.completion(rows, records)

    def test_generic_exact_change_rejects_unrelated_edits(self):
        self.assertEqual(('State: preview', 'State: experimental'),
                         c.exact_line_change('# Guide\nState: preview\nKeep.\n',
                                             '# Guide\nState: experimental\nKeep.\n'))
        with self.assertRaises(r.RunnerError):
            c.exact_line_change('# Guide\nState: preview\nKeep.\n',
                                '# Guide\nState: experimental\nChanged.\n')

    def test_freeze_author_gate_and_payload_drift(self):
        cases = self.cases(); maps = {x['id']: [] for x in cases}
        raw = b'Frozen synthetic instruction.\n'; source_hash = c.hashlib.sha256(raw).hexdigest()
        manifest = {'sources': [{'id': 'synthetic-source', 'path': 'skills/synthetic.md',
                                'version': 'sha256:' + source_hash, 'source_sha256': source_hash,
                                'bytes_base64': base64.b64encode(raw).decode()}], 'thresholds': {'fixed': .15},
                    'subject_resources': {v: {'case_maps': maps} for v in ('baseline', 'candidate')}}
        heldout = [x for x in cases if x['split'] == 'heldout']
        with tempfile.TemporaryDirectory() as temp:
            directory = Path(temp) / 'freeze'
            with self.assertRaises(r.RunnerError):
                c.freeze_campaign(directory, manifest, cases, 'campaign')
            self.assertFalse(directory.exists())
            with patch.object(c, 'prepare_adapter'):
                c.freeze_campaign(directory, manifest, cases, 'campaign', author_freeze_approved=True)
            self.assertTrue(c.verify_frozen_campaign(directory, sealed_cases=heldout)['valid'])
            protocol = json.loads((directory / 'protocol.json').read_text(encoding='utf8'))
            protocol['schema_version'] = 999
            (directory / 'protocol.json').write_text(json.dumps(protocol), encoding='utf8')
            with self.assertRaises(r.RunnerError): c.verify_frozen_campaign(directory, sealed_cases=heldout)


if __name__ == '__main__': unittest.main()
