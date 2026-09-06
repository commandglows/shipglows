"""Evidence accounting: unknown delivery, source drift and overlapping reads."""
import hashlib
from pathlib import Path
import tempfile
import unittest

from tools.skill_activation_budget import audit_trace


class ObservedTraceTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / 'rules.md').write_text('abcdefghij' * 10, encoding='utf-8')
        self.digest = hashlib.sha256((self.root / 'rules.md').read_bytes()).hexdigest()

    def event(self, chars, extent='partial'):
        return dict(path='rules.md', reason='Observed tool output', extent=extent,
                    delivered_characters=chars, source_sha256=self.digest)

    def measure(self, *events):
        return audit_trace(dict(schema_version=2, events=list(events)), self.root)

    def test_legacy_full_read_totals_are_unchanged(self):
        result = audit_trace({'events': [dict(path='rules.md', reason='Read')] * 2}, self.root)
        self.assertEqual((result['unique_tokens'], result['repeated_tokens'], result['total_tokens']), (25, 25, 50))

    def test_partial_and_truncated_delivery_use_observation_not_source_size(self):
        result = self.measure(self.event(12), self.event(5, 'truncated'))
        self.assertEqual(result['total_tokens'], 5)
        self.assertEqual(result['repeated_path_events'], 1)
        self.assertIsNone(result['unique_tokens'])  # overlap cannot be inferred from a path
        self.assertEqual(result['measurement_status'], 'complete')

    def test_unknown_delivery_does_not_become_zero_or_full_file(self):
        result = self.measure(self.event(12), self.event(None, 'truncated'))
        self.assertEqual(result['known_tokens'], 3)
        self.assertEqual(result['unmeasured_events'], 1)
        self.assertIsNone(result['total_tokens'])
        self.assertEqual(result['measurement_status'], 'incomplete')

    def test_source_drift_invalidates_comparison(self):
        (self.root / 'rules.md').write_text('changed', encoding='utf-8')
        result = self.measure(self.event(12))
        self.assertEqual(result['status'], 'invalid')
        self.assertIn('event:0:source_hash_mismatch', result['errors'])
        self.assertIsNone(result['total_tokens'])

    def test_invalid_counts_hashes_extents_and_missing_measurements_fail(self):
        for changes in ({'delivered_characters': True}, {'delivered_characters': -1},
                        {'delivered_characters': 1.5}, {'source_sha256': ''},
                        {'extent': 'guessed'}):
            with self.subTest(changes=changes):
                event = self.event(12)
                event.update(changes)
                self.assertEqual(self.measure(event)['status'], 'invalid')
        event = self.event(12)
        del event['delivered_characters']
        self.assertEqual(self.measure(event)['status'], 'invalid')

    def test_escape_and_unknown_version_fail(self):
        event = self.event(12)
        event['path'] = '../outside.md'
        self.assertEqual(self.measure(event)['status'], 'invalid')
        for version in (3, True, 1.0, '2', None):
            self.assertEqual(audit_trace({'schema_version': version, 'events': []}, self.root)['status'], 'invalid')


if __name__ == '__main__':
    unittest.main()
