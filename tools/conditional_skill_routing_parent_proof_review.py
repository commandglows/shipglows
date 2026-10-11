"""Independent replay of the synthetic Windows-parent/WSL-relay proof."""
import base64
import hashlib
import io
import json
from pathlib import Path
from tools.conditional_skill_routing_parent_transport import decoded, read_frame, read_response, verify

ROOT = Path(__file__).resolve().parents[1]
PROOF = ROOT / 'tools/fixtures/conditional_skill_routing/capture-demonstrations/parent-relay-wsl-bwrap-v1-20261007-attempt1'

def review(proof=PROOF):
    summary_raw = (proof / 'summary.json').read_bytes()
    summary = decoded(summary_raw)
    for name, item in summary['inventory'].items():
        path = (proof / name).resolve()
        assert path.is_relative_to(proof.resolve())
        raw = path.read_bytes()
        assert len(raw) == item['bytes'] and hashlib.sha256(raw).hexdigest() == item['sha256']
    bootstrap = decoded(read_frame(io.BytesIO((proof / 'bootstrap-frame.bin').read_bytes())))
    key = base64.b64decode(bootstrap['channel_key'], validate=True)
    request = verify(decoded((proof / 'parent-received-request-envelope.bin').read_bytes()), key)
    request_body = base64.b64decode(request['body_b64'], validate=True)
    assert request_body == base64.b64decode(bootstrap['body_b64'], validate=True)
    assert hashlib.sha256(request_body).hexdigest() == request['body_sha256']
    response_raw = (proof / 'parent-response-envelope.bin').read_bytes()
    response = read_response(response_raw, key, request['id'])
    assert read_frame(io.BytesIO((proof / 'parent-response-frame.bin').read_bytes())) == response_raw
    raw_stdout = b''.join(path.read_bytes() for path in sorted(proof.glob('relay-stdout-chunk-*.bin')))
    stream = io.BytesIO(raw_stdout)
    assert read_frame(stream) == (proof / 'relay-preflight-envelope.bin').read_bytes()
    assert read_frame(stream) == (proof / 'parent-received-request-envelope.bin').read_bytes()
    assert read_frame(stream) == (proof / 'relay-completion-envelope.bin').read_bytes()
    assert read_frame(stream) is None
    diagnostic = decoded((proof / 'relay-preflight-envelope.bin').read_bytes())['diagnostic']
    assert diagnostic['interfaces'] == ['lo'] and diagnostic['nonloopback_errno'] == 101
    assert all(diagnostic[key] is False for key in ('parent_sentinel_visible', 'mnt_visible', 'host_run_visible',
                                                  'credential_or_evaluator_environment_present'))
    negatives = decoded((proof / 'negative-observations.json').read_bytes())
    assert {row['kind'] for row in negatives} == {'replay', 'unauthenticated', 'partial_frame'}
    assert all(row['refused'] is True for row in negatives)
    launch = decoded((proof / 'launch.json').read_bytes())
    assert '--unshare-all' in json.dumps(launch) and '--clearenv' in json.dumps(launch)
    assert summary['checks']['temporary_parent_state_removed'] is True
    return {'artifact':'independent-synthetic-parent-relay-review', 'status':'pass', 'independent_review':True,
            'summary_sha256':hashlib.sha256(summary_raw).hexdigest(), 'inventory_artifacts':len(summary['inventory']),
            'checks':{'inventory_rehashed':True, 'exact_authenticated_framing_replayed':True,
                      'raw_child_stdout_reconstructed':True, 'actual_namespace_diagnostics_verified':True,
                      'negative_admission_receipts_retained':True},
            'limits':['Synthetic Python relay only; integrated Codex and HTTPS path not proved here',
                      'Channel authentication is not model authority; receipt signing key remains parent-owned',
                      'No real provider, secret or evaluator-heldout payload used']}

