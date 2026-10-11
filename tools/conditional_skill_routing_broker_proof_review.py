"""Independent raw replay of the fixed synthetic broker profile proof only."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROOF = ROOT / 'tools/fixtures/conditional_skill_routing/capture-demonstrations/codex-linux-broker-profile-v1-20261007-attempt2'

def sha(raw):
    return hashlib.sha256(raw).hexdigest()

def review(proof=PROOF):
    run = proof / 'workspace/run'
    summary = json.loads((run / 'summary.json').read_bytes())
    for name, row in summary['inventory'].items():
        path = (run / name).resolve()
        assert path.is_relative_to(run.resolve())
        raw = path.read_bytes()
        assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
    original, offered = [], []
    for index in range(1, 6):
        prefix = f'cli-original-{index:03d}'
        raw = (run / f'{prefix}.forwarded-model-request.bin').read_bytes()
        assert raw == (run / f'model-{index:03d}.request.bin').read_bytes()
        left = json.loads((run / f'{prefix}.request.bin').read_bytes())
        right = json.loads(raw)
        assert {k:v for k,v in left.items() if k != 'tools'} == {k:v for k,v in right.items() if k != 'tools'}
        assert [tool['name'] for tool in right['tools']] == ['instruction_read', 'fixture_read', 'simulated_replace']
        assert right['tools'] == [tool for tool in left['tools'] if tool.get('name') in
                                 ('instruction_read', 'fixture_read', 'simulated_replace')]
        original.append(left)
        offered.append(right)
    callbacks = json.loads((run / 'broker-callbacks.json').read_bytes())
    assert len(callbacks) == 3
    for index, row in enumerate(callbacks, 1):
        content = row['reply']['contentItems'][0]['text']
        assert sha(content.encode()) == row['reply_text_sha256']
        assert row['reply']['success'] is True
        for request in offered[index:]:
            matches = [item for item in request['input'] if item.get('type') == 'function_call_output' and item.get('call_id') == row['call_id']]
            assert len(matches) == 1 and matches[0]['output'] == content
    proxy = json.loads((run / 'proxy-receipts.json').read_bytes())
    assert [row['status'] for row in proxy] == [200, 200, 200, 200, 502]
    for index in range(1, 5):
        received = (run / f'cli-original-{index:03d}.received-provider-response.bin').read_bytes()
        emitted = (run / f'cli-original-{index:03d}.emitted-to-cli.bin').read_bytes()
        assert received == emitted == (run / f'model-{index:03d}.provider-response.bin').read_bytes()
    assert proxy[-1]['provider_sse_bytes_emitted_to_cli'] == 0
    assert not (run / 'cli-original-005.emitted-to-cli.bin').exists()
    malicious = (run / 'model-005.provider-response.bin').read_bytes()
    assert b'"name":"exec_command"' in malicious
    rpc = json.loads((run / 'rpc-events.json').read_bytes())
    raw_events = [json.loads(rawline) for path in sorted(run.glob('rpc-stdout-*.bin'))
                  for rawline in path.read_bytes().splitlines() if rawline]
    assert raw_events == rpc['events']
    dynamic = [event for event in raw_events if event.get('method') == 'item/tool/call']
    assert len(dynamic) == 3
    assert [event['params']['callId'] for event in dynamic] == [row['call_id'] for row in callbacks]
    turns = [event['params']['turn'] for event in raw_events if event.get('method') == 'turn/completed']
    assert [turn['status'] for turn in turns] == ['completed', 'failed']
    assert len({event['params']['threadId'] for event in raw_events if event.get('method') == 'turn/completed'}) == 1
    assert not any('commandExecution' in json.dumps(event) for event in raw_events)
    assert json.loads((proof / 'temporary-runtime-cleanup.json').read_bytes())['exists_after_cleanup'] is False
    return {'artifact':'independent-synthetic-broker-profile-review', 'status':'pass',
        'independent_review':True, 'summary_sha256':sha((run / 'summary.json').read_bytes()),
        'inventory_artifacts':len(summary['inventory']), 'requests':5, 'callbacks':3,
        'completed_user_turns':1, 'gate_failed_user_turns':1, 'same_thread':True,
        'checks':{'inventory_rehashed':True, 'only_tools_values_changed':True,
                  'all_exact_callbacks_in_next_and_later_model_requests':True,
                  'native_stream_never_emitted':True, 'raw_rpc_replayed':True,
                  'temporary_binary_removed':True},
        'limits':['Synthetic three-tool fixture only; full H/A/B/S adapter not established here',
                  'Native features remain enabled; trusted provider gate proven, not feature disablement',
                  'No real provider, credential, model retention, AC5 or campaign claim']}

if __name__ == '__main__':
    result = review()
    target = PROOF / 'independent-broker-review.json'
    with target.open('x', encoding='utf-8') as stream:
        json.dump(result, stream, indent=2)
    print(json.dumps(result))
