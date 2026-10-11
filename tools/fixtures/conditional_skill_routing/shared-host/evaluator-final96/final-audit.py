"""Independent post-campaign evidence audit; never changes frozen inputs."""
import base64
import collections
import hashlib
import json
from pathlib import Path
import time
import unicodedata

from tools import conditional_skill_routing_shared_campaign as c

p = Path('tools/fixtures/conditional_skill_routing')
f = p / 'shared-host/evaluator-final96'
load = lambda q: json.loads(q.read_text(encoding='utf-8-sig'))
sha = lambda b: hashlib.sha256(b).hexdigest()
encode = lambda x: json.dumps(x, ensure_ascii=False, sort_keys=True, indent=2).encode('utf-8')
cases = load(p / 'cases.json')['cases'] + load(p / 'evaluator-cases.json')['cases']
caseby = {x['id']: x for x in cases}
rows = load(f / 'schedule.json')['rows']
rs = {x['run_id']: load(p / 'shared-host' / x['run_id'] / 'record.json') for x in rows}
freeze = c.verify_frozen_campaign(f, sealed_cases=[x for x in cases if x['split'] == 'heldout'])
done = c.completion(rows, list(rs.values()))
m = load(f / 'manifest.json')
receipt = load(f / 'freeze-receipt.json')
protocol_text = json.dumps(c.PROTOCOL, ensure_ascii=False)
protocol_text_sha = sha(protocol_text.encode('utf-8'))
matrix, full, physical, inventory, receiptchecks = [], [], [], [], []
pairs = collections.defaultdict(list)
for x in m['sources']:
    assert sha(base64.b64decode(x['bytes_base64'])) == x['source_sha256']
    q = Path(x['path'])
    if q.exists() and sha(q.read_bytes()) != x['source_sha256']:
        physical.append({'resource_id': x['id'], 'path': x['path'],
                         'frozen_snapshot_sha256': x['source_sha256'],
                         'current_physical_sha256': sha(q.read_bytes()),
                         'effect': 'Frozen source snapshot unchanged; live host correspondence unproved.'})
for row in rows:
    rid = row['run_id']
    r = rs[rid]
    directory = p / 'shared-host' / rid
    d = load(f / (rid + '-semantic-review.json'))
    g = c.grade_case(r, caseby[row['case_id']], d['review'])
    assert g == d['grade'], rid
    assert r['max_requests'] == 100
    assert r['protocol_sha256'] == protocol_text_sha
    assert r['manifest_sha256'] == c.digest(m)
    envelope = (directory / 'initial-envelope.txt').read_bytes()
    assert r['initial_envelope_sha256'] == sha(envelope)
    assert protocol_text.encode('utf-8') in envelope
    assert r['initial_adapter_source_sha256'] == receipt['adapter_source_hashes']['conditional_skill_routing_shared.py']
    assert r['export_receipt']['case_sha256'] == c.digest(caseby[row['case_id']])
    pairs[row['pair_id']].append(row)
    full.append({'run_id': rid, 'case_id': row['case_id'], 'split': caseby[row['case_id']]['split'],
                 'variant': row['variant'], 'repetition': row['repetition'], 'subject_id': r['subject_id'],
                 'sealed': True, 'observed_task_outcome': d['observed_task_outcome'],
                 'formal_behavior': g['behavior'], 'record_sha256': c.digest(r),
                 'review_sha256': c.digest(d), 'events': len(r['raw_observation_events']),
                 'requests': r['requests'], 'callback_refusal_files': d.get('actual_callback_refusal_files', []),
                 'measurement': 'inconclusive', 'strict_eligible': False,
                 'started_ns': r['started_ns'], 'ended_ns': r['ended_ns']})
    for q in directory.glob('*.receipt.json'):
        z = load(q)
        for kind in ['request', 'stdout']:
            b = q.with_name(q.name.replace('.receipt.json', '.' + kind + '.bin'))
            actual, original = sha(b.read_bytes()), z[kind + '_sha256']
            changed = actual != original
            if changed:
                assert z['private_sanitization'] and any(z[kind + '_sensitive_matches'])
            receiptchecks.append({'path': b.as_posix(), 'original_sha256': original,
                                  'durable_sha256': actual, 'original_digest_equals_durable': not changed,
                                  'sanitized_private_bytes': changed})
    for q in sorted(directory.rglob('*')):
        if q.is_file():
            inventory.append({'path': q.as_posix(), 'bytes': q.stat().st_size, 'sha256': sha(q.read_bytes())})
for pid, z in pairs.items():
    a, b = z
    assert [a['variant'], b['variant']] == (['candidate', 'baseline'] if a['repetition'] == 2 else ['baseline', 'candidate'])
    assert rs[a['run_id']]['ended_ns'] <= rs[b['run_id']]['started_ns'], pid