def review_integrated(proof):
    """Replay the actual CLI/Windows-parent mocked exchange separately."""
    proof = Path(proof)
    run = proof / 'workspace/run'
    summary_raw = (proof / 'summary.json').read_bytes()
    summary = decoded(summary_raw)
    for name, item in summary['inventory'].items():
        path = (proof / name).resolve()
        assert path.is_relative_to(proof.resolve())
        raw = path.read_bytes()
        assert len(raw) == item['bytes'] and hashlib.sha256(raw).hexdigest() == item['sha256']
    bootstrap = decoded(read_frame(io.BytesIO((proof / 'bootstrap-frame.bin').read_bytes())))
    key = base64.b64decode(bootstrap['channel_key'], validate=True)
    facts = decoded(read_frame(io.BytesIO((proof / 'child-frame-000.bin').read_bytes())))['facts']
    assert facts['interfaces'] == ['lo'] and facts['nonloopback_probe_errno'] == 101
    offered = []
    for index in range(1, 6):
        wire = read_frame(io.BytesIO((proof / f'child-frame-{index:03d}.bin').read_bytes()))
        request = verify(decoded(wire), key)
        raw = base64.b64decode(request['body_b64'], validate=True)
        assert hashlib.sha256(raw).hexdigest() == request['body_sha256']
        assert raw == (proof / f'windows-model-{index:03d}.request.bin').read_bytes()
        assert raw == (run / f'cli-original-{index:03d}.forwarded-model-request.bin').read_bytes()
        left = decoded((run / f'cli-original-{index:03d}.request.bin').read_bytes())
        right = decoded(raw)
        assert {k:v for k,v in left.items() if k != 'tools'} == {k:v for k,v in right.items() if k != 'tools'}
        assert right['tools'] == [tool for tool in left['tools'] if tool.get('name') in
                                 ('instruction_read', 'fixture_read', 'simulated_replace')]
        offered.append(right)
        response = read_response(read_frame(io.BytesIO((proof / f'parent-frame-{index:03d}.bin').read_bytes())), key, request['id'])
        if index < 5:
            assert response['status'] == 200
            assert response['body'] == (proof / f'windows-model-{index:03d}.response.bin').read_bytes()
            assert response['body'] == (run / f'cli-original-{index:03d}.emitted-to-cli.bin').read_bytes()
        else:
            assert response['status'] == 502 and b'exec_command' in (proof / 'windows-model-005.response.bin').read_bytes()
            assert not (run / 'cli-original-005.emitted-to-cli.bin').exists()
    callbacks = decoded((run / 'broker-callbacks.json').read_bytes())
    assert len(callbacks) == 3
    for index, row in enumerate(callbacks, 1):
        content = row['reply']['contentItems'][0]['text']
        for request in offered[index:]:
            outputs = [item for item in request['input'] if item.get('type') == 'function_call_output' and item.get('call_id') == row['call_id']]
            assert len(outputs) == 1 and outputs[0]['output'] == content
    rpc = decoded((run / 'rpc-events.json').read_bytes())['events']
    raw_rpc = [decoded(line) for path in sorted(run.glob('rpc-stdout-*.bin')) for line in path.read_bytes().splitlines() if line]
    assert rpc == raw_rpc
    assert len([event for event in rpc if event.get('method') == 'item/tool/call']) == 3
    assert [event['params']['turn']['status'] for event in rpc if event.get('method') == 'turn/completed'] == ['completed', 'failed']
    assert not any('commandExecution' in json.dumps(event) for event in rpc)
    assert decoded((proof / 'temporary-runtime-cleanup.json').read_bytes())['exists_after_cleanup'] is False
    return {'artifact':'independent-integrated-cli-parent-review', 'status':'pass', 'independent_review':True,
            'summary_sha256':hashlib.sha256(summary_raw).hexdigest(), 'inventory_artifacts':len(summary['inventory']),
            'checks':{'inventory_rehashed':True, 'authenticated_parent_requests_exact':True,
                      'registered_tool_schemas_unchanged':True, 'input_and_instructions_unchanged':True,
                      'all_exact_callbacks_in_next_and_later_requests':True, 'native_stream_not_released':True,
                      'raw_rpc_replayed':True, 'temporary_binary_removed':True},
            'limits':['Three synthetic tools; full case-owned parent adapter requires separate proof',
                      'No real provider, account, semantic AC5 or internal model-retention claim']}

if __name__ == '__main__':
    result = review()
    source = Path(__file__).read_bytes()
    (PROOF / 'independent-parent-review-source.py').write_bytes(source)
    result['review_source_sha256'] = hashlib.sha256(source).hexdigest()
    with (PROOF / 'independent-parent-review.json').open('x', encoding='utf-8') as stream:
        json.dump(result, stream, indent=2)
    print(json.dumps(result))