for cid in dict.fromkeys(x['case_id'] for x in rows):
    item = {'case_id': cid, 'split': caseby[cid]['split']}
    for v in ['baseline', 'candidate']:
        z = [x for x in full if x['case_id'] == cid and x['variant'] == v]
        assert len(z) == 3
        item[v] = {'observed': dict(collections.Counter(x['observed_task_outcome'] for x in z)),
                   'formal': dict(collections.Counter(x['formal_behavior'] for x in z))}
    matrix.append(item)
totals = {}
for v in ['baseline', 'candidate']:
    z = [x for x in full if x['variant'] == v]
    totals[v] = {'observed': dict(collections.Counter(x['observed_task_outcome'] for x in z)),
                 'formal': dict(collections.Counter(x['formal_behavior'] for x in z))}
canon = lambda s: ''.join(ch for ch in unicodedata.normalize('NFKC', s).casefold() if unicodedata.category(ch) != 'Cf')
scanned, matches = 0, []
private = [x for x in rows if x['case_id'].startswith('S')]
assert len(private) == 24
for row in private:
    directory = p / 'shared-host' / row['run_id']
    r = rs[row['run_id']]
    assert not (directory / 'state.trusted.pickle').exists()
    assert not any(r['final_sensitive_matches'])
    assert not any(any(t) for t in r['response_sensitive_matches'])
    marks = [canon(x) for x in caseby[row['case_id']]['expected']['sensitive_markers']]
    for q in directory.rglob('*'):
        if q.is_file():
            scanned += 1
            content = canon(q.read_bytes().decode('utf-8', 'ignore'))
            if any(x in content for x in marks):
                matches.append(q.as_posix())
assert not matches
audit = {'completed_ns': time.time_ns(), 'completion': done, 'independently_scored': 96,
         'cases': 16, 'repetitions': 3, 'variants': 2, 'pairs': 48,
         'pair_alternation': 'B/C rep1 and rep3; C/B rep2',
         'all_within_pair_first_terminal_sealed_before_second_prepared': True,
         'unique_subject_ids': 96, 'fresh_native_subject_launches': 96, 'fork_turns': 'none',
         'effective_isolation': 'absent', 'fresh_model_provider_context_proof': 'unknown',
         'terminal_active_subjects': 0, 'freeze_validation': freeze,
         'frozen_source_snapshot_hashes_all_valid': True,
         'live_physical_correspondence_differences': physical,
         'protocol_identical_for_all96': True, 'protocol_object_sha256': c.digest(c.PROTOCOL),
         'protocol_rendered_text_sha256': protocol_text_sha, 'same_max_requests': 100,
         'record_and_review_hash_links_valid': True, 'actual_event_links_valid': True,
         'receipts_checked': len(receiptchecks) // 2,
         'sanitized_original_to_durable_digest_differences': sum(x['sanitized_private_bytes'] for x in receiptchecks),
         'unexpected_receipt_digest_differences': 0,
         'privacy': {'synthetic_private_runs': 24, 'private_pickle_states_remaining': 0,
                     'known_marker_durable_files_scanned': scanned, 'known_marker_durable_matches': 0,
                     'all_final_and_intermediate_captured_responses_known_marker_free': True,
                     'scan_scope': 'NFKC/casefold/Cf-stripped known synthetic markers in durable run files; unknown native extra access excluded'},
         'totals': totals, 'matrix': matrix, 'runs': full, 'thresholds': m['thresholds'],
         'measurement': 'inconclusive', 'budget': 'inconclusive', 'migration': 'no-go',
         'strict_isolated_pilot_eligible': False, 'author_blind_until_independent_scoring_complete': True,
         'candidate_edits_after_freeze': False, 'automatic_draft_callback_boundary_corrections': 2,
         'original_failure_records_preserved': True, 'coordinator_utf8_incidents': 1,
         'restart_or_repair_after_observation': False}
for name, obj in [('completion-audit.json', audit), ('receipt-digest-audit.json', {'entries': receiptchecks}),
                  ('durable-artifact-inventory.json', {'entries': inventory})]:
    with (f / name).open('xb') as stream:
        stream.write(encode(obj))
(f / 'current-progress.json').write_bytes(encode({'expected': 96, 'sealed': 96, 'independently_scored': 96,
    'active_handles': [], 'active_status_verified': 'None; last subject terminal confirmed through native agent registry.',
    'verified_ns': time.time_ns(), 'model_call_total': 'unknown', 'author_payloads_disclosed': False,
    'strict_isolated_pilot_eligible': False}))
print(json.dumps({'completion': done, 'independently_scored': 96, 'pairs': 48, 'totals': totals,
    'unexpected_receipt_digest_differences': 0, 'sanitized_digest_differences': audit['sanitized_original_to_durable_digest_differences'],
    'live_physical_source_differences': len(physical), 'inventory_files': len(inventory), 'privacy': audit['privacy']}))
